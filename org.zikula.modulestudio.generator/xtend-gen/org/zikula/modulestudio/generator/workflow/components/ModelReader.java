package org.zikula.modulestudio.generator.workflow.components;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;
import de.guite.modulestudio.MostDslRuntimeModule;
import de.guite.modulestudio.MostDslStandaloneSetup;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.zikula.modulestudio.generator.workflow.components.WorkflowComponentWithSlot;

/**
 * Workflow component class for reading the input model.
 */
@SuppressWarnings("all")
public class ModelReader extends WorkflowComponentWithSlot {
  /**
   * Whether we are inside a manual mwe workflow or OSGi.
   */
  private Boolean isStandalone = Boolean.valueOf(false);
  
  /**
   * The treated uri.
   */
  private String _uri = "";
  
  /**
   * The treated uri.
   */
  public String getUri() {
    return this._uri;
  }
  
  /**
   * The treated uri.
   */
  public void setUri(final String uri) {
    this._uri = uri;
  }
  
  /**
   * The Guice injector instance.
   */
  private Injector injector = null;
  
  /**
   * Invokes the workflow component from the outside.
   * 
   * @return The created Resource instance.
   */
  public Resource invoke() {
    Resource _resource = this.getResource();
    return _resource;
  }
  
  /**
   * Invokes the workflow component from a workflow.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  public void invoke(final IWorkflowContext ctx) {
    String _slot = this.getSlot();
    Resource _resource = this.getResource();
    ctx.put(_slot, _resource);
  }
  
  /**
   * Retrieves the resource for the given uri.
   * 
   * @return The created Resource instance.
   */
  protected Resource getResource() {
    Resource _xblockexpression = null;
    {
      final Injector injector = this.getInjector();
      final XtextResourceSet resourceSet = injector.<XtextResourceSet>getInstance(XtextResourceSet.class);
      resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, 
        Boolean.TRUE);
      final String uri = this.getUri();
      URI _xifexpression = null;
      String _substring = uri.substring(0, 4);
      boolean _equals = _substring.equals("file");
      if (_equals) {
        URI _createURI = URI.createURI(uri);
        _xifexpression = _createURI;
      } else {
        URI _createFileURI = URI.createFileURI(uri);
        _xifexpression = _createFileURI;
      }
      final URI fileURI = _xifexpression;
      final Resource resource = resourceSet.getResource(fileURI, true);
      _xblockexpression = (resource);
    }
    return _xblockexpression;
  }
  
  /**
   * Sets the standalone flag.
   * 
   * @param newValue
   *            The given flag value.
   */
  public Boolean setIsStandalone(final Boolean newValue) {
    Boolean _isStandalone = this.isStandalone = newValue;
    return _isStandalone;
  }
  
  /**
   * Sets the injector.
   * 
   * @param injector
   *            The given {@link Injector} instance.
   */
  public Injector setInjector(final Injector injector) {
    Injector _injector = this.injector = injector;
    return _injector;
  }
  
  /**
   * Returns the injector.
   * 
   * @return The injector.
   */
  protected Injector getInjector() {
    Injector _xblockexpression = null;
    {
      boolean _tripleNotEquals = (this.injector != null);
      if (_tripleNotEquals) {
        return this.injector;
      }
      boolean _not = (!(this.isStandalone).booleanValue());
      if (_not) {
        MostDslRuntimeModule _mostDslRuntimeModule = new MostDslRuntimeModule();
        final Module runtimeModule = _mostDslRuntimeModule;
        Injector _createInjector = Guice.createInjector(runtimeModule);
        this.injector = _createInjector;
      } else {
        MostDslStandaloneSetup _mostDslStandaloneSetup = new MostDslStandaloneSetup();
        Injector _createInjectorAndDoEMFRegistration = _mostDslStandaloneSetup.createInjectorAndDoEMFRegistration();
        this.injector = _createInjectorAndDoEMFRegistration;
      }
      _xblockexpression = (this.injector);
    }
    return _xblockexpression;
  }
}
