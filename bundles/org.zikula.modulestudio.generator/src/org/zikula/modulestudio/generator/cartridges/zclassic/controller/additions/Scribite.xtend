package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
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

    IFileSystemAccess fsa
    String docPath

    def generate(Application it, IFileSystemAccess fsa) {
        'Generating Scribite support'.printIfNotTesting(fsa)
        this.fsa = fsa

        docPath = getResourcesPath + 'scribite/'
        var fileName = 'integration.md'
        if (!shouldBeSkipped(docPath + fileName)) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'integration.generated.md'
            }
            fsa.generateFile(docPath + fileName, integration)
        }

        pluginCk
        pluginQuill
        pluginSummernote
        pluginTinyMce
    }

    def private pluginCk(Application it) {
        val pluginPath = docPath + 'CKEditor/' + appName.formatForDB + '/'

        var fileName = 'plugin.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'plugin.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, ckPlugin)
        }
    }

    def private pluginQuill(Application it) {
        var pluginPath = docPath + 'Quill/' + appName.formatForDB + '/'

        var fileName = 'plugin.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'plugin.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, quillPlugin)
        }
    }

    def private pluginSummernote(Application it) {
        var pluginPath = docPath + 'Summernote/' + appName.formatForDB + '/'

        var fileName = 'plugin.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'plugin.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, summernotePlugin)
        }
    }

    def private pluginTinyMce(Application it) {
        var pluginPath = docPath + 'TinyMce/' + appName.formatForDB + '/'

        var fileName = 'plugin.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'plugin.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, tinyPlugin)
        }
        fileName = 'plugin.min.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'plugin.min.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, tinyPlugin)
        }
    }

    def private integration(Application it) '''
        # SCRIBITE INTEGRATION

        It is easy to include «appName» in your [Scribite editors](https://github.com/zikula-modules/Scribite/).
        «appName» contains already a popup for selecting «getLeadingEntity.nameMultiple.formatForDisplay»«IF entities.size() > 1» and other items«ENDIF».
        Please note that Scribite 6.0+ is required for this.

        To activate the popup for the editor of your choice (currently supported: CKEditor, Quill, Summernote, TinyMCE)
        you only need to add the plugin to the list of extra plugins in the editor configuration.
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
                    .css('background', 'url(' + Zikula.Config.baseURL + Zikula.Config.baseURI + '/web/modules/«vendorAndName.toLowerCase»/images/admin.png) no-repeat center center transparent')
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
                            contents: '<img src="' + Zikula.Config.baseURL + Zikula.Config.baseURI + '/web/modules/«vendorAndName.toLowerCase»/images/admin.png' + '" alt="«name.formatForDisplayCapital»" width="16" height="16" />',
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
            var icon;

            icon = Zikula.Config.baseURL + Zikula.Config.baseURI + '/web/modules/«vendorAndName.toLowerCase»/images/admin.png';

            editor.addButton('«appName.formatForDB»', {
                //text: '«name.formatForDisplayCapital»',
                image: icon,
                onclick: function() {
                    «appName»FinderOpenPopup(editor, 'tinymce');
                }
            });
            editor.addMenuItem('«appName.formatForDB»', {
                text: '«name.formatForDisplayCapital»',
                context: 'tools',
                image: icon,
                onclick: function() {
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
