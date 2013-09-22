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
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension UrlExtensions = new UrlExtensions
    @Inject extension Utils = new Utils

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
            {foreach item='«name.formatForCode»' from=$items}
                «val leadingField = getLeadingField»
                «IF leadingField !== null»
                    <dt>{$«name.formatForCode».«leadingField.name.formatForCode»}</dt>
                «ELSE»
                    <dt>{gt text='«name.formatForDisplayCapital»'}</dt>
                «ENDIF»
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty»
                    {if $«name.formatForCode».«textFields.head.name.formatForCode»}
                        <dd>{$«name.formatForCode».«textFields.head.name.formatForCode»|truncate:200:"..."}</dd>
                    {/if}
                «ELSE»
                    «val stringFields = fields.filter(StringField).filter[!leading && !password]»
                    «IF !stringFields.empty»
                        {if $«name.formatForCode».«stringFields.head.name.formatForCode»}
                            <dd>{$«name.formatForCode».«stringFields.head.name.formatForCode»|truncate:200:"..."}</dd>
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
        {foreach item='«name.formatForCode»' from=$items}
            «val leadingField = getLeadingField»
            «IF leadingField !== null»
                <h3>{$«name.formatForCode».«leadingField.name.formatForCode»}</h3>
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

        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            {gt text='Object type' domain='module_«appName.formatForDB»' assign='objectTypeSelectorLabel'}
            {formlabel for='«appName»_objecttype' text=$objectTypeSelectorLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
                {formdropdownlist id='«appName»_objecttype' dataField='objectType' group='data' mandatory=true items=$allObjectTypes«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='If you change this please save the element once to reload the parameters below.' domain='module_«appName.formatForDB»'}</span>
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
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
                <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                    {modapifunc modname='«appName»' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                    {gt text='Category' domain='module_«appName.formatForDB»' assign='categorySelectorLabel'}
                    {assign var='selectionMode' value='single'}
                    {if $hasMultiSelection eq true}
                        {gt text='Categories' domain='module_«appName.formatForDB»' assign='categorySelectorLabel'}
                        {assign var='selectionMode' value='multiple'}
                    {/if}
                    {formlabel for="«appName»_catids`$propertyName`" text=$categorySelectorLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                    «IF !targets('1.3.5')»
                        <div class="col-lg-9">
                    «ENDIF»
                        {formdropdownlist id="«appName»_catids`$propName`" items=$categories.$propName dataField="catids`$propName`" group='data' selectionMode=$selectionMode«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                        <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='This is an optional filter.' domain='module_«appName.formatForDB»'}</span>
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                </div>
            {/foreach}
            {/nocache}
        {/if}
        {/formvolatile}

        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            {gt text='Sorting' domain='module_«appName.formatForDB»' assign='sortingLabel'}
            {formlabel text=$sortingLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            <div«IF !targets('1.3.5')» class="col-lg-9"«ENDIF»>
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

        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            {gt text='Amount' domain='module_«appName.formatForDB»' assign='amountLabel'}
            {formlabel for='«appName»_amount' text=$amountLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {formintinput id='«appName»_amount' dataField='amount' group='data' mandatory=true maxLength=2}
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>

        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            {gt text='Template' domain='module_«appName.formatForDB»' assign='templateLabel'}
            {formlabel for='«appName»_template' text=$templateLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {«appName.formatForDB»TemplateSelector assign='allTemplates'}
                {formdropdownlist id='«appName»_template' dataField='template' group='data' mandatory=true items=$allTemplates«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>

        <div id="customtemplatearea" class="«IF targets('1.3.5')»z-formrow z-hide«ELSE»form-group hide«ENDIF»">
            {gt text='Custom template' domain='module_«appName.formatForDB»' assign='customTemplateLabel'}
            {formlabel for='«appName»_customtemplate' text=$customTemplateLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {formtextinput id='«appName»_customtemplate' dataField='customTemplate' group='data' mandatory=false maxLength=80«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='Example' domain='module_«appName.formatForDB»'}: <em>itemlist_[objecttype]_display.tpl</em></span>
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>

        <div class="«IF targets('1.3.5')»z-formrow z-hide«ELSE»form-group hide«ENDIF»"«/* TODO: wait until FilterUtil is ready for Doctrine 2 - see https://github.com/zikula/core/issues/118 */»>
            {gt text='Filter (expert option)' domain='module_«appName.formatForDB»' assign='filterLabel'}
            {formlabel for='«appName»_filter' text=$filterLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {formtextinput id='«appName»_filter' dataField='filter' group='data' mandatory=false maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">({gt text='Syntax examples' domain='module_«appName.formatForDB»'}: <kbd>name:like:foobar</kbd> {gt text='or' domain='module_«appName.formatForDB»'} <kbd>status:ne:3</kbd>)</span>
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>

        {pageaddvar name='javascript' value='prototype'}
        <script type="text/javascript">
        /* <![CDATA[ */
            function «prefix()»ToggleCustomTemplate() {
                if ($F('«appName»_template') == 'custom') {
                    $('customtemplatearea').removeClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
                } else {
                    $('customtemplatearea').addClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
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
        <a href="{modurl modname='«appName»' type='user' «modUrlDisplayWithFreeOt(name.formatForCode, true, '$objectType')»}">{gt text='Read more'}</a>
    '''
}
