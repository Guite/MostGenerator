package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SharedFormElements {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def fieldFormRow(DerivedField it, String subElem) '''
        «IF !visible»
            <div class="«IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»">
                «formRow(it, subElem)»
            </div>
        «ELSE»
            «formRow(it, subElem)»
        «ENDIF»
    '''

    def private formRow(Field it, String subElem) '''
        «IF !subElem.empty»
            {{ form_row(attribute(«subElem», '«name.formatForCode»')) }}
        «ELSE»
            {{ form_row(form.«name.formatForCode») }}
        «ENDIF»
    '''

    def additionalInitScript(Field it) {
        switch it {
            UploadField: additionalInitScriptUpload
            UserField: additionalInitScriptUser
            DatetimeField: additionalInitScriptCalendar
        }
    }

    def private additionalInitScriptUpload(UploadField it) '''
        «IF null !== entity»
            «application.vendorAndName»InitUploadField('«application.appName.toLowerCase»_«entity.name.formatForCode.toLowerCase»_«name.formatForCode»_«name.formatForCode»');
        «ELSE»
            «application.vendorAndName»InitUploadField('«application.appName.toLowerCase»_appsettings_«name.formatForCode»_«name.formatForCode»');
        «ENDIF»
    '''

    def private additionalInitScriptUser(UserField it) '''
        «IF null !== entity»
            initUserLiveSearch('«application.appName.toLowerCase»_«entity.name.formatForCode.toLowerCase»_«name.formatForCode»');
        «ELSE»
            initUserLiveSearch('«application.appName.toLowerCase»_appsettings_«name.formatForCode»');
        «ENDIF»
    '''

    def private additionalInitScriptCalendar(DatetimeField it) '''
        «IF !mandatory»
            «IF null !== entity»
                «application.vendorAndName»InitDateField('«application.appName.toLowerCase»_«entity.name.formatForCode.toLowerCase»_«name.formatForCode»');
            «ELSE»
                «application.vendorAndName»InitDateField('«application.appName.toLowerCase»_appsettings_«name.formatForCode»');
            «ENDIF»
        «ENDIF»
    '''

}