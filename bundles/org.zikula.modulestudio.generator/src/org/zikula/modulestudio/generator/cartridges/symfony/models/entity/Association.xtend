package org.zikula.modulestudio.generator.cartridges.symfony.models.entity

import de.guite.modulestudio.metamodel.CascadeType
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.RelationFetchType
import de.guite.modulestudio.metamodel.Relationship
import java.util.ArrayList
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
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
    ArrayList<String> importedEntities

    new() {
        resetImports
    }

    def resetImports() {
        importedEntities = newArrayList
    }

    /**
     * If we have an outgoing association useTarget is true; for an incoming one it is false.
     */
    def importRelatedEntity(Relationship it, Boolean useTarget) {
        val imports = newArrayList
        val entityClassName = (if (useTarget) target else source).simpleEntityClassName
        if (!importedEntities.contains(entityClassName)) {
            importedEntities += entityClassName
            imports.add(application.appNamespace + '\\Entity\\' + entityClassName)
        }
        imports
    }

    def private simpleEntityClassName(Entity it) {
        name.formatForCodeCapital
    }

    /**
     * If we have an outgoing association useTarget is true; for an incoming one it is false.
     */
    def generate(Relationship it, Boolean useTarget) {
        fh = new FileHelper(application)
        val sourceName = getRelationAliasName(false).toFirstLower
        val targetName = getRelationAliasName(true).toFirstLower
        val entityClass = (if (useTarget) target else source).simpleEntityClassName
        directionSwitch(useTarget, sourceName, targetName, entityClass)
    }

    def private directionSwitch(Relationship it, Boolean useTarget, String sourceName, String targetName, String entityClass) {
        if (!bidirectional)
            unidirectionalImpl(useTarget, sourceName, targetName, entityClass)
        else
            bidirectionalImpl(useTarget, sourceName, targetName, entityClass)
    }

    def private unidirectionalImpl(Relationship it, Boolean useTarget, String sourceName, String targetName, String entityClass) '''
        «IF useTarget»
            «outgoing(sourceName, targetName, entityClass)»
        «ENDIF»
    '''

    def private bidirectionalImpl(Relationship it, Boolean useTarget, String sourceName, String targetName, String entityClass) '''
        «IF !useTarget»
            «incoming(sourceName, targetName, entityClass)»
        «ELSE»
            «outgoing(sourceName, targetName, entityClass)»
        «ENDIF»
    '''

    def private dispatch incoming(Relationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * Bidirectional - «incomingMappingDescription(it, sourceName, targetName)».
        «IF isManySide(false)»
            «' '»* @var Collection<int, «entityClass»>
        «ENDIF»
         */
        «incomingMappingDetails»
        #[ORM\«incomingMappingType»(targetEntity: «entityClass»::class, inversedBy: '«targetName»'«additionalOptions(true)»)]
        «joinDetails(false)»
        «IF !nullable»
            «val aliasName = getRelationAliasName(false).toFirstLower»
            «IF !isManySide(false)»
                #[Assert\NotNull(message: 'Choosing a «aliasName.formatForDisplay» is required.')]
            «ELSE»
                #[Assert\NotNull(message: 'Choosing at least one of the «aliasName.formatForDisplay» is required.')]
            «ENDIF»
        «ENDIF»«/* disabled due to problems with upload fields
        IF !isManySide(false)»
            #[Assert\Valid]
        «ENDIF*/»
        protected ?«IF isManySide(false)»Collection«ELSE»«entityClass»«ENDIF» $«sourceName» = null;
        «/* this last line is on purpose */»
    '''

    def private dispatch incomingMappingDescription(Relationship it, String sourceName, String targetName) {
        switch it {
            OneToOneRelationship: '''One «targetName» [«target.name.formatForDisplay»] is linked by one «sourceName» [«source.name.formatForDisplay»] (INVERSE SIDE)'''
            OneToManyRelationship: '''Many «targetName» [«target.nameMultiple.formatForDisplay»] are linked by one «sourceName» [«source.name.formatForDisplay»] (OWNING SIDE)'''
            default: ''
        }
    }
    def private incomingMappingDetails(Relationship it) {
        switch it {
            OneToOneRelationship case it.primaryKey: '''#[ORM\Id]'''
            default: ''
        }
    }
    def private incomingMappingType(Relationship it) {
        switch it {
            OneToOneRelationship: 'OneToOne'
            OneToManyRelationship: 'ManyToOne'
            default: ''
        }
    }

    def private dispatch incoming(ManyToOneRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * Bidirectional - «incomingMappingDescription(it, sourceName, targetName)».
         */
        «IF primaryKey»
            #[ORM\Id]
        «ENDIF»
        #[ORM\OneToOne]
        «joinDetails(false)»
        «IF !nullable»
            «val aliasName = getRelationAliasName(false).toFirstLower»
            #[Assert\NotNull(message: 'Choosing a «aliasName.formatForDisplay» is required.')]
        «ENDIF»«/* disabled due to problems with upload fields
        #[Assert\Valid]*/»
        protected ?«entityClass» $«sourceName» = null;
        «/* this last line is on purpose */»
    '''

    def private dispatch incomingMappingDescription(ManyToOneRelationship it, String sourceName, String targetName) '''One «targetName» [«target.name.formatForDisplay»] is linked by many «sourceName» [«source.nameMultiple.formatForDisplay»] (INVERSE SIDE)'''

    def private dispatch incoming(ManyToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        «IF bidirectional»
            /**
             * Bidirectional - «incomingMappingDescription(sourceName, targetName)».
             * @var Collection<int, «entityClass»>
             */
            #[ORM\ManyToMany(targetEntity: «entityClass»::class, mappedBy: '«targetName»'«additionalOptions(true)»)]
            «IF null !== orderByReverse && !orderByReverse.empty»
                #[ORM\OrderBy([«orderByDetails(orderByReverse)»])]
            «ENDIF»
            «IF !nullable»
                «val aliasName = getRelationAliasName(false).toFirstLower»
                #[Assert\NotNull(message: 'Choosing at least one of the «aliasName.formatForDisplay» is required.')]
            «ENDIF»
            «IF maxSource > 0»
                #[Assert\Count(min: «minSource», max: «maxSource»)]
            «ENDIF»
            protected ?Collection $«sourceName» = null;
        «ENDIF»
    '''

    def private dispatch incomingMappingDescription(ManyToManyRelationship it, String sourceName, String targetName) '''Many «targetName» [«target.nameMultiple.formatForDisplay»] are linked by many «sourceName» [«source.nameMultiple.formatForDisplay»] (INVERSE SIDE)'''

    /**
     * This default rule is used for OneToOne and ManyToOne.
     */
    def private dispatch outgoing(Relationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         */
        #[ORM\«outgoingMappingType»(targetEntity: «entityClass»::class«IF bidirectional», mappedBy: '«sourceName»'«ENDIF»«cascadeOptions(false)»«fetchTypeTag»«outgoingMappingAdditions»)]
        «joinDetails(true)»
        «IF it instanceof ManyToOneRelationship && (it as ManyToOneRelationship).sortableGroup»
            #[Gedmo\SortableGroup]
        «ENDIF»
        «IF !nullable»
            «val aliasName = getRelationAliasName(true).toFirstLower»
            «IF !isManySide(true)»
                #[Assert\NotNull(message: 'Choosing a «aliasName.formatForDisplay» is required.')]
            «ELSE»
                #[Assert\NotNull(message: 'Choosing at least one of the «aliasName.formatForDisplay» is required.')]
            «ENDIF»
        «ENDIF»«/* disabled due to problems with upload fields
        IF !isManySide(true)»
            #[Assert\Valid]
        «ENDIF*/»
        protected ?«entityClass» $«targetName» = null;
        «/* this last line is on purpose */»
    '''

    def private dispatch outgoingMappingDescription(Relationship it, String sourceName, String targetName) {
        switch it {
            OneToOneRelationship: '''One «sourceName» [«source.name.formatForDisplay»] has one «targetName» [«target.name.formatForDisplay»] (INVERSE SIDE)'''
            ManyToOneRelationship: '''Many «sourceName» [«source.nameMultiple.formatForDisplay»] have one «targetName» [«target.name.formatForDisplay»] (OWNING SIDE)'''
            default: ''
        }
    }
    def private outgoingMappingType(Relationship it) {
        switch it {
            OneToOneRelationship: 'OneToOne'
            ManyToOneRelationship: 'ManyToOne'
            default: ''
        }
    }

    def private dispatch outgoingMappingAdditions(Relationship it) ''''''
    def private dispatch outgoingMappingAdditions(OneToOneRelationship it) '''«IF orphanRemoval», orphanRemoval: true«ENDIF»'''
    def private dispatch outgoingMappingAdditions(OneToManyRelationship it) '''«IF orphanRemoval», orphanRemoval: true«ENDIF»'''
    def private dispatch outgoingMappingAdditions(ManyToManyRelationship it) '''«IF orphanRemoval», orphanRemoval: true«ENDIF»'''

    def private dispatch outgoing(OneToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         * @var Collection<int, «entityClass»>
         */
        «IF !bidirectional»
            #[ORM\ManyToMany(targetEntity: «entityClass»::class«additionalOptions(false)»)]
        «ELSE»
            #[ORM\OneToMany(targetEntity: «entityClass»::class, mappedBy: '«sourceName»'«additionalOptions(false)»«outgoingMappingAdditions»)]
        «ENDIF»
        «joinDetails(true)»
        «IF null !== orderBy && !orderBy.empty»
            #[ORM\OrderBy([«orderByDetails(orderBy)»])]
        «ENDIF»
        «IF !nullable»
            «val aliasName = getRelationAliasName(true).toFirstLower»
            #[Assert\NotNull(message: 'Choosing at least one of the «aliasName.formatForDisplay» is required.')]
        «ENDIF»
        «IF maxTarget > 0»
            #[Assert\Count(min: «minTarget», max: «maxTarget»)]
        «ENDIF»
        protected ?Collection $«targetName» = null;
        «/* this last line is on purpose */»
    '''

    def private dispatch outgoingMappingDescription(OneToManyRelationship it, String sourceName, String targetName) '''One «sourceName» [«source.name.formatForDisplay»] has many «targetName» [«target.nameMultiple.formatForDisplay»] (INVERSE SIDE)'''

    def private dispatch outgoing(ManyToManyRelationship it, String sourceName, String targetName, String entityClass) '''
        /**
         * «IF bidirectional»Bi«ELSE»Uni«ENDIF»directional - «outgoingMappingDescription(sourceName, targetName)».
         * @var Collection<int, «entityClass»>
         */
        #[ORM\ManyToMany(targetEntity: «entityClass»::class«IF bidirectional», inversedBy: '«sourceName»'«ENDIF»«additionalOptions(false)»«outgoingMappingAdditions»)]
        «joinDetails(true)»
        «IF null !== orderBy && !orderBy.empty»
            #[ORM\OrderBy([«orderByDetails(orderBy)»])]
        «ENDIF»
        «IF !nullable»
            «val aliasName = getRelationAliasName(true).toFirstLower»
            #[Assert\NotNull(message: 'Choosing at least one of the «aliasName.formatForDisplay» is required.')]
        «ENDIF»
        «IF maxTarget > 0»
            #[Assert\Count(min: «minTarget», max: «maxTarget»)]
        «ENDIF»
        protected ?Collection $«targetName» = null;
    '''

    def private dispatch outgoingMappingDescription(ManyToManyRelationship it, String sourceName, String targetName) '''Many «sourceName» [«source.nameMultiple.formatForDisplay»] have many «targetName» [«target.nameMultiple.formatForDisplay»] (OWNING SIDE)'''


    def private joinDetails(Relationship it, Boolean useTarget) {
        val joinedEntityLocal = { if (useTarget) source else target }
        val joinedEntityForeign = { if (useTarget) target else source }
        val joinColumnsLocal = { if (useTarget) getSourceFields else getTargetFields }
        val joinColumnsForeign = { if (useTarget) getTargetFields else getSourceFields }
        val foreignTableName = fullJoinTableName(useTarget, joinedEntityForeign)
        if (it instanceof OneToOneRelationship && !bidirectional) {
            '''«joinColumn(it, joinColumnsForeign.head, joinedEntityForeign.getPrimaryKey.name.formatForDB, useTarget, false)»'''
        } else if (joinColumnsForeign.containsDefaultIdField(joinedEntityForeign) && joinColumnsLocal.containsDefaultIdField(joinedEntityLocal)
           && !unique && nullable && onDelete.empty) '''#[ORM\JoinTable(name: '«foreignTableName»')]'''
        else '''
#[ORM\JoinTable(name: '«foreignTableName»')]
«joinTableDetails(useTarget)»
'''
    }

    def private joinTableDetails(Relationship it, Boolean useTarget) '''
        «val joinedEntityLocal = { if (useTarget) source else target }»
        «val joinedEntityForeign = { if (useTarget) target else source }»
        «val joinColumnsLocal = { if (useTarget) getSourceFields else getTargetFields }»
        «val joinColumnsForeign = { if (useTarget) getTargetFields else getSourceFields }»
        «IF (joinColumnsForeign.size > 1)»«joinColumnsMultiple(useTarget, joinedEntityLocal, joinColumnsLocal)»
        «ELSE»«joinColumnsSingle(useTarget, joinedEntityLocal, joinColumnsLocal)»
        «ENDIF»
        «IF (joinColumnsForeign.size > 1)»«FOR joinColumnForeign : joinColumnsForeign SEPARATOR ', '»«joinColumn(joinColumnForeign, joinedEntityForeign.getPrimaryKey.name.formatForDB, useTarget, true)»«ENDFOR»
        «ELSE»«joinColumn(joinColumnsForeign.head, joinedEntityForeign.getPrimaryKey.name.formatForDB, useTarget, true)»
        «ENDIF»
    '''

    def private joinColumnsMultiple(Relationship it, Boolean useTarget, Entity joinedEntityLocal, String[] joinColumnsLocal) '''«FOR joinColumnLocal : joinColumnsLocal»«joinColumn(joinColumnLocal, joinedEntityLocal.getPrimaryKey.name.formatForDB, !useTarget, false)»«ENDFOR»'''

    def private joinColumnsSingle(Relationship it, Boolean useTarget, Entity joinedEntityLocal, String[] joinColumnsLocal) '''«joinColumn(joinColumnsLocal.head, joinedEntityLocal.getPrimaryKey.name.formatForDB, !useTarget, false)»'''

    def private joinColumn(Relationship it, String columnName, String referencedColumnName, Boolean useTarget, Boolean inverse) '''
        #[ORM\«IF inverse»Inverse«ENDIF»JoinColumn(name: '«joinColumnName(columnName, useTarget)»', referencedColumnName: '«referencedColumnName»'«IF unique», unique: true«ENDIF»«IF !nullable», nullable: false«ENDIF»«IF !onDelete.empty», onDelete: '«onDelete»'«ENDIF»)]'''

    def private joinColumnName(Relationship it, String columnName, Boolean useTarget) {
        switch it {
            case columnName == 'id': (if (useTarget) target else source).name.formatForDB + '_id' //$NON-NLS-1$ //$NON-NLS-2$
            default: columnName
        }
        //(if (useTarget) target else source).name.formatForDB + '_' + columnName //$NON-NLS-1$
    }

    def private additionalOptions(Relationship it, Boolean useReverse) '''«cascadeOptions(useReverse)»«fetchTypeTag»'''
    def private cascadeOptions(Relationship it, Boolean useReverse) {
        val cascadeProperty = { if (useReverse) cascadeReverse else cascade }
        if (cascadeProperty == CascadeType.NONE) ''
        else ''', cascade: [«cascadeOptionsImpl(useReverse)»]'''
    }

    def private fetchTypeTag(Relationship it) { if (fetchType != RelationFetchType.LAZY) ''', fetch: '«fetchType.literal»'«''»''' }

    def private cascadeOptionsImpl(Relationship it, Boolean useReverse) {
        val cascadeProperty = { if (useReverse) cascadeReverse else cascade }
        if (cascadeProperty == CascadeType.PERSIST) '\'persist\''
        else if (cascadeProperty == CascadeType.REMOVE) '\'remove\''
        else if (cascadeProperty == CascadeType.MERGE) '\'merge\''
        else if (cascadeProperty == CascadeType.DETACH) '\'detach\''
        else if (cascadeProperty == CascadeType.PERSIST_REMOVE) '\'persist\', \'remove\''
        else if (cascadeProperty == CascadeType.PERSIST_MERGE) '\'persist\', \'merge\''
        else if (cascadeProperty == CascadeType.PERSIST_DETACH) '\'persist\', \'detach\''
        else if (cascadeProperty == CascadeType.REMOVE_MERGE) '\'remove\', \'merge\''
        else if (cascadeProperty == CascadeType.REMOVE_DETACH) '\'remove\', \'detach\''
        else if (cascadeProperty == CascadeType.MERGE_DETACH) '\'merge\', \'detach\''
        else if (cascadeProperty == CascadeType.PERSIST_REMOVE_MERGE) '\'persist\', \'remove\', \'merge\''
        else if (cascadeProperty == CascadeType.PERSIST_REMOVE_DETACH) '\'persist\', \'remove\', \'detach\''
        else if (cascadeProperty == CascadeType.PERSIST_MERGE_DETACH) '\'persist\', \'merge\', \'detach\''
        else if (cascadeProperty == CascadeType.REMOVE_MERGE_DETACH) '\'remove\', \'merge\', \'detach\''
        else if (cascadeProperty == CascadeType.ALL) '\'all\''
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
                sorting = criteriaParts.lastOrNull
            }
            criteria.add('"' + fieldName + '" = "' + sorting.toUpperCase + '"')
        }
        criteria.join(', ')
    }

    def initCollections(Entity it) '''
        «FOR relation : getOutgoingCollections»«relation.initCollection(true)»«ENDFOR»
        «FOR relation : getIncomingCollections»«relation.initCollection(false)»«ENDFOR»
    '''

    def private initCollection(Relationship it, Boolean outgoing) '''
        «IF isManySide(outgoing)»
            $this->«getRelationAliasName(outgoing)» = new ArrayCollection();
        «ENDIF»
    '''

    def relationAccessor(Relationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget)»
        «relationAccessorImpl(useTarget, relationAliasName)»
    '''

    def private relationAccessorImpl(Relationship it, Boolean useTarget, String aliasName) '''
        «val entityClass = { (if (useTarget) target else source).simpleEntityClassName }»
        «val nameSingle = { (if (useTarget) target else source).name }»
        «val isMany = isManySide(useTarget)»
        «IF isMany»
            «fh.getterAndSetterMethods(it, aliasName, 'Collection<int, ' + entityClass + '>', true, '', relationSetterCustomImpl(useTarget, aliasName))»
        «ELSE»
            «fh.getterAndSetterMethods(it, aliasName, entityClass, true, 'null', relationSetterCustomImpl(useTarget, aliasName))»
        «ENDIF»
        «IF isMany»
            «addMethod(useTarget, aliasName, nameSingle, entityClass)»
            «removeMethod(useTarget, aliasName, nameSingle, entityClass)»
        «ENDIF»
    '''

    def private relationSetterCustomImpl(Relationship it, Boolean useTarget, String aliasName) '''
        «val otherIsMany = isManySide(useTarget)»
        «IF otherIsMany»
            «val nameSingle = { (if (useTarget) target else source).name + 'Single' }»
            if (null === $this->«aliasName») {
                $this->«aliasName» = new ArrayCollection();
            }
            foreach ($this->«aliasName» as $«nameSingle») {
                $this->remove«aliasName.toFirstUpper»($«nameSingle»);
            }
            if (null !== $«aliasName») {
                foreach ($«aliasName» as $«nameSingle») {
                    $this->add«aliasName.toFirstUpper»($«nameSingle»);
                }
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

    def private addMethod(Relationship it, Boolean useTarget, String name, String nameSingle, String type) '''

        /**
         * Adds an instance of «type» to the list of «name.formatForDisplay».
         */
        «addMethodImpl(useTarget, name, nameSingle, type)»
    '''

    def private isManyToMany(Relationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }

    def private addParameters(Relationship it, Boolean useTarget, String name, String type) '''
        «type» $«name»'''

    def private addMethodSignature(Relationship it, Boolean useTarget, String name, String nameSingle, String type) '''
        public function add«name.toFirstUpper»(«addParameters(useTarget, nameSingle, type)»): self'''

    def private addMethodImplDefault(Relationship it, Boolean useTarget, String name, String nameSingle, String type) '''
        «addMethodSignature(useTarget, name, nameSingle, type)»
        {
            if (!$this->«name»->contains($«nameSingle»)) {
                $this->«name»->add($«nameSingle»);
                «addInverseCalls(useTarget, nameSingle)»
            }

            return $this;
        }
    '''
    def private dispatch addMethodImpl(Relationship it, Boolean useTarget, String name, String nameSingle, String type) '''
        «addMethodImplDefault(useTarget, name, nameSingle, type)»
    '''
    def private dispatch addMethodImpl(OneToManyRelationship it, Boolean useTarget, String name, String nameSingle, String type) '''
        «addMethodImplDefault(useTarget, name, nameSingle, type)»
    '''
    def private dispatch addMethodImpl(ManyToManyRelationship it, Boolean useTarget, String name, String nameSingle, String type) '''
        «addMethodImplDefault(useTarget, name, nameSingle, type)»
    '''

    def private addInverseCalls(Relationship it, Boolean useTarget, String nameSingle) '''
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

    def private removeMethod(Relationship it, Boolean useTarget, String name, String nameSingle, String type) '''

        /**
         * Removes an instance of «type» from the list of «name.formatForDisplay».
         */
        public function remove«name.toFirstUpper»(«type» $«nameSingle»): self
        {
            if ($this->«name»->contains($«nameSingle»)) {
                $this->«name»->removeElement($«nameSingle»);
                «val generateInverseCalls = bidirectional && ((!isManyToMany && useTarget) || (isManyToMany && !useTarget))»
                «IF generateInverseCalls»
                    «val ownAliasName = getRelationAliasName(!useTarget).toFirstUpper»
                    «val otherIsMany = isManySide(!useTarget)»
                    «IF otherIsMany»
                        $«nameSingle»->remove«ownAliasName»($this);
                    «ELSE»
                        if ($«nameSingle»->get«ownAliasName»() === $this) {
                            $«nameSingle»->set«ownAliasName»(null);
                        }
                    «ENDIF»
                «ENDIF»
            }

            return $this;
        }
    '''

    def private isBidirectional(Relationship it) {
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
