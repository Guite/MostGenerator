package org.zikula.modulestudio.generator.cartridges.symfony.tests

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Tests {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for bundle unit test classes.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        var testsPath = getAppTestsPath

        var fileName = 'Unit/StackTest.php'
        fsa.generateFile(testsPath + fileName, stackUnitTest)

        fileName = 'Integration/StackTest.php'
        fsa.generateFile(testsPath + fileName, stackIntegrationTest)
    }

    def private stackUnitTest(Application it) '''
        namespace «appNamespace»\Tests\Unit;

        use PHPUnit\Framework\TestCase;

        class StackTest extends TestCase
        {
            public function testPushAndPop(): void
            {
                $stack = [];
                self::assertCount(0, $stack);

                $stack[] = 'foo';
                self::assertEquals('foo', $stack[count($stack) - 1]);
                self::assertCount(1, $stack);

                self::assertEquals('foo', array_pop($stack));
                self::assertCount(0, $stack);
            }
        }
    '''

    def private stackIntegrationTest(Application it) '''
        namespace «appNamespace»\Tests\Integration;

        use PHPUnit\Framework\TestCase;

        class StackTest extends TestCase
        {
            public function testEmpty(): array
            {
                $stack = [];
                self::assertEmpty($stack);

                return $stack;
            }

            /**
             * @depends testEmpty
             */
            public function testPush(array $stack): array
            {
                $stack[] = 'foo';
                self::assertEquals('foo', $stack[count($stack) - 1]);
                self::assertNotEmpty($stack);

                return $stack;
            }

            /**
             * @depends testPush
             */
            public function testPop(array $stack): void
            {
                self::assertEquals('foo', array_pop($stack));
                self::assertEmpty($stack);
            }
        }
   '''
}
