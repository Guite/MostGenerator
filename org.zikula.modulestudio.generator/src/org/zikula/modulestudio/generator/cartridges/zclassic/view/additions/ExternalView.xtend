package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    private SimpleFields fieldHelper = new SimpleFields

    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        for (entity : getAllEntities) {
            val templatePath = getViewPath + (if (targets('1.3.5')) 'external/' + entity.name.formatForCode else 'External/' + entity.name.formatForCodeCapital) + '/'

            fileName = 'display.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'display.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.displayTemplate(it))
            }

            fileName = 'info.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'info.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.itemInfoTemplate(it))
            }

            fileName = 'find.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'find.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.findTemplate(it))
            }

            fileName = 'select.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'select.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.selectTemplate(it))
            }
        }
    }

    def private displayTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display one certain «name.formatForDisplay» within an external context *}
        <div id="«name.formatForCode»{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}" class="«app.appName.toLowerCase»-external-«name.formatForDB»">
        {if $displayMode eq 'link'}
            <p«IF app.hasUserController» class="«app.appName.toLowerCase»-external-link"«ENDIF»>
            «IF app.hasUserController»
                «IF app.targets('1.3.5')»
                    <a href="{modurl modname='«app.appName»' type='user' func='display' ot='«name.formatForCode»' «routeParamsLegacy(name.formatForCode, true, true)»}" title="{$«name.formatForCode»->getTitleFromDisplayPattern()|replace:"\"":""}">
                «ELSE»
                    <a href="{route name='«app.appName.formatForDB»_«name.formatForDB»_display' «routeParams(name.formatForCode, true)»}" title="{$«name.formatForCode»->getTitleFromDisplayPattern()|replace:"\"":""}">
                «ENDIF»
            «ENDIF»
            {$«name.formatForCode»->getTitleFromDisplayPattern()|notifyfilters:'«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'}
            «IF app.hasUserController»
                </a>
            «ENDIF»
            </p>
        {/if}
        {checkpermissionblock component='«app.appName»::' instance='::' level='ACCESS_EDIT'}«/* TODO review whether this permission check is required here */»
            {if $displayMode eq 'embed'}
                <p class="«app.appName.toLowerCase»-external-title">
                    <strong>{$«name.formatForCode»->getTitleFromDisplayPattern()|notifyfilters:'«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'}</strong>
                </p>
            {/if}
        {/checkpermissionblock}

        {if $displayMode eq 'link'}
        {elseif $displayMode eq 'embed'}
            <div class="«app.appName.toLowerCase»-external-snippet">
                «displaySnippet»
            </div>

            {* you can distinguish the context like this: *}
            {*if $source eq 'contentType'}
                ...
            {elseif $source eq 'scribite'}
                ...
            {/if*}
            «IF hasAbstractStringFieldsEntity || categorisable»

            {* you can enable more details about the item: *}
            {*
                <p class="«app.appName.toLowerCase»-external-description">
                    «displayDescription('', '<br />')»
                    «IF categorisable»
                        {assignedcategorieslist categories=$«name.formatForCode».categories doctrine2=true}
                    «ENDIF»
                </p>
            *}
            «ENDIF»
        {/if}
        </div>
    '''

    def private displaySnippet(Entity it) '''
        «IF hasImageFieldsEntity»
            «val imageField = getImageFieldsEntity.head»
            «fieldHelper.displayField(imageField, name.formatForCode, 'display')»
        «ELSE»
            &nbsp;
        «ENDIF»
    '''

    def private displayDescription(Entity it, String praefix, String suffix) '''
        «IF hasAbstractStringFieldsEntity»
            «IF hasTextFieldsEntity»
                {if $«name.formatForCode».«getTextFieldsEntity.head.name.formatForCode» ne ''}«praefix»{$«name.formatForCode».«getTextFieldsEntity.head.name.formatForCode»}«suffix»{/if}
            «ELSEIF hasStringFieldsEntity»
                {if $«name.formatForCode».«getStringFieldsEntity.head.name.formatForCode» ne ''}«praefix»{$«name.formatForCode».«getStringFieldsEntity.head.name.formatForCode»}«suffix»{/if}
            «ENDIF»
        «ENDIF»
    '''

    def private itemInfoTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display item information for previewing from other modules *}
        <dl id="«name.formatForCode»{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}">
        <dt>{$«name.formatForCode»->getTitleFromDisplayPattern()|notifyfilters:'«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'|htmlentities}</dt>
        «IF hasImageFieldsEntity»
            <dd>«displaySnippet»</dd>
        «ENDIF»
        «displayDescription('<dd>', '</dd>')»
        «IF categorisable»
            <dd>{assignedcategorieslist categories=$«name.formatForCode».categories doctrine2=true}</dd>
        «ENDIF»
        </dl>
    '''

    def private findTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display a popup selector of «nameMultiple.formatForDisplay» for scribite integration *}
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{lang}" lang="{lang}">
        <head>
            <title>{gt text='Search and select «name.formatForDisplay»'}</title>
            <link type="text/css" rel="stylesheet" href="{$baseurl}style/core.css" />
            <link type="text/css" rel="stylesheet" href="{$baseurl}«app.rootFolder»/«IF app.targets('1.3.5')»«app.appName»/style/«ELSE»«app.getAppCssPath»«ENDIF»style.css" />
            <link type="text/css" rel="stylesheet" href="{$baseurl}«app.rootFolder»/«IF app.targets('1.3.5')»«app.appName»/style/«ELSE»«app.getAppCssPath»«ENDIF»finder.css" />
            {assign var='ourEntry' value=$modvars.ZConfig.entrypoint}
            <script type="text/javascript">/* <![CDATA[ */
                if (typeof(Zikula) == 'undefined') {var Zikula = {};}
                Zikula.Config = {'entrypoint': '{{$ourEntry|default:'index.php'}}', 'baseURL': '{{$baseurl}}'}; /* ]]> */</script>
                «IF app.targets('1.3.5')»
                    <script type="text/javascript" src="{$baseurl}javascript/ajax/proto_scriptaculous.combined.min.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/livepipe/livepipe.combined.min.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.UI.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.ImageViewer.js"></script>
                «ELSE»
                    <link rel="stylesheet" href="web/bootstrap/css/bootstrap.min.css" type="text/css" />
                    <link rel="stylesheet" href="web/bootstrap/css/bootstrap-theme.css" type="text/css" />
                    <script type="text/javascript" src="web/jquery/jquery.min.js"></script>
                    <script type="text/javascript" src="web/bootstrap/js/bootstrap.min.js"></script>
                «ENDIF»
            <script type="text/javascript" src="{$baseurl}«app.rootFolder»/«IF app.targets('1.3.5')»«app.appName»/javascript/«ELSE»«app.getAppJsPath»«ENDIF»«app.appName»«IF app.targets('1.3.5')»_f«ELSE».F«ENDIF»inder.js"></script>
        «IF app.targets('1.3.5')»
            {if $editorName eq 'tinymce'}
                <script type="text/javascript" src="{$baseurl}modules/Scribite/includes/tinymce/tiny_mce_popup.js"></script>
            {/if}
        «ENDIF»
        </head>
        <body>
            «findTemplateObjectTypeSwitcher(app)»
            <form action="{$ourEntry|default:'index.php'}" id="«app.appName.toFirstLower»SelectorForm" method="get" class="«IF app.targets('1.3.5')»z-form«ELSE»form-horizontal«ENDIF»"«IF !app.targets('1.3.5')» role="form"«ENDIF»>
            <div>
                <input type="hidden" name="module" value="«app.appName»" />
                <input type="hidden" name="type" value="external" />
                <input type="hidden" name="func" value="finder" />
                <input type="hidden" name="objectType" value="{$objectType}" />
                <input type="hidden" name="editor" id="editorName" value="{$editorName}" />

                <fieldset>
                    <legend>{gt text='Search and select «name.formatForDisplay»'}</legend>
                    «findTemplateCategories(app)»

                    «findTemplatePasteAs(app)»
                    <br />

                    «findTemplateObjectId(app)»

                    «findTemplateSorting(app)»

                    «findTemplatePageSize(app)»

                    «findTemplateSearch(app)»
                    <div style="margin-left: 6em">
                        {pager display='page' rowcount=$pager.numitems limit=$pager.itemsperpage posvar='pos' template='pagercss.tpl' maxpages='10'«IF !app.targets('1.3.5')» route='«app.appName.formatForDB»_external_finder'«ENDIF»}
                    </div>
                    <input type="submit" id="«app.appName.toFirstLower»Submit" name="submitButton" value="{gt text='Change selection'}"«IF !app.targets('1.3.5')» class="btn btn-success"«ENDIF» />
                    <input type="button" id="«app.appName.toFirstLower»Cancel" name="cancelButton" value="{gt text='Cancel'}"«IF !app.targets('1.3.5')» class="btn btn-default"«ENDIF» />
                    <br />
                </fieldset>
            </div>
            </form>

            «findTemplateJs(app)»

            «findTemplateEditForm(app)»
        </body>
        </html>
    '''

    def private findTemplateObjectTypeSwitcher(Entity it, Application app) '''
        «IF app.getAllEntities.size > 1»
            «IF app.targets('1.3.5')»
                <p>{gt text='Switch to'}:
                «FOR entity : app.getAllEntities.filter[e|e.name != name] SEPARATOR ' | '»
                    <a href="{modurl modname='«app.appName»' type='external' func='finder' objectType='«entity.name.formatForCode»' editor=$editorName}" title="{gt text='Search and select «entity.name.formatForDisplay»'}">{gt text='«entity.nameMultiple.formatForDisplayCapital»'}</a>
                «ENDFOR»
                </p>
            «ELSE»
                <ul class="nav nav-pills nav-justified">
                «FOR entity : app.getAllEntities.filter[e|e.name != name] SEPARATOR ' | '»
                    <li{if $objectType eq '«entity.name.formatForCode»'} class="active"{/if}><a href="{route name='«app.appName.formatForDB»_external_finder' objectType='«entity.name.formatForCode»' editor=$editorName}" title="{gt text='Search and select «entity.name.formatForDisplay»'}">{gt text='«entity.nameMultiple.formatForDisplayCapital»'}</a></li>
                «ENDFOR»
                </ul>
            «ENDIF»
        «ENDIF»
    '''

    def private findTemplateCategories(Entity it, Application app) '''
        «IF categorisable»

            {if $properties ne null && is_array($properties)}
                {gt text='All' assign='lblDefault'}
                {nocache}
                {foreach key='propertyName' item='propertyId' from=$properties}
                    <div class="«IF app.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF» categoryselector">
                        {modapifunc modname='«app.appName»' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                        {gt text='Category' assign='categoryLabel'}
                        {assign var='categorySelectorId' value='catid'}
                        {assign var='categorySelectorName' value='catid'}
                        {assign var='categorySelectorSize' value='1'}
                        {if $hasMultiSelection eq true}
                            {gt text='Categories' assign='categoryLabel'}
                            {assign var='categorySelectorName' value='catids'}
                            {assign var='categorySelectorId' value='catids__'}
                            {assign var='categorySelectorSize' value='8'}
                        {/if}
                        <label for="{$categorySelectorId}{$propertyName}"«IF !app.targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{$categoryLabel}</label>
                        «IF !app.targets('1.3.5')»
                            <div class="col-lg-9">
                        «ELSE»
                            &nbsp;
                        «ENDIF»
                            {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«app.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize«IF !app.targets('1.3.5')» cssClass='form-control'«ENDIF»}
                            <span class="«IF app.targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='This is an optional filter.'}</span>
                        «IF !app.targets('1.3.5')»
                            </div>
                        «ENDIF»
                    </div>
                {/foreach}
                {/nocache}
            {/if}
        «ENDIF»
    '''

    def private findTemplatePasteAs(Entity it, Application app) '''
        <div class="«IF app.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«app.appName.toFirstLower»PasteAs"«IF !app.targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Paste as'}:</label>
            «IF !app.targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <select id="«app.appName.toFirstLower»PasteAs" name="pasteas"«IF !app.targets('1.3.5')» class="form-control"«ENDIF»>
                    <option value="1">{gt text='Link to the «name.formatForDisplay»'}</option>
                    <option value="2">{gt text='ID of «name.formatForDisplay»'}</option>
                </select>
            «IF !app.targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private findTemplateObjectId(Entity it, Application app) '''
        <div class="«IF app.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«app.appName.toFirstLower»ObjectId"«IF !app.targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='«name.formatForDisplayCapital»'}:</label>
            «IF !app.targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <div id="«app.appName.toLowerCase»ItemContainer">
                    <ul>
                    {foreach item='«name.formatForCode»' from=$items}
                        <li>
                            <a href="#" onclick="«app.appName.toFirstLower».finder.selectItem({$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»})" onkeypress="«app.appName.toFirstLower».finder.selectItem({$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»})">{$«name.formatForCode»->getTitleFromDisplayPattern()}</a>
                            <input type="hidden" id="url{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}" value="«IF app.hasUserController»«IF app.targets('1.3.5')»{modurl modname='«app.appName»' type='user' func='display' ot='«name.formatForCode»' «routeParamsLegacy(name.formatForCode, true, true)» fqurl=true}«ELSE»{route name='«app.appName.formatForDB»_«name.formatForDB»_display' «routeParams(name.formatForCode, true)» absolute=true}«ENDIF»«ENDIF»" />
                            <input type="hidden" id="title{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}" value="{$«name.formatForCode»->getTitleFromDisplayPattern()|replace:"\"":""}" />
                            <input type="hidden" id="desc{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}" value="{capture assign='description'}«displayDescription('', '')»{/capture}{$description|strip_tags|replace:"\"":""}" />
                        </li>
                    {foreachelse}
                        <li>{gt text='No entries found.'}</li>
                    {/foreach}
                    </ul>
                </div>
            «IF !app.targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private findTemplateSorting(Entity it, Application app) '''
        <div class="«IF app.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«app.appName.toFirstLower»Sort"«IF !app.targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Sort by'}:</label>
            «IF !app.targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <select id="«app.appName.toFirstLower»Sort" name="sort" style="width: 150px" class="«IF app.targets('1.3.5')»z-floatleft«ELSE»pull-left«ENDIF»" style="margin-right: 10px">
                «FOR field : getDerivedFields»
                    <option value="«field.name.formatForCode»"{if $sort eq '«field.name.formatForCode»'} selected="selected"{/if}>{gt text='«field.name.formatForDisplayCapital»'}</option>
                «ENDFOR»
                «IF standardFields»
                    <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                    <option value="createdUserId"{if $sort eq 'createdUserId'} selected="selected"{/if}>{gt text='Creator'}</option>
                    <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
                «ENDIF»
                </select>
                <select id="«app.appName.toFirstLower»SortDir" name="sortdir" style="width: 100px"«IF !app.targets('1.3.5')» class="form-control"«ENDIF»>
                    <option value="asc"{if $sortdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                    <option value="desc"{if $sortdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
                </select>
            «IF !app.targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private findTemplatePageSize(Entity it, Application app) '''
        <div class="«IF app.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«app.appName.toFirstLower»PageSize"«IF !app.targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Page size'}:</label>
            «IF !app.targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <select id="«app.appName.toFirstLower»PageSize" name="num" style="width: 50px; text-align: right"«IF !app.targets('1.3.5')» class="form-control"«ENDIF»>
                    <option value="5"{if $pager.itemsperpage eq 5} selected="selected"{/if}>5</option>
                    <option value="10"{if $pager.itemsperpage eq 10} selected="selected"{/if}>10</option>
                    <option value="15"{if $pager.itemsperpage eq 15} selected="selected"{/if}>15</option>
                    <option value="20"{if $pager.itemsperpage eq 20} selected="selected"{/if}>20</option>
                    <option value="30"{if $pager.itemsperpage eq 30} selected="selected"{/if}>30</option>
                    <option value="50"{if $pager.itemsperpage eq 50} selected="selected"{/if}>50</option>
                    <option value="100"{if $pager.itemsperpage eq 100} selected="selected"{/if}>100</option>
                </select>
            «IF !app.targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private findTemplateSearch(Entity it, Application app) '''
        «IF hasAbstractStringFieldsEntity»
            <div class="«IF app.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                <label for="«app.appName.toFirstLower»SearchTerm"«IF !app.targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Search for'}:</label>
            «IF !app.targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                    <input type="text" id="«app.appName.toFirstLower»SearchTerm" name="q" style="width: 150px" class="«IF app.targets('1.3.5')»z-floatleft«ELSE»form-control pull-left«ENDIF»" style="margin-right: 10px" />
                    <input type="button" id="«app.appName.toFirstLower»SearchGo" name="gosearch" value="{gt text='Filter'}" style="width: 80px"«IF !app.targets('1.3.5')» class="btn btn-default"«ENDIF» />
            «IF !app.targets('1.3.5')»
                </div>
            «ENDIF»
            </div>

        «ENDIF»
    '''

    def private findTemplateJs(Entity it, Application app) '''
        <script type="text/javascript">
        /* <![CDATA[ */
            «IF app.targets('1.3.5')»
                document.observe('dom:loaded', function() {
                    «app.appName.toFirstLower».finder.onLoad();
                });
            «ELSE»
                ( function($) {
                    $(document).ready(function() {
                        «app.appName.toFirstLower».finder.onLoad();
                    });
                })(jQuery);
            «ENDIF»
        /* ]]> */
        </script>
    '''

    def private findTemplateEditForm(Entity it, Application app) '''
        «IF !app.getAllAdminControllers.empty»
            {*
            <div class="«app.appName.toLowerCase»-finderform">
                <fieldset>
                    {modfunc modname='«app.appName»' type='admin' func='edit'}
                </fieldset>
            </div>
            *}
        «ENDIF»
    '''

    def private selectTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display a popup selector for Forms and Content integration *}
        {assign var='baseID' value='«name.formatForCode»'}
        <div id="{$baseID}Preview" style="float: right; width: 300px; border: 1px dotted #a3a3a3; padding: .2em .5em; margin-right: 1em">
            <p><strong>{gt text='«name.formatForDisplayCapital» information'}</strong></p>
            {img id='ajax_indicator' modname='core' set='ajax' src='indicator_circle.gif' alt='' class='«IF app.targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»'}
            <div id="{$baseID}PreviewContainer">&nbsp;</div>
        </div>
        <br />
        <br />
        {assign var='leftSide' value=' style="float: left; width: 10em"'}
        {assign var='rightSide' value=' style="float: left"'}
        {assign var='break' value=' style="clear: left"'}
        «IF categorisable»

            {if $properties ne null && is_array($properties)}
                {gt text='All' assign='lblDefault'}
                {nocache}
                {foreach key='propertyName' item='propertyId' from=$properties}
                    <p>
                        {modapifunc modname='«app.appName»' type='category' func='hasMultipleSelection' ot='«name.formatForCode»' registry=$propertyName assign='hasMultiSelection'}
                        {gt text='Category' assign='categoryLabel'}
                        {assign var='categorySelectorId' value='catid'}
                        {assign var='categorySelectorName' value='catid'}
                        {assign var='categorySelectorSize' value='1'}
                        {if $hasMultiSelection eq true}
                            {gt text='Categories' assign='categoryLabel'}
                            {assign var='categorySelectorName' value='catids'}
                            {assign var='categorySelectorId' value='catids__'}
                            {assign var='categorySelectorSize' value='8'}
                        {/if}
                        <label for="{$baseID}_{$categorySelectorId}{$propertyName}"{$leftSide}>{$categoryLabel}:</label>
                        &nbsp;
                        {selector_category name="`$baseID`_`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«app.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize«IF !app.targets('1.3.5')» cssClass='form-control'«ENDIF»}
                        <br{$break} />
                    </p>
                {/foreach}
                {/nocache}
            {/if}
        «ENDIF»
        <p>
            <label for="{$baseID}Id"{$leftSide}>{gt text='«name.formatForDisplayCapital»'}:</label>
            <select id="{$baseID}Id" name="id"{$rightSide}>
                {foreach item='«name.formatForCode»' from=$items}
                    <option value="{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}"{if $selectedId eq $«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»} selected="selected"{/if}>{$«name.formatForCode»->getTitleFromDisplayPattern()}</option>
                {foreachelse}
                    <option value="0">{gt text='No entries found.'}</option>
                {/foreach}
            </select>
            <br{$break} />
        </p>
        <p>
            <label for="{$baseID}Sort"{$leftSide}>{gt text='Sort by'}:</label>
            <select id="{$baseID}Sort" name="sort"{$rightSide}>
                «FOR field : getDerivedFields»
                    <option value="«field.name.formatForCode»"{if $sort eq '«field.name.formatForCode»'} selected="selected"{/if}>{gt text='«field.name.formatForDisplayCapital»'}</option>
                «ENDFOR»
                «IF standardFields»
                    <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                    <option value="createdUserId"{if $sort eq 'createdUserId'} selected="selected"{/if}>{gt text='Creator'}</option>
                    <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
                «ENDIF»
            </select>
            <select id="{$baseID}SortDir" name="sortdir"«IF !app.targets('1.3.5')» class="form-control"«ENDIF»>
                <option value="asc"{if $sortdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                <option value="desc"{if $sortdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
            </select>
            <br{$break} />
        </p>
        «IF hasAbstractStringFieldsEntity»
            <p>
                <label for="{$baseID}SearchTerm"{$leftSide}>{gt text='Search for'}:</label>
                <input type="text" id="{$baseID}SearchTerm" name="q"«IF !app.targets('1.3.5')» class="form-control"«ENDIF»{$rightSide} />
                <input type="button" id="«app.appName.toFirstLower»SearchGo" name="gosearch" value="{gt text='Filter'}"«IF !app.targets('1.3.5')» class="btn btn-default"«ENDIF» />
                <br{$break} />
            </p>
        «ENDIF»
        <br />
        <br />

        <script type="text/javascript">
        /* <![CDATA[ */
            «IF app.targets('1.3.5')»
                document.observe('dom:loaded', function() {
                    «app.appName.toFirstLower».itemSelector.onLoad('{{$baseID}}', {{$selectedId|default:0}});
                });
            «ELSE»
                ( function($) {
                    $(document).ready(function() {
                        «app.appName.toFirstLower».itemSelector.onLoad('{{$baseID}}', {{$selectedId|default:0}});
                    });
                })(jQuery);
            «ENDIF»
        /* ]]> */
        </script>
    '''
}
