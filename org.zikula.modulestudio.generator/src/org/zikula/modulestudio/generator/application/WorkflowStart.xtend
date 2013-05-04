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
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.Diagnostician
import org.eclipse.emf.common.util.Diagnostic
import de.guite.modulestudio.metamodel.modulestudio.Application

/**
 * Main entry point for the workflow.
 */
class WorkflowStart {

    private String currentCartridge = ''
    public WorkflowSettings settings = new WorkflowSettings()
    public WorkflowPreProcess preProcess = new WorkflowPreProcess()
    private Resource model = null;

	/**
	 * Validate the model
	 * 
	 */
	def validate() {
		val progressMonitor = settings.progressMonitor
		progressMonitor.beginTask('Validating "' + settings.appName + ' ' + settings.appVersion + '" ...', -1)
    	
    	var diag = Diagnostician::INSTANCE.validate(getModel.contents.get(0))
    	
    	switch  diag.getSeverity {
    		case Diagnostic::ERROR: {
    			progressMonitor.subTask("Errors: " + diag.toString)
    			progressMonitor.done();
    			return false;
    		}
    		case Diagnostic::WARNING: {
    			progressMonitor.subTask("Warnings: " + diag.toString)
    			progressMonitor.done();
    			return true;
    		}
    		default: {
    			progressMonitor.subTask("Valid: " + diag.toString)
    			progressMonitor.done();
    			return true;
    		}
    	}
	}

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
            val progressMonitor = settings.progressMonitor
            progressMonitor.beginTask('Generating "' + settings.appName + ' ' + settings.appVersion + '" ...', -1)

            for (singleCartridge : settings.getSelectedCartridges) {
                // The generator cartridge to execute (zclassic, reporting)
                currentCartridge = singleCartridge.toString

                if (!currentCartridge.equals('reporting')) {
                    val generator = new MostGenerator
                    generator.setCartridge(currentCartridge)
                    generator.setMonitor(settings.progressMonitor)

                    val fileSystemAccess = getConfiguredFileSystemAccess

                    generator.doGenerate(getModel, fileSystemAccess)
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
            'DEFAULT_OUTPUT', settings.getOutputPath + '/' + currentCartridge + '/' + settings.getAppName + '/');

        configuredFileSystemAccess
    }
    
    def private getModel() {
    	if (model === null) {
        	val reader = new ModelReader()
        	reader.setUri(settings.modelPath)
        	model = reader.invoke
    	}
    	model
    }
    
    def readSettingsFromModel() {
    	val model = getModel
    	val app = model.contents.get(0) as Application;
    	println(app.getName())
    	settings.appName = app.name
		settings.appVersion = app.version
    	return
    }
}
