package org.zikula.modulestudio.generator.cartridges.symfony.view.formcomponents

import de.guite.modulestudio.metamodel.Field
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class SharedFormElements {

    extension FormattingExtensions = new FormattingExtensions

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
}
