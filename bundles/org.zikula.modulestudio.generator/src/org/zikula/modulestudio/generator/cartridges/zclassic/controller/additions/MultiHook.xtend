package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MultiHook {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app

    def generate(Application it, IFileSystemAccess fsa) {
        app = it
        for (entity: getAllEntities.filter[e|e.hasActions('view') || e.hasActions('display')]) {
            entity.generateNeedle(fsa)
        }
    }

    def private generateNeedle(Entity it, IFileSystemAccess fsa) {
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Needles/' + name.formatForDB + '_info.php',
            fh.phpFileContent(app, needleBaseInfo), fh.phpFileContent(app, needleInfo)
        )
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Needles/' + name.formatForDB + '.php',
            fh.phpFileContent(app, needleBaseImpl), fh.phpFileContent(app, needleImpl)
        )
    }

    def private needleBaseInfo(Entity it) '''
        /**
         * «app.appName» «name.formatForDisplay» needle information.
         *
         * @param none
         *
         * @return string with short usage description
         */
        function «app.appName»_needleapi_«name.formatForDB»_baseInfo()
        {
            $info = «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                // module name
                'module'  => '«app.appName»',
                // possible needles
                'info'    => '«app.prefix.toUpperCase»{«IF hasActions('view')»«nameMultiple.formatForCode.toUpperCase»«ENDIF»«IF hasActions('display')»«IF hasActions('view')»|«ENDIF»«name.formatForCode.toUpperCase»-«name.formatForCode»Id«ENDIF»}',
                // whether a reverse lookup is possible, needs «app.appName»_needleapi_«name.formatForDisplay»_inspect() function
                'inspect' => false
            «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;

            return $info;
        }
    '''

    def private needleBaseImpl(Entity it) '''
        /**
         * Replaces a given needle id by the corresponding content.
         *
         * @param array $args Arguments array
         *     int nid The needle id
         *
         * @return string Replaced value for the needle
         */
        function «app.appName»_needleapi_«name.formatForDB»_base($args)
        {
            // Get arguments from argument array
            $nid = $args['nid'];
            unset($args);

            // cache the results
            static $cache;
            if (!isset($cache)) {
                $cache = array();
            }

            $dom = \ZLanguage::getModuleDomain('«app.appName»');

            if (empty($nid)) {
                return '<em>' . \DataUtil::formatForDisplay(__('No correct needle id given.', $dom)) . '</em>';
            }

            if (isset($cache[$nid])) {
                // needle is already in cache array
                return $cache[$nid];
            }

            if (!\ModUtil::available('«app.appName»')) {
                $cache[$nid] = '<em>' . \DataUtil::formatForDisplay(__f('Module %s is not available.', array('«app.appName»'), $dom)) . '</em>';

                return $cache[$nid];
            }

            // strip application prefix from needle
            $needleId = str_replace('«app.prefix.toUpperCase»', '', $nid);

            «IF !app.targets('1.3.x')»
                $router = \ServiceUtil::getService('router');

            «ENDIF»
            «IF hasActions('view')»
                if ($needleId == '«nameMultiple.formatForCode.toUpperCase»') {
                    if (!\SecurityUtil::checkPermission('«app.appName»:«name.formatForCodeCapital»:', '::', ACCESS_READ)) {
                        $cache[$nid] = '';

                        return $cache[$nid];
                    }
                }

                «IF app.targets('1.3.x')»
                    $cache[$nid] = '<a href="' . ModUtil::url('«app.appName»', '«name.formatForCode»', 'view') . '" title="' . __('View «nameMultiple.formatForDisplay»', $dom) . '">' . __('«nameMultiple.formatForDisplayCapital»', $dom) . '</a>';
                «ELSE»
                    $cache[$nid] = '<a href="' . $router->generate('«app.appName.formatForDB»_«nameMultiple.formatForDB»_view') . '" title="' . __('View «nameMultiple.formatForDisplay»', $dom) . '">' . __('«nameMultiple.formatForDisplayCapital»', $dom) . '</a>';
                «ENDIF»
            «ENDIF»
            «IF hasActions('display')»
                $needleParts = explode('-', $needleId);
                if ($needleParts[0] != '«name.formatForCode.toUpperCase»' || count($needleParts) < 2) {
                    $cache[$nid] = '';

                    return $cache[$nid];
                }

                «IF !app.targets('1.3.x')»
                    $permissionApi = \ServiceUtil::get('zikula_permissions_module.api.permission');
                «ENDIF»
                $entityId = (int)$needleParts[1];

                if (!«IF app.targets('1.3.x')»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission('«app.appName»:«name.formatForCodeCapital»:', $entityId . '::', ACCESS_READ)) {
                    $cache[$nid] = '';

                    return $cache[$nid];
                }

                «IF app.targets('1.3.x')»
                    $entity = \ModUtil::apiFunc('«app.appName»', 'selection', 'getEntity', array('ot' => '«name.formatForCode»', 'id' => $entityId));
                «ELSE»
                    $selectionHelper = \ServiceUtil::get('«app.appService».selection_helper');
                    $entity = $selectionHelper->getEntity('«name.formatForCode»', $entityId);
                «ENDIF»
                if (null === $entity) {
                    $cache[$nid] = '<em>' . __f('«name.formatForDisplayCapital» with id %s could not be found', «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»$entityId«IF app.targets('1.3.x')»)«ELSE»]«ENDIF», $dom) . '</em>';

                    return $cache[$nid];
                }

                $title = $entity->getTitleFromDisplayPattern();

                «IF app.targets('1.3.x')»
                    $cache[$nid] = '<a href="' . ModUtil::url('«app.appName»', '«name.formatForCode»', 'display', array('id' => $entityId)) . '" title="' . str_replace('"', '', $title) . '">' . $title . '</a>';
                «ELSE»
                    $cache[$nid] = '<a href="' . $router->generate('«app.appName.formatForDB»_«nameMultiple.formatForDB»_display', ['id' => $entityId]) . '" title="' . str_replace('"', '', $title) . '">' . $title . '</a>';
                «ENDIF»
            «ENDIF»

            return $cache[$nid];
        }
    '''

    def private needleInfo(Entity it) '''
        include_once 'Needles/Base/Abstract«name.formatForDB»_info.php';

        /**
         * «app.appName» «name.formatForDisplay» needle information.
         *
         * @param none
         *
         * @return string with short usage description
         */
        function «app.appName»_needleapi_«name.formatForDB»_info()
        {
            return «app.appName»_needleapi_«name.formatForDB»_baseInfo();
        }
    '''

    def private needleImpl(Entity it) '''
        include_once 'Needles/Base/Abstract«name.formatForDB».php';

        /**
         * Replaces a given needle id by the corresponding content.
         *
         * @param array $args Arguments array
         *     int nid The needle id
         *
         * @return string Replaced value for the needle
         */
        function «app.appName»_needleapi_«name.formatForDB»($args)
        {
            return «app.appName»_needleapi_«name.formatForDB»_base($args)
        }
    '''
}
