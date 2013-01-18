package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Attributes {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    def generate (Application it, Controller controller, IFileSystemAccess fsa) {
        val templatePath = getAppSourcePath + 'templates/' + controller.formattedName + '/'
        if (controller.hasActions('view') || controller.hasActions('display'))
            fsa.generateFile(templatePath + 'include_attributes_display.tpl', attributesViewImpl(controller))
        if (controller.hasActions('edit'))
            fsa.generateFile(templatePath + 'include_attributes_edit.tpl', attributesEditImpl(controller))
    }

    def private attributesViewImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable display of entity attributes *}
        {if isset($obj.attributes)}
            {if isset($panel) && $panel eq true}
                <h3 class="attributes z-panel-header z-panel-indicator z-pointer">{gt text='Attributes'}</h3>
                <div class="attributes z-panel-content" style="display: none">
            {else}
                <h3 class="attributes">{gt text='Attributes'}</h3>
            {/if}
            <dl class="propertylist">
            {foreach key='fieldName' item='fieldInfo' from=$obj.attributes}
                <dt>{$fieldName|safetext}</dt>
                <dd>{$fieldInfo.value|default:''|safetext}</dd>
            {/foreach}
            </dl>
            {if isset($panel) && $panel eq true}
                </div>
            {/if}
        {/if}
    '''

    def private attributesEditImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable editing of entity attributes *}
            {if isset($panel) && $panel eq true}
                <h3 class="attributes z-panel-header z-panel-indicator z-pointer">{gt text='Attributes'}</h3>
                <fieldset class="attributes z-panel-content" style="display: none">
            {else}
                <fieldset class="attributes">
            {/if}
            <legend>{gt text='Attributes'}</legend>
            {formvolatile}
            {foreach key='fieldName' item='fieldValue' from=$attributes}
            <div class="z-formrow">
                {formlabel for="attributes`$fieldName`"' text=$fieldName}
                {formtextinput id="attributes`$fieldName`" group='attributes' dataField=$fieldName maxLength=255}
            </div>
            {/foreach}
            {/formvolatile}
        </fieldset>
    '''
}
