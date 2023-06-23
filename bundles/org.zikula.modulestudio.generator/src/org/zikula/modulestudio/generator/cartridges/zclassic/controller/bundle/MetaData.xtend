package org.zikula.modulestudio.generator.cartridges.zclassic.controller.bundle

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.application.ImportList

class MetaData {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    /**
     * Entry point for application initializer.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasUploads && !hasCategorisableEntities) {
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
        if (hasCategorisableEntities) {
            for (entity : getCategorisableEntities) {
                imports.add(appNamespace + '\\Entity\\' + entity.name.formatForCodeCapital)
            }
        }
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

            public function getCategorizableEntityClasses(): array
            {
                «IF !hasCategorisableEntities»
                    return [];
                «ELSE»
                    return [
                        «FOR entity : getCategorisableEntities»
                            «entity.name.formatForCodeCapital»::class,
                        «ENDFOR»
                    ];
                «ENDIF»
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
