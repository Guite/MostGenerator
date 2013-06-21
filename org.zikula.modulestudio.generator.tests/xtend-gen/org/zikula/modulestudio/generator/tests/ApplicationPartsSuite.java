package org.zikula.modulestudio.generator.tests;

import org.jnario.runner.Contains;
import org.jnario.runner.ExampleGroupRunner;
import org.jnario.runner.Named;
import org.junit.runner.RunWith;
import org.zikula.modulestudio.generator.tests.application.TestsForGeneratorApplicationClassesSpec;

@Named("Application parts")
@Contains(TestsForGeneratorApplicationClassesSpec.class)
@RunWith(ExampleGroupRunner.class)
@SuppressWarnings("all")
public class ApplicationPartsSuite {
}
