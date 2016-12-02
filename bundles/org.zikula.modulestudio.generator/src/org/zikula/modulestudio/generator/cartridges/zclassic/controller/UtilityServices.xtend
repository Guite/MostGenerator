package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.FeatureActivationHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.HookHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ImageHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ListEntriesHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ModelHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.TranslatableHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ViewHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.WorkflowHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Entry point for the utility service class creation.
 */
class UtilityServices {

    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        new ModelHelper().generate(it, fsa)
        new ControllerHelper().generate(it, fsa)
        new ViewHelper().generate(it, fsa)
        new WorkflowHelper().generate(it, fsa)

        if (!targets('1.3.x') && needsFeatureActivationHelper) {
            new FeatureActivationHelper().generate(it, fsa)
        }
        if (hasUploads) {
            new ImageHelper().generate(it, fsa)
        }
        if (hasListFields) {
            new ListEntriesHelper().generate(it, fsa)
        }
        if (hasTranslatable) {
            new TranslatableHelper().generate(it, fsa)
        }

        new HookHelper().generate(it, fsa)
    }
}
