package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Categories {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate (Application it, Controller controller, IFileSystemAccess fsa) {
        val templatePath = appName.getAppSourcePath + 'templates/' + controller.formattedName + '/'
        if (controller.hasActions('view') || controller.hasActions('display'))
            fsa.generateFile(templatePath + 'include_categories_display.tpl', categoriesViewImpl(controller))
        if (controller.hasActions('edit'))
            fsa.generateFile(templatePath + 'include_categories_edit.tpl', categoriesEditImpl(controller))
    }

    def private categoriesViewImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable display of entity categories *}
        {if isset($obj.categories)}
            <h3 class="categories">{gt text='Categories'}</h3>
            {*
            <dl class="propertylist">
            {foreach key='propName' item='catMapping' from=$obj.categories}
                <dt>{$propName}</dt>
                <dd>{$catMapping.category.name|safetext}</dd>
            {/foreach}
            </dl>
            *}
            {assignedcategorieslist categories=$obj.categories doctrine2=true}
        {/if}
    '''

    def private categoriesEditImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable editing of entity attributes *}
        <fieldset>
            <legend>{gt text='Categories'}</legend>
            {formvolatile}
            {foreach key='registryId' item='registryCid' from=$registries}
                <div class="z-formrow">
                    {formlabel for="category_`$registryId`" __text='Category'}
                    {formcategoryselector id="category_`$registryId`" category=$registryCid
                                          dataField='categories' group=$groupName registryId=$registryId doctrine2=true}
                </div>
            {/foreach}
            {/formvolatile}
        </fieldset>
    '''
}
