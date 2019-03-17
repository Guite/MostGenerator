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

        «IF targets('2.0') && !getAllEntities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty»
            use DateInterval;
        «ENDIF»
        «IF hasLoggable»
            use Gedmo\Loggable\Entity\MappedSuperclass\AbstractLogEntry;
        «ENDIF»
        «IF hasTrees»
            use Knp\Menu\Matcher\Matcher;
            use Knp\Menu\Renderer\ListRenderer;
        «ENDIF»
        «IF generateIcsTemplates && hasEntitiesWithIcsTemplates»
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        «IF hasCountryFields»
            use Symfony\Component\Intl\Intl;
        «ENDIF»
        «IF hasTrees»
            use Symfony\Component\Routing\RouterInterface;
        «ENDIF»
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
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
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
         * Twig extension base class.
         */
        abstract class AbstractTwigExtension extends «IF targets('3.0')»Abstract«ELSE»Twig_«ENDIF»Extension
        {
            «twigExtensionBody»
        }
    '''

    def private twigExtensionBody(Application it) '''
        «val appNameLower = appName.toLowerCase»
        use TranslatorTrait;

        «IF hasTrees»
            /**
             * @var RouterInterface
             */
            protected $router;

        «ENDIF»
        «IF generateIcsTemplates && hasEntitiesWithIcsTemplates»
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
        /**
         * TwigExtension constructor.
         *
         * @param TranslatorInterface $translator
         «IF hasTrees»
            * @param Routerinterface $router
         «ENDIF»
         «IF generateIcsTemplates && hasEntitiesWithIcsTemplates»
            * @param RequestStack $requestStack
         «ENDIF»
         * @param VariableApiInterface $variableApi
         «IF hasTrees»
         * @param EntityFactory $entityFactory
         «ENDIF»
         * @param EntityDisplayHelper $entityDisplayHelper
         * @param WorkflowHelper $workflowHelper
         «IF hasListFields»
            * @param ListEntriesHelper $listHelper
         «ENDIF»
         «IF hasLoggable»
            * @param LoggableHelper $loggableHelper
         «ENDIF»
         «IF hasTrees»
            * @param MenuBuilder $menuBuilder
         «ENDIF»
         */
        public function __construct(
            TranslatorInterface $translator«IF hasTrees»,
            RouterInterface $router«ENDIF»«IF generateIcsTemplates && hasEntitiesWithIcsTemplates»,
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
            $this->setTranslator($translator);
            «IF hasTrees»
                $this->router = $router;
            «ENDIF»
            «IF generateIcsTemplates && hasEntitiesWithIcsTemplates»
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

        «setTranslatorMethod»

        /**
         * Returns a list of custom Twig functions.
         *
         * @return «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function[] List of functions
         */
        public function getFunctions()
        {
            return [
                «IF hasTrees»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_treeData', [$this, 'getTreeData'], ['is_safe' => ['html']]),
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_treeSelection', [$this, 'getTreeSelection']),
                «ENDIF»
                «IF generateModerationPanel && needsApproval»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_moderationObjects', [$this, 'getModerationObjects']),
                «ENDIF»
                new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_objectTypeSelector', [$this, 'getObjectTypeSelector']),
                new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Function('«appNameLower»_templateSelector', [$this, 'getTemplateSelector'])
            ];
        }

        /**
         * Returns a list of custom Twig filters.
         *
         * @return «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter[] List of filters
         */
        public function getFilters()
        {
            return [
                «IF hasCountryFields»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_countryName', [$this, 'getCountryName']),
                «ENDIF»
                «IF targets('2.0') && !getAllEntities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_dateInterval', [$this, 'getFormattedDateInterval']),
                «ENDIF»
                «IF hasUploads»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_fileSize', [$this, 'getFileSize'], ['is_safe' => ['html']]),
                «ENDIF»
                «IF hasListFields»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_listEntry', [$this, 'getListEntry']),
                «ENDIF»
                «IF hasGeographical»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_geoData', [$this, 'formatGeoData']),
                «ENDIF»
                «IF hasEntitiesWithIcsTemplates»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_icalText', [$this, 'formatIcalText']),
                «ENDIF»
                «IF hasLoggable»
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_logDescription', [$this, 'getLogDescription']),
                «ENDIF»
                new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_formattedTitle', [$this, 'getFormattedEntityTitle']),
                new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Filter('«appNameLower»_objectState', [$this, 'getObjectState'], ['is_safe' => ['html']])
            ];
        }
        «IF hasLoggable»

            /**
             * Returns a list of custom Twig tests.
             *
             * @return «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Test[] List of tests
             */
            public function getTests()
            {
                return [
                    new «IF targets('3.0')»Twig«ELSE»\Twig_Simple«ENDIF»Test('«appNameLower»_instanceOf', function ($var, $instance) {
                        return $var instanceof $instance;
                    })
                ];
            }
        «ENDIF»

        «generateInternal»
        «IF targets('2.0') && !getAllEntities.filter[!fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty].empty»

            /**
             * The «appName.formatForDB»_dateInterval filter outputs a formatted description for a given date interval (duration string).
             * Example:
             *     {{ myDateIntervalString|«appName.formatForDB»_dateInterval }}
             *
             * @see http://php.net/manual/en/dateinterval.format.php
             *
             * @param object $duration The given duration string
             *
             * @return string The formatted title
             */
            public function getFormattedDateInterval($duration)
            {
                $interval = new DateInterval($duration);

                $description = $interval->invert == 1 ? '- ' : '';

                $amount = $interval->y;
                if ($amount > 0) {
                    $description .= $this->translator->transChoice('%amount year|%amount years', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                }

                $amount = $interval->m;
                if ($amount > 0) {
                    $description .= ', ' . $this->translator->transChoice('%amount month|%amount months', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                }

                $amount = $interval->d;
                if ($amount > 0) {
                    $description .= ', ' . $this->translator->transChoice('%amount day|%amount days', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                }

                $amount = $interval->h;
                if ($amount > 0) {
                    $description .= ', ' . $this->translator->transChoice('%amount hour|%amount hours', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                }

                $amount = $interval->i;
                if ($amount > 0) {
                    $description .= ', ' . $this->translator->transChoice('%amount minute|%amount minutes', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                }

                $amount = $interval->s;
                if ($amount > 0) {
                    $description .= ', ' . $this->translator->transChoice('%amount second|%amount seconds', $amount, ['%amount' => $amount]«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»);
                }

                return $description;
            }
        «ENDIF»

        /**
         * The «appName.formatForDB»_formattedTitle filter outputs a formatted title for a given entity.
         * Example:
         *     {{ myPost|«appName.formatForDB»_formattedTitle }}
         *
         * @param object $entity The given entity instance
         *
         * @return string The formatted title
         */
        public function getFormattedEntityTitle($entity)
        {
            return $this->entityDisplayHelper->getFormattedTitle($entity);
        }
        «IF hasLoggable»

            /**
             * The «appName.formatForDB»_logDescription filter returns the translated clear text
             * description for a given log entry.
             * Example:
             *     {{ logEntry|«appName.formatForDB»_logDescription }}
             *
             * @param AbstractLogEntry $logEntry
             *
             * @return string
             */
            public function getLogDescription(AbstractLogEntry $logEntry)
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

    def private viewPlugins(Application it) {
        val result = newArrayList
        result += new ObjectState().generate(it)
        if (hasCountryFields) {
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
        if (generateIcsTemplates && hasEntitiesWithIcsTemplates) {
            result += new FormatIcalText().generate(it)
        }
        result.join("\n\n")
    }

    def private otherPlugins(Application it) {
        val result = newArrayList
        if (generateDetailContentType && !targets('2.0')) {
            new ItemSelector().generate(it, fsa)
        }
        result += new ObjectTypeSelector().generate(it, fsa, false)
        result += new TemplateSelector().generate(it, fsa, false)
        result.join("\n\n")
    }
}
