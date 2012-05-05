package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

public class Logger implements IWorkflowComponent {
    private String message = "Hello World!";

    public void setMessage(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    @Override
    public void invoke(IWorkflowContext ctx) {
        System.out.println(getMessage());
    }

    @Override
    public void preInvoke() {
    }

    @Override
    public void postInvoke() {
    }
}
