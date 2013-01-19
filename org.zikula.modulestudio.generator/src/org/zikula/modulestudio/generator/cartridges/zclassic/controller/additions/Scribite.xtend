package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * This class creates additional artifacts which can be helpful for Scribite integration.
 */
class Scribite {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating Scribite support')
        var docPath = getAppDocPath + 'scribite/'
        fsa.generateFile(docPath + 'integration.txt', integration)

        docPath = docPath + 'plugins/'

        //fsa.generateFile(docPath + 'Aloha/vendor/aloha/index.html', msUrl)

        var pluginPath = docPath + 'CKEditor/vendor/ckeditor/plugins/' + name.formatForDB + '/'
        fsa.generateFile(pluginPath + 'plugin.js', ckPlugin)
        fsa.generateFile(pluginPath + 'lang/de.js', ckLangDe)
        fsa.generateFile(pluginPath + 'lang/en.js', ckLangEn)
        fsa.generateFile(pluginPath + 'lang/nl.js', ckLangNl)

        //fsa.generateFile(docPath + 'MarkItUp/vendor/markitup/index.html', msUrl)

        //fsa.generateFile(docPath + 'NicEdit/vendor/nicedit/index.html', msUrl)

        pluginPath = docPath + 'TinyMCE/vendor/tinymce/plugins/' + name.formatForDB + '/'
        fsa.generateFile(pluginPath + 'editor_plugin.js', tinyPlugin)
        fsa.generateFile(pluginPath + 'langs/de.js', tinyLangDe)
        fsa.generateFile(pluginPath + 'langs/en.js', tinyLangEn)
        fsa.generateFile(pluginPath + 'langs/nl.js', tinyLangNl)

        pluginPath = docPath + 'WYMeditor/vendor/wymeditor/plugins/' + name.formatForDB + '/'
        //fsa.generateFile(pluginPath + 'index.html', msUrl)

        //fsa.generateFile(docPath + 'Wysihtml5/javascript/index.html', msUrl)

        pluginPath = docPath + 'Xinha/vendor/xinha/plugins/' + appName + '/'
        fsa.generateFile(pluginPath + appName + '.js', xinhaPlugin)

        //fsa.generateFile(docPath + 'YUI/index.html', msUrl)
    }

    def private integration(Application it) '''
        SCRIBITE INTEGRATION
        --------------------

        It is easy to include «appName» in your Scribite editors.
        While «appName» contains already the a popup for selecting «getLeadingEntity.nameMultiple.formatForDisplay» and other items,
        the actual Scribite enhancements must be done manually for Scribite <= 4.3.
        From Scribite 5.0 onwards the integration is automatic. The necessary javascript is loaded via event system and the
        plugins are already in the Scribite package.

        Just follow these few steps to complete the integration for Scribite <= 4.3:
          1. Open modules/Scribite/lib/Scribite/Api/User.php in your favourite text editor.
          2. Search for
                if (\ModUtil::available('SimpleMedia')) {
                    \PageUtil::AddVar('javascript', 'modules/SimpleMedia/«IF targets('1.3.5')»javascript«ELSE»Resources/public/js«ENDIF»/findItem.js');
                }
          3. Below this add
                if (\ModUtil::available('«appName»')) {
                    \PageUtil::AddVar('javascript', 'modules/«appName»/«IF targets('1.3.5')»javascript«ELSE»Resources/public/js«ENDIF»/«appName»_finder.js');
                }
          4. Copy or move all files from «IF targets('1.3.5')»modules/«appName»«ELSE»Resources«ENDIF»/docs/scribite/plugins/ into modules/Scribite/plugins/.

        Just follow these few steps to complete the integration for Scribite >= 5.0:
         1. Check if the plugins for «appName» are in Scribite/plugins/EDITOR/vendor/plugins. If not then copy from
            modules/«appName»/«IF targets('1.3.5')»docs«ELSE»«getAppDocPath»«ENDIF»/scribite/plugins into modules/Scribite/plugins.
    '''

    def private ckPlugin(Application it) '''
        /**
         * @license Copyright (c) 2003-2013, «appName» - Erik Spaan. All rights reserved.
         */

        CKEDITOR.plugins.add('«appName»', {
            requires: 'popup',
            lang: 'en,nl,de',
            init: function (editor) {
                editor.addCommand('insert«appName»', {
                    exec: function (editor) {
                        var url = Zikula.Config.baseURL + Zikula.Config.entrypoint + '?module=«appName»&type=external&func=finder&editor=ckeditor';
                        // call method in «appName»_Finder.js and also give current editor
                        «appName»FinderCKEditor(editor, url);
                    }
                });
                editor.ui.addButton('«appName.formatForDB»', {
                    label: 'Insert «appName» object',
                    command: 'insert«appName»',
                 // icon: this.path + 'images/ed_«appName.formatForDB».png'
                    icon: '/images/icons/extrasmall/favorites.png'
                });
            }
        });
    '''

    def private ckLangDe(Application it) '''
        tinyMCE.addI18n('de.«name.formatForDB»', {
            title : '«appName»-Objekt einfügen',
            alt: '«appName»-Objekt einfügen'
        });
    '''

    def private ckLangEn(Application it) '''
        CKEDITOR.plugins.setLang('«name.formatForDB»', 'en', {
            title: 'Insert «appName» object',
            alt: 'Insert «appName» object'
        });
    '''

    def private ckLangNl(Application it) '''
        tinyMCE.addI18n('nl.«name.formatForDB»', {
            title : '«appName» Object invoegen',
            alt: '«appName» Object invoegen'
        });
    '''

    def private tinyPlugin(Application it) '''
        /**
         * editor_plugin_src.js
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
                 * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
                 * @param {string} url Absolute URL to where the plugin is located.
                 */
                init : function (ed, url) {
                    // Register the command so that it can be invoked by using tinyMCE.activeEditor.execCommand('mce«appName»');
                    ed.addCommand('mce«appName»', function () {
                        ed.windowManager.open({
                            file : Zikula.Config.baseURL + Zikula.Config.entrypoint + '?module=«appName»&type=external&func=finder&editor=tinymce',
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
                     // image : url + '/img/«appName».gif'
                        image : '/images/icons/extrasmall/favorites.png'
                    });

                    // Add a node change handler, selects the button in the UI when a image is selected
                    ed.onNodeChange.add(function (ed, cm, n) {
                        cm.setActive('«name.formatForDB»', n.nodeName === 'IMG');
                    });
                },

                /**
                 * Creates control instances based in the incomming name. This method is normally not
                 * needed since the addButton method of the tinymce.Editor class is a more easy way of adding buttons
                 * but you sometimes need to create more complex controls like listboxes, split buttons etc then this
                 * method can be used to create those.
                 *
                 * @param {String} n Name of the control to create.
                 * @param {tinymce.ControlManager} cm Control manager to use inorder to create new control.
                 * @return {tinymce.ui.Control} New control instance or null if no control was created.
                 */
                createControl : function (n, cm) {
                    return null;
                },

                /**
                 * Returns information about the plugin as a name/value array.
                 * The current keys are longname, author, authorurl, infourl and version.
                 *
                 * @return {Object} Name/value array containing information about the plugin.
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
             // image    : _editor_url + 'plugins/«appName»/img/ed_«appName».gif',
                image    : '/images/icons/extrasmall/favorites.png',
                textMode : false,
                action   : function (editor) {
                    var url = Zikula.Config.baseURL + 'index.php'/*Zikula.Config.entrypoint*/ + '?module=«appName»&type=external&func=finder&editor=xinha';
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
