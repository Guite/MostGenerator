package org.zikula.modulestudio.generator.application

import com.google.inject.Injector
import java.io.IOException
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.MostGenerator
import org.zikula.modulestudio.generator.cartridges.MostGeneratorSetup
import org.zikula.modulestudio.generator.exceptions.ExceptionBase
import org.zikula.modulestudio.generator.exceptions.M2TFailedGeneratorResourceNotFound
import org.zikula.modulestudio.generator.exceptions.M2TUnknownException
import org.zikula.modulestudio.generator.workflow.components.ModelReader

/**
 * Main entry point for the workflow.
 */
class WorkflowStart {

    private String modelName = ''
    private String currentCartridge = ''
    public WorkflowSettings settings = new WorkflowSettings()
    public WorkflowPreProcess preProcess = new WorkflowPreProcess()

    /**
     * Executes the workflow; preProcess.run() has already been called.
     */
    def run() throws ExceptionBase {
        performM2T
        new WorkflowPostProcess(settings).run
    }

    /**
     * Workflow facade executing the actual model-to-text workflows.
     */
    def private performM2T() throws ExceptionBase {
        if (settings.selectedCartridges.size == 1 && settings.selectedCartridges.head == 'reporting') {
            return false
        }

        var success = false

        try {
            val modelPathFull = settings.modelPath
            // The path where to find the model, without trailing slash
            val modelPathOnly = modelPathFull.substring(0, modelPathFull.lastIndexOf('/'))
            // The model to be processed (file name without extension)
            modelName = modelPathFull.replace(modelPathOnly, '').replace('.mostapp', '').replaceFirst('/', '')

            val progressMonitor = settings.progressMonitor
            progressMonitor.beginTask('Generating "' + settings.appName + ' ' + settings.appVersion + '" ...', -1)

            for (singleCartridge : settings.getSelectedCartridges) {
                // The generator cartridge to execute (zclassic, reporting)
                currentCartridge = singleCartridge.toString

                if (!currentCartridge.equals('reporting')) {
                    val generator = new MostGenerator
                    generator.setCartridge(currentCartridge)
                    generator.setMonitor(settings.progressMonitor)

                    val reader = new ModelReader()
                    reader.setUri(settings.modelPath)
                    val resource = reader.invoke
                    val fileSystemAccess = getConfiguredFileSystemAccess

                    generator.doGenerate(resource, fileSystemAccess)
                }
            }
            success = true
        } catch (IOException e) {
            throw new M2TFailedGeneratorResourceNotFound
        } catch (Exception e) {
            e.printStackTrace
            throw new M2TUnknownException
        } finally {
        }

        success
    }

    def protected getConfiguredFileSystemAccess() {
        val setup = new MostGeneratorSetup
        val Injector injector = setup.createInjectorAndDoEMFRegistration

        val configuredFileSystemAccess = injector
                .getInstance(typeof(JavaIoFileSystemAccess))

        configuredFileSystemAccess.setOutputPath(
            'DEFAULT_OUTPUT', settings.getOutputPath + '/' + currentCartridge + '/' + modelName + '/');

        configuredFileSystemAccess
    }
}
