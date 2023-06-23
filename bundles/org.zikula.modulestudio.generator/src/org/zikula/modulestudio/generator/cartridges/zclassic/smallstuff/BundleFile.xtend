package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.application.ImportList

class BundleFile {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    Boolean needsInitializer = false

    def generate(Application it, IMostFileSystemAccess fsa) {
        needsInitializer = if (hasUploads || hasCategorisableEntities) true else false
        fsa.generateClassPair(appName + '.php', bundleBaseClass, bundleImpl)
    }

    def private bundleBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        «moduleBaseImpl»
    '''

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Component\\HttpKernel\\Bundle\\Bundle',
            'Zikula\\CoreBundle\\Bundle\\MetaData\\BundleMetaDataInterface',
            'Zikula\\CoreBundle\\Bundle\\MetaData\\MetaDataAwareBundleInterface',
            appNamespace + '\\Bundle\\MetaData\\' + name.formatForCodeCapital + 'BundleMetaData'
        ])
        if (needsInitializer) {
            imports.addAll(#[
                'Zikula\\CoreBundle\\Bundle\\Initializer\\BundleInitializerInterface',
                'Zikula\\CoreBundle\\Bundle\\Initializer\\InitializableBundleInterface',
                appNamespace + '\\Bundle\\Initializer\\' + name.formatForCodeCapital + 'Initializer'
            ])
        }
        imports
    }

    def private moduleBaseImpl(Application it) '''
        «collectBaseImports.print»

        /**
         * Bundle base class.
         */
        abstract class Abstract«appName» extends Bundle implements «IF needsInitializer»InitializableBundleInterface, «ENDIF»MetaDataAwareBundleInterface
        {
            public function getMetaData(): BundleMetaDataInterface
            {
                return $this->container->get(«name.formatForCodeCapital»BundleMetaData::class);
            }
            «IF needsInitializer»

                public function getInitializer(): BundleInitializerInterface
                {
                    return $this->container->get(«name.formatForCodeCapital»Initializer::class);
                }
            «ENDIF»
        }
    '''

    def private bundleImpl(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\Abstract«appName»;

        /**
         * Bundle implementation class.
         */
        class «appName» extends Abstract«appName»
        {
            // custom enhancements can go here
        }
    '''
}
