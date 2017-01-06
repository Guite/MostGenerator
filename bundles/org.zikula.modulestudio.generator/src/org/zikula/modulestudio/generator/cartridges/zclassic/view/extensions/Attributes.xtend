package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Attributes {

    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions

    def generate (Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Helper/'
        val templateExtension = '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeAttributesDisplay' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeAttributesDisplay.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, attributesViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'includeAttributesEdit' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeAttributesEdit.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, attributesEditImpl)
            }
        }
    }

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

    def private viewBody(Application it) '''
        <dl class="propertylist">
        {% for attributeName, attributeInfo in obj.attributes %}
            <dt>{{ attributeName }}</dt>
            <dd>{{ attributeInfo.value }}</dd>
        {% endfor %}
        </dl>
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

    def private editBody(Application it) '''
        {% for attributeName, attributeValue in attributes %}
            {{ form_row(attribute(form, 'attributes' ~ attributeName)) }}
        {% endfor %}
    '''
}
