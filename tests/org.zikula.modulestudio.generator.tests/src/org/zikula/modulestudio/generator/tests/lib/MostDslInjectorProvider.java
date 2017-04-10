/**
 * Copyright (c) 2007-2017 Axel Guckelsberger
 *
 * generated by Xtext 2.11.0
 *
 * see de.guite.modulestudio.mostdsl.tests/src-gen/MostDslInjectorProvider.java
 */
package org.zikula.modulestudio.generator.tests.lib;

import org.eclipse.xtext.testing.GlobalRegistries;
import org.eclipse.xtext.testing.GlobalRegistries.GlobalStateMemento;
import org.eclipse.xtext.testing.IInjectorProvider;
import org.eclipse.xtext.testing.IRegistryConfigurator;

import com.google.inject.Guice;
import com.google.inject.Injector;

import de.guite.modulestudio.MostDslRuntimeModule;
import de.guite.modulestudio.MostDslStandaloneSetup;

public class MostDslInjectorProvider implements IInjectorProvider, IRegistryConfigurator {

    protected GlobalStateMemento stateBeforeInjectorCreation;
    protected GlobalStateMemento stateAfterInjectorCreation;
    protected Injector injector;

    static {
        GlobalRegistries.initializeDefaults();
    }

    @Override
    public Injector getInjector() {
        if (injector == null) {
            stateBeforeInjectorCreation = GlobalRegistries.makeCopyOfGlobalState();
            this.injector = internalCreateInjector();
            stateAfterInjectorCreation = GlobalRegistries.makeCopyOfGlobalState();
        }
        return injector;
    }

    protected static Injector internalCreateInjector() {
        return new MostDslStandaloneSetup() {
            @Override
            public Injector createInjector() {
                return Guice.createInjector(createRuntimeModule());
            }
        }.createInjectorAndDoEMFRegistration();
    }

    protected static MostDslRuntimeModule createRuntimeModule() {
        // make it work also with Maven/Tycho and OSGI
        // see https://bugs.eclipse.org/bugs/show_bug.cgi?id=493672
        return new MostDslRuntimeModule() {
            @Override
            public ClassLoader bindClassLoaderToInstance() {
                return MostDslInjectorProvider.class.getClassLoader();
            }
        };
    }

    @Override
    public void restoreRegistry() {
        stateBeforeInjectorCreation.restoreGlobalState();
    }

    @Override
    public void setupRegistry() {
        getInjector();
        stateAfterInjectorCreation.restoreGlobalState();
    }
}
