package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.RelationEditType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModelHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for model layer')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/ModelHelper.php',
            fh.phpFileContent(it, modelFunctionsBaseImpl), fh.phpFileContent(it, modelFunctionsImpl)
        )
    }

    def private modelFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use «appNamespace»\Entity\Factory\EntityFactory;

        /**
         * Helper base class for model layer methods.
         */
        abstract class AbstractModelHelper
        {
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * ModelHelper constructor.
             *
             * @param EntityFactory $entityFactory EntityFactory service instance
             */
            public function __construct(EntityFactory $entityFactory)
            {
                $this->entityFactory = $entityFactory;
            }

            «canBeCreated»

            «hasExistingInstances»

            «resolveSortParameter»
        }
    '''

    def private canBeCreated(Application it) '''
        /**
         * Determines whether creating an instance of a certain object type is possible.
         * This is when
         *     - no tree is used
         *     - it has no incoming bidirectional non-nullable relationships.
         *     - the edit type of all those relationships has PASSIVE_EDIT and auto completion is used on the target side
         *       (then a new source object can be created while creating the target object).
         *     - corresponding source objects exist already in the system.
         *
         * Note that even creation of a certain object is possible, it may still be forbidden for the current user
         * if he does not have the required permission level.
         *
         * @param string $objectType Name of treated entity type
         *
         * @return boolean Whether a new instance can be created or not
         */
        public function canBeCreated($objectType)
        {
            $result = false;

            switch ($objectType) {
                «FOR entity : getAllEntities.filter[hasEditAction && tree == EntityTreeType.NONE]»
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
        «ELSE»«/* we can leave out those relations which have PASSIVE_EDIT as edit type and use auto completion on the target side
                * (then a new source object can be created while creating the target object). */»
            «{incomingAndMandatoryRelations = incomingAndMandatoryRelations
                .filter[!usesAutoCompletion(true)]
                .filter[getEditingType != RelationEditType.ACTIVE_NONE_PASSIVE_EDIT && getEditingType != RelationEditType.ACTIVE_EDIT_PASSIVE_EDIT]; ''}»
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
        var sourceTypes = newArrayList()
        for (relation : relations) {
            if (!sourceTypes.contains(relation.source)) {
                sourceTypes.add(relation.source)
            }
        }
        sourceTypes
    }

    def private resolveSortParameter(Application it) '''
        /**
         * Returns a desired sorting criteria for passing it to a repository method.
         *
         * @param string $objectType Name of treated entity type
         * @param string $sorting    The type of sorting (newest, random, default)
         *
         * @return string The order by clause
         */
        public function resolveSortParameter($objectType = '', $sorting = 'default')
        {
            if ($sorting == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($sorting == 'newest') {
                $sortParam = $this->entityFactory->getIdField($objectType) . ' DESC';
            } elseif ($sorting == 'default') {
                $repository = $this->entityFactory->getRepository($objectType);
                $sortParam = $repository->getDefaultSortingField() . ' ASC';
            }

            return $sortParam;
        }
    '''

    def private hasExistingInstances(Application it) '''
        /**
         * Determines whether there exists at least one instance of a certain object type in the database.
         *
         * @param string $objectType Name of treated entity type
         *
         * @return boolean Whether at least one instance exists or not
         */
        protected function hasExistingInstances($objectType)
        {
            $repository = $this->entityFactory->getRepository($objectType);
            if (null === $repository) {
                return false;
            }

            return $repository->selectCount() > 0;
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
