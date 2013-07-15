package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ActionUrl;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatGeoData;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetCountryName;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetFileSize;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetListEntry;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ModerationObjects;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectState;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectTypeSelector;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateHeaders;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateSelector;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeJS;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeSelection;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ValidationError;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.AbstractObjectSelector;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ColourInput;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.CountrySelector;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.Frame;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.GeoInput;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ItemSelector;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.RelationSelectorAutoComplete;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.RelationSelectorList;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.TreeSelector;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.UserInput;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Plugins {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
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
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  @Inject
  @Extension
  private WorkflowExtensions _workflowExtensions = new Function0<WorkflowExtensions>() {
    public WorkflowExtensions apply() {
      WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
      return _workflowExtensions;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.viewPlugins(it, fsa);
    boolean _or = false;
    boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
    if (_hasEditActions) {
      _or = true;
    } else {
      boolean _needsConfig = this._utils.needsConfig(it);
      _or = (_hasEditActions || _needsConfig);
    }
    if (_or) {
      Frame _frame = new Frame();
      _frame.generate(it, fsa);
    }
    boolean _hasEditActions_1 = this._controllerExtensions.hasEditActions(it);
    if (_hasEditActions_1) {
      this.editPlugins(it, fsa);
      ValidationError _validationError = new ValidationError();
      _validationError.generate(it, fsa);
    }
    this.otherPlugins(it, fsa);
  }
  
  private void viewPlugins(final Application it, final IFileSystemAccess fsa) {
    ActionUrl _actionUrl = new ActionUrl();
    _actionUrl.generate(it, fsa);
    ObjectState _objectState = new ObjectState();
    _objectState.generate(it, fsa);
    TemplateHeaders _templateHeaders = new TemplateHeaders();
    _templateHeaders.generate(it, fsa);
    boolean _hasCountryFields = this._modelExtensions.hasCountryFields(it);
    if (_hasCountryFields) {
      GetCountryName _getCountryName = new GetCountryName();
      _getCountryName.generate(it, fsa);
    }
    boolean _hasUploads = this._modelExtensions.hasUploads(it);
    if (_hasUploads) {
      GetFileSize _getFileSize = new GetFileSize();
      _getFileSize.generate(it, fsa);
    }
    boolean _hasListFields = this._modelExtensions.hasListFields(it);
    if (_hasListFields) {
      GetListEntry _getListEntry = new GetListEntry();
      _getListEntry.generate(it, fsa);
    }
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          boolean _isGeographical = e.isGeographical();
          return Boolean.valueOf(_isGeographical);
        }
      };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    if (_exists) {
      FormatGeoData _formatGeoData = new FormatGeoData();
      _formatGeoData.generate(it, fsa);
    }
    boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
    if (_hasTrees) {
      TreeJS _treeJS = new TreeJS();
      _treeJS.generate(it, fsa);
      TreeSelection _treeSelection = new TreeSelection();
      _treeSelection.generate(it, fsa);
    }
    boolean _needsApproval = this._workflowExtensions.needsApproval(it);
    if (_needsApproval) {
      ModerationObjects _moderationObjects = new ModerationObjects();
      _moderationObjects.generate(it, fsa);
    }
  }
  
  private void editPlugins(final Application it, final IFileSystemAccess fsa) {
    boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
    if (_hasColourFields) {
      ColourInput _colourInput = new ColourInput();
      _colourInput.generate(it, fsa);
    }
    boolean _hasCountryFields = this._modelExtensions.hasCountryFields(it);
    if (_hasCountryFields) {
      CountrySelector _countrySelector = new CountrySelector();
      _countrySelector.generate(it, fsa);
    }
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          boolean _isGeographical = e.isGeographical();
          return Boolean.valueOf(_isGeographical);
        }
      };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    if (_exists) {
      GeoInput _geoInput = new GeoInput();
      _geoInput.generate(it, fsa);
    }
    EList<Models> _models = it.getModels();
    final Function1<Models,EList<Relationship>> _function_1 = new Function1<Models,EList<Relationship>>() {
        public EList<Relationship> apply(final Models e) {
          EList<Relationship> _relations = e.getRelations();
          return _relations;
        }
      };
    List<EList<Relationship>> _map = ListExtensions.<Models, EList<Relationship>>map(_models, _function_1);
    Iterable<Relationship> _flatten = Iterables.<Relationship>concat(_map);
    List<Relationship> _list = IterableExtensions.<Relationship>toList(_flatten);
    boolean _isEmpty = _list.isEmpty();
    final boolean hasRelations = (!_isEmpty);
    boolean _or = false;
    boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
    if (_hasTrees) {
      _or = true;
    } else {
      _or = (_hasTrees || hasRelations);
    }
    if (_or) {
      AbstractObjectSelector _abstractObjectSelector = new AbstractObjectSelector();
      _abstractObjectSelector.generate(it, fsa);
    }
    boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
    if (_hasTrees_1) {
      TreeSelector _treeSelector = new TreeSelector();
      _treeSelector.generate(it, fsa);
    }
    EList<Models> _models_1 = it.getModels();
    final Function1<Models,EList<Relationship>> _function_2 = new Function1<Models,EList<Relationship>>() {
        public EList<Relationship> apply(final Models e) {
          EList<Relationship> _relations = e.getRelations();
          return _relations;
        }
      };
    List<EList<Relationship>> _map_1 = ListExtensions.<Models, EList<Relationship>>map(_models_1, _function_2);
    Iterable<Relationship> _flatten_1 = Iterables.<Relationship>concat(_map_1);
    List<Relationship> _list_1 = IterableExtensions.<Relationship>toList(_flatten_1);
    boolean _isEmpty_1 = _list_1.isEmpty();
    boolean _not = (!_isEmpty_1);
    if (_not) {
      RelationSelectorList _relationSelectorList = new RelationSelectorList();
      _relationSelectorList.generate(it, fsa);
      RelationSelectorAutoComplete _relationSelectorAutoComplete = new RelationSelectorAutoComplete();
      _relationSelectorAutoComplete.generate(it, fsa);
    }
    boolean _hasUserFields = this._modelExtensions.hasUserFields(it);
    if (_hasUserFields) {
      UserInput _userInput = new UserInput();
      _userInput.generate(it, fsa);
    }
  }
  
  private void otherPlugins(final Application it, final IFileSystemAccess fsa) {
    ItemSelector _itemSelector = new ItemSelector();
    _itemSelector.generate(it, fsa);
    ObjectTypeSelector _objectTypeSelector = new ObjectTypeSelector();
    _objectTypeSelector.generate(it, fsa);
    TemplateSelector _templateSelector = new TemplateSelector();
    _templateSelector.generate(it, fsa);
  }
}
