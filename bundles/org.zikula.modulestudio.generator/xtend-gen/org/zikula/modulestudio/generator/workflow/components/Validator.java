package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.Diagnostician;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.workflow.components.WorkflowComponentWithSlot;

/**
 * Workflow component for running validation on input model.
 */
@SuppressWarnings("all")
public class Validator extends WorkflowComponentWithSlot {
  /**
   * Whether validation should be executed or not.
   */
  private Boolean enabled = Boolean.valueOf(true);
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext} instance.
   */
  @Override
  public void invoke(final IWorkflowContext ctx) {
    if ((!(this.enabled).booleanValue())) {
      InputOutput.<String>println("Skipping validation.");
      return;
    }
    InputOutput.<String>println("Running validation.");
    Object _get = ctx.get(this.getSlot());
    final Resource resource = ((Resource) _get);
    final EObject theModel = IterableExtensions.<EObject>head(resource.getContents());
    final Diagnostic diagnostic = Diagnostician.INSTANCE.validate(theModel);
    int _severity = diagnostic.getSeverity();
    boolean _tripleEquals = (Diagnostic.ERROR == _severity);
    if (_tripleEquals) {
      InputOutput.<String>println(("Model has errors: " + diagnostic));
      throw new IllegalStateException(("Aborting generation as the model has errors: " + diagnostic));
    } else {
      int _severity_1 = diagnostic.getSeverity();
      boolean _tripleEquals_1 = (Diagnostic.WARNING == _severity_1);
      if (_tripleEquals_1) {
        InputOutput.<String>println(("Model has warnings: " + diagnostic));
      }
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
  public Boolean setEnabled(final String enabled) {
    return this.enabled = Boolean.valueOf(enabled);
  }
}
