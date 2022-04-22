package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

class PhpUnitXmlDist {

    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateTests) {
            return
        }
        fsa.generateFile('phpunit.xml.dist', phpUnitXml)
    }

    def private phpUnitXml(Application it) '''
        <?xml version="1.0" encoding="UTF-8"?>
        <phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:noNamespaceSchemaLocation="«IF targets('3.1')»../../../vendor/phpunit/phpunit/«ELSE»https://schema.phpunit.de/8.3/«ENDIF»phpunit.xsd"
                 bootstrap="../../../«IF!isSystemModule»../«ENDIF»«IF targets('3.1')»tests/bootstrap.php«ELSE»vendor/autoload.php«ENDIF»"
                 colors="true"
                 convertDeprecationsToExceptions="false"
                 executionOrder="depends,defects"
                 forceCoversAnnotation="true"
                 beStrictAboutCoversAnnotation="true"
                 beStrictAboutOutputDuringTests="true"
                 beStrictAboutTodoAnnotatedTests="true"
                 verbose="true"
                 testdox="true"
        >
            <php>
                <ini name="display_errors" value="1"/>
                <ini name="error_reporting" value="-1"/>
                <env name="KERNEL_CLASS" value="App\Kernel"/>
                <env name="SYMFONY_DEPRECATIONS_HELPER" value="disabled"/><!-- avoid deprecation warnings in test output -->
                <server name="APP_ENV" value="test" force="true"/>
                <server name="SHELL_VERBOSITY" value="-1"/>
                <server name="SYMFONY_PHPUNIT_REMOVE" value=""/>
                «IF targets('3.1')»
                    <server name="SYMFONY_PHPUNIT_VERSION" value="9.3"/>
                «ENDIF»
            </php>
            <testsuites>
                <testsuite name="«appName» Test Suite">
                    <directory>./Tests</directory>
                    <exclude>./Tests/Entity/*/Repository</exclude>
                    <exclude>./vendor/</exclude>
                </testsuite>
            </testsuites>
            <coverage pathCoverage="true">
                <include>
                    <directory suffix=".php">./</directory>
                </include>
                <exclude>
                    <directory suffix=".php">./Tests/</directory>
                </exclude>
            </coverage>
            <listeners>
                <listener class="Symfony\Bridge\PhpUnit\SymfonyTestsListener"/>
            </listeners>
        </phpunit>
    '''
}
