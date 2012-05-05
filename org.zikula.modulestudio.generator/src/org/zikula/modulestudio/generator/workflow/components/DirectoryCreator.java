package org.zikula.modulestudio.generator.workflow.components;

import java.io.File;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

public class DirectoryCreator implements IWorkflowComponent {
    private String directory = "";

    public void setDirectory(String directory) {
        this.directory = directory;
    }

    public String getDirectory() {
        return directory;
    }

    @Override
    public void invoke(IWorkflowContext ctx) {
        if (!directory.isEmpty()) {
            final File dirHandle = new File(directory);
            final boolean result = dirHandle.mkdirs();
        }
    }

    @Override
    public void preInvoke() {
    }

    @Override
    public void postInvoke() {
    }
}
