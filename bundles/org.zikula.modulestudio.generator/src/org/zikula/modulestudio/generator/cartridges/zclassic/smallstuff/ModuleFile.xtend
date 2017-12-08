package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleFile {

    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, appName + '.php',
            fh.phpFileContent(it, moduleBaseClass), fh.phpFileContent(it, moduleInfoImpl)
        )
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
            use Zikula\Bundle\CoreBundle\Bundle\AbstractCoreModule;
        «ELSE»
            use Zikula\Core\AbstractModule;
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
