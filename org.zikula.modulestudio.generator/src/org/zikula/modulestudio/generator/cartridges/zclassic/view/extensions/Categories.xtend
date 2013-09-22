package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Categories {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate (Application it, Controller controller, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) controller.formattedName else controller.formattedName.toFirstUpper) + '/'
        if (controller.hasActions('view') || controller.hasActions('display'))
            fsa.generateFile(templatePath + 'include_categories_display.tpl', categoriesViewImpl(controller))
        if (controller.hasActions('edit'))
            fsa.generateFile(templatePath + 'include_categories_edit.tpl', categoriesEditImpl(controller))
    }

    def private categoriesViewImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable display of entity categories *}
        {if isset($obj.categories)}
            {if isset($panel) && $panel eq true}
                <h3 class="categories z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Categories'}</h3>
                <div class="categories z-panel-content" style="display: none">
            {else}
                <h3 class="categories">{gt text='Categories'}</h3>
            {/if}
            {*
            <dl class="propertylist">
            {foreach key='propName' item='catMapping' from=$obj.categories}
                <dt>{$propName}</dt>
                <dd>{$catMapping.category.name|safetext}</dd>
            {/foreach}
            </dl>
            *}
            {assignedcategorieslist categories=$obj.categories doctrine2=true}
            {if isset($panel) && $panel eq true}
                </div>
            {/if}
        {/if}
    '''

    def private categoriesEditImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable editing of entity attributes *}
        {if isset($panel) && $panel eq true}
            <h3 class="categories z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Categories'}</h3>
            <fieldset class="categories z-panel-content" style="display: none">
        {else}
            <fieldset class="categories">
        {/if}
            <legend>{gt text='Categories'}</legend>
            {formvolatile}
            {foreach key='registryId' item='registryCid' from=$registries}
                {gt text='Category' assign='categorySelectorLabel'}
                {assign var='selectionMode' value='single'}
                {if $multiSelectionPerRegistry.$registryId eq true}
                    {gt text='Categories' assign='categorySelectorLabel'}
                    {assign var='selectionMode' value='multiple'}
                {/if}
                <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                    {formlabel for="category_`$registryId`" text=$categorySelectorLabel«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                    «IF !targets('1.3.5')»
                        <div class="col-lg-9">
                    «ENDIF»
                        {formcategoryselector id="category_`$registryId`" category=$registryCid
                                              dataField='categories' group=$groupName registryId=$registryId doctrine2=true
                                              selectionMode=$selectionMode}
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                </div>
            {/foreach}
            {/formvolatile}
        </fieldset>
    '''
}
