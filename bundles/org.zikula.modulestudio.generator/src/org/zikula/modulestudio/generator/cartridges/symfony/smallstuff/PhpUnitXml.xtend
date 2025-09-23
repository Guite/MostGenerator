package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

class PhpUnitXml {

    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('phpunit.dist.xml', phpUnitConfig)
    }

    def private phpUnitConfig(Application it) '''
        <?xml version="1.0" encoding="UTF-8"?>
        <!-- https://docs.phpunit.de/en/12.3/configuration.html -->
        <phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:noNamespaceSchemaLocation="../../../vendor/phpunit/phpunit/phpunit.xsd"
                 bootstrap="../../../../tests/bootstrap.php"
                 cacheDirectory=".phpunit.cache"
                 colors="true"
                 executionOrder="depends,defects"
                 failOnNotice="true"
                 failOnWarning="true"
                 requireCoverageMetadata="true"
                 beStrictAboutChangesToGlobalState="true"
                 beStrictAboutOutputDuringTests="true"
                 beStrictAboutTodoAnnotatedTests="true"
                 displayDetailsOnIncompleteTests="true"
                 displayDetailsOnSkippedTests="true"
                 displayDetailsOnTestsThatTriggerDeprecations="true"
                 displayDetailsOnTestsThatTriggerErrors="true"
                 displayDetailsOnTestsThatTriggerNotices="true"
                 displayDetailsOnTestsThatTriggerWarnings="true"
        >
            <php>
                <ini name="display_errors" value="1"/>
                <ini name="error_reporting" value="-1"/>
                <env name="KERNEL_CLASS" value="App\Kernel"/>
                <server name="APP_ENV" value="test" force="true"/>
                <server name="SHELL_VERBOSITY" value="-1"/>
            </php>

            <testsuites>
                <testsuite name="«appName» Test Suite">
                    <directory>tests</directory>
                </testsuite>
            </testsuites>

            <source ignoreSuppressionOfDeprecations="true" restrictNotices="true" restrictWarnings="true">
                <include>
                    <directory suffix=".php">src</directory>
                </include>
            </source>
        </phpunit>
    '''
}
