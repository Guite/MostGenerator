package org.zikula.modulestudio.generator.application

import java.io.File
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * This class collects required workflow properties.
 */
class WorkflowSettings {

    /**
     * The output path.
     */
    @Accessors(PUBLIC_GETTER)
    String outputPath = null

    /**
     * File handle for output directory.
     */
    @Accessors(PUBLIC_GETTER)
    File outputDir = null

    /**
     * The model path.
     */
    @Accessors
    String modelPath = null

    /**
     * The destination path for copying the model.
     */
    @Accessors
    String modelDestinationPath = null

    /**
     * Name of the vendor of the application instance described by the model.
     */
    @Accessors
    String appVendor = ''

    /**
     * Name of the application instance described by the model.
     */
    @Accessors
    String appName = ''

    /**
     * Version of the application instance described by the model.
     */
    @Accessors
    String appVersion = ''

    /**
     * The progress monitor.
     */
    @Accessors
    IProgressMonitor progressMonitor = null

    /**
     * Sets the output path.
     * 
     * @param path
     *            The given path string.
     */
    def setOutputPath(String path) {
        outputPath = path
        outputDir = new File(path)
    }
}
