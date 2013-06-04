package org.zikula.modulestudio.generator.cartridges;

import org.eclipse.xtext.resource.generic.AbstractGenericResourceSupport;

import com.google.inject.Module;

/**
 * Initialisation class for the Guice module.
 */
public class MostGeneratorSupport extends AbstractGenericResourceSupport {

    /**
     * Creates the Guice module.
     * 
     * @return The {@link MostGeneratorModule} instance.
     */
    @Override
    protected Module createGuiceModule() {
        return new MostGeneratorModule();
    }
}
