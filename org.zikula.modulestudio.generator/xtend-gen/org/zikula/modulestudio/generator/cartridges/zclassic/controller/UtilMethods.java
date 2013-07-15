package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ControllerUtil;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.Image;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ListEntries;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ModelUtil;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.Translatable;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.ViewUtil;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.util.WorkflowUtil;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * Entry point for the Util class creation.
 */
@SuppressWarnings("all")
public class UtilMethods {
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    ModelUtil _modelUtil = new ModelUtil();
    _modelUtil.generate(it, fsa);
    ControllerUtil _controllerUtil = new ControllerUtil();
    _controllerUtil.generate(it, fsa);
    ViewUtil _viewUtil = new ViewUtil();
    _viewUtil.generate(it, fsa);
    WorkflowUtil _workflowUtil = new WorkflowUtil();
    _workflowUtil.generate(it, fsa);
    boolean _hasUploads = this._modelExtensions.hasUploads(it);
    if (_hasUploads) {
      Image _image = new Image();
      _image.generate(it, fsa);
    }
    boolean _hasListFields = this._modelExtensions.hasListFields(it);
    if (_hasListFields) {
      ListEntries _listEntries = new ListEntries();
      _listEntries.generate(it, fsa);
    }
    boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
    if (_hasTranslatable) {
      Translatable _translatable = new Translatable();
      _translatable.generate(it, fsa);
    }
  }
}
