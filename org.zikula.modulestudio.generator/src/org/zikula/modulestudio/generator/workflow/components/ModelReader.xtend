package org.zikula.modulestudio.generator.workflow.components

import com.google.inject.Guice
import com.google.inject.Injector
import com.google.inject.Module
import de.guite.modulestudio.MostDslRuntimeModule
import de.guite.modulestudio.MostDslStandaloneSetup
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet

/**
 * Workflow component class for reading the input model.
 */
class ModelReader extends WorkflowComponentWithSlot {

    /**
     * Whether we are inside a manual mwe workflow or OSGi.
     */
    Boolean isStandalone = false

    /**
     * The treated uri.
     */
    @Accessors
    String uri = '' //$NON-NLS-1$

    /**
     * The Guice injector instance.
     */
    Injector injector = null

    /**
     * Invokes the workflow component from the outside.
     * 
     * @return The created Resource instance.
     */
    def Resource invoke() {
        getResource
    }

    /**
     * Invokes the workflow component from a workflow.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    override invoke(IWorkflowContext ctx) {
        ctx.put(slot, getResource)
    }

    /**
     * Retrieves the resource for the given uri.
     * 
     * @return The created Resource instance.
     */
    def protected getResource() {
        val injector = getInjector
        val XtextResourceSet resourceSet = injector
                .getInstance(XtextResourceSet)
        resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL,
                Boolean.TRUE)

        val uri = getUri
        val fileURI = if ('file'.equals(uri.substring(0, 4))) URI
                .createURI(uri) else URI.createFileURI(uri)
        val resource = resourceSet.getResource(fileURI, true)

        resource
    }

    /**
     * Sets the standalone flag.
     * 
     * @param newValue
     *            The given flag value.
     */
    def setIsStandalone(Boolean newValue) {
        isStandalone = newValue
    }

    /**
     * Sets the injector.
     * 
     * @param injector
     *            The given {@link Injector} instance.
     */
    def setInjector(Injector injector) {
        this.injector = injector
    }

    /**
     * Returns the injector.
     * 
     * @return The injector.
     */
    def protected getInjector() {
        if (injector !== null) {
            // injector given by MOST
            return this.injector
        }

        if (!this.isStandalone) {
            // create injector for WebGen
            val Module runtimeModule = new MostDslRuntimeModule
            this.injector = Guice.createInjector(runtimeModule)
        }
        else {
            // standalone setup for mwe files
            injector = new MostDslStandaloneSetup()
                    .createInjectorAndDoEMFRegistration
        }

        injector
    }
}
