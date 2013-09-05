package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ArrayField;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityChangeTrackingPolicy;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.EntityIdentifierStrategy;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndex;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexType;
import de.guite.modulestudio.metamodel.modulestudio.EntityLockType;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem;
import de.guite.modulestudio.metamodel.modulestudio.ListVar;
import de.guite.modulestudio.metamodel.modulestudio.ListVarItem;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.ObjectField;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.TimeField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UploadNamingScheme;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.extensions.CollectionUtils;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * This class contains model related extension methods.
 * TODO document class and methods.
 */
@SuppressWarnings("all")
public class ModelExtensions {
  @Inject
  @Extension
  private CollectionUtils _collectionUtils = new Function0<CollectionUtils>() {
    public CollectionUtils apply() {
      CollectionUtils _collectionUtils = new CollectionUtils();
      return _collectionUtils;
    }
  }.apply();
  
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelInheritanceExtensions _modelInheritanceExtensions = new Function0<ModelInheritanceExtensions>() {
    public ModelInheritanceExtensions apply() {
      ModelInheritanceExtensions _modelInheritanceExtensions = new ModelInheritanceExtensions();
      return _modelInheritanceExtensions;
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
  
  /**
   * Returns a list of all entities in this application.
   */
  public EList<Entity> getAllEntities(final Application it) {
    EList<Entity> _xblockexpression = null;
    {
      EList<Models> _models = it.getModels();
      Models _head = IterableExtensions.<Models>head(_models);
      EList<Entity> allEntities = _head.getEntities();
      EList<Models> _models_1 = it.getModels();
      Iterable<Models> _tail = IterableExtensions.<Models>tail(_models_1);
      for (final Models entityContainer : _tail) {
        EList<Entity> _entities = entityContainer.getEntities();
        allEntities.addAll(_entities);
      }
      _xblockexpression = (allEntities);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all entities in the primary model container.
   */
  public EList<Entity> getEntitiesFromDefaultDataSource(final Application it) {
    Models _defaultDataSource = this.getDefaultDataSource(it);
    EList<Entity> _entities = _defaultDataSource.getEntities();
    return _entities;
  }
  
  /**
   * Returns a list of all entity fields in this application.
   */
  public List<EntityField> getAllEntityFields(final Application it) {
    EList<Entity> _allEntities = this.getAllEntities(it);
    final Function1<Entity,EList<EntityField>> _function = new Function1<Entity,EList<EntityField>>() {
      public EList<EntityField> apply(final Entity e) {
        EList<EntityField> _fields = e.getFields();
        return _fields;
      }
    };
    List<EList<EntityField>> _map = ListExtensions.<Entity, EList<EntityField>>map(_allEntities, _function);
    Iterable<EntityField> _flatten = Iterables.<EntityField>concat(_map);
    List<EntityField> _list = IterableExtensions.<EntityField>toList(_flatten);
    return _list;
  }
  
  /**
   * Returns a list of all entity fields in a certain model container.
   */
  public List<EntityField> getModelEntityFields(final Models it) {
    EList<Entity> _entities = it.getEntities();
    final Function1<Entity,EList<EntityField>> _function = new Function1<Entity,EList<EntityField>>() {
      public EList<EntityField> apply(final Entity e) {
        EList<EntityField> _fields = e.getFields();
        return _fields;
      }
    };
    List<EList<EntityField>> _map = ListExtensions.<Entity, EList<EntityField>>map(_entities, _function);
    Iterable<EntityField> _flatten = Iterables.<EntityField>concat(_map);
    List<EntityField> _list = IterableExtensions.<EntityField>toList(_flatten);
    return _list;
  }
  
  /**
   * Returns the leading entity in the primary model container.
   */
  public Entity getLeadingEntity(final Application it) {
    EList<Entity> _entitiesFromDefaultDataSource = this.getEntitiesFromDefaultDataSource(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _isLeading = e.isLeading();
        return Boolean.valueOf(_isLeading);
      }
    };
    Entity _findFirst = IterableExtensions.<Entity>findFirst(_entitiesFromDefaultDataSource, _function);
    return _findFirst;
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one image field.
   */
  public boolean hasImageFields(final Application it) {
    EList<Entity> _allEntities = this.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasImageFieldsEntity = ModelExtensions.this.hasImageFieldsEntity(e);
        return Boolean.valueOf(_hasImageFieldsEntity);
      }
    };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    return _exists;
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one colour field.
   */
  public boolean hasColourFields(final Application it) {
    EList<Entity> _allEntities = this.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasColourFieldsEntity = ModelExtensions.this.hasColourFieldsEntity(e);
        return Boolean.valueOf(_hasColourFieldsEntity);
      }
    };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    return _exists;
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one country field.
   */
  public boolean hasCountryFields(final Application it) {
    EList<Entity> _allEntities = this.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasCountryFieldsEntity = ModelExtensions.this.hasCountryFieldsEntity(e);
        return Boolean.valueOf(_hasCountryFieldsEntity);
      }
    };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    return _exists;
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one upload field.
   */
  public boolean hasUploads(final Application it) {
    Iterable<Entity> _uploadEntities = this.getUploadEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_uploadEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with at least one upload field.
   */
  public Iterable<Entity> getUploadEntities(final Application it) {
    EList<Entity> _allEntities = this.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasUploadFieldsEntity = ModelExtensions.this.hasUploadFieldsEntity(e);
        return Boolean.valueOf(_hasUploadFieldsEntity);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Returns a list of all user fields in this application.
   */
  public Iterable<UserField> getAllUserFields(final Application it) {
    List<EntityField> _allEntityFields = this.getAllEntityFields(it);
    Iterable<UserField> _filter = Iterables.<UserField>filter(_allEntityFields, UserField.class);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one user field.
   */
  public boolean hasUserFields(final Application it) {
    Iterable<UserField> _allUserFields = this.getAllUserFields(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_allUserFields);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all list fields in this application.
   */
  public Iterable<ListField> getAllListFields(final Application it) {
    List<EntityField> _allEntityFields = this.getAllEntityFields(it);
    Iterable<ListField> _filter = Iterables.<ListField>filter(_allEntityFields, ListField.class);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one list field.
   */
  public boolean hasListFields(final Application it) {
    Iterable<ListField> _allListFields = this.getAllListFields(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_allListFields);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with at least one list field.
   */
  public Iterable<Entity> getListEntities(final Application it) {
    EList<Entity> _allEntities = this.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasListFieldsEntity = ModelExtensions.this.hasListFieldsEntity(e);
        return Boolean.valueOf(_hasListFieldsEntity);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled.
   */
  public boolean hasBooleansWithAjaxToggle(final Application it) {
    Iterable<Entity> _entitiesWithAjaxToggle = this.getEntitiesWithAjaxToggle(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_entitiesWithAjaxToggle);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with at least one boolean field having ajax toggle enabled.
   */
  public Iterable<Entity> getEntitiesWithAjaxToggle(final Application it) {
    EList<Entity> _allEntities = this.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasBooleansWithAjaxToggleEntity = ModelExtensions.this.hasBooleansWithAjaxToggleEntity(e);
        return Boolean.valueOf(_hasBooleansWithAjaxToggleEntity);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Returns the first model container which is default data source.
   */
  public Models getDefaultDataSource(final Application it) {
    EList<Models> _models = it.getModels();
    final Function1<Models,Boolean> _function = new Function1<Models,Boolean>() {
      public Boolean apply(final Models e) {
        boolean _isDefaultDataSource = e.isDefaultDataSource();
        boolean _equals = (_isDefaultDataSource == true);
        return Boolean.valueOf(_equals);
      }
    };
    Models _findFirst = IterableExtensions.<Models>findFirst(_models, _function);
    return _findFirst;
  }
  
  /**
   * Prepends the application database prefix to a given string.
   * Beginning with Zikula 1.3.6 the vendor is prefixed, too.
   */
  public String tableNameWithPrefix(final Application it, final String inputString) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _prefix = it.getPrefix();
      String _plus = (_prefix + "_");
      String _plus_1 = (_plus + inputString);
      _xifexpression = _plus_1;
    } else {
      String _vendor = it.getVendor();
      String _formatForDB = this._formattingExtensions.formatForDB(_vendor);
      String _plus_2 = (_formatForDB + "_");
      String _prefix_1 = this._utils.prefix(it);
      String _plus_3 = (_plus_2 + _prefix_1);
      String _plus_4 = (_plus_3 + "_");
      String _plus_5 = (_plus_4 + inputString);
      _xifexpression = _plus_5;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the full table name for a given entity instance.
   */
  public String fullEntityTableName(final Entity it) {
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    String _tableNameWithPrefix = this.tableNameWithPrefix(_application, _formatForDB);
    return _tableNameWithPrefix;
  }
  
  /**
   * Returns either the plural or the singular entity name, depending on a given boolean.
   */
  public String getEntityNameSingularPlural(final Entity it, final Boolean usePlural) {
    String _xifexpression = null;
    if ((usePlural).booleanValue()) {
      String _nameMultiple = it.getNameMultiple();
      _xifexpression = _nameMultiple;
    } else {
      String _name = it.getName();
      _xifexpression = _name;
    }
    return _xifexpression;
  }
  
  /**
   * Checks whether this entity has at least one normal (non-unique) index.
   */
  public boolean hasNormalIndexes(final Entity it) {
    Iterable<EntityIndex> _normalIndexes = this.getNormalIndexes(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_normalIndexes);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all normal (non-unique) indexes for this entity.
   */
  public Iterable<EntityIndex> getNormalIndexes(final Entity it) {
    EList<EntityIndex> _indexes = it.getIndexes();
    final Function1<EntityIndex,Boolean> _function = new Function1<EntityIndex,Boolean>() {
      public Boolean apply(final EntityIndex e) {
        EntityIndexType _type = e.getType();
        boolean _equals = Objects.equal(_type, EntityIndexType.NORMAL);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<EntityIndex> _filter = IterableExtensions.<EntityIndex>filter(_indexes, _function);
    return _filter;
  }
  
  /**
   * Checks whether this entity has at least one unique index.
   */
  public boolean hasUniqueIndexes(final Entity it) {
    Iterable<EntityIndex> _uniqueIndexes = this.getUniqueIndexes(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_uniqueIndexes);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all unique indexes for this entity.
   */
  public Iterable<EntityIndex> getUniqueIndexes(final Entity it) {
    EList<EntityIndex> _indexes = it.getIndexes();
    final Function1<EntityIndex,Boolean> _function = new Function1<EntityIndex,Boolean>() {
      public Boolean apply(final EntityIndex e) {
        EntityIndexType _type = e.getType();
        boolean _equals = Objects.equal(_type, EntityIndexType.UNIQUE);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<EntityIndex> _filter = IterableExtensions.<EntityIndex>filter(_indexes, _function);
    return _filter;
  }
  
  /**
   * Returns a list of all derived fields (excluding calculated fields) of the given entity.
   */
  public Iterable<DerivedField> getDerivedFields(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<DerivedField> _filter = Iterables.<DerivedField>filter(_fields, DerivedField.class);
    return _filter;
  }
  
  /**
   * Returns a list of all derived and unique fields of the given entity
   */
  public Iterable<DerivedField> getUniqueDerivedFields(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
      public Boolean apply(final DerivedField e) {
        boolean _isUnique = e.isUnique();
        return Boolean.valueOf(_isUnique);
      }
    };
    Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
    return _filter;
  }
  
  /**
   * Returns the field having leading = true of this entity.
   */
  public DerivedField getLeadingField(final Entity it) {
    DerivedField _xifexpression = null;
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_derivedFields);
    boolean _not = (!_isEmpty);
    if (_not) {
      Iterable<DerivedField> _derivedFields_1 = this.getDerivedFields(it);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          boolean _isLeading = e.isLeading();
          boolean _equals = (_isLeading == true);
          return Boolean.valueOf(_equals);
        }
      };
      DerivedField _findFirst = IterableExtensions.<DerivedField>findFirst(_derivedFields_1, _function);
      _xifexpression = _findFirst;
    } else {
      DerivedField _xifexpression_1 = null;
      boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting) {
        Entity _parentType = this._modelInheritanceExtensions.parentType(it);
        DerivedField _leadingField = this.getLeadingField(_parentType);
        _xifexpression_1 = _leadingField;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns a list of all derived and primary key fields of the given entity.
   */
  public Iterable<DerivedField> getPrimaryKeyFields(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
      public Boolean apply(final DerivedField e) {
        boolean _isPrimaryKey = e.isPrimaryKey();
        boolean _equals = (_isPrimaryKey == true);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
    return _filter;
  }
  
  /**
   * Returns the first derived and primary key field of the given entity.
   */
  public DerivedField getFirstPrimaryKey(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
      public Boolean apply(final DerivedField e) {
        boolean _isPrimaryKey = e.isPrimaryKey();
        boolean _equals = (_isPrimaryKey == true);
        return Boolean.valueOf(_equals);
      }
    };
    DerivedField _findFirst = IterableExtensions.<DerivedField>findFirst(_derivedFields, _function);
    return _findFirst;
  }
  
  /**
   * Checks whether the entity has more than one primary key fields.
   */
  public boolean hasCompositeKeys(final Entity it) {
    Iterable<DerivedField> _primaryKeyFields = this.getPrimaryKeyFields(it);
    int _size = IterableExtensions.size(_primaryKeyFields);
    boolean _greaterThan = (_size > 1);
    return _greaterThan;
  }
  
  /**
   * Concatenates all id strings using underscore as delimiter.
   * Used for generating some controller classes.
   */
  public CharSequence idFieldsAsParameterCode(final Entity it, final String objVar) {
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
            _builder.append("$this->");
            String _name = pkField.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "");
          }
        }
      } else {
        _builder.append("$this->");
        DerivedField _firstPrimaryKey = this.getFirstPrimaryKey(it);
        String _name_1 = _firstPrimaryKey.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
      }
    }
    return _builder;
  }
  
  /**
   * Concatenates all id strings using underscore as delimiter.
   * Used for generating some view templates.
   */
  public CharSequence idFieldsAsParameterTemplate(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<DerivedField> _primaryKeyFields = this.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("_", "");
        }
        _builder.append("`$");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append(".");
        String _name_1 = pkField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("`");
      }
    }
    return _builder;
  }
  
  /**
   * Returns a list of all fields which should be displayed.
   */
  public List<DerivedField> getDisplayFieldsForView(final Entity it) {
    List<DerivedField> _xblockexpression = null;
    {
      Iterable<DerivedField> _displayFields = this.getDisplayFields(it);
      Iterable<? extends Object> _exclude = this._collectionUtils.exclude(_displayFields, ArrayField.class);
      Iterable<? extends Object> fields = this._collectionUtils.exclude(_exclude, ObjectField.class);
      List<? extends Object> _list = IterableExtensions.toList(fields);
      _xblockexpression = (((List<DerivedField>) _list));
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all fields which should be displayed.
   */
  public Iterable<DerivedField> getDisplayFields(final Entity it) {
    Iterable<DerivedField> _xblockexpression = null;
    {
      Iterable<DerivedField> fields = this.getDerivedFields(it);
      EntityIdentifierStrategy _identifierStrategy = it.getIdentifierStrategy();
      boolean _notEquals = (!Objects.equal(_identifierStrategy, EntityIdentifierStrategy.NONE));
      if (_notEquals) {
        final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
          public Boolean apply(final DerivedField e) {
            boolean _isPrimaryKey = e.isPrimaryKey();
            boolean _not = (!_isPrimaryKey);
            return Boolean.valueOf(_not);
          }
        };
        Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(fields, _function);
        fields = _filter;
      }
      boolean _hasVisibleWorkflow = this._workflowExtensions.hasVisibleWorkflow(it);
      boolean _not = (!_hasVisibleWorkflow);
      if (_not) {
        final Function1<DerivedField,Boolean> _function_1 = new Function1<DerivedField,Boolean>() {
          public Boolean apply(final DerivedField e) {
            String _name = e.getName();
            boolean _notEquals = (!Objects.equal(_name, "workflowState"));
            return Boolean.valueOf(_notEquals);
          }
        };
        Iterable<DerivedField> _filter_1 = IterableExtensions.<DerivedField>filter(fields, _function_1);
        fields = _filter_1;
      }
      _xblockexpression = (fields);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all fields which should be displayed.
   */
  public Iterable<DerivedField> getLeadingDisplayFields(final Entity it) {
    Iterable<DerivedField> _xblockexpression = null;
    {
      Iterable<DerivedField> _displayFields = this.getDisplayFields(it);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          String _name = e.getName();
          boolean _notEquals = (!Objects.equal(_name, "workflowState"));
          return Boolean.valueOf(_notEquals);
        }
      };
      Iterable<DerivedField> fields = IterableExtensions.<DerivedField>filter(_displayFields, _function);
      boolean _and = false;
      DerivedField _leadingField = this.getLeadingField(it);
      boolean _tripleNotEquals = (_leadingField != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        DerivedField _leadingField_1 = this.getLeadingField(it);
        boolean _showLeadingFieldInTitle = this.showLeadingFieldInTitle(_leadingField_1);
        _and = (_tripleNotEquals && _showLeadingFieldInTitle);
      }
      if (_and) {
        final Function1<DerivedField,Boolean> _function_1 = new Function1<DerivedField,Boolean>() {
          public Boolean apply(final DerivedField e) {
            boolean _isLeading = e.isLeading();
            boolean _not = (!_isLeading);
            return Boolean.valueOf(_not);
          }
        };
        Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(fields, _function_1);
        fields = _filter;
      }
      _xblockexpression = (fields);
    }
    return _xblockexpression;
  }
  
  public boolean showLeadingFieldInTitle(final DerivedField it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof IntegerField) {
        final IntegerField _integerField = (IntegerField)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        final StringField _stringField = (StringField)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        final TextField _textField = (TextField)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  /**
   * Returns a list of all editable fields of the given entity.
   * At the moment instances of ArrayField and ObjectField are excluded.
   */
  public List<DerivedField> getEditableFields(final Entity it) {
    List<DerivedField> _xblockexpression = null;
    {
      Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          String _name = e.getName();
          boolean _notEquals = (!Objects.equal(_name, "workflowState"));
          return Boolean.valueOf(_notEquals);
        }
      };
      Iterable<DerivedField> fields = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
      EntityIdentifierStrategy _identifierStrategy = it.getIdentifierStrategy();
      boolean _notEquals = (!Objects.equal(_identifierStrategy, EntityIdentifierStrategy.NONE));
      if (_notEquals) {
        final Function1<DerivedField,Boolean> _function_1 = new Function1<DerivedField,Boolean>() {
          public Boolean apply(final DerivedField e) {
            boolean _isPrimaryKey = e.isPrimaryKey();
            boolean _not = (!_isPrimaryKey);
            return Boolean.valueOf(_not);
          }
        };
        Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(fields, _function_1);
        fields = _filter;
      }
      Iterable<? extends Object> _exclude = this._collectionUtils.exclude(fields, ArrayField.class);
      final Iterable<? extends Object> wantedFields = this._collectionUtils.exclude(_exclude, ObjectField.class);
      List<? extends Object> _list = IterableExtensions.toList(wantedFields);
      _xblockexpression = (((List<DerivedField>) _list));
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all fields of the given entity for which we provide example data.
   * At the moment instances of UploadField are excluded.
   */
  public List<DerivedField> getFieldsForExampleData(final Entity it) {
    List<DerivedField> _xblockexpression = null;
    {
      Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          boolean _isPrimaryKey = e.isPrimaryKey();
          boolean _not = (!_isPrimaryKey);
          return Boolean.valueOf(_not);
        }
      };
      Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
      final Iterable<? extends Object> exampleFields = this._collectionUtils.exclude(_filter, UploadField.class);
      List<? extends Object> _list = IterableExtensions.toList(exampleFields);
      _xblockexpression = (((List<DerivedField>) _list));
    }
    return _xblockexpression;
  }
  
  /**
   * Checks whether this entity has at least one user field.
   */
  public boolean hasUserFieldsEntity(final Entity it) {
    Iterable<UserField> _userFieldsEntity = this.getUserFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_userFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all user fields of this entity.
   */
  public Iterable<UserField> getUserFieldsEntity(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<UserField> _filter = Iterables.<UserField>filter(_fields, UserField.class);
    return _filter;
  }
  
  /**
   * Checks whether this entity has at least one upload field.
   */
  public boolean hasUploadFieldsEntity(final Entity it) {
    Iterable<UploadField> _uploadFieldsEntity = this.getUploadFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_uploadFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all upload fields of this entity.
   */
  public Iterable<UploadField> getUploadFieldsEntity(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<UploadField> _filter = Iterables.<UploadField>filter(_fields, UploadField.class);
    return _filter;
  }
  
  /**
   * Checks whether this entity has at least one list field.
   */
  public boolean hasListFieldsEntity(final Entity it) {
    Iterable<ListField> _listFieldsEntity = this.getListFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_listFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all list fields of this entity.
   */
  public Iterable<ListField> getListFieldsEntity(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<ListField> _filter = Iterables.<ListField>filter(_fields, ListField.class);
    return _filter;
  }
  
  /**
   * Returns a list of all default items of this list.
   */
  public Iterable<ListFieldItem> getDefaultItems(final ListField it) {
    EList<ListFieldItem> _items = it.getItems();
    final Function1<ListFieldItem,Boolean> _function = new Function1<ListFieldItem,Boolean>() {
      public Boolean apply(final ListFieldItem e) {
        boolean _isDefault = e.isDefault();
        return Boolean.valueOf(_isDefault);
      }
    };
    Iterable<ListFieldItem> _filter = IterableExtensions.<ListFieldItem>filter(_items, _function);
    return _filter;
  }
  
  /**
   * Returns a list of all default items of this list.
   */
  public Iterable<ListVarItem> getDefaultItems(final ListVar it) {
    EList<ListVarItem> _items = it.getItems();
    final Function1<ListVarItem,Boolean> _function = new Function1<ListVarItem,Boolean>() {
      public Boolean apply(final ListVarItem e) {
        boolean _isDefault = e.isDefault();
        return Boolean.valueOf(_isDefault);
      }
    };
    Iterable<ListVarItem> _filter = IterableExtensions.<ListVarItem>filter(_items, _function);
    return _filter;
  }
  
  /**
   * Checks whether this entity has at least one image field.
   */
  public boolean hasImageFieldsEntity(final Entity it) {
    Iterable<UploadField> _imageFieldsEntity = this.getImageFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_imageFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all image fields of this entity.
   */
  public Iterable<UploadField> getImageFieldsEntity(final Entity it) {
    Iterable<UploadField> _uploadFieldsEntity = this.getUploadFieldsEntity(it);
    final Function1<UploadField,Boolean> _function = new Function1<UploadField,Boolean>() {
      public Boolean apply(final UploadField e) {
        String _allowedExtensions = e.getAllowedExtensions();
        String[] _split = _allowedExtensions.split(", ");
        final Function1<String,Boolean> _function = new Function1<String,Boolean>() {
          public Boolean apply(final String ext) {
            boolean _or = false;
            boolean _or_1 = false;
            boolean _or_2 = false;
            boolean _equals = Objects.equal(ext, "gif");
            if (_equals) {
              _or_2 = true;
            } else {
              boolean _equals_1 = Objects.equal(ext, "jpeg");
              _or_2 = (_equals || _equals_1);
            }
            if (_or_2) {
              _or_1 = true;
            } else {
              boolean _equals_2 = Objects.equal(ext, "jpg");
              _or_1 = (_or_2 || _equals_2);
            }
            if (_or_1) {
              _or = true;
            } else {
              boolean _equals_3 = Objects.equal(ext, "png");
              _or = (_or_1 || _equals_3);
            }
            return Boolean.valueOf(_or);
          }
        };
        boolean _forall = IterableExtensions.<String>forall(((Iterable<String>)Conversions.doWrapArray(_split)), _function);
        return Boolean.valueOf(_forall);
      }
    };
    Iterable<UploadField> _filter = IterableExtensions.<UploadField>filter(_uploadFieldsEntity, _function);
    return _filter;
  }
  
  /**
   * Checks whether this entity has at least one colour field.
   */
  public boolean hasColourFieldsEntity(final Entity it) {
    Iterable<StringField> _colourFieldsEntity = this.getColourFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_colourFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all colour fields of this entity.
   */
  public Iterable<StringField> getColourFieldsEntity(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    Iterable<StringField> _filter = Iterables.<StringField>filter(_derivedFields, StringField.class);
    final Function1<StringField,Boolean> _function = new Function1<StringField,Boolean>() {
      public Boolean apply(final StringField e) {
        boolean _isHtmlcolour = e.isHtmlcolour();
        return Boolean.valueOf(_isHtmlcolour);
      }
    };
    Iterable<StringField> _filter_1 = IterableExtensions.<StringField>filter(_filter, _function);
    return _filter_1;
  }
  
  /**
   * Checks whether this entity has at least one country field.
   */
  public boolean hasCountryFieldsEntity(final Entity it) {
    Iterable<StringField> _countryFieldsEntity = this.getCountryFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_countryFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all country fields of this entity.
   */
  public Iterable<StringField> getCountryFieldsEntity(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    Iterable<StringField> _filter = Iterables.<StringField>filter(_derivedFields, StringField.class);
    final Function1<StringField,Boolean> _function = new Function1<StringField,Boolean>() {
      public Boolean apply(final StringField e) {
        boolean _isCountry = e.isCountry();
        boolean _equals = (_isCountry == true);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<StringField> _filter_1 = IterableExtensions.<StringField>filter(_filter, _function);
    return _filter_1;
  }
  
  /**
   * Checks whether this entity has at least one language field.
   */
  public boolean hasLanguageFieldsEntity(final Entity it) {
    Iterable<StringField> _languageFieldsEntity = this.getLanguageFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_languageFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all language fields of this entity.
   */
  public Iterable<StringField> getLanguageFieldsEntity(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    Iterable<StringField> _filter = Iterables.<StringField>filter(_derivedFields, StringField.class);
    final Function1<StringField,Boolean> _function = new Function1<StringField,Boolean>() {
      public Boolean apply(final StringField e) {
        boolean _isLanguage = e.isLanguage();
        boolean _equals = (_isLanguage == true);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<StringField> _filter_1 = IterableExtensions.<StringField>filter(_filter, _function);
    return _filter_1;
  }
  
  /**
   * Checks whether this entity has at least one textual field.
   */
  public boolean hasAbstractStringFieldsEntity(final Entity it) {
    Iterable<AbstractStringField> _abstractStringFieldsEntity = this.getAbstractStringFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_abstractStringFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all textual fields of this entity.
   */
  public Iterable<AbstractStringField> getAbstractStringFieldsEntity(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    Iterable<AbstractStringField> _filter = Iterables.<AbstractStringField>filter(_derivedFields, AbstractStringField.class);
    return _filter;
  }
  
  /**
   * Checks whether this entity has at least one string field.
   */
  public boolean hasStringFieldsEntity(final Entity it) {
    Iterable<StringField> _stringFieldsEntity = this.getStringFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_stringFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all string fields of this entity.
   */
  public Iterable<StringField> getStringFieldsEntity(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    Iterable<StringField> _filter = Iterables.<StringField>filter(_derivedFields, StringField.class);
    return _filter;
  }
  
  /**
   * Checks whether this entity has at least one text field.
   */
  public boolean hasTextFieldsEntity(final Entity it) {
    Iterable<TextField> _textFieldsEntity = this.getTextFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_textFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all text fields of this entity.
   */
  public Iterable<TextField> getTextFieldsEntity(final Entity it) {
    Iterable<DerivedField> _derivedFields = this.getDerivedFields(it);
    Iterable<TextField> _filter = Iterables.<TextField>filter(_derivedFields, TextField.class);
    return _filter;
  }
  
  /**
   * Returns a list of all boolean fields of this entity.
   */
  public Iterable<BooleanField> getBooleanFieldsEntity(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<BooleanField> _filter = Iterables.<BooleanField>filter(_fields, BooleanField.class);
    return _filter;
  }
  
  /**
   * Checks whether this entity has at least one boolean field.
   */
  public boolean hasBooleanFieldsEntity(final Entity it) {
    Iterable<BooleanField> _booleanFieldsEntity = this.getBooleanFieldsEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_booleanFieldsEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Checks whether this entity has at least one boolean field having ajax toggle enabled.
   */
  public boolean hasBooleansWithAjaxToggleEntity(final Entity it) {
    Iterable<BooleanField> _booleansWithAjaxToggleEntity = this.getBooleansWithAjaxToggleEntity(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_booleansWithAjaxToggleEntity);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all boolean fields having ajax toggle enabled.
   */
  public Iterable<BooleanField> getBooleansWithAjaxToggleEntity(final Entity it) {
    Iterable<BooleanField> _booleanFieldsEntity = this.getBooleanFieldsEntity(it);
    final Function1<BooleanField,Boolean> _function = new Function1<BooleanField,Boolean>() {
      public Boolean apply(final BooleanField e) {
        boolean _isAjaxTogglability = e.isAjaxTogglability();
        return Boolean.valueOf(_isAjaxTogglability);
      }
    };
    Iterable<BooleanField> _filter = IterableExtensions.<BooleanField>filter(_booleanFieldsEntity, _function);
    return _filter;
  }
  
  /**
   * Returns a list of all integer fields which are used as aggregates.
   */
  public Iterable<IntegerField> getAggregateFields(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<IntegerField> _filter = Iterables.<IntegerField>filter(_fields, IntegerField.class);
    final Function1<IntegerField,Boolean> _function = new Function1<IntegerField,Boolean>() {
      public Boolean apply(final IntegerField e) {
        boolean _and = false;
        String _aggregateFor = e.getAggregateFor();
        boolean _tripleNotEquals = (_aggregateFor != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _aggregateFor_1 = e.getAggregateFor();
          boolean _notEquals = (!Objects.equal(_aggregateFor_1, ""));
          _and = (_tripleNotEquals && _notEquals);
        }
        return Boolean.valueOf(_and);
      }
    };
    Iterable<IntegerField> _filter_1 = IterableExtensions.<IntegerField>filter(_filter, _function);
    return _filter_1;
  }
  
  /**
   * Returns the subfolder path segment for this upload field,
   * that is either the subFolderName attribute (if set) or the name otherwise.
   */
  public String subFolderPathSegment(final UploadField it) {
    String _xifexpression = null;
    boolean _and = false;
    String _subFolderName = it.getSubFolderName();
    boolean _tripleNotEquals = (_subFolderName != null);
    if (!_tripleNotEquals) {
      _and = false;
    } else {
      String _subFolderName_1 = it.getSubFolderName();
      boolean _notEquals = (!Objects.equal(_subFolderName_1, ""));
      _and = (_tripleNotEquals && _notEquals);
    }
    if (_and) {
      String _subFolderName_2 = it.getSubFolderName();
      _xifexpression = _subFolderName_2;
    } else {
      String _name = it.getName();
      _xifexpression = _name;
    }
    String _formatForDB = this._formattingExtensions.formatForDB(_xifexpression);
    return _formatForDB;
  }
  
  /**
   * Prints an output number corresponding to the given upload naming scheme.
   */
  public String namingSchemeAsInt(final UploadField it) {
    String _switchResult = null;
    UploadNamingScheme _namingScheme = it.getNamingScheme();
    final UploadNamingScheme getNamingScheme = _namingScheme;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(getNamingScheme,UploadNamingScheme.ORIGINALWITHCOUNTER)) {
        _matched=true;
        _switchResult = "0";
      }
    }
    if (!_matched) {
      if (Objects.equal(getNamingScheme,UploadNamingScheme.RANDOMCHECKSUM)) {
        _matched=true;
        _switchResult = "1";
      }
    }
    if (!_matched) {
      if (Objects.equal(getNamingScheme,UploadNamingScheme.FIELDNAMEWITHCOUNTER)) {
        _matched=true;
        _switchResult = "2";
      }
    }
    if (!_matched) {
      _switchResult = "0";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string corresponding to the given identifier strategy.
   */
  public String asConstant(final EntityIdentifierStrategy strategy) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(strategy,EntityIdentifierStrategy.NONE)) {
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (Objects.equal(strategy,EntityIdentifierStrategy.AUTO)) {
        _matched=true;
        _switchResult = "AUTO";
      }
    }
    if (!_matched) {
      if (Objects.equal(strategy,EntityIdentifierStrategy.SEQUENCE)) {
        _matched=true;
        _switchResult = "SEQUENCE";
      }
    }
    if (!_matched) {
      if (Objects.equal(strategy,EntityIdentifierStrategy.TABLE)) {
        _matched=true;
        _switchResult = "TABLE";
      }
    }
    if (!_matched) {
      if (Objects.equal(strategy,EntityIdentifierStrategy.IDENTITY)) {
        _matched=true;
        _switchResult = "IDENTITY";
      }
    }
    if (!_matched) {
      if (Objects.equal(strategy,EntityIdentifierStrategy.UUID)) {
        _matched=true;
        _switchResult = "UUID";
      }
    }
    if (!_matched) {
      if (Objects.equal(strategy,EntityIdentifierStrategy.CUSTOM)) {
        _matched=true;
        _switchResult = "CUSTOM";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string corresponding to the given change tracking policy.
   */
  public String asConstant(final EntityChangeTrackingPolicy policy) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(policy,EntityChangeTrackingPolicy.DEFERRED_IMPLICIT)) {
        _matched=true;
        _switchResult = "DEFERRED_IMPLICIT";
      }
    }
    if (!_matched) {
      if (Objects.equal(policy,EntityChangeTrackingPolicy.DEFERRED_EXPLICIT)) {
        _matched=true;
        _switchResult = "DEFERRED_EXPLICIT";
      }
    }
    if (!_matched) {
      if (Objects.equal(policy,EntityChangeTrackingPolicy.NOTIFY)) {
        _matched=true;
        _switchResult = "NOTIFY";
      }
    }
    if (!_matched) {
      _switchResult = "DEFERRED_IMPLICIT";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string corresponding to the given entity lock type.
   */
  public String asConstant(final EntityLockType lockType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(lockType,EntityLockType.NONE)) {
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (Objects.equal(lockType,EntityLockType.OPTIMISTIC)) {
        _matched=true;
        _switchResult = "OPTIMISTIC";
      }
    }
    if (!_matched) {
      if (Objects.equal(lockType,EntityLockType.PESSIMISTIC_READ)) {
        _matched=true;
        _switchResult = "PESSIMISTIC_READ";
      }
    }
    if (!_matched) {
      if (Objects.equal(lockType,EntityLockType.PESSIMISTIC_WRITE)) {
        _matched=true;
        _switchResult = "PESSIMISTIC_WRITE";
      }
    }
    if (!_matched) {
      if (Objects.equal(lockType,EntityLockType.PAGELOCK)) {
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (Objects.equal(lockType,EntityLockType.PAGELOCK_OPTIMISTIC)) {
        _matched=true;
        _switchResult = "OPTIMISTIC";
      }
    }
    if (!_matched) {
      if (Objects.equal(lockType,EntityLockType.PAGELOCK_PESSIMISTIC_READ)) {
        _matched=true;
        _switchResult = "PESSIMISTIC_READ";
      }
    }
    if (!_matched) {
      if (Objects.equal(lockType,EntityLockType.PAGELOCK_PESSIMISTIC_WRITE)) {
        _matched=true;
        _switchResult = "PESSIMISTIC_WRITE";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  public boolean hasNotifyPolicy(final Entity it) {
    EntityChangeTrackingPolicy _changeTrackingPolicy = it.getChangeTrackingPolicy();
    boolean _equals = Objects.equal(_changeTrackingPolicy, EntityChangeTrackingPolicy.NOTIFY);
    return _equals;
  }
  
  public boolean hasOptimisticLock(final Entity it) {
    boolean _or = false;
    EntityLockType _lockType = it.getLockType();
    boolean _equals = Objects.equal(_lockType, EntityLockType.OPTIMISTIC);
    if (_equals) {
      _or = true;
    } else {
      EntityLockType _lockType_1 = it.getLockType();
      boolean _equals_1 = Objects.equal(_lockType_1, EntityLockType.PAGELOCK_OPTIMISTIC);
      _or = (_equals || _equals_1);
    }
    return _or;
  }
  
  public boolean hasPessimisticReadLock(final Entity it) {
    boolean _or = false;
    EntityLockType _lockType = it.getLockType();
    boolean _equals = Objects.equal(_lockType, EntityLockType.PESSIMISTIC_READ);
    if (_equals) {
      _or = true;
    } else {
      EntityLockType _lockType_1 = it.getLockType();
      boolean _equals_1 = Objects.equal(_lockType_1, EntityLockType.PAGELOCK_PESSIMISTIC_READ);
      _or = (_equals || _equals_1);
    }
    return _or;
  }
  
  public boolean hasPessimisticWriteLock(final Entity it) {
    boolean _or = false;
    EntityLockType _lockType = it.getLockType();
    boolean _equals = Objects.equal(_lockType, EntityLockType.PESSIMISTIC_WRITE);
    if (_equals) {
      _or = true;
    } else {
      EntityLockType _lockType_1 = it.getLockType();
      boolean _equals_1 = Objects.equal(_lockType_1, EntityLockType.PAGELOCK_PESSIMISTIC_WRITE);
      _or = (_equals || _equals_1);
    }
    return _or;
  }
  
  public boolean hasPageLockSupport(final Entity it) {
    boolean _or = false;
    boolean _or_1 = false;
    boolean _or_2 = false;
    EntityLockType _lockType = it.getLockType();
    boolean _equals = Objects.equal(_lockType, EntityLockType.PAGELOCK);
    if (_equals) {
      _or_2 = true;
    } else {
      EntityLockType _lockType_1 = it.getLockType();
      boolean _equals_1 = Objects.equal(_lockType_1, EntityLockType.PAGELOCK_OPTIMISTIC);
      _or_2 = (_equals || _equals_1);
    }
    if (_or_2) {
      _or_1 = true;
    } else {
      EntityLockType _lockType_2 = it.getLockType();
      boolean _equals_2 = Objects.equal(_lockType_2, EntityLockType.PAGELOCK_PESSIMISTIC_READ);
      _or_1 = (_or_2 || _equals_2);
    }
    if (_or_1) {
      _or = true;
    } else {
      EntityLockType _lockType_3 = it.getLockType();
      boolean _equals_3 = Objects.equal(_lockType_3, EntityLockType.PAGELOCK_PESSIMISTIC_WRITE);
      _or = (_or_1 || _equals_3);
    }
    return _or;
  }
  
  public DerivedField getVersionField(final Entity it) {
    DerivedField _xblockexpression = null;
    {
      EList<EntityField> _fields = it.getFields();
      Iterable<IntegerField> _filter = Iterables.<IntegerField>filter(_fields, IntegerField.class);
      final Function1<IntegerField,Boolean> _function = new Function1<IntegerField,Boolean>() {
        public Boolean apply(final IntegerField e) {
          boolean _isVersion = e.isVersion();
          return Boolean.valueOf(_isVersion);
        }
      };
      final Iterable<IntegerField> intVersions = IterableExtensions.<IntegerField>filter(_filter, _function);
      DerivedField _xifexpression = null;
      boolean _isEmpty = IterableExtensions.isEmpty(intVersions);
      boolean _not = (!_isEmpty);
      if (_not) {
        IntegerField _head = IterableExtensions.<IntegerField>head(intVersions);
        _xifexpression = _head;
      } else {
        DatetimeField _xblockexpression_1 = null;
        {
          EList<EntityField> _fields_1 = it.getFields();
          Iterable<DatetimeField> _filter_1 = Iterables.<DatetimeField>filter(_fields_1, DatetimeField.class);
          final Function1<DatetimeField,Boolean> _function_1 = new Function1<DatetimeField,Boolean>() {
            public Boolean apply(final DatetimeField e) {
              boolean _isVersion = e.isVersion();
              return Boolean.valueOf(_isVersion);
            }
          };
          final Iterable<DatetimeField> datetimeVersions = IterableExtensions.<DatetimeField>filter(_filter_1, _function_1);
          DatetimeField _xifexpression_1 = null;
          boolean _isEmpty_1 = IterableExtensions.isEmpty(datetimeVersions);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            DatetimeField _head_1 = IterableExtensions.<DatetimeField>head(datetimeVersions);
            _xifexpression_1 = _head_1;
          }
          _xblockexpression_1 = (_xifexpression_1);
        }
        _xifexpression = _xblockexpression_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  public boolean isDefaultIdField(final DerivedField it) {
    Entity _entity = it.getEntity();
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    boolean _isDefaultIdFieldName = this.isDefaultIdFieldName(_entity, _formatForDB);
    return _isDefaultIdFieldName;
  }
  
  public boolean isDefaultIdFieldName(final Entity it, final String s) {
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    String _plus = (_formatForDB + "id");
    String _name_1 = it.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_1);
    String _plus_1 = (_formatForDB_1 + "_id");
    ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList("id", _plus, _plus_1);
    boolean _contains = _newArrayList.contains(s);
    return _contains;
  }
  
  public boolean containsDefaultIdField(final Iterable<String> l, final Entity entity) {
    boolean _or = false;
    String _head = IterableExtensions.<String>head(l);
    boolean _isDefaultIdFieldName = this.isDefaultIdFieldName(entity, _head);
    if (_isDefaultIdFieldName) {
      _or = true;
    } else {
      boolean _and = false;
      int _size = IterableExtensions.size(l);
      boolean _greaterThan = (_size > 1);
      if (!_greaterThan) {
        _and = false;
      } else {
        Iterable<String> _tail = IterableExtensions.<String>tail(l);
        boolean _containsDefaultIdField = this.containsDefaultIdField(_tail, entity);
        _and = (_greaterThan && _containsDefaultIdField);
      }
      _or = (_isDefaultIdFieldName || _and);
    }
    return _or;
  }
  
  public AbstractDateField getStartDateField(final Entity it) {
    AbstractDateField _xblockexpression = null;
    {
      EList<EntityField> _fields = it.getFields();
      Iterable<DatetimeField> _filter = Iterables.<DatetimeField>filter(_fields, DatetimeField.class);
      final Function1<DatetimeField,Boolean> _function = new Function1<DatetimeField,Boolean>() {
        public Boolean apply(final DatetimeField e) {
          boolean _isStartDate = e.isStartDate();
          return Boolean.valueOf(_isStartDate);
        }
      };
      final Iterable<DatetimeField> datetimeFields = IterableExtensions.<DatetimeField>filter(_filter, _function);
      AbstractDateField _xifexpression = null;
      boolean _isEmpty = IterableExtensions.isEmpty(datetimeFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        DatetimeField _head = IterableExtensions.<DatetimeField>head(datetimeFields);
        _xifexpression = _head;
      } else {
        DateField _xblockexpression_1 = null;
        {
          EList<EntityField> _fields_1 = it.getFields();
          Iterable<DateField> _filter_1 = Iterables.<DateField>filter(_fields_1, DateField.class);
          final Function1<DateField,Boolean> _function_1 = new Function1<DateField,Boolean>() {
            public Boolean apply(final DateField e) {
              boolean _isStartDate = e.isStartDate();
              return Boolean.valueOf(_isStartDate);
            }
          };
          final Iterable<DateField> dateFields = IterableExtensions.<DateField>filter(_filter_1, _function_1);
          DateField _xifexpression_1 = null;
          boolean _isEmpty_1 = IterableExtensions.isEmpty(dateFields);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            DateField _head_1 = IterableExtensions.<DateField>head(dateFields);
            _xifexpression_1 = _head_1;
          }
          _xblockexpression_1 = (_xifexpression_1);
        }
        _xifexpression = _xblockexpression_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  public AbstractDateField getEndDateField(final Entity it) {
    AbstractDateField _xblockexpression = null;
    {
      EList<EntityField> _fields = it.getFields();
      Iterable<DatetimeField> _filter = Iterables.<DatetimeField>filter(_fields, DatetimeField.class);
      final Function1<DatetimeField,Boolean> _function = new Function1<DatetimeField,Boolean>() {
        public Boolean apply(final DatetimeField e) {
          boolean _isEndDate = e.isEndDate();
          return Boolean.valueOf(_isEndDate);
        }
      };
      final Iterable<DatetimeField> datetimeFields = IterableExtensions.<DatetimeField>filter(_filter, _function);
      AbstractDateField _xifexpression = null;
      boolean _isEmpty = IterableExtensions.isEmpty(datetimeFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        DatetimeField _head = IterableExtensions.<DatetimeField>head(datetimeFields);
        _xifexpression = _head;
      } else {
        DateField _xblockexpression_1 = null;
        {
          EList<EntityField> _fields_1 = it.getFields();
          Iterable<DateField> _filter_1 = Iterables.<DateField>filter(_fields_1, DateField.class);
          final Function1<DateField,Boolean> _function_1 = new Function1<DateField,Boolean>() {
            public Boolean apply(final DateField e) {
              boolean _isEndDate = e.isEndDate();
              return Boolean.valueOf(_isEndDate);
            }
          };
          final Iterable<DateField> dateFields = IterableExtensions.<DateField>filter(_filter_1, _function_1);
          DateField _xifexpression_1 = null;
          boolean _isEmpty_1 = IterableExtensions.isEmpty(dateFields);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            DateField _head_1 = IterableExtensions.<DateField>head(dateFields);
            _xifexpression_1 = _head_1;
          }
          _xblockexpression_1 = (_xifexpression_1);
        }
        _xifexpression = _xblockexpression_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  /**
   * Prints an output string describing the type of the given derived field.
   */
  public String fieldTypeAsString(final DerivedField it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BooleanField) {
        final BooleanField _booleanField = (BooleanField)it;
        _matched=true;
        _switchResult = "boolean";
      }
    }
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        final AbstractIntegerField _abstractIntegerField = (AbstractIntegerField)it;
        _matched=true;
        String _xifexpression = null;
        int _length = _abstractIntegerField.getLength();
        boolean _lessThan = (_length < 5);
        if (_lessThan) {
          _xifexpression = "smallint";
        } else {
          String _xifexpression_1 = null;
          int _length_1 = _abstractIntegerField.getLength();
          boolean _lessThan_1 = (_length_1 < 10);
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
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        _switchResult = "decimal";
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        final StringField _stringField = (StringField)it;
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        final TextField _textField = (TextField)it;
        _matched=true;
        _switchResult = "text";
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        final EmailField _emailField = (EmailField)it;
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        final UrlField _urlField = (UrlField)it;
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        final UploadField _uploadField = (UploadField)it;
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        final ListField _listField = (ListField)it;
        _matched=true;
        _switchResult = "string";
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        final ArrayField _arrayField = (ArrayField)it;
        _matched=true;
        _switchResult = "array";
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        final ObjectField _objectField = (ObjectField)it;
        _matched=true;
        _switchResult = "object";
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        final DatetimeField _datetimeField = (DatetimeField)it;
        _matched=true;
        _switchResult = "DateTime";
      }
    }
    if (!_matched) {
      if (it instanceof DateField) {
        final DateField _dateField = (DateField)it;
        _matched=true;
        _switchResult = "date";
      }
    }
    if (!_matched) {
      if (it instanceof TimeField) {
        final TimeField _timeField = (TimeField)it;
        _matched=true;
        _switchResult = "time";
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        final FloatField _floatField = (FloatField)it;
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
