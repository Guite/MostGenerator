package org.zikula.modulestudio.generator.workflow.components;

import java.io.IOException;
import java.util.Collections;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.common.util.WrappedException;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.zikula.modulestudio.generator.workflow.components.WorkflowComponentWithSlot;

/**
 * Workflow component class for writing the enriched model for debugging
 * purposes after m2m transformation has been applied.
 */
@SuppressWarnings("all")
public class ModelWriter extends WorkflowComponentWithSlot {
  /**
   * The treated uri.
   */
  @Accessors
  private String uri = "";
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  @Override
  public void invoke(final IWorkflowContext ctx) {
    Object _get = ctx.get(this.getSlot());
    final Resource resource = ((Resource) _get);
    URI fileUri = URI.createFileURI(this.uri);
    fileUri = resource.getResourceSet().getURIConverter().normalize(fileUri);
    resource.setURI(fileUri);
    try {
      resource.save(Collections.EMPTY_MAP);
    } catch (final Throwable _t) {
      if (_t instanceof IOException) {
        final IOException e = (IOException)_t;
        throw new WrappedException(e);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  @Pure
  public String getUri() {
    return this.uri;
  }
  
  public void setUri(final String uri) {
    this.uri = uri;
  }
}
