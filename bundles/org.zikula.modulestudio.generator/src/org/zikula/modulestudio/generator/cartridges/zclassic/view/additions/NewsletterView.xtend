package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class NewsletterView {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        val pluginClassSuffix = 'Plugin'
        val templatePath = getViewPath + 'plugin_config/'
        // not ready for Twig yet
        var fileName = 'ItemList' + pluginClassSuffix + '.tpl'
        fsa.generateFile(templatePath + fileName, editTemplate)
    }

    def private editTemplate(Application it) '''
        {* Purpose of this template: Display an edit form for configuring the newsletter plugin *}
        {assign var='objectTypes' value=$plugin_parameters.«appName»_NewsletterPlugin_ItemList.param.ObjectTypes}
        {assign var='pageArgs' value=$plugin_parameters.«appName»_NewsletterPlugin_ItemList.param.Args}

        {assign var='j' value=1}
        {foreach key='objectType' item='objectTypeData' from=$objectTypes}
            <hr />
            <div class="form-group">
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
            <p class="alert alert-warning">{gt text='No object types found.'}</p>
        {/foreach}
    '''

    def private editTemplateObjectTypes(Application it) '''
        <div class="«IF targets('3.0')»col-md-9 offset-md-3«ELSE»col-sm-offset-3 col-sm-9«ENDIF»">
            <div class="«IF targets('3.0')»custom-control custom-checkbo«ELSE»checkbox«ENDIF»">
                «IF targets('3.0')»
                    <input id="plugin_{$i}_enable_{$j}" type="checkbox" name="«appName»ObjectTypes[{$objectType}]" class="custom-control-input" value="1"{if $objectTypeData.nwactive} checked="checked"{/if} />
                    <label for="plugin_{$i}_enable_{$j}" class="custom-control-label">{$objectTypeData.name|safetext}</label>
                «ELSE»
                    <label>
                        <input id="plugin_{$i}_enable_{$j}" type="checkbox" name="«appName»ObjectTypes[{$objectType}]" value="1"{if $objectTypeData.nwactive} checked="checked"{/if} /> {$objectTypeData.name|safetext}
                    </label>
                «ENDIF»
            </div>
        </div>
    '''

    def private editTemplateSorting(Application it) '''
        <div class="form-group«IF targets('3.0')» row«ENDIF»">
            <label for="«appName.toFirstLower»Args_{$objectType}_sorting" class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-3 «IF targets('3.0')»col-form«ELSE»control«ENDIF»-label">{gt text='Sorting'}:</label>
            <div class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-9">
                <select id="«appName.toFirstLower»Args_{$objectType}_sorting" name="«appName»Args[{$objectType}][sorting]" class="form-control">
                    <option value="random"{if $pageArgs.$objectType.sorting eq 'random'} selected="selected"{/if}>{gt text='Random'}</option>
                    <option value="newest"{if $pageArgs.$objectType.sorting eq 'newest'} selected="selected"{/if}>{gt text='Newest'}</option>
                    <option value="updated"{if $pageArgs.$objectType.sorting eq 'updated'} selected="selected"{/if}>{gt text='Updated'}</option>
                    <option value="alpha"{if $pageArgs.$objectType.sorting eq 'default' || ($pageArgs.$objectType.sorting != 'random' && $pageArgs.$objectType.sorting != 'newest' && $pageArgs.$objectType.sorting != 'updated')} selected="selected"{/if}>{gt text='Default'}</option>
                </select>
            </div>
        </div>
    '''

    def private editTemplateAmount(Application it) '''
        <div class="form-group«IF targets('3.0')» row«ENDIF»">
            <label for="«appName.toFirstLower»Args_{$objectType}_amount" class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-3 «IF targets('3.0')»col-form«ELSE»control«ENDIF»-label">{gt text='Amount'}:</label>
            <div class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-9">
                <input type="text" id="«appName.toFirstLower»Args_{$objectType}_amount" name="«appName»Args[{$objectType}][amount]" value="{$pageArgs.$objectType.amount|default:'5'}" maxlength="2" size="10" class="form-control" />
            </div>
        </div>
    '''

/*
    def private editTemplateTemplate(Application it) '''
        <div class="form-group«IF targets('3.0')» row«ENDIF»">
            <label for="«appName.toFirstLower»Args_{$objectType}_template" class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-3 «IF targets('3.0')»col-form«ELSE»control«ENDIF»-label">{gt text='Template'}:</label>
            <div class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-9">
                <select id="«appName.toFirstLower»Args_{$objectType}_template" name="«appName»Args[{$objectType}][template]" class="form-control">
                    <option value="itemlist_display.tpl"{if $pageArgs.$objectType.template eq 'itemlist_display.tpl'} selected="selected"{/if}>{gt text='Only item titles'}</option>
                    <option value="itemlist_display_description.tpl"{if $pageArgs.$objectType.template eq 'itemlist_display_description.tpl'} selected="selected"{/if}>{gt text='With description'}</option>
                    <option value="custom"{if $pageArgs.$objectType.template eq 'custom'} selected="selected"{/if}>{gt text='Custom template'}</option>
                </select>
                «IF targets('3.0')»
                    <small class="form-text text-muted">{gt text='Only for HTML Newsletter'}</small>
                «ELSE»
                    <span class="help-block">{gt text='Only for HTML Newsletter'}</span>
                «ENDIF
            </div>
        </div>
        <div id="customTemplateArea_{$objectType}" class="form-group«IF targets('3.0')» row«ENDIF»" data-switch="«appName.toFirstLower»Args_{$objectType}_template" data-switch-value="custom">
            <label for="«appName.toFirstLower»Args_{$objectType}_customtemplate" class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-3 «IF targets('3.0')»col-form«ELSE»control«ENDIF»-label">{gt text='Custom template'}:</label>
            <div class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-9">
                <input type="text" id="«appName.toFirstLower»Args_{$objectType}_customtemplate" name="«appName»Args[{$objectType}][customtemplate]" value="{$pageArgs.$objectType.customtemplate|default:''}" maxlength="80" size="40" class="form-control" />
                «IF targets('3.0')»
                    <small class="form-text text-muted">{gt text='Example'}: <code>itemlist_{objecttype}_display.tpl</code></small>
                    <small class="form-text text-muted">{gt text='Only for HTML Newsletter'}</small>
                «ELSE»
                    <span class="help-block">{gt text='Example'}: <code>itemlist_{objecttype}_display.tpl</em></span>
                    <span class="help-block">{gt text='Only for HTML Newsletter'}</span>
                «ENDIF»
            </div>
        </div>
    '''
*/

    def private editTemplateFilter(Application it) '''
        <div class="form-group«IF targets('3.0')» row«ENDIF»">
            <label for="«appName.toFirstLower»Args_{$objectType}_filter" class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-3 «IF targets('3.0')»col-form«ELSE»control«ENDIF»-label">{gt text='Filter (expert option)'}:</label>
            <div class="col-«IF targets('3.0')»md«ELSE»sm«ENDIF»-9">
                <input type="text" id="«appName.toFirstLower»Args_{$objectType}_filter" name="«appName»Args[{$objectType}][filter]" value="{$pageArgs.$objectType.filter|default:''}" size="40" class="form-control" />
                «IF targets('3.0')»
                    <small class="form-text text-muted">{gt text='Example'}: <code>tbl.age >= 18</code></small>
                «ELSE»
                    <span class="help-block">{gt text='Example'}: <code>tbl.age >= 18</code></span>
                «ENDIF»
            </div>
        </div>
    '''
}
