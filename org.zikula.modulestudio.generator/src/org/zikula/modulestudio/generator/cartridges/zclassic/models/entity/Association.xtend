package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

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
import org.zikula.modulestudio.generator.extensions.Utils

class Association {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * If we have an outgoing association useTarget is true; for an incoming one it is false.
     */
    def generate(JoinRelationship it, Boolean useTarget) {
        val sourceName = getRelationAliasName(false).toFirstLower
        val targetName = getRelationAliasName(true).toFirstLower
        val entityClass = (if (useTarget) target else source).entityClassName('', false)
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
            «outgoing(sourceName, targetName, entityClass)»
        «ENDIF»
    '''

    def private bidirectional(JoinRelationship it, Boolean useTarget, String sourceName, String targetName, String entityClass) '''
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
         * @ORM\«incomingMappingType»(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»", inversedBy="«targetName»"«additionalOptions(true)»)
        «IF it instanceof OneToManyRelationship && getSourceFields.length == 1» * «joinColumn(getSourceFields.head, source.getFirstPrimaryKey.name.formatForDB, false)»«ELSE»«joinDetails(false)»«ENDIF»«/* @JoinTable is not required for most @ManyToOne relationships */»
        «IF !container.application.targets('1.3.5')»
            «IF !nullable»
                «val aliasName = getRelationAliasName(false).toFirstLower»
                «IF !isManySide(false)»
                    «' '»* @Assert\NotNull(message="Choosing a «aliasName.formatForDisplay» is required.")
                «ELSE»
                    «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
                «ENDIF»
            «ENDIF»
            «IF !isManySide(false)»
                «' '»* @Assert\Type(type="\«entityClass»")
            «ENDIF»
            «' '»* @Assert\Valid()
        «ENDIF»
         * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»«IF isManySide(false)»[]«ENDIF» $«sourceName».
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
         * @ORM\OneToOne(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»")
        «joinDetails(false)»
        «IF !container.application.targets('1.3.5')»
            «IF !nullable»
                «val aliasName = getRelationAliasName(false).toFirstLower»
                «' '»* @Assert\NotNull(message="Choosing a «aliasName.formatForDisplay» is required.")
            «ENDIF»
            «' '»* @Assert\Type(type="\«entityClass»")
            «' '»* @Assert\Valid()
        «ENDIF»
         * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass» $«sourceName».
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
             * @ORM\ManyToMany(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»", mappedBy="«targetName»"«additionalOptions(true)»)
             «IF orderByReverse !== null && orderByReverse != ''»
              * @ORM\OrderBy({"«orderByReverse»" = "ASC"})
             «ENDIF»
            «IF !container.application.targets('1.3.5')»
                «IF !nullable»
                    «val aliasName = getRelationAliasName(false).toFirstLower»
                    «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
                «ENDIF»
                «IF minSource > 0 && maxSource > 0»
                    «' '»* @Assert\Count(min="«minSource»", max="«maxSource»")
                «ENDIF»
                «' '»* @Assert\Valid()
            «ENDIF»
             * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»[] $«sourceName».
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
         * @ORM\«outgoingMappingType»(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»"«IF bidirectional», mappedBy="«sourceName»"«ENDIF»«cascadeOptions(false)»«fetchTypeTag»«outgoingMappingAdditions»)
        «joinDetails(true)»
        «IF !container.application.targets('1.3.5')»
            «IF !nullable»
                «val aliasName = getRelationAliasName(true).toFirstLower»
                «IF !isManySide(true)»
                    «' '»* @Assert\NotNull(message="Choosing a «aliasName.formatForDisplay» is required.")
                «ELSE»
                    «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
                «ENDIF»
            «ENDIF»
            «IF !isManySide(true)»
                «' '»* @Assert\Type(type="\«entityClass»")
            «ENDIF»
            «' '»* @Assert\Valid()
        «ENDIF»
         * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass» $«targetName».
         */
        protected $«targetName»;
        «/* this last line is on purpose */»
    '''

    def private dispatch outgoingMappingDescription(JoinRelationship it, String sourceName, String targetName) {
        switch it {
            OneToOneRelationship: '''One «sourceName» [«source.name.formatForDisplay»] has one «targetName» [«target.name.formatForDisplay»] (INVERSE SIDE)'''
            ManyToOneRelationship: '''Many «sourceName» [«source.nameMultiple.formatForDisplay»] have one «targetName» [«target.name.formatForDisplay»] (OWNING SIDE)'''
            default: ''
        }
    }
    def private outgoingMappingType(JoinRelationship it) {
        switch it {
            OneToOneRelationship: 'OneToOne'
            ManyToOneRelationship: 'ManyToOne'
            default: ''
        }
    }

    def private dispatch outgoingMappingAdditions(JoinRelationship it) ''''''
    def private dispatch outgoingMappingAdditions(OneToOneRelationship it) '''«IF orphanRemoval», orphanRemoval=true«ENDIF»'''
    def private dispatch outgoingMappingAdditions(OneToManyRelationship it) '''«IF orphanRemoval», orphanRemoval=true«ENDIF»«IF indexBy !== null && indexBy != ''», indexBy="«indexBy»"«ENDIF»)'''
    def private dispatch outgoingMappingAdditions(ManyToManyRelationship it) '''«IF orphanRemoval», orphanRemoval=true«ENDIF»«IF indexBy !== null && indexBy != ''», indexBy="«indexBy»"«ENDIF»'''

    def private dispatch outgoing(OneToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         *
         «IF !bidirectional»
          * @ORM\ManyToMany(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»"«additionalOptions(false)»)
         «ELSE»
          * @ORM\OneToMany(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»", mappedBy="«sourceName»"«additionalOptions(false)»«outgoingMappingAdditions»
         «ENDIF»
        «joinDetails(true)»
         «IF orderBy !== null && orderBy != ''»
          * @ORM\OrderBy({"«orderBy»" = "ASC"})
         «ENDIF»
        «IF !container.application.targets('1.3.5')»
            «IF !nullable»
                «val aliasName = getRelationAliasName(true).toFirstLower»
                «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
            «ENDIF»
            «IF minTarget > 0 && maxTarget > 0»
                «' '»* @Assert\Count(min="«minTarget»", max="«maxTarget»")
            «ENDIF»
            «' '»* @Assert\Valid()
        «ENDIF»
         * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»[] $«targetName».
         */
        protected $«targetName» = null;
        «/* this last line is on purpose */»
    '''

    def private dispatch outgoingMappingDescription(OneToManyRelationship it, String sourceName, String targetName) '''One «sourceName» [«source.name.formatForDisplay»] has many «targetName» [«target.nameMultiple.formatForDisplay»] (INVERSE SIDE)'''

    def private dispatch outgoing(ManyToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         *
         * @ORM\ManyToMany(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»"«IF bidirectional», inversedBy="«sourceName»"«ENDIF»«additionalOptions(false)»«outgoingMappingAdditions»)
        «joinDetails(true)»
         «IF orderBy !== null && orderBy != ''»
          * @ORM\OrderBy({"«orderBy»" = "ASC"})
         «ENDIF»
        «IF !container.application.targets('1.3.5')»
            «IF !nullable»
                «val aliasName = getRelationAliasName(true).toFirstLower»
                «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
            «ENDIF»
            «IF minTarget > 0 && maxTarget > 0»
                «' '»* @Assert\Count(min="«minTarget»", max="«maxTarget»")
            «ENDIF»
            «' '»* @Assert\Valid()
        «ENDIF»
         * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClass»[] $«targetName».
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
           && !unique && nullable && onDelete == '') ''' * @ORM\JoinTable(name="«foreignTableName»")'''
        else ''' * @ORM\JoinTable(name="«foreignTableName»",
        «joinTableDetails(useTarget)»
         * )'''
    }

    def private joinTableDetails(JoinRelationship it, Boolean useTarget) '''
        «val joinedEntityLocal = { if (useTarget) source else target }»
        «val joinedEntityForeign = { if (useTarget) target else source }»
        «val joinColumnsLocal = { if (useTarget) getSourceFields else getTargetFields }»
        «val joinColumnsForeign = { if (useTarget) getTargetFields else getSourceFields }»
        «IF (joinColumnsForeign.size > 1)»«joinColumnsMultiple(useTarget, joinedEntityLocal, joinColumnsLocal)»
        «ELSE»«joinColumnsSingle(useTarget, joinedEntityLocal, joinColumnsLocal)»
        «ENDIF»
        «IF (joinColumnsForeign.size > 1)» *      inverseJoinColumns={«FOR joinColumnForeign : joinColumnsForeign SEPARATOR ', '»«joinColumn(joinColumnForeign, joinedEntityForeign.getFirstPrimaryKey.name.formatForDB, useTarget)»«ENDFOR»}
        «ELSE» *      inverseJoinColumns={«joinColumn(joinColumnsForeign.head, joinedEntityForeign.getFirstPrimaryKey.name.formatForDB, useTarget)»}
        «ENDIF»
    '''

    def private joinColumnsMultiple(JoinRelationship it, Boolean useTarget, Entity joinedEntityLocal, String[] joinColumnsLocal) ''' *      joinColumns={«FOR joinColumnLocal : joinColumnsLocal SEPARATOR ', '»«joinColumn(joinColumnLocal, joinedEntityLocal.getFirstPrimaryKey.name.formatForDB, !useTarget)»«ENDFOR»},'''

    def private joinColumnsSingle(JoinRelationship it, Boolean useTarget, Entity joinedEntityLocal, String[] joinColumnsLocal) ''' *      joinColumns={«joinColumn(joinColumnsLocal.head, joinedEntityLocal.getFirstPrimaryKey.name.formatForDB, !useTarget)»},'''

    def private joinColumn(JoinRelationship it, String columnName, String referencedColumnName, Boolean useTarget) '''
        @ORM\JoinColumn(name="«joinColumnName(columnName, useTarget)»", referencedColumnName="«referencedColumnName»" «IF unique», unique=true«ENDIF»«IF !nullable», nullable=false«ENDIF»«IF onDelete != ''», onDelete="«onDelete»"«ENDIF»)
    '''

    def private joinColumnName(JoinRelationship it, String columnName, Boolean useTarget) {
        (if (useTarget) target else source).name.formatForDB + '_' + columnName //$NON-NLS-1$
    }

    def private additionalOptions(JoinRelationship it, Boolean useReverse) '''«cascadeOptions(useReverse)»«fetchTypeTag»'''
    def private cascadeOptions(JoinRelationship it, Boolean useReverse) {
        val cascadeProperty = { if (useReverse) cascadeReverse else cascade }
        if (cascadeProperty == CascadeType::NONE) ''
        else ''', cascade={«cascadeOptionsImpl(useReverse)»}'''
    }

    def private fetchTypeTag(JoinRelationship it) { if (fetchType != RelationFetchType::LAZY) ''', fetch="«fetchType.literal»"''' }

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
            $this->attributes = new ArrayCollection();
        «ENDIF»
        «IF categorisable»
            $this->categories = new ArrayCollection();
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
        «val entityClass = { (if (useTarget) target else source).entityClassName('', false) }»
        «val nameSingle = { (if (useTarget) target else source).name }»
        «val isMany = isManySide(useTarget)»
        «val entityClassPrefix = (if (!container.application.targets('1.3.5')) '\\' else '')»
        «IF isMany»
            «fh.getterAndSetterMethods(it, aliasName, entityClassPrefix + entityClass, true, false, '', relationSetterCustomImpl(useTarget, aliasName))»
            «relationAccessorAdditions(useTarget, aliasName, nameSingle)»
        «ELSE»
            «fh.getterAndSetterMethods(it, aliasName, entityClassPrefix + entityClass, false, true, 'null', relationSetterCustomImpl(useTarget, aliasName))»
        «ENDIF»
        «IF isMany»
            «addMethod(useTarget, isMany, aliasName, nameSingle, entityClass)»
            «removeMethod(useTarget, isMany, aliasName, nameSingle, entityClass)»
        «ENDIF»
    '''

    def private relationSetterCustomImpl(JoinRelationship it, Boolean useTarget, String aliasName) '''
        «val otherIsMany = isManySide(useTarget)»
        «IF otherIsMany»
            «val nameSingle = { (if (useTarget) target else source).name + 'Single' }»
            foreach ($«aliasName» as $«nameSingle») {
                $this->add«aliasName.toFirstUpper»($«nameSingle»);
            }
        «ELSE»
            $this->«aliasName.formatForCode» = $«aliasName»;
            «val generateInverseCalls = bidirectional && ((!isManyToMany && useTarget) || (isManyToMany && !useTarget))»
            «IF generateInverseCalls»
                «val ownAliasName = getRelationAliasName(!useTarget).toFirstUpper»
                $«aliasName»->set«ownAliasName»($this);
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch relationAccessorAdditions(JoinRelationship it, Boolean useTarget, String aliasName, String singleName) '''
    '''

    def private dispatch relationAccessorAdditions(OneToManyRelationship it, Boolean useTarget, String aliasName, String singleName) '''
        «IF !useTarget && indexBy !== null && indexBy != ''»
            /**
             * Returns an instance of «source.entityClassName('', false)» from the list of «getRelationAliasName(useTarget)» by its given «indexBy.formatForDisplay» index.
             *
             * @param «source.entityClassName('', false)» $«indexBy.formatForCode».
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
         * Adds an instance of «IF !container.application.targets('1.3.5')»\«ENDIF»«type» to the list of «name.formatForDisplay».
         *
         * @param «addParameters(useTarget, nameSingle, type)» The instance to be added to the collection.
         *
         * @return void
         */
        «addMethodImpl(useTarget, selfIsMany, name, nameSingle, type)»
        «/* this last line is on purpose */»
    '''

    def private isManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }

    def private dispatch addParameters(JoinRelationship it, Boolean useTarget, String name, String type) '''
        «IF !container.application.targets('1.3.5')»\«ENDIF»«type» $«name»'''
    def private dispatch addParameters(OneToManyRelationship it, Boolean useTarget, String name, String type) '''
        «IF !useTarget && !source.getAggregateFields.empty»
            «val targetField = source.getAggregateFields.head.getAggregateTargetField»
            «IF !container.application.targets('1.3.5')»\«ENDIF»«targetField.fieldTypeAsString» $«targetField.name.formatForCode»
        «ELSE»«IF !container.application.targets('1.3.5')»\«ENDIF»«type» $«name»«ENDIF»'''

    def private addMethodSignature(JoinRelationship it, Boolean useTarget, String name, String nameSingle, String type) '''
        public function add«name.toFirstUpper»(«addParameters(useTarget, nameSingle, type)»)'''

    def private addMethodImplDefault(JoinRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle, String type) '''
        «addMethodSignature(useTarget, name, nameSingle, type)»
        {
            $this->«name»«IF selfIsMany»->add(«ELSE» = «ENDIF»$«nameSingle»«IF selfIsMany»)«ENDIF»;
            «addInverseCalls(useTarget, nameSingle)»
        }
    '''
    def private dispatch addMethodImpl(JoinRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle, String type) '''
        «addMethodImplDefault(useTarget, selfIsMany, name, nameSingle, type)»
    '''
    def private dispatch addMethodImpl(OneToManyRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle, String type) '''
        «IF !useTarget && indexBy !== null && indexBy != ''»
            «addMethodSignature(useTarget, name, nameSingle, type)»
            {
                $this->«name»[$«nameSingle»->get«indexBy.formatForCodeCapital»()] = $«nameSingle»;
                «addInverseCalls(useTarget, nameSingle)»
            }
        «ELSEIF !useTarget && !source.getAggregateFields.empty»
            «addMethodSignature(useTarget, name, nameSingle, type)»
            {
                «val sourceField = source.getAggregateFields.head»
                «val targetField = sourceField.getAggregateTargetField»
                $«getRelationAliasName(true)» = new «target.entityClassName('', false)»($this, $«targetField.name.formatForCode»);
                $this->«name»«IF selfIsMany»[]«ENDIF» = $«nameSingle»;
                $this->«sourceField.name.formatForCode» += $«targetField.name.formatForCode»;

                return $«getRelationAliasName(true)»;
            }

            /**
             * Additional add function for internal use.
             *
             * @param «targetField.fieldTypeAsString» $«targetField.name.formatForCode» Given instance to be used for aggregation.
             */
            protected function add«targetField.name.formatForCodeCapital»Without«getRelationAliasName(true).formatForCodeCapital»($«targetField.name.formatForCode»)
            {
                $this->«sourceField.name.formatForCode» += $«targetField.name.formatForCode»;
            }
        «ELSE»
            «addMethodImplDefault(useTarget, selfIsMany, name, nameSingle, type)»
        «ENDIF»
    '''
    def private dispatch addMethodImpl(ManyToManyRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle, String type) '''
        «IF !useTarget && indexBy !== null && indexBy != ''»
            «addMethodSignature(useTarget, name, nameSingle, type)»
            {
                $this->«name»[$«nameSingle»->get«indexBy.formatForCodeCapital»()] = $«nameSingle»;
                «addInverseCalls(useTarget, nameSingle)»
            }
        «ELSE»
            «addMethodImplDefault(useTarget, selfIsMany, name, nameSingle, type)»
        «ENDIF»
    '''

    def private addInverseCalls(JoinRelationship it, Boolean useTarget, String nameSingle) '''
        «val generateInverseCalls = bidirectional && ((!isManyToMany && useTarget) || (isManyToMany && !useTarget))»
        «IF generateInverseCalls»
            «val ownAliasName = getRelationAliasName(!useTarget).toFirstUpper»
            «val otherIsMany = isManySide(!useTarget)»
            «IF otherIsMany»
                $«nameSingle»->add«ownAliasName»($this);
            «ELSE»
                $«nameSingle»->set«ownAliasName»($this);
            «ENDIF»
        «ENDIF»
    '''

    def private removeMethod(JoinRelationship it, Boolean useTarget, Boolean selfIsMany, String name, String nameSingle, String type) '''
        /**
         * Removes an instance of «IF !container.application.targets('1.3.5')»\«ENDIF»«type» from the list of «name.formatForDisplay».
         *
         * @param «IF !container.application.targets('1.3.5')»\«ENDIF»«type» $«nameSingle» The instance to be removed from the collection.
         *
         * @return void
         */
        public function remove«name.toFirstUpper»(«IF !container.application.targets('1.3.5')»\«ENDIF»«type» $«nameSingle»)
        {
            «IF selfIsMany»
                $this->«name»->removeElement($«nameSingle»);
            «ELSE»
                $this->«name» = null;
            «ENDIF»
            «val generateInverseCalls = bidirectional && ((!isManyToMany && useTarget) || (isManyToMany && !useTarget))»
            «IF generateInverseCalls»
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
