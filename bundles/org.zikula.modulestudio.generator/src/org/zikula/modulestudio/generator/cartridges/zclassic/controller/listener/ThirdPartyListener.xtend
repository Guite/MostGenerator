package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ThirdPartyListener {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it) '''
        «IF generateScribitePlugins || (needsApproval && generatePendingContentSupport)»
            public function __construct(
                «IF generateScribitePlugins»
                    protected ZikulaHttpKernelInterface $kernel,
                    protected Filesystem $filesystem,
                    protected RequestStack $requestStack«IF needsApproval && generatePendingContentSupport»,«ENDIF»
                «ENDIF»
                «IF needsApproval && generatePendingContentSupport»
                    protected WorkflowHelper $workflowHelper
                «ENDIF»
            ) {
            }

        «ENDIF»
        public static function getSubscribedEvents()
        {
            return [
                «IF needsApproval && generatePendingContentSupport»
                    PendingContentEvent::class => ['pendingContentListener', 5],
                «ENDIF»
                «IF generateScribitePlugins»
                    EditorHelperEvent::class => ['getEditorHelpers', 5],
                    LoadExternalPluginsEvent::class => ['getEditorPlugins', 5],
                «ENDIF»
            ];
        }
        «IF needsApproval && generatePendingContentSupport»

            «pendingContentListener»
        «ENDIF»
        «IF generateScribitePlugins»

            «getEditorHelpers»

            «getEditorPlugins»

            «getPathToModuleWebAssets»
        «ENDIF»
    '''

    def private pendingContentListener(Application it) '''
        /**
         * Listener for the `PendingContentEvent` which collects information from extensions
         * about pending content items waiting for approval.
         */
        public function pendingContentListener(PendingContentEvent $event): void
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
            if (0 < count($amounts)) {
                foreach ($amounts as $amountInfo) {
                    $aggregateType = $amountInfo['aggregateType'];
                    $description = $amountInfo['description'];
                    $amount = $amountInfo['amount'];
                    $route = '«appName.toLowerCase»_' . mb_strtolower($amountInfo['objectType']) . '_adminview';
                    $routeArgs = [
                        'workflowState' => $amountInfo['state'],
                    ];
                    $item = new PendingContentCollectible($aggregateType, $description, $amount, $route, $routeArgs);
                    $collection->add($item);
                }

                // add collected items for pending content
                if (0 < $collection->count()) {
                    $event->getSubject()->add($collection);
                }
            }
        «ENDIF»
    '''

    def private getEditorHelpers(Application it) '''
        /**
         * Listener for the `EditorHelperEvent`.
         *
         * This occurs when Scribite adds pagevars to the editor page.
         * «appName» will use this to add a javascript helper to add custom items.
         *
         * Note the selected editor name can be used like this: `if ('CKEditor' === $event->getEditor())`.
         */
        public function getEditorHelpers(EditorHelperEvent $event): void
        {
            // install assets for Scribite plugins
            $projectDir = $this->kernel->getProjectDir();
            $resourcesDir = str_replace('Listener/Base', '', __DIR__) . 'Resources/public/';
            $targetDir = $projectDir . '/public/modules/«vendorAndName.toLowerCase»/scribite';

            if (!$this->filesystem->exists($targetDir)) {
                $originDir = $resourcesDir . 'scribite';
                if (is_dir($originDir)) {
                    $this->filesystem->symlink($originDir, $targetDir, true);
                }
            }

            $commonEditorAssets = [
                'images/admin.png',
                'js/«appName».Finder.js',
            ];

            foreach ($commonEditorAssets as $assetRelativePath) {
                $assetPath = str_replace('scribite', $assetRelativePath, $targetDir);
                if (!$this->filesystem->exists($assetPath)) {
                    $origin = $resourcesDir . $assetRelativePath;
                    $this->filesystem->symlink($origin, $assetPath, true);
                }
            }

            $event->getHelperCollection()->add(
                [
                    'module' => '«appName»',
                    'type' => 'javascript',
                    'path' => $this->getPathToModuleWebAssets() . 'js/«appName».Finder.js',
                ]
            );
        }
    '''

    def private getEditorPlugins(Application it) '''
        /**
         * Listener for the `LoadExternalPluginsEvent`.
         */
        public function getEditorPlugins(LoadExternalPluginsEvent $event): void
        {
            $editorId = $event->getEditor();
            if ('CKEditor' === $editorId) {
                $event->getPluginCollection()->add([
                    'name' => '«appName.formatForDB»',
                    'path' => $this->getPathToModuleWebAssets() . 'scribite/' . $editorId . '/«appName.formatForDB»/',
                    'file' => 'plugin.js',
                    'img' => 'ed_«appName.formatForDB».gif',
                ]);
            } elseif (in_array($editorId, ['Quill', 'Summernote', 'TinyMce'], true)) {
                $event->getPluginCollection()->add([
                    'name' => '«appName.formatForDB»',
                    'path' => $this->getPathToModuleWebAssets() . 'scribite/' . $editorId . '/«appName.formatForDB»/plugin.js',
                ]);
            }
        }
    '''

    def private getPathToModuleWebAssets(Application it) '''
        /**
         * Returns base path where module assets are located.
         */
        protected function getPathToModuleWebAssets(): string
        {
            return $this->requestStack->getCurrentRequest()->getBasePath() . '/modules/«vendorAndName.toLowerCase»/';
        }
    '''
}
