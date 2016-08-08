package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MetaData {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app

    def generate (Application it, IFileSystemAccess fsa) {
        this.app = it
        val templatePath = getViewPath + (if (targets('1.3.x')) 'helper' else 'Helper') + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeMetaDataDisplay' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeMetaDataDisplay.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) metaDataViewImplLegacy else metaDataViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'includeMetaDataEdit' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeMetaDataEdit.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) metaDataEditImplLegacy else metaDataEditImpl)
            }
        }
    }

    def private metaDataViewImplLegacy(Application it) '''
        {* purpose of this template: reusable display of meta data fields *}
        {if isset($obj.metadata)}
            {if isset($panel) && $panel eq true}
                <h3 class="metadata z-panel-header z-panel-indicator z-pointer">{gt text='Metadata'}</h3>
                <div class="metadata z-panel-content" style="display: none">
            {else}
                <h3 class="metadata">{gt text='Metadata'}</h3>
            {/if}
            «viewBody»
            {if isset($panel) && $panel eq true}
                </div>
            {/if}
        {/if}
    '''

    def private metaDataViewImpl(Application it) '''
        {# purpose of this template: reusable display of meta data fields #}
        {% if obj.metadata is defined %}
            {% if panel|default(false) == true %}
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMetadata">{{ __('Metadata') }}</a></h3>
                    </div>
                    <div id="collapseMetadata" class="panel-collapse collapse in">
                        <div class="panel-body">
            {% else %}
                <h3 class="metadata">{{ __('Metadata') }}</h3>
            {% endif %}
            «viewBody»
            {% if panel|default(false) == true %}
                        </div>
                    </div>
                </div>
            {% endif %}
        {% endif %}
    '''

    def private viewBody(Application it) '''
        <dl class="propertylist">
        «displayRow('title')»
        «displayRow('author')»
        «displayRow('subject')»
        «displayRow('keywords')»
        «displayRow('description')»
        «displayRow('publisher')»
        «displayRow('contributor')»
        «IF targets('1.3.x')»
            {if $obj.metadata.startdate ne ''}
                <dt>{gt text='Start date'}</dt>
                <dd>{$obj.metadata.startdate|dateformat}</dd>
            {/if}
            {if $obj.metadata.enddate ne ''}
                <dt>{gt text='End date'}</dt>
                <dd>{$obj.metadata.enddate|dateformat}</dd>
            {/if}
        «ELSE»
            {% if obj.metadata.startdate is not empty %}
                <dt>{{ __('Start date') }}</dt>
                <dd>{{ obj.metadata.startdate|localizeddate('medium', 'short') }}</dd>
            {% endif %}
            {% if obj.metadata.enddate is not empty %}
                <dt>{{ __('End date') }}</dt>
                <dd>{{ obj.metadata.enddate|localizeddate('medium', 'short') }}</dd>
            {% endif %}
        «ENDIF»
        «displayRow('type')»
        «displayRow('format')»
        «displayRow('uri')»
        «displayRow('source')»
        «displayRow('language')»
        «displayRow('relation')»
        «displayRow('coverage')»
        «displayRow('comment')»
        «displayRow('extra')»
        </dl>
    '''

    def private displayRow(String fieldName) '''
        «IF app.targets('1.3.x')»
            {if $obj.metadata.«fieldName» ne ''}
                <dt>{gt text='«fieldName.formatForDisplayCapital»'}</dt>
                «IF 'language'.equals(fieldName)»
                <dd>{$obj.metadata.«fieldName»|getlanguagename|safehtml}</dd>
                «ELSE»
                <dd>{$obj.metadata.«fieldName»|default:'-'|safetext}</dd>
                «ENDIF»
            {/if}
        «ELSE»
            {% if obj.metadata.«fieldName» is not empty %}
                <dt>{{ __('«fieldName.formatForDisplayCapital»') }}</dt>
                «IF 'language'.equals(fieldName)»
                <dd>{{ obj.metadata.«fieldName»|languageName|safeHtml }}</dd>
                «ELSE»
                <dd>{{ obj.metadata.«fieldName» }}</dd>
                «ENDIF»
            {% endif %}
        «ENDIF»
    '''

    def private metaDataEditImplLegacy(Application it) '''
        {* purpose of this template: reusable editing of meta data fields *}
        {if isset($panel) && $panel eq true}
            <h3 class="metadata z-panel-header z-panel-indicator z-pointer">{gt text='Metadata'}</h3>
            <fieldset class="metadata z-panel-content" style="display: none">
        {else}
            <fieldset class="metadata">
        {/if}
            <legend>{gt text='Metadata'}</legend>
            «editBody»
        {if isset($panel) && $panel eq true}
            </fieldset>
        {else}
            </fieldset>
        {/if}
    '''

    def private metaDataEditImpl(Application it) '''
        {# purpose of this template: reusable editing of meta data fields #}
        {% if panel|default(false) == true %}
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMetadata">{{ __('Metadata') }}</a></h3>
                </div>
                <div id="collapseMetadata" class="panel-collapse collapse in">
                    <div class="panel-body">
        {% else %}
            <fieldset class="metadata">
        {% endif %}
            <legend>{{ __('Metadata') }}</legend>
            «editBody»
        {% if panel|default(false) == true %}
                    </div>
                </div>
            </div>
        {% else %}
            </fieldset>
        {% endif %}
    '''

    def private editBody(Application it) '''

        «formRowWrapper('title', 80)»
        «formRowWrapper('author', 80)»
        «formRowWrapper('subject', 255)»
        «formRowWrapper('keywords', 128)»
        «formRowWrapper('description', 255)»
        «formRowWrapper('publisher', 128)»
        «formRowWrapper('contributor', 80)»
        «formRowWrapper('startdate', 0)»
        «formRowWrapper('enddate', 0)»
        «formRowWrapper('type', 128)»
        «formRowWrapper('format', 128)»
        «formRowWrapper('uri', 255)»
        «formRowWrapper('source', 128)»
        «formRowWrapper('language', 0)»
        «formRowWrapper('relation', 255)»
        «formRowWrapper('coverage', 64)»
        «formRowWrapper('comment', 255)»
        «formRowWrapper('extra', 255)»
    '''

    def private formRowWrapper(String fieldName, Integer length) '''
        «IF app.targets('1.3.x')»«formRowLegacy(fieldName, length)»«ELSE»«formRow(fieldName)»«ENDIF»
    '''

    def private formRowLegacy(String fieldName, Integer length) '''
        <div class="z-formrow">
            {formlabel for='metadata«fieldName»' __text='«fieldName.formatForDisplayCapital»'}
            «IF 'startdate'.equals(fieldName) || 'enddate'.equals(fieldName)»
                {if $mode ne 'create'}
                    {formdateinput group='meta' id='metadata«fieldName»' dataField='«fieldName»' mandatory=false includeTime=true}
                {else}
                    {formdateinput group='meta' id='metadata«fieldName»' dataField='«fieldName»' mandatory=false includeTime=true defaultValue='now'}
                {/if}
            «ELSEIF 'language'.equals(fieldName)»
                {formlanguageselector group='meta' id='metadata«fieldName»' mandatory=false __title='Choose a language' dataField='«fieldName»'}
            «ELSE»
                {formtextinput group='meta' id='metadata«fieldName»' dataField='«fieldName»' maxLength=«length»}
            «ENDIF»
        </div>
    '''

    def private formRow(String fieldName) '''
        {{ form_row(form.metadata.«fieldName») }}
    '''
}
