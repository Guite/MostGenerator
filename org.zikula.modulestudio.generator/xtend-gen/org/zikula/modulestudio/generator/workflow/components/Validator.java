package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.EList;
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
   *            The given {@link IWorkflowContext} instance.
   */
  public void invoke(final IWorkflowContext ctx) {
    boolean _not = (!(this.enabled).booleanValue());
    if (_not) {
      InputOutput.<String>println("Skipping validation.");
      return;
    }
    InputOutput.<String>println("Running validation.");
    String _slot = this.getSlot();
    Object _get = ctx.get(_slot);
    final Resource resource = ((Resource) _get);
    EList<EObject> _contents = resource.getContents();
    final EObject theModel = IterableExtensions.<EObject>head(_contents);
    final Diagnostic diagnostic = Diagnostician.INSTANCE.validate(theModel);
    int _severity = diagnostic.getSeverity();
    boolean _equals = (_severity == Diagnostic.ERROR);
    if (_equals) {
      String _plus = ("Model has errors: " + diagnostic);
      System.err.println(_plus);
      IllegalStateException _illegalStateException = new IllegalStateException("Abort the workflow");
      throw _illegalStateException;
    } else {
      int _severity_1 = diagnostic.getSeverity();
      boolean _equals_1 = (_severity_1 == Diagnostic.WARNING);
      if (_equals_1) {
        String _plus_1 = ("Model has warnings: " + diagnostic);
        InputOutput.<String>println(_plus_1);
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
    Boolean _valueOf = Boolean.valueOf(enabled);
    Boolean _enabled = this.enabled = _valueOf;
    return _enabled;
  }
}
