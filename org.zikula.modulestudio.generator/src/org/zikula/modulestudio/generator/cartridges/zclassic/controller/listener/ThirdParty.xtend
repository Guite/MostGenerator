package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ThirdParty {
    @Inject extension Utils = new Utils()
    @Inject extension WorkflowExtensions = new WorkflowExtensions()

    def generate(Application it, Boolean isBase) '''
        «pendingContentListener(isBase)»

        «contentGetTypes(isBase)»
    '''

    def private pendingContentListener(Application it, Boolean isBase) '''
        /**
         * Listener for pending content items.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function pendingContentListener(Zikula_Event $event)
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
            $workflowHelper = new «appName»_Util_Workflow($serviceManager);
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
         * @param Zikula_Event $event The event instance.
         */
        public static function contentGetTypes(Zikula_Event $event)
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
}
