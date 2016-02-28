package org.zikula.modulestudio.generator.application

import java.io.File
import java.io.IOException
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.mwe.utils.FileCopy
import org.zikula.modulestudio.generator.workflow.components.ModelFileCopier

/**
 * Workflow post processing for copying the admin image (zclassic) and
 * exporting the report files (reporting).
 */
class WorkflowPostProcess {
    WorkflowSettings settings

    new(WorkflowSettings settings) {
        this.settings = settings
    }

    /**
     * Executes the workflow.
     */
    def run() {
        copyModelFiles
        copyAdminImage
    }

    /**
     * Copies the model files into the output folder.
     */
    def private copyModelFiles() {
        val srcPath = settings.modelPath.replaceFirst('file:', '') //$NON-NLS-1$ //$NON-NLS-2$
        val modelFileName = new File(srcPath).name
        val copier = new ModelFileCopier => [
            sourceModelFile = srcPath
            targetModelFile = settings.modelDestinationPath + modelFileName
            sourceModelFileEnriched = srcPath.replace('.mostapp', '_enriched.mostapp') //$NON-NLS-1$ //$NON-NLS-2$
            targetModelFileEnriched = settings.modelDestinationPath + modelFileName.replace('.mostapp', '_enriched.mostapp') //$NON-NLS-1$ //$NON-NLS-2$
            //sourceDiagramFile = srcPath.replace('.mostapp', '.mostdiagram') //$NON-NLS-1$ //$NON-NLS-2$
            //targetDiagramFile = settings.modelDestinationPath + modelFileName.replace('.mostapp', '.mostdiagram') //$NON-NLS-1$ //$NON-NLS-2$
        ]
        copier.invoke
    }

    /**
     * Copies the admin image for zclassic cartridge.
     */
    def private copyAdminImage() {
        val fileCopy = new FileCopy
        val bundle = Platform.getBundle(ModuleStudioGeneratorActivator.PLUGIN_ID)
        var resources = FileLocator.findEntries(bundle, new Path('/src/resources/images/MOST_48.png')) //$NON-NLS-1$
        val resourcesExported = FileLocator.findEntries(bundle, new Path('/resources/images/MOST_48.png')) //$NON-NLS-1$
        if (resources.empty) {
            resources = resourcesExported
        }
        if (!resources.empty) {
            try {
                val url = resources.head
                val fileUrl = FileLocator.toFileURL(url)
                val file = new File(fileUrl.getPath)
                fileCopy.sourceFile = file.absolutePath

                val targetBasePath = settings.outputPath + File.separator + 'zclassic' + File.separator + settings.appName.toFirstUpper + File.separator //$NON-NLS-1$
                var imageFolder = 'Resources' + File.separator + 'public' + File.separator + 'images' //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
                var targetFolder = new File(targetBasePath + imageFolder)
                if (!targetFolder.exists) {
                    // BC support for 1.3.x
                    imageFolder = 'src' + File.separator + 'modules' + File.separator + settings.appName.toFirstUpper + File.separator + 'images' //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
                    targetFolder = new File(targetBasePath + imageFolder)
                }
                if (targetFolder.exists) {
                    fileCopy.targetFile = targetBasePath + imageFolder + File.separator + 'admin.png' //$NON-NLS-1$
                    fileCopy.invoke(null)
                }
            } catch (IOException e) {
                ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.message, e)
            }
        }
    }
}
