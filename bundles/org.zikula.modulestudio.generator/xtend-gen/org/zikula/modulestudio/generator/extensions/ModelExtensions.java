package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.AbstractIntegerField;
import de.guite.modulestudio.metamodel.AbstractStringField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.EmailField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityChangeTrackingPolicy;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.EntityFieldDisplayType;
import de.guite.modulestudio.metamodel.EntityIdentifierStrategy;
import de.guite.modulestudio.metamodel.EntityIndex;
import de.guite.modulestudio.metamodel.EntityIndexType;
import de.guite.modulestudio.metamodel.EntityLockType;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.InheritanceRelationship;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.IpAddressScope;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ListFieldItem;
import de.guite.modulestudio.metamodel.ListVar;
import de.guite.modulestudio.metamodel.ListVarItem;
import de.guite.modulestudio.metamodel.ObjectField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.TimeField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UrlField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.Collections;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.extensions.CollectionUtils;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * This class contains model related extension methods.
 */
@SuppressWarnings("all")
public class ModelExtensions {
  @Extension
  private CollectionUtils _collectionUtils = new CollectionUtils();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  /**
   * Returns a list of all entity fields in this application.
   */
  public List<EntityField> getAllEntityFields(final Application it) {
    final Function1<DataObject, EList<EntityField>> _function = (DataObject it_1) -> {
      return it_1.getFields();
    };
    return IterableExtensions.<EntityField>toList(Iterables.<EntityField>concat(ListExtensions.<DataObject, EList<EntityField>>map(it.getEntities(), _function)));
  }
  
  /**
   * Returns a list of all entities (data objects except mapped super classes).
   */
  public Iterable<Entity> getAllEntities(final Application it) {
    return Iterables.<Entity>filter(it.getEntities(), Entity.class);
  }
  
