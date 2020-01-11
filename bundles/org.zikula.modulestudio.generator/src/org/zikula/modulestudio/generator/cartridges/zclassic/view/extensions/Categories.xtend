package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Categories {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate (Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Helper/'
        val templateExtension = '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeCategoriesDisplay' + templateExtension
            fsa.generateFile(templatePath + fileName, categoriesViewImpl)
        }
        if (hasEditActions) {
            fileName = 'includeCategoriesEdit' + templateExtension
            fsa.generateFile(templatePath + fileName, categoriesEditImpl)
        }
    }

    def private categoriesViewImpl(Application it) '''
        {# purpose of this template: reusable display of entity categories #}
        «IF !isSystemModule && targets('3.0')»
            {% trans_default_domain '«appName.formatForDB»' %}
        «ENDIF»
        {% if obj.categories is defined %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabCategories" aria-labelledby="categoriesTab">
                    <h3>«IF targets('3.0')»{% trans %}Categories{% endtrans %}«ELSE»{{ __('Categories') }}«ENDIF»</h3>
            {% else %}
                <h3 class="categories">«IF targets('3.0')»{% trans %}Categories{% endtrans %}«ELSE»{{ __('Categories') }}«ENDIF»</h3>
            {% endif %}
            «viewBody»
            {% if tabs|default(false) == true %}
                </div>
            {% endif %}
        {% endif %}
    '''

    def private viewBody(Application it) '''
        <ul class="category-list">
        {% for catMapping in obj.categories %}
            <li>«IF targets('3.0')»{% if catMapping.category.icon %}<i class="fa-fw {{ catMapping.category.icon|e('html_attr') }}"></i> {% endif %}«ENDIF»{{ catMapping.category.display_name[app.request.locale]|default(catMapping.category.name) }}</li>
        {% endfor %}
        </ul>
    '''

    def private categoriesEditImpl(Application it) '''
        {# purpose of this template: reusable editing of entity categories #}
        «IF !isSystemModule && targets('3.0')»
            {% trans_default_domain '«appName.formatForDB»' %}
        «ENDIF»
        {% if tabs|default(false) == true %}
            <div role="tabpanel" class="tab-pane fade" id="tabCategories" aria-labelledby="categoriesTab">
                <h3>«IF targets('3.0')»{% trans %}Categories{% endtrans %}«ELSE»{{ __('Categories') }}«ENDIF»</h3>
        {% else %}
            <fieldset class="categories">
        {% endif %}
            <legend>«IF targets('3.0')»{% trans %}Categories{% endtrans %}«ELSE»{{ __('Categories') }}«ENDIF»</legend>
            {{ form_row(form.categories) }}
        {% if tabs|default(false) == true %}
            </div>
        {% else %}
            </fieldset>
        {% endif %}
    '''
}
