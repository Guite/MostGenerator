package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleApproval {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for Simple Approval workflow.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        val workflowPath = appName.getAppSourcePath + 'workflows/'
        fsa.generateFile(workflowPath + 'simpleapproval.xml', xmlSchema)
        fsa.generateFile(workflowPath + 'function.standard_permissioncheck.php', permissionCheckFile)
        fsa.generateFile(workflowPath + 'operations/function.updateObjectStatus.php', updateStatusOperationFile)
    }

    def private permissionCheckFile(Application it) '''
        «fh.phpFileHeader(it)»
        «permissionCheckImpl»
    '''

    def private updateStatusOperationFile(Application it) '''
        «fh.phpFileHeader(it)»
        «updateStatusOperationImpl»
    '''

    def private xmlSchema(Application it) '''
        <workflow>
            <title>Simple approval workflow</title>
            <description>Simple content workflow for approval by moderators.</description>

            <!-- define available states -->
            <states>
                <state id="initial">
                    <title>Initial</title>
                    <description>Initial state. Content has been created, but not yet submitted.</description>
                </state>

                <state id="waiting">
                    <title>Waiting</title>
                    <description>Content has been submitted and is waiting for acceptance.</description>
                </state>

                <state id="approved">
                    <title>Approved</title>
                    <description>Content has been approved and is available online.</description>
                </state>
            </states>

            <!-- define actions and assign their availability to certain states -->
            <!-- available permissions: overview, read, comment, edit, add, delete, moderate, admin -->
            <actions>
                <!-- begin actions for initial state -->
                <action id="submit">
                    <title>Submit</title>
                    <description>Submit new content for acceptance by the local moderator.</description>
                    <permission>add</permission>
                    <state>initial</state>
                    <nextState>waiting</nextState>
                    <operation ot="item" status="2">updateObjectStatus</operation>
                  <!-- multiple operations can be executed in sequence
                    <operation group='admin'>notify</operation>
                  -->
                  <!-- actions can also define additional parameters
                    <parameter className="z-bt-ok" titleText="Click me">Button</parameter>
                  -->
                </action>

                <action id="approve">
                    <title>Approve</title>
                    <description>Approve publication for immediate publishing.</description>
                    <permission>moderate</permission>
                    <state>waiting</state>
                    <nextState>approved</nextState>
                    <operation ot="item" status="3">updateObjectStatus</operation>
                </action>
            </actions>
        </workflow>
    '''

    def permissionCheckImpl(Application it) '''
        /**
         * Check permissions during the workflow.
         *
         * @param array $obj
         * @param int $permLevel
         * @param int $currentUser
         * @return bool
         */
        function «appName»_workflow_simpleapproval_permissioncheck($obj, $permLevel, $currentUser)
        {
            /** TODO */
            $component = '«appName»:objecttype:';
            // process $obj and calculate an instance
            /** TODO */
            $instance = 'ids::';

            return SecurityUtil::checkPermission($component, $instance, $permLevel, $currentUser);
        }
    '''

    def updateStatusOperationImpl(Application it) '''
        /**
         * Operation method for amendments of the status field.
         *
         * @param array $obj
         * @param array, $params
         *
         * @return bool
         */
        function «appName»_operation_updateObjectStatus(&$obj, $params)
        {
            // get attributes read from the workflow
            $objectType = isset($params['ot']) ? $params['ot'] : 'item'; /** TODO required? */
            $status = isset($params['status']) ? $params['status'] : 1;

            // assign value to the data object
            $obj['status'] = $status;

            /** TODO */
            //return {UPDATE}
            return true;
        }
    '''
}
