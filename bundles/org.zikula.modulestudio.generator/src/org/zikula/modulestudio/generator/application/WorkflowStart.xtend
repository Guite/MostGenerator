package org.zikula.modulestudio.generator.application

import com.google.inject.Injector
import de.guite.modulestudio.metamodel.Application
import java.io.File
import java.io.IOException
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.Diagnostician
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.xtext.util.EmfFormatter
import org.eclipse.xtext.validation.FeatureBasedDiagnostic
import org.zikula.modulestudio.generator.cartridges.MostGenerator
import org.zikula.modulestudio.generator.cartridges.MostGeneratorSetup
import org.zikula.modulestudio.generator.exceptions.ExceptionBase
import org.zikula.modulestudio.generator.exceptions.M2TFailedGeneratorResourceNotFound
import org.zikula.modulestudio.generator.exceptions.M2TUnknownException
import org.zikula.modulestudio.generator.workflow.components.ModelReader

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
    String currentCartridge = ''

    public WorkflowSettings settings = new WorkflowSettings

    public WorkflowPreProcess preProcess = new WorkflowPreProcess

    /**
     * Reference to the model's {@link Resource} object.
     */
    Resource model = null

    /**
     * The Guice injector instance which may be provided
     * if the generator is executed inside MOST.
     */
    @Accessors
    Injector injector = null

    /**
     * Validates the model.
     */
    def validate() {
        val progressMonitor = settings.progressMonitor
        progressMonitor.beginTask('Validating "' + settings.appName + ' ' + settings.appVersion + '" ...', -1)
        
        var diag = Diagnostician.INSTANCE.validate(getModel.contents.head)
        
        switch diag.getSeverity {
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
     * Executes the workflow, preProcess.run() has already been called.
     */
    def run() throws ExceptionBase {
        performM2T
        new WorkflowPostProcess(settings).run
    }

    /**
     * Workflow facade executing the actual model-to-text workflows.
     */
    def private performM2T() throws ExceptionBase {
        var success = false

        try {
            val progressMonitor = settings.progressMonitor
            progressMonitor.beginTask('Generating "' + settings.appVendor + File.separator + settings.appName + 'Bundle ' + settings.appVersion + '" ...', -1)

            for (singleCartridge : #['symfony']) { //$NON-NLS-1$
                // The generator cartridge to execute
                currentCartridge = singleCartridge.toString

                val generator = new MostGenerator
                generator.setCartridge(currentCartridge)
                generator.setMonitor(settings.progressMonitor)

                val fileSystemAccess = getConfiguredFileSystemAccess

                generator.doGenerate(getModel, fileSystemAccess)
            }
            success = true
        } catch (IOException e) {
            throw new M2TFailedGeneratorResourceNotFound(e)
        } catch (Exception e) {
            e.printStackTrace
            throw new M2TUnknownException(e)
        } finally {
        }

        success
    }

    def protected getConfiguredFileSystemAccess() {
        val setup = new MostGeneratorSetup
        val Injector injector = setup.createInjectorAndDoEMFRegistration

        val fileSystemAccess = injector.getInstance(JavaIoFileSystemAccess)

        fileSystemAccess.setOutputPath('DEFAULT_OUTPUT', settings.getPathToBundleRoot)
        if (fileSystemAccess instanceof MostFileSystemAccess) {
            fileSystemAccess.app = getModel.contents.head as Application
        }

        fileSystemAccess
    }

    def private getModel() {
        // do not read in the model again after validation did it already
        if (null === model) {
            val reader = new ModelReader
            reader.uri = settings.modelPath
            if (null !== injector) {
               reader.injector = injector
            }
            model = reader.invoke
        }
        model
    }

    def readSettingsFromModel() {
        val model = getModel
        val app = model.contents.head as Application
        settings.appName = app.name?.formatForCodeCapital ?: 'Bundle' //$NON-NLS-1$
        settings.appVendor = app.vendor?.formatForCodeCapital ?: 'Vendor' //$NON-NLS-1$
        settings.appVersion = if (null !== app.version) app.version else '1.0.0' //$NON-NLS-1$

        // compute destination path for model files
        //modelDestinationPath = File.separator + 'symfony' + File.separator + settings.appName + File.separator
        var modelDestinationPath = settings.getPathToBundleRoot
        modelDestinationPath += 'docs' + File.separator + 'model' + File.separator //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        settings.modelDestinationPath = modelDestinationPath

        return
    }

    /**
     * Formats a string for usage in generated source code starting with capital.
     *
     * @param s given input string
     * @return String formatted for source code usage.
     */
    def private formatForCodeCapital(String s) {
        s.replace('Ä', 'Ae').replace('ä', 'ae').replace('Ö', 'Oe')
         .replace('ö', 'oe').replace('Ü', 'Ue').replace('ü', 'ue')
         .replace('ß', 'ss').replaceAll('[\\W]', '').toFirstUpper
    }
}
