package org.zikula.modulestudio.generator.workflow.components

import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.nio.channels.FileChannel
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Workflow component class for copying model files into the output folder.
 */
class ModelFileCopier implements IWorkflowComponent {

    /**
     * Whether copying should be executed or not.
     */
    Boolean enabled = true

    /**
     * Path to the source application model file.
     */
    @Accessors
    String sourceModelFile = '' //$NON-NLS-1$

    /**
     * Path to the enriched source application model file.
     */
    @Accessors
    String sourceModelFileEnriched = '' //$NON-NLS-1$

    /**
     * Path to the source diagram model file.
     * /
    @Accessors
    String sourceDiagramFile = '' //$NON-NLS-1$*/

    /**
     * Path to the target application model file.
     */
    @Accessors
    String targetModelFile = '' //$NON-NLS-1$

    /**
     * Path to the enriched target application model file.
     */
    @Accessors
    String targetModelFileEnriched = '' //$NON-NLS-1$

    /**
     * Path to the target diagram model file.
     * /
    @Accessors
    String targetDiagramFile = '' //$NON-NLS-1$*/

    /**
     * Invokes the workflow component from the outside.
     */
    def void invoke() {
        invokeInternal
    }

    /**
     * Invokes the workflow component from a workflow.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    override invoke(IWorkflowContext ctx) {
        invokeInternal
    }

    /**
     * Performs the actual process.
     */
    def protected void invokeInternal() {
        if (!this.isEnabled) {
            println('Skipping model file copier.')
            return
        }
        println('Running model file copier.')

        copy(sourceModelFile, targetModelFile)
        //copy(sourceModelFileEnriched, targetModelFileEnriched)
        //copy(sourceDiagramFile, targetDiagramFile)
    }

    /**
     * Copies one certain file to a given target file.
     * 
     * @param sourceFile
     *            The source file path.
     * @param targetFile
     *            The target file path.
     */
    def protected void copy(String sourceFile, String targetFile) {
        if (sourceFile.empty || targetFile.empty) {
            return
        }

        try {
            val source = new File(sourceFile)
            val target = new File(targetFile)

            if (!source.exists) {
                return
            }
            if (!target.exists) {
                if (!target.parentFile.exists && !target.parentFile.mkdirs) {
                    return
                }
                if (!target.createNewFile) {
                    return
                }
            }

            var FileChannel sourceChannel = null
            var FileChannel destinationChannel = null
            try {
                val inputStream = new FileInputStream(source)
                val outputStream = new FileOutputStream(target)
                sourceChannel = inputStream.channel
                destinationChannel = outputStream.channel
                destinationChannel.transferFrom(sourceChannel, 0, sourceChannel.size)
                sourceChannel.close
                destinationChannel.close
                inputStream.close
                outputStream.close
            } finally {
                sourceChannel?.close
                destinationChannel?.close
            }
        } catch (IOException exception) {
            //ModuleStudioGeneratorActivator.log(IStatus.ERROR, exception.message, exception)
            println(exception.message)
        }
    }

    /**
     * Performs actions before the invocation.
     */
    override preInvoke() {
        // Nothing to do here yet
    }

    /**
     * Performs actions after the invocation.
     */
    override postInvoke() {
        // Nothing to do here yet
    }

    /**
     * Returns the enabled flag.
     * 
     * @return The enabled flag.
     */
    def isEnabled() {
        enabled
    }

    /**
     * Sets the enabled flag.
     * 
     * @param enabled
     *            The enabled flag.
     */
    def setEnabled(String enabled) {
        enabled = Boolean.valueOf(enabled)
    }
}
