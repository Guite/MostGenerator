package org.zikula.modulestudio.generator.extensions.transformation;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.BoolVar;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityIndex;
import de.guite.modulestudio.metamodel.EntityIndexItem;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.IntVar;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.IpAddressScope;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ListFieldItem;
import de.guite.modulestudio.metamodel.ListVar;
import de.guite.modulestudio.metamodel.ListVarItem;
import de.guite.modulestudio.metamodel.ModuleStudioFactory;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextVar;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.Variable;
import de.guite.modulestudio.metamodel.Variables;
import java.util.Collections;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * This class adds primary key fields to all entities of an application.
 */
@SuppressWarnings("all")
public class PersistenceTransformer {
  /**
   * Extension methods for controllers.
   */
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  /**
   * Extension methods for generator settings.
   */
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  /**
   * Extension methods for formatting names.
   */
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  /**
   * Extension methods related to behavioural model extensions.
   */
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  /**
   * Extension methods related to the model layer.
   */
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  /**
   * Transformation entry point consuming the application instance.
   * 
   * @param it The given {@link Application} instance.
   */
  public void modify(final Application it) {
    InputOutput.<String>println("Starting model transformation");
    Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      this.handleEntity(entity);
    }
    this.addWorkflowSettings(it);
    this.addViewSettings(it);
    this.addImageSettings(it);
    this.addIntegrationSettings(it);
    this.addGeoSettings(it);
  }
  
  /**
   * Transformation processing for a single entity.
   * 
   * @param it The currently treated {@link Entity} instance.
   */
  private void handleEntity(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this._modelExtensions.getPrimaryKeyFields(it));
    if (_isEmpty) {
      this.addPrimaryKey(it);
    }
    this.addWorkflowState(it);
    final Function1<UploadField, Boolean> _function = (UploadField f) -> {
      boolean _isMandatory = f.isMandatory();
      return Boolean.valueOf((!_isMandatory));
    };
    Iterable<UploadField> _filter = IterableExtensions.<UploadField>filter(Iterables.<UploadField>filter(it.getFields(), UploadField.class), _function);
    for (final UploadField field : _filter) {
      field.setNullable(true);
    }
    Iterable<StringField> _filter_1 = Iterables.<StringField>filter(it.getFields(), StringField.class);
    for (final StringField field_1 : _filter_1) {
      if ((((((((field_1.isBic() || field_1.isCountry()) || field_1.isCurrency()) || field_1.isLanguage()) || field_1.isLocale()) || (!Objects.equal(field_1.getIpAddress(), IpAddressScope.NONE))) || field_1.isHtmlcolour()) || field_1.isUuid())) {
        field_1.setNospace(true);
      }
    }
  }
  
  /**
   * Adds a primary key to a given entity.
   * 
   * @param entity The given {@link Entity} instance.
   */
  private void addPrimaryKey(final Entity entity) {
    entity.getFields().add(0, this.createIdColumn("", Boolean.valueOf(true)));
  }
  
  /**
   * Creates a new identifier field.
   * 
   * @param colName The column name.
   * @param isPrimary Whether the field should be primary or not.
   * @return IntegerField The created column object.
   */
  private IntegerField createIdColumn(final String colName, final Boolean isPrimary) {
    IntegerField _xblockexpression = null;
    {
      final ModuleStudioFactory factory = ModuleStudioFactory.eINSTANCE;
      IntegerField _createIntegerField = factory.createIntegerField();
      final Procedure1<IntegerField> _function = (IntegerField it) -> {
        String _xifexpression = null;
        if ((isPrimary).booleanValue()) {
          _xifexpression = "id";
        } else {
          String _formatForCode = this._formattingExtensions.formatForCode(colName);
          _xifexpression = (_formatForCode + "_id");
        }
        it.setName(_xifexpression);
        it.setLength(9);
        it.setPrimaryKey((isPrimary).booleanValue());
        it.setUnique((isPrimary).booleanValue());
      };
      final IntegerField idField = ObjectExtensions.<IntegerField>operator_doubleArrow(_createIntegerField, _function);
      _xblockexpression = idField;
    }
    return _xblockexpression;
  }
  
  /**
   * Adds a list field for the workflow state to a given entity.
   * 
   * @param entity The given {@link Entity} instance.
   */
  private boolean addWorkflowState(final Entity entity) {
    boolean _xblockexpression = false;
    {
      final ModuleStudioFactory factory = ModuleStudioFactory.eINSTANCE;
      ListField _createListField = factory.createListField();
      final Procedure1<ListField> _function = (ListField it) -> {
        it.setName("workflowState");
        it.setDocumentation("the current workflow state");
        it.setLength(20);
        it.setDefaultValue("initial");
        it.setMultiple(false);
      };
      final ListField listField = ObjectExtensions.<ListField>operator_doubleArrow(_createListField, _function);
      EList<ListFieldItem> _items = listField.getItems();
      ListFieldItem _createListFieldItem = factory.createListFieldItem();
      final Procedure1<ListFieldItem> _function_1 = (ListFieldItem it) -> {
        it.setName("Initial");
        it.setValue("initial");
        it.setDocumentation("Pseudo-state for content which is just created and not persisted yet.");
        it.setDefault(true);
      };
      ListFieldItem _doubleArrow = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem, _function_1);
      _items.add(_doubleArrow);
      boolean _isOwnerPermission = entity.isOwnerPermission();
      if (_isOwnerPermission) {
        EList<ListFieldItem> _items_1 = listField.getItems();
        ListFieldItem _createListFieldItem_1 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_2 = (ListFieldItem it) -> {
          it.setName("Deferred");
          it.setValue("deferred");
          it.setDocumentation("Content has not been submitted yet or has been waiting, but was rejected.");
        };
        ListFieldItem _doubleArrow_1 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_1, _function_2);
        _items_1.add(_doubleArrow_1);
      }
      EntityWorkflowType _workflow = entity.getWorkflow();
      boolean _notEquals = (!Objects.equal(_workflow, EntityWorkflowType.NONE));
      if (_notEquals) {
        EList<ListFieldItem> _items_2 = listField.getItems();
        ListFieldItem _createListFieldItem_2 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_3 = (ListFieldItem it) -> {
          it.setName("Waiting");
          it.setValue("waiting");
          it.setDocumentation("Content has been submitted and waits for approval.");
        };
        ListFieldItem _doubleArrow_2 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_2, _function_3);
        _items_2.add(_doubleArrow_2);
        EntityWorkflowType _workflow_1 = entity.getWorkflow();
        boolean _equals = Objects.equal(_workflow_1, EntityWorkflowType.ENTERPRISE);
        if (_equals) {
          EList<ListFieldItem> _items_3 = listField.getItems();
          ListFieldItem _createListFieldItem_3 = factory.createListFieldItem();
          final Procedure1<ListFieldItem> _function_4 = (ListFieldItem it) -> {
            it.setName("Accepted");
            it.setValue("accepted");
            it.setDocumentation("Content has been submitted and accepted, but still waits for approval.");
          };
          ListFieldItem _doubleArrow_3 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_3, _function_4);
          _items_3.add(_doubleArrow_3);
        }
      }
      EList<ListFieldItem> _items_4 = listField.getItems();
      ListFieldItem _createListFieldItem_4 = factory.createListFieldItem();
      final Procedure1<ListFieldItem> _function_5 = (ListFieldItem it) -> {
        it.setName("Approved");
        it.setValue("approved");
        it.setDocumentation("Content has been approved and is available online.");
      };
      ListFieldItem _doubleArrow_4 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_4, _function_5);
      _items_4.add(_doubleArrow_4);
      boolean _isHasTray = entity.isHasTray();
      if (_isHasTray) {
        EList<ListFieldItem> _items_5 = listField.getItems();
        ListFieldItem _createListFieldItem_5 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_6 = (ListFieldItem it) -> {
          it.setName("Suspended");
          it.setValue("suspended");
          it.setDocumentation("Content has been approved, but is temporarily offline.");
        };
        ListFieldItem _doubleArrow_5 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_5, _function_6);
        _items_5.add(_doubleArrow_5);
      }
      boolean _isHasArchive = entity.isHasArchive();
      if (_isHasArchive) {
        EList<ListFieldItem> _items_6 = listField.getItems();
        ListFieldItem _createListFieldItem_6 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_7 = (ListFieldItem it) -> {
          it.setName("Archived");
          it.setValue("archived");
          it.setDocumentation("Content has reached the end and became archived.");
        };
        ListFieldItem _doubleArrow_6 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_6, _function_7);
        _items_6.add(_doubleArrow_6);
      }
      EList<ListFieldItem> _items_7 = listField.getItems();
      ListFieldItem _createListFieldItem_7 = factory.createListFieldItem();
      final Procedure1<ListFieldItem> _function_8 = (ListFieldItem it) -> {
        it.setName("Deleted");
        it.setValue("deleted");
        it.setDocumentation("Pseudo-state for content which has been deleted from the database.");
      };
      ListFieldItem _doubleArrow_7 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_7, _function_8);
      _items_7.add(_doubleArrow_7);
      entity.getFields().add(1, listField);
      EntityIndex _createEntityIndex = factory.createEntityIndex();
      final Procedure1<EntityIndex> _function_9 = (EntityIndex it) -> {
        it.setName("workflowStateIndex");
      };
      final EntityIndex wfIndex = ObjectExtensions.<EntityIndex>operator_doubleArrow(_createEntityIndex, _function_9);
      EList<EntityIndexItem> _items_8 = wfIndex.getItems();
      EntityIndexItem _createEntityIndexItem = factory.createEntityIndexItem();
      final Procedure1<EntityIndexItem> _function_10 = (EntityIndexItem it) -> {
        it.setName("workflowState");
      };
      EntityIndexItem _doubleArrow_8 = ObjectExtensions.<EntityIndexItem>operator_doubleArrow(_createEntityIndexItem, _function_10);
      _items_8.add(_doubleArrow_8);
      EList<EntityIndex> _indexes = entity.getIndexes();
      _xblockexpression = _indexes.add(wfIndex);
    }
    return _xblockexpression;
  }
  
  private void addWorkflowSettings(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      EntityWorkflowType _workflow = it_1.getWorkflow();
      return Boolean.valueOf((!Objects.equal(_workflow, EntityWorkflowType.NONE)));
    };
    final Iterable<Entity> entitiesWithWorkflow = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    boolean _isEmpty = IterableExtensions.isEmpty(entitiesWithWorkflow);
    if (_isEmpty) {
      return;
    }
    final Variables varContainer = this.createVarContainerForWorkflowSettings(it);
    final ModuleStudioFactory factory = ModuleStudioFactory.eINSTANCE;
    for (final Entity entity : entitiesWithWorkflow) {
      {
        EList<Variable> _vars = varContainer.getVars();
        IntVar _createIntVar = factory.createIntVar();
        final Procedure1<IntVar> _function_1 = (IntVar it_1) -> {
          String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getNameMultiple());
          String _plus = ("moderationGroupFor" + _formatForCodeCapital);
          it_1.setName(_plus);
          it_1.setValue("2");
          it_1.setDocumentation("Used to determine moderator user accounts for sending email notifications.");
        };
        IntVar _doubleArrow = ObjectExtensions.<IntVar>operator_doubleArrow(_createIntVar, _function_1);
        _vars.add(_doubleArrow);
        EntityWorkflowType _workflow = entity.getWorkflow();
        boolean _equals = Objects.equal(_workflow, EntityWorkflowType.ENTERPRISE);
        if (_equals) {
          EList<Variable> _vars_1 = varContainer.getVars();
          IntVar _createIntVar_1 = factory.createIntVar();
          final Procedure1<IntVar> _function_2 = (IntVar it_1) -> {
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getNameMultiple());
            String _plus = ("superModerationGroupFor" + _formatForCodeCapital);
            it_1.setName(_plus);
            it_1.setValue("2");
            it_1.setDocumentation("Used to determine moderator user accounts for sending email notifications.");
          };
          IntVar _doubleArrow_1 = ObjectExtensions.<IntVar>operator_doubleArrow(_createIntVar_1, _function_2);
          _vars_1.add(_doubleArrow_1);
        }
      }
    }
    EList<Variables> _variables = it.getVariables();
    _variables.add(varContainer);
  }
  
  private void addViewSettings(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this._controllerExtensions.hasViewAction(it_1));
    };
    final Iterable<Entity> entitiesWithView = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    boolean _isEmpty = IterableExtensions.isEmpty(entitiesWithView);
    if (_isEmpty) {
      return;
    }
    final Variables varContainer = this.createVarContainerForViewSettings(it);
    final ModuleStudioFactory factory = ModuleStudioFactory.eINSTANCE;
    for (final Entity entity : entitiesWithView) {
      {
        EList<Variable> _vars = varContainer.getVars();
        IntVar _createIntVar = factory.createIntVar();
        final Procedure1<IntVar> _function_1 = (IntVar it_1) -> {
          String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
          String _plus = (_formatForCode + "EntriesPerPage");
          it_1.setName(_plus);
          it_1.setValue("10");
          String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
          String _plus_1 = ("The amount of " + _formatForDisplay);
          String _plus_2 = (_plus_1 + " shown per page");
          it_1.setDocumentation(_plus_2);
        };
        IntVar _doubleArrow = ObjectExtensions.<IntVar>operator_doubleArrow(_createIntVar, _function_1);
        _vars.add(_doubleArrow);
        if ((this._generatorSettingsExtensions.generateAccountApi(it) && entity.isStandardFields())) {
          EList<Variable> _vars_1 = varContainer.getVars();
          BoolVar _createBoolVar = factory.createBoolVar();
          final Procedure1<BoolVar> _function_2 = (BoolVar it_1) -> {
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getNameMultiple());
            String _plus = ("linkOwn" + _formatForCodeCapital);
            String _plus_1 = (_plus + "OnAccountPage");
            it_1.setName(_plus_1);
            it_1.setValue("true");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
            String _plus_2 = ("Whether to add a link to " + _formatForDisplay);
            String _plus_3 = (_plus_2 + " of the current user on his account page");
            it_1.setDocumentation(_plus_3);
          };
          BoolVar _doubleArrow_1 = ObjectExtensions.<BoolVar>operator_doubleArrow(_createBoolVar, _function_2);
          _vars_1.add(_doubleArrow_1);
        }
      }
    }
    EList<Variables> _variables = it.getVariables();
    _variables.add(varContainer);
  }
  
  private void addImageSettings(final Application it) {
    boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
    boolean _not = (!_hasImageFields);
    if (_not) {
      return;
    }
    final Variables varContainer = this.createVarContainerForImageSettings(it);
    final ModuleStudioFactory factory = ModuleStudioFactory.eINSTANCE;
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this._modelExtensions.hasImageFieldsEntity(it_1));
    };
    final Iterable<Entity> entitiesWithImageUploads = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    for (final Entity entity : entitiesWithImageUploads) {
      Iterable<UploadField> _imageFieldsEntity = this._modelExtensions.getImageFieldsEntity(entity);
      for (final UploadField imageUploadField : _imageFieldsEntity) {
        {
          String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
          String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(imageUploadField.getName());
          final String fieldSuffix = (_formatForCodeCapital + _formatForCodeCapital_1);
          EList<Variable> _vars = varContainer.getVars();
          BoolVar _createBoolVar = factory.createBoolVar();
          final Procedure1<BoolVar> _function_1 = (BoolVar it_1) -> {
            it_1.setName(("enableShrinkingFor" + fieldSuffix));
            it_1.setValue("false");
            it_1.setDocumentation("Whether to enable shrinking huge images to maximum dimensions. Stores downscaled version of the original image.");
          };
          BoolVar _doubleArrow = ObjectExtensions.<BoolVar>operator_doubleArrow(_createBoolVar, _function_1);
          _vars.add(_doubleArrow);
          EList<Variable> _vars_1 = varContainer.getVars();
          IntVar _createIntVar = factory.createIntVar();
          final Procedure1<IntVar> _function_2 = (IntVar it_1) -> {
            it_1.setName(("shrinkWidth" + fieldSuffix));
            it_1.setValue("800");
            it_1.setDocumentation("The maximum image width in pixels.");
          };
          IntVar _doubleArrow_1 = ObjectExtensions.<IntVar>operator_doubleArrow(_createIntVar, _function_2);
          _vars_1.add(_doubleArrow_1);
          EList<Variable> _vars_2 = varContainer.getVars();
          IntVar _createIntVar_1 = factory.createIntVar();
          final Procedure1<IntVar> _function_3 = (IntVar it_1) -> {
            it_1.setName(("shrinkHeight" + fieldSuffix));
            it_1.setValue("600");
            it_1.setDocumentation("The maximum image height in pixels.");
          };
          IntVar _doubleArrow_2 = ObjectExtensions.<IntVar>operator_doubleArrow(_createIntVar_1, _function_3);
          _vars_2.add(_doubleArrow_2);
          ListVar _createListVar = factory.createListVar();
          final Procedure1<ListVar> _function_4 = (ListVar it_1) -> {
            it_1.setName(("thumbnailMode" + fieldSuffix));
            it_1.setValue("inset");
            it_1.setDocumentation("Thumbnail mode (inset or outbound).");
          };
          final ListVar thumbModeVar = ObjectExtensions.<ListVar>operator_doubleArrow(_createListVar, _function_4);
          EList<ListVarItem> _items = thumbModeVar.getItems();
          ListVarItem _createListVarItem = factory.createListVarItem();
          final Procedure1<ListVarItem> _function_5 = (ListVarItem it_1) -> {
            it_1.setName("Inset");
            it_1.setDefault(true);
          };
          ListVarItem _doubleArrow_3 = ObjectExtensions.<ListVarItem>operator_doubleArrow(_createListVarItem, _function_5);
          _items.add(_doubleArrow_3);
          EList<ListVarItem> _items_1 = thumbModeVar.getItems();
          ListVarItem _createListVarItem_1 = factory.createListVarItem();
          final Procedure1<ListVarItem> _function_6 = (ListVarItem it_1) -> {
            it_1.setName("Outbound");
          };
          ListVarItem _doubleArrow_4 = ObjectExtensions.<ListVarItem>operator_doubleArrow(_createListVarItem_1, _function_6);
          _items_1.add(_doubleArrow_4);
          EList<Variable> _vars_3 = varContainer.getVars();
          _vars_3.add(thumbModeVar);
          for (final String action : Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("view", "display", "edit"))) {
            if ((((Objects.equal(action, "view") && this._controllerExtensions.hasViewAction(entity)) || (Objects.equal(action, "display") && this._controllerExtensions.hasDisplayAction(entity))) || (Objects.equal(action, "edit") && this._controllerExtensions.hasEditAction(entity)))) {
              EList<Variable> _vars_4 = varContainer.getVars();
              IntVar _createIntVar_2 = factory.createIntVar();
              final Procedure1<IntVar> _function_7 = (IntVar it_1) -> {
                String _firstUpper = StringExtensions.toFirstUpper(action);
                String _plus = (("thumbnailWidth" + fieldSuffix) + _firstUpper);
                it_1.setName(_plus);
                String _xifexpression = null;
                boolean _equals = Objects.equal(action, "view");
                if (_equals) {
                  _xifexpression = "32";
                } else {
                  _xifexpression = "240";
                }
                it_1.setValue(_xifexpression);
                it_1.setDocumentation((("Thumbnail width on " + action) + " pages in pixels."));
              };
              IntVar _doubleArrow_5 = ObjectExtensions.<IntVar>operator_doubleArrow(_createIntVar_2, _function_7);
              _vars_4.add(_doubleArrow_5);
              EList<Variable> _vars_5 = varContainer.getVars();
              IntVar _createIntVar_3 = factory.createIntVar();
              final Procedure1<IntVar> _function_8 = (IntVar it_1) -> {
                String _firstUpper = StringExtensions.toFirstUpper(action);
                String _plus = (("thumbnailHeight" + fieldSuffix) + _firstUpper);
                it_1.setName(_plus);
                String _xifexpression = null;
                boolean _equals = Objects.equal(action, "view");
                if (_equals) {
                  _xifexpression = "24";
                } else {
                  _xifexpression = "180";
                }
                it_1.setValue(_xifexpression);
                it_1.setDocumentation((("Thumbnail height on " + action) + " pages in pixels."));
              };
              IntVar _doubleArrow_6 = ObjectExtensions.<IntVar>operator_doubleArrow(_createIntVar_3, _function_8);
              _vars_5.add(_doubleArrow_6);
            }
          }
        }
      }
    }
    EList<Variables> _variables = it.getVariables();
    _variables.add(varContainer);
  }
  
  private void addIntegrationSettings(final Application it) {
    boolean _generateExternalControllerAndFinder = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
    boolean _not = (!_generateExternalControllerAndFinder);
    if (_not) {
      return;
    }
    final Variables varContainer = this.createVarContainerForIntegrationSettings(it);
    final ModuleStudioFactory factory = ModuleStudioFactory.eINSTANCE;
    ListVar _createListVar = factory.createListVar();
    final Procedure1<ListVar> _function = (ListVar it_1) -> {
      it_1.setName("enabledFinderTypes");
      it_1.setValue("");
      it_1.setDocumentation("Which sections are supported in the Finder component (used by Scribite plug-ins).");
      it_1.setMultiple(true);
    };
    final ListVar listVar = ObjectExtensions.<ListVar>operator_doubleArrow(_createListVar, _function);
    final Function1<Entity, Boolean> _function_1 = (Entity it_1) -> {
      return Boolean.valueOf(this._controllerExtensions.hasDisplayAction(it_1));
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function_1);
    for (final Entity entity : _filter) {
      EList<ListVarItem> _items = listVar.getItems();
      ListVarItem _createListVarItem = factory.createListVarItem();
      final Procedure1<ListVarItem> _function_2 = (ListVarItem it_1) -> {
        it_1.setName(this._formattingExtensions.formatForCode(entity.getName()));
        it_1.setDefault(true);
      };
      ListVarItem _doubleArrow = ObjectExtensions.<ListVarItem>operator_doubleArrow(_createListVarItem, _function_2);
      _items.add(_doubleArrow);
    }
    EList<Variable> _vars = varContainer.getVars();
    _vars.add(listVar);
    EList<Variables> _variables = it.getVariables();
    _variables.add(varContainer);
  }
  
  private void addGeoSettings(final Application it) {
    boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
    boolean _not = (!_hasGeographical);
    if (_not) {
      return;
    }
    final Variables varContainer = this.createVarContainerForGeoSettings(it);
    final ModuleStudioFactory factory = ModuleStudioFactory.eINSTANCE;
    EList<Variable> _vars = varContainer.getVars();
    TextVar _createTextVar = factory.createTextVar();
    final Procedure1<TextVar> _function = (TextVar it_1) -> {
      it_1.setName("googleMapsApiKey");
      it_1.setValue("");
      it_1.setDocumentation("The API key required for Google Maps.");
    };
    TextVar _doubleArrow = ObjectExtensions.<TextVar>operator_doubleArrow(_createTextVar, _function);
    _vars.add(_doubleArrow);
    Iterable<Entity> _geographicalEntities = this._modelBehaviourExtensions.getGeographicalEntities(it);
    for (final Entity entity : _geographicalEntities) {
      EList<Variable> _vars_1 = varContainer.getVars();
      BoolVar _createBoolVar = factory.createBoolVar();
      final Procedure1<BoolVar> _function_1 = (BoolVar it_1) -> {
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
        String _plus = ("enable" + _formatForCodeCapital);
        String _plus_1 = (_plus + "GeoLocation");
        it_1.setName(_plus_1);
        it_1.setValue("false");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
        String _plus_2 = ("Whether to enable geo location functionality for " + _formatForDisplay);
        String _plus_3 = (_plus_2 + " or not.");
        it_1.setDocumentation(_plus_3);
      };
      BoolVar _doubleArrow_1 = ObjectExtensions.<BoolVar>operator_doubleArrow(_createBoolVar, _function_1);
      _vars_1.add(_doubleArrow_1);
    }
    EList<Variables> _variables = it.getVariables();
    _variables.add(varContainer);
  }
  
  private Variables createVarContainerForWorkflowSettings(final Application it) {
    Variables _xblockexpression = null;
    {
      final int newSortNumber = this.getNextVarContainerSortNumber(it);
      Variables _createVariables = ModuleStudioFactory.eINSTANCE.createVariables();
      final Procedure1<Variables> _function = (Variables it_1) -> {
        it_1.setName("Moderation");
        it_1.setDocumentation("Here you can assign moderation groups for enhanced workflow actions.");
        it_1.setSortOrder(newSortNumber);
      };
      _xblockexpression = ObjectExtensions.<Variables>operator_doubleArrow(_createVariables, _function);
    }
    return _xblockexpression;
  }
  
  private Variables createVarContainerForViewSettings(final Application it) {
    Variables _xblockexpression = null;
    {
      final int newSortNumber = this.getNextVarContainerSortNumber(it);
      Variables _createVariables = ModuleStudioFactory.eINSTANCE.createVariables();
      final Procedure1<Variables> _function = (Variables it_1) -> {
        it_1.setName("ListViews");
        it_1.setDocumentation("Here you can configure parameters for list views.");
        it_1.setSortOrder(newSortNumber);
      };
      _xblockexpression = ObjectExtensions.<Variables>operator_doubleArrow(_createVariables, _function);
    }
    return _xblockexpression;
  }
  
  private Variables createVarContainerForImageSettings(final Application it) {
    Variables _xblockexpression = null;
    {
      final int newSortNumber = this.getNextVarContainerSortNumber(it);
      Variables _createVariables = ModuleStudioFactory.eINSTANCE.createVariables();
      final Procedure1<Variables> _function = (Variables it_1) -> {
        it_1.setName("Images");
        it_1.setDocumentation("Here you can define several options for image handling.");
        it_1.setSortOrder(newSortNumber);
      };
      _xblockexpression = ObjectExtensions.<Variables>operator_doubleArrow(_createVariables, _function);
    }
    return _xblockexpression;
  }
  
  private Variables createVarContainerForIntegrationSettings(final Application it) {
    Variables _xblockexpression = null;
    {
      final int newSortNumber = this.getNextVarContainerSortNumber(it);
      Variables _createVariables = ModuleStudioFactory.eINSTANCE.createVariables();
      final Procedure1<Variables> _function = (Variables it_1) -> {
        it_1.setName("Integration");
        it_1.setDocumentation("These options allow you to configure integration aspects.");
        it_1.setSortOrder(newSortNumber);
      };
      _xblockexpression = ObjectExtensions.<Variables>operator_doubleArrow(_createVariables, _function);
    }
    return _xblockexpression;
  }
  
  private Variables createVarContainerForGeoSettings(final Application it) {
    Variables _xblockexpression = null;
    {
      final int newSortNumber = this.getNextVarContainerSortNumber(it);
      Variables _createVariables = ModuleStudioFactory.eINSTANCE.createVariables();
      final Procedure1<Variables> _function = (Variables it_1) -> {
        it_1.setName("Geo");
        it_1.setDocumentation("Here you can define settings related to geographical features.");
        it_1.setSortOrder(newSortNumber);
      };
      _xblockexpression = ObjectExtensions.<Variables>operator_doubleArrow(_createVariables, _function);
    }
    return _xblockexpression;
  }
  
  private int getNextVarContainerSortNumber(final Application it) {
    int _xblockexpression = (int) 0;
    {
      int lastVarContainerSortNumber = 0;
      boolean _isEmpty = it.getVariables().isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        final Function1<Variables, Integer> _function = (Variables it_1) -> {
          return Integer.valueOf(it_1.getSortOrder());
        };
        lastVarContainerSortNumber = IterableExtensions.<Variables>head(ListExtensions.<Variables>reverseView(IterableExtensions.<Variables, Integer>sortBy(it.getVariables(), _function))).getSortOrder();
      }
      final int newSortNumber = (lastVarContainerSortNumber + 1);
      _xblockexpression = newSortNumber;
    }
    return _xblockexpression;
  }
}
