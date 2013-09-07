package org.zikula.modulestudio.generator.tests.lib

import org.jnario.lib.AbstractSpecCreator
import com.google.inject.Injector
import org.eclipse.xtext.junit4.IInjectorProvider
import org.eclipse.xtext.junit4.IRegistryConfigurator

/**
 * See http://jnario.org/org/jnario/spec/tests/integration/CustomizingTheSpecCreationSpec.html
 * and https://groups.google.com/forum/#!msg/jnario/U_jVMQKC5wA/IUQ1N3HGTK8J
 *
 * This allows using
 *     @CreateWith(GuiceSpecCreator)
 * as a replacement for
 *     // JUnit 4 Runner, backups and restores EMF Registries
 *     @RunWith(XtextRunner) // There is also ParameterizedXtextRunner
 *     // Google Guice Injector
 *     @InjectWith(MostDslUiInjectorProvider)
 *
 * Detailed explanation:
 * Xtext offers a specific org.junit.runner.Runner. This allows in combination with a
 * org.eclipse.xtext.junit4.IInjectorProvider language specific injections within the test.
 *
 * Since we have fragment = junit.Junit4Fragment {} in our workflow
 * Xtext already generated the class org.xtext.example.mydsl.MyDslInjectorProvider.
 *
 * To wire these things up we annotate your Test with
 *     @RunWith(XtextRunner)
 * and
 *     @InjectWith(MyDslInjectorProvider)
 */
class GuiceSpecCreator extends AbstractSpecCreator {
    var Injector injector

    var static MostDslInjectorProvider injectorProvider = new MostDslInjectorProvider()

    override <T> T create(Class<T> klass) {
        if (injector == null) {
            beforeSpecRun
        }
        injector.getInstance(klass)
    }

    override void beforeSpecRun() {
        injector = getInjectorProvider.getInjector
        if (getInjectorProvider instanceof IRegistryConfigurator) {
            (getInjectorProvider as IRegistryConfigurator).setupRegistry
        }
    }

    override void afterSpecRun() {
        if (getInjectorProvider instanceof IRegistryConfigurator) {
            (getInjectorProvider as IRegistryConfigurator).restoreRegistry
        }
    }

    def static IInjectorProvider getInjectorProvider() {
        injectorProvider
    }
}
