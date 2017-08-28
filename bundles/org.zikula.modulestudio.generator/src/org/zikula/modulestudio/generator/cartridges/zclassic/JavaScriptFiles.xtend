package org.zikula.modulestudio.generator.cartridges.zclassic

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.AutoCompletion
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.ConfigFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.DisplayFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.EditFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Finder
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.GeoFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.HistoryFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.InlineEditing
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.ItemSelector
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions

class JavaScriptFiles {

    extension ControllerExtensions = new ControllerExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelExtensions = new ModelExtensions

    /**
     * Entry point for generating JavaScript files.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (hasImageFields) {
            new ConfigFunctions().generate(it, fsa)
        }
        new DisplayFunctions().generate(it, fsa)
        if (hasEditActions) {
            new EditFunctions().generate(it, fsa)
        }
        if (needsAutoCompletion) {
            new InlineEditing().generate(it, fsa)
            new AutoCompletion().generate(it, fsa)
        }
        if (generateExternalControllerAndFinder) {
            new Finder().generate(it, fsa)
        }
        val needsDetailContentType = generateDetailContentType && hasDisplayActions
        if (needsDetailContentType) {
            new ItemSelector().generate(it, fsa)
        }
        if (hasGeographical) {
            new GeoFunctions().generate(it, fsa)
        }
        if (hasLoggable) {
            new HistoryFunctions().generate(it, fsa)
        }
    }
}
