package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeView {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension UrlExtensions = new UrlExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
    	val templatePath = appName.getAppSourcePath + 'templates/contenttype/'
        for (entity : getAllEntities) {
            fsa.generateFile(templatePath + 'itemlist_' + entity.name.formatForCode.toFirstUpper + '_display_description.tpl', entity.displayDescTemplate(it))
            fsa.generateFile(templatePath + 'itemlist_' + entity.name.formatForCode.toFirstUpper + '_display.tpl', entity.displayTemplate(it))
        }
        fsa.generateFile(templatePath + 'itemlist_edit.tpl', editTemplate)
    }

    def private displayDescTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context *}
        <dl>
            {foreach item='item' from=$items}
                «val leadingField = getLeadingField»
                «IF leadingField != null»
                    <dt>{$item.«leadingField.name.formatForCode»}</dt>
                «ELSE»
                    <dt>{gt text='«name.formatForDisplayCapital»'}</dt>
                «ENDIF»
                «val textFields = fields.filter(typeof(TextField))»
                «IF !textFields.isEmpty»
                    {if $item.«textFields.head.name.formatForCode»}
                        <dd>{$item.«textFields.head.name.formatForCode»|truncate:200:"..."}</dd>
                    {/if}
                «ELSE»
                    «val stringFields = fields.filter(typeof(StringField)).filter(e|!e.leading && !e.password)»
                    «IF !stringFields.isEmpty»
                        {if $item.«stringFields.head.name.formatForCode»}
                            <dd>{$item.«stringFields.head.name.formatForCode»|truncate:200:"..."}</dd>
                        {/if}
                    «ENDIF»
                «ENDIF»
                <dd>«detailLink(app.appName)»</dd>
            {foreachelse}
                <dt>{gt text='No entries found.'}</dt>
            {/foreach}
        </dl>
    '''

    def private displayTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context *}
        {foreach item='item' from=$items}
            «val leadingField = getLeadingField»
            «IF leadingField != null»
                <h3>{$item.«leadingField.name.formatForCode»}</h3>
            «ELSE»
                <h3>{gt text='«name.formatForDisplayCapital»'}</h3>
            «ENDIF»
            «IF app.hasUserController && app.getMainUserController.hasActions('display')»
                <p>«detailLink(app.appName)»</p>
            «ENDIF»
        {/foreach}
    '''

    def private editTemplate(Application it) '''
        {* Purpose of this template: edit view of generic item list content type *}

        <div class="z-formrow">
            {formlabel for='«appName»_objecttype' __text='Object type'}
            {«appName.formatForDB»SelectorObjectTypes assign='allObjectTypes'}
            {formdropdownlist id='«appName»_objecttype' dataField='objectType' group='data' mandatory=true items=$allObjectTypes}
        </div>

        <div class="z-formrow">
            {formlabel __text='Sorting'}
            <div>
                {formradiobutton id='«appName»_srandom' value='random' dataField='sorting' group='data' mandatory=true}
                {formlabel for='«appName»_srandom' __text='Random'}
                {formradiobutton id='«appName»_snewest' value='newest' dataField='sorting' group='data' mandatory=true}
                {formlabel for='«appName»_snewest' __text='Newest'}
                {formradiobutton id='«appName»_sdefault' value='default' dataField='sorting' group='data' mandatory=true}
                {formlabel for='«appName»_sdefault' __text='Default'}
            </div>
        </div>

        <div class="z-formrow">
            {formlabel for='«appName»_amount' __text='Amount'}
            {formtextinput id='«appName»_amount' dataField='amount' group='data' mandatory=true maxLength=2}
        </div>

        <div class="z-formrow">
            {formlabel for='«appName»_template' __text='Template File'}
            {«appName.formatForDB»SelectorTemplates assign='allTemplates'}
            {formdropdownlist id='«appName»_template' dataField='template' group='data' mandatory=true items=$allTemplates}
        </div>

        <div class="z-formrow" style="display: none"«/* TODO: wait until FilterUtil is ready for Doctrine 2 */»>
            {formlabel for='«appName»_filter' __text='Filter (expert option)'}
            {formtextinput id='«appName»_filter' dataField='filter' group='data' mandatory=false maxLength=255}
            <div class="z-formnote">({gt text='Syntax examples'}: <kbd>name:like:foobar</kbd> {gt text='or'} <kbd>status:ne:3</kbd>)</div>
        </div>
    '''

    def private detailLink(Entity it, String appName) '''
        <a href="{modurl modname='«appName»' type='user' «modUrlDisplayWithFreeOt('item', true, '$objectType')»}">{gt text='Read more'}</a>
    '''
}
