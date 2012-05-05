package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

public class StopWatch implements IWorkflowComponent {
    private long start;
    private boolean shouldStop = false;

    @Override
    public void invoke(IWorkflowContext ctx) {
    }

    @Override
    public void preInvoke() {
        start = System.currentTimeMillis();
    }

    @Override
    public void postInvoke() {
        if (shouldStop) {
            final long elapsed = System.currentTimeMillis() - start;
            System.out.println("Time elapsed: " + elapsed + " ms");
        }
        shouldStop = true;
    }
}
