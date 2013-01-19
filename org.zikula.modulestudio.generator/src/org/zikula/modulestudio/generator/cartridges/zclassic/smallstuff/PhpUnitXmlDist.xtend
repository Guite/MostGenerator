package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class PhpUnitXmlDist {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
        fsa.generateFile(getAppSourcePath + 'phpunit.xml.dist', phpUnitXml)
    }

    def private phpUnitXml(Application it) '''
        <?xml version="1.0" encoding="UTF-8"?>

        <phpunit backupGlobals="false"
                 backupStaticAttributes="false"
                 colors="true"
                 convertErrorsToExceptions="true"
                 convertNoticesToExceptions="true"
                 convertWarningsToExceptions="true"
                 processIsolation="false"
                 stopOnFailure="false"
                 syntaxCheck="false"
                 bootstrap="vendor/autoload.php"
        >
            <testsuites>
                <testsuite name="«appName» Module Test Suite">
                    <directory>./Tests/</directory>
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
