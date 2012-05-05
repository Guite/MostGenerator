package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Attributes {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate (Application it, Controller controller, IFileSystemAccess fsa) {
        val templatePath = appName.getAppSourcePath + 'templates/' + controller.formattedName + '/'
        if (controller.hasActions('view') || controller.hasActions('display'))
            fsa.generateFile(templatePath + 'include_attributes_display.tpl', attributesViewImpl(controller))
        if (controller.hasActions('edit'))
            fsa.generateFile(templatePath + 'include_attributes_edit.tpl', attributesEditImpl(controller))
    }

    def private attributesViewImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable display of entity attributes *}
        {if isset($obj.attributes)}
            <h3 class="attributes">{gt text='Attributes'}</h3>
            <dl class="propertylist">
            {foreach key='fieldName' item='fieldInfo' from=$obj.attributes}
                <dt>{$fieldName|safetext}</dt>
                <dd>{$fieldInfo.value|default:''|safetext}</dd>
            {/foreach}
            </dl>
        {/if}
    '''

    def private attributesEditImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable editing of entity attributes *}
        <fieldset>
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
