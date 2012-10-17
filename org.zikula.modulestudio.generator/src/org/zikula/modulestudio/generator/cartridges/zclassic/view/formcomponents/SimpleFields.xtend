package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleFields {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension Utils = new Utils()

    Validation validationHelper = new Validation()

    def formRow(DerivedField it, String groupSuffix, String idSuffix) '''
        «formLabel(groupSuffix, idSuffix)»
        «formField(groupSuffix, idSuffix)»
        «validationHelper.mandatoryValidationMessage(it, idSuffix)»
        «validationHelper.additionalValidationMessages(it, idSuffix)»
    '''

    def private dispatch formLabel(DerivedField it, String groupSuffix, String idSuffix) '''
        «initDocumentationToolTip»
        {formlabel for=«templateIdWithSuffix(name.formatForCode, idSuffix)» __text='«formLabelText»'«IF mandatory» mandatorysym='1'«ENDIF»«formLabelAdditions»}
    '''

    def private dispatch formLabel(UploadField it, String groupSuffix, String idSuffix) '''
        «initDocumentationToolTip»
        «IF mandatory»
            {assign var='mandatorySym' value='1'}
            {if $mode ne 'create'}
                {assign var='mandatorySym' value='0'}
            {/if}
        «ENDIF»
        {formlabel for=«templateIdWithSuffix(name.formatForCode, idSuffix)» __text='«formLabelText»'«IF mandatory» mandatorysym=$mandatorySym«ENDIF»«formLabelAdditions»}<br />{* break required for Google Chrome *}
    '''

    def private initDocumentationToolTip(DerivedField it) '''
        «IF documentation != null && documentation != ''»
            {gt text='«documentation.replaceAll("'", '"')»' assign='toolTip'}
        «ENDIF»
    '''

    def private formLabelAdditions(DerivedField it) '''«IF documentation != null && documentation != ''» class='«entity.container.application.appName.formatForDB»FormTooltips' title=$toolTip«ENDIF»'''

    def private formLabelText(DerivedField it) {
        name.formatForDisplayCapital
    }

    def private groupAndId(EntityField it, String groupSuffix, String idSuffix) '''group=«templateIdWithSuffix(entity.name.formatForDB, groupSuffix)» id=«templateIdWithSuffix(name.formatForCode, idSuffix)»'''

    def private dispatch formField(BooleanField it, String groupSuffix, String idSuffix) '''
        {formcheckbox «groupAndId(groupSuffix, idSuffix)» readOnly=«readonly.displayBool» __title='«name.formatForDisplay» ?'«validationHelper.fieldValidationCssClass(it)»}
    '''

    def private dispatch formField(IntegerField it, String groupSuffix, String idSuffix) '''
        {formintinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' maxLength=«length»«IF minValue != 0» minValue=«minValue»«ENDIF»«IF maxValue != 0» maxValue=«maxValue»«ENDIF»«validationHelper.fieldValidationCssClass(it)»}
    '''

    def private dispatch formField(DecimalField it, String groupSuffix, String idSuffix) '''
        {formfloatinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF minValue != 0 && minValue.toString() != '0.0' && minValue.toString() != '0.00'» minValue=«minValue»«ENDIF»«IF maxValue != 0 && maxValue.toString() != '0.0' && maxValue.toString() != '0.00'» maxValue=«maxValue»«ENDIF» maxLength=«(length+3+scale)»«IF scale != 2» precision=«scale»«ENDIF»«validationHelper.fieldValidationCssClass(it)»}
    '''

    def private dispatch formField(FloatField it, String groupSuffix, String idSuffix) '''
        {formfloatinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF minValue != 0 && minValue.toString() != '0.0' && minValue.toString() != '0.00'» minValue=«minValue»«ENDIF»«IF maxValue != 0 && maxValue.toString() != '0.0' && maxValue.toString() != '0.00'» maxValue=«maxValue»«ENDIF»«validationHelper.fieldValidationCssClass(it)»}
    '''

    def private dispatch formField(StringField it, String groupSuffix, String idSuffix) '''
        «IF country»
            {«entity.container.application.appName.formatForDB»CountrySelector «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'}
        «ELSEIF language»
            {formlanguageselector «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'}
        «ELSEIF htmlcolour»
            {«entity.container.application.appName.formatForDB»ColourInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«validationHelper.fieldValidationCssClass(it)»}
        «ELSE»
            {formtextinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='«IF password»password«ELSE»singleline«ENDIF»'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it)»}
        «ENDIF»
    '''

    def private dispatch formField(TextField it, String groupSuffix, String idSuffix) '''
        {formtextinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='multiline'«IF minLength > 0» minLength=«minLength»«ENDIF» rows='6«/*8*/»' cols='50'«validationHelper.fieldValidationCssClass(it)»}
    '''

    def private dispatch formField(EmailField it, String groupSuffix, String idSuffix) '''
        {formemailinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it)»}
    '''

    def private dispatch formField(UrlField it, String groupSuffix, String idSuffix) '''
        {formurlinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it)»}
    '''

    def private dispatch formField(UploadField it, String groupSuffix, String idSuffix) '''
        «IF mandatory»
            {if $mode eq 'create'}
                {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClass(it)»}
            {else}
                {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=false readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClassEdit(it)»}
                <p class="z-formnote"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="z-hide">{gt text='Reset to empty value'}</a></p>
            {/if}
        «ELSE»
            {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=false readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClass(it)»}
            <p class="z-formnote"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="z-hide">{gt text='Reset to empty value'}</a></p>
        «ENDIF»

            <div class="z-formnote">{gt text='Allowed file extensions:'} <span id="fileextensions«name.formatForCode»">«allowedExtensions»</span></div>
        «IF allowedFileSize > 0»
            <div class="z-formnote">{gt text='Allowed file size:'} {'«allowedFileSize»'|«entity.container.application.appName.formatForDB»GetFileSize:'':false:false}</div>
        «ENDIF»
        «decideWhetherToShowCurrentFile»
    '''

    def private decideWhetherToShowCurrentFile(UploadField it) '''
        «val fieldName = entity.name.formatForCode + '.' + name.formatForCode»
        {if $mode ne 'create'}
            {if $«fieldName» ne ''}
                «showCurrentFile»
            {/if}
        {/if}
    '''

    def private showCurrentFile(UploadField it) '''
        «val appNameSmall = entity.container.application.appName.formatForDB»
        «val objName = entity.name.formatForCode»
        «val realName = objName + '.' + name.formatForCode»
        <div class="z-formnote">
            {gt text='Current file'}:
            <a href="{$«realName»FullPathUrl}" title="{$«objName».«entity.getLeadingField.name.formatForCode»|replace:"\"":""}"{if $«realName»Meta.isImage} rel="imageviewer[«entity.name.formatForDB»]"{/if}>
            {if $«realName»Meta.isImage}
                <img src="{$«realName»FullPath|«appNameSmall»ImageThumb:80:50}" width="80" height="50" alt="{$«objName».«entity.getLeadingField.name.formatForCode»|replace:"\"":""}" />
            {else}
                {gt text='Download'} ({$«realName»Meta.size|«appNameSmall»GetFileSize:$«realName»FullPath:false:false})
            {/if}
            </a>
        </div>
        «IF !mandatory»
            <div class="z-formnote">
                {formcheckbox group='«entity.name.formatForDB»' id='«name.formatForCode»DeleteFile' readOnly=false __title='Delete «name.formatForDisplay» ?'}
                {formlabel for='«name.formatForCode»DeleteFile' __text='Delete existing file'}
            </div>
        «ENDIF»
    '''

    def private dispatch formField(ListField it, String groupSuffix, String idSuffix) '''
        «IF multiple == true && useChecks == true»
            {formcheckboxlist «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay»' repeatColumns=2}
        «ELSE»
            {formdropdownlist «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay»' selectionMode='«IF multiple»multiple«ELSE»single«ENDIF»'}
        «ENDIF»
    '''

    def private dispatch formField(UserField it, String groupSuffix, String idSuffix) '''
        {«entity.container.application.appName.formatForDB»UserInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter a part of the user name to search' maxLength=25 cssClass='«IF mandatory»required «ENDIF»validate-alphanum«IF unique» validate-unique«ENDIF»'}
        {if $mode ne 'create' && $«entity.name.formatForDB».«name.formatForDB» && !$inlineUsage}
            {checkpermissionblock component='Users::' instance='.*' level='ACCESS_ADMIN'}
            <div class="z-formnote"><a href="{modurl modname='Users' type='admin' func='modify' userid=$«entity.name.formatForDB».«name.formatForDB»}" title="{gt text='Switch to the user administration'}">{gt text='Manage user'}</a></div>
            {/checkpermissionblock}
        {/if}
    '''

    def private dispatch formField(AbstractDateField it, String groupSuffix, String idSuffix) '''
        «formFieldDetails(groupSuffix, idSuffix)»
        «IF past»
            <div class="z-formnote">{gt text='Note: this value must be in the past.'}</div>
        «ELSEIF future»
            <div class="z-formnote">{gt text='Note: this value must be in the future.'}</div>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(AbstractDateField it, String groupSuffix, String idSuffix) {
    }
    def private dispatch formFieldDetails(DatetimeField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' includeTime=true«validationHelper.fieldValidationCssClass(it)»}
        {else}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' includeTime=true defaultValue='«IF defaultValue != null && defaultValue != '' && defaultValue != 'now'»«defaultValue»«ELSE»now«ENDIF»'«validationHelper.fieldValidationCssClass(it)»}
        {/if}
        «/*TODO: visible=false*/»
        «IF !mandatory»
            <p class="z-formnote"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="z-hide">{gt text='Reset to empty value'}</a></p>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(DateField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' useSelectionMode=true«validationHelper.fieldValidationCssClass(it)»}
        {else}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' useSelectionMode=true defaultValue='«IF defaultValue != null && defaultValue != '' && defaultValue != 'now'»«defaultValue»«ELSE»today«ENDIF»'«validationHelper.fieldValidationCssClass(it)»}
        {/if}
        «IF !mandatory»
            <p class="z-formnote"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="z-hide">{gt text='Reset to empty value'}</a></p>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(TimeField it, String groupSuffix, String idSuffix) '''
        {* TODO: support time fields in Zikula (see https://github.com/Guite/MostGenerator/issues/87 for more information) *}
        {formtextinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline' maxLength=8«validationHelper.fieldValidationCssClass(it)»}
    '''
}
