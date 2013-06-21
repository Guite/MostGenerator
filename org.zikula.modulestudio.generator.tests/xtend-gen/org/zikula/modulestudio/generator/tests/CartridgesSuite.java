package org.zikula.modulestudio.generator.tests;

import org.jnario.runner.Contains;
import org.jnario.runner.ExampleGroupRunner;
import org.jnario.runner.Named;
import org.junit.runner.RunWith;
import org.zikula.modulestudio.generator.tests.ReportingSuite;
import org.zikula.modulestudio.generator.tests.ZikulaClassicSuite;

@Named("Cartridges")
@Contains({ ZikulaClassicSuite.class, ReportingSuite.class })
@RunWith(ExampleGroupRunner.class)
@SuppressWarnings("all")
public class CartridgesSuite {
}
