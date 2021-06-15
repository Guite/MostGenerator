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
                 xsi:noNamespaceSchemaLocation="«IF targets('3.x-dev')»../../../vendor/phpunit/phpunit/«ELSE»https://schema.phpunit.de/8.3/«ENDIF»phpunit.xsd"
                 bootstrap="../../../«IF targets('3.0') && !isSystemModule»../«ENDIF»«IF targets('3.x-dev')»tests/bootstrap.php«ELSE»vendor/autoload.php«ENDIF»"
                 colors="true"
                 «IF targets('3.0')»
                    convertDeprecationsToExceptions="false"
                 «ENDIF»
                 executionOrder="depends,defects"
                 forceCoversAnnotation="true"
                 beStrictAboutCoversAnnotation="true"
                 beStrictAboutOutputDuringTests="true"
                 beStrictAboutTodoAnnotatedTests="true"
                 verbose="true"
        >
            «IF !targets('3.0')»
                <php>
                    <server name="KERNEL_CLASS" value="ZikulaKernel" />
                </php>
            «ENDIF»
            <testsuites>
                <testsuite name="«appName» Test Suite">
                    <directory>./Tests</directory>
                    <exclude>./Tests/Entity/*/Repository</exclude>
                    <exclude>./vendor/</exclude>
                </testsuite>
            </testsuites>
            <filter>
                <whitelist>
                    <directory>./</directory>
                    <exclude>
                        <directory>./Resources</directory>
                        <directory>./Tests</directory>
                        <directory>./vendor</directory>
                    </exclude>
                </whitelist>
            </filter>
        </phpunit>
    '''
}
