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
        for (entity: getAllEntities.filter[hasViewAction || hasDisplayAction]) {
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
            $info = [
                // module name
                'module'  => '«app.appName»',
                // possible needles
                'info'    => '«app.prefix.toUpperCase»{«IF hasViewAction»«nameMultiple.formatForCode.toUpperCase»«ENDIF»«IF hasDisplayAction»«IF hasViewAction»|«ENDIF»«name.formatForCode.toUpperCase»-«name.formatForCode»Id«ENDIF»}',
                // whether a reverse lookup is possible, needs «app.appName»_needleapi_«name.formatForDisplay»_inspect() function
                'inspect' => false
            ];

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
                $cache = [];
            }

            $container = \ServiceUtil::get('service_container');
            $translator = $container->get('translator.default');

            if (empty($nid)) {
                return '<em>' . \DataUtil::formatForDisplay(__('No correct needle id given.')) . '</em>';
            }

            if (isset($cache[$nid])) {
                // needle is already in cache array
                return $cache[$nid];
            }

            if (!$container->get('kernel')->isBundle('«app.appName»')) {
                $cache[$nid] = '<em>' . \DataUtil::formatForDisplay($translator->__f('Module %moduleName% is not available.', ['%moduleName%' => «app.appName»'])) . '</em>';

                return $cache[$nid];
            }

            // strip application prefix from needle
            $needleId = str_replace('«app.prefix.toUpperCase»', '', $nid);

            $router = $container->getService('router');

            «IF hasViewAction»
                if ($needleId == '«nameMultiple.formatForCode.toUpperCase»') {
                    if (!\SecurityUtil::checkPermission('«app.appName»:«name.formatForCodeCapital»:', '::', ACCESS_READ)) {
                        $cache[$nid] = '';

                        return $cache[$nid];
                    }
                }

                $cache[$nid] = '<a href="' . $router->generate('«app.appName.formatForDB»_«nameMultiple.formatForDB»_view') . '" title="' . $translator->__('View «nameMultiple.formatForDisplay»') . '">' . $translator->__('«nameMultiple.formatForDisplayCapital»') . '</a>';
            «ENDIF»
            «IF hasDisplayAction»
                $needleParts = explode('-', $needleId);
                if ($needleParts[0] != '«name.formatForCode.toUpperCase»' || count($needleParts) < 2) {
                    $cache[$nid] = '';

                    return $cache[$nid];
                }

                $permissionApi = $container->get('zikula_permissions_module.api.permission');
                $entityId = (int)$needleParts[1];

                if (!$permissionApi->hasPermission('«app.appName»:«name.formatForCodeCapital»:', $entityId . '::', ACCESS_READ)) {
                    $cache[$nid] = '';

                    return $cache[$nid];
                }

                $repository = $container->get('«app.appService».entity_factory')->getRepository('«name.formatForCode»');
                $entity = $repository->selectById($entityId);
                if (null === $entity) {
                    $cache[$nid] = '<em>' . $translator->__f('«name.formatForDisplayCapital» with id %id% could not be found', ['%id%' => $entityId]) . '</em>';

                    return $cache[$nid];
                }

                $title = $entity->getTitleFromDisplayPattern();
                $cache[$nid] = '<a href="' . $router->generate('«app.appName.formatForDB»_«nameMultiple.formatForDB»_display', ['id' => $entityId]) . '" title="' . str_replace('"', '', $title) . '">' . $title . '</a>';
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
            return «app.appName»_needleapi_«name.formatForDB»_base($args);
        }
    '''
}
