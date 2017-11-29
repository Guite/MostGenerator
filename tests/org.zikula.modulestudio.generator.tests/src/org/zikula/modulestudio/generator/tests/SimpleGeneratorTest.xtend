/**
 * Copyright (c) 2007-2017 Axel Guckelsberger
 */
package org.zikula.modulestudio.generator.tests

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith
import org.zikula.modulestudio.generator.cartridges.MostGenerator

import static extension org.junit.Assert.*

/**
 * Tests for the generator.
 */
@RunWith(XtextRunner)
@InjectWith(MostDslInjectorProvider)
class SimpleGeneratorTest {

    @Inject MostGenerator generator

    @Inject extension ParseHelper<Application>

    /**
     * capture the results by keeping files in memory
     * instead of writing them to the disk
     */
    var InMemoryFileSystemAccess fsa

    /**
     * First simple test.
     */
    @Test
    def void testDummyGenerator() {
        val app = TestModels.simpleNews.parse
        startGeneration(app)

        //println('Binary files:')
        //println(fsa.binaryFiles)
        //println('Text files:')
        //println(fsa.textFiles)

        fsa.textFiles.size.assertNotEquals(0)

        checkTextFile('bootstrap.php',
            '''
            here comes the expected output
            ''')

        checkTextFile('composer.json',
            '''
            here comes the expected output
            ''')

        checkTextFile('zikula.manifest.json',
            '''
            here comes the expected output
            ''')
    }

    def private startGeneration(Application app) {
        fsa = new InMemoryFileSystemAccess
        fsa.textFileEnconding = 'UTF-8'

        generator.cartridge = 'zclassic'
        generator.doGenerate(app.eResource, fsa)
    }

    def private checkTextFile(String fileName, String content) {
        val filePath = IFileSystemAccess.DEFAULT_OUTPUT + fileName
        fsa.textFiles.containsKey(filePath).assertTrue
        //TODO enable content checks
        content.assertNotEquals('')
        //fsa.textFiles.get(filePath).toString.assertEquals(content)
    }

    //@Test(expected=IllegalStateException)
    @Test(expected=NullPointerException)
    def void testInvalidInputWithoutAnyEntities() {
        val app = TestModels.simpleNews.parse
        app.entities.clear
        startGeneration(app)

        /*
        val allErrors = getErrorsAndWarnings.filter[severity == Severity.ERROR]
        if (!allErrors.empty) {
            throw new IllegalStateException(
                "One or more resources contained errors : " +
                allErrors.map[toString].join(", ")
            )
        }*/
    }

    /**
     * Strategic aspect: tests verifying the generator output are not always a good idea as
     * generator templates are often subject of amendments.
     *
     * Therefore we should primarily write unit tests for the extensions that are
     * used by the generator in order to test them intensively.
     * 
     * Testing generator output can still make sense for doing integration tests though.
     */
}
