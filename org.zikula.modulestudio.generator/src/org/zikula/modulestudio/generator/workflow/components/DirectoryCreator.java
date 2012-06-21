package org.zikula.modulestudio.generator.workflow.components;

import java.io.File;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

/**
 * Workflow component class for cleaning a certain directory.
 */
public class DirectoryCreator implements IWorkflowComponent {

    /**
     * The treated directory.
     */
    private String directory = ""; //$NON-NLS-1$

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    @Override
    public void invoke(IWorkflowContext ctx) {
        if (!getDirectory().isEmpty()) {
            final File dirHandle = new File(getDirectory());
            final boolean result = dirHandle.mkdirs();
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
     * Returns the directory.
     * 
     * @return The directory string.
     */
    public String getDirectory() {
        return this.directory;
    }

    /**
     * Sets the directory.
     * 
     * @param dir
     *            The directory string.
     */
    public void setDirectory(String dir) {
        this.directory = dir;
    }
}
