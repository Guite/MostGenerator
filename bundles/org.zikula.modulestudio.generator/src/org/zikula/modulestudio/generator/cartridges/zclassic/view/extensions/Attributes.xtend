package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Attributes {
    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate (Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.x')) 'helper' else 'Helper') + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeAttributesDisplay' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeAttributesDisplay.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) attributesViewImplLegacy else attributesViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'includeAttributesEdit' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeAttributesEdit.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) attributesEditImplLegacy else attributesEditImpl)
            }
        }
    }

    def private attributesViewImplLegacy(Application it) '''
        {* purpose of this template: reusable display of entity attributes *}
        {if isset($obj.attributes)}
            {if isset($panel) && $panel eq true}
                <h3 class="attributes z-panel-header z-panel-indicator z-pointer">{gt text='Attributes'}</h3>
                <div class="attributes z-panel-content" style="display: none">
            {else}
                <h3 class="attributes">{gt text='Attributes'}</h3>
            {/if}
            «viewBodyLegacy»
            {if isset($panel) && $panel eq true}
                </div>
            {/if}
        {/if}
    '''

    def private attributesViewImpl(Application it) '''
        {# purpose of this template: reusable display of entity attributes #}
        {% if obj.attributes is defined %}
            {% if panel|default(false) == true %}
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseAttributes">{{ __('Attributes') }}</a></h3>
                    </div>
                    <div id="collapseAttributes" class="panel-collapse collapse in">
                        <div class="panel-body">
            {% else %}
                <h3 class="attributes">{{ __('Attributes') }}</h3>
            {% endif %}
            «viewBody»
            {% if panel|default(false) == true %}
                        </div>
                    </div>
                </div>
            {% endif %}
        {% endif %}
    '''

    def private viewBodyLegacy(Application it) '''
        <dl class="propertylist">
        {foreach key='fieldName' item='fieldInfo' from=$obj.attributes}
            <dt>{$fieldName|safetext}</dt>
            <dd>{$fieldInfo.value|default:''|safetext}</dd>
        {/foreach}
        </dl>
    '''

    def private viewBody(Application it) '''
        <dl class="propertylist">
        {% for fieldName, fieldInfo in obj.attributes %}
            <dt>{{ fieldName }}</dt>
            <dd>{{ fieldInfo.value }}</dd>
        {% endfor %}
        </dl>
    '''

    def private attributesEditImplLegacy(Application it) '''
        {* purpose of this template: reusable editing of entity attributes *}
        {if isset($panel) && $panel eq true}
            <h3 class="attributes z-panel-header z-panel-indicator z-pointer">{gt text='Attributes'}</h3>
            <fieldset class="attributes z-panel-content" style="display: none">
        {else}
            <fieldset class="attributes">
        {/if}
            <legend>{gt text='Attributes'}</legend>
            «editBodyLegacy»
        {if isset($panel) && $panel eq true}
            </fieldset>
        {else}
            </fieldset>
        {/if}
    '''

    def private attributesEditImpl(Application it) '''
        {# purpose of this template: reusable editing of entity attributes #}
        {% if panel|default(false) == true %}
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseAttributes">{{ __('Attributes') }}</a></h3>
                </div>
                <div id="collapseAttributes" class="panel-collapse collapse in">
                    <div class="panel-body">
        {% else %}
            <fieldset class="attributes">
        {% endif %}
            <legend>{{ __('Attributes') }}</legend>
            «editBody»
        {% if panel|default(false) == true %}
                    </div>
                </div>
            </div>
        {% else %}
            </fieldset>
        {% endif %}
    '''

    def private editBodyLegacy(Application it) '''
        {formvolatile}
        {foreach key='fieldName' item='fieldValue' from=$attributes}
            <div class="z-formrow">
                {formlabel for="attributes`$fieldName`"' text=$fieldName}
                {formtextinput id="attributes`$fieldName`" group='attributes' dataField=$fieldName maxLength=255}
            </div>
        {/foreach}
        {/formvolatile}
    '''

    def private editBody(Application it) '''
        {% for fieldName, fieldValue in attributes %}
            {{ form_row(attribute(form.attributes, fieldName)) }}
        {% endfor %}
    '''
}
