package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Categories {

    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions

    def generate (Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Helper/'
        val templateExtension = '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeCategoriesDisplay' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeCategoriesDisplay.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, categoriesViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'includeCategoriesEdit' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeCategoriesEdit.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, categoriesEditImpl)
            }
        }
    }

    def private categoriesViewImpl(Application it) '''
        {# purpose of this template: reusable display of entity categories #}
        {% if obj.categories is defined %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabCategories" aria-labelledby="categoriesTab">
                    <h3>{{ __('Categories') }}</h3>
            {% else %}
                <h3 class="categories">{{ __('Categories') }}</h3>
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
            <li>{{ catMapping.category.display_name[app.request.locale]|default(catMapping.category.name) }}</li>
        {% endfor %}
        </ul>
    '''

    def private categoriesEditImpl(Application it) '''
        {# purpose of this template: reusable editing of entity categories #}
        {% if tabs|default(false) == true %}
            <div role="tabpanel" class="tab-pane fade" id="tabCategories" aria-labelledby="categoriesTab">
                <h3>{{ __('Categories') }}</h3>
        {% else %}
            <fieldset class="categories">
        {% endif %}
            <legend>{{ __('Categories') }}</legend>
            {{ form_row(form.categories) }}
        {% if tabs|default(false) == true %}
            </div>
        {% else %}
            </fieldset>
        {% endif %}
    '''
}
