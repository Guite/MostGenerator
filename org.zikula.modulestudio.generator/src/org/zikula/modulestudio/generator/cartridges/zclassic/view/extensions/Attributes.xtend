package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Attributes {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate (Application it, Controller controller, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) controller.formattedName else controller.formattedName.toFirstUpper) + '/'
        var fileName = ''
        if (controller.hasActions('view') || controller.hasActions('display')) {
            fileName = 'include_attributes_display.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'include_attributes_display.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, attributesViewImpl(controller))
            }
        }
        if (controller.hasActions('edit')) {
            fileName = 'include_attributes_edit.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'include_attributes_edit.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, attributesEditImpl(controller))
            }
        }
    }

    def private attributesViewImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable display of entity attributes *}
        {if isset($obj.attributes)}
            {if isset($panel) && $panel eq true}
                <h3 class="attributes z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Attributes'}</h3>
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
                <h3 class="attributes z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Attributes'}</h3>
                <fieldset class="attributes z-panel-content" style="display: none">
            {else}
                <fieldset class="attributes">
            {/if}
            <legend>{gt text='Attributes'}</legend>
            {formvolatile}
            {foreach key='fieldName' item='fieldValue' from=$attributes}
            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for="attributes`$fieldName`"' text=$fieldName«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput id="attributes`$fieldName`" group='attributes' dataField=$fieldName maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>
            {/foreach}
            {/formvolatile}
        </fieldset>
    '''
}
