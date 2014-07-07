package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.modulestudio.Application
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
        val templatePath = getViewPath + (if (targets('1.3.5')) 'helper' else 'Helper') + '/'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'include_metadata_display.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'include_metadata_display.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, metaDataViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'include_metadata_edit.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'include_metadata_edit.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, metaDataEditImpl)
            }
        }
    }

    def private metaDataViewImpl(Application it) '''
        {* purpose of this template: reusable display of meta data fields *}
        {if isset($obj.metadata)}
            {if isset($panel) && $panel eq true}
                «IF targets('1.3.5')»
                    <h3 class="metadata z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Metadata'}</h3>
                    <div class="metadata z-panel-content" style="display: none">
                «ELSE»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMetadata">{gt text='Metadata'}</a></h3>
                        </div>
                        <div id="collapseMetadata" class="panel-collapse collapse in">
                            <div class="panel-body">
                «ENDIF»
            {else}
                <h3 class="metadata">{gt text='Metadata'}</h3>
            {/if}
            «viewBody»
            {if isset($panel) && $panel eq true}
                «IF targets('1.3.5')»
                    </div>
                «ELSE»
                            </div>
                        </div>
                    </div>
                «ENDIF»
            {/if}
        {/if}
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
        {if $obj.metadata.startdate ne ''}
            <dt>{gt text='Start date'}</dt>
            <dd>{$obj.metadata.startdate|dateformat}</dd>
        {/if}
        {if $obj.metadata.enddate ne ''}
            <dt>{gt text='End date'}</dt>
            <dd>{$obj.metadata.enddate|dateformat}</dd>
        {/if}
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
        {if $obj.metadata.«fieldName» ne ''}
            <dt>{gt text='«fieldName.formatForDisplayCapital»'}</dt>
            «IF 'language'.equals(fieldName)»
            <dd>{$obj.metadata.«fieldName»|getlanguagename|safehtml}</dd>
            «ELSE»
            <dd>{$obj.metadata.«fieldName»|default:'-'|safetext}</dd>
            «ENDIF»
        {/if}
    '''

    def private metaDataEditImpl(Application it) '''
        {* purpose of this template: reusable editing of meta data fields *}
        {if isset($panel) && $panel eq true}
            «IF targets('1.3.5')»
                <h3 class="metadata z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Metadata'}</h3>
                <fieldset class="metadata z-panel-content" style="display: none">
            «ELSE»
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMetadata">{gt text='Metadata'}</a></h3>
                    </div>
                    <div id="collapseMetadata" class="panel-collapse collapse in">
                        <div class="panel-body">
            «ENDIF»
        {else}
            <fieldset class="metadata">
        {/if}
            <legend>{gt text='Metadata'}</legend>
            «editBody»
        {if isset($panel) && $panel eq true}
            «IF targets('1.3.5')»
                </fieldset>
            «ELSE»
                        </div>
                    </div>
                </div>
            «ENDIF»
        {else}
            </fieldset>
        {/if}
    '''

    def private editBody(Application it) '''

        «formRow('title', 80)»
        «formRow('author', 80)»
        «formRow('subject', 255)»
        «formRow('keywords', 128)»
        «formRow('description', 255)»
        «formRow('publisher', 128)»
        «formRow('contributor', 80)»
        «formRow('startdate', 0)»
        «formRow('enddate', 0)»
        «formRow('type', 128)»
        «formRow('format', 128)»
        «formRow('uri', 255)»
        «formRow('source', 128)»
        «formRow('language', 0)»
        «formRow('relation', 255)»
        «formRow('coverage', 64)»
        «formRow('comment', 255)»
        «formRow('extra', 255)»
    '''

    def private formRow(String fieldName, Integer length) '''
        «val useBootstrap = !app.targets('1.3.5')»
        «val label = fieldName.formatForDisplayCapital»

        <div class="«IF useBootstrap»form-group«ELSE»z-formrow«ENDIF»">
            {formlabel for='metadata«label»' __text='«label»'«IF useBootstrap» cssClass='col-lg-3 control-label'«ENDIF»}
            «IF useBootstrap»
                <div class="col-lg-9">
            «ENDIF»
                «IF 'startdate'.equals(fieldName) || 'enddate'.equals(fieldName)»
                {if $mode ne 'create'}
                    {formdateinput group='meta' id='metadataEnddate' dataField='enddate' mandatory=false includeTime=true«IF useBootstrap» cssClass='form-control'«ENDIF»}
                {else}
                    {formdateinput group='meta' id='metadataEnddate' dataField='enddate' mandatory=false includeTime=true defaultValue='now'«IF useBootstrap» cssClass='form-control'«ENDIF»}
                {/if}
                «ELSEIF 'language'.equals(fieldName)»
                {formlanguageselector group='meta' id='metadata«label»' mandatory=false __title='Choose a language' dataField='«fieldName»'«IF useBootstrap» cssClass='form-control'«ENDIF»}
                «ELSE»
                {formtextinput group='meta' id='metadata«label»' dataField='«fieldName»' maxLength=«length»«IF useBootstrap» cssClass='form-control'«ENDIF»}
                «ENDIF»
            «IF useBootstrap»
                </div>
            «ENDIF»
        </div>
    '''
}
