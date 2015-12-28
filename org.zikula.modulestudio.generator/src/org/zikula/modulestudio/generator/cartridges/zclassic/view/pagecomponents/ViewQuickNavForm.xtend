package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
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

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        val templatePath = templateFile('viewQuickNav')
        if (!application.shouldBeSkipped(templatePath)) {
            println('Generating view filter form templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templatePath, if (application.targets('1.3.x')) quickNavFormLegacy else quickNavForm)
        }
    }

    def private quickNavFormLegacy(Entity it) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» view filter form *}
        {checkpermissionblock component='«application.appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_EDIT'}
        {assign var='objectType' value='«name.formatForCode»'}
        <form action="{$modvars.ZConfig.entrypoint|default:'index.php'}" method="get" id="«application.appName.toFirstLower»«name.formatForCodeCapital»QuickNavForm" class="«application.appName.toLowerCase»-quicknav">
            <fieldset>
                <h3>{gt text='Quick navigation'}</h3>
                <input type="hidden" name="module" value="{modgetinfo modname='«application.appName»' info='url'}" />
                <input type="hidden" name="type" value="{$lct}" />
                <input type="hidden" name="func" value="view" />
                <input type="hidden" name="ot" value="«objName»" />
                <input type="hidden" name="all" value="{$all|default:0}" />
                <input type="hidden" name="own" value="{$own|default:0}" />
                {gt text='All' assign='lblDefault'}
                «formFields»
                <input type="submit" name="updateview" id="quicknavSubmit" value="{gt text='OK'}" />
            </fieldset>
        </form>

        <script type="text/javascript">
        /* <![CDATA[ */
            document.observe('dom:loaded', function() {
                «application.vendorAndName»InitQuickNavigation('«name.formatForCode»');
                {{if isset($searchFilter) && $searchFilter eq false}}
                    {{* we can hide the submit button if we have no quick search field *}}
                    $('quicknavSubmit').addClassName('z-hide');
                {{/if}}
            });
        /* ]]> */
        </script>
        {/checkpermissionblock}
    '''

    def private quickNavForm(Entity it) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» view filter form #}
        {% if hasPermission('«application.appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_EDIT' %}
        {% set objectType = '«name.formatForCode»' %}
        <form action="{{ path('«application.appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view') }}" method="get" id="«application.appName.toFirstLower»«name.formatForCodeCapital»QuickNavForm" class="«application.appName.toLowerCase»-quicknav {# form-inline #}navbar-form" role="navigation">
            <fieldset>
                <h3>{{ __('Quick navigation') }}</h3>
                <input type="hidden" name="all" value="{{ all|default(0) }}" />
                <input type="hidden" name="own" value="{{ own|default(0) }}" />
                {% set lblDefault = __('All') %}
                «formFields»
                <input type="submit" name="updateview" id="quicknavSubmit" value="{{ __('OK') }}" class="btn btn-default btn-sm" />
            </fieldset>
        </form>

        <script type="text/javascript">
        /* <![CDATA[ */
            ( function($) {
                $(document).ready(function() {
                    «application.vendorAndName»InitQuickNavigation('«name.formatForCode»');
                    {% if searchFilter|default and searchFilter == false %}
                        {# we can hide the submit button if we have no quick search field #}
                        $('#quicknavSubmit').addClass('hidden');
                    {% endif %}
                });
            })(jQuery);
        /* ]]> */
        </script>
        {% endif %}
    '''

    def private formFields(Entity it) '''
        «categoriesFields»
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
            «IF application.targets('1.3.x')»
                {if !isset($searchFilter) || $searchFilter eq true}
                    <label for="searchTerm">{gt text='Search'}</label>
                    <input type="text" id="searchTerm" name="q" value="{$q}" />
                {/if}
            «ELSE»
                {% if searchFilter is not defined or searchFilter == true %}
                    <div class="form-group">
                        <label for="searchTerm">{{ __('Search') }}</label>
                        <input type="text" id="searchTerm" name="q" value="{{ q }}" class="form-control input-sm" />
                    </div>
                {% endif %}
            «ENDIF»
        «ENDIF»
        «sortingAndPageSize»
        «IF hasBooleanFieldsEntity»
            «FOR field : getBooleanFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
    '''

    def private categoriesFields(Entity it) '''
        «IF categorisable»
            «IF application.targets('1.3.x')»
                {if !isset($categoryFilter) || $categoryFilter eq true}
                    {nocache}
                    {modapifunc modname='«application.appName»' type='category' func='getAllProperties' ot=$objectType assign='properties'}
                    {if $properties ne null && is_array($properties)}
                        {gt text='All' assign='lblDefault'}
                        {foreach key='propertyName' item='propertyId' from=$properties}
                            {modapifunc modname='«application.appName»' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                            {gt text='Category' assign='categoryLabel'}
                            {assign var='categorySelectorId' value='catid'}
                            {assign var='categorySelectorName' value='catid'}
                            {assign var='categorySelectorSize' value='1'}
                            {if $hasMultiSelection eq true}
                                {gt text='Categories' assign='categoryLabel'}
                                {assign var='categorySelectorName' value='catids'}
                                {assign var='categorySelectorId' value='catids__'}
                                {assign var='categorySelectorSize' value='5'}
                            {/if}
                            <label for="{$categorySelectorId}{$propertyName}">{$categoryLabel}</label>
                            &nbsp;
                            {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIdList.$propertyName categoryRegistryModule='«application.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}
                        {/foreach}
                    {/if}
                    {/nocache}
                {/if}
            «ELSE»
                {% if categoryFilter is not defined or categoryFilter == true %}
                    {% set properties = «application.appName.formatForDB»_getCategoryProperties(objectType) %}
                    {% if properties is not null and properties is iterable %}
                        {% set lblDefault = __('All') %}
                        {% for propertyName, propertyId in properties %}
                            {% set hasMultiSelection = «application.appName.formatForDB»_isCategoryMultiValued(objectType, propertyName) %}
                            {% set categoryLabel = __('Category') %}
                            {% set categorySelectorId = 'catid' %}
                            {% set categorySelectorName = 'catid' %}
                            {% set categorySelectorSize = 1 %}
                            {% if hasMultiSelection == true %}
                                {% set categoryLabel = __('Categories') %}
                                {% set categorySelectorName = 'catids' %}
                                {% set categorySelectorId = 'catids__' %}
                                {% set categorySelectorSize = 5 %}
                            {% endif %}
                            <div class="form-group">
                                <label for="{{ categorySelectorId ~ propertyName }}">{{ categoryLabel }}</label>
                                &nbsp;
                                «/* TODO migrate to Symfony forms #416 */»
                                {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIdList.$propertyName categoryRegistryModule='«application.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize cssClass='form-control input-sm'}
                            </div>
                        {% endfor %}
                    {% endif %}
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch formField(DerivedField it) '''
        «val fieldName = name.formatForCode»
        «IF entity.application.targets('1.3.x')»
            {if !isset($«fieldName»Filter) || $«fieldName»Filter eq true}
                «formFieldImpl»
            {/if}
        «ELSE»
            {% if «fieldName»Filter is not defined or «fieldName»Filter == true %}
                <div class="form-group">
                    «formFieldImpl»
                </div>
            {% endif %}
        «ENDIF»
    '''

    def private dispatch formFieldImpl(BooleanField it) '''
        «val fieldName = name.formatForCode»
        «val fieldLabel = if (name == 'workflowState') 'state' else name»
        «IF entity.application.targets('1.3.x')»
            <label for="«fieldName»">{gt text='«fieldLabel.formatForDisplayCapital»'}</label>
            <select id="«fieldName»" name="«fieldName»">
                <option value="">{$lblDefault}</option>
            {foreach item='option' from=$«fieldName»Items}
                <option value="{$option.value}"{if $option.value eq $«fieldName»} selected="selected"{/if}>{$option.text|safetext}</option>
            {/foreach}
            </select>
        «ELSE»
            <label for="«fieldName»">{{ __('«fieldLabel.formatForDisplayCapital»') }}</label>
            <select id="«fieldName»" name="«fieldName»" class="form-control input-sm">
                <option value="">{{ lblDefault }}</option>
            {% for option in «fieldName»Items %}
                <option value="{{ option.value }}"{{ option.value == «fieldName» ? ' selected="selected"' : '' }}>{{ option.text }}</option>
            {% endfor %}
            </select>
        «ENDIF»
    '''

    def private dispatch formFieldImpl(StringField it) '''
        «val fieldName = name.formatForCode»
        «IF entity.application.targets('1.3.x')»
            <label for="«fieldName»">{gt text='«name.formatForDisplayCapital»'}</label>
            «IF country»
                {selector_countries name='«fieldName»' selectedValue=$«fieldName» defaultText=$lblDefault defaultValue=''}
            «ELSEIF language || locale»
                {html_select_locales name='«fieldName»' selected=$«fieldName»}
            «ENDIF»
        «ELSE»
            <label for="«fieldName»">{{ __('«name.formatForDisplayCapital»') }}</label>
            «IF country»
                «/* TODO migrate to Symfony forms #416 */»
                {selector_countries name='«fieldName»' selectedValue=$«fieldName» defaultText=$lblDefault defaultValue=''}
            «ELSEIF language || locale»
                «/* TODO migrate to Symfony forms #416 */»
                {html_select_locales name='«fieldName»' selected=$«fieldName»}
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch formFieldImpl(UserField it) '''
        «val fieldName = name.formatForCode»
        «IF entity.application.targets('1.3.x')»
            <label for="«fieldName»">{gt text='«name.formatForDisplayCapital»'}</label>
            {selector_user name='«fieldName»' selectedValue=$«fieldName» defaultText=$lblDefault}
        «ELSE»
            <label for="«fieldName»">{{ __('«name.formatForDisplayCapital»') }}</label>
            «/* TODO migrate to Symfony forms #416 -> core needs to provide a form type for this */»
            {# selector_user name='«fieldName»' selectedValue=$«fieldName» defaultText=$lblDefault #}
        «ENDIF»
    '''

    def private dispatch formFieldImpl(ListField it) '''
        «val fieldName = name.formatForCode»
        «IF entity.application.targets('1.3.x')»
            <label for="«fieldName»">{gt text='«name.formatForDisplayCapital»'}</label>
            <select id="«fieldName»" name="«fieldName»">
                <option value="">{$lblDefault}</option>
            {foreach item='option' from=$«fieldName»Items}
            «IF multiple»
                <option value="%{$option.value}"{if $option.title ne ''} title="{$option.title|safetext}"{/if}{if "%`$option.value`" eq $formats} selected="selected"{/if}>{$option.text|safetext}</option>
            «ELSE»
                <option value="{$option.value}"{if $option.title ne ''} title="{$option.title|safetext}"{/if}{if $option.value eq $«fieldName»} selected="selected"{/if}>{$option.text|safetext}</option>
            «ENDIF»
            {/foreach}
            </select>
        «ELSE»
            <label for="«fieldName»">{{ __('«name.formatForDisplayCapital»') }}</label>
            <select id="«fieldName»" name="«fieldName»" class="form-control input-sm">
                <option value="">{{ lblDefault }}</option>
            {% for option in «fieldName»Items %}
            «IF multiple»
                <option value="%{{ option.value }}"{% if option.title is not empty %} title="{{ option.title|e('html_attr') }}"{% endif %}{{ '%' ~ option.value == formats ? ' selected="selected"' : '' }}>{{ option.text }}</option>
            «ELSE»
                <option value="{{ option.value }}"{% if option.title is not empty %} title="{{ option.title|e('html_attr') }}"{% endif %}{{ option.value == «fieldName» ? ' selected="selected"' : '' }}>{{ option.text }}</option>
            «ENDIF»
            {/foreach}
            </select>
        «ENDIF»
    '''

    def private dispatch formField(JoinRelationship it) '''
        «val sourceName = source.name.formatForCode»
        «val sourceAliasName = getRelationAliasName(false)»
        «IF application.targets('1.3.x')»
            {if !isset($«sourceName»Filter) || $«sourceName»Filter eq true}
                <label for="«sourceAliasName»">{gt text='«(source as Entity).nameMultiple.formatForDisplayCapital»'}</label>
                {php}
                    $mainSearchTerm = '';
                    if (isset($_GET['q'])) {
                        $mainSearchTerm = $_GET['q'];
                        unset($_GET['q']);
                    }
                {/php}
                {modapifunc modname='«source.application.appName»' type='selection' func='getEntities' ot='«source.name.formatForCode»'«IF !(source as Entity).categorisable» useJoins=false«ENDIF» assign='listEntries'}
                <select id="«sourceAliasName»" name="«sourceAliasName»">
                    <option value="">{$lblDefault}</option>
                {foreach item='option' from=$listEntries}
                    «IF source.hasCompositeKeys»
                        {assign var='entryId' value="«FOR pkField : source.getPrimaryKeyFields SEPARATOR '_'»`$option.«pkField.name.formatForCode»`«ENDFOR»"}
                    «ELSE»
                        {assign var='entryId' value=$option.«source.getFirstPrimaryKey.name.formatForCode»}
                    «ENDIF»
                    <option value="{$entryId}"{if $entryId eq $«sourceAliasName»} selected="selected"{/if}>{$option->getTitleFromDisplayPattern()}</option>
                {/foreach}
                </select>
                {php}
                    if (!empty($mainSearchTerm)) {
                        $_GET['q'] = $mainSearchTerm;
                    }
                {/php}
            {/if}
        «ELSE»
            {% if «sourceName»Filter not defined or «sourceName»Filter == true %}
                <div class="form-group">
                    <label for="«sourceAliasName»">{{ __('«(source as Entity).nameMultiple.formatForDisplayCapital»') }}</label>
                    {% set mainSearchTerm = '' %}
                    {% if app.request.query.has('q') %}
                        {% set mainSearchTerm = app.request.query.get('q') %}
                        {{ app.request.query.remove('q') }}
                    {% endif %}
                    «/* TODO replace modapifunc -> migrate to Symfony forms #416 */»
                    {% set listEntries = array() %}
                    {# modapifunc modname='«source.application.appName»' type='selection' func='getEntities' ot='«source.name.formatForCode»'«IF !(source as Entity).categorisable» useJoins=false«ENDIF» assign='listEntries' #}
                    <select id="«sourceAliasName»" name="«sourceAliasName»" class="form-control input-sm">
                        <option value="">{{ lblDefault }}</option>
                    {% for option in listEntries %}
                        {% set entryId = «FOR pkField : source.getPrimaryKeyFields SEPARATOR ' ~ '»option.«pkField.name.formatForCode»«ENDFOR» %}
                        <option value="{{ entryId }}"{{ entryId == «sourceAliasName» ? ' selected="selected"' : '' }}>{{ option.getTitleFromDisplayPattern() }}</option>
                    {% endfor %}
                    </select>
                    {% if mainSearchTerm is not empty %}
                        {{ app.request.query.set('q', mainSearchTerm) }}
                    {% endif %}
                </div>
            {% endif %}
        «ENDIF»
    '''

    def private sortingAndPageSize(Entity it) '''
        «IF application.targets('1.3.x')»
            {if !isset($sorting) || $sorting eq true}
                <label for="sortBy">{gt text='Sort by'}</label>
                &nbsp;
                <select id="sortBy" name="sort">
                    «FOR field : getDerivedFields»
                        «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                            <option value="«field.name.formatForCode»"{if $sort eq '«field.name.formatForCode»'} selected="selected"{/if}>{gt text='«field.name.formatForDisplayCapital»'}</option>
                        «ENDIF»
                    «ENDFOR»
                    «IF standardFields»
                        <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                        <option value="createdUserId"{if $sort eq 'createdUserId'} selected="selected"{/if}>{gt text='Creator'}</option>
                        <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
                    «ENDIF»
                </select>
                <select id="sortDir" name="sortdir">
                    <option value="asc"{if $sdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                    <option value="desc"{if $sdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
                </select>
            {else}
                <input type="hidden" name="sort" value="{$sort}" />
                <input type="hidden" name="sdir" value="{if $sdir eq 'desc'}asc{else}desc{/if}" />
            {/if}
            {if !isset($pageSizeSelector) || $pageSizeSelector eq true}
                <label for="num">{gt text='Page size'}</label>
                <select id="num" name="num">
                    <option value="5"{if $pageSize eq 5} selected="selected"{/if}>5</option>
                    <option value="10"{if $pageSize eq 10} selected="selected"{/if}>10</option>
                    <option value="15"{if $pageSize eq 15} selected="selected"{/if}>15</option>
                    <option value="20"{if $pageSize eq 20} selected="selected"{/if}>20</option>
                    <option value="30"{if $pageSize eq 30} selected="selected"{/if}>30</option>
                    <option value="50"{if $pageSize eq 50} selected="selected"{/if}>50</option>
                    <option value="100"{if $pageSize eq 100} selected="selected"{/if}>100</option>
                </select>
            {/if}
        «ELSE»
            {% if sorting is not defined or sorting == true %}
                <div class="form-group">
                    <label for="sortBy">{{ __('Sort by') }}</label>
                    &nbsp;
                    <select id="sortBy" name="sort" class="form-control input-sm">
                        «FOR field : getDerivedFields»
                            «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                                <option value="«field.name.formatForCode»"{{ sort == '«field.name.formatForCode»' ? ' selected="selected"' : '' }}>{{ __('«field.name.formatForDisplayCapital»') }}</option>
                            «ENDIF»
                        «ENDFOR»
                        «IF standardFields»
                            <option value="createdDate"{{ sort == 'createdDate' ? ' selected="selected"' : '' }}>{{ __('Creation date') }}</option>
                            <option value="createdUserId"{{ sort == 'createdUserId' ? ' selected="selected"' : '' }}>{{ __('Creator') }}</option>
                            <option value="updatedDate"{{ sort == 'updatedDate' ? ' selected="selected"' : '' }}>{{ __('Update date') }}</option>
                        «ENDIF»
                    </select>
                </div>
                <div class="form-group">
                    <select id="sortDir" name="sortdir" class="form-control input-sm">
                        <option value="asc"{{ sdir == 'asc' ? ' selected="selected"' : '' }}>{{ __('ascending') }}</option>
                        <option value="desc"{{ sdir == 'desc' ? ' selected="selected"' : '' }}>{{ __('descending') }}</option>
                    </select>
                </div>
            {% else %}
                <input type="hidden" name="sort" value="{{ sort }}" />
                <input type="hidden" name="sdir" value="{{ sdir == 'desc' ? 'asc' : 'desc' }}" />
            {% endif %}
            {% if pageSizeSelector is not defined or pageSizeSelector == true %}
                <div class="form-group">
                    <label for="num">{{ __('Page size') }}</label>
                    <select id="num" name="num" class="form-control input-sm" style="min-width: 70px">
                        <option value="5"{{ pageSize == 5 ? ' selected="selected"' : '' }}>5</option>
                        <option value="10"{{ pageSize == 10 ? ' selected="selected"' : '' }}>10</option>
                        <option value="15"{{ pageSize == 15 ? ' selected="selected"' : '' }}>15</option>
                        <option value="20"{{ pageSize == 20 ? ' selected="selected"' : '' }}>20</option>
                        <option value="30"{{ pageSize == 30 ? ' selected="selected"' : '' }}>30</option>
                        <option value="50"{{ pageSize == 50 ? ' selected="selected"' : '' }}>50</option>
                        <option value="100"{{ pageSize == 100 ? ' selected="selected"' : '' }}>100</option>
                    </select>
                </div>
            {% endif %}
        «ENDIF»
    '''
}
