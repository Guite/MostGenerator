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

public class MostGeneratorComponent extends GeneratorComponent implements
        IWorkflowComponent {
    private Injector injector;
    private final List<String> slotNames = newArrayList();
    private final Map<String, String> outlets = newHashMap();

    private String cartridge = "";

    /**
     * registering an {@link ISetup}, which causes the execution of
     * {@link ISetup#createInjectorAndDoEMFRegistration()} the resulting
     * {@link com.google.inject.Inject} is stored and used to obtain the used
     * {@link IGenerator}.
     */
    @Override
    public void setRegister(ISetup setup) {
        injector = setup.createInjectorAndDoEMFRegistration();
    }

    /**
     * sets the {@link Injector} to be used to obtain the used
     * {@link IGenerator} instance.
     */
    @Override
    public void setInjector(Injector injector) {
        this.injector = injector;
    }

    /**
     * adds a slot name to look for {@link Resource}s (the slot's contents might
     * be a Resource or an Iterable of Resources).
     */
    @Override
    public void addSlot(String slot) {
        this.slotNames.add(slot);
    }

    @Override
    public void preInvoke() {
        if (slotNames.isEmpty()) {
            throw new IllegalStateException("no 'slot' has been configured.");
        }
        if (injector == null) {
            throw new IllegalStateException(
                    "no Injector has been configured. Use 'register' with an ISetup or 'injector' directly.");
        }
        if (outlets.isEmpty()) {
            throw new IllegalStateException("no 'outlet' has been configured.");
        }

        for (final Entry<String, String> outlet : outlets.entrySet()) {
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

    public static class Outlet {

        private String outletName = IFileSystemAccess.DEFAULT_OUTPUT;
        private String path;

        public void setOutletName(String outputName) {
            this.outletName = outputName;
        }

        public void setPath(String path) {
            this.path = path;
        }

        public String getOutletName() {
            return outletName;
        }

        public String getPath() {
            return path;
        }
    }

    /**
     * an outlet is defined by a name and a path. The generator will internally
     * choose one of the configured outlets when generating a file. the given
     * path defines the root directory of the outlet.
     */
    public void addOutlet(Outlet out) {
        outlets.put(out.outletName, out.path);
    }

    @Override
    public void invoke(IWorkflowContext ctx) {
        final IGenerator instance = getCompiler();
        final IFileSystemAccess fileSystemAccess = getConfiguredFileSystemAccess();
        for (final String slot : slotNames) {
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
        final MostGenerator generator = (MostGenerator) injector
                .getInstance(IGenerator.class);
        generator.setCartridge(cartridge);
        return generator;
    }

    @Override
    protected IFileSystemAccess getConfiguredFileSystemAccess() {
        final JavaIoFileSystemAccess configuredFileSystemAccess = injector
                .getInstance(JavaIoFileSystemAccess.class);
        for (final Entry<String, String> outs : outlets.entrySet()) {
            configuredFileSystemAccess.setOutputPath(outs.getKey(),
                    outs.getValue());
        }
        return configuredFileSystemAccess;
    }

    @Override
    public void postInvoke() {

    }

    public String getCartridge() {
        return cartridge;
    }

    public void setCartridge(String cartridgeName) {
        cartridge = cartridgeName;
    }
}
