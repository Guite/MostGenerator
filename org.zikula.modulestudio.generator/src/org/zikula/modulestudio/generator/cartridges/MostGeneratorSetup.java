package org.zikula.modulestudio.generator.cartridges;

import org.eclipse.xtext.ISetup;

import com.google.inject.Guice;
import com.google.inject.Injector;

/**
 * Guice setup for the generator.
 */
public class MostGeneratorSetup implements ISetup {

    /**
     * Creates the injector for {@link MostGeneratorModule}.
     * 
     * @return The {@link Injector} instance.
     */
    @Override
    public Injector createInjectorAndDoEMFRegistration() {
        return Guice.createInjector(new MostGeneratorModule());
    }
}
