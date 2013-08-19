package org.zikula.modulestudio.generator.tests;

import org.jnario.runner.Contains;
import org.jnario.runner.ExampleGroupRunner;
import org.jnario.runner.Named;
import org.junit.runner.RunWith;
import org.zikula.modulestudio.generator.tests.ApplicationPartsSuite;
import org.zikula.modulestudio.generator.tests.CartridgesSuite;
import org.zikula.modulestudio.generator.tests.GeneralExtensionsSuite;

@Named("Unit tests")
@Contains({ ApplicationPartsSuite.class, GeneralExtensionsSuite.class, CartridgesSuite.class })
@RunWith(ExampleGroupRunner.class)
@SuppressWarnings("all")
public class UnitTestsSuite {
}
