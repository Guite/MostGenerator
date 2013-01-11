package org.zikula.modulestudio.generator.workflow.components;

import java.io.IOException;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.common.util.WrappedException;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

/**
 * Workflow component class for writing the enriched model for debugging
 * purposes after m2m transformation has been applied.
 */
public class ModelWriter extends WorkflowComponentWithSlot {

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
        final Resource resource = (Resource) ctx.get(getSlot());
        URI uri = URI.createFileURI(getUri());
        uri = resource.getResourceSet().getURIConverter().normalize(uri);
        resource.setURI(uri);
        try {
            resource.save(null);
        } catch (final IOException e) {
            throw new WrappedException(e);
        }
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
