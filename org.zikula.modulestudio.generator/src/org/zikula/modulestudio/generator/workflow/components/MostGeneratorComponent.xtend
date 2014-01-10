package org.zikula.modulestudio.generator.workflow.components

import com.google.inject.Inject
import com.google.inject.Injector
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext
import org.eclipse.xtext.ISetup
import org.eclipse.xtext.generator.GeneratorComponent
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.MostGenerator

/**
 * Workflow component class for invoking the generator.
 */
class MostGeneratorComponent extends GeneratorComponent implements
        IWorkflowComponent {

    /**
     * The injector.
     */
    @Property
    Injector injector

    /**
     * List of slot names.
     */
    @Property
    List<String> slotNames = newArrayList()

    /**
     * List of outlets.
     */
    @Property
    Map<String, String> outlets = newHashMap()

    /**
     * Name of current cartridge.
     */
    @Property
    String cartridge = '' //$NON-NLS-1$

    /**
     * Registers an {@link ISetup}, which causes the execution of
     * {@link ISetup#createInjectorAndDoEMFRegistration()} the resulting
     * {@link Inject} is stored and used to obtain the used
     * {@link IGenerator}.
     */
    override setRegister(ISetup setup) {
        setInjector(setup.createInjectorAndDoEMFRegistration)
    }

    /**
     * adds a slot name to look for {@link Resource}s (the slot's contents might
     * be a Resource or an Iterable of Resources).
     */
    override addSlot(String slot) {
        slotNames.add(slot)
    }

    /**
     * Performs actions before the invocation.
     */
    override preInvoke() {
        if (slotNames.empty) {
            throw new IllegalStateException("no 'slot' has been configured.")
        }
        if (injector === null) {
            throw new IllegalStateException(
                    "no Injector has been configured. Use 'register' with an ISetup or 'injector' directly.")
        }
        if (outlets.empty) {
            throw new IllegalStateException("no 'outlet' has been configured.")
        }

        for (outlet : outlets.entrySet) {
            if (outlet.key === null) {
                throw new IllegalStateException('One of the outlets was configured without a name')
            }
            if (outlet.value === null) {
                throw new IllegalStateException("The path of outlet '" + outlet.key + "' was null.")
            }
        }
    }

    /**
     * An outlet is defined by a name and a path. The generator will internally
     * choose one of the configured outlets when generating a file. the given
     * path defines the root directory of the outlet.
     * 
     * @param out
     *            The given {@link org.zikula.modulestudio.generator.workflow.Outlet}.
     */
    def void addOutlet(org.zikula.modulestudio.generator.workflow.Outlet out) {
        outlets.put(out.outletName, out.path)
    }

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    override invoke(IWorkflowContext ctx) {
        val instance = getCompiler
        val fileSystemAccess = configuredFileSystemAccess
        for (slot : slotNames) {
            val object = ctx.get(slot)
            if (object === null) {
                throw new IllegalStateException("Slot '" + slot + "' was empty!")
            }
            if (object instanceof Iterable<?>) {
                for (object2 : object) {
                    if (!(object2 instanceof Resource)) {
                        throw new IllegalStateException(
                                "Slot contents was not a Resource but a '" + object.class.simpleName + "'!")
                    }
                    instance.doGenerate(object2 as Resource, fileSystemAccess)
                }
            } else if (object instanceof Resource) {
                instance.doGenerate(object, fileSystemAccess)
            } else {
                throw new IllegalStateException(
                        "Slot contents was not a Resource but a '" + object.class.simpleName + "'!")
            }
        }
    }

    override protected IGenerator getCompiler() {
        // return injector.getInstance(IGenerator)
        val generator = injector.getInstance(IGenerator) as MostGenerator
        generator.cartridge = cartridge

        generator
    }

    override protected IFileSystemAccess getConfiguredFileSystemAccess() {
        val configuredFileSystemAccess = injector.getInstance(JavaIoFileSystemAccess)
        for (outlet : outlets.entrySet) {
            configuredFileSystemAccess.setOutputPath(outlet.key, outlet.value)
        }
        configuredFileSystemAccess
    }

    /**
     * Performs actions after the invocation.
     */
    override postInvoke() {
        // Nothing to do here yet
    }
}
