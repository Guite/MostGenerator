package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ThirdParty {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils
    @Inject extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, Boolean isBase) '''
        «IF generatePendingContentSupport»
            «pendingContentListener(isBase)»
        «ENDIF»
        «val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')»
        «IF generateListContentType || needsDetailContentType»

            «contentGetTypes(isBase)»
        «ENDIF»
        «IF !targets('1.3.5')»
            «IF generateScribitePlugins»

                «getEditorHelpers(isBase)»

                «getTinyMcePlugins(isBase)»

                «getCKEditorPlugins(isBase)»
            «ENDIF»

            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return array(«IF generatePendingContentSupport»
                        'get.pending_content'                   => array('pendingContentListener', 5),«ENDIF»«IF generateListContentType || needsDetailContentType»
                        'module.content.gettypes'               => array('contentGetTypes', 5),«ENDIF»«IF generateScribitePlugins»
                        'module.scribite.editorhelpers'         => array('getEditorHelpers', 5),
                        'moduleplugin.tinymce.externalplugins'  => array('getTinyMcePlugins', 5),
                        'moduleplugin.ckeditor.externalplugins' => array('getCKEditorPlugins', 5)«ENDIF»
                    );
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }
        «ENDIF»
    '''

    def private pendingContentListener(Application it, Boolean isBase) '''
        /**
         * Listener for the 'get.pending_content' event with registration requests and
         * other submitted data pending approval.
         *
         * When a 'get.pending_content' event is fired, the Users module will respond with the
         * number of registration requests that are pending administrator approval. The number
         * pending may not equal the total number of outstanding registration requests, depending
         * on how the 'moderation_order' module configuration variable is set, and whether e-mail
         * address verification is required.
         * If the 'moderation_order' variable is set to require approval after e-mail verification
         * (and e-mail verification is also required) then the number of pending registration
         * requests will equal the number of registration requested that have completed the
         * verification process but have not yet been approved. For other values of
         * 'moderation_order', the number should equal the number of registration requests that
         * have not yet been approved, without regard to their current e-mail verification state.
         * If moderation of registrations is not enabled, then the value will always be 0.
         * In accordance with the 'get_pending_content' conventions, the count of pending
         * registrations, along with information necessary to access the detailed list, is
         * assemped as a {@link Zikula_Provider_AggregateItem} and added to the event
         * subject's collection.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function pendingContentListener(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::pendingContentListener($event);
            «ELSE»
                «pendingContentListenerImpl»
            «ENDIF»
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
            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.5')»
                $workflowHelper = new «appName»_Util_Workflow($this->serviceManager);
            «ELSE»
                $workflowHelper = $serviceManager->get('«appName.formatForDB».workflow_helper');
            «ENDIF»

            $modname = '«appName»';
            $useJoins = false;

            $collection = new «IF targets('1.3.5')»Zikula_Collection_«ENDIF»Container($modname);
            $amounts = $workflowHelper->collectAmountOfModerationItems();
            if (count($amounts) > 0) {
                foreach ($amounts as $amountInfo) {
                    $aggregateType = $amountInfo['aggregateType'];
                    $description = $amountInfo['description'];
                    $amount = $amountInfo['amount'];
                    $viewArgs = array('ot' => $amountInfo['objectType'],
                                      'workflowState' => $amountInfo['state']);
                    $aggregateItem = new «IF targets('1.3.5')»Zikula_Provider_«ENDIF»AggregateItem($aggregateType, $description, $amount, 'admin', 'view', $viewArgs);
                    $collection->add($aggregateItem);
                }

                // add collected items for pending content
                if ($collection->count() > 0) {
                    $event->getSubject()->add($collection);
                }
            }
        «ENDIF»
    '''

    def private contentGetTypes(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.content.gettypes` event.
         *
         * This event occurs when the Content module is 'searching' for Content plugins.
         * The subject is an instance of Content_Types.
         * You can register custom content types as well as custom layout types.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function contentGetTypes(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::contentGetTypes($event);
            «ELSE»
                «contentGetTypesImpl»
            «ENDIF»
        }
    '''

    def private contentGetTypesImpl(Application it) '''
        // intended is using the add() method to add a plugin like below
        $types = $event->getSubject();

        «IF generateDetailContentType && hasUserController && getMainUserController.hasActions('display')»

            // plugin for showing a single item
            $types->add('«appName»_ContentType_Item');
        «ENDIF»
        «IF generateListContentType»

            // plugin for showing a list of multiple items
            $types->add('«appName»_ContentType_ItemList');
        «ENDIF»
    '''

    def private getEditorHelpers(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.scribite.editorhelpers` event.
         *
         * This occurs when Scribite adds pagevars to the editor page.
         * «appName» will use this to add a javascript helper to add custom items.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function getEditorHelpers(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::getEditorHelpers($event);
            «ELSE»
                «getEditorHelpersImpl»
            «ENDIF»
        }
    '''

    def private getEditorHelpersImpl(Application it) '''
        // intended is using the add() method to add a helper like below
        $helpers = $event->getSubject();

        $helpers->add(
            array('module' => '«appName»',
                  'type'   => 'javascript',
                  'path'   => 'modules/«IF targets('1.3.5')»«appName»/javascript/«ELSE»«getAppJsPath»«ENDIF»«appName»_finder.js')
        );
    '''

    def private getTinyMcePlugins(Application it, Boolean isBase) '''
        /**
         * Listener for the `moduleplugin.tinymce.externalplugins` event.
         *
         * Adds external plugin to TinyMCE.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function getTinyMcePlugins(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::getTinyMcePlugins($event);
            «ELSE»
                «getTinyMcePluginsImpl»
            «ENDIF»
        }
    '''

    def private getTinyMcePluginsImpl(Application it) '''
        // intended is using the add() method to add a plugin like below
        $plugins = $event->getSubject();

        $plugins->add(
            array('name' => '«appName.formatForDB»',
                  'path' => 'modules/«IF targets('1.3.5')»«appName»/docs/«ELSE»«getAppDocPath»«ENDIF»scribite/plugins/TinyMce/vendor/tinymce/plugins/«appName.formatForDB»/editor_plugin.js'
            )
        );
    '''

    def private getCKEditorPlugins(Application it, Boolean isBase) '''
        /**
         * Listener for the `moduleplugin.ckeditor.externalplugins` event.
         *
         * Adds external plugin to CKEditor.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function getCKEditorPlugins(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::getCKEditorPlugins($event);
            «ELSE»
                «getCKEditorPluginsImpl»
            «ENDIF»
        }
    '''

    def private getCKEditorPluginsImpl(Application it) '''
        // intended is using the add() method to add a plugin like below
        $plugins = $event->getSubject();

        $plugins->add(
            array('name' => '«appName.formatForDB»',
                  'path' => 'modules/«IF targets('1.3.5')»«appName»/docs/«ELSE»«getAppDocPath»«ENDIF»scribite/plugins/CKEditor/vendor/ckeditor/plugins/«appName.formatForDB»/',
                  'file' => 'plugin.js',
                  'img'  => 'ed_«appName.formatForDB».gif'
            )
        );
    '''
}
