package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BundleFile {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    Boolean needsInitializer = false

    def generate(Application it, IMostFileSystemAccess fsa) {
        needsInitializer = if (hasUploads || hasCategorisableEntities) true else false
        fsa.generateClassPair(appName + '.php', moduleBaseClass, moduleInfoImpl)
    }

    def private moduleBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        «moduleBaseImpl»
    '''

    def private moduleBaseImpl(Application it) '''
        use Zikula\Bundle\CoreBundle\AbstractModule;
        «IF needsInitializer»
            use Zikula\Bundle\CoreBundle\BundleInitializer\BundleInitializerInterface;
            use Zikula\Bundle\CoreBundle\BundleInitializer\InitializableBundleInterface;
            use «appNamespace»\Initializer\«name.formatForCodeCapital»Initializer;
        «ENDIF»

        /**
         * Bundle base class.
         */
        abstract class Abstract«appName» extends AbstractModule«IF needsInitializer» implements InitializableBundleInterface«ENDIF»
        {
            «IF needsInitializer»
                public function getInitializer(): BundleInitializerInterface
                {
                    return $this->container->get(«name.formatForCodeCapital»Initializer::class);
                }
            «ENDIF»
        }
    '''

    def private moduleInfoImpl(Application it) '''
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
