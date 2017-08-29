package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeListView {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'ContentType/'
        new CommonIntegrationTemplates().generate(it, fsa, templatePath)

        // content type editing is not ready for Twig yet
        var fileName = 'itemlist_edit.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_edit.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    // content type editing is not ready for Twig yet
    def private editTemplate(Application it) '''
        {* Purpose of this template: edit view of generic item list content type *}
        «editTemplateObjectType»

        «IF hasCategorisableEntities»
            «editTemplateCategories»

        «ENDIF»
        «editTemplateSorting»

        «editTemplateAmount»

        «editTemplateTemplate»

        «editTemplateFilter»

        <script type="text/javascript">
            (function($) {
            	$('#«appName.toFirstLower»Template').change(function() {
            	    $('#customTemplateArea').toggleClass('hidden', $(this).val() != 'custom');
        	    }).trigger('change');
            })(jQuery)
        </script>
    '''

    def private editTemplateObjectType(Application it) '''
        <div class="form-group">
            {gt text='Object type' domain='«appName.formatForDB»' assign='objectTypeSelectorLabel'}
            {formlabel for='«appName.toFirstLower»ObjectType' text=$objectTypeSelectorLabel«editLabelClass»}
            <div class="col-sm-9">
                {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
                {formdropdownlist id='«appName.toFirstLower»ObjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypes«editInputClass»}
                <span class="help-block">{gt text='If you change this please save the element once to reload the parameters below.' domain='«appName.formatForDB»'}</span>
            </div>
        </div>
    '''

    def private editTemplateCategories(Application it) '''
        {if $featureActivationHelper->isEnabled(constant('«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), $objectType)}
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
                {formintinput id='«appName.toFirstLower»Amount' dataField='amount' group='data' mandatory=true maxLength=2 cssClass='form-control'}
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

        <div id="customTemplateArea" class="form-group"{* data-switch="«appName.toFirstLower»Template" data-switch-value="custom"*}>
            {gt text='Custom template' domain='«appName.formatForDB»' assign='customTemplateLabel'}
            {formlabel for='«appName.toFirstLower»CustomTemplate' text=$customTemplateLabel«editLabelClass»}
            <div class="col-sm-9">
                {formtextinput id='«appName.toFirstLower»CustomTemplate' dataField='customTemplate' group='data' mandatory=false maxLength=80«editInputClass»}
                <span class="help-block">{gt text='Example' domain='«appName.formatForDB»'}: <em>itemlist_[objectType]_display.html.twig</em></span>
            </div>
        </div>
    '''

    def private editTemplateFilter(Application it) '''
        <div class="form-group">
            {gt text='Filter (expert option)' domain='«appName.formatForDB»' assign='filterLabel'}
            {formlabel for='«appName.toFirstLower»Filter' text=$filterLabel«editLabelClass»}
            <div class="col-sm-9">
                {formtextinput id='«appName.toFirstLower»Filter' dataField='filter' group='data' mandatory=false maxLength=255«editInputClass»}
                <span class="help-block">{gt text='Example' domain='«appName.formatForDB»'}: <em>tbl.age >= 18</em></span>
            </div>
        </div>
    '''

    def private editLabelClass() ''' cssClass='col-sm-3 control-label'«''»'''
    def private editInputClass() ''' cssClass='form-control'«''»'''
}
