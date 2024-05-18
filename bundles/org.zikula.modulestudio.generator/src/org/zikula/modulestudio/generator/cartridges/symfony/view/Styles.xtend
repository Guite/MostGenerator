package org.zikula.modulestudio.generator.cartridges.symfony.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ItemActionsStyle
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Styles {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
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

        if (generatePdfSupport) {
            fileName = 'pdf.css'
            fsa.generateFile(getAppCssPath + fileName, pdfStyles)
        }

        if (generateTechnicalDocumentation) {
            fileName = 'techdocs.css'
            fsa.generateFile(getAppCssPath + fileName, techDocsStyles)
        }
    }

    def private appStyles(Application it) '''
        «IF hasIndexActions»
            /* index pages */
            div#z-maincontent.z-module-«name.formatForDB» table tbody tr td {
                vertical-align: top;
            }
            «IF hasSortable»
                .ui-state-highlight {
                    height: 40px;
                }
            «ENDIF»

        «ENDIF»
        «IF hasDetailActions»
            /* detail pages */
            .«cssPrefix»-detail p.managelink {
                margin: 18px 0 0 18px;
            }

            «IF detailActionsStyle == ItemActionsStyle.DROPDOWN»
                .z-module-«appName.formatForDB» h2 .dropdown.item-actions,
                .z-module-«appName.formatForDB» h3 .dropdown.item-actions {
                    display: inline;
                    font-size: 18px;
                }

            «ENDIF»
        «ENDIF»
        «IF hasGeographical»
            div.«cssPrefix»-mapcontainer {
                height: 400px;
            }
            «IF hasIndexActions»
                «cssPrefix»-index.«cssPrefix»-map div.«cssPrefix»-mapcontainer {
                    height: 800px;
                }
                «cssPrefix»-index.«cssPrefix»-map .detail-marker {
                    width: auto !important;
                    height: auto !important;
                    background-color: #f5f5f5;
                    border: 1px solid #666;
                    padding: 15px 10px 10px;
                    border-radius: 4px;
                }
            «ENDIF»

        «ENDIF»
        «IF hasTrees»
            .tree-container {
                border: 1px solid #ccc;
                /*width: 400px;*/
                float: left;
                margin-right: 16px;
            }

        «ENDIF»

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

    def private autoCompletion(Application it) '''
        «val joinRelations = getJoinRelations»
        «IF !joinRelations.empty»

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
                background: white url("../../zikulausers/images/indicator_arrows.gif") right center no-repeat;
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
                content: "\f105";
                font-family: 'Font Awesome 5 Free';
                font-weight: 900;
                color: #7db441;
                position: absolute;
                left: 10px;
                top: 2px;
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
        «IF hasIndexActions»

            /** fix dropdown visibility inside responsive tables */
            div.«cssPrefix»-index .table-responsive {
                min-height: 300px;
            }
            «viewFilterForm»

            div.«cssPrefix»-index .avatar img {
                width: auto;
                max-height: 24px;
            }
        «ENDIF»
        «IF hasLoggable»

            div.«cssPrefix»-history .table-responsive .table > tbody > tr > td.diff-old {
                background-color: #ffecec !important;
            }
            div.«cssPrefix»-history .table-responsive .table > tbody > tr > td.diff-new {
                background-color: #eaffea !important;
            }
            div.«cssPrefix»-history .img-fluid {
                max-width: 20px;
            }
        «ENDIF»
    '''

    def private viewFilterForm(Application it) '''
        div.«cssPrefix»-index form.«cssPrefix»-quicknav {
            margin: 10px 0;
            padding: 8px 12px;
            border: 1px solid #ccc;
        }

        div.«cssPrefix»-index form.«cssPrefix»-quicknav h3 {
            display: none;
        }

        div.«cssPrefix»-index form.«cssPrefix»-quicknav .form-group {
            display: inline-block;
        }

        div.«cssPrefix»-index form.«cssPrefix»-quicknav label {
           margin: 0 5px;
           display: inline;
        }
    '''

    def private pdfStyles(Application it) '''
        @page {
            margin: 1cm 2cm 1cm 1cm;
        }
        img {
            border-width: 0;
            vertical-align: top;
        }
    '''

    def private techDocsStyles(Application it) '''
        body {
            padding-bottom: 80px;
        }
        h2 {
            margin-top: 80px;
        }
        h3 {
            margin-top: 50px;
        }
        table {
            width: 100%;
        }
        th, td {
            vertical-align: top;
        }
    '''
}
