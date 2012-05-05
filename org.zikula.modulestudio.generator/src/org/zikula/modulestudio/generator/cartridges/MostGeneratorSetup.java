package org.zikula.modulestudio.generator.cartridges;

import org.eclipse.xtext.ISetup;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class MostGeneratorSetup implements ISetup {

    @Override
    public Injector createInjectorAndDoEMFRegistration() {
        return Guice.createInjector(new MostGeneratorModule());
    }
}
