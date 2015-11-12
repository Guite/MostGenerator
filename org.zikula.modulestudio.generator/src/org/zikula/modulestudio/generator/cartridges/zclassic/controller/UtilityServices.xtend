package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ControllerUtil
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.HookHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.Image
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ListEntries
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ModelUtil
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.Translatable
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ViewUtil
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.WorkflowUtil
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
        new ModelUtil().generate(it, fsa)
        new ControllerUtil().generate(it, fsa)
        new ViewUtil().generate(it, fsa)
        new WorkflowUtil().generate(it, fsa)

        if (hasUploads) {
            new Image().generate(it, fsa)
        }
        if (hasListFields) {
            new ListEntries().generate(it, fsa)
        }
        if (hasTranslatable) {
            new Translatable().generate(it, fsa)
        }

        if (!targets('1.3.x')) {
            new HookHelper().generate(it, fsa)
        }
    }
}
