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
class LegacyOperations {

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
         *
         * @param object $entity The treated object
         * @param array  $params Additional arguments
         *
         * @return bool False on failure or true if everything worked well
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         */
        function «app.appName»_operation_«opName»(&$entity, $params)
        {
«/*
            // handling of additional parameters
            // $params['foobar'] = isset($params['foobar']) ? (bool)$params['foobar'] : false;
*/»
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
        // get attributes read from the workflow
        if (isset($params['nextstate']) && !empty($params['nextstate'])) {
            // assign value to the data object
            $entity['workflowState'] = $params['nextstate'];
        }

        // get entity manager
        $container = \ServiceUtil::get('service_container');
        $entityManager = $container->get('«app.entityManagerService»');
        $logger = $container->get('logger');
        $logArgs = ['app' => '«app.appName»', 'user' => $container->get('zikula_users_module.current_user')->get('uname')];

        // save entity data
        try {
            //$this->entityManager->transactional(function($entityManager) {
            $entityManager->persist($entity);
            $entityManager->flush();
            //});
            $result = true;
            $logger->notice('{app}: User {user} updated an entity.', $logArgs);
        } catch (\Exception $e) {
            $logger->error('{app}: User {user} tried to update an entity, but failed.', $logArgs);
            throw new \RuntimeException($e->getMessage());
        }
    '''

    def private deleteImpl() '''
        // get attributes read from the workflow
        if (isset($params['nextstate']) && !empty($params['nextstate'])) {
            // assign value to the data object
            $entity['workflowState'] = $params['nextstate'];
        }

        // get entity manager
        $container = \ServiceUtil::get('service_container');
        $entityManager = $container->get('«app.entityManagerService»');
        $logger = $container->get('logger');
        $logArgs = ['app' => '«app.appName»', 'user' => $container->get('zikula_users_module.current_user')->get('uname')];

        // delete entity
        try {
            $entityManager->remove($entity);
            $entityManager->flush();
            $result = true;
            $logger->notice('{app}: User {user} deleted an entity.', $logArgs);
        } catch (\Exception $e) {
            $logger->error('{app}: User {user} tried to delete an entity, but failed.', $logArgs);
            throw new \RuntimeException($e->getMessage());
        }
    '''

    def private notifyImpl() '''
        // workflow parameters are always lower-cased (#656)
        $recipientType = isset($params['recipientType']) ? $params['recipientType'] : $params['recipienttype'];

        $notifyArgs = [
            'recipientType' => $recipientType,
            'action' => $params['action'],
            'entity' => $entity
        ];

        $result = \ServiceUtil::get('«app.appService».notification_helper')->process($notifyArgs);
    '''
}
