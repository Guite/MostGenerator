package org.zikula.modulestudio.generator.cartridges;

import org.eclipse.xtext.resource.generic.AbstractGenericResourceSupport;

import com.google.inject.Module;

public class MostGeneratorSupport extends AbstractGenericResourceSupport {

    @Override
    protected Module createGuiceModule() {
        return new MostGeneratorModule();
    }
}
