package org.zikula.modulestudio.generator.cartridges.zclassic.view

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Styles {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    /**
     * Entry point for application styles.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(getAppCssPath + 'style.css', appStyles)
        fsa.generateFile(getAppCssPath + 'finder.css', finderStyles)
    }

    def private appStyles(Application it) '''
        /* view pages */
        div#z-maincontent.z-module-«name.formatForDB» table tbody tr td {
            vertical-align: top;
        }

        /* display pages */
        .«appName.toLowerCase»-display.withrightbox div.z-panel-content {
            float: left;
            width: 79%;
        }
        .«appName.toLowerCase»-display div.«appName.toLowerCase»rightbox {
            float: right;
            margin: 0 1em;
            padding: .5em;
            width: 20%;
            /*border: 1px solid #666;*/
        }

        .«appName.toLowerCase»-display div.«appName.toLowerCase»rightbox h3 {
            color: #333;
            font-weight: 400;
            border-bottom: 1px solid #CCC;
            padding-bottom: 8px;
        }

        .«appName.toLowerCase»-display div.«appName.toLowerCase»rightbox p.manageLink {
            margin-left: 18px;
        }
        «IF hasGeographical»

            div.«appName.toLowerCase»mapcontainer {
                height: 400px;
            }
        «ENDIF»
        «IF hasTrees»

            .z-treecontainer {
                border: 1px solid #ccc;
                width: 400px;
                float: left;
                margin-right: 16px;
            }
        «ENDIF»
        «IF hasColourFields»
            .«appName.formatForDB»ColourPicker {
                cursor: pointer;
            }
        «ENDIF»
        «validationStyles»
        «autoCompletion»
        «viewFilterForm»
        «IF interactiveInstallation»

            dl#«name.formatForDB»featurelist {
                margin-left: 50px;
            }
            dl#«name.formatForDB»featurelist dt {
                font-weight: 700;
            }
        «ENDIF»
    '''

    def private validationStyles(Application it) '''
        /* validation */
        div.z-formrow input.required, div.z-formrow textarea.required {
            border: 1px solid #00a8e6;
        }
        div.z-formrow input.validation-failed, div.z-formrow textarea.validation-failed {
            border: 1px solid #f30;
            color: #f30;
        }
        div.z-formrow input.validation-passed, div.z-formrow textarea.validation-passed {
            border: 1px solid #0c0;
            color: #000;
        }

        .validation-advice {
            margin: 5px 0;
            padding: 5px;
            background-color: #f90;
            color: #fff;
            font-weight: 700;
        }
    '''

    def private autoCompletion(Application it) '''
        «val hasUserFields = hasUserFields»
        «val hasImageFields = hasImageFields»
        «val joinRelations = getJoinRelations»
        «IF !joinRelations.empty || hasUserFields»

            /* edit pages */
            «IF !joinRelations.empty»
                div.«prefix»RelationLeftSide {
                    float: left;
                    width: 25%;
                }

                div.«prefix»RelationRightSide {
                    float: right;
                    width: 65%;
                }

            «ENDIF»
            /* hide legends if z-panels are used as both contain the same labels */
            div.«name.formatForDB»-edit .z-panel-content legend {
                display: none;
            }

            «IF hasUserFields»
                div.«prefix»LiveSearchUser {
                    margin: 0;
                }

            «ENDIF»
            «/*required for IE*/»
            div.«prefix»AutoCompleteWrap {
                position: absolute;
                height: 40px;
                margin: 0;
                padding: 0;
                left: 260px;
                top: 10px;
            }

            div.«prefix»AutoComplete«IF hasUserFields»,
            div.«prefix»AutoCompleteUser«ENDIF»«IF hasImageFields»,
            div.«prefix»AutoCompleteWithImage«ENDIF» {
                position: relative !important;
                top: 2px !important;
                width: 191px !important;
                background-color: #fff;
                border: 1px solid #888;
                margin: 0;
                padding: 0;
            }

            div.«prefix»AutoComplete«IF hasImageFields»,
            div.«prefix»AutoCompleteWithImage«ENDIF» {
                left: 0 !important;
            }
            «IF hasUserFields»
                div.«prefix»AutoCompleteUser {
                    left: 29% !important;
                }

            «ENDIF»
            div.«prefix»AutoComplete ul«IF hasUserFields»,
            div.«prefix»AutoCompleteUser ul«ENDIF»«IF hasImageFields»,
            div.«prefix»AutoCompleteWithImage ul«ENDIF» {
                margin: 0;
                padding: 0;
            }

            div.«prefix»AutoComplete ul li«IF hasUserFields»,
            div.«prefix»AutoCompleteUser ul li«ENDIF»«IF hasImageFields»,
            div.«prefix»AutoCompleteWithImage ul li«ENDIF» {
                margin: 0;
                padding: 0.2em 0 0.2em 20px;
                list-style-type: none;
                line-height: 1.4em;
                cursor: pointer;
                display: block;
                background-position: 2px 2px;
                background-repeat: no-repeat;
            }

            div.«prefix»AutoComplete ul li {
                background-image: url("../../../images/icons/extrasmall/tab_right.png");
            }
            «IF hasUserFields»
                div.«prefix»AutoCompleteUser ul li {
                    background-image: url("../../../images/icons/extrasmall/user.png");
                }
            «ENDIF»
            «IF hasImageFields»
                div.«prefix»AutoCompleteWithImage ul li {
                    background-image: url("../../../images/icons/extrasmall/agt_Multimedia.png");
                }
            «ENDIF»

            div.«prefix»AutoComplete ul li.selected«IF hasUserFields»,
            div.«prefix»AutoCompleteUser ul li.selected«ENDIF»«IF hasImageFields»,
            div.«prefix»AutoCompleteWithImage ul li.selected«ENDIF» {
                background-color: #ffb;
            }

            «IF hasImageFields || !joinRelations.empty»
                div.«prefix»AutoComplete ul li div.itemtitle«IF hasImageFields»,
                div.«prefix»AutoCompleteWithImage ul li div.itemtitle«ENDIF» {
                    font-weight: 700;
                    font-size: 12px;
                    line-height: 1.2em;
                }
                div.«prefix»AutoComplete ul li div.itemdesc«IF hasImageFields»,
                div.«prefix»AutoCompleteWithImage ul li div.itemdesc«ENDIF» {
                    font-size: 10px;
                    color: #888;
                }

                «IF !joinRelations.empty»
                    button.«prefix»InlineButton {
                        margin-top: 1em;
                    }
                «ENDIF»
            «ENDIF»

        «ENDIF»
    '''

    def private viewFilterForm(Application it) '''
        «IF !getAllControllers.map(e|e.hasActions('view')).empty»
            div.«appName.toLowerCase»-view form.«prefix»QuickNavForm {
                margin: 10px 0;
                padding: 8px 12px;
                border: 1px solid #ccc;
            }

            div.«appName.toLowerCase»-view form.«prefix»QuickNavForm fieldset {
                padding: 3px 10px;
                margin-bottom: 0;
            }

            div.«appName.toLowerCase»-view form.«prefix»QuickNavForm fieldset h3 {
                margin-top: 0;
            }

            div.«appName.toLowerCase»-view form.«prefix»QuickNavForm fieldset #num {
                width: 50px;
                text-align: right;
            }
        «ENDIF»
    '''

    def private finderStyles(Application it) '''
        body {
            background-color: #ddd;
            margin: 10px;
            text-align: left;
        }

        .«prefix()»form fieldset,
        .«prefix()»form fieldset legend {
            background-color: #fff;
            border: none;
        }

        #«prefix()»itemcontainer {
            background-color: #eee;
            height: 300px;
            overflow: auto;
            padding: 5px;
        }

        #«prefix()»itemcontainer ul {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        #«prefix()»itemcontainer a {
            color: #000;
            margin: 0.1em 0.2em;
            text-decoration: underline;
        }
        #«prefix()»itemcontainer a:hover,
        #«prefix()»itemcontainer a:focus,
        #«prefix()»itemcontainer a:active {
            color: #900;
            text-decoration: none;
        }

        #«prefix()»itemcontainer a img {
            border: none;
        }

        #«prefix()»itemcontainer a img {
            border: 1px solid #ccc;
            background-color: #f5f5f5;
            padding: 0.5em;
        }
        #«prefix()»itemcontainer a:hover img,
        #«prefix()»itemcontainer a:focus img,
        #«prefix()»itemcontainer a:active img {
            background-color: #fff;
        }
    '''
}
