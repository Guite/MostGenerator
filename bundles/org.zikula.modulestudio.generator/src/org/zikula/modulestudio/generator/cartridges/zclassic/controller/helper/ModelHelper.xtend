package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.RelationEditMode
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModelHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for model layer'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ModelHelper.php', modelFunctionsBaseImpl, modelFunctionsImpl)
    }

    def private modelFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use «appNamespace»\Entity\Factory\EntityFactory;

        /**
         * Helper base class for model layer methods.
         */
        abstract class AbstractModelHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var EntityFactory
         */
        protected $entityFactory;

        public function __construct(EntityFactory $entityFactory)
        {
            $this->entityFactory = $entityFactory;
        }

        «canBeCreated»

        «hasExistingInstances»

        «resolveSortParameter»
    '''

    def private canBeCreated(Application it) '''
        /**
         * Determines whether creating an instance of a certain object type is possible.
         * This is when
         *     - it has no incoming bidirectional non-nullable relationships.
         *     - the edit type of all those relationships has PASSIVE_EDIT and auto completion is used on the target side
         *       (then a new source object can be created while creating the target object).
         *     - corresponding source objects exist already in the system.
         *
         * Note that even creation of a certain object is possible, it may still be forbidden for the current user
         * if he does not have the required permission level.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         *
         * @return bool Whether a new instance can be created or not
         «ENDIF»
         */
        public function canBeCreated(«IF targets('3.0')»string «ENDIF»$objectType = '')«IF targets('3.0')»: bool«ENDIF»
        {
            $result = false;

            switch ($objectType) {
                «FOR entity : getAllEntities.filter[hasEditAction]»
                    case '«entity.name.formatForCode»':
                        «entity.canBeCreatedImpl»
                        break;
                «ENDFOR»
            }

            return $result;
        }
    '''

    def private canBeCreatedImpl(Entity it) '''
        «var incomingAndMandatoryRelations = getBidirectionalIncomingAndMandatoryJoinRelations»
        «IF incomingAndMandatoryRelations.empty»«/* has no incoming bidirectional non-nullable relationships */»
            $result = true;
        «ELSE»«/* we can leave out those relations which have INLINE OR EMBEDDED as target edit type and use auto completion on the target side
                * (then a new source object can be created while creating the target object). */»
            «{incomingAndMandatoryRelations = incomingAndMandatoryRelations
                .filter[!usesAutoCompletion(true)]
                .filter[!#[RelationEditMode.INLINE, RelationEditMode.EMBEDDED].contains(getTargetEditMode)]; ''}»
            «IF incomingAndMandatoryRelations.empty»
                $result = true;
            «ELSE»«/* corresponding source objects exist already in the system */»
                $result = true;
                «FOR entity : getUniqueListOfSourceEntityTypes(incomingAndMandatoryRelations)»
                    $result &= $this->hasExistingInstances('«entity.name.formatForCode»');
                «ENDFOR»
            «ENDIF»
        «ENDIF»
    '''

    def private getUniqueListOfSourceEntityTypes(Entity it, Iterable<JoinRelationship> relations) {
        var sourceTypes = newArrayList
        for (relation : relations) {
            if (!sourceTypes.contains(relation.source)) {
                sourceTypes += relation.source
            }
        }
        sourceTypes
    }

    def private resolveSortParameter(Application it) '''
        /**
         * Returns a desired sorting criteria for passing it to a repository method.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         * @param string $sorting The type of sorting (newest, random, default)
         *
         * @return string The order by clause
         «ENDIF»
         */
        public function resolveSortParameter(«IF targets('3.0')»string «ENDIF»$objectType = '', «IF targets('3.0')»string «ENDIF»$sorting = 'default')«IF targets('3.0')»: string«ENDIF»
        {
            if ('random' === $sorting) {
                return 'RAND()';
            }

            $hasStandardFields = in_array($objectType, ['«getAllEntities.filter[standardFields].map[name.formatForCode].join('\', \'')»']);

            $sortParam = '';
            if ('newest' === $sorting) {
                if (true === $hasStandardFields) {
                    $sortParam = 'createdDate DESC';
                } else {
                    $sortParam = $this->entityFactory->getIdField($objectType) . ' DESC';
                }
            } elseif ('updated' === $sorting) {
                if (true === $hasStandardFields) {
                    $sortParam = 'updatedDate DESC';
                } else {
                    $sortParam = $this->entityFactory->getIdField($objectType) . ' DESC';
                }
            } elseif ('default' === $sorting) {
                $repository = $this->entityFactory->getRepository($objectType);
                $sortParam = $repository->getDefaultSortingField();
            }

            return $sortParam;
        }
    '''

    def private hasExistingInstances(Application it) '''
        /**
         * Determines whether there exists at least one instance of a certain object type in the database.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         *
         * @return bool Whether at least one instance exists or not
         «ENDIF»
         */
        protected function hasExistingInstances(«IF targets('3.0')»string «ENDIF»$objectType = '')«IF targets('3.0')»: bool«ENDIF»
        {
            $repository = $this->entityFactory->getRepository($objectType);
            if (null === $repository) {
                return false;
            }

            return 0 < $repository->selectCount();
        }
    '''

    def private modelFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractModelHelper;

        /**
         * Helper implementation class for model layer methods.
         */
        class ModelHelper extends AbstractModelHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
