package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.EntityField
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import java.math.BigInteger
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleFields {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Validation validationHelper = new Validation

    def formRow(DerivedField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            «formLabel(groupSuffix, idSuffix)»
        «ENDIF»
        «formField(groupSuffix, idSuffix)»
        «IF isLegacyApp»
            «validationHelper.mandatoryValidationMessage(it, idSuffix)»
            «validationHelper.additionalValidationMessages(it, idSuffix)»
        «ENDIF»
    '''

    // 1.3.x only
    def private dispatch formLabel(DerivedField it, String groupSuffix, String idSuffix) '''
        «initDocumentationToolTip»
        {formlabel for=«templateIdWithSuffix(name.formatForCode, idSuffix)» __text='«formLabelText»'«IF mandatory» mandatorysym='1'«ENDIF»«formLabelAdditions»}
    '''

    // 1.3.x only
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

    // 1.3.x only
    def private initDocumentationToolTip(DerivedField it) '''
        «IF documentation !== null && documentation != ''»
            {gt text='«documentation.replace("'", '"')»' assign='toolTip'}
        «ENDIF»
    '''

    // 1.3.x only
    def private formLabelAdditions(DerivedField it) ''' cssClass='«IF documentation !== null && documentation != ''»«entity.application.appName.toLowerCase»-form-tooltips«ENDIF»'«IF documentation !== null && documentation != ''» title=$toolTip«ENDIF»'''

    // 1.3.x only
    def private formLabelText(DerivedField it) {
        name.formatForDisplayCapital
    }

    // 1.3.x only
    def private groupAndId(EntityField it, String groupSuffix, String idSuffix) '''group=«templateIdWithSuffix(entity.name.formatForDB, groupSuffix)» id=«templateIdWithSuffix(name.formatForCode, idSuffix)»'''

    // 1.4.x only
    def private fieldRow(EntityField it, String groupSuffix, String idSuffix) '''{{ form_row(form.«IF groupSuffix != ''»«groupSuffix».«ENDIF»«name.formatForCode»«idSuffix») }}'''

    def private dispatch formField(BooleanField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            {formcheckbox «groupAndId(groupSuffix, idSuffix)» readOnly=«readonly.displayBool» __title='«name.formatForDisplay» ?'«validationHelper.fieldValidationCssClass(it)»}
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(IntegerField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            {formintinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' maxLength=«length»«IF minValue.toString != '0'» minValue=«minValue»«ENDIF»«IF maxValue.toString != '0'» maxValue=«maxValue»«ENDIF»«validationHelper.fieldValidationCssClass(it)»}
            «val hasMin = minValue.compareTo(BigInteger.valueOf(0)) > 0»
            «val hasMax = maxValue.compareTo(BigInteger.valueOf(0)) > 0»
            «IF hasMin || hasMax»
                «IF hasMin && hasMax»
                    «IF minValue == maxValue»
                        <span class="z-formnote">{gt text='Note: this value must exactly be %s.' tag1='«minValue»'}</span>
                    «ELSE»
                        <span class="z-formnote">{gt text='Note: this value must be between %1$s and %2$s.' tag1='«minValue»' tag2='«maxValue»'}</span>
                    «ENDIF»
                «ELSEIF hasMin»
                    <span class="z-formnote">{gt text='Note: this value must be greater than %s.' tag1='«minValue»'}</span>
                «ELSEIF hasMax»
                    <span class="z-formnote">{gt text='Note: this value must be less than %s.' tag1='«maxValue»'}</span>
                «ENDIF»
            «ENDIF»
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(DecimalField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            {formfloatinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF minValue != 0 && minValue.toString != '0.0' && minValue.toString() != '0.00'» minValue=«minValue»«ENDIF»«IF maxValue != 0 && maxValue.toString() != '0.0' && maxValue.toString() != '0.00'» maxValue=«maxValue»«ENDIF» maxLength=«(length+3+scale)»«IF scale != 2» precision=«scale»«ENDIF»«validationHelper.fieldValidationCssClass(it)»}
            «val hasMin = minValue > 0»
            «val hasMax = maxValue > 0»
            «IF hasMin || hasMax»
                «IF hasMin && hasMax»
                    «IF minValue == maxValue»
                        <span class="z-formnote">{gt text='Note: this value must exactly be %s.' tag1='«minValue»'}</span>
                    «ELSE»
                        <span class="z-formnote">{gt text='Note: this value must be between %1$s and %2$s.' tag1='«minValue»' tag2='«maxValue»'}</span>
                    «ENDIF»
                «ELSEIF hasMin»
                    <span class="z-formnote">{gt text='Note: this value must be greater than %s.' tag1='«minValue»'}</span>
                «ELSEIF hasMax»
                    <span class="z-formnote">{gt text='Note: this value must be less than %s.' tag1='«maxValue»'}</span>
                «ENDIF»
            «ENDIF»
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(FloatField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            {formfloatinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF minValue != 0 && minValue.toString != '0.0' && minValue.toString() != '0.00'» minValue=«minValue»«ENDIF»«IF maxValue != 0 && maxValue.toString() != '0.0' && maxValue.toString() != '0.00'» maxValue=«maxValue»«ENDIF»«validationHelper.fieldValidationCssClass(it)»}
            «val hasMin = minValue > 0»
            «val hasMax = maxValue > 0»
            «IF hasMin || hasMax»
                «IF hasMin && hasMax»
                    «IF minValue == maxValue»
                        <span class="z-formnote">{gt text='Note: this value must exactly be %s.' tag1='«minValue»'}</span>
                    «ELSE»
                        <span class="z-formnote">{gt text='Note: this value must be between %1$s and %2$s.' tag1='«minValue»' tag2='«maxValue»'}</span>
                    «ENDIF»
                «ELSEIF hasMin»
                    <span class="z-formnote">{gt text='Note: this value must be greater than %s.' tag1='«minValue»'}</span>
                «ELSEIF hasMax»
                    <span class="z-formnote">{gt text='Note: this value must be less than %s.' tag1='«maxValue»'}</span>
                «ENDIF»
            «ENDIF»
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(StringField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            «IF country»
                {«entity.application.appName.formatForDB»CountrySelector «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'}
            «ELSEIF language || locale»
                {formlanguageselector «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool»«IF mandatory» addAllOption=false«ENDIF» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'}
            «ELSEIF htmlcolour»
                {«entity.application.appName.formatForDB»ColourInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«validationHelper.fieldValidationCssClass(it)»}
            «ELSE»
                {formtextinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='«IF password»password«ELSE»singleline«ENDIF»'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it)»}
            «ENDIF»
            «IF regexp !== null && regexp != ''»
                <span class="z-formnote">{gt text='Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%s".' tag1='«regexp.replace('\'', '')»'}</span>
            «ENDIF»
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(TextField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            {formtextinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='multiline'«IF minLength > 0» minLength=«minLength»«ENDIF» rows='6«/*8*/»' cols='50'«validationHelper.fieldValidationCssClass(it)»}
            «IF regexp !== null && regexp != ''»
                <span class="z-formnote">{gt text='Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%s".' tag1='«regexp.replace('\'', '')»'}</span>
            «ENDIF»
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(EmailField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            {formemailinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it)»}
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(UrlField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            {formurlinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline'«IF minLength > 0» minLength=«minLength»«ENDIF» maxLength=«length»«validationHelper.fieldValidationCssClass(it)»}
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(UploadField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            «IF mandatory»
                {if $mode eq 'create'}
                    {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClass(it)»}
                {else}
                    {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=false readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClassOptional(it)»}
                    <span class="z-formnote z-sub"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="z-hide">{gt text='Reset to empty value'}</a></span>
                {/if}
            «ELSE»
                {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=false readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClassOptional(it)»}
                <span class="z-formnote z-sub"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="z-hide" style="clear:left;">{gt text='Reset to empty value'}</a></span>
            «ENDIF»

                <span class="z-formnote">{gt text='Allowed file extensions:'} <span id="«name.formatForCode»FileExtensions">«allowedExtensions»</span></span>
            «IF allowedFileSize > 0»
                <span class="z-formnote">{gt text='Allowed file size:'} {'«allowedFileSize»'|«entity.application.appName.formatForDB»GetFileSize:'':false:false}</span>
            «ENDIF»
            «decideWhetherToShowCurrentFile»
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    // 1.3.x only
    def private decideWhetherToShowCurrentFile(UploadField it) '''
        «val fieldName = entity.name.formatForDB + '.' + name.formatForCode»
        {if $mode ne 'create' && $«fieldName» ne ''}
            «showCurrentFile»
        {/if}
    '''

    // 1.3.x only
    def private showCurrentFile(UploadField it) '''
        «val appNameSmall = entity.application.appName.formatForDB»
        «val objName = entity.name.formatForDB»
        «val realName = objName + '.' + name.formatForCode»
        <span class="z-formnote">
            {gt text='Current file'}:
            <a href="{$«realName»FullPathUrl}" title="{$formattedEntityTitle|replace:"\"":""}"{if $«realName»Meta.isImage} rel="imageviewer[«entity.name.formatForDB»]"{/if}>
            {if $«realName»Meta.isImage}
                {thumb image=$«realName»FullPath objectid="«entity.name.formatForCode»«IF entity.hasCompositeKeys»«FOR pkField : entity.getPrimaryKeyFields»-`$«objName».«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$«objName».«entity.primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$«entity.name.formatForCode»ThumbPreset«name.formatForCodeCapital» tag=true img_alt=$formattedEntityTitle}
            {else}
                {gt text='Download'} ({$«realName»Meta.size|«appNameSmall»GetFileSize:$«realName»FullPath:false:false})
            {/if}
            </a>
        </span>
        «IF !mandatory»
            <span class="z-formnote">
                {formcheckbox group='«entity.name.formatForDB»' id='«name.formatForCode»DeleteFile' readOnly=false __title='Delete «name.formatForDisplay» ?'}
                {formlabel for='«name.formatForCode»DeleteFile' __text='Delete existing file'}
            </span>
        «ENDIF»
    '''

    def private dispatch formField(ListField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            «IF multiple == true && useChecks == true»
                {formcheckboxlist «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay»' repeatColumns=2}
            «ELSE»
                {formdropdownlist «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Choose the «name.formatForDisplay»' selectionMode='«IF multiple»multiple«ELSE»single«ENDIF»'}
            «ENDIF»
            «IF multiple && min > 0 && max > 0»
                «IF min == max»
                    <span class="z-formnote">{gt text='Note: you must select exactly %s choices.' tag1='«min»'}</span>
                «ELSE»
                    <span class="z-formnote">{gt text='Note: you must select between %1$s and %2$s choices.' tag1='«min»' tag2='«max»'}</span>
                «ENDIF»
            «ENDIF»
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(UserField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            {«entity.application.appName.formatForDB»UserInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter a part of the user name to search'«IF mandatory» cssClass='required'«ENDIF»}
            {if $mode ne 'create' && $«entity.name.formatForDB».«name.formatForDB» && !$inlineUsage}
                <span class="z-formnote avatar">
                    {useravatar uid=$«entity.name.formatForDB».«name.formatForDB» rating='g'}
                </span>
                {checkpermissionblock component='Users::' instance='::' level='ACCESS_ADMIN'}
                <span class="z-formnote"><a href="{modurl modname='Users' type='admin' func='modify' userid=$«entity.name.formatForDB».«name.formatForDB»}" title="{gt text='Switch to users administration'}">{gt text='Manage user'}</a></span>
                {/checkpermissionblock}
            {/if}
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private dispatch formField(AbstractDateField it, String groupSuffix, String idSuffix) '''
        «IF isLegacyApp»
            «formFieldDetails(groupSuffix, idSuffix)»
            «IF past»
                <span class="z-formnote">{gt text='Note: this value must be in the past.'}</span>
            «ELSEIF future»
                <span class="z-formnote">{gt text='Note: this value must be in the future.'}</span>
            «ENDIF»
        «ELSE»
            «fieldRow(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    // 1.3.x only
    def private dispatch formFieldDetails(AbstractDateField it, String groupSuffix, String idSuffix) {
    }
    def private dispatch formFieldDetails(DatetimeField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' includeTime=true«validationHelper.fieldValidationCssClass(it)»}
        {else}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' includeTime=true«IF defaultValue !== null && defaultValue != '' && defaultValue != 'now'» defaultValue='«defaultValue»'«ELSEIF mandatory || !nullable» defaultValue='now'«ENDIF»«validationHelper.fieldValidationCssClass(it)»}
        {/if}
        «IF !mandatory && nullable»
            <span class="z-formnote z-sub"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="z-hide">{gt text='Reset to empty value'}</a></span>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(DateField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {«entity.application.appName.formatForDB»DateInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«validationHelper.fieldValidationCssClass(it)»}
        {else}
            {«entity.application.appName.formatForDB»DateInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF defaultValue !== null && defaultValue != '' && defaultValue != 'now'» defaultValue='«defaultValue»'«ELSEIF mandatory || !nullable» defaultValue='today'«ENDIF»«validationHelper.fieldValidationCssClass(it)»}
        {/if}
        «IF !mandatory && nullable»
            <span class="z-formnote z-sub"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="z-hide">{gt text='Reset to empty value'}</a></span>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(TimeField it, String groupSuffix, String idSuffix) '''
        {«entity.application.appName.formatForDB»TimeInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline' maxLength=8«validationHelper.fieldValidationCssClass(it)»}
    '''

    def private isLegacyApp(DerivedField it) {
        entity.application.targets('1.3.x')
    }
}
