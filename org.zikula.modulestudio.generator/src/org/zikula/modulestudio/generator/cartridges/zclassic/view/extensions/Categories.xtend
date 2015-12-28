package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Categories {
    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate (Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.x')) 'helper' else 'Helper') + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeCategoriesDisplay' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeCategoriesDisplay.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) categoriesViewImplLegacy else categoriesViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'includeCategoriesEdit' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeCategoriesEdit.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) categoriesEditImplLegacy else categoriesEditImpl)
            }
        }
    }

    def private categoriesViewImplLegacy(Application it) '''
        {* purpose of this template: reusable display of entity categories *}
        {if isset($obj.categories)}
            {if isset($panel) && $panel eq true}
                <h3 class="categories z-panel-header z-panel-indicator z-pointer">{gt text='Categories'}</h3>
                <div class="categories z-panel-content" style="display: none">
            {else}
                <h3 class="categories">{gt text='Categories'}</h3>
            {/if}
            «viewBodyLegacy»
            {if isset($panel) && $panel eq true}
                </div>
            {/if}
        {/if}
    '''

    def private categoriesViewImpl(Application it) '''
        {# purpose of this template: reusable display of entity categories #}
        {% if obj.categories is defined %}
            {% if panel|default(false) == true %}
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseCategories">{{ __('Categories') }}</a></h3>
                    </div>
                    <div id="collapseCategories" class="panel-collapse collapse in">
                        <div class="panel-body">
            {% else %}
                <h3 class="categories">{{ __('Categories') }}</h3>
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
        {*
        <dl class="category-list">
        {foreach key='propName' item='catMapping' from=$obj.categories}
            <dt>{$propName}</dt>
            <dd>{$catMapping.category.name|safetext}</dd>
        {/foreach}
        </dl>
        *}
        {assignedcategorieslist categories=$obj.categories doctrine2=true}
    '''

    def private viewBody(Application it) '''
        <dl class="category-list">
        {% for propName, catMapping in obj.categories %}
            <dt>{{ propName }}</dt>
            <dd>{{ catMapping.category.display_name[lang] }}</dd>
        {% endfor %}
        </dl>
    '''

    def private categoriesEditImplLegacy(Application it) '''
        {* purpose of this template: reusable editing of entity categories *}
        {if isset($panel) && $panel eq true}
            <h3 class="categories z-panel-header z-panel-indicator z-pointer">{gt text='Categories'}</h3>
            <fieldset class="categories z-panel-content" style="display: none">
        {else}
            <fieldset class="categories">
        {/if}
            <legend>{gt text='Categories'}</legend>
            «editBodyLegacy»
        {if isset($panel) && $panel eq true}
            </fieldset>
        {else}
            </fieldset>
        {/if}
    '''

    def private categoriesEditImpl(Application it) '''
        {# purpose of this template: reusable editing of entity categories #}
        {% if panel|default(false) == true %}
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseCategories">{{ __('Categories') }}</a></h3>
                </div>
                <div id="collapseCategories" class="panel-collapse collapse in">
                    <div class="panel-body">
        {% else %}
            <fieldset class="categories">
        {% endif %}
            <legend>{{ __('Categories') }}</legend>
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
        {foreach key='registryId' item='registryCid' from=$registries}
            {gt text='Category' assign='categorySelectorLabel'}
            {assign var='selectionMode' value='single'}
            {if $multiSelectionPerRegistry.$registryId eq true}
                {gt text='Categories' assign='categorySelectorLabel'}
                {assign var='selectionMode' value='multiple'}
            {/if}
            <div class="z-formrow">
                {formlabel for="category_`$registryId`" text=$categorySelectorLabel}
                {formcategoryselector id="category_`$registryId`" category=$registryCid
                                      dataField='categories' group=$groupName registryId=$registryId doctrine2=true
                                      selectionMode=$selectionMode}
            </div>
        {/foreach}
        {/formvolatile}
    '''

    def private editBody(Application it) '''
        «/* TODO migrate to Symfony forms #416 */»
        {% for registryId, registryCid in registries %}
            {% set categorySelectorLabel = __('Category') %}
            {% set selectionMode = 'single' %}
            {% if attribute(multiSelectionPerRegistry, registryId) == true %}
                {% set categorySelectorLabel = __('Categories') %}
                {% set selectionMode = 'multiple' %}
            {% endif %}
            <div class="form-group">
                {formlabel for="category_`$registryId`" text=$categorySelectorLabel cssClass='col-sm-3 control-label'}
                <div class="col-sm-9">
                    {formcategoryselector id="category_`$registryId`" category=$registryCid
                                          dataField='categories' group=$groupName registryId=$registryId doctrine2=true
                                          selectionMode=$selectionMode}
                </div>
            </div>
        {% endfor %}
    '''
}
