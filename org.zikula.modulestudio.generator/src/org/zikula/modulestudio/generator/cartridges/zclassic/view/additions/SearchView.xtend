package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SearchView {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) 'search' else 'Search') + '/'
        if (!shouldBeSkipped(templatePath + 'options.tpl')) {
            fsa.generateFile(templatePath + 'options.tpl', optionsTemplate)
        }
    }

    def private optionsTemplate(Application it) '''
        {* Purpose of this template: Display search options *}
        <input type="hidden" id="«appName.toFirstLower»Active" name="active[«appName»]" value="1" checked="checked" />
        «val appLower = appName.toFirstLower»
        «FOR entity : getAllEntities.filter[hasAbstractStringFieldsEntity]»
            «val nameMulti = entity.nameMultiple.formatForCodeCapital»
            <div>
                <input type="checkbox" id="«appLower»«nameMulti»" name="«appLower»SearchTypes[]" value="«entity.name.formatForCode»"{if $active_«entity.name.formatForCode»} checked="checked"{/if} />
                <label for="active_«appLower»«nameMulti»">{gt text='«entity.nameMultiple.formatForDisplayCapital»' domain='module_«appLower.formatForDB»'}</label>
            </div>
        «ENDFOR»
    '''
}
