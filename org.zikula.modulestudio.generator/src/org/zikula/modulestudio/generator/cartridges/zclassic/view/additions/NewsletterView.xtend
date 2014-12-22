package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class NewsletterView {
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginClassSuffix = if (!targets('1.3.5')) 'Plugin' else ''
        val templatePath = getViewPath + 'plugin_config/'
        var fileName = 'ItemList' + pluginClassSuffix + '.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'ItemList' + pluginClassSuffix + '.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    def private editTemplate(Application it) '''
        {* Purpose of this template: Display an edit form for configuring the newsletter plugin *}
        {assign var='objectTypes' value=$plugin_parameters.«appName»_NewsletterPlugin_ItemList.param.ObjectTypes}
        {assign var='pageArgs' value=$plugin_parameters.«appName»_NewsletterPlugin_ItemList.param.Args}

        {assign var='j' value=1}
        {foreach key='objectType' item='objectTypeData' from=$objectTypes}
            <hr />
            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                «editTemplateObjectTypes»
            </div>
            <div id="plugin_{$i}_suboption_{$j}">
                «editTemplateSorting»
                «editTemplateAmount»
                «/*editTemplateTemplate*/»
                «editTemplateFilter»
            </div>
            {assign var='j' value=$j+1}
        {foreachelse}
            <div class="«IF targets('1.3.5')»z-warningmsg«ELSE»alert alert-warningmsg«ENDIF»">{gt text='No object types found.'}</div>
        {/foreach}
«/*
        «IF !targets('1.3.5')»

            {include file='include_filterSyntaxDialog.tpl'}
        «ENDIF»

        «editTemplateJs»
*/»
    '''

    def private editTemplateObjectTypes(Application it) '''
        «IF targets('1.3.5')»
            <label for="plugin_{$i}_enable_{$j}">{$objectTypeData.name|safetext}</label>
            <input id="plugin_{$i}_enable_{$j}" type="checkbox" name="«appName»ObjectTypes[{$objectType}]" value="1"{if $objectTypeData.nwactive} checked="checked"{/if} />
        «ELSE»
            <div class="col-lg-offset-3 col-lg-9">
                <div class="checkbox">
                    <label>
                        <input id="plugin_{$i}_enable_{$j}" type="checkbox" name="«appName»ObjectTypes[{$objectType}]" value="1"{if $objectTypeData.nwactive} checked="checked"{/if} /> {$objectTypeData.name|safetext}
                    </label>
                </div>
            </div>
        «ENDIF»
    '''

    def private editTemplateSorting(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«appName.toFirstLower»Args_{$objectType}_sorting"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Sorting'}:</label>
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <select id="«appName.toFirstLower»Args_{$objectType}_sorting" name="«appName»Args[{$objectType}][sorting]"«IF !targets('1.3.5')» class="form-control"«ENDIF»>
                    <option value="random"{if $pageArgs.$objectType.sorting eq 'random'} selected="selected"{/if}>{gt text='Random'}</option>
                    <option value="newest"{if $pageArgs.$objectType.sorting eq 'newest'} selected="selected"{/if}>{gt text='Newest'}</option>
                    <option value="alpha"{if $pageArgs.$objectType.sorting eq 'default' || ($pageArgs.$objectType.sorting != 'random' && $pageArgs.$objectType.sorting != 'newest')} selected="selected"{/if}>{gt text='Default'}</option>
                </select>
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateAmount(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«appName.toFirstLower»Args_{$objectType}_amount"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Amount'}:</label>
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <input type="text" id="«appName.toFirstLower»Args_{$objectType}_amount" name="«appName»Args[{$objectType}][amount]" value="{$pageArgs.$objectType.amount|default:'5'}" maxlength="2" size="10"«IF !targets('1.3.5')» class="form-control"«ENDIF» />
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

/*
    def private editTemplateTemplate(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«appName.toFirstLower»Args_{$objectType}_template"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Template'}:</label>
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <select id="«appName.toFirstLower»Args_{$objectType}_template" name="«appName»Args[{$objectType}][template]"«IF !targets('1.3.5')» class="form-control"«ENDIF»>
                    <option value="itemlist_display.tpl"{if $pageArgs.$objectType.template eq 'itemlist_display.tpl'} selected="selected"{/if}>{gt text='Only item titles'}</option>
                    <option value="itemlist_display_description.tpl"{if $pageArgs.$objectType.template eq 'itemlist_display_description.tpl'} selected="selected"{/if}>{gt text='With description'}</option>
                    <option value="custom"{if $pageArgs.$objectType.template eq 'custom'} selected="selected"{/if}>{gt text='Custom template'}</option>
                </select>
                <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='Only for HTML Newsletter'}</span>
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
        <div id="customTemplateArea_{$objectType}" class="«IF targets('1.3.5')»z-formrow z-hide«ELSE»form-group hidden«ENDIF»"«IF !targets('1.3.5')» data-switch="«appName.toFirstLower»Args_{$objectType}_template" data-switch-value="custom"«ENDIF»>
            <label for="«appName.toFirstLower»Args_{$objectType}_customtemplate"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Custom template'}:</label>
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <input type="text" id="«appName.toFirstLower»Args_{$objectType}_customtemplate" name="«appName»Args[{$objectType}][customtemplate]" value="{$pageArgs.$objectType.customtemplate|default:''}" maxlength="80" size="40"«IF !targets('1.3.5')» class="form-control"«ENDIF» />
                <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='Example'}: <em>itemlist_{objecttype}_display.tpl</em></span>
                <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='Only for HTML Newsletter'}</span>
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''
*/

    def private editTemplateFilter(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow z-hide«ELSE»form-group«ENDIF»">
            <label for="«appName.toFirstLower»Args_{$objectType}_filter"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Filter (expert option)'}:</label>
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <input type="text" id="«appName.toFirstLower»Args_{$objectType}_filter" name="«appName»Args[{$objectType}][filter]" value="{$pageArgs.$objectType.filter|default:''}" size="40"«IF !targets('1.3.5')» class="form-control"«ENDIF» />
                «IF targets('1.3.5')»
                    <span class="z-sub z-formnote">
                        ({gt text='Syntax examples'}: <kbd>name:like:foobar</kbd> {gt text='or'} <kbd>status:ne:3</kbd>)
                    </span>
                «ELSE»
                    <span class="help-block">
                        <a class="fa fa-filter" data-toggle="modal" data-target="#filterSyntaxModal">{gt text='Show syntax examples'}</a>
                    </span>
                «ENDIF»
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''
/*
    def private editTemplateJs(Application it) '''
        «IF targets('1.3.5')»
            {pageaddvar name='javascript' value='prototype'}
        «ELSE»
            {pageaddvar name='stylesheet' value='web/bootstrap/css/bootstrap.min.css'}
            {pageaddvar name='stylesheet' value='web/bootstrap/css/bootstrap-theme.min.css'}
            {pageaddvar name='javascript' value='jquery'}
            {pageaddvar name='javascript' value='web/bootstrap/js/bootstrap.min.js'}
        «ENDIF»
        «IF targets('1.3.5')»
            <script type="text/javascript">
            /* <![CDATA[ * /
                function «vendorAndName»ToggleCustomTemplate(objectType) {
                    if ($F('«appName.toFirstLower»Args_' + objectType + '_template') == 'custom') {
                        $('customTemplateArea_' + objectType).removeClassName('«IF targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»');
                    } else {
                        $('customTemplateArea_' + objectType).addClassName('«IF targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»');
                    }
                }
    
                document.observe('dom:loaded', function() {
                    {{foreach key='objectType' item='objectTypeData' from=$objectTypes}}
                        «vendorAndName»ToggleCustomTemplate('{{$objectType}}');
                        $('«appName.toFirstLower»Args_{{$objectType}}_template').observe('change', function(e) {
                            «vendorAndName»ToggleCustomTemplate('{{$objectType}}');
                        });
                    {{/foreach}}
                });
            /* ]]> * /
            </script>
        «ENDIF»
    '''
*/
}
