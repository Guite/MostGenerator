package org.zikula.modulestudio.generator.cartridges.symfony.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.CollectionFilterHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.EntityDisplayHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.ExpiryHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.FeatureActivationHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.ImageHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.ListEntriesHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.LoggableHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.ModelHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.NotificationHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.PermissionHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.SlugTransliterator
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.TranslatableHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.UploadHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.ViewHelper
import org.zikula.modulestudio.generator.cartridges.symfony.controller.helper.WorkflowHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

/**
 * Entry point for the utility service class creation.
 */
class HelperServices {

    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        new PermissionHelper().generate(it, fsa)
        if (hasAutomaticExpiryHandling || hasLoggable) {
            new ExpiryHelper().generate(it, fsa)
        }
        new CollectionFilterHelper().generate(it, fsa)
        new ControllerHelper().generate(it, fsa)
        new EntityDisplayHelper().generate(it, fsa)
        if (needsFeatureActivationHelper) {
            new FeatureActivationHelper().generate(it, fsa)
        }
        if (hasUploads) {
            new ImageHelper().generate(it, fsa)
            new UploadHelper().generate(it, fsa)
        }
        if (hasListFields) {
            new ListEntriesHelper().generate(it, fsa)
        }
        if (hasLoggable) {
            new LoggableHelper().generate(it, fsa)
        }
        new ModelHelper().generate(it, fsa)
        if (needsApproval) {
            new NotificationHelper().generate(it, fsa)
        }
        if (hasSluggable) {
            new SlugTransliterator().generate(it, fsa)
        }
        if (hasTranslatable) {
            new TranslatableHelper().generate(it, fsa)
        }
        new ViewHelper().generate(it, fsa)
        new WorkflowHelper().generate(it, fsa)
    }
}
