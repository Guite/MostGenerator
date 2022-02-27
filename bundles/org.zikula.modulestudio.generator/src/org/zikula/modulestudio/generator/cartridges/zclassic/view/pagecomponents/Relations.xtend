package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.HookProviderMode
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

        if (application.separateAdminTemplates) {
            templatePath = templateFile('Admin/includeDisplayItemList' + (if (many) 'Many' else 'One'))
            fsa.generateFile(templatePath, inclusionTemplate(app, many))
        }
    }

    def private inclusionTemplate(Entity it, Application app, Boolean many) '''
        {# purpose of this template: inclusion template for display of related «nameMultiple.formatForDisplay»«IF uiHooksProvider != HookProviderMode.DISABLED» or hook assignments«ENDIF» #}
        «IF !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        «IF many && uiHooksProvider != HookProviderMode.DISABLED»
            {#
                You can use the context variable to check for the context of this list:
                    - 'display': list of related «nameMultiple.formatForDisplay» included in a display template
                    - 'hookDisplayView': list of «nameMultiple.formatForDisplay» assigned using an UI hook (display/view template)
                    - 'hookDisplayEdit': list of «nameMultiple.formatForDisplay» assigned using an UI hook (edit template)
                    - 'hookDisplayDelete': list of «nameMultiple.formatForDisplay» assigned using an UI hook (delete template)
            #}
        «ENDIF»
        {% set hasAdminPermission = permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_ADD')) %}
        «IF ownerPermission || uiHooksProvider != HookProviderMode.DISABLED»
            {% set hasEditPermission = permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»')) %}
        «ENDIF»
        «IF many && uiHooksProvider != HookProviderMode.DISABLED»
            {% if context != 'display' %}
                <h3>{% trans«IF !app.isSystemModule» from 'hooks'«ENDIF» %}Assigned «nameMultiple.formatForDisplay»{% endtrans %}</h3>
                {{ pageAddAsset('stylesheet', zasset('@«app.appName»:css/style.css')) }}
                {{ pageAddAsset('stylesheet', zasset('@«app.appName»:css/custom.css'), 120) }}
                {{ pageAddAsset('stylesheet', asset('jquery-ui/themes/base/jquery-ui.min.css')) }}
                {{ pageAddAsset('javascript', asset('jquery-ui/jquery-ui.min.js'), constant('Zikula\\ThemeModule\\Engine\\AssetBag::WEIGHT_JQUERY_UI')) }}
                {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».js'), 99) }}
                {% if context == 'hookDisplayView' and hasEditPermission %}
                    {% set entityNameTranslated = '«name.formatForDisplay»'|trans %}
                    {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».HookAssignment.js'), 99) }}
                    {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».EditFunctions.js'), 99) }}
                    {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».InlineEditing.js'), 99) }}
                    {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».AutoCompletion.js'), 99) }}
                {% endif %}
            {% endif %}
        «ENDIF»
        «IF hasDisplayAction»
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
        «IF hasDisplayAction»
            {% apply spaceless %}
            {% if not noLink %}
                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams('item', true)») }}" title="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}">
            {% endif %}
        «ENDIF»
            {{ item|«app.appName.formatForDB»_formattedTitle }}
        «IF hasDisplayAction»
            {% if not noLink %}
                </a>
                <a id="«name.formatForCode»Item{{ item.getKey() }}Display" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display', {«IF !hasSluggableFields || !slugUnique»«routePkParams('item', true)»«ENDIF»«appendSlug('item', true)», raw: 1}) }}" title="{% trans %}Open quick view window{% endtrans %}" class="«app.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fas fa-id-card"></i></a>
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
            «IF uiHooksProvider != HookProviderMode.DISABLED»
                {% if context == 'hookDisplayView' and hasEditPermission %}
                    {% set assignmentId = '' %}
                    {% for assignment in assignments if assignment.getAssignedId() == item.getKey() %}
                        {% set assignmentId = assignment.getId() %}
                    {% endfor %}
                    <p>
                        {% set removeLinkText = 'Detach %name%'|trans({'%name%': entityNameTranslated}) %}
                        <a href="javascript:void(0);" title="{{ removeLinkText|e('html_attr') }}" class="detach-«app.appName.formatForDB»-object d-none" data-assignment-id="{{ assignmentId|e('html_attr') }}"><i class="fas fa-unlink"></i> {{ removeLinkText }}</a>
                    </p>
                {% endif %}
            «ENDIF»
                </li>
                {% endif %}
            {% endfor %}
            </ul>
            {% endif %}
            «IF uiHooksProvider != HookProviderMode.DISABLED»
                {% if context == 'hookDisplayView' and hasEditPermission %}
                    {% set idPrefix = 'hookAssignment«name.formatForCodeCapital»' %}
                    {% set addLinkText = 'Attach %name%'|trans({'%name%': entityNameTranslated}) %}
                    {% set findLinkText = 'Find %name%'|trans({'%name%': entityNameTranslated}) %}
                    {% set searchLinkText = 'Search %name%'|trans({'%name%': entityNameTranslated}) %}
                    «IF hasEditAction»
                        {% set createNewLinkText = 'Create new %name%'|trans({'%name%': entityNameTranslated}) %}
                    «ENDIF»
                    <div id="{{ idPrefix }}LiveSearch" class="«app.appName.toLowerCase»-add-hook-assignment">
                        <a id="{{ idPrefix }}AddLink" href="javascript:void(0);" title="{{ addLinkText|e('html_attr') }}" class="attach-«app.appName.formatForDB»-object d-none" data-owner="{{ subscriberOwner|e('html_attr') }}" data-area-id="{{ subscriberAreaId|e('html_attr') }}" data-object-id="{{ subscriberObjectId|e('html_attr') }}" data-url="{{ subscriberUrl|e('html_attr') }}" data-assigned-entity="«name.formatForCode»"><i class="fas fa-link"></i> {{ addLinkText }}</a>
                        <div id="{{ idPrefix }}AddFields" class="«app.appName.toLowerCase»-autocomplete«IF hasImageFieldsEntity»-with-image«ENDIF»">
                            <label for="{{ idPrefix }}Selector">{{ findLinkText }}</label>
                            <br />
                            <i class="fas fa-search" title="{{ searchLinkText|e('html_attr') }}"></i>
                            <input type="hidden" name="{{ idPrefix }}" id="{{ idPrefix }}" value="{% for assignment in assignments %}{% if not loop.first %},{% endif %}{{ assignment.getAssignedId() }}{% endfor %}" />
                            <input type="hidden" name="{{ idPrefix }}Multiple" id="{{ idPrefix }}Multiple" value="0" />
                            <input type="text" id="{{ idPrefix }}Selector" name="{{ idPrefix }}Selector" autocomplete="off" />
                            <input type="button" id="{{ idPrefix }}SelectorDoCancel" name="{{ idPrefix }}SelectorDoCancel" value="{% trans %}Cancel{% endtrans %}" class="btn btn-secondary «app.appName.toLowerCase»-inline-button" />
                            «IF hasEditAction»
                                <a id="{{ idPrefix }}SelectorDoNew" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'edit') }}" title="{{ createNewLinkText|e('html_attr') }}" class="btn btn-secondary «app.appName.toLowerCase»-inline-button"><i class="fas fa-plus"></i> {% trans %}Create{% endtrans %}</a>
                            «ENDIF»
                            <noscript><p>{% trans %}This function requires JavaScript activated!{% endtrans %}</p></noscript>
                        </div>
                    </div>
                    <div class="relation-editing-definition" data-object-type="«name.formatForCode»" data-alias="{{ idPrefix|e('html_attr') }}" data-prefix="{{ idPrefix|e('html_attr') }}SelectorDoNew" data-inline-prefix="{{ idPrefix|e('html_attr') }}SelectorDoNew" data-module-name="«app.appName»" data-include-editing="«IF hasEditAction»1«ELSE»0«ENDIF»" data-input-type="autocomplete" data-create-url="«IF hasEditAction»{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'edit')|e('html_attr') }}«ENDIF»"></div>
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def displayRelatedItems(JoinRelationship it, String appName, Entity relatedEntity, Boolean isAdmin, Boolean useTarget) '''
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
                    {% set createLink = path('«appName.formatForDB»_«otherEntity.name.formatForDB»_' ~ routeArea ~ 'edit', {«relationAliasNameParam»: «relatedEntity.name.formatForCode».get«IF relatedEntity.hasSluggableFields && relatedEntity.slugUnique»Slug«ELSE»Key«ENDIF»()}) %}
                    {% set createTitle = 'Create «otherEntity.name.formatForDisplay»'|trans«IF !application.isSystemModule»({}, '«otherEntity.name.formatForCode»')«ENDIF» %}
                {% endif %}
            {% endif %}
        «ENDIF»
        {% set sectionTitle %}
            {% trans«IF !application.isSystemModule» from '«otherEntity.name.formatForCode»'«ENDIF» %}«getRelationAliasName(useTarget).formatForDisplayCapital»{% endtrans %}
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
                '@«application.appName»/«otherEntity.name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»includeDisplayItemList«getTargetMultiplicity(useTarget)».html.twig',
                {item«IF many»s«ENDIF»: «relatedEntity.name.formatForCode».«relationAliasName»«IF otherEntity.uiHooksProvider != HookProviderMode.DISABLED», context: 'display'«ENDIF»}
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
