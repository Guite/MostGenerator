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
        if (app.targets('2.0')) {
            fsa.generateClassPair('Needle/' + name.formatForCodeCapital + 'Needle.php', needleBaseClass, needleImpl)
        } else {
            fsa.generateClassPair('Needles/' + name.formatForDB + '_info.php', needleBaseInfoLegacy, needleInfoLegacy)
            fsa.generateClassPair('Needles/' + name.formatForDB + '.php', needleBaseImplLegacy, needleImplLegacy)
        }
    }

    def private needleBaseInfoLegacy(Entity it) '''
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

    def private needleBaseImplLegacy(Entity it) '''
        use Symfony\Component\Routing\Generator\UrlGeneratorInterface;

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
                return $nid;
            }

            if (isset($cache[$nid])) {
                // needle is already in cache array
                return $cache[$nid];
            }

            if (!$container->get('kernel')->isBundle('«app.appName»')) {
                $cache[$nid] = '<em>' . htmlspecialchars($translator->__f('Module "%moduleName%" is not available.', ['%moduleName%' => '«app.appName»'], '«app.appName.formatForDB»')) . '</em>';

                return $cache[$nid];
            }

            // strip application prefix from needle
            $needleId = str_replace('«app.prefix.toUpperCase»', '', $nid);

            $permissionHelper = $this->container->get('«app.appService».permission_helper');
            $router = $container->getService('router');

            «IF hasViewAction»
                if ('«nameMultiple.formatForCode.toUpperCase»' == $needleId) {
                    if (!$permissionHelper->hasComponentPermission('«name.formatForCode»', ACCESS_READ)) {
                        $cache[$nid] = '';
                    } else {
                        $cache[$nid] = '<a href="' . $router->generate('«app.appName.formatForDB»_«name.formatForDB»_view', [], UrlGeneratorInterface::ABSOLUTE_URL) . '" title="' . $translator->__('View «nameMultiple.formatForDisplay»', '«app.appName.formatForDB»') . '">' . $translator->__('«nameMultiple.formatForDisplayCapital»', '«app.appName.formatForDB»') . '</a>';
                    }

                    return $cache[$nid];
                }

            «ENDIF»
            «IF hasDisplayAction»
                $needleParts = explode('-', $needleId);
                if ('«name.formatForCode.toUpperCase»' != $needleParts[0] || count($needleParts) < 2) {
                    $cache[$nid] = '';

                    return $cache[$nid];
                }

                $entityId = (int)$needleParts[1];

                $repository = $container->get('«app.appService».entity_factory')->getRepository('«name.formatForCode»');
                $entity = $repository->selectById($entityId, false);
                if (null === $entity) {
                    $cache[$nid] = '<em>' . $translator->__f('«name.formatForDisplayCapital» with id %id% could not be found', ['%id%' => $entityId], '«app.appName.formatForDB»') . '</em>';

                    return $cache[$nid];
                }

                if (!$permissionHelper->mayRead($entity)) {
                    $cache[$nid] = '';

                    return $cache[$nid];
                }

                $title = $container->get('«app.appService».entity_display_helper')->getFormattedTitle($entity);
                $cache[$nid] = '<a href="' . $router->generate('«app.appName.formatForDB»_«name.formatForDB»_display', $entity->createUrlArgs(), UrlGeneratorInterface::ABSOLUTE_URL) . '" title="' . str_replace('"', '', $title) . '">' . $title . '</a>';
            «ENDIF»

            return $cache[$nid];
        }
    '''

    def private needleInfoLegacy(Entity it) '''
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

    def private needleImplLegacy(Entity it) '''
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

    def private needleBaseClass(Entity it) '''
        namespace «app.appNamespace»\Needle\Base;

        use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
        use Symfony\Component\Routing\RouterInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        «IF hasDisplayAction»
            use «app.appNamespace»\Entity\Factory\EntityFactory;
            use «app.appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        use «app.appNamespace»\Helper\PermissionHelper;

        /**
         * «name.formatForCodeCapital»Needle base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Needle
        {
            «needleBaseImpl»
        }
    '''

    def private needleBaseImpl(Entity it) '''
        /**
         * Translator instance
         *
         * @var TranslatorInterface
         */
        protected $translator;

        /**
         * @var RouterInterface
         */
        protected $router;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;

        «IF hasDisplayAction»
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var EntityDisplayHelper
             */
            protected $entityDisplayHelper;

        «ENDIF»
        /**
         * Bundle name
         *
         * @var string
         */
        protected $bundleName;

        /**
         * The name of this needle
         *
         * @var string
         */
        protected $name;

        /**
         * «name.formatForCodeCapital»Needle constructor.
         *
         * @param TranslatorInterface $translator
         * @param RouterInterface $router
         * @param PermissionHelper $permissionHelper
        «IF hasDisplayAction»
         * @param EntityFactory $entityFactory
         * @param EntityDisplayHelper $entityDisplayHelper
        «ENDIF»
         */
        public function __construct(
            TranslatorInterface $translator,
            RouterInterface $router,
            PermissionHelper $permissionHelper«IF hasDisplayAction»,
            EntityFactory $entityFactory,
            EntityDisplayHelper $entityDisplayHelper«ENDIF»
        ) {
            $this->translator = $translator;
            $this->router = $router;
            $this->permissionHelper = $permissionHelper;
            «IF hasDisplayAction»
                $this->entityFactory = $entityFactory;
                $this->entityDisplayHelper = $entityDisplayHelper;
            «ENDIF»

            $nsParts = explode('\\', get_class($this));
            $vendor = $nsParts[0];
            $nameAndType = $nsParts[1];

            $this->bundleName = $vendor . $nameAndType;
            $this->name = str_replace('Needle', '', array_pop($nsParts));
        }

        /**
         * Returns the bundle name.
         *
         * @return string
         */
        public function getBundleName()
        {
            return $this->bundleName;
        }

        /**
         * Returns the name of this needle.
         *
         * @return string
         */
        public function getName()
        {
            return $this->name;
        }

        /**
         * Returns the icon name (FontAwesome icon code suffix, e.g. "pencil").
         *
         * @return string
         */
        public function getIcon()
        {
            return 'circle-o';
        }

        /**
         * Returns the title of this needle.
         *
         * @return string
         */
        public function getTitle()
        {
            return $this->translator->__('«nameMultiple.formatForDisplayCapital»', '«app.appName.formatForDB»');
        }

        /**
         * Returns the description of this needle.
         *
         * @return string
         */
        public function getDescription()
        {
            return $this->translator->__('Links to «IF hasViewAction»the list of «nameMultiple.formatForDisplay»«ENDIF»«IF hasDisplayAction»«IF hasViewAction» and «ENDIF»specific «nameMultiple.formatForDisplay»«ENDIF».', '«app.appName.formatForDB»');
        }

        /**
         * Returns usage information shown on settings page.
         *
         * @return string
         */
        public function getUsageInfo()
        {
            return '«app.prefix.toUpperCase»{«IF hasViewAction»«nameMultiple.formatForCode.toUpperCase»«ENDIF»«IF hasDisplayAction»«IF hasViewAction»|«ENDIF»«name.formatForCode.toUpperCase»-«name.formatForCode»Id«ENDIF»}';
        }

        /**
         * Returns whether this needle is active or not.
         *
         * @return boolean
         */
        public function isActive()
        {
            return true;
        }

        /**
         * Returns whether this needle is case sensitive or not.
         *
         * @return boolean
         */
        public function isCaseSensitive()
        {
            return true;
        }

        /**
         * Returns the needle subject entries.
         *
         * @return string[]
         */
        public function getSubjects()
        {
            return [«IF hasViewAction»'«app.prefix.toUpperCase»«nameMultiple.formatForCode.toUpperCase»'«ENDIF»«IF hasDisplayAction»«IF hasViewAction», «ENDIF»'«app.prefix.toUpperCase»«name.formatForCode.toUpperCase»-'«ENDIF»];
        }

        /**
         * Applies the needle functionality.
         *
         * @param string $needleId
         * @param string $needleText
         *
         * @return string Replaced value for the needle
         */
        public function apply($needleId, $needleText)
        {
            // cache the results
            static $cache;
            if (!isset($cache)) {
                $cache = [];
            }

            if (isset($cache[$needleId])) {
                // needle is already in cache array
                return $cache[$needleId];
            }

            // strip application prefix from needle
            $needleText = str_replace('«app.prefix.toUpperCase»', '', $needleText);

            «IF hasViewAction»
                if ('«nameMultiple.formatForCode.toUpperCase»' == $needleText) {
                    if (!$this->permissionHelper->hasComponentPermission('«name.formatForCode»', ACCESS_READ)) {
                        $cache[$needleId] = '';
                    } else {
                        $cache[$needleId] = '<a href="' . $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_view', [], UrlGeneratorInterface::ABSOLUTE_URL) . '" title="' . $this->translator->__('View «nameMultiple.formatForDisplay»', '«app.appName.formatForDB»') . '">' . $this->translator->__('«nameMultiple.formatForDisplayCapital»', '«app.appName.formatForDB»') . '</a>';
                    }

                    return $cache[$needleId];
                }

            «ENDIF»
            «IF hasDisplayAction»
                $entityId = intval($needleId);
                if (!$entityId) {
                    $cache[$needleId] = '';

                    return $cache[$needleId];
                }

                $repository = $this->entityFactory->getRepository('«name.formatForCode»');
                $entity = $repository->selectById($entityId, false);
                if (null === $entity) {
                    $cache[$needleId] = '<em>' . $this->translator->__f('«name.formatForDisplayCapital» with id %id% could not be found', ['%id%' => $entityId], '«app.appName.formatForDB»') . '</em>';

                    return $cache[$needleId];
                }

                if (!$this->permissionHelper->mayRead($entity)) {
                    $cache[$needleId] = '';

                    return $cache[$needleId];
                }

                $title = $this->entityDisplayHelper->getFormattedTitle($entity);
                $cache[$needleId] = '<a href="' . $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_display', $entity->createUrlArgs(), UrlGeneratorInterface::ABSOLUTE_URL) . '" title="' . str_replace('"', '', $title) . '">' . $title . '</a>';
            «ENDIF»

            return $cache[$needleId];
        }
    '''

    def private needleImpl(Entity it) '''
        namespace «app.appNamespace»\Needle;

        use «app.appNamespace»\Needle\Base\Abstract«name.formatForCodeCapital»Needle;

        /**
         * «name.formatForCodeCapital»Needle implementation class.
         */
        class «name.formatForCodeCapital»Needle extends Abstract«name.formatForCodeCapital»Needle
        {
            // feel free to extend the needle here
        }
    '''
}
