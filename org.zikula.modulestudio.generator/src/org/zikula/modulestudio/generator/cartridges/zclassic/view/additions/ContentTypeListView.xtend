package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeListView {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension UrlExtensions = new UrlExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) 'contenttype' else 'ContentType') + '/'
        for (entity : getAllEntities) {
            fsa.generateFile(templatePath + 'itemlist_' + entity.name.formatForCode + '_display_description.tpl', entity.displayDescTemplate(it))
            fsa.generateFile(templatePath + 'itemlist_' + entity.name.formatForCode + '_display.tpl', entity.displayTemplate(it))
        }
        fsa.generateFile(templatePath + 'itemlist_edit.tpl', editTemplate)
    }

    def private displayDescTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context *}
        <dl>
            {foreach item='item' from=$items}
                «val leadingField = getLeadingField»
                «IF leadingField != null»
                    <dt>{$item.«leadingField.name.formatForCode»}</dt>
                «ELSE»
                    <dt>{gt text='«name.formatForDisplayCapital»'}</dt>
                «ENDIF»
                «val textFields = fields.filter(typeof(TextField))»
                «IF !textFields.isEmpty»
                    {if $item.«textFields.head.name.formatForCode»}
                        <dd>{$item.«textFields.head.name.formatForCode»|truncate:200:"..."}</dd>
                    {/if}
                «ELSE»
                    «val stringFields = fields.filter(typeof(StringField)).filter(e|!e.leading && !e.password)»
                    «IF !stringFields.isEmpty»
                        {if $item.«stringFields.head.name.formatForCode»}
                            <dd>{$item.«stringFields.head.name.formatForCode»|truncate:200:"..."}</dd>
                        {/if}
                    «ENDIF»
                «ENDIF»
                <dd>«detailLink(app.appName)»</dd>
            {foreachelse}
                <dt>{gt text='No entries found.'}</dt>
            {/foreach}
        </dl>
    '''

    def private displayTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context *}
        {foreach item='item' from=$items}
            «val leadingField = getLeadingField»
            «IF leadingField != null»
                <h3>{$item.«leadingField.name.formatForCode»}</h3>
            «ELSE»
                <h3>{gt text='«name.formatForDisplayCapital»'}</h3>
            «ENDIF»
            «IF app.hasUserController && app.getMainUserController.hasActions('display')»
                <p>«detailLink(app.appName)»</p>
            «ENDIF»
        {/foreach}
    '''

    def private editTemplate(Application it) '''
        {* Purpose of this template: edit view of generic item list content type *}

        <div class="z-formrow">
            {gt text='Object type' domain='module_«appName.formatForDB»' assign='objectTypeSelectorLabel'}
            {formlabel for='«appName»_objecttype' text=$objectTypeSelectorLabel}
            {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
            {formdropdownlist id='«appName»_objecttype' dataField='objectType' group='data' mandatory=true items=$allObjectTypes}
            <div class="z-sub z-formnote">{gt text='If you change this please save the element once to reload the parameters below.' domain='module_«appName.formatForDB»'}</div>
        </div>

        {formvolatile}
        {if $properties ne null && is_array($properties)}
            {nocache}
            {foreach key='registryId' item='registryCid' from=$registries}
                {assign var='propName' value=''}
                {foreach key='propertyName' item='propertyId' from=$properties}
                    {if $propertyId eq $registryId}
                        {assign var='propName' value=$propertyName}
                    {/if}
                {/foreach}
                <div class="z-formrow">
                    {modapifunc modname='«appName»' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                    {gt text='Category' domain='module_«appName.formatForDB»' assign='categorySelectorLabel'}
                    {assign var='selectionMode' value='single'}
                    {if $hasMultiSelection eq true}
                        {gt text='Categories' domain='module_«appName.formatForDB»' assign='categorySelectorLabel'}
                        {assign var='selectionMode' value='multiple'}
                    {/if}
                    {formlabel for="«appName»_catids`$propertyName`" text=$categorySelectorLabel}
                    {formdropdownlist id="«appName»_catids`$propName`" items=$categories.$propName dataField='catids' group='data' selectionMode=$selectionMode}
                    <div class="z-sub z-formnote">{gt text='This is an optional filter.' domain='module_«appName.formatForDB»'}</div>
                </div>
            {/foreach}
            {/nocache}
        {/if}
        {/formvolatile}

        <div class="z-formrow">
            {formlabel __text='Sorting'}
            <div>
                {formradiobutton id='«appName»_srandom' value='random' dataField='sorting' group='data' mandatory=true}
                {gt text='Random' domain='module_«appName.formatForDB»' assign='sortingRandomLabel'}
                {formlabel for='«appName»_srandom' text=$sortingRandomLabel}
                {formradiobutton id='«appName»_snewest' value='newest' dataField='sorting' group='data' mandatory=true}
                {gt text='Newest' domain='module_«appName.formatForDB»' assign='sortingNewestLabel'}
                {formlabel for='«appName»_snewest' text=$sortingNewestLabel}
                {formradiobutton id='«appName»_sdefault' value='default' dataField='sorting' group='data' mandatory=true}
                {gt text='Default' domain='module_«appName.formatForDB»' assign='sortingDefaultLabel'}
                {formlabel for='«appName»_sdefault' text=$sortingDefaultLabel}
            </div>
        </div>

        <div class="z-formrow">
            {gt text='Amount' domain='module_«appName.formatForDB»' assign='amountLabel'}
            {formlabel for='«appName»_amount' text=$amountLabel}
            {formintinput id='«appName»_amount' dataField='amount' group='data' mandatory=true maxLength=2}
        </div>

        <div class="z-formrow">
            {gt text='Template' domain='module_«appName.formatForDB»' assign='templateLabel'}
            {formlabel for='«appName»_template' text=$templateLabel}
            {«appName.formatForDB»TemplateSelector assign='allTemplates'}
            {formdropdownlist id='«appName»_template' dataField='template' group='data' mandatory=true items=$allTemplates}
        </div>

        <div id="customtemplatearea" class="z-formrow z-hide">
            {gt text='Custom template' domain='module_«appName.formatForDB»' assign='customTemplateLabel'}
            {formlabel for='«appName»_customtemplate' text=$customTemplateLabel}
            {formtextinput id='«appName»_customtemplate' dataField='customTemplate' group='data' mandatory=false maxLength=80}
            <div class="z-sub z-formnote">{gt text='Example' domain='module_«appName.formatForDB»'}: <em>itemlist_[objecttype]_display.tpl</em></div>
        </div>

        <div class="z-formrow z-hide"«/* TODO: wait until FilterUtil is ready for Doctrine 2 - see https://github.com/zikula/core/issues/118 */»>
            {gt text='Filter (expert option)' domain='module_«appName.formatForDB»' assign='filterLabel'}
            {formlabel for='«appName»_filter' text=$filterLabel}
            {formtextinput id='«appName»_filter' dataField='filter' group='data' mandatory=false maxLength=255}
            <div class="z-sub z-formnote">({gt text='Syntax examples' domain='module_«appName.formatForDB»'}: <kbd>name:like:foobar</kbd> {gt text='or' domain='module_«appName.formatForDB»'} <kbd>status:ne:3</kbd>)</div>
        </div>

        {pageaddvar name='javascript' value='prototype'}
        <script type="text/javascript">
        /* <![CDATA[ */
            function «prefix()»ToggleCustomTemplate() {
                if ($F('«appName»_template') == 'custom') {
                    $('customtemplatearea').removeClassName('z-hide');
                } else {
                    $('customtemplatearea').addClassName('z-hide');
                }
            }

            document.observe('dom:loaded', function() {
                «prefix()»ToggleCustomTemplate();
                $('«appName»_template').observe('change', function(e) {
                    «prefix()»ToggleCustomTemplate();
                });
            });
        /* ]]> */
        </script>
    '''

    def private detailLink(Entity it, String appName) '''
        <a href="{modurl modname='«appName»' type='user' «modUrlDisplayWithFreeOt('item', true, '$objectType')»}">{gt text='Read more'}</a>
    '''
}
