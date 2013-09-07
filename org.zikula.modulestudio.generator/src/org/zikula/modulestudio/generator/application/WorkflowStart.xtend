
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
import org.eclipse.xtext.util.EmfFormatter
import org.eclipse.xtext.validation.FeatureBasedDiagnostic

/**
 * Return Value for Validate Method
 */
enum ErrorState { OK, WARN, ERROR }

/**
 * Main entry point for the workflow.
 */
class WorkflowStart {

    /**
     * Name of currently processed generator cartridge.
     */
    private String currentCartridge = ''

    public WorkflowSettings settings = new WorkflowSettings

    public WorkflowPreProcess preProcess = new WorkflowPreProcess

    /**
     * Reference to the model's {@link Resource} object.
     */
    private Resource model = null;

    /**
     * The Guice injector instance which may be provided
     * if the generator is executed inside MOST.
     */
    public Injector injector = null;

	/**
	 * Validates the model.
	 */
	def validate() {
		val progressMonitor = settings.progressMonitor
		progressMonitor.beginTask('Validating "' + settings.appName + ' ' + settings.appVersion + '" ...', -1)
    	
    	var diag = Diagnostician.INSTANCE.validate(getModel.contents.head)
    	
    	switch  diag.getSeverity {
    		case Diagnostic.ERROR: {
    			progressMonitor.subTask("Errors: \n" + validatorMessage(diag))
    			progressMonitor.done
    			return ErrorState.ERROR
    		}
    		case Diagnostic.WARNING: {
    			progressMonitor.subTask("Warnings: \n" + validatorMessage(diag))
    			progressMonitor.done
    			return ErrorState.WARN
    		}
    		default: {
    			progressMonitor.subTask('Valid')
    			progressMonitor.done
    			return ErrorState.OK
    		}
    	}
	}

	def validatorMessage(Diagnostic diag) 
		'''
		«FOR c: diag.children»
		- «c.message» at «EmfFormatter.objPath((c as FeatureBasedDiagnostic).sourceEObject)»
		«ENDFOR»
		'''

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
                .getInstance(JavaIoFileSystemAccess)

        configuredFileSystemAccess.setOutputPath(
            'DEFAULT_OUTPUT', settings.getOutputPath + '/' + currentCartridge + '/' + settings.getAppName + '/');

        configuredFileSystemAccess
    }
    
    def private getModel() {
        // do not read in the model again after validation did it already
    	if (model === null) {
        	val reader = new ModelReader
        	reader.uri = settings.modelPath
        	if (injector !== null) {
        	   reader.injector = injector
        	}
        	model = reader.invoke
    	}
    	model
    }

    def readSettingsFromModel() {
    	val model = getModel
    	val app = model.contents.head as Application
    	settings.appName = app.name
		settings.appVersion = app.version
    	return
    }
}
