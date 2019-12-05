package org.zikula.modulestudio.generator.application

import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream
import org.eclipse.core.runtime.FileLocator
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
            //ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.message, e)
            println(e.message)
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
        val targetFolder = settings.getPathToModuleImageAssets
        if (!targetFolder.exists) {
            return
        }
        val targetFilePath = targetFolder + File.separator + 'admin.png' //$NON-NLS-1$

        if (!settings.isStandalone) {
            val url = settings.adminImageUrl
            if (null === url) {
                return
            }

            try {
                val sourceImageUrl = FileLocator.toFileURL(url)
                val sourceImageFile = new File(sourceImageUrl.getPath)

                val fileCopy = new FileCopy
                fileCopy.sourceFile = sourceImageFile.absolutePath
                fileCopy.targetFile = targetFilePath
                fileCopy.invoke(null)
            } catch (IOException exception) {
                //ModuleStudioGeneratorActivator.log(IStatus.ERROR, exception.message, exception)
                println(exception.message)
            }
        } else {
            val inputStream = this.class.getResourceAsStream(settings.getAdminImageInputPath)
            if (null === inputStream) {
                return
            }
            var OutputStream outputStream
            var int readBytes
            val buffer = newByteArrayOfSize(4096)
            try {
                outputStream = new FileOutputStream(new File(targetFilePath))
                while ((readBytes = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, readBytes) 
                }
                outputStream.close
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }
    }
}
