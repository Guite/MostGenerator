package org.zikula.modulestudio.generator.application

import java.io.File
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
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
     * Whether stand-alone execution (using jar file) is done or not.
     */
    @Accessors
    Boolean isStandalone = false

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

    /**
     * Returns url of default admin image.
     *
     * @return image url
     */
    def getAdminImageUrl() {
        val bundle = Platform.getBundle('org.zikula.modulestudio.generator') // $NON-NLS-1$
        var resources = FileLocator.findEntries(bundle, new Path('/src' + getAdminImageInputPath)) //$NON-NLS-1$
        val resourcesExported = FileLocator.findEntries(bundle, new Path(getAdminImageInputPath))
        if (resources.empty) {
            resources = resourcesExported
        }
        if (resources.empty) {
            return null
        }

        resources.head
    }

    /**
     * Returns path to input admin image.
     *
     * @return string
     */
    def getAdminImageInputPath() {
        '/resources/images/MOST_48.png' //$NON-NLS-1$
    }

    /**
     * Returns base path to the bundle's root folder.
     *
     * @return string Bundle base path
     */
    def getPathToBundleRoot() {
        outputPath + File.separator + appVendor.toFirstUpper + File.separator + appName.toFirstUpper + 'Bundle' + File.separator //$NON-NLS-1$
    }

    /**
     * Returns path to the module's image assets folder.
     *
     * @return path to images folder
     */
    def getPathToModuleImageAssets() {
        val targetBasePath = getPathToBundleRoot
        var imagePath = 'Resources' + File.separator + 'public' + File.separator + 'images' //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        var targetFolder = new File(targetBasePath + imagePath)

        targetFolder
    }
}
