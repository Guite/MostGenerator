package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Styles {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    String cssPrefix

    /**
     * Entry point for application styles.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        cssPrefix = appName.toLowerCase

        var fileName = 'style.css'
        fsa.generateFile(getAppCssPath + fileName, appStyles)

        fileName = 'custom.css'
        fsa.generateFile(getAppCssPath + fileName, '/* this file is intended for custom styles */')

        if (generateExternalControllerAndFinder) {
            fileName = 'finder.css'
            fsa.generateFile(getAppCssPath + fileName, finderStyles)
        }
    }

    def private appStyles(Application it) '''
        «IF hasViewActions»
            /* view pages */
            div#z-maincontent.z-module-«name.formatForDB» table tbody tr td {
                vertical-align: top;
            }
            «IF hasSortable»
                .ui-state-highlight {
                    height: 40px;
                }
            «ENDIF»

        «ENDIF»
        «IF hasDisplayActions»
            /* display pages */
            .«cssPrefix»-display p.managelink {
                margin: 18px 0 0 18px;
            }

        «ENDIF»
        «IF hasGeographical»
            div.«cssPrefix»-mapcontainer {
                height: 400px;
            }

        «ENDIF»
        «IF hasTrees»
            .tree-container {
                border: 1px solid #ccc;
                /*width: 400px;*/
                float: left;
                margin-right: 16px;
            }

        «ENDIF»
        «IF hasColourFields»
            .«cssPrefix»-colour-picker {
                cursor: pointer;
            }

        «ENDIF»

        «validationStyles»

        /* hide legends if tabs are used as both contain the same labels */
        div.«name.formatForDB»-edit .tab-pane legend {
            display: none;
        }
        «autoCompletion»
        «viewAdditions»
        «IF hasTrees»

            .vakata-context, .vakata-context ul {
                z-index: 100;
            }
        «ENDIF»
    '''

    def private validationStyles(Application it) '''
        /* validation */
        div.form-group input:required, div.form-group textarea:required, div.form-group select:required {
            /*border: 1px solid #00a8e6;*/
            background-color: #fff;
        }
        div.form-group input:required:valid, div.form-group textarea:required:valid, div.form-group select:required:valid {
            /*border: 1px solid green;*/
        }
        div.form-group input:required:invalid, div.form-group textarea:required:invalid, div.form-group select:required:invalid {
            border: 1px solid red;
        }
    '''

    def private autoCompletion(Application it) '''
        «val joinRelations = getJoinRelations»
        «IF !joinRelations.empty || hasUiHooksProviders»

            /* edit pages */
            «IF !joinRelations.empty»
                div.«cssPrefix»-relation-leftside {
                    float: left;
                    width: 25%;
                }

                div.«cssPrefix»-relation-rightside {
                    float: right;
                    width: 65%;
                }

            «ENDIF»
            .ui-autocomplete {
                max-height: 150px;
                overflow-y: auto;
                overflow-x: hidden;
            }

            * html .ui-autocomplete {
                height: 150px;
            }

            .ui-autocomplete-loading {
                background: white url("../../../../../../web/bundles/core/images/ajax/indicator_arrows.gif") right center no-repeat;
            }

            .ui-autocomplete .suggestion {
                margin: 0;
                padding: 0.2em 0 0.2em 20px;
                list-style-type: none;
                line-height: 1.4em;
                cursor: pointer;
                display: block;
                background-position: 2px 2px;
                background-repeat: no-repeat;
                background-color: #fff;
            }

            .ui-autocomplete .suggestion:before {
                content: "\f0da";
                font-family: 'FontAwesome';
                font-style: normal;
                color: #7db441;
                margin-right: 15px;
                position: absolute;
                left: 20px;
            }

            .ui-autocomplete .suggestion img {
                max-width: 20px;
                max-height: 20px;
            }

            .ui-autocomplete .suggestion .ui-state-active {
                background-color: #ffb;
            }

            .ui-autocomplete .suggestion .media-body {
                font-size: 10px;
                color: #888;
            }
            .ui-autocomplete .suggestion .media-body .media-heading {
                font-size: 12px;
                line-height: 1.2em;
            }
        «ENDIF»
    '''

    def private viewAdditions(Application it) '''
        «IF hasViewActions»

            /** fix dropdown visibility inside responsive tables */
            div.«cssPrefix»-view .table-responsive {
                min-height: 300px;
            }
            «viewFilterForm»

            div.«cssPrefix»-view .avatar img {
                width: auto;
                max-height: 24px;
            }
        «ENDIF»
        «IF hasCategorisableEntities»

            @media (max-width: 767px) {
                div.form-group div.category-selector {
                    height: auto;
                    padding: 0;
                }
            }
        «ENDIF»
        «IF hasLoggable»

            div.«cssPrefix»-history .table-responsive .table > tbody > tr > td.diff-old {
                background-color: #ffecec !important;
            }
            div.«cssPrefix»-history .table-responsive .table > tbody > tr > td.diff-new {
                background-color: #eaffea !important;
            }
            div.«cssPrefix»-history .img-responsive {
                max-width: 20px;
            }
        «ENDIF»
    '''

    def private viewFilterForm(Application it) '''
        div.«cssPrefix»-view form.«cssPrefix»-quicknav {
            margin: 10px 0;
            padding: 8px 12px;
            border: 1px solid #ccc;
        }

        div.«cssPrefix»-view form.«cssPrefix»-quicknav fieldset {
            padding: 3px 10px;
            margin-bottom: 0;
        }

        div.«cssPrefix»-view form.«cssPrefix»-quicknav fieldset h3 {
            margin-top: 0;
            display: none;
        }

        div.«cssPrefix»-view form.«cssPrefix»-quicknav fieldset label {
            margin-right: 5px;
        }
    '''

    def private finderStyles(Application it) '''
        body {
            background-color: #ddd;
            margin: 10px;
            text-align: left;
        }

        #«cssPrefix»ItemContainer {
            background-color: #eee;
            height: 300px;
            overflow: auto;
            padding: 5px;
        }

        #«cssPrefix»ItemContainer ul {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        #«cssPrefix»ItemContainer a {
            color: #000;
            margin: 0.1em 0.2em;
            text-decoration: underline;
        }
        #«cssPrefix»ItemContainer a:hover,
        #«cssPrefix»ItemContainer a:focus,
        #«cssPrefix»ItemContainer a:active {
            color: #900;
            text-decoration: none;
        }
        «IF hasImageFields»

            #«cssPrefix»ItemContainer a img {
                border: none;
            }

            #«cssPrefix»ItemContainer a img {
                border: 1px solid #ccc;
                background-color: #f5f5f5;
                padding: 0.5em;
            }
            #«cssPrefix»ItemContainer a:hover img,
            #«cssPrefix»ItemContainer a:focus img,
            #«cssPrefix»ItemContainer a:active img {
                background-color: #fff;
            }
        «ENDIF»

        .«cssPrefix»-finderform fieldset,
        .«cssPrefix»-finderform fieldset legend {
            background-color: #fff;
            border: none;
        }
    '''
}
