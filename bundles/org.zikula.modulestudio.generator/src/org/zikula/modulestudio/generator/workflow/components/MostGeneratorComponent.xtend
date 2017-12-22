package org.zikula.modulestudio.generator.workflow.components

import com.google.inject.Inject
import com.google.inject.Injector
import de.guite.modulestudio.metamodel.Application
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ISetup
import org.eclipse.xtext.generator.GeneratorComponent
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.zikula.modulestudio.generator.application.MostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.MostGenerator

/**
 * Workflow component class for invoking the generator.
 */
class MostGeneratorComponent extends GeneratorComponent implements
        IWorkflowComponent {

    /**
     * The injector.
     */
    @Accessors
    Injector injector

    /**
     * List of slot names.
     */
    @Accessors
    List<String> slotNames = newArrayList

    /**
     * List of outlets.
     */
    @Accessors
    Map<String, String> outlets = newHashMap()

    /**
     * Name of current cartridge.
     */
    @Accessors
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
        slotNames += slot
    }

    /**
     * Performs actions before the invocation.
     */
    override preInvoke() {
        if (slotNames.empty) {
            throw new IllegalStateException("no 'slot' has been configured.")
        }
        if (null === injector) {
            throw new IllegalStateException(
                    "no Injector has been configured. Use 'register' with an ISetup or 'injector' directly.")
        }
        if (outlets.empty) {
            throw new IllegalStateException("no 'outlet' has been configured.")
        }

        for (outlet : outlets.entrySet) {
            if (null === outlet.key) {
                throw new IllegalStateException('One of the outlets was configured without a name')
            }
            if (null === outlet.value) {
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
            if (null === object) {
                throw new IllegalStateException("Slot '" + slot + "' was empty!")
            }
            if (object instanceof Iterable<?>) {
                for (object2 : object) {
                    if (!(object2 instanceof Resource)) {
                        throw new IllegalStateException("Slot contents was not a Resource but a '" + object.class.simpleName + "'!")
                    }
                    val model = object2 as Resource
                    if (fileSystemAccess instanceof MostFileSystemAccess) {
                        fileSystemAccess.app = model.contents.head as Application
                    }
                    instance.doGenerate(model, fileSystemAccess)
                }
            } else if (object instanceof Resource) {
                if (fileSystemAccess instanceof MostFileSystemAccess) {
                    fileSystemAccess.app = object.contents.head as Application
                }
                instance.doGenerate(object, fileSystemAccess)
            } else {
                throw new IllegalStateException(
                        "Slot contents was not a Resource but a '" + object.class.simpleName + "'!")
            }
        }
    }

    override protected getCompiler() {
        val generator = injector.getInstance(IGenerator2) as MostGenerator
        generator.cartridge = cartridge

        generator
    }

    override protected getConfiguredFileSystemAccess() {
        val fileSystemAccess = injector.getInstance(JavaIoFileSystemAccess)
        for (outlet : outlets.entrySet) {
            fileSystemAccess.setOutputPath(outlet.key, outlet.value)
        }
        fileSystemAccess
    }

    /**
     * Performs actions after the invocation.
     */
    override postInvoke() {
        // Nothing to do here yet
    }
}
