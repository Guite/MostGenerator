package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class NewsletterView {
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginClassSuffix = if (!targets('1.3.5')) 'Plugin' else ''
        val templateFileName = 'ItemList' + pluginClassSuffix + '.tpl'
        val templatePath = getViewPath + 'plugin_config/'
        fsa.generateFile(templatePath + templateFileName, editTemplate)
    }

    def private editTemplate(Application it) '''
        {* Purpose of this template: Display an edit form for configuring the newsletter plugin *}
        {assign var='objectTypes' value=$plugin_parameters.«appName»_NewsletterPlugin_ItemList.param.ObjectTypes}
        {assign var='pageArgs' value=$plugin_parameters.«appName»_NewsletterPlugin_ItemList.param.Args}

        {assign var='j' value=1}
        {foreach key='objectType' item='objectTypeData' from=$objectTypes}
            <hr />
            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
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
            </div>
            <div id="plugin_{$i}_suboption_{$j}">
                <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                    <label for="«appName»Args_{$objectType}_sorting"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Sorting'}:</label>
                    «IF !targets('1.3.5')»
                        <div class="col-lg-9">
                    «ENDIF»
                        <select name="«appName»Args[{$objectType}][sorting]" id="«appName»Args_{$objectType}_sorting"«IF !targets('1.3.5')» class="form-control"«ENDIF»>
                            <option value="random"{if $pageArgs.$objectType.sorting eq 'random'} selected="selected"{/if}>{gt text='Random'}</option>
                            <option value="newest"{if $pageArgs.$objectType.sorting eq 'newest'} selected="selected"{/if}>{gt text='Newest'}</option>
                            <option value="alpha"{if $pageArgs.$objectType.sorting eq 'default' || ($pageArgs.$objectType.sorting != 'random' && $pageArgs.$objectType.sorting != 'newest')} selected="selected"{/if}>{gt text='Default'}</option>
                        </select>
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                </div>
                <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                    <label for="«appName»Args_{$objectType}_amount"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Amount'}:</label>
                    «IF !targets('1.3.5')»
                        <div class="col-lg-9">
                    «ENDIF»
                        <input type="text" value="{$pageArgs.$objectType.amount|default:'5'}" name="«appName»Args[{$objectType}][amount]" id="«appName»Args_{$objectType}_amount" maxlength="2" size="10"«IF !targets('1.3.5')» class="form-control"«ENDIF» />
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                </div>
«/*
                <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                    <label for="«appName»Args_{$objectType}_template"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Template'}:</label>
                    «IF !targets('1.3.5')»
                        <div class="col-lg-9">
                    «ENDIF»
                        <select name="«appName»Args[{$objectType}][template]" id="«appName»Args_{$objectType}_template"«IF !targets('1.3.5')» class="form-control"«ENDIF»>
                            <option value="itemlist_display.tpl"{if $pageArgs.$objectType.template eq 'itemlist_display.tpl'} selected="selected"{/if}>{gt text='Only item titles'}</option>
                            <option value="itemlist_display_description.tpl"{if $pageArgs.$objectType.template eq 'itemlist_display_description.tpl'} selected="selected"{/if}>{gt text='With description'}</option>
                            <option value="custom"{if $pageArgs.$objectType.template eq 'custom'} selected="selected"{/if}>{gt text='Custom template'}</option>
                        </select>
                        <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='Only for HTML Newsletter'}</span>
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                </div>
                <div id="customtemplatearea_{$objectType}" class="«IF targets('1.3.5')»z-formrow z-hide«ELSE»form-group hide«ENDIF»">
                    <label for="«appName»Args_{$objectType}_customtemplate"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Custom template'}:</label>
                    «IF !targets('1.3.5')»
                        <div class="col-lg-9">
                    «ENDIF»
                        <input type="text" value="{$pageArgs.$objectType.customtemplate|default:''}" name="«appName»Args[{$objectType}][customtemplate]" id="«appName»Args_{$objectType}_customtemplate" maxlength="80" size="40"«IF !targets('1.3.5')» class="form-control"«ENDIF» />
                        <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='Example'}: <em>itemlist_{objecttype}_display.tpl</em></span>
                        <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='Only for HTML Newsletter'}</span>
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                </div>
*/»
                <div class="«IF targets('1.3.5')»z-formrow z-hide«ELSE»form-group hide«ENDIF»"«/* TODO: wait until FilterUtil is ready for Doctrine 2 - see https://github.com/zikula/core/issues/118 */»>
                    <label for="«appName»Args_{$objectType}_filter"«IF !targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='Filter (expert option)'}:</label>
                    «IF !targets('1.3.5')»
                        <div class="col-lg-9">
                    «ENDIF»
                        <input type="text" value="{$pageArgs.$objectType.filter|default:''}" name="«appName»Args[{$objectType}][filter]" id="«appName»Args_{$objectType}_filter" size="40"«IF !targets('1.3.5')» class="form-control"«ENDIF» />
                        <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">({gt text='Syntax examples'}: <kbd>name:like:foobar</kbd> {gt text='or'} <kbd>status:ne:3</kbd>)</span>
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                </div>
            </div>
            {assign var='j' value=$j+1}
        {foreachelse}
            <div class="«IF targets('1.3.5')»z-warningmsg«ELSE»alert alert-warningmsg«ENDIF»">{gt text='No object types found.'}</div>
        {/foreach}
«/*
        {pageaddvar name='javascript' value='prototype'}
        <script type="text/javascript">
        /* <![CDATA[ * /
            function «prefix()»ToggleCustomTemplate(objectType) {
                if ($F('«appName»Args_' + objectType + '_template') == 'custom') {
                    $('customtemplatearea_' + objectType).removeClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
                } else {
                    $('customtemplatearea_' + objectType).addClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
                }
            }

            document.observe('dom:loaded', function() {
                {{foreach key='objectType' item='objectTypeData' from=$objectTypes}}
                    «prefix()»ToggleCustomTemplate('{{$objectType}}');
                    $('«appName»Args_{{$objectType}}_template').observe('change', function(e) {
                        «prefix()»ToggleCustomTemplate('{{$objectType}}');
                    });
                {{/foreach}}
            });
        /* ]]> * /
        </script>
*/»
    '''
}
