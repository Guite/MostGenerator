package org.zikula.modulestudio.generator

import com.google.inject.Inject
import com.google.inject.Provider
import de.guite.modulestudio.MostDslStandaloneSetup
import java.io.File
import java.lang.reflect.InvocationTargetException
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.zikula.modulestudio.generator.application.WorkflowStart
import org.zikula.modulestudio.generator.exceptions.ExceptionBase
import org.zikula.modulestudio.generator.exceptions.M2TFailedGeneratorResourceNotFound
import org.zikula.modulestudio.generator.exceptions.M2TUnknownException

/**
 * Entry point for stand-alone generator.
 */
class Main
{
    def static main(String[] args) {
        if (args.empty) {
            System.err.println('Error: no model provided!')
            System.err.println
            System.err.println('Call this like:')
            System.err.println('    java -jar ModuleStudio-generator.jar MyModel.mostapp')
            System.err.println
            System.err.println('You can also define a custom output folder:')
            System.err.println('    java -jar ModuleStudio-generator.jar MyModel.mostapp MySubFolder')
            return
        }
        val injector = new MostDslStandaloneSetup().createInjectorAndDoEMFRegistration
        val main = injector.getInstance(Main)

        val modelUri = args.head
        var outputFolder = System.getProperty('user.dir') + File.separator
        outputFolder += (if (args.length > 1) args.get(1) else 'GeneratedModule') + File.separator

        val outputDirectory = new File(outputFolder)
        if (!outputDirectory.exists) {
            outputDirectory.mkdirs
        }

        main.runGenerator(modelUri, outputFolder)
    }

    @Inject Provider<ResourceSet> resourceSetProvider

    @Inject IResourceValidator validator

    //@Inject GeneratorDelegate generator

    //@Inject JavaIoFileSystemAccess fileAccess

    def protected runGenerator(String modelUri, String outputFolder) {
        // Load the resource
        val set = resourceSetProvider.get
        val resource = set.getResource(URI.createFileURI(modelUri), true)

        // Validate the resource
        val issues = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl)
        if (!issues.empty) {
            issues.forEach[
                System.err.println(it)
            ]
        }
        if (!issues.filter[severity == Severity.ERROR].empty) {
            System.err.println
            System.err.println('Aborting because the model has errors.')
            return
        }

        val workflow = new WorkflowStart
        workflow.settings.setOutputPath(outputFolder)
        workflow.settings.isStandalone = true

        // set important parameters
        workflow.settings.setModelPath(modelUri)
        workflow.readSettingsFromModel

        // create progress monitor
        workflow.settings.setProgressMonitor(new NullProgressMonitor)

        // start generator workflow
        try {
            workflow.run
            println('Code generation finished. The output is located in the "' + outputFolder + '" folder.')
        } catch (M2TFailedGeneratorResourceNotFound exception) {
            System.err.println('Error: Generator resource could not be found.')
            exception.printStackTrace
        } catch (M2TUnknownException exception) {
            System.err.println('Error: A M2T exception occurred during the workflow.')
            exception.printStackTrace
        } catch (ExceptionBase exception) {
            System.err.println('Error: A general exception occurred during the workflow.')
            exception.printStackTrace
        } catch (InvocationTargetException exception) {
            exception.printStackTrace
        } catch (InterruptedException exception) {
            exception.printStackTrace
        }
    }
}
