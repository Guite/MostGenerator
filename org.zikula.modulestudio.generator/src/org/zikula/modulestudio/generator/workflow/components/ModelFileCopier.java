package org.zikula.modulestudio.generator.workflow.components;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

/**
 * Workflow component class for copying model files into the output folder.
 */
public class ModelFileCopier implements IWorkflowComponent {

    /**
     * Whether copying should be executed or not.
     */
    private Boolean enabled = true;

    /**
     * Path to the source application model file.
     */
    private String sourceModelFile = ""; //$NON-NLS-1$

    /**
     * Path to the enriched source application model file.
     */
    private String sourceModelFileEnriched = ""; //$NON-NLS-1$

    /**
     * Path to the source diagram model file.
     */
    private String sourceDiagramFile = ""; //$NON-NLS-1$

    /**
     * Path to the target application model file.
     */
    private String targetModelFile = ""; //$NON-NLS-1$

    /**
     * Path to the enriched target application model file.
     */
    private String targetModelFileEnriched = ""; //$NON-NLS-1$

    /**
     * Path to the target diagram model file.
     */
    private String targetDiagramFile = ""; //$NON-NLS-1$

    /**
     * Invokes the workflow component from the outside.
     */
    public void invoke() {
        invokeInternal();
    }

    /**
     * Invokes the workflow component from a workflow.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    @Override
    public void invoke(IWorkflowContext ctx) {
        invokeInternal();
    }

    /**
     * Performs the actual process.
     */
    protected void invokeInternal() {
        if (!this.isEnabled()) {
            System.out.println("Skipping model file copier.");
            return;
        }
        System.out.println("Running model file copier.");

        copy(getSourceModelFile(), getTargetModelFile());
        copy(getSourceModelFileEnriched(), getTargetModelFileEnriched());
        copy(getSourceDiagramFile(), getTargetDiagramFile());
    }

    /**
     * Copies one certain file to a given target file.
     * 
     * @param sourceFile
     *            The source file path.
     * @param targetFile
     *            The target file path.
     */
    protected void copy(String sourceFile, String targetFile) {
        if (sourceFile.isEmpty() || targetFile.isEmpty()) {
            return;
        }

        try {
            final File source = new File(sourceFile);
            final File target = new File(targetFile);

            if (!source.exists()) {
                return;
            }
            if (!target.exists()) {
                if (!target.getParentFile().exists()
                        && !target.getParentFile().mkdirs()) {
                    return;
                }
                target.createNewFile();
            }

            FileChannel sourceChannel = null;
            FileChannel destinationChannel = null;
            try {
                sourceChannel = new FileInputStream(source).getChannel();
                destinationChannel = new FileOutputStream(target).getChannel();
                destinationChannel.transferFrom(sourceChannel, 0,
                        sourceChannel.size());
                sourceChannel.close();
                destinationChannel.close();
            } finally {
                if (sourceChannel != null) {
                    sourceChannel.close();
                }
                if (destinationChannel != null) {
                    destinationChannel.close();
                }
            }
        } catch (final IOException x) {
            // TODO
        }
    }

    /**
     * Performs actions before the invocation.
     */
    @Override
    public void preInvoke() {
        // Nothing to do here yet
    }

    /**
     * Performs actions after the invocation.
     */
    @Override
    public void postInvoke() {
        // Nothing to do here yet
    }

    /**
     * Returns the enabled flag.
     * 
     * @return The enabled flag.
     */
    public Boolean isEnabled() {
        return this.enabled;
    }

    /**
     * Sets the enabled flag.
     * 
     * @param enabled
     *            The enabled flag.
     */
    public void setEnabled(String enabled) {
        this.enabled = Boolean.valueOf(enabled);
    }

    /**
     * @return sourceModelFile
     */
    public String getSourceModelFile() {
        return this.sourceModelFile;
    }

    /**
     * @param sourceModelFile
     *            the source model file
     */
    public void setSourceModelFile(String sourceModelFile) {
        this.sourceModelFile = sourceModelFile;
    }

    /**
     * @return sourceModelFileEnriched
     */
    public String getSourceModelFileEnriched() {
        return this.sourceModelFileEnriched;
    }

    /**
     * @param sourceModelFileEnriched
     *            the source model file enriched
     */
    public void setSourceModelFileEnriched(String sourceModelFileEnriched) {
        this.sourceModelFileEnriched = sourceModelFileEnriched;
    }

    /**
     * @return sourceDiagramFile
     */
    public String getSourceDiagramFile() {
        return this.sourceDiagramFile;
    }

    /**
     * @param sourceDiagramFile
     *            the source diagram file
     */
    public void setSourceDiagramFile(String sourceDiagramFile) {
        this.sourceDiagramFile = sourceDiagramFile;
    }

    /**
     * @return targetModelFile
     */
    public String getTargetModelFile() {
        return this.targetModelFile;
    }

    /**
     * @param targetModelFile
     *            the target model file
     */
    public void setTargetModelFile(String targetModelFile) {
        this.targetModelFile = targetModelFile;
    }

    /**
     * @return targetModelFileEnriched
     */
    public String getTargetModelFileEnriched() {
        return this.targetModelFileEnriched;
    }

    /**
     * @param targetModelFileEnriched
     *            the target model file enriched
     */
    public void setTargetModelFileEnriched(String targetModelFileEnriched) {
        this.targetModelFileEnriched = targetModelFileEnriched;
    }

    /**
     * @return targetDiagramFile
     */
    public String getTargetDiagramFile() {
        return this.targetDiagramFile;
    }

    /**
     * @param targetDiagramFile
     *            the target diagram file
     */
    public void setTargetDiagramFile(String targetDiagramFile) {
        this.targetDiagramFile = targetDiagramFile;
    }
}
