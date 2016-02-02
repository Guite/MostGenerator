package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookBundles {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def setup(Application it) '''
        «val areaPrefix = appName.formatForDB + '.'»
        «val uiArea = areaPrefix + 'ui_hooks.'»
        «FOR entity : getAllEntities.filter[e|!e.skipHookSubscribers]»
            «/* we register one hook subscriber bundle for each entity type */»«val areaName = entity.nameMultiple.formatForDB»
            $bundle = new «IF targets('1.3.x')»Zikula_HookManager_«ENDIF»SubscriberBundle('«appName»', 'subscriber.«areaPrefix».ui_hooks.«areaName»', 'ui_hooks', $this->__('«areaPrefix» «entity.nameMultiple.formatForDisplayCapital» Display Hooks'));
            «/* $bundle->addEvent('hook type', 'event name triggered by *this* module');*/»
            «IF targets('1.3.x') && (hasViewActions || hasDisplayActions) || !targets('1.3.x') && (entity.hasActions('view') || entity.hasActions('display'))»
                // Display hook for view/display templates.
                $bundle->addEvent('display_view', '«uiArea»«areaName».display_view');
            «ENDIF»
            // Display hook for create/edit forms.
            $bundle->addEvent('form_edit', '«uiArea»«areaName».form_edit');
            «IF targets('1.3.x') && (hasEditActions || hasDeleteActions) || !targets('1.3.x') && (entity.hasActions('edit') || entity.hasActions('delete'))»
                // Display hook for delete dialogues.
                $bundle->addEvent('form_delete', '«uiArea»«areaName».form_delete');
            «ENDIF»
            // Validate input from an ui create/edit form.
            $bundle->addEvent('validate_edit', '«uiArea»«areaName».validate_edit');
            «IF targets('1.3.x') && (hasEditActions || hasDeleteActions) || !targets('1.3.x') && (entity.hasActions('edit') || entity.hasActions('delete'))»
                // Validate input from an ui delete form.
                $bundle->addEvent('validate_delete', '«uiArea»«areaName».validate_delete');
            «ENDIF»
            // Perform the final update actions for a ui create/edit form.
            $bundle->addEvent('process_edit', '«uiArea»«areaName».process_edit');
            «IF targets('1.3.x') && (hasEditActions || hasDeleteActions) || !targets('1.3.x') && (entity.hasActions('edit') || entity.hasActions('delete'))»
                // Perform the final delete actions for a ui form.
                $bundle->addEvent('process_delete', '«uiArea»«areaName».process_delete');
            «ENDIF»
            $this->registerHookSubscriberBundle($bundle);

            $bundle = new «IF targets('1.3.x')»Zikula_HookManager_«ENDIF»SubscriberBundle('«appName»', 'subscriber.«areaPrefix».filter_hooks.«areaName»', 'filter_hooks', $this->__('«areaPrefix» «entity.nameMultiple.formatForDisplayCapital» Filter Hooks'));
            // A filter applied to the given area.
            $bundle->addEvent('filter', '«areaPrefix»filter_hooks.«areaName».filter');
            $this->registerHookSubscriberBundle($bundle);

        «ENDFOR»

        «/* TODO see #15
            Example for name of provider area: provider_area.comments.general

            $bundle = new «IF targets('1.3.x')»Zikula_HookManager_«ENDIF»ProviderBundle('«appName»', 'provider.ratings.ui_hooks.rating', 'ui_hooks', $this->__('Ratings Hook Providers'));
            $bundle->addServiceHandler('display_view', 'Ratings_Hooks', 'uiView', 'ratings.service');
            // add other hooks as needed
            $this->registerHookProviderBundle($bundle);

            //... repeat as many times as necessary
        */»
    '''
}
