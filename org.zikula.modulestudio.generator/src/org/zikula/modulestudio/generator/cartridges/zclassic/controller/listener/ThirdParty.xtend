package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ThirdParty {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()
    @Inject extension WorkflowExtensions = new WorkflowExtensions()

    def generate(Application it, Boolean isBase) '''
        «pendingContentListener(isBase)»

        «contentGetTypes(isBase)»
        «IF !targets('1.3.5')»

        «getEditorHelpers(isBase)»
        «getTinyMcePlugins(isBase)»
        «getCKEditorPlugins(isBase)»
        «ENDIF»
    '''

    def private pendingContentListener(Application it, Boolean isBase) '''
        /**
         * Listener for pending content items.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function pendingContentListener(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
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
        «ELSE»
            $serviceManager = ServiceUtil::getManager();
            $workflowHelper = new «appName»«IF targets('1.3.5')»_Util_«ELSE»\Util\«ENDIF»Workflow($serviceManager);
            $modname = '«appName»';
            $useJoins = false;

            $collection = new Zikula_Collection_Container($modname);
            $amounts = $workflowHelper->collectAmountOfModerationItems();
            if (count($amounts) > 0) {
                foreach ($amounts as $amountInfo) {
                    $aggregateType = $amountInfo['aggregateType'];
                    $description = $amountInfo['description'];
                    $amount = $amountInfo['amount'];
                    $viewArgs = array('ot' => $amountInfo['objectType'],
                                      'workflowState' => $amountInfo['state']);
                    $aggregateItem = new Zikula_Provider_AggregateItem($aggregateType, $description, $amount, 'admin', 'view', $viewArgs);
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
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function contentGetTypes(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
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

        // plugin for showing a single item
        $types->add('«appName»_ContentType_Item');

        // plugin for showing a list of multiple items
        $types->add('«appName»_ContentType_ItemList');
    '''

    def private getEditorHelpers(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.scribite.editorhelpers` event.
         *
         * This occurs when Scribite adds pagevars to the editor page.
         * «appName» will use this to add a javascript helper to add custom items.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function getEditorHelpers(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
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
                  'path'   => 'modules/«appName»/«getAppJsPath»/«appName»_finder.js')
        );
    '''

    def private getTinyMcePlugins(Application it, Boolean isBase) '''
        /**
         * Listener for the `moduleplugin.tinymce.externalplugins` event.
         *
         * Adds external plugin to TinyMCE.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function getTinyMcePlugins(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
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
                  'path' => 'modules/«appName»/docs/scribite/plugins/TinyMCE/vendor/tiny_mce/plugins/«appName.formatForDB»/editor_plugin.js'
            )
        );
    '''

    def private getCKEditorPlugins(Application it, Boolean isBase) '''
        /**
         * Listener for the `moduleplugin.ckeditor.externalplugins` event.
         *
         * Adds external plugin to CKEditor.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function getCKEditorPlugins(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
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
                  'path' => 'modules/«appName»/docs/scribite/plugins/CKEditor/vendor/ckeditor/plugins/«appName.formatForDB»/',
                  'file' => 'plugin.js',
                  'img'  => 'ed_«appName.formatForDB».gif'));
            )
        );
    '''
}
