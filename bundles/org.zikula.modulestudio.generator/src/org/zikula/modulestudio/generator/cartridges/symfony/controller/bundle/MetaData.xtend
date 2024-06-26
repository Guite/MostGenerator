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
        fsa.generateClassPair('Bundle/MetaData/' + name.formatForCodeCapital + 'MetaData.php', metaDataBaseClass, metaDataImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
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
        abstract class Abstract«name.formatForCodeCapital»BundleMetaData implements BundleMetaDataInterface
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

        use «appNamespace»\Bundle\MetaData\Base\Abstract«name.formatForCodeCapital»BundleMetaData;

        /**
         * Meta data implementation class.
         */
        class «name.formatForCodeCapital»BundleMetaData extends Abstract«name.formatForCodeCapital»BundleMetaData
        {
            // feel free to extend the bundle meta data here
        }
    '''
}
