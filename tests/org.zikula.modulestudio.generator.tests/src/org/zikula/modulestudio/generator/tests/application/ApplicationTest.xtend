package org.zikula.modulestudio.generator.tests.application

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Test

import static extension org.junit.Assert.*

/**
 * This class tests certain aspects of the Application meta class.
 */
class ApplicationTest {

    //@Inject MostGenerator generator
    @Inject IGenerator generator

    @Inject extension ParseHelper<Application>

    var InMemoryFileSystemAccess fsa

    /**
     * Testing a code generator.
     */
    @Test
    def void testDummyGenerator() {
        val app = '''
            application "SimpleNews" {
                documentation "Simple news extension"
                vendor "Guite"
                author "Axel Guckelsberger"
                email "info@guite.de"
                url "https://guite.de"
                prefix "sinew"
                entities {
                    entity "article" {
                    }
                }
            }
        '''.parse

        // To capture the results we use a special kind of IFileSystemAccess
        // that keeps the files InMemory and does not write them to the disk.
        fsa = new InMemoryFileSystemAccess

        // Call the generator with our test resource and a InMemoryFileSystemAccess.
        generator.doGenerate(app.eResource, fsa)

        println('Binary files:')
        println(fsa.binaryFiles)
        println('Text files:')
        println(fsa.textFiles)

        fsa.textFiles.size.assertEquals(0)

        checkTextFile('bootstrap.php',
            '''
            here comes the expected output
            ''')

        checkTextFile('SomeClass.php',
            '''
            public class SomeClass
            {
                 // expected code
            }
            ''')
    }

    def private checkTextFile(String fileName, String content) {
        val filePath = IFileSystemAccess.DEFAULT_OUTPUT + fileName
        fsa.textFiles.containsKey(filePath).assertTrue
        fsa.textFiles.get(filePath).toString.assertEquals(content)
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
