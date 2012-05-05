package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ModelUtil
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ControllerUtil
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ViewUtil
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.Image
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ListEntries
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.Translatable
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions

/**
 * Entry point for the Util class creation.
 */
class UtilMethods {
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()

    def generate(Application it, IFileSystemAccess fsa) {
        new ModelUtil().generate(it, fsa)
        new ControllerUtil().generate(it, fsa)
        new ViewUtil().generate(it, fsa)
        if (hasUploads)
            new Image().generate(it, fsa)
        if (hasListFields)
            new ListEntries().generate(it, fsa)
        if (hasTranslatable)
            new Translatable().generate(it, fsa)
    }
}
