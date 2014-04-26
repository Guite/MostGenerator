package org.zikula.modulestudio.generator.cartridges.zclassic.tests

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Tests {
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for module unit test classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var testsPath = getAppTestsPath

        var fileName = 'bootstrap.php'
        if (!shouldBeSkipped(testsPath + fileName)) {
            if (shouldBeMarked(testsPath + fileName)) {
                fileName = 'bootstrap.generated.php'
            }
            fsa.generateFile(testsPath + fileName, fh.phpFileContent(it, bootstrapImpl))
        }

        fileName = 'AllTests.php'
        if (!shouldBeSkipped(testsPath + fileName)) {
            if (shouldBeMarked(testsPath + fileName)) {
                fileName = 'AllTests.generated.php'
            }
            fsa.generateFile(testsPath + fileName, fh.phpFileContent(it, testSuiteImpl))
        }
    }

    def private bootstrapImpl(Application it) '''
        error_reporting(E_ALL | E_STRICT);
        require_once 'PHPUnit/TextUI/TestRunner.php';
    '''

    def private testSuiteImpl(Application it) '''
        if (!defined('PHPUnit_MAIN_METHOD')) {
            define('PHPUnit_MAIN_METHOD', 'AllTests::main');
        }

        require_once dirname(__FILE__) . '/bootstrap.php';

        class AllTests
        {
            public static function main()
            {
                PHPUnit_TextUI_TestRunner::run(self::suite());
            }

            public static function suite()
            {
                $suite = new PHPUnit_Framework_TestSuite('«appName» - All Tests');

                return $suite;
            }
        }

        if (PHPUnit_MAIN_METHOD == 'AllTests::main') {
            AllTests::main();
        }
   '''
}
