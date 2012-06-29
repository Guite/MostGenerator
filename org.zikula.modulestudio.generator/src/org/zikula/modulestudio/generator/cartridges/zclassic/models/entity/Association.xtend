package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.CascadeType
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.RelationFetchType
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Association {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    FileHelper fh = new FileHelper()

    /**
     * If we have an outgoing association useTarget is true; for an incoming one it is false.
     */
    def generate(JoinRelationship it, Boolean useTarget) {
        val sourceName = getRelationAliasName(false)
        val targetName = getRelationAliasName(true)
        val entityClass = (if (useTarget) target else source).implClassModelEntity
        directionSwitch(useTarget, sourceName, targetName, entityClass)
    }

    def private directionSwitch(JoinRelationship it, Boolean useTarget, String sourceName, String targetName, String entityClass) {
        if (!bidirectional)
            unidirectional(useTarget, sourceName, targetName, entityClass)
        else
            bidirectional(useTarget, sourceName, targetName, entityClass)
    }

    def private unidirectional(JoinRelationship it, Boolean useTarget, String sourceName, String targetName, String entityClass) '''
        «IF useTarget»
            «IF source == target»
                /**
                 * Self relations were not working yet, must be retested with Doctrine 2.
                 * See #9 for more information
                 */
            «ENDIF»
            «outgoing(sourceName, targetName, entityClass)»
        «ENDIF»
    '''

    def private bidirectional(JoinRelationship it, Boolean useTarget, String sourceName, String targetName, String entityClass) '''
        «IF source == target»
            /**
             * Self relations were not working yet, must be retested with Doctrine 2.
             * See #9 for more information
             */
        «ENDIF»
        «IF !useTarget»
            «incoming(sourceName, targetName, entityClass)»
        «ELSE»
            «outgoing(sourceName, targetName, entityClass)»
        «ENDIF»
    '''


    def private dispatch incoming(JoinRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * Bidirectional - «incomingMappingDescription(it, sourceName, targetName)».
         *
        «incomingMappingDetails»
         * @ORM\«incomingMappingType»(targetEntity="«entityClass»", inversedBy="«targetName»"«additionalOptions(true)»)
        «joinDetails(false)»
         * @var «entityClass» $«sourceName».
         */
        protected $«sourceName»;
        «/* this last line is on purpose */»
    '''

    def private dispatch incomingMappingDescription(JoinRelationship it, String sourceName, String targetName) {
    	switch it {
            OneToOneRelationship: '''One «targetName» [«target.name.formatForDisplay»] is linked by one «sourceName» [«source.name.formatForDisplay»] (INVERSE SIDE)'''
            OneToManyRelationship: '''Many «targetName» [«target.nameMultiple.formatForDisplay»] are linked by one «sourceName» [«source.name.formatForDisplay»] (OWNING SIDE)'''
    	    default: ''
    	}
    }
    def private incomingMappingDetails(JoinRelationship it) {
    	switch it {
            OneToOneRelationship case it.primaryKey: ''' * @ORM\Id'''
    	    default: ''
    	}
    }
    def private incomingMappingType(JoinRelationship it) {
    	switch it {
            OneToOneRelationship: 'OneToOne'
            OneToManyRelationship: 'ManyToOne'
    	    default: ''
    	}
    }

    def private dispatch incoming(ManyToOneRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * Bidirectional - «incomingMappingDescription(it, sourceName, targetName)».
         *
         «IF primaryKey»
             * @ORM\Id
         «ENDIF»
         * @ORM\OneToOne(targetEntity="«entityClass»")
        «joinDetails(false)»
         * @var «entityClass» $«sourceName».
         */
        protected $«sourceName»;
        «/* this last line is on purpose */»
    '''

    def private dispatch incomingMappingDescription(ManyToOneRelationship it, String sourceName, String targetName) '''One «targetName» [«target.name.formatForDisplay»] is linked by many «sourceName» [«source.nameMultiple.formatForDisplay»] (INVERSE SIDE)'''

    def private dispatch incoming(ManyToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        «IF bidirectional»
            /**
             * Bidirectional - «incomingMappingDescription(sourceName, targetName)».
             *
             * @ORM\ManyToMany(targetEntity="«entityClass»", mappedBy="«targetName»"«additionalOptions(true)»)
             * @var «entityClass»[] $«sourceName».
             */
            protected $«sourceName» = null;
        «ENDIF»
    '''

    def private dispatch incomingMappingDescription(ManyToManyRelationship it, String sourceName, String targetName) '''Many «targetName» [«target.nameMultiple.formatForDisplay»] are linked by many «sourceName» [«source.nameMultiple.formatForDisplay»] (INVERSE SIDE)'''

    /**
     * This default rule is used for OneToOne and ManyToOne.
     */
    def private dispatch outgoing(JoinRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         *
         * @ORM\«outgoingMappingType»(targetEntity="«entityClass»"«IF bidirectional», mappedBy="«sourceName»"«ENDIF»«fetchTypeTag»«outgoingMappingAdditions»)
        «joinDetails(true)»
         * @var «entityClass» $«targetName».
         */
        protected $«targetName»;
        «/* this last line is on purpose */»
    '''

    def private dispatch outgoingMappingDescription(JoinRelationship it, String sourceName, String targetName) {
    	switch (it) {
            OneToOneRelationship: '''One «sourceName» [«source.name.formatForDisplay»] has one «targetName» [«target.name.formatForDisplay»] (INVERSE SIDE)'''
            ManyToOneRelationship: '''Many «sourceName» [«source.nameMultiple.formatForDisplay»] have one «targetName» [«target.name.formatForDisplay»] (OWNING SIDE)'''
    	    default: ''
    	}
    }
    def private outgoingMappingType(JoinRelationship it) {
    	switch (it) {
            OneToOneRelationship: 'OneToOne'
            ManyToOneRelationship: 'ManyToOne'
    	    default: ''
    	}
    }

    def private dispatch outgoingMappingAdditions(JoinRelationship it) {
    }
    def private dispatch outgoingMappingAdditions(OneToOneRelationship it) {
        if (orphanRemoval) ', orphanRemoval=true'
    }

    def private dispatch outgoing(OneToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         *
         «IF !bidirectional»
          * @ORM\ManyToMany(targetEntity="«entityClass»"«additionalOptions(false)»)
         «ELSE»
          * @ORM\OneToMany(targetEntity="«entityClass»", mappedBy="«sourceName»"«additionalOptions(false)»«IF orphanRemoval», orphanRemoval=true«ENDIF»«IF indexBy != null && indexBy != ''», indexBy="«indexBy»"«ENDIF»)
         «ENDIF»
        «joinDetails(true)»
         «IF orderBy != null && orderBy != ''»
          * @ORM\OrderBy({"«orderBy»" = "ASC"})
         «ENDIF»
         * @var «entityClass»[] $«targetName».
         */
        protected $«targetName» = null;
        «/* this last line is on purpose */»
    '''

    def private dispatch outgoingMappingDescription(OneToManyRelationship it, String sourceName, String targetName) '''One «sourceName» [«source.name.formatForDisplay»] has many «targetName» [«target.nameMultiple.formatForDisplay»] (INVERSE SIDE)'''

    def private dispatch outgoing(ManyToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         *
         * @ORM\ManyToMany(targetEntity="«entityClass»"«IF bidirectional», inversedBy="«sourceName»"«ENDIF»«additionalOptions(false)»«IF indexBy != null && indexBy != ''», indexBy="«indexBy»"«ENDIF»)
        «joinDetails(true)»
         «IF orderBy != null && orderBy != ''»
          * @ORM\OrderBy({"«orderBy»" = "ASC"})
         «ENDIF»
         * @var «entityClass»[] $«targetName».
         */
        protected $«targetName» = null;
    '''

    def private dispatch outgoingMappingDescription(ManyToManyRelationship it, String sourceName, String targetName) '''Many «sourceName» [«source.nameMultiple.formatForDisplay»] have many «targetName» [«target.nameMultiple.formatForDisplay»] (OWNING SIDE)'''


    def private joinDetails(JoinRelationship it, Boolean useTarget) {
        val joinedEntityLocal = { if (useTarget) source else target }
        val joinedEntityForeign = { if (useTarget) target else source }
        val joinColumnsLocal = { if (useTarget) getSourceFields else getTargetFields }
        val joinColumnsForeign = { if (useTarget) getTargetFields else getSourceFields }
        val foreignTableName = fullJoinTableName(useTarget, joinedEntityForeign)
        if (joinColumnsForeign.containsDefaultIdField(joinedEntityForeign) && joinColumnsLocal.containsDefaultIdField(joinedEntityLocal)
   	    && !unique && nullable && onDelete == '' && onUpdate == '') ''' * @ORM\JoinTable(name="«foreignTableName»")'''
        else ''' * @ORM\JoinTable(name="«foreignTableName»",
        «joinTableDetails(useTarget)»
             * )'''
    }

    def private joinTableDetails(JoinRelationship it, Boolean useTarget) {
        val joinedEntityLocal = { if (useTarget) source else target }
        val joinedEntityForeign = { if (useTarget) target else source }
        val joinColumnsLocal = { if (useTarget) getSourceFields else getTargetFields }
        val joinColumnsForeign = { if (useTarget) getTargetFields else getSourceFields }
        if (joinColumnsForeign.size > 1) joinColumnsMultiple(useTarget, joinedEntityLocal, joinColumnsLocal)
        else joinColumnsSingle(useTarget, joinedEntityLocal, joinColumnsLocal)
        if (joinColumnsForeign.size > 1) ''' *      inverseJoinColumns={«FOR joinColumnForeign : joinColumnsForeign SEPARATOR ', '»«joinColumn(joinColumnForeign, joinedEntityForeign.getFirstPrimaryKey.name.formatForDB, useTarget)»«ENDFOR»}'''
        else ''' *      inverseJoinColumns={«joinColumn(joinColumnsForeign.head, joinedEntityForeign.getFirstPrimaryKey.name.formatForDB, useTarget)»}'''
    }

    def private joinColumnsMultiple(JoinRelationship it, Boolean useTarget, Entity joinedEntityLocal, String[] joinColumnsLocal) ''' *      joinColumns={«FOR joinColumnLocal : joinColumnsLocal SEPARATOR ', '»«joinColumn(joinColumnLocal, joinedEntityLocal.getFirstPrimaryKey.name.formatForDB, !useTarget)»«ENDFOR»},'''

    def private joinColumnsSingle(JoinRelationship it, Boolean useTarget, Entity joinedEntityLocal, String[] joinColumnsLocal) ''' *      joinColumns={«joinColumn(joinColumnsLocal.head, joinedEntityLocal.getFirstPrimaryKey.name.formatForDB, !useTarget)»},'''

    def private joinColumn(JoinRelationship it, String columnName, String referencedColumnName, Boolean useTarget) '''
        @ORM\JoinColumn(name="«joinColumnName(columnName, useTarget)»", referencedColumnName="«referencedColumnName»" «IF unique», unique=true«ENDIF»«IF !nullable», nullable=false«ENDIF»«IF onDelete != ''», onDelete="«onDelete»"«ENDIF»«IF onUpdate != ''», onUpdate="«onUpdate»"«ENDIF»)
    '''

    def private joinColumnName(JoinRelationship it, String columnName, Boolean useTarget) {
        switch it {
            ManyToManyRelationship case columnName == 'id': (if (useTarget) target else source).name.formatForDB + '_id'
            default: columnName
        }
    }

    def private additionalOptions(JoinRelationship it, Boolean useReverse) '''«cascadeOptions(useReverse)»«fetchTypeTag»'''
    def private cascadeOptions(JoinRelationship it, Boolean useReverse) {
        val cascadeProperty = { if (useReverse) cascadeReverse else cascade }
        if (cascadeProperty == CascadeType::NONE) ''
        else ''', cascade={«cascadeOptionsImpl(useReverse)»}'''
    }

    def private fetchTypeTag(JoinRelationship it) { if (fetchType != RelationFetchType::LAZY) ''', fetch="«fetchType.asConstant»"''' }

    def private cascadeOptionsImpl(JoinRelationship it, Boolean useReverse) {
        val cascadeProperty = { if (useReverse) cascadeReverse else cascade }
        if (cascadeProperty == CascadeType::PERSIST) '"persist"'
        else if (cascadeProperty == CascadeType::REMOVE) '"remove"'
        else if (cascadeProperty == CascadeType::MERGE) '"merge"'
        else if (cascadeProperty == CascadeType::DETACH) '"detach"'
        else if (cascadeProperty == CascadeType::PERSIST_REMOVE) '"persist", "remove"'
        else if (cascadeProperty == CascadeType::PERSIST_MERGE) '"persist", "merge"'
        else if (cascadeProperty == CascadeType::PERSIST_DETACH) '"persist", "detach"'
        else if (cascadeProperty == CascadeType::REMOVE_MERGE) '"remove", "merge"'
        else if (cascadeProperty == CascadeType::REMOVE_DETACH) '"remove", "detach"'
        else if (cascadeProperty == CascadeType::MERGE_DETACH) '"merge", "detach"'
        else if (cascadeProperty == CascadeType::PERSIST_REMOVE_MERGE) '"persist", "remove", "merge"'
        else if (cascadeProperty == CascadeType::PERSIST_REMOVE_DETACH) '"persist", "remove", "detach"'
        else if (cascadeProperty == CascadeType::PERSIST_MERGE_DETACH) '"persist", "merge", "detach"'
        else if (cascadeProperty == CascadeType::REMOVE_MERGE_DETACH) '"remove", "merge", "detach"'
        else if (cascadeProperty == CascadeType::ALL) '"all"'
    }


    def initCollections(Entity it) '''
        «FOR relation : getOutgoingCollections»«relation.initCollection(true)»«ENDFOR»
        «FOR relation : getIncomingCollections»«relation.initCollection(false)»«ENDFOR»
        «IF attributable»
            $this->attributes = new Doctrine\Common\Collections\ArrayCollection();
        «ENDIF»
        «IF categorisable»
            $this->categories = new Doctrine\Common\Collections\ArrayCollection();
        «ENDIF»
    '''

    def private initCollection(JoinRelationship it, Boolean outgoing) '''
        «IF isManySide(outgoing)»
            $this->«getRelationAliasName(outgoing)» = new ArrayCollection();
        «ENDIF»
    '''


    def relationAccessor(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget)»
        «relationAccessorImpl(useTarget, relationAliasName)»
    '''

    def private relationAccessorImpl(JoinRelationship it, Boolean useTarget, String aliasName) '''
        «val entityClass = { (if (useTarget) target else source).implClassModelEntity }»
        «val singleName = { (if (useTarget) target else source).name }»
        «val isMany = isManySide(useTarget)»
        «IF isMany»
            «fh.getterAndSetterMethods(it, aliasName, entityClass, true, false, '')»
            «relationAccessorAdditions(useTarget, aliasName, singleName)»
        «ELSE»
            «fh.getterAndSetterMethods(it, aliasName, entityClass, false, true, 'null')»
        «ENDIF»
        «IF isMany»
            «addMethod(useTarget, isMany, aliasName, singleName, entityClass)»
            «removeMethod(useTarget, isMany, aliasName, singleName, entityClass)»
        «ENDIF»
    '''

    def private dispatch relationAccessorAdditions(JoinRelationship it, Boolean useTarget, String aliasName, String singleName) '''
    '''

    def private dispatch relationAccessorAdditions(OneToManyRelationship it, Boolean useTarget, String aliasName, String singleName) '''
        «IF !useTarget && indexBy != null && indexBy != ''»
            /**
             * Returns an instance of «source.implClassModelEntity» from the list of «getRelationAliasName(useTarget)» by its given «indexBy.formatForDisplay» index.
             *
             * @param «source.implClassModelEntity» $«indexBy.formatForCode».
             */
            public function get«singleName.formatForCodeCapital»($«indexBy.formatForCode»)
            {
                if (!isset($this->«aliasName.formatForCode»[$«indexBy.formatForCode»])) {
                    throw new \InvalidArgumentException("«indexBy.formatForDisplayCapital» is not available on this list of «aliasName.formatForDisplay».");
                }

                return $this->«aliasName.formatForCode»[$«indexBy.formatForCode»];
            }
            «/* this last line is on purpose */»
        «ENDIF»
    '''

    def private addMethod(JoinRelationship it, Boolean useTarget, Boolean selfIsMany, String name, String nameSingle, String type) '''
        /**
         * Adds an instance of «type» to the list of «name.formatForDisplay».
         *
         * @param «addParameters(useTarget, nameSingle, type, true)».
         *
         * @return void
         */
        public function add«name.toFirstUpper»(«addParameters(useTarget, nameSingle, type, false)»)
        {
            «addAssignment(useTarget, selfIsMany, name, nameSingle)»
            «IF bidirectional && !useTarget»
                «val ownAliasName = getRelationAliasName(!useTarget).toFirstUpper»
                «val otherIsMany = isManySide(!useTarget)»
                «IF otherIsMany»
                    $«nameSingle»->add«ownAliasName»($this);
                «ELSE»
                    $«nameSingle»->set«ownAliasName»($this);
                «ENDIF»
            «ENDIF»
        }
        «/* this last line is on purpose */»
    '''

    def private dispatch addParameters(JoinRelationship it, Boolean useTarget, String name, String type, Boolean withDescription) '''
        «type» $«name»«IF withDescription»«/*TODO description*/»«ENDIF»'''
    def private dispatch addParameters(OneToManyRelationship it, Boolean useTarget, String name, String type, Boolean withDescription) '''
        «IF !useTarget && !source.getAggregateFields.isEmpty»
            «val targetField = source.getAggregateFields.head.getAggregateTargetField»
            «IF withDescription»«targetField.fieldTypeAsString» «ENDIF»$«targetField.name.formatForCode»«IF withDescription»«/*TODO description*/»«ENDIF»
        «ELSE»
            «type» $«name»«IF withDescription»«/*TODO description*/»«ENDIF»
        «ENDIF»'''

    def private addAssignmentDefault(JoinRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle) '''
        $this->«name»«IF selfIsMany»[]«ENDIF» = $«nameSingle»;
    '''
    def private dispatch addAssignment(JoinRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle) '''
        «addAssignmentDefault(useTarget, selfIsMany, name, nameSingle)»
    '''
    def private dispatch addAssignment(OneToManyRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle) '''
        «IF !useTarget && indexBy != null && indexBy != ''»
            $this->«name»[$«nameSingle»->get«indexBy.formatForCodeCapital»()] = $«nameSingle»;
        «ELSEIF !useTarget && !source.getAggregateFields.isEmpty»
            «val sourceField = source.getAggregateFields.head»
            «val targetField = sourceField.getAggregateTargetField»
            $«getRelationAliasName(true)» = new «target.implClassModelEntity»($this, $«targetField.name.formatForCode»);
            $this->«name»«IF selfIsMany»[]«ENDIF» = $«nameSingle»;
            $this->«sourceField.name.formatForCode» += $«targetField.name.formatForCode»;
            return $«getRelationAliasName(true)»;
        }

        /**
         * Additional add function for internal use.
         *
         * @param «targetField.fieldTypeAsString» $«targetField.name.formatForCode»«/*TODO description*/»
         */
        protected function add«targetField.name.formatForCodeCapital»Without«getRelationAliasName(true).formatForCodeCapital»($«targetField.name.formatForCode»)
        {
            $this->«sourceField.name.formatForCode» += $«targetField.name.formatForCode»;
        «ELSE»
            «addAssignmentDefault(useTarget, selfIsMany, name, nameSingle)»
        «ENDIF»
    '''
    def private dispatch addAssignment(ManyToManyRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle) '''
        «IF !useTarget && indexBy != null && indexBy != ''»
            $this->«name»[$«nameSingle»->get«indexBy.formatForCodeCapital»()] = $«nameSingle»;
        «ELSE»
            «addAssignmentDefault(useTarget, selfIsMany, name, nameSingle)»
        «ENDIF»
    '''

    def private removeMethod(JoinRelationship it, Boolean useTarget, Boolean selfIsMany, String name, String nameSingle, String type) '''
        /**
         * Removes an instance of «type» from the list of «name.formatForDisplay».
         *
         * @param «type» $«nameSingle».
         *
         * @return void
         */
        public function remove«name.toFirstUpper»(«type» $«nameSingle»)
        {
            «IF selfIsMany»
                $this->«name»->removeElement($«nameSingle»);
            «ELSE»
                $this->«name» = null;
            «ENDIF»
            «IF bidirectional && !useTarget»
                «val ownAliasName = getRelationAliasName(!useTarget).toFirstUpper»
                «val otherIsMany = isManySide(!useTarget)»
                «IF otherIsMany»
                    $«nameSingle»->remove«ownAliasName»($this);
                «ELSE»
                    $«nameSingle»->set«ownAliasName»(null);
                «ENDIF»
            «ENDIF»
        }
        «/* this last line is on purpose */»
    '''
}
