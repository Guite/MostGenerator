package org.zikula.modulestudio.generator.cartridges.symfony.controller.bundle

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MetaData {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    /**
     * Entry point for application initializer.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasUploads) {
            return
        }
        fsa.generateClassPair('Bundle/MetaData/' + appName + 'MetaData.php', metaDataBaseClass, metaDataImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Component\\Translation\\TranslatableMessage',
            'Zikula\\CoreBundle\\Bundle\\MetaData\\BundleMetaDataInterface',
            'function Symfony\\Component\\Translation\\t'
        ])
        imports
    }

    def private metaDataBaseClass(Application it) '''
        namespace «appNamespace»\Bundle\MetaData\Base;

        «collectBaseImports.print»

        /**
         * Meta data base class.
         */
        abstract class Abstract«appName»MetaData implements BundleMetaDataInterface
        {
            public function getDisplayName(): TranslatableMessage
            {
                return t('«name.formatForDisplayCapital»');
            }

            public function getDescription(): TranslatableMessage
            {
                return t('«appDescription»');
            }

            public function getIcon(): string
            {
                return 'fas fa-database';
            }
        }
    '''

    def private metaDataImpl(Application it) '''
        namespace «appNamespace»\Bundle\MetaData;

        use «appNamespace»\Bundle\MetaData\Base\Abstract«appName»MetaData;

        /**
         * Meta data implementation class.
         */
        class «appName»MetaData extends Abstract«appName»MetaData
        {
            // feel free to extend the bundle meta data here
        }
    '''
}
