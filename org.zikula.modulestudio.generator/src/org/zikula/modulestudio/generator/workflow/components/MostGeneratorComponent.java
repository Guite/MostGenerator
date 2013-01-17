package org.zikula.modulestudio.generator.workflow.components;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;

import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.ISetup;
import org.eclipse.xtext.generator.GeneratorComponent;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.zikula.modulestudio.generator.cartridges.MostGenerator;

import com.google.inject.Injector;

/**
 * Workflow component class for invoking the generator.
 */
public class MostGeneratorComponent extends GeneratorComponent implements
        IWorkflowComponent {

    /**
     * The injector.
     */
    private Injector injector;

    /**
     * List of slot names.
     */
    private List<String> slotNames = newArrayList();

    /**
     * List of outlets.
     */
    private Map<String, String> outlets = newHashMap();

    /**
     * Name of current cartridge.
     */
    private String cartridge = ""; //$NON-NLS-1$

    /**
     * Registers an {@link ISetup}, which causes the execution of
     * {@link ISetup#createInjectorAndDoEMFRegistration()} the resulting
     * {@link com.google.inject.Inject} is stored and used to obtain the used
     * {@link IGenerator}.
     */
    @Override
    public void setRegister(ISetup setup) {
        setInjector(setup.createInjectorAndDoEMFRegistration());
    }

    /**
     * adds a slot name to look for {@link Resource}s (the slot's contents might
     * be a Resource or an Iterable of Resources).
     */
    @Override
    public void addSlot(String slot) {
        this.slotNames.add(slot);
    }

    /**
     * Performs actions before the invocation.
     */
    @Override
    public void preInvoke() {
        if (getSlotNames().isEmpty()) {
            throw new IllegalStateException("no 'slot' has been configured.");
        }
        if (getInjector() == null) {
            throw new IllegalStateException(
                    "no Injector has been configured. Use 'register' with an ISetup or 'injector' directly.");
        }
        if (getOutlets().isEmpty()) {
            throw new IllegalStateException("no 'outlet' has been configured.");
        }

        for (final Entry<String, String> outlet : getOutlets().entrySet()) {
            if (outlet.getKey() == null) {
                throw new IllegalStateException(
                        "One of the outlets was configured without a name");
            }
            if (outlet.getValue() == null) {
                throw new IllegalStateException("The path of outle '"
                        + outlet.getKey() + "' was null.");
            }
        }
    }

    /**
     * Represents an outlet of the generator.
     */
    public static class Outlet {

        /**
         * Name of the outlet.
         */
        private String outletName = IFileSystemAccess.DEFAULT_OUTPUT;

        /**
         * The output path.
         */
        private String path;

        /**
         * Returns name of the outlet.
         * 
         * @return The outlet name.
         */
        public String getOutletName() {
            return this.outletName;
        }

        /**
         * Sets outlet name.
         * 
         * @param outputName
         *            The given name.
         */
        public void setOutletName(String outputName) {
            this.outletName = outputName;
        }

        /**
         * Returns the path.
         * 
         * @return The path.
         */
        public String getPath() {
            return this.path;
        }

        /**
         * Sets path.
         * 
         * @param newPath
         *            The given path.
         */
        public void setPath(String newPath) {
            this.path = newPath;
        }
    }

    /**
     * An outlet is defined by a name and a path. The generator will internally
     * choose one of the configured outlets when generating a file. the given
     * path defines the root directory of the outlet.
     * 
     * @param out
     *            The given {@link Outlet}.
     */
    public void addOutlet(Outlet out) {
        getOutlets().put(out.getOutletName(), out.getPath());
    }

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    @Override
    public void invoke(IWorkflowContext ctx) {
        final IGenerator instance = getCompiler();
        final IFileSystemAccess fileSystemAccess = getConfiguredFileSystemAccess();
        for (final String slot : getSlotNames()) {
            final Object object = ctx.get(slot);
            if (object == null) {
                throw new IllegalStateException("Slot '" + slot
                        + "' was empty!");
            }
            if (object instanceof Iterable) {
                final Iterable<?> iterable = (Iterable<?>) object;
                for (final Object object2 : iterable) {
                    if (!(object2 instanceof Resource)) {
                        throw new IllegalStateException(
                                "Slot contents was not a Resource but a '"
                                        + object.getClass().getSimpleName()
                                        + "'!");
                    }
                    instance.doGenerate((Resource) object2, fileSystemAccess);
                }
            }
            else if (object instanceof Resource) {
                instance.doGenerate((Resource) object, fileSystemAccess);
            }
            else {
                throw new IllegalStateException(
                        "Slot contents was not a Resource but a '"
                                + object.getClass().getSimpleName() + "'!");
            }
        }
    }

    @Override
    protected IGenerator getCompiler() {
        // return injector.getInstance(IGenerator.class);
        final MostGenerator generator = (MostGenerator) getInjector()
                .getInstance(IGenerator.class);
        generator.setCartridge(getCartridge());

        return generator;
    }

    @Override
    protected IFileSystemAccess getConfiguredFileSystemAccess() {
        final JavaIoFileSystemAccess configuredFileSystemAccess = getInjector()
                .getInstance(JavaIoFileSystemAccess.class);
        for (final Entry<String, String> outs : getOutlets().entrySet()) {
            configuredFileSystemAccess.setOutputPath(outs.getKey(),
                    outs.getValue());
        }
        return configuredFileSystemAccess;
    }

    /**
     * Performs actions after the invocation.
     */
    @Override
    public void postInvoke() {
        // Nothing to do here yet
    }

    /**
     * Returns the current injector.
     * 
     * @return The {@link Injector} instance.
     */
    public Injector getInjector() {
        return this.injector;
    }

    /**
     * Sets the {@link Injector} to be used to obtain the used
     * {@link IGenerator} instance.
     * 
     * @param newInjector
     *            The given {@link Injector} instance.
     */
    @Override
    public void setInjector(Injector newInjector) {
        this.injector = newInjector;
    }

    /**
     * Returns the list of slot names.
     * 
     * @return The list of slot names.
     */
    public List<String> getSlotNames() {
        return this.slotNames;
    }

    /**
     * Sets the list of slot names.
     * 
     * @param newNames
     *            the new names to set.
     */
    public void setSlotNames(List<String> newNames) {
        this.slotNames = newNames;
    }

    /**
     * Returns the list of outlets.
     * 
     * @return The list of outlets.
     */
    public Map<String, String> getOutlets() {
        return this.outlets;
    }

    /**
     * Sets the list of outlets.
     * 
     * @param newOutlets
     *            the new outlets to set.
     */
    public void setOutlets(Map<String, String> newOutlets) {
        this.outlets = newOutlets;
    }

    /**
     * Returns name of the current cartridge.
     * 
     * @return The cartridge name.
     */
    public String getCartridge() {
        return this.cartridge;
    }

    /**
     * Sets name of the current cartridge.
     * 
     * @param cartridgeName
     *            The given name.
     */
    public void setCartridge(String cartridgeName) {
        this.cartridge = cartridgeName;
    }
}
