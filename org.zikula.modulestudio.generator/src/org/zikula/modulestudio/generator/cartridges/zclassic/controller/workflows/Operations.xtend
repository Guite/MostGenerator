package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

/**
 * Workflow operations.
 */
class Operations {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension WorkflowExtensions = new WorkflowExtensions
    extension Utils = new Utils

    Application app
    //EntityWorkflowType wfType

    IFileSystemAccess fsa
    String outputPath
    FileHelper fh = new FileHelper

    /**
     * Entry point for workflow operations.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        app = it
        this.fsa = fsa
        outputPath = getAppSourcePath + 'workflows/operations/'

        generate(EntityWorkflowType.NONE)
        generate(EntityWorkflowType.STANDARD)
        generate(EntityWorkflowType.ENTERPRISE)
    }

    def private generate(EntityWorkflowType wfType) {
        if (!app.hasWorkflow(wfType)) {
            return
        }

        //this.wfType = wfType

        operation('update')
        operation('delete')
        if (app.needsApproval) {
            operation('notify')
        }
    }

    def private operation(String opName) {
        var fileName = 'function.' + opName + '.php'
        if (!app.shouldBeSkipped(outputPath + fileName)) {
            if (app.shouldBeMarked(outputPath + fileName)) {
                fileName = 'function.' + opName + '.generated.php'
            }
            fsa.generateFile(outputPath + fileName, fh.phpFileContent(app, operationFile(opName)))
        }
    }

    def private operationFile(String opName) '''
        /**
         * «opName.formatForDisplayCapital» operation.
         * @param object $entity The treated object.
         * @param array  $params Additional arguments.
         *
         * @return bool False on failure or true if everything worked well.
         «IF !app.targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         «ENDIF»
         */
        function «app.appName»_operation_«opName»(&$entity, $params)
        {
            $dom = «IF !app.targets('1.3.x')»\«ENDIF»ZLanguage::getModuleDomain('«app.appName»');
«/*
            // handling of additional parameters
            // $params['foobar'] = isset($params['foobar']) ? (bool)$params['foobar'] : false;
*/»

            // initialise the result flag
            $result = false;

            «operationImpl(opName)»

            // return result of this operation
            return $result;
        }
    '''

    def private operationImpl(String opName) '''
        «IF opName == 'update'»«updateImpl»
        «ELSEIF opName == 'delete'»«deleteImpl»
        «ELSEIF opName == 'notify'»«notifyImpl»
        «ENDIF»
    '''

    def private updateImpl() '''
        $objectType = $entity['_objectType'];
        $currentState = $entity['workflowState'];

        // get attributes read from the workflow
        if (isset($params['nextstate']) && !empty($params['nextstate'])) {
            // assign value to the data object
            $entity['workflowState'] = $params['nextstate'];
            if ($params['nextstate'] == 'archived') {
                // bypass validator (for example an end date could have lost it's "value in future")
                $entity['_bypassValidation'] = true;
            }
        }

        // get entity manager
        $serviceManager = «IF !app.targets('1.3.x')»\«ENDIF»ServiceUtil::getManager();
        $entityManager = $serviceManager->get«IF app.targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');

        // save entity data
        try {
            //$this->entityManager->transactional(function($entityManager) {
            $entityManager->persist($entity);
            $entityManager->flush();
            //});
            $result = true;
            «IF !app.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->notice('{app}: User {user} updated an entity.', array('app' => '«app.appName»', 'user' => \UserUtil::getVar('uname')));
            «ENDIF»
        } catch (\Exception $e) {
            «IF app.targets('1.3.x')»LogUtil::registerError«ELSE»throw new \RuntimeException«ENDIF»($e->getMessage());
            «IF !app.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->error('{app}: User {user} tried to update an entity, but failed.', array('app' => '«app.appName»', 'user' => \UserUtil::getVar('uname')));
            «ENDIF»
        }
    '''

    def private deleteImpl() '''
        // get entity manager
        $serviceManager = «IF !app.targets('1.3.x')»\«ENDIF»ServiceUtil::getManager();
        $entityManager = $serviceManager->get«IF app.targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');

        // delete entity
        try {
            $entityManager->remove($entity);
            $entityManager->flush();
            $result = true;
            «IF !app.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->notice('{app}: User {user} deleted an entity.', array('app' => '«app.appName»', 'user' => \UserUtil::getVar('uname')));
            «ENDIF»
        } catch (\Exception $e) {
            «IF app.targets('1.3.x')»LogUtil::registerError«ELSE»throw new \RuntimeException«ENDIF»($e->getMessage());
            «IF !app.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->error('{app}: User {user} tried to delete an entity, but failed.', array('app' => '«app.appName»', 'user' => \UserUtil::getVar('uname')));
            «ENDIF»
        }
    '''

    def private notifyImpl() '''
        // workflow parameters are always lower-cased (#656)
        $recipientType = isset($params['recipientType']) ? $params['recipientType'] : $params['recipienttype'];

        $notifyArgs = array(
            'recipientType' => $recipientType,
            'action' => $params['action'],
            'entity' => $entity
        );

        ModUtil::apiFunc('«app.appName»', 'notification', 'process', $notifyArgs);
    '''
}
