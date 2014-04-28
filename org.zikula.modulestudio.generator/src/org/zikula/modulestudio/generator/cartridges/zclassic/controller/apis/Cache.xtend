package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.CustomAction
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Cache {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating cache api')
        generateClassPair(fsa, getAppSourceLibPath + 'Api/Cache' + (if (targets('1.3.5')) '' else 'Api') + '.php',
            fh.phpFileContent(it, cacheApiBaseClass), fh.phpFileContent(it, cacheApiImpl)
        )
    }

    def private cacheApiBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Api\Base;

            use ModUtil;
            use Zikula_AbstractApi;
            use Zikula_View;
            use Zikula_View_Theme;
        «ENDIF»
        /**
         * Cache api base class.
         */
        class «IF targets('1.3.5')»«appName»_Api_Base_Cache«ELSE»CacheApi«ENDIF» extends Zikula_AbstractApi
        {
            «cacheApiBaseImpl»
        }
    '''

    def private cacheApiBaseImpl(Application it) '''
        /**
         * Clear cache for given item. Can be called from other modules to clear an item cache.
         *
         * @param $args['ot']   the treated object type
         * @param $args['item'] the actual object
         */
        public function clearItemCache(array $args = array())
        {
            if (!isset($args['ot']) || !isset($args['item'])) {
                return;
            }

            $objectType = $args['ot'];
            $item = $args['item'];

            «IF targets('1.3.5')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->serviceManager->get('«appName.formatForDB».controller_helper');
            «ENDIF»
            $utilArgs = array('api' => 'cache', 'action' => 'clearItemCache');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
                return;
            }

            if ($item && !is_array($item) && !is_object($item)) {
                $item = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $item, 'useJoins' => false, 'slimMode' => true));
            }

            if (!$item) {
                return;
            }

            «IF hasUserController && getMainUserController.hasActions('display')»
                // create full identifier (considering composite keys)
                $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));
                $instanceId = '';
                foreach ($idFields as $idField) {
                    if (!empty($instanceId)) {
                        $instanceId .= '_';
                    }
                    $instanceId .= $item[$idField];
                }

            «ENDIF»

            // Clear View_cache
            $cacheIds = array();
            «IF hasUserController»
            «IF getMainUserController.hasActions('index')»
                $cacheIds[] = '«IF targets('1.3.5')»main«ELSE»index«ENDIF»';
            «ENDIF»
            «IF getMainUserController.hasActions('view')»
                $cacheIds[] = 'view';
            «ENDIF»
            «IF getMainUserController.hasActions('display')»
                $cacheIds[] = $instanceId;
            «ENDIF»
            «/* edit is not needed as Forms are not cached IF getMainUserController.hasActions('edit')»
                $cacheIds[] = 'edit';
            «ENDIF*/»
            «/*delete is not needed as we disable caching there IF getMainUserController.hasActions('delete')»
                $cacheIds[] = 'delete';
            «ENDIF*/»
            «IF getMainUserController.hasActions('custom')»
                «FOR customAction : getMainUserController.actions.filter(CustomAction)»
                    $cacheIds[] = '«customAction.name.formatForCode.toFirstLower»';
                «ENDFOR»
            «ENDIF»
            «ENDIF»

            $view = Zikula_View::getInstance('«appName»');
            foreach ($cacheIds as $cacheId) {
                $view->clear_cache(null, $cacheId);
            }


            // Clear Theme_cache
            $cacheIds = array();
            $cacheIds[] = 'homepage'; // for homepage (can be assigned in the Settings module)
            «IF hasUserController»
            «IF getMainUserController.hasActions('index')»
                $cacheIds[] = '«appName»/user/«IF targets('1.3.5')»main«ELSE»index«ENDIF»'; // «IF targets('1.3.5')»main«ELSE»index«ENDIF» function
            «ENDIF»
            «IF getMainUserController.hasActions('view')»
                $cacheIds[] = '«appName»/user/view/' . $objectType; // view function (list views)
            «ENDIF»
            «IF getMainUserController.hasActions('display')»
                $cacheIds[] = '«appName»/user/display/' . $objectType . '|' . $instanceId; // display function (detail views)
            «ENDIF»
            «/* edit is not needed as Forms are not cached IF getMainUserController.hasActions('edit')»
                $cacheIds[] = '«appName»/user/edit/' . $objectType; // edit function (forms)
            «ENDIF*/»
            «/*delete is not needed as we disable caching there IF getMainUserController.hasActions('delete')»
                $cacheIds[] = '«appName»/user/delete/' . $objectType; // delete function (forms)
            «ENDIF*/»
            «IF getMainUserController.hasActions('custom')»
                «FOR customAction : getMainUserController.actions.filter(CustomAction)»
                    $cacheIds[] = '«appName»/user/«customAction.name.formatForCode.toFirstLower»'; // «customAction.name.formatForDisplay» function
                «ENDFOR»
            «ENDIF»
            «ENDIF»
            $theme = Zikula_View_Theme::getInstance();
            $theme->clear_cacheid_allthemes($cacheIds);
        }
    '''

    def private cacheApiImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Api;

            use «appNamespace»\Api\Base\CacheApi as BaseCacheApi;

        «ENDIF»
        /**
         * Cache api implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Api_Cache extends «appName»_Api_Base_Cache
        «ELSE»
        class CacheApi extends BaseCacheApi
        «ENDIF»
        {
            // feel free to extend the cache api here
        }
    '''
}
