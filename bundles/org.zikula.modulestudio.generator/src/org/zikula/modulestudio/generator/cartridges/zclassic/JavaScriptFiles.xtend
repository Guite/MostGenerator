package org.zikula.modulestudio.generator.cartridges.zclassic

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.AutoCompletion
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.BacklinkIntegrator
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.ConfigFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.DisplayFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.EditFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Finder
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.GeoFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.HistoryFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.InlineEditing
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.RawPageFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.TreeFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Validation
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class JavaScriptFiles {

    extension ControllerExtensions = new ControllerExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    /**
     * Entry point for generating JavaScript files.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (hasImageFields || hasLoggable) {
            new ConfigFunctions().generate(it, fsa)
        }
        new DisplayFunctions().generate(it, fsa)
        if (hasEditActions || needsConfig) {
            new EditFunctions().generate(it, fsa)
        }
        if (needsInlineEditing) {
            new InlineEditing().generate(it, fsa)
        }
        if (needsAutoCompletion) {
            new AutoCompletion().generate(it, fsa)
        }
        if (generateExternalControllerAndFinder) {
            new Finder().generate(it, fsa)
        }
        if (hasGeographical) {
            new GeoFunctions().generate(it, fsa)
        }
        if (hasLoggable) {
            new HistoryFunctions().generate(it, fsa)
        }
        if (hasTrees) {
            new TreeFunctions().generate(it, fsa)
        }
        new Validation().generate(it, fsa)
        if (generatePoweredByBacklinksIntoFooterTemplates) {
            new BacklinkIntegrator().generate(it, fsa)
        }
        new RawPageFunctions().generate(it, fsa)
    }
}
