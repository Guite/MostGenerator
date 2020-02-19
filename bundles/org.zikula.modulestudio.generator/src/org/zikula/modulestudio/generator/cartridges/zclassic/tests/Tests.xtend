package org.zikula.modulestudio.generator.cartridges.zclassic.tests

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Tests {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for module unit test classes.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        var testsPath = getAppTestsPath

        var fileName = 'Unit/StackTest.php'
        fsa.generateFile(testsPath + fileName, stackUnitTest)

        fileName = 'Integration/StackTest.php'
        fsa.generateFile(testsPath + fileName, stackIntegrationTest)
    }

    def private stackUnitTest(Application it) '''
        use PHPUnit\Framework\TestCase;
        
        class «appName»_Unit_StackTest extends TestCase
        {
            public function testPushAndPop()
            {
                $stack = array();
                $this->assertEquals(0, count($stack));
         
                array_push($stack, 'foo');
                $this->assertEquals('foo', $stack[count($stack)-1]);
                $this->assertEquals(1, count($stack));
         
                $this->assertEquals('foo', array_pop($stack));
                $this->assertEquals(0, count($stack));
            }
        }
    '''

    def private stackIntegrationTest(Application it) '''
        use PHPUnit\Framework\TestCase;
        
        class «appName»_Integration_StackTest extends TestCase
        {
            public function testEmpty()
            {
                $stack = array();
                $this->assertEmpty($stack);
         
                return $stack;
            }
         
            /**
             * @depends testEmpty
             */
            public function testPush(array $stack)
            {
                array_push($stack, 'foo');
                $this->assertEquals('foo', $stack[count($stack)-1]);
                $this->assertNotEmpty($stack);
         
                return $stack;
            }
         
            /**
             * @depends testPush
             */
            public function testPop(array $stack)
            {
                $this->assertEquals('foo', array_pop($stack));
                $this->assertEmpty($stack);
            }
        }
   '''
}
