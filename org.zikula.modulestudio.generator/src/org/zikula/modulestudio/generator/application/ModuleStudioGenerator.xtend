package org.zikula.modulestudio.generator.application

import de.guite.modulestudio.metamodel.modulestudio.Application
import java.io.File
import java.io.IOException
import java.util.HashMap
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.mwe2.language.Mwe2StandaloneSetup
import org.eclipse.emf.mwe2.launch.runtime.Mwe2Runner

/**
 * The outer generator class running the MWE2 workflow.
 */
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
     *
     * @param application The given {@link Application} instance
     * @param monitor The {@link IProgressMonitor} instance
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
     * @param outputPath The given output path.
     * @param cartridgeName Name of currently processed cartridge.
     * @return Boolean Whether the generation was successful or not.
     * @throws CoreException In case something goes wrong.
     * @throws IOException In case input or output errors occur.
     */
    def runWorkflow(String outputPath, String cartridgeName)
            throws CoreException, IOException {
        runWorkflow(outputPath, cartridgeName, getDefaultWorkflowFile)
    }

    /**
     * Starts a given workflow for a given output path.
     *
     * @param outputPath The given output path.
     * @param cartridgeName Name of currently processed cartridge.
     * @param wfFile Name of custom workflow file.
     * @return Boolean Whether the generation was successful or not.
     * @throws CoreException In case something goes wrong.
     * @throws IOException In case input or output errors occur.
     */
    def runWorkflow(String outputPath, String cartridgeName,
            String wfFile) throws CoreException, IOException {
        setWorkflowFile(wfFile)
        setCartridgeName(cartridgeName)
        setOutputPath(outputPath)
        runWorkflowInternal
    }

    /**
     * Executes the workflow internally.
     *
     * @return Boolean Whether the generation was successful or not.
     * @throws CoreException In case something goes wrong.
     * @throws IOException In case input or output errors occur.
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
     * Returns the default workflow file.
     *
     * @return String the default workflow file.
     */
    def private getDefaultWorkflowFile() {
        'msWorkflow.mwe2'
    }

    /**
     * Returns the workflow file.
     *
     * @return String the workflow file.
     */
    def getWorkflowFile() {
        'src/org/zikula/modulestudio/generator/workflow/' + workflowFile
    }

    /**
     * Sets the workflow file.
     *
     * @param wfFile The workflow file to set.
     * @return String The new workflow file.
     */
    def private setWorkflowFile(String wfFile) {
        this.workflowFile = wfFile
    }

    /**
     * Sets the cartridge name.
     *
     * @param cartridge The cartridge name to set.
     * @return String The new cartridge name.
     */
    def private setCartridgeName(String cartridge) {
        this.cartridgeName = cartridge
    }

    /**
     * Returns the output path.
     *
     * @return String the output path.
     */
    def getOutputPath() {
        outputPath
    }

    /**
     * Sets the output path.
     *
     * @param path The output path to set.
     * @return String The new output path.
     */
    def private setOutputPath(String path) {
        this.outputPath = path
    }

    /**
     * Returns the list of workflow properties.
     *
     * @return the property list.
     */
    def getProperties() {
        properties
    }

    /**
     * Adds a property to the workflow properties map.
     * 
     * @param name Property name
     * @param value Property value
     */
    def void addProperty(String name, String value) {
        if (properties.containsKey(name))
            properties.remove(name)

        properties.put(name, value)
    }
}
