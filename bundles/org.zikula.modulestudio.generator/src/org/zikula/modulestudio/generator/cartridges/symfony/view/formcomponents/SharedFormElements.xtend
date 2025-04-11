package org.zikula.modulestudio.generator.cartridges.symfony.view.formcomponents

import de.guite.modulestudio.metamodel.DatetimeField
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

    def fieldFormRow(Field it, String subElem) '''
        {% if «formElemAccessor(subElem)» is defined %}
            «fieldFormRowImpl(subElem)»
        {% endif %}
    '''

    def fieldFormRowImpl(Field it, String subElem) '''
        «IF !visibleOnNew || !visibleOnEdit»
            <div class="«IF !visibleOnNew && !visibleOnEdit»d-none«ELSEIF visibleOnNew»{{ mode == 'create' ? '' : 'd-none' }}«ELSEIF visibleOnEdit»{{ mode != 'create' ? '' : 'd-none' }}«ENDIF»">
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
        val containerName = entity.name.formatForCode.toLowerCase
        switch it {
            UserField: jsDefinitionUser(containerName)
            DatetimeField: jsDefinitionCalendar(containerName)
            UploadField: jsDefinitionUpload(containerName)
        }
    }

    def private jsDefinitionUser(UserField it, String containerName) '''
        {% if form.«name.formatForCode» is defined %}
            <div class="field-editing-definition" data-field-type="user" data-field-name="«application.appName.toLowerCase»_«containerName»_«name.formatForCode»"></div>
        {% endif %}
    '''

    def private jsDefinitionCalendar(DatetimeField it, String containerName) '''
        «IF !mandatory»
            {% if form.«name.formatForCode» is defined %}
                <div class="field-editing-definition" data-field-type="date" data-field-name="«application.appName.toLowerCase»_«containerName»_«name.formatForCode»"></div>
            {% endif %}
        «ENDIF»
    '''

    def private jsDefinitionUpload(UploadField it, String containerName) '''
        {% if form.«name.formatForCode» is defined %}
            <div class="field-editing-definition" data-field-type="upload" data-field-name="«application.appName.toLowerCase»_«containerName»_«name.formatForCode»_«name.formatForCode»"></div>
        {% endif %}
    '''
}
