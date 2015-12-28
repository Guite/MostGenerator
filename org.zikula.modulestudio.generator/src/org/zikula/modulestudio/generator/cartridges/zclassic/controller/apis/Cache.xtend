package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Cache {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) { // only generated for 1.3.x, because 1.4.x is migrated to Twig
            return
        }
        println('Generating cache api')
        generateClassPair(fsa, getAppSourceLibPath + 'Api/Cache' + (if (targets('1.3.x')) '' else 'Api') + '.php',
            fh.phpFileContent(it, cacheApiBaseClass), fh.phpFileContent(it, cacheApiImpl)
        )
    }

    def private cacheApiBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api\Base;

            use ModUtil;
            use UserUtil;
            use Zikula_AbstractBase;
            use Zikula_View;
            use Zikula_View_Theme;

        «ENDIF»
        /**
         * Cache api base class.
         */
        class «IF targets('1.3.x')»«appName»_Api_Base_Cache extends Zikula_AbstractApi«ELSE»CacheApi extends Zikula_AbstractBase«ENDIF»
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

            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«appName.formatForDB».controller_helper');
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

            $instanceId = $item->createCompositeIdentifier();
            «IF !targets('1.3.x')»

                $logger = $this->get('logger');
                $logger->info('{app}: User {user} caused clearing the cache for entity {entity} with id {id}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'entity' => $objectType, 'id' => $instanceId));
            «ENDIF»

            // Clear View_cache
            $cacheIds = array();
            «IF hasUserController»
                «IF getMainUserController.hasActions('index')»
                    $cacheIds[] = 'user_«IF targets('1.3.x')»main«ELSE»index«ENDIF»';
                «ENDIF»
                «IF getMainUserController.hasActions('custom')»
                    «FOR customAction : getMainUserController.actions.filter(CustomAction)»
                        $cacheIds[] = 'user_«customAction.name.formatForCode.toFirstLower»';
                    «ENDFOR»
                «ENDIF»
            «ENDIF»
            switch ($objectType) {
                «FOR entity : getAllEntities»
                    «entity.clearCache(it, 'view')»
                «ENDFOR»
            }

            $view = Zikula_View::getInstance('«appName»');
            foreach ($cacheIds as $cacheId) {
                $view->clear_cache(null, $cacheId);
            }


            // Clear Theme_cache
            $cacheIds = array();
            $cacheIds[] = 'homepage'; // for homepage (can be assigned in the Settings module)
            «IF hasUserController»
                «IF getMainUserController.hasActions('index')»
                    $cacheIds[] = '«appName»/user/«IF targets('1.3.x')»main«ELSE»index«ENDIF»'; // «IF targets('1.3.x')»main«ELSE»index«ENDIF» function
                «ENDIF»
                «IF getMainUserController.hasActions('custom')»
                    «FOR customAction : getMainUserController.actions.filter(CustomAction)»
                        $cacheIds[] = '«appName»/user/«customAction.name.formatForCode.toFirstLower»'; // «customAction.name.formatForDisplay» function
                    «ENDFOR»
                «ENDIF»
            «ENDIF»
            switch ($objectType) {
                «FOR entity : getAllEntities»
                    «entity.clearCache(it, 'theme')»
                «ENDFOR»
            }
            $theme = Zikula_View_Theme::getInstance();
            $theme->clear_cacheid_allthemes($cacheIds);
        }
    '''

    def private clearCache(Entity it, Application app, String cacheType) '''
        case '«name.formatForCode»':
            «IF cacheType == 'theme'»
                $cacheIdPrefix = '«app.appName»/' . $objectType . '/';
            «ENDIF»
            «IF hasActions('index')»
                «IF cacheType == 'view'»
                    $cacheIds[] = '«name.formatForCode»_«IF app.targets('1.3.x')»main«ELSE»index«ENDIF»';
                «ELSEIF cacheType == 'theme'»
                    $cacheIds[] = $cacheIdPrefix . '«IF app.targets('1.3.x')»main«ELSE»index«ENDIF»'; // «IF app.targets('1.3.x')»main«ELSE»index«ENDIF» function
                «ENDIF»
            «ENDIF»
            «IF hasActions('view')»
                «IF cacheType == 'view'»
                    $cacheIds[] = $objectType . '_view';
                «ELSEIF cacheType == 'theme'»
                    $cacheIds[] = $cacheIdPrefix . 'view/'; // view function (list views)
                «ENDIF»
            «ENDIF»
            «IF hasActions('display')»
                «IF cacheType == 'view'»
                    $cacheIds[] = $objectType . '_display|' . $instanceId;
                «ELSEIF cacheType == 'theme'»
                    $cacheIds[] = $cacheIdPrefix . 'display/' . $instanceId; // display function (detail views)
                «ENDIF»
            «ENDIF»
            «/* edit is not needed as Forms are not cached IF hasActions('edit')»
                «IF cacheType == 'view'»
                    $cacheIds[] = $objectType . '_edit|' . $instanceId;
                «ELSEIF cacheType == 'theme'»
                    $cacheIds[] = $cacheIdPrefix . 'edit/' . $instanceId; // edit function (forms)
                «ENDIF»
            «ENDIF*/»
            «/*delete is not needed as we disable caching there IF hasActions('delete')»
                «IF cacheType == 'view'»
                    $cacheIds[] = $objectType . '_delete|' . $instanceId;
                «ELSEIF cacheType == 'theme'»
                    $cacheIds[] = $cacheIdPrefix . 'delete/' . $instanceId; // delete function (forms)
                «ENDIF»
            «ENDIF*/»
            «IF hasActions('custom')»
                «FOR customAction : actions.filter(CustomAction)»
                    «IF cacheType == 'view'»
                        $cacheIds[] = $objectType . '|' . '«customAction.name.formatForCode.toFirstLower»';
                    «ELSEIF cacheType == 'theme'»
                        $cacheIds[] = $cacheIdPrefix . '«customAction.name.formatForCode.toFirstLower»'; // «customAction.name.formatForDisplay» function
                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            break;
    '''

    def private cacheApiImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api;

            use «appNamespace»\Api\Base\CacheApi as BaseCacheApi;

        «ENDIF»
        /**
         * Cache api implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Api_Cache extends «appName»_Api_Base_Cache
        «ELSE»
        class CacheApi extends BaseCacheApi
        «ENDIF»
        {
            // feel free to extend the cache api here
        }
    '''
}
