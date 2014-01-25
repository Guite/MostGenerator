package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MetaData {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate (Application it, Controller controller, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) controller.formattedName else controller.formattedName.toFirstUpper) + '/'
        if (controller.hasActions('view') || controller.hasActions('display')) {
            if (!shouldBeSkipped(templatePath + 'include_metadata_display.tpl')) {
                fsa.generateFile(templatePath + 'include_metadata_display.tpl', metaDataViewImpl(controller))
            }
        }
        if (controller.hasActions('edit')) {
            if (!shouldBeSkipped(templatePath + 'include_metadata_edit.tpl')) {
                fsa.generateFile(templatePath + 'include_metadata_edit.tpl', metaDataEditImpl(controller))
            }
        }
    }

    def private metaDataViewImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable display of meta data fields *}
        {if isset($obj.metadata)}
            {if isset($panel) && $panel eq true}
                <h3 class="metadata z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Metadata'}</h3>
                <div class="metadata z-panel-content" style="display: none">
            {else}
                <h3 class="metadata">{gt text='Metadata'}</h3>
            {/if}
            <dl class="propertylist">
            {if $obj.metadata.title ne ''}
                <dt>{gt text='Title'}</dt>
                <dd>{$obj.metadata.title|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.author ne ''}
                <dt>{gt text='Author'}</dt>
                <dd>{$obj.metadata.author|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.subject ne ''}
                <dt>{gt text='Subject'}</dt>
                <dd>{$obj.metadata.subject|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.keywords ne ''}
                <dt>{gt text='Keywords'}</dt>
                <dd>{$obj.metadata.keywords|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.description ne ''}
                <dt>{gt text='Description'}</dt>
                <dd>{$obj.metadata.description|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.publisher ne ''}
                <dt>{gt text='Publisher'}</dt>
                <dd>{$obj.metadata.publisher|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.contributor ne ''}
                <dt>{gt text='Contributor'}</dt>
                <dd>{$obj.metadata.contributor|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.startdate ne ''}
                <dt>{gt text='Start date'}</dt>
                <dd>{$obj.metadata.startdate|dateformat}</dd>
            {/if}
            {if $obj.metadata.enddate ne ''}
                <dt>{gt text='End date'}</dt>
                <dd>{$obj.metadata.enddate|dateformat}</dd>
            {/if}
            {if $obj.metadata.type ne ''}
                <dt>{gt text='Type'}</dt>
                <dd>{$obj.metadata.type|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.format ne ''}
                <dt>{gt text='Format'}</dt>
                <dd>{$obj.metadata.format|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.uri ne ''}
                <dt>{gt text='Uri'}</dt>
                <dd>{$obj.metadata.uri|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.source ne ''}
                <dt>{gt text='Source'}</dt>
                <dd>{$obj.metadata.source|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.language ne ''}
                <dt>{gt text='Language'}</dt>
                <dd>{$obj.metadata.language|getlanguagename|safehtml}</dd>
            {/if}
            {if $obj.metadata.relation ne ''}
                <dt>{gt text='Relation'}</dt>
                <dd>{$obj.metadata.relation|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.coverage ne ''}
                <dt>{gt text='Coverage'}</dt>
                <dd>{$obj.metadata.coverage|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.comment ne ''}
                <dt>{gt text='Comment'}</dt>
                <dd>{$obj.metadata.comment|default:'-'|safetext}</dd>
            {/if}
            {if $obj.metadata.extra ne ''}
                <dt>{gt text='Extra'}</dt>
                <dd>{$obj.metadata.extra|default:'-'|safetext}</dd>
            {/if}
            </dl>
            {if isset($panel) && $panel eq true}
                </div>
            {/if}
        {/if}
    '''

    def private metaDataEditImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable editing of meta data fields *}
        {if isset($panel) && $panel eq true}
            <h3 class="metadata z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Metadata'}</h3>
            <fieldset class="metadata z-panel-content" style="display: none">
        {else}
            <fieldset class="metadata">
        {/if}
            <legend>{gt text='Metadata'}</legend>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataTitle' __text='Title'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataTitle' dataField='title' maxLength=80«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataAuthor' __text='Author'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataAuthor' dataField='author' maxLength=80«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataSubject' __text='Subject'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataSubject' dataField='subject' maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataKeywords' __text='Keywords'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataKeywords' dataField='keywords' maxLength=128«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataDescription' __text='Description'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataDescription' dataField='description' maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataPublisher' __text='Publisher'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataPublisher' dataField='publisher' maxLength=128«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataContributor' __text='Contributor'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataContributor' dataField='contributor' maxLength=80«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataStartdate' __text='Start date'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                {if $mode ne 'create'}
                    {formdateinput group='meta' id='metadataStartdate' dataField='startdate' mandatory=false includeTime=true«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                {else}
                    {formdateinput group='meta' id='metadataStartdate' dataField='startdate' mandatory=false includeTime=true defaultValue='now'«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                {/if}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataEnddate' __text='End date'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                {if $mode ne 'create'}
                    {formdateinput group='meta' id='metadataEnddate' dataField='enddate' mandatory=false includeTime=true«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                {else}
                    {formdateinput group='meta' id='metadataEnddate' dataField='enddate' mandatory=false includeTime=true defaultValue='now'«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                {/if}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataType' __text='Type'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataType' dataField='type' maxLength=128«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataFormat' __text='Format'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataFormat' dataField='format' maxLength=128«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataUri' __text='Uri'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataUri' dataField='uri' maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataSource' __text='Source'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataSource' dataField='source' maxLength=128«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataLanguage' __text='Language'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formlanguageselector group='meta' id='metadataLanguage' mandatory=false __title='Choose a language' dataField='language'«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataRelation' __text='Relation'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataRelation' dataField='relation' maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataCoverage' __text='Coverage'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataCoverage' dataField='coverage' maxLength=64«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataComment' __text='Comment'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataComment' dataField='comment' maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>

            <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='metadataExtra' __text='Extra'«IF !targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group='meta' id='metadataExtra' dataField='extra' maxLength=255«IF !targets('1.3.5')» cssClass='form-control'«ENDIF»}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
            </div>
        </fieldset>
    '''
}
