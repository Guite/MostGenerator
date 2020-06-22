package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.CategoryHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.CollectionFilterHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.EntityDisplayHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ExampleDataHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ExpiryHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.FeatureActivationHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.HookHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ImageHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ListEntriesHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.LoggableHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ModelHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.NotificationHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.PermissionHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.SearchHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.SlugTransliterator
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.TranslatableHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.UploadHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ViewHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.WorkflowHelper
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
        if (hasAutomaticExpiryHandling) {
            new ExpiryHelper().generate(it, fsa)
        }
        if (hasCategorisableEntities) {
            new CategoryHelper().generate(it, fsa)
        }
        new CollectionFilterHelper().generate(it, fsa)
        new ControllerHelper().generate(it, fsa)
        new EntityDisplayHelper().generate(it, fsa)
        if (amountOfExampleRows > 0) {
            new ExampleDataHelper().generate(it, fsa)
        }
        if (needsFeatureActivationHelper) {
            new FeatureActivationHelper().generate(it, fsa)
        }
        new HookHelper().generate(it, fsa)
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
        if (generateSearchApi && !entities.filter[hasAbstractStringFieldsEntity].empty) {
            new SearchHelper().generate(it, fsa)
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
