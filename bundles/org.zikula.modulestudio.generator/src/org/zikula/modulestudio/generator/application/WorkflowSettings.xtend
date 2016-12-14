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
        val bundle = Platform.getBundle(ModuleStudioGeneratorActivator.PLUGIN_ID)
        var resources = FileLocator.findEntries(bundle, new Path('/src/resources/images/MOST_48.png')) //$NON-NLS-1$
        val resourcesExported = FileLocator.findEntries(bundle, new Path('/resources/images/MOST_48.png')) //$NON-NLS-1$
        if (resources.empty) {
            resources = resourcesExported
        }
        if (resources.empty) {
            return null
        }

        resources.head
    }

    /**
     * Returns base path to the module's root folder.
     *
     * @return module base path
     */
    def getPathToModuleRoot() {
        outputPath + File.separator + 'zclassic' + File.separator + appName.toFirstUpper + File.separator //$NON-NLS-1$
    }

    /**
     * Returns path to the module's image assets folder.
     *
     * @return path to images folder
     */
    def getPathToModuleImageAssets() {
        val targetBasePath = getPathToModuleRoot
        var imagePath = 'Resources' + File.separator + 'public' + File.separator + 'images' //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        var targetFolder = new File(targetBasePath + imagePath)
        if (!targetFolder.exists) {
            // BC support for 1.3.x
            imagePath = 'src' + File.separator + 'modules' + File.separator + appName.toFirstUpper + File.separator + 'images' //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            targetFolder = new File(targetBasePath + imagePath)
        }

        targetFolder
    }

    /**
     * Returns pathes to image folders of Scribite plugins.
     *
     * @return list of pathes to images folders
     */
    def getPathesToScribiteImageAssets() {
        val targetFolders = newArrayList

        val targetBasePath = getPathToModuleRoot
        val scribiteFolder = File.separator + 'docs' + File.separator + 'scribite' + File.separator + 'plugins' + File.separator //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        var scribitePath = 'Resources' + scribiteFolder //$NON-NLS-1$
        var baseFolder = new File(targetBasePath + scribitePath)
        var fullAppName = appVendor.toFirstUpper + appName.toFirstUpper + 'Module' //$NON-NLS-1$
        if (!baseFolder.exists) {
            // BC support for 1.3.x
            scribitePath = 'src' + File.separator + 'modules' + File.separator + appName.toFirstUpper + scribiteFolder //$NON-NLS-1$ //$NON-NLS-2$
            baseFolder = new File(targetBasePath + scribitePath)
            fullAppName = appName.toFirstUpper
        }

        if (!baseFolder.exists) {
            // no Scribite plugins have been generated
            return targetFolders
        }

        var File imageFolder
        val supportedEditors = #['CKEditor', 'TinyMce'] //$NON-NLS-1$ //$NON-NLS-2$
        for (editor : supportedEditors) {
            imageFolder = new File(targetBasePath + scribitePath + editor + File.separator + 'vendor' + File.separator + editor.toLowerCase + File.separator + 'plugins/' + (if (editor == 'Xinha') fullAppName else appName.toLowerCase) + File.separator + 'images') //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
            if (imageFolder.exists) {
                targetFolders += imageFolder
            }
        }

        targetFolders
    }
}
