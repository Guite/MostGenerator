package org.zikula.modulestudio.generator.application;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.mwe.core.WorkflowEngine;
import org.eclipse.emf.mwe.core.monitor.NullProgressMonitor;
import org.eclipse.emf.mwe.core.resources.ResourceLoaderFactory;

import de.guite.modulestudio.metamodel.modulestudio.Application;

public class ModuleStudioGenerator {

    /**
     * the workflow file being processed within generation
     */
    private String workflowFile = "";

    /**
     * the cartridge name used for selecting actual generator
     */
    private String cartridgeName = "";

    /**
     * the output path where generated files will be created
     */
    private String outputPath = "";

    /**
     * provide required workflow properties, overrides properties defined in the
     * workflow.
     */
    private Map<String, String> properties = null;

    /**
     * map with slot contents for injecting model from memory
     */
    private Map<String, Object> slotContents = null;

    /**
     * Progress monitor for the ui
     */
    private IProgressMonitor progressMonitor = null;

    /**
     * default constructor
     */
    public ModuleStudioGenerator(Application application,
            IProgressMonitor monitor) {
        properties = new HashMap<String, String>();

        // name of the model / module
        final String modelName = application.getName();
        addProperty("modelName", modelName);

        // obsolete start
        final String modelPath = application.getModelPath();
        // input model file
        addProperty("modelFile", modelPath);

        // set output model file for M2M transformation
        addProperty("enrichedModelFile",
                modelPath.replace(".mostapp", "_Enriched.mostapp"));
        // obsolete end

        slotContents = new HashMap<String, Object>();
        slotContents.put("progressMonitor", monitor);
        // TODO: retrieve model which is already in memory
        // strips out table columns
        // slotContents.put("model", application);

        progressMonitor = monitor;
        progressMonitor.beginTask("Generating \"" + application.getName() + " "
                + application.getVersion() + "\" ...", -1);
    }

    /**
     * starts the default workflow for a given output path
     * 
     * @param output
     *            path
     * @param cartridge
     *            name
     * @return whether generation was successful
     * @throws CoreException
     * @throws IOException
     */
    public boolean runWorkflow(String outputPath, String cartridgeName)
            throws CoreException, IOException {
        return runWorkflow(outputPath, cartridgeName, getDefaultWorkflowFile());
    }

    /**
     * starts a given workflow for a given output path
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
    public boolean runWorkflow(String outputPath, String cartridgeName,
            String wfFile) throws CoreException, IOException {
        setWorkflowFile(wfFile);
        setCartridgeName(cartridgeName);
        setOutputPath(outputPath);// + "/" + cartridgeName);
        return runWorkflowInternal();
    }

    /**
     * internal workflow execution
     * 
     * @return whether generation was successful
     * @throws CoreException
     * @throws IOException
     */
    private boolean runWorkflowInternal() throws CoreException, IOException {
        // cartridgeName
        addProperty("cartridgeName", cartridgeName);
        // directory for generated sources
        addProperty("srcGenPath", getOutputPath());

        // save old ClassLoader
        final ClassLoader before = Thread.currentThread()
                .getContextClassLoader();
        boolean success = false;
        /**
         * IResource resource = givenEditorResource... // set the work folder
         * properties.put("basedir", getProject().getLocation().toOSString());
         * // access current resource properties.put("model",
         * resource.getLocation().toOSString());
         */

        try {
            final ModuleStudioResourceLoader resourceLoader = new ModuleStudioResourceLoader();
            // set oaw's class loader to the current class-loader
            ResourceLoaderFactory
                    .setCurrentThreadResourceLoader(resourceLoader);

            // instantiate MWE workflow engine
            final WorkflowEngine wfEngine = new WorkflowEngine();

            // start it
            success = wfEngine.run(getWorkflowFile(),
                    new NullProgressMonitor(), getProperties(), slotContents);
        } finally {
            ResourceLoaderFactory.setCurrentThreadResourceLoader(null);

            // restore old ClassLoader
            Thread.currentThread().setContextClassLoader(before);
        }

        return success;
    }

    /**
     * @return returns the path to resources in other plugins / private String
     *         getPluginResourcePath(String pluginid, String fileName) throws
     *         IOException { // simple solution only for images:
     *         Activator.findImageDescriptor()
     * 
     * 
     *         // get bundle for given plugin Bundle bundle =
     *         Platform.getBundle(pluginid); Path path = new Path(fileName);
     * 
     *         // returns something like
     *         "bundleentry://bundle_number/path_to_your_file" URL url =
     *         FileLocator.find(bundle, path, Collections.EMPTY_MAP);
     * 
     *         // if one wants to read a file physically: // URL fileUrl =
     *         FileLocator.toFileURL(url); // File file = new
     *         File(fileUrl.getPath());
     * 
     *         String result = new
     *         Path(FileLocator.resolve(url).getFile()).toFile().toString();
     *         return result; }
     */

    /**
     * @return the default workflow file
     */
    private String getDefaultWorkflowFile() {
        return "msWorkflow.mwe";
    }

    /**
     * @return the workflow file
     */
    public String getWorkflowFile() {
        /**
         * FIXME: src/ is needed when starting from IDE only; TODO: change
         * build.properties accordingly
         */
        return /* "src/ */"workflow/" + workflowFile;
    }

    /**
     * @param workflowFile
     *            the workflowFile to set
     */
    private void setWorkflowFile(String workflowFile) {
        this.workflowFile = workflowFile;
    }

    /**
     * @param cartridgeName
     *            the cartridgeName to set
     */
    private void setCartridgeName(String cartridgeName) {
        this.cartridgeName = cartridgeName;
    }

    /**
     * @return the outputPath
     */
    public String getOutputPath() {
        return outputPath;
    }

    /**
     * @param outputPath
     *            the outputPath to set
     */
    private void setOutputPath(String outputPath) {
        this.outputPath = outputPath;
    }

    /**
     * @return the properties
     */
    public Map<String, String> getProperties() {
        return properties;
    }

    /**
     * adds a property to the workflow properties map
     * 
     * @param name
     * @param value
     */
    public void addProperty(String name, String value) {
        this.properties.put(name, value);
    }
}
