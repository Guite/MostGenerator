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
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    @Override
    public void invoke(IWorkflowContext ctx) {
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
        final XtextResourceSet resourceSet = injector
                .getInstance(XtextResourceSet.class);
        resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL,
                Boolean.TRUE);

        final URI fileURI = URI.createFileURI(this.getUri());
        final Resource resource = resourceSet.getResource(fileURI, true);
        ctx.put(getSlot(), resource);
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
