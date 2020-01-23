package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleFile {

    extension ControllerExtensions = new ControllerExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair(appName + '.php', moduleBaseClass, moduleInfoImpl)
    }

    def private moduleBaseClass(Application it) '''
        «IF (generateListContentType || (generateDetailContentType && hasDisplayActions)) && !targets('2.0')»
            namespace «appNamespace»\Base {

                «moduleBaseImpl»
            }

            namespace {

                if (!class_exists('Content_AbstractContentType')) {
                    if (file_exists('modules/Content/lib/Content/AbstractContentType.php')) {
                        require_once 'modules/Content/lib/Content/AbstractType.php';
                        require_once 'modules/Content/lib/Content/AbstractContentType.php';
                    } else {
                        class Content_AbstractContentType {}
                    }
                }

                «IF generateListContentType»
                    class «appName»_ContentType_ItemList extends \«appNamespace»\ContentType\ItemList {
                    }
                «ENDIF»
                «IF generateDetailContentType && hasDisplayActions»
                    class «appName»_ContentType_Item extends \«appNamespace»\ContentType\Item {
                    }
                «ENDIF»
            }
        «ELSE»
            namespace «appNamespace»\Base;

            «moduleBaseImpl»
        «ENDIF»
    '''

    def private moduleBaseImpl(Application it) '''
        «IF isSystemModule»
            «IF targets('3.0')»
                use Zikula\ExtensionsModule\AbstractCoreModule;
            «ELSE»
                use Zikula\Bundle\CoreBundle\Bundle\AbstractCoreModule;
            «ENDIF»
        «ELSE»
            «IF targets('3.0')»
                use Zikula\ExtensionsModule\AbstractModule;
            «ELSE»
                use Zikula\Core\AbstractModule;
            «ENDIF»
        «ENDIF»

        /**
         * Module base class.
         */
        abstract class Abstract«appName» extends Abstract«IF isSystemModule»Core«ENDIF»Module
        {
        }
    '''

    def private moduleInfoImpl(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\Abstract«appName»;

        /**
         * Module implementation class.
         */
        class «appName» extends Abstract«appName»
        {
            // custom enhancements can go here
        }
    '''
}