  /**
   * Returns the leading entity in the primary model container.
   */
  public Entity getLeadingEntity(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(it_1.isLeading());
    };
    return IterableExtensions.<Entity>findFirst(this.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with hook subscriber capability.
   */
  public boolean hasHookSubscribers(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity e) -> {
      boolean _isSkipHookSubscribers = e.isSkipHookSubscribers();
      return Boolean.valueOf((!_isSkipHookSubscribers));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this.getAllEntities(it), _function));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one image field.
   */
  public boolean hasImageFields(final Application it) {
    final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
      return Boolean.valueOf(this.hasImageFieldsEntity(it_1));
    };
    return IterableExtensions.<DataObject>exists(it.getEntities(), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one colour field.
   */
  public boolean hasColourFields(final Application it) {
    final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
      return Boolean.valueOf(this.hasColourFieldsEntity(it_1));
    };
    return IterableExtensions.<DataObject>exists(it.getEntities(), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one country field.
   */
  public boolean hasCountryFields(final Application it) {
    final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
      return Boolean.valueOf(this.hasCountryFieldsEntity(it_1));
    };
    return IterableExtensions.<DataObject>exists(it.getEntities(), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one upload field.
   */
  public boolean hasUploads(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getUploadEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with at least one upload field.
   */
  public Iterable<DataObject> getUploadEntities(final Application it) {
    final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
      return Boolean.valueOf(this.hasUploadFieldsEntity(it_1));
    };
    return IterableExtensions.<DataObject>filter(it.getEntities(), _function);
  }
  
  /**
   * Returns a list of all user fields in this application.
   */
  public Iterable<UserField> getAllUserFields(final Application it) {
    return Iterables.<UserField>filter(this.getAllEntityFields(it), UserField.class);
  }
  
  /**
   * Checks whether the application contains at least one user field.
   */
  public boolean hasUserFields(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getAllUserFields(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all list fields in this application.
   */
  public Iterable<ListField> getAllListFields(final Application it) {
    return Iterables.<ListField>filter(this.getAllEntityFields(it), ListField.class);
  }
  
  /**
   * Checks whether the application contains at least one list field.
   */
  public boolean hasListFields(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getAllListFields(it));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether the application contains at least one list field with multi selection.
   */
  public boolean hasMultiListFields(final Application it) {
    final Function1<ListField, Boolean> _function = (ListField l) -> {
      return Boolean.valueOf(l.isMultiple());
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(this.getAllListFields(it), _function));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with at least one list field.
   */
  public Iterable<DataObject> getListEntities(final Application it) {
    final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
      return Boolean.valueOf(this.hasListFieldsEntity(it_1));
    };
    return IterableExtensions.<DataObject>filter(it.getEntities(), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled.
   */
  public boolean hasBooleansWithAjaxToggle(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getEntitiesWithAjaxToggle(it));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled for it's view action.
   */
  public boolean hasBooleansWithAjaxToggleInView(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this.hasBooleansWithAjaxToggleEntity(it_1, "view"));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this.getAllEntities(it), _function));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled for it's display action.
   */
  public boolean hasBooleansWithAjaxToggleInDisplay(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this.hasBooleansWithAjaxToggleEntity(it_1, "display"));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this.getAllEntities(it), _function));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with at least one boolean field having ajax toggle enabled.
   */
  public Iterable<DataObject> getEntitiesWithAjaxToggle(final Application it) {
    final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
      return Boolean.valueOf(this.hasBooleansWithAjaxToggleEntity(it_1, ""));
    };
    return IterableExtensions.<DataObject>filter(it.getEntities(), _function);
  }
  
  /**
   * Prepends the application vendor and the database prefix to a given string.
   */
  public String tableNameWithPrefix(final Application it, final String inputString) {
    String _formatForDB = this._formattingExtensions.formatForDB(it.getVendor());
    String _plus = (_formatForDB + "_");
    String _prefix = this._utils.prefix(it);
    String _plus_1 = (_plus + _prefix);
    String _plus_2 = (_plus_1 + "_");
    return (_plus_2 + inputString);
  }
  
  /**
   * Returns the full table name for a given entity instance.
   */
  public String fullEntityTableName(final DataObject it) {
    return this.tableNameWithPrefix(it.getApplication(), this._formattingExtensions.formatForDB(it.getName()));
  }
  
  /**
   * Returns either the plural or the singular entity name, depending on a given boolean.
   */
  public String getEntityNameSingularPlural(final Entity it, final Boolean usePlural) {
    String _xifexpression = null;
    if ((usePlural).booleanValue()) {
      _xifexpression = it.getNameMultiple();
    } else {
      _xifexpression = it.getName();
    }
    return _xifexpression;
  }
  
  /**
   * Checks whether this entity has at least one normal (non-unique) index.
   */
  public boolean hasNormalIndexes(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getNormalIndexes(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all normal (non-unique) indexes for this entity.
   */
  public Iterable<EntityIndex> getNormalIndexes(final Entity it) {
    final Function1<EntityIndex, Boolean> _function = (EntityIndex it_1) -> {
      EntityIndexType _type = it_1.getType();
      return Boolean.valueOf(Objects.equal(_type, EntityIndexType.NORMAL));
    };
    return IterableExtensions.<EntityIndex>filter(it.getIndexes(), _function);
  }
  
  /**
   * Checks whether this entity has at least one unique index.
   */
  public boolean hasUniqueIndexes(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getUniqueIndexes(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all unique indexes for this entity.
   */
  public Iterable<EntityIndex> getUniqueIndexes(final Entity it) {
    final Function1<EntityIndex, Boolean> _function = (EntityIndex it_1) -> {
      EntityIndexType _type = it_1.getType();
      return Boolean.valueOf(Objects.equal(_type, EntityIndexType.UNIQUE));
    };
    return IterableExtensions.<EntityIndex>filter(it.getIndexes(), _function);
  }
  
  /**
   * Returns a list of all derived fields (excluding calculated fields) of the given entity.
   */
  public Iterable<DerivedField> getDerivedFields(final DataObject it) {
    return Iterables.<DerivedField>filter(it.getFields(), DerivedField.class);
  }
  
  /**
   * Returns a list of all derived and unique fields of the given entity
   */
  public Iterable<DerivedField> getUniqueDerivedFields(final DataObject it) {
    final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
      return Boolean.valueOf(it_1.isUnique());
    };
    return IterableExtensions.<DerivedField>filter(this.getDerivedFields(it), _function);
  }
  
  /**
   * Returns a list of all derived and primary key fields of the given entity.
   */
  public Iterable<DerivedField> getPrimaryKeyFields(final DataObject it) {
    final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
      return Boolean.valueOf(it_1.isPrimaryKey());
    };
    return IterableExtensions.<DerivedField>filter(this.getDerivedFields(it), _function);
  }
  
  /**
   * Returns the first derived and primary key field of the given entity.
   */
  public DerivedField getFirstPrimaryKey(final DataObject it) {
    final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
      return Boolean.valueOf(it_1.isPrimaryKey());
    };
    return IterableExtensions.<DerivedField>findFirst(this.getDerivedFields(it), _function);
  }
  
  /**
   * Checks whether the entity has more than one primary key fields.
   */
  public boolean hasCompositeKeys(final DataObject it) {
    int _size = IterableExtensions.size(this.getPrimaryKeyFields(it));
    return (_size > 1);
  }
  
  /**
   * Concatenates all id strings using underscore as delimiter.
   * Used for generating some controller classes.
   */
  public CharSequence idFieldsAsParameterCode(final DataObject it, final String objVar) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCompositeKeys = this.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        {
          Iterable<DerivedField> _primaryKeyFields = this.getPrimaryKeyFields(it);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(" . \'_\' . ", "");
            }
            _builder.append("$");
            _builder.append(objVar);
            _builder.append("[\'");
            String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode);
            _builder.append("\']");
          }
        }
      } else {
        _builder.append("$");
        _builder.append(objVar);
        _builder.append("[\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(this.getFirstPrimaryKey(it).getName());
        _builder.append(_formatForCode_1);
        _builder.append("\']");
      }
    }
    return _builder;
  }
  
  /**
   * Concatenates all id strings using underscore as delimiter.
   * Used for generating some view templates.
   */
  public CharSequence idFieldsAsParameterTemplate(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<DerivedField> _primaryKeyFields = this.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" ~ \'_\' ~ ", "");
        }
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append(".");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode_1);
      }
    }
    return _builder;
  }
  
  /**
   * Returns a list of all fields which should be displayed on the view page.
   */
  public List<DerivedField> getFieldsForViewPage(final Entity it) {
    List<DerivedField> _xblockexpression = null;
    {
      final Function1<DerivedField, Boolean> _function = (DerivedField f) -> {
        return Boolean.valueOf(this.isVisibleOnViewPage(f));
      };
      Iterable<?> fields = this._collectionUtils.exclude(this._collectionUtils.exclude(IterableExtensions.<DerivedField>filter(this.getDisplayFields(it), _function), ArrayField.class), ObjectField.class);
      List<?> _list = IterableExtensions.toList(fields);
      _xblockexpression = ((List<DerivedField>) _list);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all fields which should be displayed on the display page.
   */
  public Iterable<DerivedField> getFieldsForDisplayPage(final Entity it) {
    final Function1<DerivedField, Boolean> _function = (DerivedField f) -> {
      return Boolean.valueOf(this.isVisibleOnDisplayPage(f));
    };
    return IterableExtensions.<DerivedField>filter(this.getDisplayFields(it), _function);
  }
  
  /**
   * Returns a list of all fields which should be displayed.
   */
  public Iterable<DerivedField> getDisplayFields(final DataObject it) {
    Iterable<DerivedField> _xblockexpression = null;
    {
      Iterable<DerivedField> fields = this.getDerivedFields(it);
      if ((it instanceof Entity)) {
        EntityIdentifierStrategy _identifierStrategy = ((Entity)it).getIdentifierStrategy();
        boolean _notEquals = (!Objects.equal(_identifierStrategy, EntityIdentifierStrategy.NONE));
        if (_notEquals) {
          final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
            boolean _isPrimaryKey = it_1.isPrimaryKey();
            return Boolean.valueOf((!_isPrimaryKey));
          };
          fields = IterableExtensions.<DerivedField>filter(fields, _function);
        }
        boolean _hasVisibleWorkflow = this._workflowExtensions.hasVisibleWorkflow(((Entity)it));
        boolean _not = (!_hasVisibleWorkflow);
        if (_not) {
          final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_1) -> {
            String _name = it_1.getName();
            return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
          };
          fields = IterableExtensions.<DerivedField>filter(fields, _function_1);
        }
      }
      _xblockexpression = fields;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all fields which may be used for sorting.
   */
  public List<EntityField> getSortingFields(final DataObject it) {
    List<EntityField> _xblockexpression = null;
    {
      final Function1<DerivedField, Boolean> _function = (DerivedField f) -> {
        return Boolean.valueOf(this.isSortField(f));
      };
      Iterable<?> fields = this._collectionUtils.exclude(this._collectionUtils.exclude(this._collectionUtils.exclude(IterableExtensions.<DerivedField>filter(this.getDisplayFields(it), _function), UserField.class), ArrayField.class), ObjectField.class);
      List<?> _list = IterableExtensions.toList(fields);
      _xblockexpression = ((List<EntityField>) _list);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all editable fields of the given entity.
   * At the moment instances of ArrayField and ObjectField are excluded.
   * Also version fields are excluded as these are incremented automatically.
   */
  public List<DerivedField> getEditableFields(final DataObject it) {
    List<DerivedField> _xblockexpression = null;
    {
      final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
        String _name = it_1.getName();
        return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
      };
      Iterable<DerivedField> fields = IterableExtensions.<DerivedField>filter(this.getDerivedFields(it), _function);
      if (((it instanceof Entity) && (!Objects.equal(((Entity) it).getIdentifierStrategy(), EntityIdentifierStrategy.NONE)))) {
        final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_1) -> {
          boolean _isPrimaryKey = it_1.isPrimaryKey();
          return Boolean.valueOf((!_isPrimaryKey));
        };
        fields = IterableExtensions.<DerivedField>filter(fields, _function_1);
      }
      final Function1<DerivedField, Boolean> _function_2 = (DerivedField it_1) -> {
        boolean _isVersionField = this.isVersionField(it_1);
        return Boolean.valueOf((!_isVersionField));
      };
      Iterable<?> filteredFields = this._collectionUtils.exclude(IterableExtensions.<DerivedField>filter(fields, _function_2), ObjectField.class);
      List<?> _list = IterableExtensions.toList(filteredFields);
      _xblockexpression = ((List<DerivedField>) _list);
    }
    return _xblockexpression;
  }
  
  /**
   * Checks whether a given field is a version field or not.
   */
  private boolean isVersionField(final EntityField it) {
    boolean _xblockexpression = false;
    {
      if ((it instanceof IntegerField)) {
        return ((IntegerField)it).isVersion();
      }
      if ((it instanceof DatetimeField)) {
        return ((DatetimeField)it).isVersion();
      }
      _xblockexpression = false;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all fields of the given entity for which we provide example data.
   * At the moment instances of UploadField are excluded.
   */
  public List<DerivedField> getFieldsForExampleData(final DataObject it) {
    List<DerivedField> _xblockexpression = null;
    {
      final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
        boolean _isPrimaryKey = it_1.isPrimaryKey();
        return Boolean.valueOf((!_isPrimaryKey));
      };
      final Iterable<?> exampleFields = this._collectionUtils.exclude(IterableExtensions.<DerivedField>filter(this.getDerivedFields(it), _function), UploadField.class);
      List<?> _list = IterableExtensions.toList(exampleFields);
      _xblockexpression = ((List<DerivedField>) _list);
    }
    return _xblockexpression;
  }
  
  /**
   * Checks whether this entity has at least one user field.
   */
  public boolean hasUserFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getUserFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all user fields of this entity.
   */
  public Iterable<UserField> getUserFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<UserField>> _function = (DataObject it_1) -> {
      return Iterables.<UserField>filter(it_1.getFields(), UserField.class);
    };
    return Iterables.<UserField>concat(IterableExtensions.<DataObject, Iterable<UserField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one upload field.
   */
  public boolean hasUploadFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getUploadFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all upload fields of this entity.
   */
  public Iterable<UploadField> getUploadFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<UploadField>> _function = (DataObject it_1) -> {
      return Iterables.<UploadField>filter(it_1.getFields(), UploadField.class);
    };
    return Iterables.<UploadField>concat(IterableExtensions.<DataObject, Iterable<UploadField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one list field.
   */
  public boolean hasListFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getListFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all list fields of this entity.
   */
  public Iterable<ListField> getListFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<ListField>> _function = (DataObject it_1) -> {
      return Iterables.<ListField>filter(it_1.getFields(), ListField.class);
    };
    return Iterables.<ListField>concat(IterableExtensions.<DataObject, Iterable<ListField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Returns whether this field is visible on the view page.
   */
  public boolean isVisibleOnViewPage(final EntityField it) {
    return Collections.<EntityFieldDisplayType>unmodifiableList(CollectionLiterals.<EntityFieldDisplayType>newArrayList(EntityFieldDisplayType.VIEW, EntityFieldDisplayType.VIEW_SORTING, EntityFieldDisplayType.VIEW_DISPLAY, EntityFieldDisplayType.ALL)).contains(it.getDisplayType());
  }
  
  /**
   * Returns whether this field is visible on the display page.
   */
  public boolean isVisibleOnDisplayPage(final EntityField it) {
    return Collections.<EntityFieldDisplayType>unmodifiableList(CollectionLiterals.<EntityFieldDisplayType>newArrayList(EntityFieldDisplayType.DISPLAY, EntityFieldDisplayType.DISPLAY_SORTING, EntityFieldDisplayType.VIEW_DISPLAY, EntityFieldDisplayType.ALL)).contains(it.getDisplayType());
  }
  
  /**
   * Returns whether this field maybe used for sorting.
   */
  public boolean isSortField(final EntityField it) {
    return Collections.<EntityFieldDisplayType>unmodifiableList(CollectionLiterals.<EntityFieldDisplayType>newArrayList(EntityFieldDisplayType.SORTING, EntityFieldDisplayType.VIEW_SORTING, EntityFieldDisplayType.DISPLAY_SORTING, EntityFieldDisplayType.ALL)).contains(it.getDisplayType());
  }
  
  /**
   * Returns a list of all default items of this list.
   */
  public Iterable<ListFieldItem> getDefaultItems(final ListField it) {
    final Function1<ListFieldItem, Boolean> _function = (ListFieldItem it_1) -> {
      return Boolean.valueOf(it_1.isDefault());
    };
    return IterableExtensions.<ListFieldItem>filter(it.getItems(), _function);
  }
  
  /**
   * Returns a list of all default items of this list.
   */
  public Iterable<ListVarItem> getDefaultItems(final ListVar it) {
    final Function1<ListVarItem, Boolean> _function = (ListVarItem it_1) -> {
      return Boolean.valueOf(it_1.isDefault());
    };
    return IterableExtensions.<ListVarItem>filter(it.getItems(), _function);
  }
  
  /**
   * Returns a list of inheriting data objects.
   */
  public List<DataObject> getParentDataObjects(final DataObject it, final List<DataObject> parents) {
    List<DataObject> _xblockexpression = null;
    {
      final Function1<InheritanceRelationship, Boolean> _function = (InheritanceRelationship it_1) -> {
        DataObject _target = it_1.getTarget();
        return Boolean.valueOf((null != _target));
      };
      final Iterable<InheritanceRelationship> inheritanceRelation = IterableExtensions.<InheritanceRelationship>filter(Iterables.<InheritanceRelationship>filter(it.getOutgoing(), InheritanceRelationship.class), _function);
      boolean _isEmpty = IterableExtensions.isEmpty(inheritanceRelation);
      boolean _not = (!_isEmpty);
      if (_not) {
        parents.add(IterableExtensions.<InheritanceRelationship>head(inheritanceRelation).getTarget());
        this.getParentDataObjects(IterableExtensions.<InheritanceRelationship>head(inheritanceRelation).getTarget(), parents);
      }
      _xblockexpression = parents;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of an object and it's inheriting data objects.
   */
  public Iterable<DataObject> getSelfAndParentDataObjects(final DataObject it) {
    List<DataObject> _parentDataObjects = this.getParentDataObjects(it, Collections.<DataObject>unmodifiableList(CollectionLiterals.<DataObject>newArrayList()));
    return Iterables.<DataObject>concat(_parentDataObjects, Collections.<DataObject>unmodifiableList(CollectionLiterals.<DataObject>newArrayList(it)));
  }
  
  /**
   * Checks whether this entity has at least one image field.
   */
  public boolean hasImageFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getImageFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all image fields of this entity.
   */
  public Iterable<UploadField> getImageFieldsEntity(final DataObject it) {
    final Function1<UploadField, Boolean> _function = (UploadField it_1) -> {
      return Boolean.valueOf(this.isImageField(it_1));
    };
    return IterableExtensions.<UploadField>filter(this.getUploadFieldsEntity(it), _function);
  }
  
  /**
   * Checks whether an upload field is an image field.
   */
  public boolean isImageField(final UploadField it) {
    final Function1<String, Boolean> _function = (String it_1) -> {
      return Boolean.valueOf((((Objects.equal(it_1, "gif") || Objects.equal(it_1, "jpeg")) || Objects.equal(it_1, "jpg")) || Objects.equal(it_1, "png")));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<String>filter(((Iterable<String>)Conversions.doWrapArray(it.getAllowedExtensions().split(", "))), _function));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether an upload field is an image field without supporting other file types.
   */
  public boolean isOnlyImageField(final UploadField it) {
    final Function1<String, Boolean> _function = (String it_1) -> {
      return Boolean.valueOf(((((!Objects.equal(it_1, "gif")) && (!Objects.equal(it_1, "jpeg"))) && (!Objects.equal(it_1, "jpg"))) && (!Objects.equal(it_1, "png"))));
    };
    return IterableExtensions.isEmpty(IterableExtensions.<String>filter(((Iterable<String>)Conversions.doWrapArray(it.getAllowedExtensions().split(", "))), _function));
  }
  
  /**
   * Checks whether this entity has at least one colour field.
   */
  public boolean hasColourFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getColourFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all colour fields of this entity.
   */
  public Iterable<StringField> getColourFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<StringField>> _function = (DataObject it_1) -> {
      final Function1<StringField, Boolean> _function_1 = (StringField it_2) -> {
        return Boolean.valueOf(it_2.isHtmlcolour());
      };
      return IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it_1.getFields(), StringField.class), _function_1);
    };
    return Iterables.<StringField>concat(IterableExtensions.<DataObject, Iterable<StringField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one country field.
   */
  public boolean hasCountryFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getCountryFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all country fields of this entity.
   */
  public Iterable<StringField> getCountryFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<StringField>> _function = (DataObject it_1) -> {
      final Function1<StringField, Boolean> _function_1 = (StringField it_2) -> {
        return Boolean.valueOf(it_2.isCountry());
      };
      return IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it_1.getFields(), StringField.class), _function_1);
    };
    return Iterables.<StringField>concat(IterableExtensions.<DataObject, Iterable<StringField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one language field.
   */
  public boolean hasLanguageFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getLanguageFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all language fields of this entity.
   */
  public Iterable<StringField> getLanguageFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<StringField>> _function = (DataObject it_1) -> {
      final Function1<StringField, Boolean> _function_1 = (StringField it_2) -> {
        return Boolean.valueOf(it_2.isLanguage());
      };
      return IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it_1.getFields(), StringField.class), _function_1);
    };
    return Iterables.<StringField>concat(IterableExtensions.<DataObject, Iterable<StringField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one locale field.
   */
  public boolean hasLocaleFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getLocaleFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all locale fields of this entity.
   */
  public Iterable<StringField> getLocaleFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<StringField>> _function = (DataObject it_1) -> {
      final Function1<StringField, Boolean> _function_1 = (StringField it_2) -> {
        return Boolean.valueOf(it_2.isLocale());
      };
      return IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it_1.getFields(), StringField.class), _function_1);
    };
    return Iterables.<StringField>concat(IterableExtensions.<DataObject, Iterable<StringField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one time zone field.
   */
  public boolean hasTimezoneFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getTimezoneFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all time zone fields of this entity.
   */
  public Iterable<StringField> getTimezoneFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<StringField>> _function = (DataObject it_1) -> {
      final Function1<StringField, Boolean> _function_1 = (StringField it_2) -> {
        return Boolean.valueOf(it_2.isTimezone());
      };
      return IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it_1.getFields(), StringField.class), _function_1);
    };
    return Iterables.<StringField>concat(IterableExtensions.<DataObject, Iterable<StringField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one currency field.
   */
  public boolean hasCurrencyFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getCurrencyFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all currency fields of this entity.
   */
  public Iterable<StringField> getCurrencyFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<StringField>> _function = (DataObject it_1) -> {
      final Function1<StringField, Boolean> _function_1 = (StringField it_2) -> {
        return Boolean.valueOf(it_2.isCurrency());
      };
      return IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it_1.getFields(), StringField.class), _function_1);
    };
    return Iterables.<StringField>concat(IterableExtensions.<DataObject, Iterable<StringField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one textual field.
   */
  public boolean hasAbstractStringFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getAbstractStringFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all textual fields of this entity.
   */
  public Iterable<AbstractStringField> getAbstractStringFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<AbstractStringField>> _function = (DataObject it_1) -> {
      return Iterables.<AbstractStringField>filter(it_1.getFields(), AbstractStringField.class);
    };
    return Iterables.<AbstractStringField>concat(IterableExtensions.<DataObject, Iterable<AbstractStringField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one string field.
   */
  public boolean hasStringFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getStringFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all string fields of this entity.
   */
  public Iterable<StringField> getStringFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<StringField>> _function = (DataObject it_1) -> {
      return Iterables.<StringField>filter(it_1.getFields(), StringField.class);
    };
    return Iterables.<StringField>concat(IterableExtensions.<DataObject, Iterable<StringField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one text field.
   */
  public boolean hasTextFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getTextFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all text fields of this entity.
   */
  public Iterable<TextField> getTextFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<TextField>> _function = (DataObject it_1) -> {
      return Iterables.<TextField>filter(it_1.getFields(), TextField.class);
    };
    return Iterables.<TextField>concat(IterableExtensions.<DataObject, Iterable<TextField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one boolean field.
   */
  public boolean hasBooleanFieldsEntity(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getBooleanFieldsEntity(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all boolean fields of this entity.
   */
  public Iterable<BooleanField> getBooleanFieldsEntity(final DataObject it) {
    final Function1<DataObject, Iterable<BooleanField>> _function = (DataObject it_1) -> {
      return Iterables.<BooleanField>filter(it_1.getFields(), BooleanField.class);
    };
    return Iterables.<BooleanField>concat(IterableExtensions.<DataObject, Iterable<BooleanField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether this entity has at least one boolean field having ajax toggle enabled.
   */
  public boolean hasBooleansWithAjaxToggleEntity(final DataObject it, final String context) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getBooleansWithAjaxToggleEntity(it, context));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all boolean fields having ajax toggle enabled.
   */
  public Iterable<BooleanField> getBooleansWithAjaxToggleEntity(final DataObject it, final String context) {
    final Function1<BooleanField, Boolean> _function = (BooleanField it_1) -> {
      return Boolean.valueOf(it_1.isAjaxTogglability());
    };
    final Iterable<BooleanField> fields = IterableExtensions.<BooleanField>filter(this.getBooleanFieldsEntity(it), _function);
    if ((IterableExtensions.isEmpty(fields) || Objects.equal(context, ""))) {
      return fields;
    }
    boolean _equals = Objects.equal(context, "view");
    if (_equals) {
      final Function1<BooleanField, Boolean> _function_1 = (BooleanField f) -> {
        return Boolean.valueOf(this.isVisibleOnViewPage(f));
      };
      return IterableExtensions.<BooleanField>filter(fields, _function_1);
    } else {
      boolean _equals_1 = Objects.equal(context, "display");
      if (_equals_1) {
        final Function1<BooleanField, Boolean> _function_2 = (BooleanField f) -> {
          return Boolean.valueOf(this.isVisibleOnDisplayPage(f));
        };
        return IterableExtensions.<BooleanField>filter(fields, _function_2);
      }
    }
    return null;
  }
  
  /**
   * Returns a list of all integer fields which are used as aggregates.
   */
  public Iterable<IntegerField> getAggregateFields(final DataObject it) {
    final Function1<DataObject, Iterable<IntegerField>> _function = (DataObject it_1) -> {
      final Function1<IntegerField, Boolean> _function_1 = (IntegerField it_2) -> {
        return Boolean.valueOf(((null != it_2.getAggregateFor()) && (!Objects.equal(it_2.getAggregateFor(), ""))));
      };
      return IterableExtensions.<IntegerField>filter(Iterables.<IntegerField>filter(it_1.getFields(), IntegerField.class), _function_1);
    };
    return Iterables.<IntegerField>concat(IterableExtensions.<DataObject, Iterable<IntegerField>>map(this.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Returns the sub folder path segment for this upload field,
   * that is either the subFolderName attribute (if set) or the name otherwise.
   */
  public String subFolderPathSegment(final UploadField it) {
    String _xifexpression = null;
    if (((null != it.getSubFolderName()) && (!Objects.equal(it.getSubFolderName(), "")))) {
      _xifexpression = it.getSubFolderName();
    } else {
      _xifexpression = it.getName();
    }
    return this._formattingExtensions.formatForDB(_xifexpression);
  }
  
  /**
   * Prints an output string corresponding to the given entity lock type.
   */
  public String lockTypeAsConstant(final EntityLockType lockType) {
    String _switchResult = null;
    if (lockType != null) {
      switch (lockType) {
        case NONE:
          _switchResult = "";
          break;
        case OPTIMISTIC:
          _switchResult = "OPTIMISTIC";
          break;
        case PESSIMISTIC_READ:
          _switchResult = "PESSIMISTIC_READ";
          break;
        case PESSIMISTIC_WRITE:
          _switchResult = "PESSIMISTIC_WRITE";
          break;
        case PAGELOCK:
          _switchResult = "";
          break;
        case PAGELOCK_OPTIMISTIC:
          _switchResult = "OPTIMISTIC";
          break;
        case PAGELOCK_PESSIMISTIC_READ:
          _switchResult = "PESSIMISTIC_READ";
          break;
        case PAGELOCK_PESSIMISTIC_WRITE:
          _switchResult = "PESSIMISTIC_WRITE";
          break;
        default:
          _switchResult = "";
          break;
      }
    } else {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Checks whether this entity has enabled the notify tracking policy.
   */
  public boolean hasNotifyPolicy(final Entity it) {
    EntityChangeTrackingPolicy _changeTrackingPolicy = it.getChangeTrackingPolicy();
    return Objects.equal(_changeTrackingPolicy, EntityChangeTrackingPolicy.NOTIFY);
  }
  
  /**
   * Checks whether this entity has enabled optimistic locking.
   */
  public boolean hasOptimisticLock(final Entity it) {
    return (Objects.equal(it.getLockType(), EntityLockType.OPTIMISTIC) || Objects.equal(it.getLockType(), EntityLockType.PAGELOCK_OPTIMISTIC));
  }
  
  /**
   * Checks whether this entity has enabled pessimistic read locking.
   */
  public boolean hasPessimisticReadLock(final Entity it) {
    return (Objects.equal(it.getLockType(), EntityLockType.PESSIMISTIC_READ) || Objects.equal(it.getLockType(), EntityLockType.PAGELOCK_PESSIMISTIC_READ));
  }
  
  /**
   * Checks whether this entity has enabled pessimistic write locking.
   */
  public boolean hasPessimisticWriteLock(final Entity it) {
    return (Objects.equal(it.getLockType(), EntityLockType.PESSIMISTIC_WRITE) || Objects.equal(it.getLockType(), EntityLockType.PAGELOCK_PESSIMISTIC_WRITE));
  }
  
  /**
   * Checks whether this entity has enabled support for the PageLock module.
   */
  public boolean hasPageLockSupport(final Entity it) {
    return (((Objects.equal(it.getLockType(), EntityLockType.PAGELOCK) || Objects.equal(it.getLockType(), EntityLockType.PAGELOCK_OPTIMISTIC)) || Objects.equal(it.getLockType(), EntityLockType.PAGELOCK_PESSIMISTIC_READ)) || Objects.equal(it.getLockType(), EntityLockType.PAGELOCK_PESSIMISTIC_WRITE));
  }
  
  /**
   * Determines the version field of a data object if there is one.
   */
  public DerivedField getVersionField(final DataObject it) {
    DatetimeField _xblockexpression = null;
    {
      final Function1<DataObject, Iterable<IntegerField>> _function = (DataObject it_1) -> {
        final Function1<IntegerField, Boolean> _function_1 = (IntegerField it_2) -> {
          return Boolean.valueOf(it_2.isVersion());
        };
        return IterableExtensions.<IntegerField>filter(Iterables.<IntegerField>filter(it_1.getFields(), IntegerField.class), _function_1);
      };
      final Iterable<IntegerField> intVersions = Iterables.<IntegerField>concat(IterableExtensions.<DataObject, Iterable<IntegerField>>map(this.getSelfAndParentDataObjects(it), _function));
      boolean _isEmpty = IterableExtensions.isEmpty(intVersions);
      boolean _not = (!_isEmpty);
      if (_not) {
        return IterableExtensions.<IntegerField>head(intVersions);
      }
      final Function1<DataObject, Iterable<DatetimeField>> _function_1 = (DataObject it_1) -> {
        final Function1<DatetimeField, Boolean> _function_2 = (DatetimeField it_2) -> {
          return Boolean.valueOf(it_2.isVersion());
        };
        return IterableExtensions.<DatetimeField>filter(Iterables.<DatetimeField>filter(it_1.getFields(), DatetimeField.class), _function_2);
      };
      final Iterable<DatetimeField> datetimeVersions = Iterables.<DatetimeField>concat(IterableExtensions.<DataObject, Iterable<DatetimeField>>map(this.getSelfAndParentDataObjects(it), _function_1));
      DatetimeField _xifexpression = null;
      boolean _isEmpty_1 = IterableExtensions.isEmpty(datetimeVersions);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _xifexpression = IterableExtensions.<DatetimeField>head(datetimeVersions);
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  /**
   * Checks whether the given field is a default (= no custom) identifier field.
   */
  public boolean isDefaultIdField(final DerivedField it) {
    return this.isDefaultIdFieldName(it.getEntity(), this._formattingExtensions.formatForDB(it.getName()));
  }
  
  /**
   * Checks whether the given string is the name of the default (= no custom) identifier field.
   */
  public boolean isDefaultIdFieldName(final DataObject it, final String s) {
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    String _plus = (_formatForDB + "id");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    String _plus_1 = (_formatForDB_1 + "_id");
    return CollectionLiterals.<String>newArrayList("id", _plus, _plus_1).contains(s);
  }
  
  /**
   * Checks whether the given list contains the name of a default (= no custom) identifier field.
   */
  public boolean containsDefaultIdField(final Iterable<String> l, final DataObject dataObject) {
    return (this.isDefaultIdFieldName(dataObject, IterableExtensions.<String>head(l)) || ((IterableExtensions.size(l) > 1) && this.containsDefaultIdField(IterableExtensions.<String>tail(l), dataObject)));
  }
  
  /**
   * Determines the start date field of a data object if there is one.
   */
  public AbstractDateField getStartDateField(final DataObject it) {
    DateField _xblockexpression = null;
    {
      final Function1<DataObject, Iterable<DatetimeField>> _function = (DataObject it_1) -> {
        final Function1<DatetimeField, Boolean> _function_1 = (DatetimeField it_2) -> {
          return Boolean.valueOf(it_2.isStartDate());
        };
        return IterableExtensions.<DatetimeField>filter(Iterables.<DatetimeField>filter(it_1.getFields(), DatetimeField.class), _function_1);
      };
      final Iterable<DatetimeField> datetimeFields = Iterables.<DatetimeField>concat(IterableExtensions.<DataObject, Iterable<DatetimeField>>map(this.getSelfAndParentDataObjects(it), _function));
      boolean _isEmpty = IterableExtensions.isEmpty(datetimeFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        return IterableExtensions.<DatetimeField>head(datetimeFields);
      }
      final Function1<DataObject, Iterable<DateField>> _function_1 = (DataObject it_1) -> {
        final Function1<DateField, Boolean> _function_2 = (DateField it_2) -> {
          return Boolean.valueOf(it_2.isStartDate());
        };
        return IterableExtensions.<DateField>filter(Iterables.<DateField>filter(it_1.getFields(), DateField.class), _function_2);
      };
      final Iterable<DateField> dateFields = Iterables.<DateField>concat(IterableExtensions.<DataObject, Iterable<DateField>>map(this.getSelfAndParentDataObjects(it), _function_1));
      DateField _xifexpression = null;
      boolean _isEmpty_1 = IterableExtensions.isEmpty(dateFields);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _xifexpression = IterableExtensions.<DateField>head(dateFields);
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  /**
   * Determines the end date field of a data object if there is one.
   */
  public AbstractDateField getEndDateField(final DataObject it) {
    DateField _xblockexpression = null;
    {
      final Function1<DataObject, Iterable<DatetimeField>> _function = (DataObject it_1) -> {
        final Function1<DatetimeField, Boolean> _function_1 = (DatetimeField it_2) -> {
          return Boolean.valueOf(it_2.isEndDate());
        };
        return IterableExtensions.<DatetimeField>filter(Iterables.<DatetimeField>filter(it_1.getFields(), DatetimeField.class), _function_1);
      };
      final Iterable<DatetimeField> datetimeFields = Iterables.<DatetimeField>concat(IterableExtensions.<DataObject, Iterable<DatetimeField>>map(this.getSelfAndParentDataObjects(it), _function));
      boolean _isEmpty = IterableExtensions.isEmpty(datetimeFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        return IterableExtensions.<DatetimeField>head(datetimeFields);
      }
      final Function1<DataObject, Iterable<DateField>> _function_1 = (DataObject it_1) -> {
        final Function1<DateField, Boolean> _function_2 = (DateField it_2) -> {
          return Boolean.valueOf(it_2.isEndDate());
        };
        return IterableExtensions.<DateField>filter(Iterables.<DateField>filter(it_1.getFields(), DateField.class), _function_2);
      };
      final Iterable<DateField> dateFields = Iterables.<DateField>concat(IterableExtensions.<DataObject, Iterable<DateField>>map(this.getSelfAndParentDataObjects(it), _function_1));
      DateField _xifexpression = null;
      boolean _isEmpty_1 = IterableExtensions.isEmpty(dateFields);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _xifexpression = IterableExtensions.<DateField>head(dateFields);
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  /**
   * Prints an output string corresponding to the given entity lock type.
   */
  public String ipScopeAsConstant(final IpAddressScope scope) {
    String _switchResult = null;
    if (scope != null) {
      switch (scope) {
        case NONE:
          _switchResult = "";
          break;
        case IP4:
          _switchResult = "4";
          break;
        case IP6:
          _switchResult = "6";
          break;
        case ALL:
          _switchResult = "all";
          break;
        case IP4_NO_PRIV:
          _switchResult = "4_no_priv";
          break;
        case IP6_NO_PRIV:
          _switchResult = "6_no_priv";
          break;
        case ALL_NO_PRIV:
          _switchResult = "all_no_priv";
          break;
        case IP4_NO_RES:
          _switchResult = "4_no_res";
          break;
        case IP6_NO_RES:
          _switchResult = "6_no_res";
          break;
        case ALL_NO_RES:
          _switchResult = "all_no_res";
          break;
        case IP4_PUBLIC:
          _switchResult = "4_public";
          break;
        case IP6_PUBLIC:
          _switchResult = "6_public";
          break;
        case ALL_PUBLIC:
          _switchResult = "all_public";
          break;
        default:
          _switchResult = "";
          break;
      }
    } else {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string describing the type of the given derived field.
   */
  public String fieldTypeAsString(final DerivedField it) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof BooleanField) {
      _matched=true;
      _switchResult = "boolean";
    }
    if (!_matched) {
      if (it instanceof UserField) {
        _matched=true;
        _switchResult = "UserEntity";
      }
    }
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        _matched=true;
        String _xifexpression = null;
        int _length = ((AbstractIntegerField)it).getLength();
        boolean _lessThan = (_length < 5);
        if (_lessThan) {
          _xifexpression = "smallint";
        } else {
          String _xifexpression_1 = null;
          int _length_1 = ((AbstractIntegerField)it).getLength();
          boolean _lessThan_1 = (_length_1 < 12);
          if (_lessThan_1) {
            _xifexpression_1 = "integer";
          } else {
            _xifexpression_1 = "bigint";
          }
          _xifexpression = _xifexpression_1;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        _matched=true;
        _switchResult = "decimal";
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        _matched=true;
        _switchResult = "text";
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        _matched=true;
        _switchResult = "array";
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        _matched=true;
        _switchResult = "object";
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        _matched=true;
        _switchResult = "DateTime";
      }
    }
    if (!_matched) {
      if (it instanceof DateField) {
        _matched=true;
        _switchResult = "date";
      }
    }
    if (!_matched) {
      if (it instanceof TimeField) {
        _matched=true;
        _switchResult = "time";
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        _matched=true;
        _switchResult = "float";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
}
