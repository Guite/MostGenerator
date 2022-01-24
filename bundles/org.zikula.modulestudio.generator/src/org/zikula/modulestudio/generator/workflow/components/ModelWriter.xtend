package org.zikula.modulestudio.generator.workflow.components

import java.io.IOException
import java.util.Collections
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.common.util.WrappedException
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Workflow component class for writing the enriched model for debugging
 * purposes after m2m transformation has been applied.
 */
class ModelWriter extends WorkflowComponentWithSlot {

    /**
     * The treated uri.
     */
    @Accessors
    String uri = '' //$NON-NLS-1$

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    override invoke(IWorkflowContext ctx) {
        val resource = ctx.get(slot) as Resource
        var fileUri = URI.createFileURI(uri)
        fileUri = resource.resourceSet.URIConverter.normalize(fileUri)
        resource.URI = fileUri
        try {
            resource.save(Collections.EMPTY_MAP)
        } catch (IOException exception) {
            throw new WrappedException(exception)
        }
    }
}
