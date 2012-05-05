package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DisplayFunctions {
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for the javascript file with display functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(getAppSourcePath(appName) + 'javascript/' + appName + '.js', generate)
    }

    def private generate(Application it) '''

        «IF !getJoinRelations.isEmpty»
            «initRelationWindow»
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»
            «initToggle»

            «toggleFlag»
        «ENDIF»
    '''

    def private initRelationWindow(Application it) '''
        /**
         * Helper function to create new Zikula.UI.Window instances.
         * For edit forms we use "iframe: true" to ensure file uploads work without problems.
         * For all other windows we use "iframe: false" because we want the escape key working.
         */
        function «prefix»InitInlineWindow(containerElem, title)
        {
            // show the container (hidden for users without JavaScript)
            containerElem.show();

            // define the new window instance
            var newWindow = new Zikula.UI.Window(
                containerElem,
                {
                    minmax: true,
                    resizable: true,
                    title: title,
                    width: 600,
                    initMaxHeight: 400,
                    modal: false,
                    iframe: false
                }
            );

            // return the instance
            return newWindow;
        }

    '''

    def private initToggle(Application it) '''
        /**
         * Initialise ajax-based toggle for boolean fields.
         */
        function «prefix»InitToggle(objectType, fieldName, itemId)
        {
            var idSuffix = fieldName.toLowerCase() + itemId;
            if ($('toggle' + idSuffix) == undefined) {
                return;
            }
            $('toggle' + idSuffix).observe('click', function() {
                «prefix»ToggleFlag(objectType, fieldName, itemId);
            }).show();
        }
    '''

    def private toggleFlag(Application it) '''
        /**
         * Toggle a certain flag for a given item.
         */
        function «prefix»ToggleFlag(objectType, fieldName, itemId)
        {
            var pars = 'ot=' + objectType + '&field=' + fieldName + '&id=' + itemId;

            new Zikula.Ajax.Request(
                Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=toggleFlag',
                {
                    method: 'post',
                    parameters: pars,
                    onComplete: function(req) {
                        if (!req.isSuccess()) {
                            Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_«appName»'));
                            return;
                        }
                        var data = req.getData();
                        /*if (data.message) {
                            Zikula.UI.Alert(data.message, Zikula.__('Success', 'module_«appName»'));
                        }*/

                        var idSuffix = fieldName.toLowerCase() + '_' + itemId;
                        var state = data.state;
                        if (state === true) {
                            $('no' + idSuffix).hide();
                            $('yes' + idSuffix).show();
                        } else {
                            $('yes' + idSuffix).hide();
                            $('no' + idSuffix).show();
                        }
                    }
                }
            );
        }
    '''
}
