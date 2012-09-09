package org.zikula.modulestudio.generator.application

import java.io.IOException
import org.zikula.modulestudio.generator.exceptions.ExceptionBase
import org.zikula.modulestudio.generator.exceptions.M2TFailedCartridgeIncomplete
import org.zikula.modulestudio.generator.exceptions.M2TFailedGeneratorResourceNotFound
import org.zikula.modulestudio.generator.exceptions.M2TUnknownException

/**
 * Main entry point for the workflow.
 */
class WorkflowStart {

    public WorkflowSettings settings = new WorkflowSettings()
    public WorkflowPreProcess preProcess = new WorkflowPreProcess()

    /**
     * Executes the workflow.
     */
    def run() throws ExceptionBase {
        performM2T
        new WorkflowPostProcess(settings).run
    }

    /**
     * Workflow facade executing the actual model-to-text workflows.
     */
    def private performM2T() throws ExceptionBase {
        if (settings.getSelectedCartridges.size == 1 && settings.getSelectedCartridges.head == 'reporting') {
            return;
        }

        try {
            // instantiate generator with Application instance and progress monitor
            val msGen = new ModuleStudioGenerator(settings.getApp, settings.getProgressMonitor)
            for (singleCartridge : settings.getSelectedCartridges) {
                // run workflow
                val generateResult = msGen.runWorkflow(settings.getOutputPath, singleCartridge.toString)
                if (!generateResult) {
                    throw new M2TFailedCartridgeIncomplete(singleCartridge.toString)
                }
            }
        } catch (IOException e) {
            throw new M2TFailedGeneratorResourceNotFound()
        } catch (Exception e) {
            e.printStackTrace();
            throw new M2TUnknownException()
        }
    }
}
