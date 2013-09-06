package org.zikula.modulestudio.generator.extensions.transformation;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndex;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexItem;
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem;
import de.guite.modulestudio.metamodel.modulestudio.ModulestudioFactory;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * This class adds primary key fields to all entities of an application.
 */
@SuppressWarnings("all")
public class PersistenceTransformer {
  /**
   * Extension methods for formatting names.
   */
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  /**
   * Extension methods related to the model layer.
   */
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  /**
   * Transformation entry point consuming the application instance.
   * 
   * @param it The given {@link Application} instance.
   */
  public void modify(final Application it) {
    it.setInteractiveInstallation(false);
    InputOutput.<String>println("Starting model transformation");
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      this.handleEntity(entity);
    }
  }
  
  /**
   * Transformation processing for a single entity.
   * 
   * @param it The currently treated {@link Entity} instance.
   */
  private void handleEntity(final Entity it) {
    Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_primaryKeyFields);
    if (_isEmpty) {
      this.addPrimaryKey(it);
    }
    this.addWorkflowState(it);
  }
  
  /**
   * Adds a primary key to a given entity.
   * 
   * @param entity The given {@link Entity} instance
   */
  private void addPrimaryKey(final Entity entity) {
    EList<EntityField> _fields = entity.getFields();
    IntegerField _createIdColumn = this.createIdColumn("", Boolean.valueOf(true));
    _fields.add(0, _createIdColumn);
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
      final ModulestudioFactory factory = ModulestudioFactory.eINSTANCE;
      IntegerField _createIntegerField = factory.createIntegerField();
      final Procedure1<IntegerField> _function = new Procedure1<IntegerField>() {
        public void apply(final IntegerField it) {
          String _xifexpression = null;
          if ((isPrimary).booleanValue()) {
            _xifexpression = "id";
          } else {
            String _formatForCode = PersistenceTransformer.this._formattingExtensions.formatForCode(colName);
            String _plus = (_formatForCode + "_id");
            _xifexpression = _plus;
          }
          it.setName(_xifexpression);
          it.setLength(9);
          it.setPrimaryKey((isPrimary).booleanValue());
          it.setUnique((isPrimary).booleanValue());
        }
      };
      final IntegerField idField = ObjectExtensions.<IntegerField>operator_doubleArrow(_createIntegerField, _function);
      _xblockexpression = (idField);
    }
    return _xblockexpression;
  }
  
  /**
   * Adds a list field for the workflow state to a given entity.
   * 
   * @param entity The given {@link Entity} instance
   */
  private boolean addWorkflowState(final Entity entity) {
    boolean _xblockexpression = false;
    {
      final ModulestudioFactory factory = ModulestudioFactory.eINSTANCE;
      ListField _createListField = factory.createListField();
      final Procedure1<ListField> _function = new Procedure1<ListField>() {
        public void apply(final ListField it) {
          it.setName("workflowState");
          it.setDocumentation("the current workflow state");
          it.setLength(20);
          it.setDefaultValue("initial");
          it.setMultiple(false);
        }
      };
      final ListField listField = ObjectExtensions.<ListField>operator_doubleArrow(_createListField, _function);
      EList<ListFieldItem> _items = listField.getItems();
      ListFieldItem _createListFieldItem = factory.createListFieldItem();
      final Procedure1<ListFieldItem> _function_1 = new Procedure1<ListFieldItem>() {
        public void apply(final ListFieldItem it) {
          it.setName("Initial");
          it.setValue("initial");
          it.setDocumentation("Pseudo-state for content which is just created and not persisted yet.");
          it.setDefault(true);
        }
      };
      ListFieldItem _doubleArrow = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem, _function_1);
      _items.add(_doubleArrow);
      boolean _isOwnerPermission = entity.isOwnerPermission();
      if (_isOwnerPermission) {
        EList<ListFieldItem> _items_1 = listField.getItems();
        ListFieldItem _createListFieldItem_1 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_2 = new Procedure1<ListFieldItem>() {
          public void apply(final ListFieldItem it) {
            it.setName("Deferred");
            it.setValue("deferred");
            it.setDocumentation("Content has not been submitted yet or has been waiting, but was rejected.");
          }
        };
        ListFieldItem _doubleArrow_1 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_1, _function_2);
        _items_1.add(_doubleArrow_1);
      }
      EntityWorkflowType _workflow = entity.getWorkflow();
      boolean _notEquals = (!Objects.equal(_workflow, EntityWorkflowType.NONE));
      if (_notEquals) {
        EList<ListFieldItem> _items_2 = listField.getItems();
        ListFieldItem _createListFieldItem_2 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_3 = new Procedure1<ListFieldItem>() {
          public void apply(final ListFieldItem it) {
            it.setName("Waiting");
            it.setValue("waiting");
            it.setDocumentation("Content has been submitted and waits for approval.");
          }
        };
        ListFieldItem _doubleArrow_2 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_2, _function_3);
        _items_2.add(_doubleArrow_2);
        EntityWorkflowType _workflow_1 = entity.getWorkflow();
        boolean _equals = Objects.equal(_workflow_1, EntityWorkflowType.ENTERPRISE);
        if (_equals) {
          EList<ListFieldItem> _items_3 = listField.getItems();
          ListFieldItem _createListFieldItem_3 = factory.createListFieldItem();
          final Procedure1<ListFieldItem> _function_4 = new Procedure1<ListFieldItem>() {
            public void apply(final ListFieldItem it) {
              it.setName("Accepted");
              it.setValue("accepted");
              it.setDocumentation("Content has been submitted and accepted, but still waits for approval.");
            }
          };
          ListFieldItem _doubleArrow_3 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_3, _function_4);
          _items_3.add(_doubleArrow_3);
        }
      }
      EList<ListFieldItem> _items_4 = listField.getItems();
      ListFieldItem _createListFieldItem_4 = factory.createListFieldItem();
      final Procedure1<ListFieldItem> _function_5 = new Procedure1<ListFieldItem>() {
        public void apply(final ListFieldItem it) {
          it.setName("Approved");
          it.setValue("approved");
          it.setDocumentation("Content has been approved and is available online.");
        }
      };
      ListFieldItem _doubleArrow_4 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_4, _function_5);
      _items_4.add(_doubleArrow_4);
      boolean _isHasTray = entity.isHasTray();
      if (_isHasTray) {
        EList<ListFieldItem> _items_5 = listField.getItems();
        ListFieldItem _createListFieldItem_5 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_6 = new Procedure1<ListFieldItem>() {
          public void apply(final ListFieldItem it) {
            it.setName("Suspended");
            it.setValue("suspended");
            it.setDocumentation("Content has been approved, but is temporarily offline.");
          }
        };
        ListFieldItem _doubleArrow_5 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_5, _function_6);
        _items_5.add(_doubleArrow_5);
      }
      boolean _isHasArchive = entity.isHasArchive();
      if (_isHasArchive) {
        EList<ListFieldItem> _items_6 = listField.getItems();
        ListFieldItem _createListFieldItem_6 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_7 = new Procedure1<ListFieldItem>() {
          public void apply(final ListFieldItem it) {
            it.setName("Archived");
            it.setValue("archived");
            it.setDocumentation("Content has reached the end and became archived.");
          }
        };
        ListFieldItem _doubleArrow_6 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_6, _function_7);
        _items_6.add(_doubleArrow_6);
      }
      boolean _isSoftDeleteable = entity.isSoftDeleteable();
      if (_isSoftDeleteable) {
        EList<ListFieldItem> _items_7 = listField.getItems();
        ListFieldItem _createListFieldItem_7 = factory.createListFieldItem();
        final Procedure1<ListFieldItem> _function_8 = new Procedure1<ListFieldItem>() {
          public void apply(final ListFieldItem it) {
            it.setName("Trashed");
            it.setValue("trashed");
            it.setDocumentation("Content has been marked as deleted, but is still persisted in the database.");
          }
        };
        ListFieldItem _doubleArrow_7 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_7, _function_8);
        _items_7.add(_doubleArrow_7);
      }
      EList<ListFieldItem> _items_8 = listField.getItems();
      ListFieldItem _createListFieldItem_8 = factory.createListFieldItem();
      final Procedure1<ListFieldItem> _function_9 = new Procedure1<ListFieldItem>() {
        public void apply(final ListFieldItem it) {
          it.setName("Deleted");
          it.setValue("deleted");
          it.setDocumentation("Pseudo-state for content which has been deleted from the database.");
        }
      };
      ListFieldItem _doubleArrow_8 = ObjectExtensions.<ListFieldItem>operator_doubleArrow(_createListFieldItem_8, _function_9);
      _items_8.add(_doubleArrow_8);
      EList<EntityField> _fields = entity.getFields();
      _fields.add(1, listField);
      EntityIndex _createEntityIndex = factory.createEntityIndex();
      final Procedure1<EntityIndex> _function_10 = new Procedure1<EntityIndex>() {
        public void apply(final EntityIndex it) {
          it.setName("workflowStateIndex");
        }
      };
      final EntityIndex wfIndex = ObjectExtensions.<EntityIndex>operator_doubleArrow(_createEntityIndex, _function_10);
      EList<EntityIndexItem> _items_9 = wfIndex.getItems();
      EntityIndexItem _createEntityIndexItem = factory.createEntityIndexItem();
      final Procedure1<EntityIndexItem> _function_11 = new Procedure1<EntityIndexItem>() {
        public void apply(final EntityIndexItem it) {
          it.setName("workflowState");
        }
      };
      EntityIndexItem _doubleArrow_9 = ObjectExtensions.<EntityIndexItem>operator_doubleArrow(_createEntityIndexItem, _function_11);
      _items_9.add(_doubleArrow_9);
      EList<EntityIndex> _indexes = entity.getIndexes();
      boolean _add = _indexes.add(wfIndex);
      _xblockexpression = (_add);
    }
    return _xblockexpression;
  }
}
