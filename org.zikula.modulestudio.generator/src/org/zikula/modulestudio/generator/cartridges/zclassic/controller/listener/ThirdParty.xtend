package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class ThirdParty {
    @Inject extension Utils = new Utils()

    def generate(Application it) '''
        /**
         * Listener for pending content items.
         */
        public static function pendingContentListener(Zikula_Event $event)
        {
            if (!SecurityUtil::checkPermission('«appName»:objecttype:', 'ids::', ACCESS_MODERATE)) {
                return;
            }
            /** this is an example implementation from the Users module
            $approvalOrder = ModUtil::getVar('Users', 'moderation_order', UserUtil::APPROVAL_ANY);
            $filter = array('approved_by' => 0);
            if ($approvalOrder == UserUtil::APPROVAL_AFTER) {
                $filter['isverified'] = true;
            }
            $numPendingApproval = ModUtil::apiFunc('Users', 'registration', 'countAll', array('filter' => $filter));

            if (!empty($numPendingApproval)) {
                $collection = new Zikula_Collection_Container('Users');
                $collection->add(new Zikula_Provider_AggregateItem('registrations', __('Registrations pending approval'), $numPendingApproval, 'admin', 'viewRegistrations'));
                $event->getSubject()->add($collection);
            }
            */
        }

        /**
         * Listener for the `module.content.gettypes` event.
         *
         * This event occurs when the Content module is 'searching' for Content plugins.
         * The subject is an instance of Content_Types.
         */
        public static function contentGetTypes(Zikula_Event $event)
        {
            // intended is using the add() method to add a plugin like below
            $types = $event->getSubject();

            // plugin for showing a single item
            $types->add('«appName»_ContentType_Item');

            // plugin for showing a list of multiple items
            $types->add('«appName»_ContentType_ItemList');
        }
    '''
}
