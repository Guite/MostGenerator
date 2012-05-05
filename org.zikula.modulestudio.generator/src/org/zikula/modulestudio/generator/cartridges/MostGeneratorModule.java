package org.zikula.modulestudio.generator.cartridges;

import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.resource.generic.AbstractGenericResourceRuntimeModule;

public class MostGeneratorModule extends AbstractGenericResourceRuntimeModule {

    @Override
    protected String getLanguageName() {
        return "most.generator.GeneratorEditorID";
    }

    @Override
    protected String getFileExtensions() {
        return "mostapp";// mostdsl";
    }

    public Class<? extends IGenerator> bindIGenerator() {
        return MostGenerator.class;
    }

    public Class<? extends ResourceSet> bindResourceSet() {
        return ResourceSetImpl.class;
        // Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("mostapp"/*"mostdsl"*/,
        // new ModulestudioResourceFactoryImpl());
    }
}
