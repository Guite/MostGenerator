package org.zikula.modulestudio.generator.workflow.components;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;
import de.guite.modulestudio.MostDslRuntimeModule;
import de.guite.modulestudio.MostDslStandaloneSetup;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtend.lib.annotations.AccessorType;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.xbase.lib.Pure;
import org.zikula.modulestudio.generator.workflow.components.WorkflowComponentWithSlot;

/**
 * Workflow component class for reading the input model.
 */
@SuppressWarnings("all")
public class ModelReader extends WorkflowComponentWithSlot {
  /**
   * Whether we are inside a manual mwe workflow or OSGi.
   */
  @Accessors(AccessorType.PUBLIC_SETTER)
  private Boolean isStandalone = Boolean.valueOf(false);
  
  /**
   * The treated uri.
   */
  @Accessors
  private String uri = "";
  
  /**
   * The Guice injector instance.
   */
  @Accessors(AccessorType.PUBLIC_SETTER)
  private Injector injector = null;
  
  /**
   * Invokes the workflow component from the outside.
   * 
   * @return The created Resource instance.
   */
  public Resource invoke() {
    return this.getResource();
  }
  
  /**
   * Invokes the workflow component from a workflow.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  @Override
  public void invoke(final IWorkflowContext ctx) {
    ctx.put(this.getSlot(), this.getResource());
  }
  
  /**
   * Retrieves the resource for the given uri.
   * 
   * @return The created Resource instance.
   */
  protected Resource getResource() {
    Resource _xblockexpression = null;
    {
      final XtextResourceSet resourceSet = this.getInjector().<XtextResourceSet>getInstance(XtextResourceSet.class);
      resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
      final String uri = this.getUri();
      URI _xifexpression = null;
      boolean _equals = "file".equals(uri.substring(0, 4));
      if (_equals) {
        _xifexpression = URI.createURI(uri);
      } else {
        _xifexpression = URI.createFileURI(uri);
      }
      final URI fileURI = _xifexpression;
      final Resource resource = resourceSet.getResource(fileURI, true);
      _xblockexpression = resource;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the injector.
   * 
   * @return The injector.
   */
  protected Injector getInjector() {
    Injector _xblockexpression = null;
    {
      if ((null != this.injector)) {
        return this.injector;
      }
      if ((!(this.isStandalone).booleanValue())) {
        final Module runtimeModule = new MostDslRuntimeModule();
        this.injector = Guice.createInjector(runtimeModule);
      } else {
        this.injector = new MostDslStandaloneSetup().createInjectorAndDoEMFRegistration();
      }
      _xblockexpression = this.injector;
    }
    return _xblockexpression;
  }
  
  public void setIsStandalone(final Boolean isStandalone) {
    this.isStandalone = isStandalone;
  }
  
  @Pure
  public String getUri() {
    return this.uri;
  }
  
  public void setUri(final String uri) {
    this.uri = uri;
  }
  
  public void setInjector(final Injector injector) {
    this.injector = injector;
  }
}
