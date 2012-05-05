package org.zikula.modulestudio.generator.application

import de.guite.modulestudio.metamodel.modulestudio.Application
import java.io.File
import java.io.IOException
import java.util.HashMap
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.mwe2.language.Mwe2StandaloneSetup
import org.eclipse.emf.mwe2.launch.runtime.Mwe2Runner

class ModuleStudioGenerator {

    /**
     * The workflow file being processed within generation.
     */
    String workflowFile = ''

    /**
     * The cartridge selected by the user.
     */
    String cartridgeName = ''

    /**
     * The output path where generated files will be created in.
     */
    String outputPath = ''

    /**
     * Provides required workflow properties, overrides properties defined
     * in the workflow.
     */
    HashMap<String, String> properties = null

    /**
     * Progress monitor for the ui.
     */
    IProgressMonitor progressMonitor = null

    /**
     * Default constructor.
     */
    new(Application application, IProgressMonitor monitor) {
        properties = new HashMap<String, String>();

        // obsolete start
        // name of the model / module
        //addProperty('modelName', application.name)

        // input model file
        // addProperty('modelFile', application.modelPath)
        // obsolete end

        /**
         * IResource resource = givenEditorResource...
         * // set the work folder
         * properties.put('basedir', getProject.getLocation.toOSString)
         * // access current resource
         * properties.put('model', resource.getLocation.toOSString)
         */


        val modelPath = application.modelPath
        val modelPathOnly = modelPath.substring(0, modelPath.lastIndexOf(File::separator))
        val modelFile = modelPath.replace(modelPathOnly, '').replace('.mostapp', '').replaceFirst('/', '')

        // The model to be processed (file name without extension)
        addProperty('modelName', modelFile)
        // The path where to find the model, without trailing slash
        addProperty('modelPath', modelPathOnly)
        // The generator cartridge to execute (zclassic, zoo, reporting)
        addProperty('cartridgeName', cartridgeName)
        // whether to validate the model before processing
        addProperty('doValidation', 'true')
        // whether to copy the models into the target folder
        addProperty('doModelCopy', 'true')

        progressMonitor = monitor
        progressMonitor.beginTask('Generating "' + application.name + ' ' + application.version + '" ...', -1)
    }

    /**
     * Starts the default workflow for a given output path.
     * 
     * @param output
     *            path
     * @param cartridge
     *            name
     * @return whether generation was successful
     * @throws CoreException
     * @throws IOException
     */
    def runWorkflow(String outputPath, String cartridgeName)
            throws CoreException, IOException {
        runWorkflow(outputPath, cartridgeName, getDefaultWorkflowFile)
    }

    /**
     * Starts a given workflow for a given output path.
     * 
     * @param output
     *            path
     * @param cartridge
     *            name
     * @param custom
     *            workflow file
     * @return whether generation was successful
     * @throws CoreException
     * @throws IOException
     */
    def runWorkflow(String outputPath, String cartridgeName,
            String wfFile) throws CoreException, IOException {
        setWorkflowFile(wfFile)
        setCartridgeName(cartridgeName)
        setOutputPath(outputPath)
        runWorkflowInternal
    }

    /**
     * Processes the internal workflow execution.
     * 
     * @return whether generation was successful
     * @throws CoreException
     * @throws IOException
     */
    def private runWorkflowInternal() throws CoreException, IOException {
        // The generator cartridge to execute (zclassic, zoo, reporting)
        addProperty('cartridgeName', cartridgeName)

        // Destination folder
        addProperty('targetDir', getOutputPath)

        // save old ClassLoader
        //val before = Thread::currentThread().getContextClassLoader
        var success = false
        /**
         * IResource resource = givenEditorResource...
         * // set the work folder
         * properties.put('basedir', getProject.getLocation.toOSString)
         * // access current resource
         * properties.put('model', resource.getLocation.toOSString)
         */

        try {
            //val resourceLoader = new ModuleStudioResourceLoader()
            // set oaw's classloader to the current class-loader
            //ResourceLoaderFactory::setCurrentThreadResourceLoader(resourceLoader)

            // instantiate MWE2 workflow runner
			val injector = new Mwe2StandaloneSetup().createInjectorAndDoEMFRegistration()
			val mweRunner = injector.getInstance(typeof(Mwe2Runner))
            //val mweRunner = new Mwe2Runner()

            // start it
            mweRunner.run(getWorkflowFile, getProperties)

            success = true
        } finally {
            //ResourceLoaderFactory::setCurrentThreadResourceLoader(null)

            // restore old ClassLoader
            //Thread::currentThread.setContextClassLoader(before)
        }

        success
    }

    /**
     * Catch issues during generation for error reporting. /
     * private void prepareLogger(final IResource resource) {
     *     Logger l = Logger::getLogger(org.eclipse.workflow.WorkflowRunner);
     *     /* TODO Mwe2Runner
     * / // create a handler which will be added to the java.util.logging Logger class used during the workflow
     *     Handler h = new Handler() {
     * 
     * @Override public void close() throws SecurityException { }
     * @Override public void publish(LogRecord record) {
     *     if (record.getLevel == Level::SEVERE) {
     *         addMarker((IFile) resource, record.getMessage, 1, IMarker::SEVERITY_ERROR);
     *     } else if (record.getLevel == Level::WARNING) {
     *         addMarker((IFile) resource, record.getMessage, 1, IMarker::SEVERITY_WARNING);
     *     }
     * }
     * @Override public void flush { } }; l.addHandler(h); }
     */
    /**
     * 
     * @return returns the path to resources in other plugins / private String
     *     getPluginResourcePath(String pluginid, String fileName) throws IOException {
     *         // simple solution only for images:
     *         Activator.findImageDescriptor
     * 
     * 
     *         // get bundle for given plugin
     *         val bundle = Platform::getBundle(pluginid)
     *         val path = new Path(fileName)
     * 
     *         // returns something like
     *         "bundleentry://bundle_number/path_to_your_file"
     *         val url = FileLocator::find(bundle, path, Collections::EMPTY_MAP)
     * 
     *         // if one wants to read a file physically:
     *         // val fileUrl = FileLocator::toFileURL(url)
     *         // val file = new File(fileUrl.getPath)
     * 
     *         val result = new Path(FileLocator::resolve(url).getFile).toFile.toString
     *         result
     *     }
     */

    /**
     * @return the default workflow file
     */
    def private getDefaultWorkflowFile() {
        'msWorkflow.mwe2'
    }

    /**
     * @return the workflow file
     */
    def getWorkflowFile() {
        'src/org/zikula/modulestudio/generator/workflow/' + workflowFile
    }

    /**
     * @param workflowFile
     *            the workflowFile to set
     */
    def private setWorkflowFile(String workflowFile) {
        this.workflowFile = workflowFile
    }

    /**
     * @param cartridgeName
     *            the cartridgeName to set
     */
    def private setCartridgeName(String cartridgeName) {
        this.cartridgeName = cartridgeName
    }

    /**
     * @return the outputPath
     */
    def getOutputPath() {
        outputPath
    }

    /**
     * @param outputPath
     *            the outputPath to set
     */
    def private setOutputPath(String outputPath) {
        this.outputPath = outputPath
    }

    /**
     * @return the properties
     */
    def getProperties() {
        properties
    }

    /**
     * Adds a property to the workflow properties map.
     * 
     * @param name
     * @param value
     */
    def addProperty(String name, String value) {
        if (properties.containsKey(name))
            properties.remove(name)

        properties.put(name, value)
    }
}
