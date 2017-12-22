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

        var fileName = 'bootstrap.php'
        fsa.generateFile(testsPath + fileName, bootstrapImpl)

        fileName = 'AllTests.php'
        fsa.generateFile(testsPath + fileName, testSuiteImpl)
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
