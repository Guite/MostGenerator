package org.zikula.modulestudio.generator.cartridges;

import org.eclipse.core.internal.resources.Workspace;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.resource.generic.AbstractGenericResourceRuntimeModule;
import org.eclipse.xtext.ui.resource.IStorage2UriMapper;
import org.eclipse.xtext.ui.resource.Storage2UriMapperImpl;

import com.google.inject.Binder;

/**
 * This class is the generator module which is injected by
 * {@link org.zikula.modulestudio.generator.cartridges.MostGeneratorSetup}.
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
     * Binds the
     * {@link org.zikula.modulestudio.generator.cartridges.MostGenerator}.
     * 
     * @return The {@link org.eclipse.xtext.generator.IGenerator} instance.
     */
    public Class<? extends IGenerator> bindIGenerator() {
        return MostGenerator.class;
    }

    /**
     * Binds the {@link org.eclipse.emf.ecore.resource.ResourceSet}.
     * 
     * @return The {@link org.eclipse.emf.ecore.resource.ResourceSet} instance.
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

    /**
     * Binds a workspace (required for the configure method above).
     * 
     * @return Bound workspace class.
     */
    public Class<? extends IWorkspace> bindIWorkspace() {
        return Workspace.class;
    }

    /**
     * Binds a mapper instance (required for the configure method above).
     * 
     * @return Bound storage to uri mapper class.
     */
    public Class<? extends IStorage2UriMapper> bindIStorage2UriMapper() {
        return Storage2UriMapperImpl.class;
    }
}
