package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.RelationEditType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModelUtil {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for model layer')
        generateClassPair(fsa, getAppSourceLibPath + 'Util/Model' + (if (targets('1.3.5')) '' else 'Util') + '.php',
            fh.phpFileContent(it, modelFunctionsBaseImpl), fh.phpFileContent(it, modelFunctionsImpl)
        )
    }

    def private modelFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Util\Base;

            use ModUtil;
            use Zikula_AbstractBase;

        «ENDIF»
        /**
         * Utility base class for model helper methods.
         */
        class «IF targets('1.3.5')»«appName»_Util_Base_Model«ELSE»ModelUtil«ENDIF» extends Zikula_AbstractBase
        {
            «canBeCreated»

            «hasExistingInstances»
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
         * @param string $objectType Name of treated entity type.
         *
         * @return boolean Whether a new instance can be created or not.
         */
        public function canBeCreated($objectType)
        {
            «IF targets('1.3.5')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->serviceManager->get('«appName.formatForDB».controller_helper');
            «ENDIF»
            if (!in_array($objectType, $controllerHelper->getObjectTypes('util', array('util' => 'model', 'action' => 'canBeCreated')))) {
                throw new \Exception('Error! Invalid object type received.');
            }

            $result = false;

            switch ($objectType) {
                «FOR entity : entities.filter[tree == EntityTreeType.NONE]»
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
                .filter[editType != RelationEditType.ACTIVE_NONE_PASSIVE_EDIT && editType != RelationEditType.ACTIVE_EDIT_PASSIVE_EDIT]; ''}»
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

    def private hasExistingInstances(Application it) '''
        /**
         * Determines whether there exist at least one instance of a certain object type in the database.
         *
         * @param string $objectType Name of treated entity type.
         *
         * @return boolean Whether at least one instance exists or not.
         */
        protected function hasExistingInstances($objectType)
        {
            «IF targets('1.3.5')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->serviceManager->get('«appName.formatForDB».controller_helper');
            «ENDIF»
            if (!in_array($objectType, $controllerHelper->getObjectTypes('util', array('util' => 'model', 'action' => 'hasExistingInstances')))) {
                throw new \Exception('Error! Invalid object type received.');
            }

            «IF targets('1.3.5')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
                $repository = $this->entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $this->serviceManager->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();
            «ENDIF»

            return ($repository->selectCount() > 0);
        }
    '''

    def private modelFunctionsImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Util;

            use «appNamespace»\Util\Base\ModelUtil as BaseModelUtil;

        «ENDIF»
        /**
         * Utility implementation class for model helper methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_Model extends «appName»_Util_Base_Model
        «ELSE»
        class ModelUtil extends BaseModelUtil
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
