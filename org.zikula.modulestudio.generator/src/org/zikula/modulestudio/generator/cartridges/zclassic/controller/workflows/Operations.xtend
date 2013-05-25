package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
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
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension WorkflowExtensions = new WorkflowExtensions()
    @Inject extension Utils = new Utils()

    Application app
    //EntityWorkflowType wfType

    IFileSystemAccess fsa
    String outputPath
    FileHelper fh = new FileHelper()

    /**
     * Entry point for workflow operations.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        app = it
        this.fsa = fsa
        outputPath = getAppSourcePath + 'workflows/operations/'

        generate(EntityWorkflowType::NONE)
        generate(EntityWorkflowType::STANDARD)
        generate(EntityWorkflowType::ENTERPRISE)
    }

    def private generate(EntityWorkflowType wfType) {
        if (!app.hasWorkflow(wfType)) {
            return
        }

        //this.wfType = wfType

        operation('update')
        operation('delete')
    }

    def private operation(String opName) {
        fsa.generateFile(outputPath + 'function.' + opName + '.php', operationFile(opName))
    }

    def private operationFile(String opName) '''
        «fh.phpFileHeader(app)»
        /**
         * «opName.formatForDisplayCapital» operation.
         * @param object $entity The treated object.
         * @param array  $params Additional arguments.
         *
         * @return bool False on failure or true if everything worked well.
         */
        function «app.appName»_operation_«opName»(&$entity, $params)
        {
            $dom = ZLanguage::getModuleDomain('«app.appName»');
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
                $entity['bypassValidation'] = true;
            }
        }

        // get entity manager
        $serviceManager = ServiceUtil::getManager();
        $entityManager = $serviceManager->getService('doctrine.entitymanager');

        // save entity data
        try {
            //$this->entityManager->transactional(function($entityManager) {
            $entityManager->persist($entity);
            $entityManager->flush();
            //});
            $result = true;
        } catch (Exception $e) {
            LogUtil::registerError($e->getMessage());
        }
    '''

    def private deleteImpl() '''
        // get entity manager
        $serviceManager = ServiceUtil::getManager();
        $entityManager = $serviceManager->getService('doctrine.entitymanager');

        // delete entity
        try {
            $entityManager->remove($entity);
            $entityManager->flush();
            $result = true;
        } catch (Exception $e) {
            LogUtil::registerError($e->getMessage());
        }
    '''
}
