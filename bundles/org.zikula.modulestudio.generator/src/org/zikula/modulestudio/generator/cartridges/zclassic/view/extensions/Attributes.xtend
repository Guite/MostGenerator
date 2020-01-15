package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Attributes {

    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate (Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Helper/'
        val templateExtension = '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeAttributesDisplay' + templateExtension
            fsa.generateFile(templatePath + fileName, attributesViewImpl)
        }
        if (hasEditActions) {
            fileName = 'includeAttributesEdit' + templateExtension
            fsa.generateFile(templatePath + fileName, attributesEditImpl)
        }
    }

    def private attributesViewImpl(Application it) '''
        {# purpose of this template: reusable display of entity attributes #}
        {% if obj.attributes is defined %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabAttributes" aria-labelledby="attributesTab">
                    <h3>«IF targets('3.0')»{% trans %}Attributes{% endtrans %}«ELSE»{{ __('Attributes') }}«ENDIF»</h3>
            {% else %}
                <h3 class="attributes">«IF targets('3.0')»{% trans %}Attributes{% endtrans %}«ELSE»{{ __('Attributes') }}«ENDIF»</h3>
            {% endif %}
            «viewBody»
            {% if tabs|default(false) == true %}
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
        {% if tabs|default(false) == true %}
            <div role="tabpanel" class="tab-pane fade" id="tabAttributes" aria-labelledby="attributesTab">
                <h3>«IF targets('3.0')»{% trans %}Attributes{% endtrans %}«ELSE»{{ __('Attributes') }}«ENDIF»</h3>
        {% else %}
            <fieldset class="attributes">
        {% endif %}
            <legend>«IF targets('3.0')»{% trans %}Attributes{% endtrans %}«ELSE»{{ __('Attributes') }}«ENDIF»</legend>
            «editBody»
        {% if tabs|default(false) == true %}
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
