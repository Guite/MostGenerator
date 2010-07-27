package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.mwe.core.resources.ResourceLoaderFactory;
import org.eclipse.emf.mwe2.launch.runtime.Mwe2Runner;
import org.zikula.modulestudio.generator.beautifier.GeneratorFileUtil;
import org.zikula.modulestudio.generator.beautifier.formatter.FormatterFacade;

import de.guite.modulestudio.metamodel.modulestudio.Application;

public class ModuleStudioGeneratorMwe2 {

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
     * default constructor
     */
    public ModuleStudioGeneratorMwe2(Application application,
            IProgressMonitor monitor) {
        properties = new HashMap<String, String>();

        // obsolete start
        final String modelPath = application.getModelPath();
        // input model file
        addProperty("modelFile", modelPath);

        // set output model file for M2M transformation
        addProperty("enrichedModelFile",
                modelPath.replace(".mostapp", "_Enriched.mostapp"));
        // obsolete end

        // TODO: retrieve model which is already in memory
        // strips out table columns
        // slotContents.put("model", application);

        monitor.beginTask("Generating \"" + application.getName() + " "
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
        // The model to be processed (file name without extension)
        addProperty("modelName", "TODO");
        // The path where to find the model, without trailing slash
        addProperty("modelPath", "TODO");
        // The generator cartridge to execute
        // (zclassic, zoo, documentation, reporting)
        addProperty("cartridgeName", cartridgeName);
        // whether to output slot dumps
        addProperty("doSlotDumps", "true");
        // whether to validate the model before processing
        addProperty("doValidation", "true");
        // whether to copy the models into the target folder
        addProperty("doModelCopy", "true");
        // whether to use the profiler
        addProperty("doProfiling", "true");

        // Destination folder
        addProperty("targetDir", getOutputPath());

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
            // set oaw's classloader to the current class-loader
            ResourceLoaderFactory
                    .setCurrentThreadResourceLoader(resourceLoader);

            // instantiate MWE2 workflow launcher
            // Mwe2Launcher launcher = new Mwe2Launcher();

            // instantiate MWE2 workflow runner
            final Mwe2Runner runner = new Mwe2Runner();

            // start it
            // launcher.run(getWorkflowFile(), getProperties());
            runner.run(getWorkflowFile(), getProperties());

            success = true;
        } finally {
            ResourceLoaderFactory.setCurrentThreadResourceLoader(null);

            // restore old ClassLoader
            Thread.currentThread().setContextClassLoader(before);
        }

        return success;
    }

    public void applyBeautifier() throws CoreException {
        // System.out.println("Tests started.");
        // root path
        final File dir = new File(getOutputPath());

        // retrieve files
        final Vector<File> fileList = new Vector<File>();
        GeneratorFileUtil.getRecursivePhpFiles(dir, fileList);

        // initialize formatter class
        final FormatterFacade beautifier = new FormatterFacade();
        // process files
        for (final File file : fileList) {
            beautifier.formatFile(file);
        }
        // System.out.println("Tests finished.");
    }

    /**
     * Catch issues during generation for error reporting. / private void
     * prepareLogger(final IResource resource) { Logger l =
     * Logger.getLogger(org.eclipse.workflow.WorkflowRunner); /* TODO Mwe2Runner
     * / // create a handler which will be added to the java.util.logging Logger
     * // class used during the workflow Handler h = new Handler() {
     * 
     * @Override public void close() throws SecurityException { }
     * @Override public void publish(LogRecord record) { if (record.getLevel()
     *           == Level.SEVERE) { addMarker((IFile) resource,
     *           record.getMessage(), 1, IMarker.SEVERITY_ERROR); } else if
     *           (record.getLevel() == Level.WARNING) { addMarker((IFile)
     *           resource, record.getMessage(), 1, IMarker.SEVERITY_WARNING); }
     *           }
     * @Override public void flush() { } }; l.addHandler(h); }
     */
    /**
     * 
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
        return "msWorkflow.mwe2";
    }

    /**
     * @return the workflow file
     */
    public String getWorkflowFile() {
        return "src/org/zikula/modulestudio/generator/workflow/" + workflowFile;
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
