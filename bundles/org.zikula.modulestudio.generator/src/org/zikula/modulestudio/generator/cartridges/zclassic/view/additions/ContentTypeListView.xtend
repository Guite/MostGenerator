package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeListView {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'ContentType/'
        val templateExtension = '.html.twig'
        var fileName = ''
        for (entity : getAllEntities) {
            fileName = 'itemlist_' + entity.name.formatForCode + '_display_description' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'itemlist_' + entity.name.formatForCode + '_display_description.generated' + templateExtension 
                }
                fsa.generateFile(templatePath + fileName, entity.displayDescTemplate(it))
            }
            fileName = 'itemlist_' + entity.name.formatForCode + '_display' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'itemlist_' + entity.name.formatForCode + '_display.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, entity.displayTemplate(it))
            }
        }
        fileName = 'itemlist_display' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_display.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, fallbackDisplayTemplate)
        }
        // content type editing is not ready for Twig yet
        fileName = 'itemlist_edit.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_edit.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    def private displayDescTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context #}
        <dl>
            {% for «name.formatForCode» in items %}
                <dt>{{ «name.formatForCode».getTitleFromDisplayPattern() }}</dt>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty»
                    {% if «name.formatForCode».«textFields.head.name.formatForCode» %}
                        <dd>{{ «name.formatForCode».«textFields.head.name.formatForCode»|striptags|truncate(200, true, '&hellip;') }}</dd>
                    {% endif %}
                «ELSE»
                    «val stringFields = fields.filter(StringField).filter[!password]»
                    «IF !stringFields.empty»
                        {% if «name.formatForCode».«stringFields.head.name.formatForCode» %}
                            <dd>{{ «name.formatForCode».«stringFields.head.name.formatForCode»|striptags|truncate(200, true, '&hellip;') }}</dd>
                        {% endif %}
                    «ENDIF»
                «ENDIF»
                <dd>«detailLink(app.appName)»</dd>
            {% else %}
                <dt>{{ __('No entries found.') }}</dt>
            {% endfor %}
        </dl>
    '''

    def private displayTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context #}
        {% for «name.formatForCode» in items %}
            <h3>{{ «name.formatForCode».getTitleFromDisplayPattern() }}</h3>
            «IF app.hasUserController && app.getMainUserController.hasActions('display')»
                <p>«detailLink(app.appName)»</p>
            «ENDIF»
        {% endfor %}
    '''

    def private fallbackDisplayTemplate(Application it) '''
        {# Purpose of this template: Display objects within an external context #}
    '''

    // content type editing is not ready for Twig yet
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
        <div class="form-group">
            {gt text='Object type' domain='«appName.formatForDB»' assign='objectTypeSelectorLabel'}
            {formlabel for='«appName.toFirstLower»ObjectType' text=$objectTypeSelectorLabel«editLabelClass»}
            <div class="col-sm-9">
                {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
                {formdropdownlist id='«appName.toFirstLower»OjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypes«editInputClass»}
                <span class="help-block">{gt text='If you change this please save the element once to reload the parameters below.' domain='«appName.formatForDB»'}</span>
            </div>
        </div>
    '''

    def private editTemplateCategories(Application it) '''
        {if $featureActivationHelper->isEnabled(const('«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES', $objectType))}
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
                <div class="form-group">
                    {assign var='hasMultiSelection' value=$categoryHelper->hasMultipleSelection($objectType, $propertyName)}
                    {gt text='Category' domain='«appName.formatForDB»' assign='categorySelectorLabel'}
                    {assign var='selectionMode' value='single'}
                    {if $hasMultiSelection eq true}
                        {gt text='Categories' domain='«appName.formatForDB»' assign='categorySelectorLabel'}
                        {assign var='selectionMode' value='multiple'}
                    {/if}
                    {formlabel for="«appName.toFirstLower»CatIds`$propertyName`" text=$categorySelectorLabel«editLabelClass»}
                    <div class="col-sm-9">
                        {formdropdownlist id="«appName.toFirstLower»CatIds`$propName`" items=$categories.$propName dataField="catids`$propName`" group='data' selectionMode=$selectionMode«editInputClass»}
                        <span class="help-block">{gt text='This is an optional filter.' domain='«appName.formatForDB»'}</span>
                    </div>
                </div>
            {/foreach}
            {/nocache}
        {/if}
        {/formvolatile}
        {/if}
    '''

    def private editTemplateSorting(Application it) '''
        <div class="form-group">
            {gt text='Sorting' domain='«appName.formatForDB»' assign='sortingLabel'}
            {formlabel text=$sortingLabel«editLabelClass»}
            <div class="col-sm-9">
                {formradiobutton id='«appName.toFirstLower»SortRandom' value='random' dataField='sorting' group='data' mandatory=true}
                {gt text='Random' domain='«appName.formatForDB»' assign='sortingRandomLabel'}
                {formlabel for='«appName.toFirstLower»SortRandom' text=$sortingRandomLabel}
                {formradiobutton id='«appName.toFirstLower»SortNewest' value='newest' dataField='sorting' group='data' mandatory=true}
                {gt text='Newest' domain='«appName.formatForDB»' assign='sortingNewestLabel'}
                {formlabel for='«appName.toFirstLower»SortNewest' text=$sortingNewestLabel}
                {formradiobutton id='«appName.toFirstLower»SortDefault' value='default' dataField='sorting' group='data' mandatory=true}
                {gt text='Default' domain='«appName.formatForDB»' assign='sortingDefaultLabel'}
                {formlabel for='«appName.toFirstLower»SortDefault' text=$sortingDefaultLabel}
            </div>
        </div>
    '''

    def private editTemplateAmount(Application it) '''
        <div class="form-group">
            {gt text='Amount' domain='«appName.formatForDB»' assign='amountLabel'}
            {formlabel for='«appName.toFirstLower»Amount' text=$amountLabel«editLabelClass»}
            <div class="col-sm-9">
                {formintinput id='«appName.toFirstLower»Amount' dataField='amount' group='data' mandatory=true maxLength=2}
            </div>
        </div>
    '''

    def private editTemplateTemplate(Application it) '''
        <div class="form-group">
            {gt text='Template' domain='«appName.formatForDB»' assign='templateLabel'}
            {formlabel for='«appName.toFirstLower»Template' text=$templateLabel«editLabelClass»}
            <div class="col-sm-9">
                {«appName.formatForDB»TemplateSelector assign='allTemplates'}
                {formdropdownlist id='«appName.toFirstLower»Template' dataField='template' group='data' mandatory=true items=$allTemplates«editInputClass»}
            </div>
        </div>

        <div id="customTemplateArea" class="form-group" data-switch="«appName.toFirstLower»Template" data-switch-value="custom">
            {gt text='Custom template' domain='«appName.formatForDB»' assign='customTemplateLabel'}
            {formlabel for='«appName.toFirstLower»CustomTemplate' text=$customTemplateLabel«editLabelClass»}
            <div class="col-sm-9">
                {formtextinput id='«appName.toFirstLower»CustomTemplate' dataField='customTemplate' group='data' mandatory=false maxLength=80«editInputClass»}
                <span class="help-block">{gt text='Example' domain='«appName.formatForDB»'}: <em>itemlist_[objectType]_display.tpl</em></span>
            </div>
        </div>
    '''

    def private editTemplateFilter(Application it) '''
        <div class="form-group">
            {gt text='Filter (expert option)' domain='«appName.formatForDB»' assign='filterLabel'}
            {formlabel for='«appName.toFirstLower»Filter' text=$filterLabel«editLabelClass»}
            <div class="col-sm-9">
                {formtextinput id='«appName.toFirstLower»Filter' dataField='filter' group='data' mandatory=false maxLength=255«editInputClass»}
                {*<span class="help-block">
                    <a class="fa fa-filter" data-toggle="modal" data-target="#filterSyntaxModal">{gt text='Show syntax examples' domain='«appName.formatForDB»'}</a>
                </span>*}
            </div>
        </div>

        {*include file='include_filterSyntaxDialog.tpl'*}
    '''

    def private editTemplateJs(Application it) '''
        {pageaddvar name='stylesheet' value='web/bootstrap/css/bootstrap.min.css'}
        {pageaddvar name='stylesheet' value='web/bootstrap/css/bootstrap-theme.min.css'}
        {pageaddvar name='javascript' value='web/bootstrap/js/bootstrap.min.js'}
    '''

    def private detailLink(Entity it, String appName) '''
        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}">{{ __('Read more') }}</a>
    '''

    def private editLabelClass() ''' cssClass='col-sm-3 control-label'«''»'''
    def private editInputClass() ''' cssClass='form-control'«''»'''
}
