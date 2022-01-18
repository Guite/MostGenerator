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
        fsa.generateClassPair('Needle/' + name.formatForCodeCapital + 'Needle.php', needleBaseClass, needleImpl)
    }

    def private needleBaseClass(Entity it) '''
        namespace «app.appNamespace»\Needle\Base;

        use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
        use Symfony\Component\Routing\RouterInterface;
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\ExtensionsModule\ModuleInterface\MultiHook\NeedleInterface;
        «IF hasDisplayAction»
            use «app.appNamespace»\Entity\Factory\EntityFactory;
            use «app.appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        use «app.appNamespace»\Helper\PermissionHelper;

        /**
         * «name.formatForCodeCapital»Needle base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Needle implements NeedleInterface
        {
            «needleBaseImpl»
        }
    '''

    def private needleBaseImpl(Entity it) '''
        protected string $bundleName;

        /**
         * The name of this needle.
         */
        protected string $name;

        public function __construct(
            protected TranslatorInterface $translator,
            protected RouterInterface $router,
            protected PermissionHelper $permissionHelper«IF hasDisplayAction»,
            protected EntityFactory $entityFactory,
            protected EntityDisplayHelper $entityDisplayHelper«ENDIF»
        ) {
            $nsParts = explode('\\', static::class);
            $vendor = $nsParts[0];
            $nameAndType = $nsParts[1];

            $this->bundleName = $vendor . $nameAndType;
            $this->name = str_replace('Needle', '', array_pop($nsParts));
        }

        public function getName(): string
        {
            return $this->name;
        }

        public function getIcon(): string
        {
            return 'circle-o';
        }

        public function getTitle(): string
        {
            return $this->translator->trans('«nameMultiple.formatForDisplayCapital»', [], '«name.formatForCode»');
        }

        public function getDescription(): string
        {
            return $this->translator->trans('Links to «IF hasViewAction»the list of «nameMultiple.formatForDisplay»«ENDIF»«IF hasDisplayAction»«IF hasViewAction» and «ENDIF»specific «nameMultiple.formatForDisplay»«ENDIF».', [], '«name.formatForCode»');
        }

        public function getUsageInfo(): string
        {
            return '«app.prefix.toUpperCase»{«IF hasViewAction»«nameMultiple.formatForCode.toUpperCase»«ENDIF»«IF hasDisplayAction»«IF hasViewAction»|«ENDIF»«name.formatForCode.toUpperCase»-«name.formatForCode»Id«ENDIF»}';
        }

        public function isActive(): bool
        {
            return true;
        }

        public function isCaseSensitive(): bool
        {
            return true;
        }

        public function getSubjects(): array
        {
            return [«IF hasViewAction»'«app.prefix.toUpperCase»«nameMultiple.formatForCode.toUpperCase»'«ENDIF»«IF hasDisplayAction»«IF hasViewAction», «ENDIF»'«app.prefix.toUpperCase»«name.formatForCode.toUpperCase»-'«ENDIF»];
        }

        /**
         * Applies the needle functionality.
         */
        public function apply(string $needleId, string $needleText): string
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
                if ('«nameMultiple.formatForCode.toUpperCase»' === $needleText) {
                    if (!$this->permissionHelper->hasComponentPermission('«name.formatForCode»', ACCESS_READ)) {
                        $cache[$needleId] = '';
                    } else {
                        $route = $this->router->generate(
                            '«app.appName.formatForDB»_«name.formatForDB»_view',
                            [],
                            UrlGeneratorInterface::ABSOLUTE_URL
                        );
                        $linkTitle = $this->translator->trans('View «nameMultiple.formatForDisplay»', [], '«name.formatForCode»');
                        $linkText = $this->translator->trans('«nameMultiple.formatForDisplayCapital»', [], '«name.formatForCode»');
                        $cache[$needleId] = '<a href="' . $route . '" title="' . $linkTitle . '">' . $linkText . '</a>';
                    }

                    return $cache[$needleId];
                }

            «ENDIF»
            «IF hasDisplayAction»
                $entityId = (int) $needleId;
                if (!$entityId) {
                    $cache[$needleId] = '';

                    return $cache[$needleId];
                }

                $repository = $this->entityFactory->getRepository('«name.formatForCode»');
                $entity = $repository->selectById($entityId, false);
                if (null === $entity) {
                    $notFoundMessage = $this->translator->trans(
                        '«name.formatForDisplayCapital» with id %id% could not be found',
                        ['%id%' => $entityId],
                        '«name.formatForCode»'
                    );
                    $cache[$needleId] = '<em>' . $notFoundMessage . '</em>';

                    return $cache[$needleId];
                }

                if (!$this->permissionHelper->mayRead($entity)) {
                    $cache[$needleId] = '';

                    return $cache[$needleId];
                }

                $title = $this->entityDisplayHelper->getFormattedTitle($entity);
                $route = $this->router->generate(
                    '«app.appName.formatForDB»_«name.formatForDB»_display',
                    $entity->createUrlArgs(),
                    UrlGeneratorInterface::ABSOLUTE_URL
                );
                $cache[$needleId] = '<a href="' . $route . '" title="' . str_replace('"', '', $title) . '">' . $title . '</a>';
            «ENDIF»

            return $cache[$needleId];
        }

        public function getBundleName(): string
        {
            return $this->bundleName;
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
