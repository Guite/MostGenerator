package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.FeatureActivationHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.HookHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ImageHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ListEntriesHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ModelHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.TranslatableHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ViewHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.WorkflowHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

/**
 * Entry point for the utility service class creation.
 */
class HelperServices {

    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        new ModelHelper().generate(it, fsa)
        new ControllerHelper().generate(it, fsa)
        new ViewHelper().generate(it, fsa)
        new WorkflowHelper().generate(it, fsa)

        if (needsFeatureActivationHelper) {
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
