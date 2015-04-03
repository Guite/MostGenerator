package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Categories {
    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate (Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.x')) 'helper' else 'Helper') + '/'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'include_categories_display.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'include_categories_display.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, categoriesViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'include_categories_edit.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'include_categories_edit.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, categoriesEditImpl)
            }
        }
    }

    def private categoriesViewImpl(Application it) '''
        {* purpose of this template: reusable display of entity categories *}
        {if isset($obj.categories)}
            {if isset($panel) && $panel eq true}
                «IF targets('1.3.x')»
                    <h3 class="categories z-panel-header z-panel-indicator «IF targets('1.3.x')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Categories'}</h3>
                    <div class="categories z-panel-content" style="display: none">
                «ELSE»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseCategories">{gt text='Categories'}</a></h3>
                        </div>
                        <div id="collapseCategories" class="panel-collapse collapse in">
                            <div class="panel-body">
                «ENDIF»
            {else}
                <h3 class="categories">{gt text='Categories'}</h3>
            {/if}
            «viewBody»
            {if isset($panel) && $panel eq true}
                «IF targets('1.3.x')»
                    </div>
                «ELSE»
                            </div>
                        </div>
                    </div>
                «ENDIF»
            {/if}
        {/if}
    '''

    def private viewBody(Application it) '''
        {*
        <dl class="propertylist">
        {foreach key='propName' item='catMapping' from=$obj.categories}
            <dt>{$propName}</dt>
            <dd>{$catMapping.category.name|safetext}</dd>
        {/foreach}
        </dl>
        *}
        {assignedcategorieslist categories=$obj.categories doctrine2=true}
    '''

    def private categoriesEditImpl(Application it) '''
        {* purpose of this template: reusable editing of entity attributes *}
        {if isset($panel) && $panel eq true}
            «IF targets('1.3.x')»
                <h3 class="categories z-panel-header z-panel-indicator «IF targets('1.3.x')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Categories'}</h3>
                <fieldset class="categories z-panel-content" style="display: none">
            «ELSE»
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseCategories">{gt text='Categories'}</a></h3>
                    </div>
                    <div id="collapseCategories" class="panel-collapse collapse in">
                        <div class="panel-body">
            «ENDIF»
        {else}
            <fieldset class="categories">
        {/if}
            <legend>{gt text='Categories'}</legend>
            «editBody»
        {if isset($panel) && $panel eq true}
            «IF targets('1.3.x')»
                </fieldset>
            «ELSE»
                        </div>
                    </div>
                </div>
            «ENDIF»
        {else}
            </fieldset>
        {/if}
    '''

    def private editBody(Application it) '''
        {formvolatile}
        {foreach key='registryId' item='registryCid' from=$registries}
            {gt text='Category' assign='categorySelectorLabel'}
            {assign var='selectionMode' value='single'}
            {if $multiSelectionPerRegistry.$registryId eq true}
                {gt text='Categories' assign='categorySelectorLabel'}
                {assign var='selectionMode' value='multiple'}
            {/if}
            <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for="category_`$registryId`" text=$categorySelectorLabel«IF !targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
                «IF !targets('1.3.x')»
                    <div class="col-sm-9">
                «ENDIF»
                    {formcategoryselector id="category_`$registryId`" category=$registryCid
                                          dataField='categories' group=$groupName registryId=$registryId doctrine2=true
                                          selectionMode=$selectionMode}
                «IF !targets('1.3.x')»
                    </div>
                «ENDIF»
            </div>
        {/foreach}
        {/formvolatile}
    '''
}
