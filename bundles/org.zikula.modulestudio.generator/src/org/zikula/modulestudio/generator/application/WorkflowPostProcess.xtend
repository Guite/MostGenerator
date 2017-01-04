package org.zikula.modulestudio.generator.application

import java.io.File
import java.io.IOException
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IStatus
import org.eclipse.emf.mwe.utils.FileCopy
import org.zikula.modulestudio.generator.workflow.components.ModelFileCopier

/**
 * Workflow post processing for copying model files and creating custom images.
 */
class WorkflowPostProcess {
    /**
     * The workflow settings.
     */
    WorkflowSettings settings

    /**
     * Constructor.
     *
     * @param settings The workflow settings
     */
    new(WorkflowSettings settings) {
        this.settings = settings
    }

    /**
     * Executes the workflow.
     */
    def run() {
        copyModelFiles
        val imageCreator = new ImageCreator
        try {
            imageCreator.generate(settings)
        } catch (Exception e) {
            ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.message, e)
            // if custom images could not be created copy the default one
            copyAdminImage
        }
    }

    /**
     * Copies the model files into the output folder.
     */
    def private copyModelFiles() {
        if (null === settings.modelDestinationPath) {
            return
        }
        val srcPath = settings.modelPath.replaceFirst('file:', '') //$NON-NLS-1$ //$NON-NLS-2$
        val modelFileName = new File(srcPath).name
        val copier = new ModelFileCopier => [
            sourceModelFile = srcPath
            targetModelFile = settings.modelDestinationPath + modelFileName
            sourceModelFileEnriched = srcPath.replace('.mostapp', '_enriched.mostapp') //$NON-NLS-1$ //$NON-NLS-2$
            targetModelFileEnriched = settings.modelDestinationPath + modelFileName.replace('.mostapp', '_enriched.mostapp') //$NON-NLS-1$ //$NON-NLS-2$
        ]
        copier.invoke
    }

    /**
     * Copies the admin image for the generated application.
     */
    def private copyAdminImage() {
        val url = settings.adminImageUrl
        if (null === url) {
            return
        }

        try {
            val targetFolder = settings.getPathToModuleImageAssets
            if (targetFolder.exists) {
                val sourceImageUrl = FileLocator.toFileURL(url)
                val sourceImageFile = new File(sourceImageUrl.getPath)

                val fileCopy = new FileCopy
                fileCopy.sourceFile = sourceImageFile.absolutePath
                fileCopy.targetFile = targetFolder + File.separator + 'admin.png' //$NON-NLS-1$
                fileCopy.invoke(null)
            }
        } catch (IOException e) {
            ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.message, e)
        }
    }
}
