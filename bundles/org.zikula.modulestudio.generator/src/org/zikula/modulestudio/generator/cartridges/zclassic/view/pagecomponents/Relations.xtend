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
        «IF !app.isSystemModule && app.targets('3.0')»
            {% trans_default_domain '«app.appName.formatForDB»' %}
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
        {% set hasAdminPermission = permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»')) %}
        «IF ownerPermission || uiHooksProvider != HookProviderMode.DISABLED»
            {% set hasEditPermission = permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»')) %}
        «ENDIF»
        «IF many && uiHooksProvider != HookProviderMode.DISABLED»
            {% if context != 'display' %}
                <h3>«IF app.targets('3.0')»{% trans %}Assigned «nameMultiple.formatForDisplay»{% endtrans %}«ELSE»{{ __('Assigned «nameMultiple.formatForDisplay»', '«app.appName.toLowerCase»') }}«ENDIF»</h3>
                {{ pageAddAsset('stylesheet', zasset('@«app.appName»:css/style.css')) }}
                {{ pageAddAsset('stylesheet', zasset('@«app.appName»:css/custom.css'), 120) }}
                {{ pageAddAsset('stylesheet', asset('jquery-ui/themes/base/jquery-ui.min.css')) }}
                {{ pageAddAsset('javascript', asset('jquery-ui/jquery-ui.min.js')) }}
                {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».js'), 99) }}
                {% if context == 'hookDisplayView' and hasEditPermission %}
                    {% set entityNameTranslated = «IF app.targets('3.0')»'«name.formatForDisplay»'|trans«ELSE»__('«name.formatForDisplay»', '«app.appName.toLowerCase»')«ENDIF» %}
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
        «IF app.targets('3.0')»<h5>«ELSE»<h4«IF many» class="list-group-item-heading"«ENDIF»>«ENDIF»
        «IF hasDisplayAction»
            {% «IF app.targets('3.0')»apply spaceless«ELSE»spaceless«ENDIF» %}
            {% if not noLink %}
                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams('item', true)») }}" title="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}">
            {% endif %}
        «ENDIF»
            {{ item|«app.appName.formatForDB»_formattedTitle }}
        «IF hasDisplayAction»
            {% if not noLink %}
                </a>
                <a id="«name.formatForCode»Item{{ item.getKey() }}Display" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display', {«IF !hasSluggableFields || !slugUnique»«routePkParams('item', true)»«ENDIF»«appendSlug('item', true)», raw: 1}) }}" title="«IF app.targets('3.0')»{% trans %}Open quick view window{% endtrans %}«ELSE»{{ __('Open quick view window', '«app.appName.toLowerCase»') }}«ENDIF»" class="«app.vendorAndName.toLowerCase»-inline-window «IF app.targets('3.0')»d-none«ELSE»hidden«ENDIF»" data-modal-title="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fa fa-id-card«IF !app.targets('3.0')»-o«ENDIF»"></i></a>
            {% endif %}
            {% «IF app.targets('3.0')»endapply«ELSE»endspaceless«ENDIF» %}
        «ENDIF»
        «IF app.targets('3.0')»</h5>«ELSE»</h4>«ENDIF»
        «IF hasImageFieldsEntity»
            «val imageFieldName = getImageFieldsEntity.head.name.formatForCode»
            {% if item.«imageFieldName» is not empty and item.«imageFieldName»Meta.isImage %}
                <p«IF many» class="list-group-item-text"«ENDIF»>
                    <img src="{{ item.«imageFieldName».getPathname()|imagine_filter('zkroot', relationThumbRuntimeOptions) }}" alt="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ relationThumbRuntimeOptions.thumbnail.size[0] }}" height="{{ relationThumbRuntimeOptions.thumbnail.size[1] }}" class="img-rounded" />
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
                    <p«IF !app.targets('3.0')» class="list-group-item-text"«ENDIF»>
                        {% set removeLinkText = «IF application.targets('3.0')»'Detach %name%'|trans({'%name%': entityNameTranslated})«ELSE»__f('Detach %name%', {'%name%': entityNameTranslated}, '«app.appName.toLowerCase»')«ENDIF» %}
                        <a href="javascript:void(0);" title="{{ removeLinkText|e('html_attr') }}" class="detach-«app.appName.formatForDB»-object «IF app.targets('3.0')»d-none«ELSE»hidden«ENDIF»" data-assignment-id="{{ assignmentId|e('html_attr') }}"><i class="fa fa-«IF app.targets('3.0')»unlink«ELSE»chain-broken«ENDIF»"></i> {{ removeLinkText }}</a>
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
                    {% set addLinkText = «IF app.targets('3.0')»'Attach %name%'|trans({'%name%': entityNameTranslated})«ELSE»__f('Attach %name%', {'%name%': entityNameTranslated}, '«app.appName.toLowerCase»')«ENDIF» %}
                    {% set findLinkText = «IF app.targets('3.0')»'Find %name%'|trans({'%name%': entityNameTranslated})«ELSE»__f('Find %name%', {'%name%': entityNameTranslated}, '«app.appName.toLowerCase»')«ENDIF» %}
                    {% set searchLinkText = «IF app.targets('3.0')»'Search %name%'|trans({'%name%': entityNameTranslated})«ELSE»__f('Search %name%', {'%name%': entityNameTranslated}, '«app.appName.toLowerCase»')«ENDIF» %}
                    «IF hasEditAction»
                        {% set createNewLinkText = «IF app.targets('3.0')»'Create new %name%'|trans({'%name%': entityNameTranslated})«ELSE»__f('Create new %name%', {'%name%': entityNameTranslated}, '«app.appName.toLowerCase»')«ENDIF» %}
                    «ENDIF»
                    <div id="{{ idPrefix }}LiveSearch" class="«app.appName.toLowerCase»-add-hook-assignment">
                        <a id="{{ idPrefix }}AddLink" href="javascript:void(0);" title="{{ addLinkText|e('html_attr') }}" class="attach-«app.appName.formatForDB»-object «IF app.targets('3.0')»d-none«ELSE»hidden«ENDIF»" data-owner="{{ subscriberOwner|e('html_attr') }}" data-area-id="{{ subscriberAreaId|e('html_attr') }}" data-object-id="{{ subscriberObjectId|e('html_attr') }}" data-url="{{ subscriberUrl|e('html_attr') }}" data-assigned-entity="«name.formatForCode»"><i class="fa fa-link"></i> {{ addLinkText }}</a>
                        <div id="{{ idPrefix }}AddFields" class="«app.appName.toLowerCase»-autocomplete«IF hasImageFieldsEntity»-with-image«ENDIF»">
                            <label for="{{ idPrefix }}Selector">{{ findLinkText }}</label>
                            <br />
                            <i class="fa fa-search" title="{{ searchLinkText|e('html_attr') }}"></i>
                            <input type="hidden" name="{{ idPrefix }}" id="{{ idPrefix }}" value="{% for assignment in assignments %}{% if not loop.first %},{% endif %}{{ assignment.getAssignedId() }}{% endfor %}" />
                            <input type="hidden" name="{{ idPrefix }}Multiple" id="{{ idPrefix }}Multiple" value="0" />
                            <input type="text" id="{{ idPrefix }}Selector" name="{{ idPrefix }}Selector" autocomplete="off" />
                            <input type="button" id="{{ idPrefix }}SelectorDoCancel" name="{{ idPrefix }}SelectorDoCancel" value="«IF app.targets('3.0')»{% trans %}Cancel{% endtrans %}«ELSE»{{ __('Cancel', '«app.appName.toLowerCase»') }}«ENDIF»" class="btn btn-default «app.appName.toLowerCase»-inline-button" />
                            «IF hasEditAction»
                                <a id="{{ idPrefix }}SelectorDoNew" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'edit') }}" title="{{ createNewLinkText|e('html_attr') }}" class="btn btn-default «app.appName.toLowerCase»-inline-button"><i class="fa fa-plus"></i> «IF app.targets('3.0')»{% trans %}Create{% endtrans %}«ELSE»{{ __('Create', '«app.appName.toLowerCase»') }}«ENDIF»</a>
                            «ENDIF»
                            <noscript><p>«IF app.targets('3.0')»{% trans %}This function requires JavaScript activated!{% endtrans %}«ELSE»{{ __('This function requires JavaScript activated!') }}«ENDIF»</p></noscript>
                        </div>
                    </div>
                    {% set assignmentInitScript %}
                        <script>
                        /* <![CDATA[ */
                            var «app.vendorAndName»InlineEditHandlers = [];
                            var «app.vendorAndName»EditHandler = {
                                alias: '{{ idPrefix }}',
                                prefix: '{{ idPrefix }}SelectorDoNew',
                                moduleName: '«app.appName»',
                                objectType: '«name.formatForCode»',
                                inputType: 'autocomplete',
                                windowInstanceId: null
                            };
                            «app.vendorAndName»InlineEditHandlers.push(«app.vendorAndName»EditHandler);

                            «app.vendorAndName»InitRelationHandling('«name.formatForCode»', '{{ idPrefix }}', '{{ idPrefix }}SelectorDoNew', «hasEditAction.displayBool», 'autocomplete', '«IF hasEditAction»{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'edit') }}«ENDIF»');
                        /* ]]> */
                        </script>
                    {% endset %}
                    {{ pageAddAsset('footer', assignmentInitScript) }}
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def displayRelatedItems(JoinRelationship it, String appName, Entity relatedEntity, Boolean isAdmin) '''
        «val incoming = (if (target == relatedEntity && source != relatedEntity) true else false)»«/* use outgoing mode for self relations #547 */»
        «val useTarget = !incoming»
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode.toFirstLower»
        «val relationAliasNameParam = getRelationAliasName(!useTarget).formatForCode»
        «val otherEntity = (if (!useTarget) source else target) as Entity»
        «val many = isManySideDisplay(useTarget)»
        {% if routeArea == 'admin' %}
            <h4>«IF application.targets('3.0')»{% trans %}«getRelationAliasName(useTarget).formatForDisplayCapital»{% endtrans %}«ELSE»{{ __('«getRelationAliasName(useTarget).formatForDisplayCapital»') }}«ENDIF»</h4>
        {% else %}
            <h3>«IF application.targets('3.0')»{% trans %}«getRelationAliasName(useTarget).formatForDisplayCapital»{% endtrans %}«ELSE»{{ __('«getRelationAliasName(useTarget).formatForDisplayCapital»') }}«ENDIF»</h3>
        {% endif %}

        {% if «relatedEntity.name.formatForCode».«relationAliasName»|default %}
            {{ include(
                '@«application.appName»/«otherEntity.name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»includeDisplayItemList«getTargetMultiplicity(useTarget)».html.twig',
                {item«IF many»s«ENDIF»: «relatedEntity.name.formatForCode».«relationAliasName»«IF otherEntity.uiHooksProvider != HookProviderMode.DISABLED», context: 'display'«ENDIF»}
            ) }}
        {% endif %}
        «IF otherEntity.hasEditAction»
            {% if not isQuickView %}
                «IF !many»
                    {% if «relatedEntity.name.formatForCode».«relationAliasName» is not defined or «relatedEntity.name.formatForCode».«relationAliasName» is null %}
                «ENDIF»
                {% set mayManage = permissionHelper.hasComponentPermission('«otherEntity.name.formatForCode»', constant('ACCESS_«IF otherEntity.ownerPermission»ADD«ELSEIF otherEntity.workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»')) %}
                {% if mayManage«IF otherEntity.ownerPermission» or (currentUser|default and «relatedEntity.name.formatForCode».createdBy|default and «relatedEntity.name.formatForCode».createdBy.getUid() == currentUser.uid)«ENDIF» %}
                    <p class="managelink">
                        {% set createTitle = «IF application.targets('3.0')»'Create «otherEntity.name.formatForDisplay»'|trans«ELSE»__('Create «otherEntity.name.formatForDisplay»')«ENDIF» %}
                        <a href="{{ path('«appName.formatForDB»_«otherEntity.name.formatForDB»_' ~ routeArea ~ 'edit', {«relationAliasNameParam»: «relatedEntity.name.formatForCode».get«IF relatedEntity.hasSluggableFields && relatedEntity.slugUnique»Slug«ELSE»Key«ENDIF»()}) }}" title="{{ createTitle|e('html_attr') }}"><i class="fa fa-plus"></i> {{ createTitle }}</a>
                    </p>
                {% endif %}
                «IF !many»
                    {% endif %}
                «ENDIF»
            {% endif %}
        «ENDIF»
    '''
}
