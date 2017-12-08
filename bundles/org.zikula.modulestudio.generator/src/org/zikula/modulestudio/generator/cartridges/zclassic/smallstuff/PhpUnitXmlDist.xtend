package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class PhpUnitXmlDist {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (!generateTests) {
            return
        }
        var fileName = 'phpunit.xml.dist'
        if (!shouldBeSkipped(fileName)) {
            if (shouldBeMarked(fileName)) {
                fileName = 'phpunit.xml.generated.dist'
            }
            fsa.generateFile(fileName, phpUnitXml)
        }
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
            syntaxCheck="true"
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
