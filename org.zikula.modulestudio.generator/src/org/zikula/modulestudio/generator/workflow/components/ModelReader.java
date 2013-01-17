package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;

import com.google.inject.Injector;

import de.guite.modulestudio.MostDslStandaloneSetup;
import de.guite.modulestudio.ui.internal.MostDslActivator;

/**
 * Workflow component class for reading the input model.
 */
public class ModelReader extends WorkflowComponentWithSlot {

    /**
     * The treated uri.
     */
    private String uri = ""; //$NON-NLS-1$

    /**
     * Invokes the workflow component from the outside.
     * 
     * @return The created Resource instance.
     */
    public Resource invoke() {
        return getResource();
    }

    /**
     * Invokes the workflow component from a workflow.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    @Override
    public void invoke(IWorkflowContext ctx) {
        final Resource resource = getResource();
        ctx.put(getSlot(), resource);
    }

    /**
     * Retrieves the resource for the given uri.
     * 
     * @return The created Resource instance.
     */
    protected Resource getResource() {
        final Injector injector = getInjector();
        final XtextResourceSet resourceSet = injector
                .getInstance(XtextResourceSet.class);
        resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL,
                Boolean.TRUE);

        final String uri = getUri();
        final URI fileURI = (uri.substring(0, 4).equals("file")) ? URI
                .createURI(uri) : URI.createFileURI(uri);
        final Resource resource = resourceSet.getResource(fileURI, true);

        return resource;
    }

    /**
     * Returns the injector.
     * 
     * @return The injector.
     */
    protected Injector getInjector() {
        MostDslActivator mostDslActivator = null;
        mostDslActivator = MostDslActivator.getInstance();
        Injector injector = null;
        if (mostDslActivator != null) {
            // Within MOST
            injector = mostDslActivator
                    .getInjector(MostDslActivator.DE_GUITE_MODULESTUDIO_MOSTDSL);
        }
        if (injector == null) {
            // Standalone execution
            injector = new MostDslStandaloneSetup()
                    .createInjectorAndDoEMFRegistration();
        }

        return injector;
    }

    /**
     * Returns the uri.
     * 
     * @return The uri string.
     */
    public String getUri() {
        return this.uri;
    }

    /**
     * Sets the uri.
     * 
     * @param uri
     *            The uri string.
     */
    public void setUri(String uri) {
        this.uri = uri;
    }
}
