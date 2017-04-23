package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ArchiveHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.CategoryHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ControllerHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.FeatureActivationHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.HookHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ImageHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ListEntriesHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ModelHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.NotificationHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.SearchHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.TranslatableHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.UploadHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.ViewHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper.WorkflowHelper;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Entry point for the utility service class creation.
 */
@SuppressWarnings("all")
public class HelperServices {
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _hasAutomaticArchiving = this._modelBehaviourExtensions.hasAutomaticArchiving(it);
    if (_hasAutomaticArchiving) {
      new ArchiveHelper().generate(it, fsa);
    }
    boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
    if (_hasCategorisableEntities) {
      new CategoryHelper().generate(it, fsa);
    }
    new ControllerHelper().generate(it, fsa);
    boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
    if (_needsFeatureActivationHelper) {
      new FeatureActivationHelper().generate(it, fsa);
    }
    boolean _hasUploads = this._modelExtensions.hasUploads(it);
    if (_hasUploads) {
      new ImageHelper().generate(it, fsa);
      new UploadHelper().generate(it, fsa);
    }
    boolean _hasListFields = this._modelExtensions.hasListFields(it);
    if (_hasListFields) {
      new ListEntriesHelper().generate(it, fsa);
    }
    new HookHelper().generate(it, fsa);
    new ModelHelper().generate(it, fsa);
    boolean _needsApproval = this._workflowExtensions.needsApproval(it);
    if (_needsApproval) {
      new NotificationHelper().generate(it, fsa);
    }
    if ((this._generatorSettingsExtensions.generateSearchApi(it) && (!IterableExtensions.isEmpty(IterableExtensions.<DataObject>filter(it.getEntities(), ((Function1<DataObject, Boolean>) (DataObject it_1) -> {
      return Boolean.valueOf(this._modelExtensions.hasAbstractStringFieldsEntity(it_1));
    })))))) {
      new SearchHelper().generate(it, fsa);
    }
    boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
    if (_hasTranslatable) {
      new TranslatableHelper().generate(it, fsa);
    }
    new ViewHelper().generate(it, fsa);
    new WorkflowHelper().generate(it, fsa);
  }
}
