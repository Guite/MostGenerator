package org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Relations {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def displayItemList(Entity it, Application app, Boolean many, IMostFileSystemAccess fsa) {
        var templatePath = templateFile('includeDisplayItemList' + (if (many) 'Many' else 'One'))
        fsa.generateFile(templatePath, inclusionTemplate(app, many))
    }

    def private inclusionTemplate(Entity it, Application app, Boolean many) '''
        {# purpose of this template: inclusion template for display of related «nameMultiple.formatForDisplay» #}
        {% trans_default_domain '«name.formatForCode»' %}
        {% set hasAdminPermission = permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_ADD')) %}
        «IF ownerPermission»
            {% set hasEditPermission = permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»')) %}
        «ENDIF»
        «IF hasDetailAction»
            {% if noLink is not defined %}
                {% set noLink = false %}
            {% endif %}
        «ENDIF»
        «IF many»
            {% if items|default and items|length > 0 %}
            <ul class="list-group «app.appName.toLowerCase»-related-item-list «name.formatForDB»">
            {% for item in items %}
                {% if hasAdminPermission or (item.workflowState == 'approved' and permissionHelper.mayRead(item))«IF ownerPermission» or (item.workflowState in ['defered', 'trashed'] and hasEditPermission and currentUser|default and item.createdBy.getUid() == currentUser.uid)«ENDIF» %}
                <li class="list-group-item">
        «ENDIF»
        <h5>
        «IF hasDetailAction»
            {% apply spaceless %}
            {% if not noLink %}
                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_detail'«routeParams('item', true)») }}" title="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}">
            {% endif %}
        «ENDIF»
            {{ item|«app.appName.formatForDB»_formattedTitle }}
        «IF hasDetailAction»
            {% if not noLink %}
                </a>
                <a id="«name.formatForCode»Item{{ item.getKey() }}Display" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_detail', {«IF !hasSluggableFields || !slugUnique»«routePkParams('item', true)»«ENDIF»«appendSlug('item', true)», raw: 1}) }}" title="{% trans %}Open quick view window{% endtrans %}" class="«app.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fas fa-id-card"></i></a>
            {% endif %}
            {% endapply %}
        «ENDIF»
        </h5>
        «IF hasImageFieldsEntity»
            «val imageFieldName = getImageFieldsEntity.head.name.formatForCode»
            {% if item.«imageFieldName» is not empty and item.«imageFieldName»Meta.isImage %}
                <p«IF many» class="list-group-item-text"«ENDIF»>
                    <img src="{{ item.«imageFieldName».getPathname()|«app.appName.formatForDB»_relativePath|imagine_filter('zkroot', relationThumbRuntimeOptions) }}" alt="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ relationThumbRuntimeOptions.thumbnail.size[0] }}" height="{{ relationThumbRuntimeOptions.thumbnail.size[1] }}" class="rounded" />
                </p>
            {% endif %}
        «ENDIF»
        «IF many»
                </li>
                {% endif %}
            {% endfor %}
            </ul>
            {% endif %}
        «ENDIF»
    '''

    def displayRelatedItems(JoinRelationship it, String appName, Entity relatedEntity, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode.toFirstLower»
        «val relationAliasNameParam = getRelationAliasName(!useTarget).formatForCode»
        «val otherEntity = (if (!useTarget) source else target) as Entity»
        «val many = isManySideDisplay(useTarget)»
        «IF otherEntity.hasEditAction»
            {% set createLink = null %}
            {% set createTitle = null %}
            {% set creationPossible = not isQuickView«IF !many» and not «relatedEntity.name.formatForCode».«relationAliasName»|default«ENDIF» %}
            {% if creationPossible %}
                {% set mayManage = permissionHelper.hasComponentPermission('«otherEntity.name.formatForCode»', constant('ACCESS_«IF otherEntity.ownerPermission»ADD«ELSEIF otherEntity.workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»')) %}
                {% if mayManage«IF otherEntity.ownerPermission» or (currentUser|default and «relatedEntity.name.formatForCode».createdBy|default and «relatedEntity.name.formatForCode».createdBy.getUid() == currentUser.uid)«ENDIF» %}
                    {% set createLink = path('«appName.formatForDB»_«otherEntity.name.formatForDB»_edit', {«relationAliasNameParam»: «relatedEntity.name.formatForCode».get«IF relatedEntity.hasSluggableFields && relatedEntity.slugUnique»Slug«ELSE»Key«ENDIF»()}) %}
                    {% set createTitle = 'Create «otherEntity.name.formatForDisplay»'|trans({}, '«otherEntity.name.formatForCode»') %}
                {% endif %}
            {% endif %}
        «ENDIF»
        {% set sectionTitle %}
            {% trans from '«otherEntity.name.formatForCode»' %}«getRelationAliasName(useTarget).formatForDisplayCapital»{% endtrans %}
            «IF otherEntity.hasEditAction»
                {% if creationPossible and createLink|default %}
                    «createLink('')»
                {% endif %}
            «ENDIF»
        {% endset %}
        {% if routeArea == 'admin' %}
            <h4>{{ sectionTitle }}</h4>
        {% else %}
            <h3>{{ sectionTitle }}</h3>
        {% endif %}
        {% if «relatedEntity.name.formatForCode».«relationAliasName»|default %}
            {{ include(
                '@«application.vendorAndName»/«otherEntity.name.formatForCodeCapital»/includeDisplayItemList«getTargetMultiplicity(useTarget)».html.twig',
                {item«IF many»s«ENDIF»: «relatedEntity.name.formatForCode».«relationAliasName»}
            ) }}
        {% endif %}
        «IF otherEntity.hasEditAction»
            {% if creationPossible and createLink|default %}
                <p class="managelink">
                    «createLink(' {{ createTitle }}')»
                </p>
            {% endif %}
        «ENDIF»
    '''

    def private createLink(JoinRelationship it, String title) '''<a href="{{ createLink|e('html_attr') }}" title="{{ createTitle|e('html_attr') }}"><i class="fas fa-plus"></i>«title»</a>'''
}
