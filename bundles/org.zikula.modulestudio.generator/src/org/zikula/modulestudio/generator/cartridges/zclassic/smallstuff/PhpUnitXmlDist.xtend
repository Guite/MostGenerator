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
        <phpunit
            bootstrap="./../../../lib/bootstrap.php"
            backupGlobals="false"
            backupStaticAttributes="false"
            colors="true"
            convertErrorsToExceptions="true"
            convertNoticesToExceptions="true"
            convertWarningsToExceptions="true"
            processIsolation="false"
            stopOnFailure="false"
        >
            <testsuites>
                <testsuite name="«appName» Test Suite">
                    <directory>./Tests</directory>
                    <exclude>./Tests/Entity/*/Repository</exclude>
                    <exclude>./vendor</exclude>
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
