package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.Diagnostician;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

/**
 * Workflow component for running validation on input model.
 */
public class Validator extends WorkflowComponentWithSlot {

    /**
     * Whether validation should be executed or not.
     */
    private Boolean enabled = true;

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    @Override
    public void invoke(IWorkflowContext ctx) {
        if (!this.isEnabled()) {
            System.out.println("Skipping validation.");
            return;
        }
        System.out.println("Running validation.");

        final Resource resource = (Resource) ctx.get(getSlot());
        final EObject theModel = resource.getContents().get(0);
        final Diagnostic diagnostic = Diagnostician.INSTANCE.validate(theModel);
        switch (diagnostic.getSeverity()) {
            case Diagnostic.ERROR:
                System.err.println("Model has errors: " + diagnostic);
                throw new IllegalStateException("Abort the workflow");
            case Diagnostic.WARNING:
                System.out.println("Model has warnings: " + diagnostic);
                break;
            default:
                break;
        }
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
}
