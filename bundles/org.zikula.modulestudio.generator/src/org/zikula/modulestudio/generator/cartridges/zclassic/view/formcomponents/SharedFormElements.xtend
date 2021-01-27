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
        {% if «formElemAccessor(subElem)» is defined %}
            «fieldFormRowImpl(subElem)»
        {% endif %}
    '''

    def fieldFormRowImpl(DerivedField it, String subElem) '''
        «IF !visible»
            <div class="«IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»">
                «formRow(it, subElem)»
            </div>
        «ELSE»
            «formRow(it, subElem)»
        «ENDIF»
    '''

    def private formRow(Field it, String subElem) '''
        {{ form_row(«formElemAccessor(subElem)») }}
    '''

    def private formElemAccessor(Field it, String subElem) {
        if (!subElem.empty) {
            return '''attribute(«subElem», '«name.formatForCode»')'''
        } else {
            return '''form.«name.formatForCode»'''
        }
    }

    def jsDefinition(Field it) {
        val containerName = if (null !== entity) entity.name.formatForCode.toLowerCase else 'appsettings'
        switch it {
            UserField: jsDefinitionUser(containerName)
            DatetimeField: jsDefinitionCalendar(containerName)
            UploadField: jsDefinitionUpload(containerName)
        }
    }

    def private jsDefinitionUser(UserField it, String containerName) '''
        <div class="field-editing-definition" data-field-type="user" data-field-name="«application.appName.toLowerCase»_«containerName»_«name.formatForCode»"></div>
    '''

    def private jsDefinitionCalendar(DatetimeField it, String containerName) '''
        «IF !mandatory»
            <div class="field-editing-definition" data-field-type="date" data-field-name="«application.appName.toLowerCase»_«containerName»_«name.formatForCode»"></div>
        «ENDIF»
    '''

    def private jsDefinitionUpload(UploadField it, String containerName) '''
        <div class="field-editing-definition" data-field-type="upload" data-field-name="«application.appName.toLowerCase»_«containerName»_«name.formatForCode»_«name.formatForCode»"></div>
    '''
}
