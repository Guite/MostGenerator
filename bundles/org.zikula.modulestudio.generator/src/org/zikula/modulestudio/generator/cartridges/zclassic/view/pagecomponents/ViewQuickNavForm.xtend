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
        {% if permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_EDIT')) %}
            {% form_theme quickNavForm with [
                'bootstrap_3_layout.html.twig'
            ] %}
            {{ form_start(quickNavForm, {attr: {id: '«application.appName.toFirstLower»«name.formatForCodeCapital»QuickNavForm', class: '«application.appName.toLowerCase»-quicknav navbar-form', role: 'navigation'}}) }}
            {{ form_errors(quickNavForm) }}
            <a href="#collapse«name.formatForCodeCapital»QuickNav" role="button" data-toggle="collapse" class="btn btn-default" aria-expanded="false" aria-controls="collapse«name.formatForCodeCapital»QuickNav">
                <i class="fa fa-filter" aria-hidden="true"></i> {{ __('Filter') }}
            </a>
            <div id="collapse«name.formatForCodeCapital»QuickNav" class="collapse">
                <fieldset>
                    <h3>{{ __('Quick navigation') }}</h3>
                    «formFields»
                    {{ form_widget(quickNavForm.updateview) }}
                    «IF categorisable»
                        {% if categoriesEnabled %}
                            {% if categoryFilter is defined and categoryFilter != true %}
                            {% else %}
                                    </div>
                                </div>
                            {% endif %}
                        {% endif %}
                    «ENDIF»
                </fieldset>
            </div>
            {{ form_end(quickNavForm) }}
        {% endif %}
    '''

    def private formFields(Entity it) '''
        «IF categorisable»
            «categoriesFields»
        «ENDIF»
        «val incomingRelations = getBidirectionalIncomingJoinRelationsWithOneSource.filter[source instanceof Entity]»
        «IF !incomingRelations.empty»
            «FOR relation : incomingRelations»
                «relation.formField»
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
        «IF hasAbstractStringFieldsEntity»
            {% if searchFilter is defined and searchFilter != true %}
                <div class="hidden">
            {% endif %}
                {{ form_row(quickNavForm.q) }}
            {% if searchFilter is defined and searchFilter != true %}
                </div>
            {% endif %}
        «ENDIF»
        «sortingAndPageSize»
        «IF hasBooleanFieldsEntity»
            «FOR field : getBooleanFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
    '''

    def private categoriesFields(Entity it) '''
        {% set categoriesEnabled = featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
        {% if categoriesEnabled %}
            {% if (categoryFilter is defined and categoryFilter != true) %}
                <div class="hidden">
            {% else %}
                <div class="row">
                    <div class="col-sm-3">
            {% endif %}
                {{ form_row(quickNavForm.categories) }}
            {% if (categoryFilter is defined and categoryFilter != true) %}
                </div>
            {% else %}
                    </div>
                    <div class="col-sm-9">
            {% endif %}
        {% endif %}
    '''

    def private dispatch formField(DerivedField it) '''
        «val fieldName = name.formatForCode»
        {% if «fieldName»Filter is defined and «fieldName»Filter != true %}
            <div class="hidden">
        {% endif %}
            {{ form_row(quickNavForm.«fieldName») }}
        {% if «fieldName»Filter is defined and «fieldName»Filter != true %}
            </div>
        {% endif %}
    '''

    def private dispatch formField(JoinRelationship it) '''
        «val sourceName = source.name.formatForCode»
        «val sourceAliasName = getRelationAliasName(false)»
        {% if «sourceName»Filter is defined and «sourceName»Filter != true %}
            <div class="hidden">
        {% endif %}
            {{ form_row(quickNavForm.«sourceAliasName») }}
        {% if «sourceName»Filter is defined and «sourceName»Filter != true %}
            </div>
        {% endif %}
    '''

    def private sortingAndPageSize(Entity it) '''
        {% if sorting is defined and sorting != true %}
            <div class="hidden">
        {% endif %}
            {{ form_row(quickNavForm.sort) }}
            {{ form_row(quickNavForm.sortdir) }}
        {% if sorting is defined and sorting != true %}
            </div>
        {% endif %}
        {% if pageSizeSelector is defined and pageSizeSelector != true %}
            <div class="hidden">
        {% endif %}
            {{ form_row(quickNavForm.num) }}
        {% if pageSizeSelector is defined and pageSizeSelector != true %}
            </div>
        {% endif %}
    '''
}
