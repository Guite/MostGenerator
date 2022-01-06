package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * This class creates additional artifacts which can be helpful for Scribite integration.
 */
class Scribite {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    IMostFileSystemAccess fsa
    String docPath

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateScribitePlugins) {
            return
        }
        'Generating Scribite support'.printIfNotTesting(fsa)
        this.fsa = fsa

        docPath = getResourcesPath + 'public/scribite/'
        fsa.generateFile(docPath + 'integration.md', integration)

        pluginCk
        pluginQuill
        pluginSummernote
        pluginTinyMce
    }

    def private pluginCk(Application it) {
        val pluginPath = docPath + 'CKEditor/' + appName.formatForDB + '/'
        fsa.generateFile(pluginPath + 'plugin.js', ckPlugin)
    }

    def private pluginQuill(Application it) {
        val pluginPath = docPath + 'Quill/' + appName.formatForDB + '/'
        fsa.generateFile(pluginPath + 'plugin.js', quillPlugin)
    }

    def private pluginSummernote(Application it) {
        val pluginPath = docPath + 'Summernote/' + appName.formatForDB + '/'
        fsa.generateFile(pluginPath + 'plugin.js', summernotePlugin)
    }

    def private pluginTinyMce(Application it) {
        val pluginPath = docPath + 'TinyMce/' + appName.formatForDB + '/'
        fsa.generateFile(pluginPath + 'plugin.js', tinyPlugin)
        fsa.generateFile(pluginPath + 'plugin.min.js', tinyPlugin)
    }

    def private integration(Application it) '''
        # Scribite integration

        It is easy to include «appName» in your [Scribite editors](https://github.com/zikula-modules/Scribite/).
        «appName» contains already a popup for selecting «getLeadingEntity.nameMultiple.formatForDisplay»«IF entities.size() > 1» and other items«ENDIF».
        Please note that Scribite 6.0+ is required for this.
    '''

    def private ckPlugin(Application it) '''
        CKEDITOR.plugins.add('«appName.formatForDB»', {
            requires: 'popup',
            init: function (editor) {
                editor.addCommand('insert«appName»', {
                    exec: function (editor) {
                        «appName»FinderOpenPopup(editor, 'ckeditor');
                    }
                });
                editor.ui.addButton('«appName.formatForDB»', {
                    label: '«name.formatForDisplayCapital»',
                    command: 'insert«appName»',
                    icon: this.path.replace('scribite/CKEditor/«appName.formatForDB»', 'images') + 'admin.png'
                });
            }
        });
    '''

    def private quillPlugin(Application it) '''
        var «appName.toLowerCase» = function(quill, options) {
            setTimeout(function() {
                var button;

                button = jQuery('button[value=«appName.toLowerCase»]');

                button
                    .css('background', 'url(' + Zikula.Config.baseURL + Zikula.Config.baseURI + '/public/modules/«vendorAndName.toLowerCase»/images/admin.png) no-repeat center center transparent')
                    .css('background-size', '16px 16px')
                    .attr('title', '«name.formatForDisplayCapital»')
                ;

                button.click(function() {
                    «appName»FinderOpenPopup(quill, 'quill');
                });
            }, 1000);
        };
    '''

    def private summernotePlugin(Application it) '''
        ( function ($) {
            $.extend($.summernote.plugins, {
                /**
                 * @param {Object} context - context object has status of editor.
                 */
                '«appName.toLowerCase»': function (context) {
                    var self = this;

                    // ui provides methods to build ui elements.
                    var ui = $.summernote.ui;

                    // add button
                    context.memo('button.«appName.toLowerCase»', function () {
                        // create button
                        var button = ui.button({
                            contents: '<img src="' + Zikula.Config.baseURL + Zikula.Config.baseURI + '/public/modules/«vendorAndName.toLowerCase»/images/admin.png' + '" alt="«name.formatForDisplayCapital»" width="16" height="16" />',
                            tooltip: '«name.formatForDisplayCapital»',
                            click: function () {
                                «appName»FinderOpenPopup(context, 'summernote');
                            }
                        });

                        // create jQuery object from button instance.
                        var $button = button.render();

                        return $button;
                    });
                }
            });
        })(jQuery);
    '''

    def private tinyPlugin(Application it) '''
        /**
         * Initializes the plugin, this will be executed after the plugin has been created.
         * This call is done before the editor instance has finished it's initialization so use the onInit event
         * of the editor instance to intercept that event.
         *
         * @param {tinymce.Editor} ed Editor instance that the plugin is initialised in
         * @param {string} url Absolute URL to where the plugin is located
         */
        tinymce.PluginManager.add('«appName.formatForDB»', function(editor, url) {
            editor.ui.registry.addButton('«appName.formatForDB»', {
                icon: 'link',
                tooltip: '«name.formatForDisplayCapital»',
                onAction: function() {
                    «appName»FinderOpenPopup(editor, 'tinymce');
                }
            });
            editor.ui.registry.addMenuItem('«appName.formatForDB»', {
                text: '«name.formatForDisplayCapital»',
                icon: 'link',
                onAction: function() {
                    «appName»FinderOpenPopup(editor, 'tinymce');
                }
            });

            return {
                getMetadata: function() {
                    return {
                        title: '«name.formatForDisplayCapital»',
                        url: '«url»'
                    };
                }
            };
        });
    '''
}
