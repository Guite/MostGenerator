package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents.DeveloperHints
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents.License_GPL
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents.License_LGPL
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Docs {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for module documentation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = 'CHANGELOG.md'
        if (!shouldBeSkipped(getAppSourcePath + fileName)) {
            if (shouldBeMarked(getAppSourcePath + fileName)) {
                fileName = 'CHANGELOG.generated.md'
            }
            fsa.generateFile(getAppSourcePath + fileName, Changelog)
        }
        fileName = 'README.md'
        if (!shouldBeSkipped(getAppSourcePath + fileName)) {
            if (shouldBeMarked(getAppSourcePath + fileName)) {
                fileName = 'README.generated.md'
            }
            fsa.generateFile(getAppSourcePath + fileName, ReadmeMarkup)
        }

        val docPath = getAppDocPath
        fileName = 'credits.md'
        if (!shouldBeSkipped(docPath + 'credits.md')) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'credits.generated.md'
            }
            fsa.generateFile(docPath + fileName, Credits)
        }
        fileName = 'developers.md'
        if (!shouldBeSkipped(docPath + fileName)) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'developers.generated.md'
            }
            fsa.generateFile(docPath + fileName, new DeveloperHints().generate(it))
        }
        fileName = 'doctrine.md'
        if (!shouldBeSkipped(docPath + fileName)) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'doctrine.generated.md'
            }
            fsa.generateFile(docPath + fileName, DoctrineHints)
        }
        fileName = 'modulestudio.md'
        if (!shouldBeSkipped(docPath + fileName)) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'modulestudio.generated.md'
            }
            fsa.generateFile(docPath + fileName, MostText)
        }
        fileName = 'install.md'
        if (!shouldBeSkipped(docPath + fileName)) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'install.generated.md'
            }
            fsa.generateFile(docPath + fileName, Install)
        }
        if (!targets('1.3.x') && !isSystemModule) {
            fileName = 'translation.md'
            if (!shouldBeSkipped(docPath + fileName)) {
                if (shouldBeMarked(docPath + fileName)) {
                    fileName = 'translation.generated.md'
                }
                fsa.generateFile(docPath + fileName, Translation)
            }
        }
        fileName = 'LICENSE'
        if (!shouldBeSkipped(getAppLicencePath + fileName)) {
            if (shouldBeMarked(getAppLicencePath + fileName)) {
                fileName = 'LICENSE.generated'
            }
            fsa.generateFile(getAppLicencePath + fileName, License)
        }
        if (writeModelToDocs) {
            fsa.generateFile(docPath + '/model/.htaccess', htAccessForModel)
        }
    }

    def private Credits(Application it) '''
        # CREDITS

    '''

    def private Changelog(Application it) '''
        # CHANGELOG

        Changes in «appName» «version»
    '''

    def private DoctrineHints(Application it) '''
        # NOTES ON USING DOCTRINE 2

        Please note that you should not use print_r() for debugging Doctrine 2 entities.
        The reason for that is that these objects contain too many references which will
        result in a very huge output.

        Instead use the Doctrine\Common\Util\Debug::dump($entity) method which reduces
        the output to reasonable information.«IF !targets('1.3.x')» Since Zikula 1.4.0 there is also
        a shortcut method available in System::dump($var, $maxDepth = 2, $stripTags = true).«ENDIF»
        
        Read more about Doctrine at http://docs.doctrine-project.org/projects/doctrine-orm/en/latest/index.html
    '''


    def private MostText(Application it) '''
        # MODULESTUDIO
        
        This module has been generated by ModuleStudio «msVersion», a model-driven solution
        for creating web applications for the Zikula Application Framework.

        If you are interested in a new level of Zikula development, visit «msUrl».
    '''

    def private Install(Application it) '''
        # INSTALLATION INSTRUCTIONS

        «IF targets('1.3.x')»
            1. Copy «appName» into your modules directory. Afterwards you should have a folder named `modules/«appName»/lib`.
        «ELSE»
            «IF isSystemModule»
                1. Copy «appName» into your system directory. Afterwards you should have a folder named `system/«name.formatForCodeCapital»Module/Resources`.
            «ELSE»
                1. Copy «appName» into your modules directory. Afterwards you should have a folder named `modules/«vendor.formatForCodeCapital»/«name.formatForCodeCapital»Module/Resources`.
            «ENDIF»
        «ENDIF»
        2. Initialize and activate «appName» in the modules administration.
        «IF hasUploads»
            «IF !targets('1.3.x')»
                3. Move or copy the directory `Resources/userdata/«appName»/` to `/userdata/«appName»/`.
                   Note this step is optional as the install process can create these folders, too.
                4. Make the directory `/userdata/«appName»/` writable including all sub folders.
            «ELSE»
                3. Make the directory `/userdata/«appName»/` writable including all sub folders.
            «ENDIF»
        «ENDIF»

        For questions and other remarks visit our homepage «url».

        «ReadmeFooter»
    '''

    def private Translation(Application it) '''
        # TRANSLATION INSTRUCTIONS

        To create a new translation follow the steps below:

        1. First install the module like described in the `install.md` file.
        2. Open a console and navigate to the Zikula root directory.
        3. Execute this command replacing `en` by your desired locale code:

        `php app/console translation:extract en --bundle=«appName» --enable-extractor=jms_i18n_routing --output-format=po`

        You can also use multiple locales at once, for example `de fr es`.

        4. Translate the resulting `.po` files in `modules/«vendor.formatForCodeCapital»/«name.formatForCodeCapital»Module/Resources/translations/` using your favourite Gettext tooling.

        For questions and other remarks visit our homepage «url».

        «ReadmeFooter»
    '''

    def private ReadmeFooter(Application it) '''
        «author»«IF email != ""» («email»)«ENDIF»
        «IF url != ""»«url»«/*«ELSE»«msUrl»*/»«ENDIF»
    '''

    def ReadmeMarkup(Application it) '''
        # «vendor.formatForDisplay»\«name.formatForCodeCapital» «version»

        «IF null !== documentation && documentation != ''»
            «documentation.replace("'", "\\'")»
        «ELSE»
            «vendor.formatForDisplayCapital»\«name.formatForCodeCapital» module generated by ModuleStudio «msVersion».
        «ENDIF»

        «IF targets('1.3.x')»
            This module is intended for being used with Zikula 1.3.5 to 1.3.11.
        «ELSE»
            This module is intended for being used with Zikula «IF targets('1.4-dev')»1.4.5-git«ELSE»1.4.4«ENDIF» and later.
            «IF targets('1.4-dev')»

            **Note this is a development version which is NOT READY for production yet.**
            «ENDIF»
        «ENDIF»

        For questions and other remarks visit our homepage «url».

        «ReadmeFooter»
    '''

    def private License(Application it) '''
        «IF license == 'http://www.gnu.org/licenses/lgpl.html GNU Lesser General Public License'
          || license == 'GNU Lesser General Public License'
          || license == 'Lesser General Public License'
          || license == 'LGPL'»
            «new License_LGPL().generate(it)»
        «ELSEIF license == 'http://www.gnu.org/copyleft/gpl.html GNU General Public License'
          || license == 'GNU General Public License'
          || license == 'General Public License'
          || license == 'GPL'»
            «new License_GPL().generate(it)»
        «ELSE»
            Please enter your license text here.
        «ENDIF»
    '''

    def private htAccessForModel(Application it) '''
        # «new FileHelper().generatedBy(it, timestampAllGeneratedFiles, versionAllGeneratedFiles)»
        # ------------------------------------------------------------
        # Purpose of file: block any web access to unallowed files
        # stored in this directory
        # ------------------------------------------------------------

        # Apache 2.2
        <IfModule !mod_authz_core.c>
            Deny from all
        </IfModule>

        # Apache 2.4
        <IfModule mod_authz_core.c>
            Require all denied
        </IfModule>
    '''
}
