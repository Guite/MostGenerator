package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * This class creates additional artifacts which can be helpful for Scribite integration.
 */
class Scribite {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    IFileSystemAccess fsa
    String docPath

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating Scribite support')
        this.fsa = fsa

        docPath = getAppDocPath + 'scribite/'
        var fileName = 'integration.md'
        if (!shouldBeSkipped(docPath + fileName)) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'integration.generated.md'
            }
            fsa.generateFile(docPath + fileName, integration)
        }

        docPath = docPath + 'plugins/'

        pluginAloha
        pluginCk
        pluginMarkItUp
        pluginNicEdit
        pluginTinyMce
        pluginWym
        pluginWysi
        pluginXinha
        pluginYui
    }

    def private pluginAloha(Application it) {
        //createPlaceholder(fsa, docPath + 'Aloha/vendor/aloha/')
    }

    def private pluginCk(Application it) {
        val pluginPath = docPath + 'CKEditor/vendor/ckeditor/plugins/' + name.formatForDB + '/'

        var fileName = 'plugin.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'plugin.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, ckPlugin)
        }
        fileName = 'lang/de.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'lang/de.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, ckLangDe)
        }
        fileName = 'lang/en.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'lang/en.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, ckLangEn)
        }
        fileName = 'lang/nl.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'lang/nl.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, ckLangNl)
        }
        createPlaceholder(fsa, pluginPath + 'images/')
    }

    def private pluginMarkItUp(Application it) {
        //createPlaceholder(fsa, docPath + 'MarkItUp/vendor/markitup/')
    }

    def private pluginNicEdit(Application it) {
        //createPlaceholder(fsa, docPath + 'NicEdit/vendor/nicedit/')
    }

    def private pluginTinyMce(Application it) {
        var pluginPath = docPath + 'TinyMce/vendor/tinymce/plugins/' + name.formatForDB + '/'

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
        fileName = 'langs/de.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'langs/de.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, tinyLangDe)
        }
        fileName = 'langs/en.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'langs/en.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, tinyLangEn)
        }
        fileName = 'langs/nl.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = 'langs/nl.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, tinyLangNl)
        }
        createPlaceholder(fsa, pluginPath + 'images/')
    }

    def private pluginWym(Application it) {
        //createPlaceholder(fsa, docPath + 'WYMeditor/vendor/wymeditor/plugins/' + name.formatForDB + '/')
    }

    def private pluginWysi(Application it) {
        //createPlaceholder(fsa, docPath + 'Wysihtml5/javascript/')
    }

    def private pluginXinha(Application it) {
        var pluginPath = docPath + 'Xinha/vendor/xinha/plugins/' + appName + '/'

        var fileName = appName + '.js'
        if (!shouldBeSkipped(pluginPath + fileName)) {
            if (shouldBeMarked(pluginPath + fileName)) {
                fileName = appName + '.generated.js'
            }
            fsa.generateFile(pluginPath + fileName, xinhaPlugin)
        }

        createPlaceholder(fsa, pluginPath + 'images/')
    }

    def private pluginYui(Application it) {
        //createPlaceholder(fsa, docPath + 'YUI/')
    }

    def private integration(Application it) '''
        SCRIBITE INTEGRATION
        --------------------

        It is easy to include «appName» in your Scribite editors.
        «appName» contains already the a popup for selecting «getLeadingEntity.nameMultiple.formatForDisplay»«IF entities.size() > 1» and other items«ENDIF».
        Please note that Scribite 5.0 is required for this.

        To activate the popup for the editor of your choice (currently supported: CKEditor, TinyMCE, Xinha)
        check if the plugins for «appName» are in Scribite/plugins/EDITOR/vendor/plugins.
        If not then copy from
            «rootFolder»/«IF targets('1.3.x')»«appName»/docs«ELSE»«getAppDocPath»«ENDIF»/scribite/plugins into modules/Scribite/plugins.
    '''

    def private ckPlugin(Application it) '''
        CKEDITOR.plugins.add('«appName.formatForDB»', {
            requires: 'popup',
            lang: 'en,nl,de',
            init: function (editor) {
                editor.addCommand('insert«appName»', {
                    exec: function (editor) {
                        «IF targets('1.3.x')»
                            var url = Zikula.Config.baseURL + Zikula.Config.entrypoint + '?module=«appName»&type=external&func=finder&editor=ckeditor';
                        «ELSE»
                            var url = Routing.generate('«appName.formatForDB»_external_finder', { editor: 'ckeditor' });
                        «ENDIF»
                        // call method in «appName»«IF targets('1.3.x')»_f«ELSE».F«ENDIF»inder.js and provide current editor
                        «appName»FinderCKEditor(editor, url);
                    }
                });
                editor.ui.addButton('«appName.formatForDB»', {
                    label: editor.lang.«appName.formatForDB».title,
                    command: 'insert«appName»',
                    icon: this.path + 'images/«appName».png'
                });
            }
        });
    '''

    def private ckLangDe(Application it) '''
        CKEDITOR.plugins.setLang('«appName.formatForDB»', 'de', {
            title : '«appName»-Objekt einfügen',
            alt: '«appName»-Objekt einfügen'
        });
    '''

    def private ckLangEn(Application it) '''
        CKEDITOR.plugins.setLang('«appName.formatForDB»', 'en', {
            title: 'Insert «appName» object',
            alt: 'Insert «appName» object'
        });
    '''

    def private ckLangNl(Application it) '''
        CKEDITOR.plugins.setLang('«appName.formatForDB»', 'nl', {
            title : '«appName» Object invoegen',
            alt: '«appName» Object invoegen'
        });
    '''

    def private tinyPlugin(Application it) '''
        /**
         * plugin.js
         *
         * Copyright 2009, Moxiecode Systems AB
         * Released under LGPL License.
         *
         * License: http://tinymce.moxiecode.com/license
         * Contributing: http://tinymce.moxiecode.com/contributing
         */

        (function () {
            // Load plugin specific language pack
            tinymce.PluginManager.requireLangPack('«name.formatForDB»');

            tinymce.create('tinymce.plugins.«appName»Plugin', {
                /**
                 * Initializes the plugin, this will be executed after the plugin has been created.
                 * This call is done before the editor instance has finished it's initialization so use the onInit event
                 * of the editor instance to intercept that event.
                 *
                 * @param {tinymce.Editor} ed Editor instance that the plugin is initialised in
                 * @param {string} url Absolute URL to where the plugin is located
                 */
                init : function (ed, url) {
                    // Register the command so that it can be invoked by using tinyMCE.activeEditor.execCommand('mce«appName»');
                    ed.addCommand('mce«appName»', function () {
                        ed.windowManager.open({
                            «IF targets('1.3.x')»
                                file : Zikula.Config.baseURL + Zikula.Config.entrypoint + '?module=«appName»&type=external&func=finder&editor=tinymce',
                            «ELSE»
                                file : Routing.generate('«appName.formatForDB»_external_finder', { editor: 'tinymce' }),
                            «ENDIF»
                            width : (screen.width * 0.75),
                            height : (screen.height * 0.66),
                            inline : 1,
                            scrollbars : true,
                            resizable : true
                        }, {
                            plugin_url : url, // Plugin absolute URL
                            some_custom_arg : 'custom arg' // Custom argument
                        });
                    });

                    // Register «name.formatForDB» button
                    ed.addButton('«name.formatForDB»', {
                        title : '«name.formatForDB».desc',
                        cmd : 'mce«appName»',
                        image : url + '/images/«appName».png',
                        onPostRender: function() {
                            var ctrl = this;
        
                            // Add a node change handler, selects the button in the UI when an anchor or an image is selected
                            ed.on('NodeChange', function(e) {
                                ctrl.active(e.element.nodeName == 'A' || e.element.nodeName == 'IMG');
                            });
                        }
                    });
                },

                /**
                 * Creates control instances based in the incomming name. This method is normally not
                 * needed since the addButton method of the tinymce.Editor class is a more easy way of adding buttons
                 * but you sometimes need to create more complex controls like listboxes, split buttons etc then this
                 * method can be used to create those.
                 *
                 * @param {String} n Name of the control to create
                 * @param {tinymce.ControlManager} cm Control manager to use in order to create new control
                 * @return {tinymce.ui.Control} New control instance or null if no control was created
                 */
                createControl : function (n, cm) {
                    return null;
                },

                /**
                 * Returns information about the plugin as a name/value array.
                 * The current keys are longname, author, authorurl, infourl and version.
                 *
                 * @return {Object} Name/value array containing information about the plugin
                 */
                getInfo : function () {
                    return {
                        longname : '«appName» for tinymce',
                        author : '«author»',
                        authorurl : '«url»',
                        infourl : '«url»',
                        version : '«version»'
                    };
                }
            });

            // Register plugin
            tinymce.PluginManager.add('«name.formatForDB»', tinymce.plugins.«appName»Plugin);
        }());
    '''

    def private tinyLangDe(Application it) '''
        tinyMCE.addI18n('de.«name.formatForDB»', {
            desc : '«appName»-Objekt einfügen'
        });
    '''

    def private tinyLangEn(Application it) '''
        tinyMCE.addI18n('en.«name.formatForDB»', {
            desc : 'Insert «appName» object'
        });
    '''

    def private tinyLangNl(Application it) '''
        tinyMCE.addI18n('nl.«name.formatForDB»', {
            desc : '«appName» Object invoegen'
        });
    '''

    def private xinhaPlugin(Application it) '''
        // «appName» plugin for Xinha
        // developed by «author»
        //
        // requires «appName» module («url»)
        //
        // Distributed under the same terms as xinha itself.
        // This notice MUST stay intact for use (see license.txt).

        'use strict';

        function «appName»(editor) {
            var cfg, self;

            this.editor = editor;
            cfg = editor.config;
            self = this;

            cfg.registerButton({
                id       : '«appName»',
                tooltip  : 'Insert «appName» object',
                image    : _editor_url + 'plugins/«appName»/images/«appName».png',
                textMode : false,
                action   : function (editor) {
                    «IF targets('1.3.x')»
                        var url = Zikula.Config.baseURL + 'index.php'/*Zikula.Config.entrypoint*/ + '?module=«appName»&type=external&func=finder&editor=xinha';
                    «ELSE»
                        var url = Routing.generate('«appName.formatForDB»_external_finder', { editor: 'xinha' });
                    «ENDIF»
                    «appName»FinderXinha(editor, url);
                }
            });
            cfg.addToolbarElement('«appName»', 'insertimage', 1);
        }

        «appName»._pluginInfo = {
            name          : '«appName» for xinha',
            version       : '«version»',
            developer     : '«author»',
            developer_url : '«url»',
            sponsor       : 'ModuleStudio «msVersion»',
            sponsor_url   : '«msUrl»',
            license       : 'htmlArea'
        };
    '''
}
