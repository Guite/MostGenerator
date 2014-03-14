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
        var entityTemplate = ''
        for (entity : getAllEntities) {
            entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + '_display_description.tpl'
            if (!shouldBeSkipped(entityTemplate)) {
                fsa.generateFile(entityTemplate, entity.displayDescTemplate(it))
            }
            entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + '_display.tpl'
            if (!shouldBeSkipped(entityTemplate)) {
                fsa.generateFile(entityTemplate, entity.displayTemplate(it))
            }
        }
        if (!shouldBeSkipped(templatePath + 'itemlist_display.tpl')) {
            fsa.generateFile(templatePath + 'itemlist_display.tpl', fallbackDisplayTemplate)
        }
        if (!shouldBeSkipped(templatePath + 'itemlist_edit.tpl')) {
            fsa.generateFile(templatePath + 'itemlist_edit.tpl', editTemplate)
        }
    }

    def private displayDescTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context *}
        <dl>
            {foreach item='«name.formatForCode»' from=$items}
                <dt>{$«name.formatForCode»->getTitleFromDisplayPattern()}</dt>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty»
                    {if $«name.formatForCode».«textFields.head.name.formatForCode»}
                        <dd>{$«name.formatForCode».«textFields.head.name.formatForCode»|strip_tags|truncate:200:'&hellip;'}</dd>
                    {/if}
                «ELSE»
                    «val stringFields = fields.filter(StringField).filter[!leading && !password]»
                    «IF !stringFields.empty»
                        {if $«name.formatForCode».«stringFields.head.name.formatForCode»}
                            <dd>{$«name.formatForCode».«stringFields.head.name.formatForCode»|strip_tags|truncate:200:'&hellip;'}</dd>
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
            <h3>{$«name.formatForCode»->getTitleFromDisplayPattern()}</h3>
            «IF app.hasUserController && app.getMainUserController.hasActions('display')»
                <p>«detailLink(app.appName)»</p>
            «ENDIF»
        {/foreach}
    '''

    def private fallbackDisplayTemplate(Application it) '''
        {* Purpose of this template: Display objects within an external context *}
    '''

    def private editTemplate(Application it) '''
        {* Purpose of this template: edit view of generic item list content type *}
        «editTemplateObjectType»

        «editTemplateCategories»

        «editTemplateSorting»

        «editTemplateAmount»

        «editTemplateTemplate»

        «editTemplateFilter»

        «editTemplateJs»
    '''

    def private editTemplateObjectType(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            {gt text='Object type' domain='module_«appName.formatForDB»' assign='objectTypeSelectorLabel'}
            {formlabel for='«appName.toFirstLower»ObjectType' text=$objectTypeSelectorLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
                {formdropdownlist id='«appName.toFirstLower»OjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypes«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='If you change this please save the element once to reload the parameters below.' domain='module_«appName.formatForDB»'}</span>
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateCategories(Application it) '''
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
                    {formlabel for="«appName.toFirstLower»CatIds`$propertyName`" text=$categorySelectorLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                    «IF !targets('1.3.5')»
                        <div class="col-lg-9">
                    «ENDIF»
                        {formdropdownlist id="«appName.toFirstLower»CatIds`$propName`" items=$categories.$propName dataField="catids`$propName`" group='data' selectionMode=$selectionMode«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                        <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='This is an optional filter.' domain='module_«appName.formatForDB»'}</span>
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                </div>
            {/foreach}
            {/nocache}
        {/if}
        {/formvolatile}
    '''

    def private editTemplateSorting(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            {gt text='Sorting' domain='module_«appName.formatForDB»' assign='sortingLabel'}
            {formlabel text=$sortingLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            <div«IF !targets('1.3.5')» class="col-lg-9"«ENDIF»>
                {formradiobutton id='«appName.toFirstLower»SortRandom' value='random' dataField='sorting' group='data' mandatory=true}
                {gt text='Random' domain='module_«appName.formatForDB»' assign='sortingRandomLabel'}
                {formlabel for='«appName.toFirstLower»SortRandom' text=$sortingRandomLabel}
                {formradiobutton id='«appName.toFirstLower»SortNewest' value='newest' dataField='sorting' group='data' mandatory=true}
                {gt text='Newest' domain='module_«appName.formatForDB»' assign='sortingNewestLabel'}
                {formlabel for='«appName.toFirstLower»SortNewest' text=$sortingNewestLabel}
                {formradiobutton id='«appName.toFirstLower»SortDefault' value='default' dataField='sorting' group='data' mandatory=true}
                {gt text='Default' domain='module_«appName.formatForDB»' assign='sortingDefaultLabel'}
                {formlabel for='«appName.toFirstLower»SortDefault' text=$sortingDefaultLabel}
            </div>
        </div>
    '''

    def private editTemplateAmount(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            {gt text='Amount' domain='module_«appName.formatForDB»' assign='amountLabel'}
            {formlabel for='«appName.toFirstLower»Amount' text=$amountLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {formintinput id='«appName.toFirstLower»Amount' dataField='amount' group='data' mandatory=true maxLength=2}
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateTemplate(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            {gt text='Template' domain='module_«appName.formatForDB»' assign='templateLabel'}
            {formlabel for='«appName.toFirstLower»Template' text=$templateLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {«appName.formatForDB»TemplateSelector assign='allTemplates'}
                {formdropdownlist id='«appName.toFirstLower»Template' dataField='template' group='data' mandatory=true items=$allTemplates«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>

        <div id="customTemplateArea" class="«IF targets('1.3.5')»z-formrow z-hide«ELSE»form-group hidden«ENDIF»">
            {gt text='Custom template' domain='module_«appName.formatForDB»' assign='customTemplateLabel'}
            {formlabel for='«appName.toFirstLower»CustomTemplate' text=$customTemplateLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {formtextinput id='«appName.toFirstLower»CustomTemplate' dataField='customTemplate' group='data' mandatory=false maxLength=80«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                <span class="«IF targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='Example' domain='module_«appName.formatForDB»'}: <em>itemlist_[objectType]_display.tpl</em></span>
            «IF !targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateFilter(Application it) '''
        <div class="«IF targets('1.3.5')»z-formrow z-hide«ELSE»form-group«ENDIF»">
            {gt text='Filter (expert option)' domain='module_«appName.formatForDB»' assign='filterLabel'}
            {formlabel for='«appName.toFirstLower»Filter' text=$filterLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF !targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                {formtextinput id='«appName.toFirstLower»Filter' dataField='filter' group='data' mandatory=false maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
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
        «IF !targets('1.3.5')»

            {include file='include_filterSyntaxDialog.tpl'}
        «ENDIF»
    '''

    def private editTemplateJs(Application it) '''
        {pageaddvar name='javascript' value='prototype'}
        <script type="text/javascript">
        /* <![CDATA[ */
            function «prefix()»ToggleCustomTemplate() {
                if ($F('«appName.toFirstLower»Template') == 'custom') {
                    $('customTemplateArea').removeClassName('«IF targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»');
                } else {
                    $('customTemplateArea').addClassName('«IF targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»');
                }
            }

            document.observe('dom:loaded', function() {
                «prefix()»ToggleCustomTemplate();
                $('«appName.toFirstLower»Template').observe('change', function(e) {
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
