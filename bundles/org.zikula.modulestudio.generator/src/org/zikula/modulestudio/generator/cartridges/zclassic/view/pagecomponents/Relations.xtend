package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.HookProviderMode
import de.guite.modulestudio.metamodel.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Relations {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def displayItemList(Entity it, Application app, Boolean many, IFileSystemAccess fsa) {
        var templatePath = templateFile('includeDisplayItemList' + (if (many) 'Many' else 'One'))
        if (!app.shouldBeSkipped(templatePath)) {
            fsa.generateFile(templatePath, inclusionTemplate(app, many))
        }
        if (application.generateSeparateAdminTemplates) {
            templatePath = templateFile('Admin/includeDisplayItemList' + (if (many) 'Many' else 'One'))
            if (!app.shouldBeSkipped(templatePath)) {
                fsa.generateFile(templatePath, inclusionTemplate(app, many))
            }
        }
    }

    def private inclusionTemplate(Entity it, Application app, Boolean many) '''
        {# purpose of this template: inclusion template for display of related «nameMultiple.formatForDisplay»«IF uiHooksProvider != HookProviderMode.DISABLED» or hook assignments«ENDIF» #}
        «IF many && uiHooksProvider != HookProviderMode.DISABLED»
            {#
                You can use the context variable to check for the context of this list:
                    - 'display': list of related «nameMultiple.formatForDisplay» included in a display template
                    - 'hookDisplayView': list of «nameMultiple.formatForDisplay» assigned using an UI hook (display/view template)
                    - 'hookDisplayEdit': list of «nameMultiple.formatForDisplay» assigned using an UI hook (edit template)
                    - 'hookDisplayDelete': list of «nameMultiple.formatForDisplay» assigned using an UI hook (delete template)
            #}
        «ENDIF»
        {% set hasAdminPermission = hasPermission('«app.appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
        «IF ownerPermission || uiHooksProvider != HookProviderMode.DISABLED»
            {% set hasEditPermission = hasPermission('«app.appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
        «ENDIF»
        «IF many && uiHooksProvider != HookProviderMode.DISABLED»
            {% if context != 'display' %}
                <h3>{{ __('Assigned «nameMultiple.formatForDisplay»') }}</h3>
                {% if context == 'hookDisplayView' and hasEditPermission %}
                    {% set entityNameTranslated = __('«name.formatForDisplay»') %}
                    {{ pageAddAsset('stylesheet', zasset('@«app.appName»:css/style.css')) }}
                    {{ pageAddAsset('stylesheet', asset('jquery-ui/themes/base/jquery-ui.min.css')) }}
                    {{ pageAddAsset('stylesheet', asset('bootstrap-jqueryui/bootstrap-jqueryui.min.css')) }}
                    {{ pageAddAsset('javascript', asset('jquery-ui/jquery-ui.min.js')) }}
                    {{ pageAddAsset('javascript', asset('bootstrap-jqueryui/bootstrap-jqueryui.min.js')) }}
                    {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».HookAssignment.js'), 99) }}
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
                {% if hasAdminPermission or item.workflowState == 'approved'«IF ownerPermission» or (item.workflowState == 'defered' and hasEditPermission and currentUser|default and item.createdBy.getUid() == currentUser.uid)«ENDIF» %}
                <li class="list-group-item">
        «ENDIF»
        <h4«IF many» class="list-group-item-heading"«ENDIF»>
        «IF hasDisplayAction»
            {% spaceless %}
            {% if not noLink %}
                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams('item', true)») }}" title="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}">
            {% endif %}
        «ENDIF»
            {{ item|«app.appName.formatForDB»_formattedTitle }}
        «IF hasDisplayAction»
            {% if not noLink %}
                </a>
                <a id="«name.formatForCode»Item{{ item.getKey() }}Display" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display', {«IF !hasSluggableFields || !slugUnique»«routePkParams('item', true)»«ENDIF»«appendSlug('item', true)», raw: 1}) }}" title="{{ __('Open quick view window') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}"><span class="fa fa-id-card-o"></span></a>
            {% endif %}
            {% endspaceless %}
        «ENDIF»
        </h4>
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
                    <p class="list-group-item-text">
                        <a href="javascript:void(0);" title="{{ __f('Detach this %name%', {'%name%': entityNameTranslated})|e('html_attr') }}" class="detach-«app.appName.formatForDB»-object hidden" data-assignment-id="{{ assignmentId|e('html_attr') }}"><i class="fa fa-chain-broken"></i> {{ __f('Detach %name%', {'%name%': entityNameTranslated}) }}</a>
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
                    {% set withImage = «hasImageFieldsEntity.displayBool» %}
                    {% set idPrefix = 'hookAssignment«name.formatForCodeCapital»' %}
                    {% set addLinkText = __f('Attach %name%', {'%name%': entityNameTranslated}) %}
                    <div id="{{ idPrefix }}LiveSearch" class="«app.appName.toLowerCase»-add-hook-assignment">
                        <a id="{{ idPrefix }}AddLink" href="javascript:void(0);" title="{{ addLinkText|e('html_attr') }}" class="attach-«app.appName.formatForDB»-object hidden" data-owner="{{ subscriberOwner|e('html_attr') }}" data-area-id="{{ subscriberAreaId|e('html_attr') }}" data-object-id="{{ subscriberObjectId|e('html_attr') }}" data-url="{{ subscriberUrl|e('html_attr') }}" data-assigned-entity="«name.formatForCode»"><i class="fa fa-link"></i> {{ addLinkText }}</a>
                        <div id="{{ idPrefix }}AddFields" class="«app.appName.toLowerCase»-autocomplete{{ withImage ? '-with-image' : '' }}">
                            <label for="{{ idPrefix }}Selector">{{ __f('Find %name%', {'%name%': entityNameTranslated}) }}</label>
                            <br />
                            <i class="fa fa-search" title="{{ __f('Search %name%', {'%name%': entityNameTranslated})|e('html_attr') }}"></i>
                            <input type="hidden" name="{{ idPrefix }}" id="{{ idPrefix }}" value="" />
                            <input type="hidden" name="{{ idPrefix }}Multiple" id="{{ idPrefix }}Multiple" value="0" />
                            <input type="hidden" name="{{ idPrefix }}Mode" id="{{ idPrefix }}Mode" value="0" />
                            <input type="hidden" name="{{ idPrefix }}ExcludedIds" id="{{ idPrefix }}ExcludedIds" value="{% for assignment in assignments %}{% if not loop.first %},{% endif %}{{ assignment.getAssignedId() }}{% endfor %}" />
                            <input type="text" id="{{ idPrefix }}Selector" name="{{ idPrefix }}Selector" autocomplete="off" />
                            <input type="button" id="{{ idPrefix }}SelectorDoCancel" name="{{ idPrefix }}SelectorDoCancel" value="{{ __('Cancel') }}" class="btn btn-default «app.appName.toLowerCase»-inline-button" />
                            «IF hasEditAction»
                                <a id="{{ idPrefix }}SelectorDoNew" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'edit') }}" title="{{ __f('Create new %name%', {'%name%': entityNameTranslated}) }}" class="btn btn-default «app.appName.toLowerCase»-inline-button">{{ __('Create') }}</a>
                            «ENDIF»
                            <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
                        </div>
                    </div>
                    {% set assignmentInitScript %}
                        <script type="text/javascript">
                        /* <![CDATA[ */
                            var relationHandler = new Array();
                            var newItem = {
                                ot: '«name.formatForCode»',
                                prefix: '{{ idPrefix }}SelectorDoNew',
                                moduleName: '«app.appName»',
                                acInstance: null,
                                windowInstanceId: null
                            };
                            relationHandler.push(newItem);

                            «app.vendorAndName»InitRelationItemsForm('«name.formatForCode»', '{{ idPrefix }}', true);
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
            <h4>{{ __('«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»') }}</h4>
        {% else %}
            <h3>{{ __('«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»') }}</h3>
        {% endif %}

        {% if «relatedEntity.name.formatForCode».«relationAliasName»|default %}
            {{ include(
                '@«application.appName»/«otherEntity.name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»includeDisplayItemList«getTargetMultiplicity(useTarget)».html.twig',
                {item«IF many»s«ENDIF»: «relatedEntity.name.formatForCode».«relationAliasName»«IF otherEntity.uiHooksProvider != HookProviderMode.DISABLED», context: 'display'«ENDIF»}
            ) }}
        {% endif %}
        «IF otherEntity.hasEditAction»

            «IF !many»
                {% if «relatedEntity.name.formatForCode».«relationAliasName» is not defined or «relatedEntity.name.formatForCode».«relationAliasName» is null %}
            «ENDIF»
            {% set mayManage = hasPermission('«appName»:«otherEntity.name.formatForCodeCapital»:', '::', 'ACCESS_«IF otherEntity.ownerPermission»ADD«ELSEIF otherEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
            {% if mayManage«IF otherEntity.ownerPermission» or (currentUser|default and «relatedEntity.name.formatForCode».createdBy|default and «relatedEntity.name.formatForCode».createdBy.getUid() == currentUser.uid)«ENDIF» %}
                <p class="managelink">
                    {% set createTitle = __('Create «otherEntity.name.formatForDisplay»') %}
                    <a href="{{ path('«appName.formatForDB»_«otherEntity.name.formatForDB»_' ~ routeArea ~ 'edit', {«relationAliasNameParam»: «relatedEntity.name.formatForCode».getKey()}) }}" title="{{ createTitle|e('html_attr') }}" class="fa fa-plus">{{ createTitle }}</a>
                </p>
            {% endif %}
            «IF !many»
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''
}
