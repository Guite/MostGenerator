package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

// 1.4 only
class HookBundlesLegacy {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def setup(Application it) '''
        «val areaPrefix = appName.formatForDB + '.'»
        «val uiArea = areaPrefix + 'ui_hooks.'»
        «FOR entity : getAllEntities.filter[e|!e.skipHookSubscribers]»
            «/* we register one hook subscriber bundle for each entity type */»«val areaName = entity.nameMultiple.formatForDB»
            $bundle = new SubscriberBundle('«appName»', 'subscriber.«uiArea»«areaName»', 'ui_hooks', $this->__('«areaPrefix» «entity.nameMultiple.formatForDisplayCapital» Display Hooks'));
            «IF entity.hasViewAction || entity.hasDisplayAction»
                // Display hook for view/display templates.
                $bundle->addEvent('display_view', '«uiArea»«areaName».display_view');
            «ENDIF»
            «IF entity.hasViewAction || entity.hasEditAction»
                «IF entity.hasEditAction»
                    // Display hook for create/edit forms.
                    $bundle->addEvent('form_edit', '«uiArea»«areaName».form_edit');
                «ENDIF»
                // Validate input from an item to be edited.
                $bundle->addEvent('validate_edit', '«uiArea»«areaName».validate_edit');
                // Perform the final update actions for an edited item.
                $bundle->addEvent('process_edit', '«uiArea»«areaName».process_edit');
            «ENDIF»
            «IF entity.hasDeleteAction»
                // Display hook for delete forms.
                $bundle->addEvent('form_delete', '«uiArea»«areaName».form_delete');
            «ENDIF»
            «IF entity.hasViewAction || entity.hasEditAction || entity.hasDeleteAction»
                // Validate input from an item to be deleted.
                $bundle->addEvent('validate_delete', '«uiArea»«areaName».validate_delete');
                // Perform the final delete actions for a deleted item.
                $bundle->addEvent('process_delete', '«uiArea»«areaName».process_delete');
            «ENDIF»
            $this->registerHookSubscriberBundle($bundle);

            $bundle = new SubscriberBundle('«appName»', 'subscriber.«areaPrefix»filter_hooks.«areaName»', 'filter_hooks', $this->__('«areaPrefix» «entity.nameMultiple.formatForDisplayCapital» Filter Hooks'));
            // A filter applied to the given area.
            $bundle->addEvent('filter', '«areaPrefix»filter_hooks.«areaName».filter');
            $this->registerHookSubscriberBundle($bundle);

        «ENDFOR»
        «/* TODO see #15
            Example for name of provider area: provider_area.comments.general

            $bundle = new ProviderBundle('«appName»', 'provider.ratings.ui_hooks.rating', 'ui_hooks', $this->__('Ratings Hook Providers'));
            $bundle->addServiceHandler('display_view', 'Ratings_Hooks', 'uiView', 'ratings.service');
            // add other hooks as needed
            $this->registerHookProviderBundle($bundle);

            //... repeat as many times as necessary
        */»
    '''
}
