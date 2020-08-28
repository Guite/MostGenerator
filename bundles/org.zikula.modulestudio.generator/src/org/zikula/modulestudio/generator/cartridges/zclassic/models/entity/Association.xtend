package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.CascadeType
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.RelationFetchType
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

    FileHelper fh

    /**
     * If we have an outgoing association useTarget is true; for an incoming one it is false.
     */
    def generate(JoinRelationship it, Boolean useTarget) {
        fh = new FileHelper(application)
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
         * @ORM\«incomingMappingType»(
         *     targetEntity="«/*\*/»«entityClass»",
         *     inversedBy="«targetName»"«additionalOptions(true)»
         * )
        «joinDetails(false)»
        «IF !nullable»
            «val aliasName = getRelationAliasName(false).toFirstLower»
            «IF !isManySide(false)»
                «' '»* @Assert\NotNull(message="Choosing a «aliasName.formatForDisplay» is required.")
            «ELSE»
                «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
            «ENDIF»
        «ENDIF»
        «IF !isManySide(false)»
            «' '»* @Assert\Type(type="«/*\*/»«entityClass»")«/* disabled due to problems with upload fields
            «' '»* @Assert\Valid()*/»
        «ENDIF»
         *
         * @var \«entityClass»«IF isManySide(false)»[]«ENDIF»
         */
        protected $«sourceName»;
        «/* this last line is on purpose */»
    '''

    def private getDisplayNameDependingOnType(DataObject it) {
        if (it instanceof Entity) {
            nameMultiple.formatForDisplay
        } else {
            name.formatForDisplay
        }
    }

    def private dispatch incomingMappingDescription(JoinRelationship it, String sourceName, String targetName) {
        switch it {
            OneToOneRelationship: '''One «targetName» [«target.name.formatForDisplay»] is linked by one «sourceName» [«source.name.formatForDisplay»] (INVERSE SIDE)'''
            OneToManyRelationship: '''Many «targetName» [«target.getDisplayNameDependingOnType»] are linked by one «sourceName» [«source.name.formatForDisplay»] (OWNING SIDE)'''
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
         * @ORM\OneToOne(targetEntity="«/*\*/»«entityClass»")
        «joinDetails(false)»
        «IF !nullable»
            «val aliasName = getRelationAliasName(false).toFirstLower»
            «' '»* @Assert\NotNull(message="Choosing a «aliasName.formatForDisplay» is required.")
        «ENDIF»
         * @Assert\Type(type="«/*\*/»«entityClass»")«/* disabled due to problems with upload fields
         * @Assert\Valid()*/»
         *
         * @var \«entityClass»
         */
        protected $«sourceName»;
        «/* this last line is on purpose */»
    '''

    def private dispatch incomingMappingDescription(ManyToOneRelationship it, String sourceName, String targetName) '''One «targetName» [«target.name.formatForDisplay»] is linked by many «sourceName» [«source.getDisplayNameDependingOnType»] (INVERSE SIDE)'''

    def private dispatch incoming(ManyToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        «IF bidirectional»
            /**
             * Bidirectional - «incomingMappingDescription(sourceName, targetName)».
             *
             * @ORM\ManyToMany(
             *     targetEntity="«/*\*/»«entityClass»",
             *     mappedBy="«targetName»"«additionalOptions(true)»
             * )
             «IF null !== orderByReverse && !orderByReverse.empty»
              * @ORM\OrderBy({«orderByDetails(orderByReverse)»})
             «ENDIF»
            «IF !nullable»
                «val aliasName = getRelationAliasName(false).toFirstLower»
                «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
            «ENDIF»
            «IF maxSource > 0»
                «' '»* @Assert\Count(min="«minSource»", max="«maxSource»")
            «ENDIF»
             *
             * @var \«entityClass»[]
             */
            protected $«sourceName» = null;
        «ENDIF»
    '''

    def private dispatch incomingMappingDescription(ManyToManyRelationship it, String sourceName, String targetName) '''Many «targetName» [«target.getDisplayNameDependingOnType»] are linked by many «sourceName» [«source.getDisplayNameDependingOnType»] (INVERSE SIDE)'''

    /**
     * This default rule is used for OneToOne and ManyToOne.
     */
    def private dispatch outgoing(JoinRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         *
         * @ORM\«outgoingMappingType»(
         *     targetEntity="«/*\*/»«entityClass»"«IF bidirectional»,
         *     mappedBy="«sourceName»"«ENDIF»«cascadeOptions(false)»«fetchTypeTag»«outgoingMappingAdditions»
         * )
        «joinDetails(true)»
        «IF !nullable»
            «val aliasName = getRelationAliasName(true).toFirstLower»
            «IF !isManySide(true)»
                «' '»* @Assert\NotNull(message="Choosing a «aliasName.formatForDisplay» is required.")
            «ELSE»
                «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
            «ENDIF»
        «ENDIF»
        «IF it instanceof ManyToOneRelationship && (it as ManyToOneRelationship).sortableGroup»
            «' '»* @Gedmo\SortableGroup
        «ENDIF»
        «IF !isManySide(true)»
            «' '»* @Assert\Type(type="«/*\*/»«entityClass»")«/* disabled due to problems with upload fields
            «' '»* @Assert\Valid()*/»
        «ENDIF»
         *
         * @var \«entityClass»
         */
        protected $«targetName»;
        «/* this last line is on purpose */»
    '''

    def private dispatch outgoingMappingDescription(JoinRelationship it, String sourceName, String targetName) {
        switch it {
            OneToOneRelationship: '''One «sourceName» [«source.name.formatForDisplay»] has one «targetName» [«target.name.formatForDisplay»] (INVERSE SIDE)'''
            ManyToOneRelationship: '''Many «sourceName» [«source.getDisplayNameDependingOnType»] have one «targetName» [«target.name.formatForDisplay»] (OWNING SIDE)'''
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
    def private dispatch outgoingMappingAdditions(OneToManyRelationship it) '''«IF orphanRemoval», orphanRemoval=true«ENDIF»«IF null !== indexBy && !indexBy.empty», indexBy="«indexBy»"«ENDIF»)'''
    def private dispatch outgoingMappingAdditions(ManyToManyRelationship it) '''«IF orphanRemoval», orphanRemoval=true«ENDIF»«IF null !== indexBy && !indexBy.empty», indexBy="«indexBy»"«ENDIF»'''

    def private dispatch outgoing(OneToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         *
         «IF !bidirectional»
          * @ORM\ManyToMany(
          *     targetEntity="«/*\*/»«entityClass»"«additionalOptions(false)»
          * )
         «ELSE»
          * @ORM\OneToMany(
          *     targetEntity="«/*\*/»«entityClass»",
          *     mappedBy="«sourceName»"«additionalOptions(false)»«outgoingMappingAdditions»
          * )
         «ENDIF»
        «joinDetails(true)»
         «IF null !== orderBy && !orderBy.empty»
          * @ORM\OrderBy({«orderByDetails(orderBy)»})
         «ENDIF»
        «IF !nullable»
            «val aliasName = getRelationAliasName(true).toFirstLower»
            «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
        «ENDIF»
        «IF maxTarget > 0»
            «' '»* @Assert\Count(min="«minTarget»", max="«maxTarget»")
        «ENDIF»
         *
         * @var \«entityClass»[]
         */
        protected $«targetName» = null;
        «/* this last line is on purpose */»
    '''

    def private dispatch outgoingMappingDescription(OneToManyRelationship it, String sourceName, String targetName) '''One «sourceName» [«source.name.formatForDisplay»] has many «targetName» [«target.getDisplayNameDependingOnType»] (INVERSE SIDE)'''

    def private dispatch outgoing(ManyToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         *
         * @ORM\ManyToMany(
         *     targetEntity="«/*\*/»«entityClass»"«IF bidirectional»,
         *     inversedBy="«sourceName»"«ENDIF»«additionalOptions(false)»«outgoingMappingAdditions»
         * )
        «joinDetails(true)»
         «IF null !== orderBy && !orderBy.empty»
          * @ORM\OrderBy({«orderByDetails(orderBy)»})
         «ENDIF»
        «IF !nullable»
            «val aliasName = getRelationAliasName(true).toFirstLower»
            «' '»* @Assert\NotNull(message="Choosing at least one of the «aliasName.formatForDisplay» is required.")
        «ENDIF»
        «IF maxTarget > 0»
            «' '»* @Assert\Count(min="«minTarget»", max="«maxTarget»")
        «ENDIF»
         *
         * @var \«entityClass»[]
         */
        protected $«targetName» = null;
    '''

    def private dispatch outgoingMappingDescription(ManyToManyRelationship it, String sourceName, String targetName) '''Many «sourceName» [«source.getDisplayNameDependingOnType»] have many «targetName» [«target.getDisplayNameDependingOnType»] (OWNING SIDE)'''


    def private joinDetails(JoinRelationship it, Boolean useTarget) {
        val joinedEntityLocal = { if (useTarget) source else target }
        val joinedEntityForeign = { if (useTarget) target else source }
        val joinColumnsLocal = { if (useTarget) getSourceFields else getTargetFields }
        val joinColumnsForeign = { if (useTarget) getTargetFields else getSourceFields }
        val foreignTableName = fullJoinTableName(useTarget, joinedEntityForeign)
        if (it instanceof OneToOneRelationship && !bidirectional) {
            ''' * «joinColumn(it, joinColumnsForeign.head, joinedEntityForeign.getPrimaryKey.name.formatForDB, useTarget)»'''
        } else if (joinColumnsForeign.containsDefaultIdField(joinedEntityForeign) && joinColumnsLocal.containsDefaultIdField(joinedEntityLocal)
           && !unique && nullable && onDelete.empty) ''' * @ORM\JoinTable(name="«foreignTableName»")'''
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
        «IF (joinColumnsForeign.size > 1)» *      inverseJoinColumns={«FOR joinColumnForeign : joinColumnsForeign SEPARATOR ', '»«joinColumn(joinColumnForeign, joinedEntityForeign.getPrimaryKey.name.formatForDB, useTarget)»«ENDFOR»}
        «ELSE» *      inverseJoinColumns={«joinColumn(joinColumnsForeign.head, joinedEntityForeign.getPrimaryKey.name.formatForDB, useTarget)»}
        «ENDIF»
    '''

    def private joinColumnsMultiple(JoinRelationship it, Boolean useTarget, DataObject joinedEntityLocal, String[] joinColumnsLocal) ''' *      joinColumns={«FOR joinColumnLocal : joinColumnsLocal SEPARATOR ', '»«joinColumn(joinColumnLocal, joinedEntityLocal.getPrimaryKey.name.formatForDB, !useTarget)»«ENDFOR»},'''

    def private joinColumnsSingle(JoinRelationship it, Boolean useTarget, DataObject joinedEntityLocal, String[] joinColumnsLocal) ''' *      joinColumns={«joinColumn(joinColumnsLocal.head, joinedEntityLocal.getPrimaryKey.name.formatForDB, !useTarget)»},'''

    def private joinColumn(JoinRelationship it, String columnName, String referencedColumnName, Boolean useTarget) '''
        @ORM\JoinColumn(name="«joinColumnName(columnName, useTarget)»", referencedColumnName="«referencedColumnName»" «IF unique», unique=true«ENDIF»«IF !nullable», nullable=false«ENDIF»«IF !onDelete.empty», onDelete="«onDelete»"«ENDIF»)'''

    def private joinColumnName(JoinRelationship it, String columnName, Boolean useTarget) {
        switch it {
            ManyToManyRelationship case columnName == 'id': (if (useTarget) target else source).name.formatForDB + '_id' //$NON-NLS-1$ //$NON-NLS-2$
            default: columnName
        }
        //(if (useTarget) target else source).name.formatForDB + '_' + columnName //$NON-NLS-1$
    }

    def private additionalOptions(JoinRelationship it, Boolean useReverse) '''«cascadeOptions(useReverse)»«fetchTypeTag»'''
    def private cascadeOptions(JoinRelationship it, Boolean useReverse) {
        val cascadeProperty = { if (useReverse) cascadeReverse else cascade }
        if (cascadeProperty == CascadeType.NONE) ''
        else ''', cascade={«cascadeOptionsImpl(useReverse)»}'''
    }

    def private fetchTypeTag(JoinRelationship it) { if (fetchType != RelationFetchType.LAZY) ''', fetch="«fetchType.literal»"''' }

    def private cascadeOptionsImpl(JoinRelationship it, Boolean useReverse) {
        val cascadeProperty = { if (useReverse) cascadeReverse else cascade }
        if (cascadeProperty == CascadeType.PERSIST) '"persist"'
        else if (cascadeProperty == CascadeType.REMOVE) '"remove"'
        else if (cascadeProperty == CascadeType.MERGE) '"merge"'
        else if (cascadeProperty == CascadeType.DETACH) '"detach"'
        else if (cascadeProperty == CascadeType.PERSIST_REMOVE) '"persist", "remove"'
        else if (cascadeProperty == CascadeType.PERSIST_MERGE) '"persist", "merge"'
        else if (cascadeProperty == CascadeType.PERSIST_DETACH) '"persist", "detach"'
        else if (cascadeProperty == CascadeType.REMOVE_MERGE) '"remove", "merge"'
        else if (cascadeProperty == CascadeType.REMOVE_DETACH) '"remove", "detach"'
        else if (cascadeProperty == CascadeType.MERGE_DETACH) '"merge", "detach"'
        else if (cascadeProperty == CascadeType.PERSIST_REMOVE_MERGE) '"persist", "remove", "merge"'
        else if (cascadeProperty == CascadeType.PERSIST_REMOVE_DETACH) '"persist", "remove", "detach"'
        else if (cascadeProperty == CascadeType.PERSIST_MERGE_DETACH) '"persist", "merge", "detach"'
        else if (cascadeProperty == CascadeType.REMOVE_MERGE_DETACH) '"remove", "merge", "detach"'
        else if (cascadeProperty == CascadeType.ALL) '"all"'
    }

    def private orderByDetails(String orderBy) {
        val criteria = newArrayList
        val orderByFields = orderBy.replace(', ', ',').split(',')

        for (orderByField : orderByFields) {
            var fieldName = orderByField
            var sorting = 'ASC'
            if (orderByField.contains(':')) {
                val criteriaParts = orderByField.split(':')
                fieldName = criteriaParts.head
                sorting = criteriaParts.last
            }
            criteria.add('"' + fieldName + '" = "' + sorting.toUpperCase + '"')
        }
        criteria.join(', ')
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
        «val entityClassPrefix = '\\'»
        «IF isMany»
            «fh.getterAndSetterMethods(it, aliasName, entityClassPrefix + entityClass, true, true, false, '', relationSetterCustomImpl(useTarget, aliasName))»
            «relationAccessorAdditions(useTarget, aliasName, nameSingle)»
        «ELSE»
            «fh.getterAndSetterMethods(it, aliasName, entityClassPrefix + entityClass, false, true, true, 'null', relationSetterCustomImpl(useTarget, aliasName))»
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
            foreach ($this->«aliasName» as $«nameSingle») {
                $this->remove«aliasName.toFirstUpper»($«nameSingle»);
            }
            foreach ($«aliasName» as $«nameSingle») {
                $this->add«aliasName.toFirstUpper»($«nameSingle»);
            }
        «ELSE»
            $this->«aliasName.formatForCode» = $«aliasName»;
            «val generateInverseCalls = bidirectional && ((!isManyToMany && useTarget) || (isManyToMany && !useTarget))»
            «IF generateInverseCalls»
                if (null !== $«aliasName») {
                    «val ownAliasName = getRelationAliasName(!useTarget).toFirstUpper»
                    $«aliasName»->set«ownAliasName»($this);
                }
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch relationAccessorAdditions(JoinRelationship it, Boolean useTarget, String aliasName, String singleName) '''
    '''

    def private dispatch relationAccessorAdditions(OneToManyRelationship it, Boolean useTarget, String aliasName, String singleName) '''
        «IF !useTarget && null !== indexBy && !indexBy.empty»

            /**
             * Returns an instance of «source.entityClassName('', false)» from the list of «getRelationAliasName(useTarget)» by its given «indexBy.formatForDisplay» index.
             *
             «IF !application.targets('3.0')»
             * @param «source.getDerivedFields.findFirst[e|e.name.equals(indexBy)].fieldTypeAsString(true)» $«indexBy.formatForCode»
             *
             * @return The desired «source.entityClassName('', false)» instance
             * 
             «ENDIF»
             * @throws InvalidArgumentException If desired index does not exist
             */
            public function get«singleName.formatForCodeCapital»(«IF application.targets('3.0')»«source.getDerivedFields.findFirst[e|e.name.equals(indexBy)].fieldTypeAsString(true)» «ENDIF»$«indexBy.formatForCode»)«IF !application.targets('3.0')»: «source.entityClassName('', false)»«ENDIF»
            {
                if (!isset($this->«aliasName.formatForCode»[$«indexBy.formatForCode»])) {
                    throw new InvalidArgumentException("«indexBy.formatForDisplayCapital» is not available on this list of «aliasName.formatForDisplay».");
                }

                return $this->«aliasName.formatForCode»[$«indexBy.formatForCode»];
            }
        «ENDIF»
    '''

    def private addMethod(JoinRelationship it, Boolean useTarget, Boolean selfIsMany, String name, String nameSingle, String type) '''

        /**
         * Adds an instance of \«type» to the list of «name.formatForDisplay».
         «IF !application.targets('3.0')»
         *
         * @param «addParameters(useTarget, nameSingle, type)» The instance to be added to the collection
         *
         * @return void
         «ENDIF»
         */
        «addMethodImpl(useTarget, selfIsMany, name, nameSingle, type)»
    '''

    def private isManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }

    def private dispatch addParameters(JoinRelationship it, Boolean useTarget, String name, String type) '''
        \«type» $«name»'''
    def private dispatch addParameters(OneToManyRelationship it, Boolean useTarget, String name, String type) '''
        «IF !useTarget && !source.getAggregateFields.empty»
            «val targetField = source.getAggregateFields.head.getAggregateTargetField»
            \«targetField.fieldTypeAsString(true)» $«targetField.name.formatForCode»
        «ELSE»\«type» $«name»«ENDIF»'''

    def private addMethodSignature(JoinRelationship it, Boolean useTarget, String name, String nameSingle, String type) '''
        public function add«name.toFirstUpper»(«addParameters(useTarget, nameSingle, type)»)«IF application.targets('3.0')»: void«ENDIF»'''

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
        «IF !useTarget && null !== indexBy && !indexBy.empty»
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
             «IF !application.targets('3.0')»
             *
             * @param «targetField.fieldTypeAsString(true)» $«targetField.name.formatForCode» Given instance to be used for aggregation
             «ENDIF»
             */
            protected function add«targetField.name.formatForCodeCapital»Without«getRelationAliasName(true).formatForCodeCapital»(«IF application.targets('3.0')»«targetField.fieldTypeAsString(true)» «ENDIF»$«targetField.name.formatForCode»)«IF application.targets('3.0')»: void«ENDIF»
            {
                $this->«sourceField.name.formatForCode» += $«targetField.name.formatForCode»;
            }
        «ELSE»
            «addMethodImplDefault(useTarget, selfIsMany, name, nameSingle, type)»
        «ENDIF»
    '''
    def private dispatch addMethodImpl(ManyToManyRelationship it, Boolean selfIsMany, Boolean useTarget, String name, String nameSingle, String type) '''
        «IF !useTarget && null !== indexBy && !indexBy.empty»
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
         * Removes an instance of \«type» from the list of «name.formatForDisplay».
         «IF !application.targets('3.0')»
         *
         * @param \«type» $«nameSingle» The instance to be removed from the collection
         *
         * @return void
         «ENDIF»
         */
        public function remove«name.toFirstUpper»(\«type» $«nameSingle»)«IF application.targets('3.0')»: void«ENDIF»
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
    '''

    def private isBidirectional(JoinRelationship it) {
        switch (it) {
            OneToOneRelationship:
                return it.bidirectional
            OneToManyRelationship:
                return it.bidirectional
            ManyToOneRelationship:
                return false
            ManyToManyRelationship:
                return it.bidirectional
        }

        false
    }
}
