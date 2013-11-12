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
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension Utils = new Utils

    Validation validationHelper = new Validation

    def formRow(DerivedField it, String groupSuffix, String idSuffix) '''
        «formLabel(groupSuffix, idSuffix)»
        «IF !entity.container.application.targets('1.3.5')»
            <div class="col-lg-9">
        «ENDIF»
        «formField(groupSuffix, idSuffix)»
        «IF !entity.container.application.targets('1.3.5')»
            </div>
        «ENDIF»
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
        «IF documentation !== null && documentation != ''»
            {gt text='«documentation.replaceAll("'", '"')»' assign='toolTip'}
        «ENDIF»
    '''

    def private formLabelAdditions(DerivedField it) ''' cssClass='«IF documentation !== null && documentation != ''»«entity.container.application.appName.toLowerCase»-form-tooltips«ENDIF»«IF !entity.container.application.targets('1.3.5')» col-lg-3 control-label«ENDIF»'«IF documentation !== null && documentation != ''» title=$toolTip«ENDIF»'''

    def private formLabelText(DerivedField it) {
        name.formatForDisplayCapital
    }

    def private groupAndId(EntityField it, String groupSuffix, String idSuffix) '''group=«templateIdWithSuffix(entity.name.formatForDB, groupSuffix)» id=«templateIdWithSuffix(name.formatForCode, idSuffix)»'''

    def private dispatch formField(BooleanField it, String groupSuffix, String idSuffix) '''
        {formcheckbox «groupAndId(groupSuffix, idSuffix)» readOnly=«readonly.displayBool» __title='«name.formatForDisplay» ?'«validationHelper.fieldValidationCssClass(it, false)»}
    '''

    def private dispatch formField(IntegerField it, String groupSuffix, String idSuffix) '''
        {formintinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' maxLength=«length»«IF minValue.toString != '0'» minValue=«minValue»«ENDIF»«IF maxValue.toString != '0'» maxValue=«maxValue»«ENDIF»«validationHelper.fieldValidationCssClass(it, true)»}
    '''

    def private dispatch formField(DecimalField it, String groupSuffix, String idSuffix) '''
        «IF !entity.container.application.targets('1.3.5') && currency»
            <div class="input-group">
                <span class="input-group-addon">{gt text='$' comment='Currency symbol'}</span>
        «ENDIF»
            {formfloatinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF minValue != 0 && minValue.toString != '0.0' && minValue.toString() != '0.00'» minValue=«minValue»«ENDIF»«IF maxValue != 0 && maxValue.toString() != '0.0' && maxValue.toString() != '0.00'» maxValue=«maxValue»«ENDIF» maxLength=«(length+3+scale)»«IF scale != 2» precision=«scale»«ENDIF»«validationHelper.fieldValidationCssClass(it, true)»}
        «IF !entity.container.application.targets('1.3.5') && currency»
            </div>
        «ENDIF»
    '''

    def private dispatch formField(FloatField it, String groupSuffix, String idSuffix) '''
        «IF !entity.container.application.targets('1.3.5') && currency»
            <div class="input-group">
                <span class="input-group-addon">{gt text='$' comment='Currency symbol'}</span>
        «ENDIF»
            {formfloatinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF minValue != 0 && minValue.toString != '0.0' && minValue.toString() != '0.00'» minValue=«minValue»«ENDIF»«IF maxValue != 0 && maxValue.toString() != '0.0' && maxValue.toString() != '0.00'» maxValue=«maxValue»«ENDIF»«validationHelper.fieldValidationCssClass(it, true)»}
        «IF !entity.container.application.targets('1.3.5') && currency»
            </div>
        «ENDIF»
    '''

    def private dispatch formField(StringField it, String groupSuffix, String idSuffix) '''
        «IF country»
            {«entity.container.application.appName.formatForDB»CountrySelector «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF !entity.container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ELSEIF language»
            {formlanguageselector «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool»«IF mandatory» addAllOption=false«ENDIF» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF !entity.container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ELSEIF htmlcolour»
            {«entity.container.application.appName.formatForDB»ColourInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«validationHelper.fieldValidationCssClass(it, true)»}
        «ELSE»
            {formtextinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='«IF password»password«ELSE»singleline«ENDIF»'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it, true)»}
        «ENDIF»
    '''

    def private dispatch formField(TextField it, String groupSuffix, String idSuffix) '''
        {formtextinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='multiline'«IF minLength > 0» minLength=«minLength»«ENDIF» rows='6«/*8*/»'«IF entity.container.application.targets('1.3.5')» cols='50'«ENDIF»«validationHelper.fieldValidationCssClass(it, true)»}
    '''

    def private dispatch formField(EmailField it, String groupSuffix, String idSuffix) '''
        «IF !entity.container.application.targets('1.3.5')»
            <div class="input-group">
                <span class="input-group-addon">@</span>
        «ENDIF»
            {formemailinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it, true)»}
        «IF !entity.container.application.targets('1.3.5')»
            </div>
        «ENDIF»
    '''

    def private dispatch formField(UrlField it, String groupSuffix, String idSuffix) '''
        {formurlinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it, true)»}
    '''

    def private dispatch formField(UploadField it, String groupSuffix, String idSuffix) '''
        «IF mandatory»
            {if $mode eq 'create'}
                {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClass(it, true)»}
            {else}
                {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=false readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClassOptional(it, true)»}
                <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="«IF entity.container.application.targets('1.3.5')»z-«ENDIF»hide">{gt text='Reset to empty value'}</a></span>
            {/if}
        «ELSE»
            {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=false readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClassOptional(it, true)»}
            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="«IF entity.container.application.targets('1.3.5')»z-«ENDIF»hide">{gt text='Reset to empty value'}</a></span>
        «ENDIF»

            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»">{gt text='Allowed file extensions:'} <span id="«name.formatForCode»FileExtensions">«allowedExtensions»</span></span>
        «IF allowedFileSize > 0»
            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»">{gt text='Allowed file size:'} {'«allowedFileSize»'|«entity.container.application.appName.formatForDB»GetFileSize:'':false:false}</span>
        «ENDIF»
        «decideWhetherToShowCurrentFile»
    '''

    def private decideWhetherToShowCurrentFile(UploadField it) '''
        «val fieldName = entity.name.formatForDB + '.' + name.formatForCode»
        {if $mode ne 'create'}
            {if $«fieldName» ne ''}
                «showCurrentFile»
            {/if}
        {/if}
    '''

    def private showCurrentFile(UploadField it) '''
        «val appNameSmall = entity.container.application.appName.formatForDB»
        «val objName = entity.name.formatForDB»
        «val realName = objName + '.' + name.formatForCode»
        <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»">
            {gt text='Current file'}:
            <a href="{$«realName»FullPathUrl}" title="{$«objName»->getTitleFromDisplayPattern()|replace:"\"":""}"{if $«realName»Meta.isImage} rel="imageviewer[«entity.name.formatForDB»]"{/if}>
            {if $«realName»Meta.isImage}
                {thumb image=$«realName»FullPath objectid="«entity.name.formatForCode»«IF entity.hasCompositeKeys»«FOR pkField : entity.getPrimaryKeyFields»-`$«objName».«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$«objName».«entity.primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$«entity.name.formatForCode»ThumbPreset«name.formatForCodeCapital» tag=true img_alt=$«objName»->getTitleFromDisplayPattern()«IF !entity.container.application.targets('1.3.5')» img_class='img-thumbnail'«ENDIF»}
            {else}
                {gt text='Download'} ({$«realName»Meta.size|«appNameSmall»GetFileSize:$«realName»FullPath:false:false})
            {/if}
            </a>
        </span>
        «IF !mandatory»
            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»">
                {formcheckbox group='«entity.name.formatForDB»' id='«name.formatForCode»DeleteFile' readOnly=false __title='Delete «name.formatForDisplay» ?'}
                {formlabel for='«name.formatForCode»DeleteFile' __text='Delete existing file'}
            </span>
        «ENDIF»
    '''

    def private dispatch formField(ListField it, String groupSuffix, String idSuffix) '''
        «IF multiple == true && useChecks == true»
            {formcheckboxlist «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay»' repeatColumns=2«IF !entity.container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ELSE»
            {formdropdownlist «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay»' selectionMode='«IF multiple»multiple«ELSE»single«ENDIF»'«IF !entity.container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ENDIF»
    '''

    def private dispatch formField(UserField it, String groupSuffix, String idSuffix) '''
        {«entity.container.application.appName.formatForDB»UserInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter a part of the user name to search' cssClass='«IF mandatory»required«ENDIF»«IF !entity.container.application.targets('1.3.5')»«IF mandatory» «ENDIF»form-control«ENDIF»'}
        {if $mode ne 'create' && $«entity.name.formatForDB».«name.formatForDB» && !$inlineUsage}
            {checkpermissionblock component='Users::' instance='::' level='ACCESS_ADMIN'}
            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»"><a href="{modurl modname='«IF entity.container.application.targets('1.3.5')»Users«ELSE»ZikulaUsersModule«ENDIF»' type='admin' func='modify' userid=$«entity.name.formatForDB».«name.formatForDB»}" title="{gt text='Switch to users administration'}">{gt text='Manage user'}</a></span>
            {/checkpermissionblock}
        {/if}
    '''

    def private dispatch formField(AbstractDateField it, String groupSuffix, String idSuffix) '''
        «formFieldDetails(groupSuffix, idSuffix)»
        «IF past»
            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»">{gt text='Note: this value must be in the past.'}</span>
        «ELSEIF future»
            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»">{gt text='Note: this value must be in the future.'}</span>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(AbstractDateField it, String groupSuffix, String idSuffix) {
    }
    def private dispatch formFieldDetails(DatetimeField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' includeTime=true«validationHelper.fieldValidationCssClass(it, true)»}
        {else}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' includeTime=true«IF defaultValue !== null && defaultValue != '' && defaultValue != 'now'» defaultValue='«defaultValue»'«ELSEIF mandatory || !nullable» defaultValue='now'«ENDIF»«validationHelper.fieldValidationCssClass(it, true)»}
        {/if}
        «/*TODO: visible=false*/»
        «IF !mandatory && nullable»
            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="«IF entity.container.application.targets('1.3.5')»z-«ENDIF»hide">{gt text='Reset to empty value'}</a></span>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(DateField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' useSelectionMode=true«validationHelper.fieldValidationCssClass(it, true)»}
        {else}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' useSelectionMode=true«IF defaultValue !== null && defaultValue != '' && defaultValue != 'now'» defaultValue='«defaultValue»'«ELSEIF mandatory || !nullable» defaultValue='today'«ENDIF»«validationHelper.fieldValidationCssClass(it, true)»}
        {/if}
        «IF !mandatory && nullable»
            <span class="«IF entity.container.application.targets('1.3.5')»z-formnote«ELSE»help-block«ENDIF»"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="«IF entity.container.application.targets('1.3.5')»z-«ENDIF»hide">{gt text='Reset to empty value'}</a></span>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(TimeField it, String groupSuffix, String idSuffix) '''
        {* TODO: support time fields in Zikula (see https://github.com/Guite/MostGenerator/issues/87 for more information) *}
        {formtextinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline' maxLength=8«validationHelper.fieldValidationCssClass(it, true)»}
    '''
}
