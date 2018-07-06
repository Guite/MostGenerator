package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MultiHook {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app

    def generate(Application it, IMostFileSystemAccess fsa) {
        app = it
        for (entity: getAllEntities.filter[hasViewAction || hasDisplayAction]) {
            entity.generateNeedle(fsa)
        }
    }

    def private generateNeedle(Entity it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Needles/' + name.formatForDB + '_info.php', needleBaseInfo, needleInfo)
        fsa.generateClassPair('Needles/' + name.formatForDB + '.php', needleBaseImpl, needleImpl)
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
        function «app.appName»_needleapi_«name.formatForDB»_base(array $args = [])
        {
            // Get arguments from argument array
            $nid = $args['nid'];
            unset($args);

            // cache the results
            static $cache;
            if (!isset($cache)) {
                $cache = [];
            }

            $container = \ServiceUtil::getManager();
            $translator = $container->get('translator.default');

            if (empty($nid)) {
                return '<em>' . htmlspecialchars($translator->__('No correct needle id given.')) . '</em>';
            }

            if (isset($cache[$nid])) {
                // needle is already in cache array
                return $cache[$nid];
            }

            if (!$container->get('kernel')->isBundle('«app.appName»')) {
                $cache[$nid] = '<em>' . htmlspecialchars($translator->__f('Module "%moduleName%" is not available.', ['%moduleName%' => '«app.appName»'])) . '</em>';

                return $cache[$nid];
            }

            // strip application prefix from needle
            $needleId = str_replace('«app.prefix.toUpperCase»', '', $nid);

            $permissionHelper = $this->container->get('«app.appService».permission_helper');
            $router = $container->getService('router');

            «IF hasViewAction»
                if ($needleId == '«nameMultiple.formatForCode.toUpperCase»') {
                    if (!$permissionHelper->hasComponentPermission('«name.formatForCode»', ACCESS_READ)) {
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

                $entityId = (int)$needleParts[1];

                $repository = $container->get('«app.appService».entity_factory')->getRepository('«name.formatForCode»');
                $entity = $repository->selectById($entityId, false);
                if (null === $entity) {
                    $cache[$nid] = '<em>' . $translator->__f('«name.formatForDisplayCapital» with id %id% could not be found', ['%id%' => $entityId]) . '</em>';

                    return $cache[$nid];
                }

                if (!$permissionHelper->mayRead($entity)) {
                    $cache[$nid] = '';

                    return $cache[$nid];
                }

                $title = $container->get('«app.appService».entity_display_helper')->getFormattedTitle($entity);
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
        function «app.appName»_needleapi_«name.formatForDB»(array $args = [])
        {
            return «app.appName»_needleapi_«name.formatForDB»_base($args);
        }
    '''
}
