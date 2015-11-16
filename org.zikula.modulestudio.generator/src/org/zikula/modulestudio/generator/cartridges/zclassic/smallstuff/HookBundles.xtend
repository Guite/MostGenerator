package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookBundles {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def setup(Application it) '''
        «val areaPrefix = appName.formatForDB»
        «FOR entity : getAllEntities»
            «/* we register one hook subscriber bundle for each entity type */»«val areaName = entity.nameMultiple.formatForDB»
            $bundle = new «IF targets('1.3.x')»Zikula_HookManager_«ENDIF»SubscriberBundle('«appName»', 'subscriber.«areaPrefix».ui_hooks.«areaName»', 'ui_hooks', $this->__('«areaPrefix» «entity.nameMultiple.formatForDisplayCapital» Display Hooks'));
            «/* $bundle->addEvent('hook type', 'event name triggered by *this* module');*/»
            // Display hook for view/display templates.
            $bundle->addEvent('display_view', '«areaPrefix».ui_hooks.«areaName».display_view');
            // Display hook for create/edit forms.
            $bundle->addEvent('form_edit', '«areaPrefix».ui_hooks.«areaName».form_edit');
            // Display hook for delete dialogues.
            $bundle->addEvent('form_delete', '«areaPrefix».ui_hooks.«areaName».form_delete');
            // Validate input from an ui create/edit form.
            $bundle->addEvent('validate_edit', '«areaPrefix».ui_hooks.«areaName».validate_edit');
            // Validate input from an ui create/edit form (generally not used).
            $bundle->addEvent('validate_delete', '«areaPrefix».ui_hooks.«areaName».validate_delete');
            // Perform the final update actions for a ui create/edit form.
            $bundle->addEvent('process_edit', '«areaPrefix».ui_hooks.«areaName».process_edit');
            // Perform the final delete actions for a ui form.
            $bundle->addEvent('process_delete', '«areaPrefix».ui_hooks.«areaName».process_delete');
            $this->registerHookSubscriberBundle($bundle);

            $bundle = new «IF targets('1.3.x')»Zikula_HookManager_«ENDIF»SubscriberBundle('«appName»', 'subscriber.«areaPrefix».filter_hooks.«areaName»', 'filter_hooks', $this->__('«areaPrefix» «entity.nameMultiple.formatForDisplayCapital» Filter Hooks'));
            // A filter applied to the given area.
            $bundle->addEvent('filter', '«areaPrefix».filter_hooks.«areaName».filter');
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
