package org.zikula.modulestudio.generator.cartridges.symfony.view.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Categories {

    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions

    def generate (Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Helper/'
        val templateExtension = '.html.twig'

        var fileName = ''
        if (hasIndexActions || hasDetailActions) {
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
        {% if obj.categories is defined %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabCategories" aria-labelledby="categoriesTab">
                    <h3>{% trans %}Categories{% endtrans %}</h3>
            {% else %}
                <h3 class="categories">{% trans %}Categories{% endtrans %}</h3>
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
            <li>{% if catMapping.category.icon %}<i class="fa-fw {{ catMapping.category.icon|e('html_attr') }}"></i> {% endif %}{{ catMapping.category.displayName[app.request.locale]|default(catMapping.category.name) }}</li>
        {% endfor %}
        </ul>
    '''

    def private categoriesEditImpl(Application it) '''
        {# purpose of this template: reusable editing of entity categories #}
        {% if tabs|default(false) == true %}
            <div role="tabpanel" class="tab-pane fade" id="tabCategories" aria-labelledby="categoriesTab">
                <h3>{% trans %}Categories{% endtrans %}</h3>
        {% else %}
            <fieldset class="categories">
        {% endif %}
            <legend>{% trans %}Categories{% endtrans %}</legend>
            {{ form_row(form.categories) }}
        {% if tabs|default(false) == true %}
            </div>
        {% else %}
            </fieldset>
        {% endif %}
    '''
}
