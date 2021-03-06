package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatGeoData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatIcalText
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetCountryName
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetFileSize
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetListEntry
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.IncreaseCounter
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ModerationObjects
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectState
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectTypeSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateSelector
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeSelection
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ItemSelector
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Plugins {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IMostFileSystemAccess fsa

    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        'Generating Twig extension class'.printIfNotTesting(fsa)
        val twigFolder = 'Twig'
        fsa.generateClassPair(twigFolder + '/TwigExtension.php', twigExtensionBaseImpl, twigExtensionImpl)
        fsa.generateClassPair(twigFolder + '/TwigRuntime.php', twigRuntimeBaseImpl, twigRuntimeImpl)
    }

    def generateInternal(Application it) {
        val result = newArrayList
        result += viewPlugins
        if (!targets('2.0')) {
            // legacy content type editing is not ready for Twig
            if (generateListContentType || generateDetailContentType) {
                new ObjectTypeSelector().generate(it, fsa, true)
            }
            if (generateListContentType) {
                new TemplateSelector().generate(it, fsa, true)
            }
            if (generateDetailContentType) {
                new ItemSelector().generate(it, fsa)
            }
        }
        result += otherPlugins
        result.join("\n\n")
    }

    def private twigExtensionBaseImpl(Application it) '''
        namespace «appNamespace»\Twig\Base;

        «IF targets('3.0')»
            use Twig\Extension\AbstractExtension;
            use Twig\TwigFilter;
            use Twig\TwigFunction;
            «IF hasLoggable»
                use Twig\TwigTest;
            «ENDIF»
        «ELSE»
            use Twig_Extension;
        «ENDIF»
        use «appNamespace»\Twig\TwigRuntime;

        /**
         * Twig extension base class.
         */
        abstract class AbstractTwigExtension extends «IF targets('3.0')»Abstract«ELSE»Twig_«ENDIF»Extension
        {
            «IF !targets('3.0')»
                /**
                 * @var TwigRuntime
                 */
                protected $twigRuntime;

                public function __construct(
                    TwigRuntime $twigRuntime
                ) {
                    $this->twigRuntime = $twigRuntime;
                }

            «ENDIF»
            «twigExtensionBody»
        }
    '''

    def private twigRuntimeBaseImpl(Application it) '''
        namespace «appNamespace»\Twig\Base;

        «IF targets('2.0') && !getAllEntities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty»
            use DateInterval;
        «ENDIF»
        «IF !getEntitiesWithCounterFields.empty»
            use Doctrine\DBAL\Driver\Connection;
        «ENDIF»
        «IF hasLoggable»
            use Gedmo\Loggable\Entity\MappedSuperclass\AbstractLogEntry;
        «ENDIF»
        «IF hasTrees»
            use Knp\Menu\Matcher\Matcher;
            use Knp\Menu\Renderer\ListRenderer;
        «ENDIF»
        «IF (generateIcsTemplates && hasEntitiesWithIcsTemplates) || !getEntitiesWithCounterFields.empty»
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        «IF hasCountryFields»
            «IF targets('3.0')»
                use Symfony\Component\Intl\Countries;
            «ELSE»
                use Symfony\Component\Intl\Intl;
            «ENDIF»
        «ENDIF»
        «IF hasTrees»
            use Symfony\Component\Routing\RouterInterface;
        «ENDIF»
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
        «ENDIF»
        use Twig\Extension\RuntimeExtensionInterface;
        «IF targets('3.0')»
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            «IF hasUploads»
                use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
            «ENDIF»
            use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Common\Translator\TranslatorTrait;
            use Zikula\Core\Doctrine\EntityAccess;
        «ENDIF»
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «IF hasTrees»
            use «appNamespace»\Entity\Factory\EntityFactory;
        «ENDIF»
        use «appNamespace»\Helper\EntityDisplayHelper;
        «IF hasListFields»
            use «appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»
        «IF hasLoggable»
            use «appNamespace»\Helper\LoggableHelper;
        «ENDIF»
        use «appNamespace»\Helper\WorkflowHelper;
        «IF hasTrees»
            use «appNamespace»\Menu\MenuBuilder;
        «ENDIF»

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
        «IF !targets('3.0')»
            /**
             * Returns a list of custom Twig functions.
             *
             * @return «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function[] List of functions
             */
        «ENDIF»
        public function getFunctions()
        {
            return [
                «IF hasTrees»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_treeData', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getTreeData'], ['is_safe' => ['html']]),
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_treeSelection', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getTreeSelection']),
                «ENDIF»
                «IF generateModerationPanel && needsApproval»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_moderationObjects', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getModerationObjects']),
                «ENDIF»
                «IF !getEntitiesWithCounterFields.empty»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_increaseCounter', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'increaseCounter']),
                «ENDIF»
                new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_objectTypeSelector', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getObjectTypeSelector']),
                new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_templateSelector', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getTemplateSelector']),
            ];
        }

        «IF !targets('3.0')»
            /**
             * Returns a list of custom Twig filters.
             *
             * @return «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter[] List of filters
             */
        «ENDIF»
        public function getFilters()
        {
            return [
                «IF hasCountryFields && !targets('3.0')»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_countryName', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getCountryName']),
                «ENDIF»
                «IF targets('2.0') && !getAllEntities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_dateInterval', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getFormattedDateInterval']),
                «ENDIF»
                «IF hasUploads»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_fileSize', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getFileSize'], ['is_safe' => ['html']]),
                    «IF targets('3.0')»
                        new TwigFilter('«appNameLower»_relativePath', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getRelativePath']),
                    «ENDIF»
                «ENDIF»
                «IF hasListFields»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_listEntry', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getListEntry']),
                «ENDIF»
                «IF hasGeographical»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_geoData', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'formatGeoData']),
                «ENDIF»
                «IF hasEntitiesWithIcsTemplates»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_icalText', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'formatIcalText']),
                «ENDIF»
                «IF hasLoggable»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_logDescription', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getLogDescription']),
                «ENDIF»
                new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_formattedTitle', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getFormattedEntityTitle']),
                new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_objectState', [«IF targets('3.0')»TwigRuntime::class«ELSE»$this->twigRuntime«ENDIF», 'getObjectState'], ['is_safe' => ['html']]),
            ];
        }
        «IF hasLoggable»

            «IF !targets('3.0')»
                /**
                 * Returns a list of custom Twig tests.
                 *
                 * @return «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Test[] List of tests
                 */
            «ENDIF»
            public function getTests()
            {
                return [
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Test('«appNameLower»_instanceOf', static function ($var, $instance) {
                        return $var instanceof $instance;
                    }),
                ];
            }
        «ENDIF»
    '''

    def private twigRuntimeBody(Application it) '''
        use TranslatorTrait;

        «IF targets('3.0') && hasUploads»
            /**
             * @var ZikulaHttpKernelInterface
             */
            protected $kernel;

        «ENDIF»
        «IF !getEntitiesWithCounterFields.empty»
            /**
             * @var Connection
             */
            protected $databaseConnection;

        «ENDIF»
        «IF hasTrees»
            /**
             * @var RouterInterface
             */
            protected $router;

        «ENDIF»
        «IF (generateIcsTemplates && hasEntitiesWithIcsTemplates) || !getEntitiesWithCounterFields.empty»
            /**
             * @var RequestStack
             */
            protected $requestStack;

        «ENDIF»
        /**
         * @var VariableApiInterface
         */
        protected $variableApi;

        «IF hasTrees»
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

        «ENDIF»
        /**
         * @var EntityDisplayHelper
         */
        protected $entityDisplayHelper;

        /**
         * @var WorkflowHelper
         */
        protected $workflowHelper;

        «IF hasListFields»
            /**
             * @var ListEntriesHelper
             */
            protected $listHelper;

        «ENDIF»
        «IF hasLoggable»
            /**
             * @var LoggableHelper
             */
            protected $loggableHelper;

        «ENDIF»
        «IF hasTrees»
            /**
             * @var MenuBuilder
             */
            protected $menuBuilder;

        «ENDIF»
        public function __construct(
            «IF targets('3.0') && hasUploads»
                ZikulaHttpKernelInterface $kernel,
            «ENDIF»
            TranslatorInterface $translator«IF !getEntitiesWithCounterFields.empty»,
            Connection $connection«ENDIF»«IF hasTrees»,
            RouterInterface $router«ENDIF»«IF (generateIcsTemplates && hasEntitiesWithIcsTemplates) || !getEntitiesWithCounterFields.empty»,
            RequestStack $requestStack«ENDIF»,
            VariableApiInterface $variableApi,
            «IF hasTrees»
                EntityFactory $entityFactory,
            «ENDIF»
            EntityDisplayHelper $entityDisplayHelper,
            WorkflowHelper $workflowHelper«IF hasListFields»,
            ListEntriesHelper $listHelper«ENDIF»«IF hasLoggable»,
            LoggableHelper $loggableHelper«ENDIF»«IF hasTrees»,
            MenuBuilder $menuBuilder«ENDIF»
        ) {
            «IF targets('3.0') && hasUploads»
                $this->kernel = $kernel;
            «ENDIF»
            $this->setTranslator($translator);
            «IF !getEntitiesWithCounterFields.empty»
                $this->databaseConnection = $connection;
            «ENDIF»
            «IF hasTrees»
                $this->router = $router;
            «ENDIF»
            «IF (generateIcsTemplates && hasEntitiesWithIcsTemplates) || !getEntitiesWithCounterFields.empty»
                $this->requestStack = $requestStack;
            «ENDIF»
            $this->variableApi = $variableApi;
            «IF hasTrees»
                $this->entityFactory = $entityFactory;
            «ENDIF»
            $this->entityDisplayHelper = $entityDisplayHelper;
            $this->workflowHelper = $workflowHelper;
            «IF hasListFields»
                $this->listHelper = $listHelper;
            «ENDIF»
            «IF hasLoggable»
                $this->loggableHelper = $loggableHelper;
            «ENDIF»
            «IF hasTrees»
                $this->menuBuilder = $menuBuilder;
            «ENDIF»
        }
        «IF !targets('3.0')»

            «setTranslatorMethod»
        «ENDIF»

        «generateInternal»
        «IF targets('2.0') && !getAllEntities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty»

            /**
             * The «appName.formatForDB»_dateInterval filter outputs a formatted description for a given date interval (duration string).
             * Example:
             *     {{ myDateIntervalString|«appName.formatForDB»_dateInterval }}
             *
             * @see http://php.net/manual/en/dateinterval.format.php
             «IF !targets('3.0')»
             *
             * @param string $duration The given duration string
             *
             * @return string The formatted title
             «ENDIF»
             */
            public function getFormattedDateInterval«IF targets('3.0')»(string $duration): string«ELSE»($duration)«ENDIF»
            {
                $interval = new DateInterval($duration);

                $description = 1 === $interval->invert ? '- ' : '';

                $amount = $interval->y;
                if (0 < $amount) {
                    «IF targets('3.0')»
                        $description .= $this->translator->trans('%count% year|%count% years', ['%count%' => $amount]);
                    «ELSE»
                        $description .= $this->translator->transChoice('%amount year|%amount years', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                    «ENDIF»
                }

                $amount = $interval->m;
                if (0 < $amount) {
                    «IF targets('3.0')»
                        $description .= ', ' . $this->translator->trans('%count% month|%count% months', ['%count%' => $amount]);
                    «ELSE»
                        $description .= ', ' . $this->translator->transChoice('%amount month|%amount months', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                    «ENDIF»
                }

                $amount = $interval->d;
                if (0 < $amount) {
                    «IF targets('3.0')»
                        $description .= ', ' . $this->translator->trans('%count% day|%count% days', ['%count%' => $amount]);
                    «ELSE»
                        $description .= ', ' . $this->translator->transChoice('%amount day|%amount days', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                    «ENDIF»
                }

                $amount = $interval->h;
                if (0 < $amount) {
                    «IF targets('3.0')»
                        $description .= ', ' . $this->translator->trans('%count% hour|%count% hours', ['%count%' => $amount]);
                    «ELSE»
                        $description .= ', ' . $this->translator->transChoice('%amount hour|%amount hours', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                    «ENDIF»
                }

                $amount = $interval->i;
                if (0 < $amount) {
                    «IF targets('3.0')»
                        $description .= ', ' . $this->translator->trans('%count% minute|%count% minutes', ['%count%' => $amount]);
                    «ELSE»
                        $description .= ', ' . $this->translator->transChoice('%amount minute|%amount minutes', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                    «ENDIF»
                }

                $amount = $interval->s;
                if (0 < $amount) {
                    «IF targets('3.0')»
                        $description .= ', ' . $this->translator->trans('%count% second|%count% seconds', ['%count%' => $amount]);
                    «ELSE»
                        $description .= ', ' . $this->translator->transChoice('%amount second|%amount seconds', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                    «ENDIF»
                }

                return $description;
            }
        «ENDIF»
        «IF targets('3.0') && hasUploads»

            /**
             * The «appName.formatForDB»__relativePath filter returns the relative web path to a file.
             * Example:
             *     {{ myPerson.image.getPathname()|«appName.formatForDB»_relativePath }}.
             */
            public function getRelativePath(string $absolutePath): string
            {
                return str_replace($this->kernel->getProjectDir() . '/public', '', $absolutePath);
            }
        «ENDIF»

        /**
         * The «appName.formatForDB»_formattedTitle filter outputs a formatted title for a given entity.
         * Example:
         *     {{ myPost|«appName.formatForDB»_formattedTitle }}.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity The given entity instance
         *
         * @return string The formatted title
         «ENDIF»
         */
        public function getFormattedEntityTitle«IF targets('3.0')»(EntityAccess $entity): string«ELSE»($entity)«ENDIF»
        {
            return $this->entityDisplayHelper->getFormattedTitle($entity);
        }
        «IF hasLoggable»

            /**
             * The «appName.formatForDB»_logDescription filter returns the translated clear text
             * description for a given log entry.
             * Example:
             *     {{ logEntry|«appName.formatForDB»_logDescription }}.
             «IF !targets('3.0')»
             *
             * @param AbstractLogEntry $logEntry
             *
             * @return string
             «ENDIF»
             */
            public function getLogDescription(AbstractLogEntry $logEntry)«IF targets('3.0')»: string«ENDIF»
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
        if (hasCountryFields && !targets('3.0')) {
            result += new GetCountryName().generate(it)
        }
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
        if (generateModerationPanel && needsApproval) {
            result += new ModerationObjects().generate(it)
        }
        if (!getEntitiesWithCounterFields.empty) {
            result += new IncreaseCounter().generate(it)
        }
        if (generateIcsTemplates && hasEntitiesWithIcsTemplates) {
            result += new FormatIcalText().generate(it)
        }
        result.join("\n")
    }

    def private otherPlugins(Application it) {
        val result = newArrayList
        if (generateDetailContentType && !targets('2.0')) {
            new ItemSelector().generate(it, fsa)
        }
        result += new ObjectTypeSelector().generate(it, fsa, false)
        result += new TemplateSelector().generate(it, fsa, false)
        result.join("\n")
    }
}
