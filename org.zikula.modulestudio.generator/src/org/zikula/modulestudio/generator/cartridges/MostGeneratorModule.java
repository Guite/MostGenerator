package org.zikula.modulestudio.generator.cartridges;

import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.resource.generic.AbstractGenericResourceRuntimeModule;

import com.google.inject.Binder;

/**
 * This class is the generator module which is injected by
 * {@link MostGeneratorSetup}.
 */
public class MostGeneratorModule extends AbstractGenericResourceRuntimeModule {

    /**
     * Returns the full qualified language name.
     * 
     * @return The language name.
     */
    @Override
    protected String getLanguageName() {
        return "most.generator.GeneratorEditorID"; //$NON-NLS-1$
    }

    /**
     * Returns the file extensions for the textual notation.
     * 
     * @return The file extensions.
     */
    @Override
    protected String getFileExtensions() {
        return "mostapp";// mostdsl"; //$NON-NLS-1$
    }

    /**
     * Binds the {@link MostGenerator}.
     * 
     * @return The {@link IGenerator} instance.
     */
    public Class<? extends IGenerator> bindIGenerator() {
        return MostGenerator.class;
    }

    /**
     * Binds the {@link ResourceSet}.
     * 
     * @return The {@link ResourceSet} instance.
     */
    public Class<? extends ResourceSet> bindResourceSet() {
        return ResourceSetImpl.class;
        // Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("mostapp"/*"mostdsl"*/,
        // new ModulestudioResourceFactoryImpl());
    }

    @Override
    public void configure(Binder binder) {
        binder.bind(EclipseResourceFileSystemAccess2.class).to(
                MostGenFileSystemAccess.class);
        super.configure(binder);
    }
}
