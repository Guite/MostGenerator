package org.zikula.modulestudio.generator.cartridges.symfony.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.FormatGeoData
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.GetFileSize
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.GetListEntry
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.ObjectState
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.TreeData
import org.zikula.modulestudio.generator.cartridges.symfony.view.plugin.TreeSelection
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Plugins {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating Twig extension class'.printIfNotTesting(fsa)
        val twigFolder = 'Twig'
        fsa.generateClassPair(twigFolder + '/TwigExtension.php', twigExtensionBaseImpl, twigExtensionImpl)
        fsa.generateClassPair(twigFolder + '/TwigRuntime.php', twigRuntimeBaseImpl, twigRuntimeImpl)
    }

    def private collectExtensionBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Twig\\Extension\\AbstractExtension',
            'Twig\\TwigFilter',
            'Twig\\TwigFunction',
            appNamespace + '\\Twig\\TwigRuntime'
        ])
        if (hasLoggable) {
            imports.add('Twig\\TwigTest')
        }
        imports
    }

    def private twigExtensionBaseImpl(Application it) '''
        namespace «appNamespace»\Twig\Base;

        «collectExtensionBaseImports.print»

        /**
         * Twig extension base class.
         */
        abstract class AbstractTwigExtension extends AbstractExtension
        {
            «twigExtensionBody»
        }
    '''

    def private collectRuntimeBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            'Twig\\Extension\\RuntimeExtensionInterface',
            appNamespace + '\\Entity\\EntityInterface',
            appNamespace + '\\Helper\\EntityDisplayHelper',
            appNamespace + '\\Helper\\WorkflowHelper'
        ])
        if (!entities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty) {
            imports.add('DateInterval')
        }
        if (hasLoggable) {
            imports.addAll(#[
                'Gedmo\\Loggable\\Entity\\MappedSuperclass\\AbstractLogEntry',
                appNamespace + '\\Helper\\LoggableHelper'
            ])
        }
        if (hasTrees) {
            imports.addAll(#[
                'Knp\\Menu\\Matcher\\Matcher',
                'Knp\\Menu\\Renderer\\ListRenderer',
                'Symfony\\Component\\Routing\\RouterInterface',
                appNamespace + '\\Entity\\Factory\\EntityFactory',
                appNamespace + '\\Menu\\MenuBuilder'
            ])
        }
        if (hasListFields) {
            imports.add(appNamespace + '\\Helper\\ListEntriesHelper')
        }
        if (hasUploads) {
            imports.add('Symfony\\Component\\DependencyInjection\\Attribute\\Autowire')
        }
        imports
    }

    def private twigRuntimeBaseImpl(Application it) '''
        namespace «appNamespace»\Twig\Base;

        «collectRuntimeBaseImports.print»

        /**
         * Twig runtime base class.
         */
        abstract class AbstractTwigRuntime implements RuntimeExtensionInterface
        {
            «twigRuntimeBody»
        }
    '''

    def private twigExtensionBody(Application it) '''
        «val appNameLower = appName.toLowerCase»
        public function getFunctions()
        {
            return [
                «IF hasTrees»
                    new TwigFunction('«appNameLower»_treeData', [TwigRuntime::class, 'getTreeData'], ['is_safe' => ['html']]),
                    new TwigFunction('«appNameLower»_treeSelection', [TwigRuntime::class, 'getTreeSelection']),
                «ENDIF»
            ];
        }

        public function getFilters()
        {
            return [
                «IF !entities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty»
                    new TwigFilter('«appNameLower»_dateInterval', [TwigRuntime::class, 'getFormattedDateInterval']),
                «ENDIF»
                «IF hasUploads»
                    new TwigFilter('«appNameLower»_fileSize', [TwigRuntime::class, 'getFileSize'], ['is_safe' => ['html']]),
                    new TwigFilter('«appNameLower»_relativePath', [TwigRuntime::class, 'getRelativePath']),
                «ENDIF»
                «IF hasListFields»
                    new TwigFilter('«appNameLower»_listEntry', [TwigRuntime::class, 'getListEntry']),
                «ENDIF»
                «IF hasGeographical»
                    new TwigFilter('«appNameLower»_geoData', [TwigRuntime::class, 'formatGeoData']),
                «ENDIF»
                «IF hasLoggable»
                    new TwigFilter('«appNameLower»_logDescription', [TwigRuntime::class, 'getLogDescription']),
                «ENDIF»
                new TwigFilter('«appNameLower»_formattedTitle', [TwigRuntime::class, 'getFormattedEntityTitle']),
                new TwigFilter('«appNameLower»_objectState', [TwigRuntime::class, 'getObjectState'], ['is_safe' => ['html']]),
            ];
        }
        «IF hasLoggable»

            public function getTests()
            {
                return [
                    new TwigTest('«appNameLower»_instanceOf', static function ($var, $instance) {
                        return $var instanceof $instance;
                    }),
                ];
            }
        «ENDIF»
    '''

    def private twigRuntimeBody(Application it) '''
        public function __construct(
            protected readonly TranslatorInterface $translator«IF hasTrees»,
            protected readonly RouterInterface $router«ENDIF»,
            «IF hasTrees»
                protected readonly EntityFactory $entityFactory,
            «ENDIF»
            protected readonly EntityDisplayHelper $entityDisplayHelper,
            protected readonly WorkflowHelper $workflowHelper«IF hasListFields»,
            protected readonly ListEntriesHelper $listHelper«ENDIF»«IF hasLoggable»,
            protected readonly LoggableHelper $loggableHelper«ENDIF»«IF hasTrees»,
            protected readonly MenuBuilder $menuBuilder«ENDIF»«IF hasUploads»,
            #[Autowire(param: 'kernel.project_dir')]
            protected readonly string $projectDir«ENDIF»
        ) {
        }

        «viewPlugins»
        «IF !entities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty»

            /**
             * The «appName.formatForDB»_dateInterval filter outputs a formatted description for a given date interval (duration string).
             * Example:
             *     {{ myDateIntervalString|«appName.formatForDB»_dateInterval }}
             *
             * @see http://php.net/manual/en/dateinterval.format.php
             */
            public function getFormattedDateInterval(string $duration): string
            {
                $interval = new DateInterval($duration);

                $description = 1 === $interval->invert ? '- ' : '';

                $amount = $interval->y;
                if (0 < $amount) {
                    $description .= $this->translator->trans('%count% year|%count% years', ['%count%' => $amount]);
                }

                $amount = $interval->m;
                if (0 < $amount) {
                    $description .= ', ' . $this->translator->trans('%count% month|%count% months', ['%count%' => $amount]);
                }

                $amount = $interval->d;
                if (0 < $amount) {
                    $description .= ', ' . $this->translator->trans('%count% day|%count% days', ['%count%' => $amount]);
                }

                $amount = $interval->h;
                if (0 < $amount) {
                    $description .= ', ' . $this->translator->trans('%count% hour|%count% hours', ['%count%' => $amount]);
                }

                $amount = $interval->i;
                if (0 < $amount) {
                    $description .= ', ' . $this->translator->trans('%count% minute|%count% minutes', ['%count%' => $amount]);
                }

                $amount = $interval->s;
                if (0 < $amount) {
                    $description .= ', ' . $this->translator->trans('%count% second|%count% seconds', ['%count%' => $amount]);
                }

                return $description;
            }
        «ENDIF»
        «IF hasUploads»

            /**
             * The «appName.formatForDB»_relativePath filter returns the relative web path to a file.
             * Example:
             *     {{ myPerson.image.getPathname()|«appName.formatForDB»_relativePath }}.
             */
            public function getRelativePath(string $absolutePath): string
            {
                return str_replace($this->projectDir . '/public', '', $absolutePath);
            }
        «ENDIF»

        /**
         * The «appName.formatForDB»_formattedTitle filter outputs a formatted title for a given entity.
         * Example:
         *     {{ myPost|«appName.formatForDB»_formattedTitle }}.
         */
        public function getFormattedEntityTitle(EntityInterface $entity): string
        {
            return $this->entityDisplayHelper->getFormattedTitle($entity);
        }
        «IF hasLoggable»

            /**
             * The «appName.formatForDB»_logDescription filter returns the translated clear text
             * description for a given log entry.
             * Example:
             *     {{ logEntry|«appName.formatForDB»_logDescription }}.
             */
            public function getLogDescription(AbstractLogEntry $logEntry): string
            {
                return $this->loggableHelper->translateActionDescription($logEntry);
            }
        «ENDIF»
    '''

    def private twigExtensionImpl(Application it) '''
        namespace «appNamespace»\Twig;

        use «appNamespace»\Twig\Base\AbstractTwigExtension;

        /**
         * Twig extension implementation class.
         */
        class TwigExtension extends AbstractTwigExtension
        {
            // feel free to add your own Twig extension methods here
        }
    '''

    def private twigRuntimeImpl(Application it) '''
        namespace «appNamespace»\Twig;

        use «appNamespace»\Twig\Base\AbstractTwigRuntime;

        /**
         * Twig runtime implementation class.
         */
        class TwigRuntime extends AbstractTwigRuntime
        {
            // feel free to add your own Twig runtime methods here
        }
    '''

    def private viewPlugins(Application it) {
        val result = newArrayList
        result += new ObjectState().generate(it)
        if (hasUploads) {
            result += new GetFileSize().generate(it)
        }
        if (hasListFields) {
            result += new GetListEntry().generate(it)
        }
        if (hasGeographical) {
            result += new FormatGeoData().generate(it)
        }
        if (hasTrees) {
            result += new TreeData().generate(it)
            result += new TreeSelection().generate(it)
        }
        result.join("\n")
    }
}
