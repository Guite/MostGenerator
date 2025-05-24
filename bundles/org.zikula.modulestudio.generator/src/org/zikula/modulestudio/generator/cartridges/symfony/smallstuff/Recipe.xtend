package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Recipe {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for Flex recipe.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        val recipePath = getRecipePath
        fsa.generateFile(recipePath + 'manifest.json', Manifest)
        fsa.generateFile(recipePath + 'config/routes/' + vendor.formatForDB + '_' + name.formatForDB + '.yaml', Routes)
        fsa.generateFile(recipePath + 'post-install.txt', Instructions)
        if (hasUploads) {
            (new Uploads()).generate(it, fsa)
        }
    }

    def private Manifest(Application it) '''
        {
            "bundles": {
                "«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Bundle\\«appName»": ["all"]
            },
            "copy-from-recipe": {
                "config/": "%CONFIG_DIR%/"«IF hasUploads»,
                "public/": "%PUBLIC_DIR%/"«ENDIF»
            }
        }
    '''

    def private Routes(Application it) '''
        «vendor.formatForDB»_«name.formatForDB»:
            resource: '@«appName»/config/routing.yaml'
    '''

    def private Instructions(Application it) '''
        «'  '»* To finish installation of <info>«appName»</> please follow these steps:

        «'  '»* <fg=blue>Create database tables</>
        «'  '»  1. Create a database migration using <comment>php bin/console make:migration</>.
        «'  '»  2. Review the generated migration file and execute it using <comment>php bin/console doctrine:migrations:migrate</>.
        «'  '»* Alternatively the quick and dirty way during development: <comment>php bin/console doctrine:schema:update --force</>.

        «'  '»* <fg=blue>JavaScript routes</>
        «'  '»  If you use the <info>FOSJsRoutingBundle</> dump JS routes using <comment>php bin/console fos:js-routing:dump</>.
        «IF hasUploads»

            «'  '»* <fg=blue>Upload folder</>
            «'  '»  Ensure the directory `/public/uploads/«appName»/` is writable including all sub folders.
        «ENDIF»
        «IF hasUploads»

            «'  '»* <fg=blue>Additional setup tasks</>
            «'  '»  Execute <comment>php bin/console zikula:init-bundle «appName»</>.
        «ENDIF»
    '''
}
