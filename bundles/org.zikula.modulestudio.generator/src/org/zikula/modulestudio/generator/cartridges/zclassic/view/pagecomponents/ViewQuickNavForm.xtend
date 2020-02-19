package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewQuickNavForm {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating view filter form templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templatePath = templateFile('viewQuickNav')
        fsa.generateFile(templatePath, quickNavForm)

        if (application.separateAdminTemplates) {
            templatePath = templateFile('Admin/viewQuickNav')
            fsa.generateFile(templatePath, quickNavForm)
        }
    }

    def private quickNavForm(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» view filter form #}
        «IF application.targets('3.0') && !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        «IF !application.targets('3.0')»
            {% import _self as helper %}
        «ENDIF»
        {% macro renderQuickNavEntry(quickNavForm, fieldName, isVisible) %}
            {% if attribute(quickNavForm, fieldName) is defined and attribute(quickNavForm, fieldName) is not null %}
                {% if not isVisible %}
                    <div class="«IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»">
                {% endif %}
                    {{ form_row(attribute(quickNavForm, fieldName)) }}
                {% if not isVisible %}
                    </div>
                {% endif %}
            {% endif %}
        {% endmacro %}
        {% if permissionHelper.mayUseQuickNav('«name.formatForCode»') %}
            {% form_theme quickNavForm with [
                'bootstrap_«IF application.targets('3.0')»4«ELSE»3«ENDIF»_layout.html.twig'
            ] %}
            {{ form_start(quickNavForm, {attr: {id: '«application.appName.toFirstLower»«name.formatForCodeCapital»QuickNavForm', class: '«application.appName.toLowerCase»-quicknav «IF application.targets('3.0')»form-inline«ELSE»navbar-form«ENDIF»', role: 'navigation'}}) }}
            {{ form_errors(quickNavForm) }}
            <a href="#collapse«name.formatForCodeCapital»QuickNav" role="button" data-toggle="collapse" class="btn btn-«IF application.targets('3.0')»secondary«ELSE»default«ENDIF»" aria-expanded="false" aria-controls="collapse«name.formatForCodeCapital»QuickNav">
                <i class="fa«IF application.targets('3.0')»s«ENDIF» fa-filter" aria-hidden="true"></i> «IF application.targets('3.0')»{% trans %}Filter{% endtrans %}«ELSE»{{ __('Filter') }}«ENDIF»
            </a>
            <div id="collapse«name.formatForCodeCapital»QuickNav" class="collapse">
                «IF application.targets('3.0')»
                    «formContent»
                «ELSE»
                    <fieldset>
                        «formContent»
                    </fieldset>
                «ENDIF»
            </div>
            {{ form_end(quickNavForm) }}
        {% endif %}
    '''

    def private formContent(Entity it) '''
        <h3>«IF application.targets('3.0')»{% trans %}Quick navigation{% endtrans %}«ELSE»{{ __('Quick navigation') }}«ENDIF»</h3>
        «IF categorisable»
            {% set categoriesEnabled = featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
        «ENDIF»
        «formFields»
        {{ form_widget(quickNavForm.updateview) }}
        <a href="{{ path('«application.appName.formatForDB»_«name.formatForCode.toLowerCase»_' ~ routeArea|default ~ 'view', {tpl: app.request.query.get('tpl', ''), all: app.request.query.get('all', '')}) }}" title="«IF application.targets('3.0')»{% trans %}Back to default view{% endtrans %}«ELSE»{{ __('Back to default view') }}«ENDIF»" class="btn btn-«IF application.targets('3.0')»secondary«ELSE»default«ENDIF» btn-sm">«IF application.targets('3.0')»{% trans %}Reset{% endtrans %}«ELSE»{{ __('Reset') }}«ENDIF»</a>
        «IF categorisable»
            {% if categoriesEnabled and quickNavForm.categories is defined and quickNavForm.categories is not null %}
                {% if categoryFilter is defined and categoryFilter != true %}
                {% else %}
                        </div>
                    </div>
                {% endif %}
            {% endif %}
        «ENDIF»
    '''

    def private formFields(Entity it) '''
        «IF categorisable»
            «categoriesFields»
        «ENDIF»
        «val incomingRelations = getBidirectionalIncomingJoinRelations.filter[source instanceof Entity]»
        «IF !incomingRelations.empty»
            «FOR relation : incomingRelations»
                «relation.formField(false)»
            «ENDFOR»
        «ENDIF»
        «val outgoingRelations = getOutgoingJoinRelations.filter[source instanceof Entity]»
        «IF !outgoingRelations.empty»
            «FOR relation : outgoingRelations»
                «relation.formField(true)»
            «ENDFOR»
        «ENDIF»
        «IF hasListFieldsEntity»
            «FOR field : getListFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasUserFieldsEntity»
            «FOR field : getUserFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasCountryFieldsEntity»
            «FOR field : getCountryFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasLanguageFieldsEntity»
            «FOR field : getLanguageFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasLocaleFieldsEntity»
            «FOR field : getLocaleFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasCurrencyFieldsEntity»
            «FOR field : getCurrencyFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasTimezoneFieldsEntity»
            «FOR field : getTimezoneFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasAbstractStringFieldsEntity»
            {{ «IF application.targets('3.0')»_self«ELSE»helper«ENDIF».renderQuickNavEntry(quickNavForm, 'q', searchFilter is not defined or searchFilter == true) }}
        «ENDIF»
        «sortingAndPageSize»
        «IF hasBooleanFieldsEntity»
            «FOR field : getBooleanFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
    '''

    def private categoriesFields(Entity it) '''
        {% if categoriesEnabled and quickNavForm.categories is defined and quickNavForm.categories is not null %}
            {% if categoryFilter is defined and categoryFilter != true %}
                <div class="«IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»">
            {% else %}
                <div class="row">
                    <div class="col-«IF application.targets('3.0')»md«ELSE»sm«ENDIF»-3">
            {% endif %}
                {{ form_row(quickNavForm.categories) }}
            {% if categoryFilter is defined and categoryFilter != true %}
                </div>
            {% else %}
                    </div>
                    <div class="col-«IF application.targets('3.0')»md«ELSE»sm«ENDIF»-9">
            {% endif %}
        {% endif %}
    '''

    def private formField(DerivedField it) '''
        «val fieldName = name.formatForCode»
        {{ «IF application.targets('3.0')»_self«ELSE»helper«ENDIF».renderQuickNavEntry(quickNavForm, '«fieldName»', «fieldName»Filter is not defined or «fieldName»Filter == true) }}
    '''

    def private formField(JoinRelationship it, Boolean useTarget) '''
        «val aliasName = getRelationAliasName(useTarget)»
        {{ «IF application.targets('3.0')»_self«ELSE»helper«ENDIF».renderQuickNavEntry(quickNavForm, '«aliasName»', «aliasName»Filter is not defined or «aliasName»Filter == true) }}
    '''

    def private sortingAndPageSize(Entity it) '''
        {% if quickNavForm.sort is defined and quickNavForm.sort is not null %}
            {% if sorting is defined and sorting != true %}
                <div class="«IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»">
            {% endif %}
                {{ form_row(quickNavForm.sort) }}
                {% if quickNavForm.sortdir is defined and quickNavForm.sortdir is not null %}
                    {{ form_row(quickNavForm.sortdir) }}
                {% endif %}
            {% if sorting is defined and sorting != true %}
                </div>
            {% endif %}
        {% endif %}
        {{ «IF application.targets('3.0')»_self«ELSE»helper«ENDIF».renderQuickNavEntry(quickNavForm, 'num', pageSizeSelector is not defined or pageSizeSelector == true) }}
    '''
}
