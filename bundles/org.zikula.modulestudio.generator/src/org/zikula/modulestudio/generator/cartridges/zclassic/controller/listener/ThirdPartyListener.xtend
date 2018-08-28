package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ThirdPartyListener {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        «IF generateScribitePlugins»
            /**
             * @var Filesystem
             */
            protected $filesystem;

            /**
             * @var RequestStack
             */
            protected $requestStack;

        «ENDIF»
        «IF needsApproval && generatePendingContentSupport»
            /**
             * @var WorkflowHelper
             */
            protected $workflowHelper;

        «ENDIF»
        «IF generateScribitePlugins || (needsApproval && generatePendingContentSupport)»
            /**
             * ThirdPartyListener constructor.
             *
             «IF generateScribitePlugins»
             * @param Filesystem   $filesystem   Filesystem service instance
             * @param RequestStack $requestStack RequestStack service instance
             «ENDIF»
             «IF needsApproval && generatePendingContentSupport»
             * @param WorkflowHelper $workflowHelper WorkflowHelper service instance
             «ENDIF»
             *
             * @return void
             */
            public function __construct(«IF generateScribitePlugins»Filesystem $filesystem, RequestStack $requestStack«ENDIF»«IF needsApproval && generatePendingContentSupport»«IF generateScribitePlugins», «ENDIF»WorkflowHelper $workflowHelper«ENDIF»)
            {
                «IF generateScribitePlugins»
                    $this->filesystem = $filesystem;
                    $this->requestStack = $requestStack;
                «ENDIF»
                «IF needsApproval && generatePendingContentSupport»
                    $this->workflowHelper = $workflowHelper;
                «ENDIF»
            }

        «ENDIF»
        «val needsDetailContentType = generateDetailContentType && hasDisplayActions»
        /**
         * Makes our handlers known to the event system.
         */
        public static function getSubscribedEvents()
        {
            return [
                «IF needsApproval && generatePendingContentSupport»
                    'get.pending_content'                     => ['pendingContentListener', 5],
                «ENDIF»
                «IF !targets('2.0') && (generateListContentType || needsDetailContentType)»
                    'module.content.gettypes'                 => ['contentGetTypes', 5],
                «ENDIF»
                «IF generateScribitePlugins»
                    'module.scribite.editorhelpers'           => ['getEditorHelpers', 5],
                    'moduleplugin.ckeditor.externalplugins'   => ['getCKEditorPlugins', 5],
                    'moduleplugin.quill.externalplugins'      => ['getQuillPlugins', 5],
                    'moduleplugin.summernote.externalplugins' => ['getSummernotePlugins', 5],
                    'moduleplugin.tinymce.externalplugins'    => ['getTinyMcePlugins', 5]
                «ENDIF»
            ];
        }

        «IF needsApproval && generatePendingContentSupport»
            «pendingContentListener»
        «ENDIF»
        «IF !targets('2.0') && (generateListContentType || needsDetailContentType)»

            «contentGetTypes»
        «ENDIF»
        «IF generateScribitePlugins»

            «getEditorHelpers»

            «getCKEditorPlugins»

            «getCommonEditorPlugins('Quill')»

            «getCommonEditorPlugins('Summernote')»

            «getCommonEditorPlugins('TinyMce')»
        «ENDIF»
    '''

    def private pendingContentListener(Application it) '''
        /**
         * Listener for the `get.pending_content` event which collects information from modules
         * about pending content items waiting for approval.
         *
         «commonExample.generalEventProperties(it, false)»
         * @param GenericEvent $event The event instance
         */
        public function pendingContentListener(GenericEvent $event)
        {
            «pendingContentListenerImpl»
        }
    '''

    def private pendingContentListenerImpl(Application it) '''
        «IF !needsApproval»
            // nothing required here as no entities use enhanced workflows including approval actions
        «ELSEIF !generatePendingContentSupport»
            // pending content support is disabled in generator settings
            // however, we keep this empty stub to prevent errors if the event handler
            // was already registered before
        «ELSE»
            $collection = new Container('«appName»');
            $amounts = $this->workflowHelper->collectAmountOfModerationItems();
            if (count($amounts) > 0) {
                foreach ($amounts as $amountInfo) {
                    $aggregateType = $amountInfo['aggregateType'];
                    $description = $amountInfo['description'];
                    $amount = $amountInfo['amount'];
                    $route = '«appName.toLowerCase»_' . strtolower($amountInfo['objectType']) . '_adminview';
                    $routeArgs = [
                        'workflowState' => $amountInfo['state']
                    ];
                    $item = new PendingContentCollectible($aggregateType, $description, $amount, $route, $routeArgs);
                    $collection->add($item);
                }

                // add collected items for pending content
                if ($collection->count() > 0) {
                    $event->getSubject()->add($collection);
                }
            }
        «ENDIF»
    '''

    def private contentGetTypes(Application it) '''
        /**
         * Listener for the `module.content.gettypes` event.
         *
         * This event occurs when the Content module is 'searching' for Content plugins.
         * The subject is an instance of Content_Types.
         * You can register custom content types as well as custom layout types.
         *
         «commonExample.generalEventProperties(it, false)»
         * @param \Zikula_Event $event The event instance
         */
        public function contentGetTypes(\Zikula_Event $event)
        {
            «contentGetTypesImpl»
        }
    '''

    def private contentGetTypesImpl(Application it) '''
        // intended is using the add() method to add a plugin like below
        $types = $event->getSubject();

        «IF generateDetailContentType && hasDisplayActions»

            // plugin for showing a single item
            $types->add('«appName»_ContentType_Item');
        «ENDIF»
        «IF generateListContentType»

            // plugin for showing a list of multiple items
            $types->add('«appName»_ContentType_ItemList');
        «ENDIF»
    '''

    def private getEditorHelpers(Application it) '''
        /**
         * Listener for the `module.scribite.editorhelpers` event.
         *
         * This occurs when Scribite adds pagevars to the editor page.
         * «appName» will use this to add a javascript helper to add custom items.
         *
         «commonExample.generalEventProperties(it, false)»
         * @param EditorHelperEvent $event The event instance
         */
        public function getEditorHelpers(EditorHelperEvent $event)
        {
            // install assets for Scribite plugins
            $targetDir = 'web/modules/«vendorAndName.toLowerCase»';
            $finder = new Finder();
            if (!$this->filesystem->exists($targetDir)) {
                $this->filesystem->mkdir($targetDir, 0777);
                if (is_dir($originDir = '«relativeAppRootPath»/Resources/public')) {
                    $this->filesystem->mirror($originDir, $targetDir, Finder::create()->in($originDir));
                }
                if (is_dir($originDir = '«relativeAppRootPath»/Resources/scribite')) {
                    $targetDir .= '/scribite';
                    $this->filesystem->mkdir($targetDir, 0777);
                    $this->filesystem->mirror($originDir, $targetDir, Finder::create()->in($originDir));
                }
            }

            $event->getHelperCollection()->add(
                [
                    'module' => '«appName»',
                    'type' => 'javascript',
                    'path' => $this->requestStack->getCurrentRequest()->getBasePath() . '/web/modules/«vendorAndName.toLowerCase»/js/«appName».Finder.js'
                ]
            );
        }
    '''

    def private getCKEditorPlugins(Application it) '''
        /**
         * Listener for the `moduleplugin.ckeditor.externalplugins` event.
         *
         * Adds external plugin to CKEditor.
         *
         «commonExample.generalEventProperties(it, false)»
         * @param GenericEvent $event The event instance
         */
        public function getCKEditorPlugins(GenericEvent $event)
        {
            $event->getSubject()->add([
                'name' => '«appName.formatForDB»',
                'path' => $this->requestStack->getCurrentRequest()->getBasePath() . '/web/modules/«vendorAndName.toLowerCase»/scribite/CKEditor/«appName.formatForDB»/',
                'file' => 'plugin.js',
                'img' => 'ed_«appName.formatForDB».gif'
            ]);
        }
    '''

    def private getCommonEditorPlugins(Application it, String editorName) '''
        /**
         * Listener for the `moduleplugin.«editorName.toLowerCase».externalplugins` event.
         *
         * Adds external plugin to «editorName».
         *
         «commonExample.generalEventProperties(it, false)»
         * @param GenericEvent $event The event instance
         */
        public function get«editorName»Plugins(GenericEvent $event)
        {
            $event->getSubject()->add([
                'name' => '«appName.formatForDB»',
                'path' => $this->requestStack->getCurrentRequest()->getBasePath() . '/web/modules/«vendorAndName.toLowerCase»/scribite/«editorName»/«appName.formatForDB»/plugin.js'
            ]);
        }
    '''
}
