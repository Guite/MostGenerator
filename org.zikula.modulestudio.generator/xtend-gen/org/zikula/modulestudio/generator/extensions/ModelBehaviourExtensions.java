package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.EntitySlugStyle;
import de.guite.modulestudio.metamodel.modulestudio.EntityTimestampableType;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import java.util.Arrays;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * This class contains model behaviour related extension methods.
 */
@SuppressWarnings("all")
public class ModelBehaviourExtensions {
  /**
   * Extensions related to the model layer.
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
   * Checks whether the application contains at least one entity with the loggable extension enabled.
   */
  public boolean hasLoggable(final Application it) {
    Iterable<Entity> _loggableEntities = this.getLoggableEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_loggableEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with the loggable extension enabled.
   */
  public Iterable<Entity> getLoggableEntities(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _isLoggable = e.isLoggable();
        return Boolean.valueOf(_isLoggable);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one entity with the geographical extension enabled.
   */
  public boolean hasGeographical(final Application it) {
    Iterable<Entity> _geographicalEntities = this.getGeographicalEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_geographicalEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with the geographical extension enabled.
   */
  public Iterable<Entity> getGeographicalEntities(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _isGeographical = e.isGeographical();
        return Boolean.valueOf(_isGeographical);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one entity with the sluggable extension enabled.
   */
  public boolean hasSluggable(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasSluggableFields = ModelBehaviourExtensions.this.hasSluggableFields(e);
        return Boolean.valueOf(_hasSluggableFields);
      }
    };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    return _exists;
  }
  
  /**
   * Checks whether the application contains at least one entity with the softDeletable extension enabled.
   */
  public boolean hasSoftDeleteable(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _isSoftDeleteable = e.isSoftDeleteable();
        return Boolean.valueOf(_isSoftDeleteable);
      }
    };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    return _exists;
  }
  
  /**
   * Checks whether the application contains at least one entity with the sortable extension enabled.
   */
  public boolean hasSortable(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasSortableFields = ModelBehaviourExtensions.this.hasSortableFields(e);
        return Boolean.valueOf(_hasSortableFields);
      }
    };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    return _exists;
  }
  
  /**
   * Checks whether the application contains at least one entity with the timestampable extension enabled.
   */
  public boolean hasTimestampable(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasTimestampableFields = ModelBehaviourExtensions.this.hasTimestampableFields(e);
        return Boolean.valueOf(_hasTimestampableFields);
      }
    };
    boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
    return _exists;
  }
  
  /**
   * Checks whether the application contains at least one entity with the translatable extension enabled.
   */
  public boolean hasTranslatable(final Application it) {
    Iterable<Entity> _translatableEntities = this.getTranslatableEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_translatableEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with the translatable extension enabled.
   */
  public Iterable<Entity> getTranslatableEntities(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _hasTranslatableFields = ModelBehaviourExtensions.this.hasTranslatableFields(e);
        return Boolean.valueOf(_hasTranslatableFields);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one entity with the tree extension enabled.
   */
  public boolean hasTrees(final Application it) {
    Iterable<Entity> _treeEntities = this.getTreeEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_treeEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with the tree extension enabled.
   */
  public Iterable<Entity> getTreeEntities(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        EntityTreeType _tree = e.getTree();
        boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
        return Boolean.valueOf(_notEquals);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one entity with the categorisable extension enabled.
   */
  public boolean hasCategorisableEntities(final Application it) {
    Iterable<Entity> _categorisableEntities = this.getCategorisableEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_categorisableEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with the categorisable extension enabled.
   */
  public Iterable<Entity> getCategorisableEntities(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _isCategorisable = e.isCategorisable();
        return Boolean.valueOf(_isCategorisable);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one entity with the meta data extension enabled.
   */
  public boolean hasMetaDataEntities(final Application it) {
    Iterable<Entity> _metaDataEntities = this.getMetaDataEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_metaDataEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with the meta data extension enabled.
   */
  public Iterable<Entity> getMetaDataEntities(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _isMetaData = e.isMetaData();
        return Boolean.valueOf(_isMetaData);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one entity with the attributable extension enabled.
   */
  public boolean hasAttributableEntities(final Application it) {
    Iterable<Entity> _attributableEntities = this.getAttributableEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_attributableEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with the attributable extension enabled.
   */
  public Iterable<Entity> getAttributableEntities(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _isAttributable = e.isAttributable();
        return Boolean.valueOf(_isAttributable);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the application contains at least one entity with the standard field extension enabled.
   */
  public boolean hasStandardFieldEntities(final Application it) {
    Iterable<Entity> _standardFieldEntities = this.getStandardFieldEntities(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_standardFieldEntities);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all entities with the standard field extension enabled.
   */
  public Iterable<Entity> getStandardFieldEntities(final Application it) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity e) {
        boolean _isStandardFields = e.isStandardFields();
        return Boolean.valueOf(_isStandardFields);
      }
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether the entity contains at least one field with the sluggable extension enabled.
   */
  public boolean hasSluggableFields(final Entity it) {
    List<AbstractStringField> _sluggableFields = this.getSluggableFields(it);
    boolean _isEmpty = _sluggableFields.isEmpty();
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all string type fields with the sluggable extension enabled.
   */
  public List<AbstractStringField> getSluggableFields(final Entity it) {
    Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
    Iterable<AbstractStringField> _filter = Iterables.<AbstractStringField>filter(_derivedFields, AbstractStringField.class);
    final Function1<AbstractStringField,Boolean> _function = new Function1<AbstractStringField,Boolean>() {
      public Boolean apply(final AbstractStringField e) {
        int _sluggablePosition = e.getSluggablePosition();
        boolean _greaterThan = (_sluggablePosition > 0);
        return Boolean.valueOf(_greaterThan);
      }
    };
    Iterable<AbstractStringField> _filter_1 = IterableExtensions.<AbstractStringField>filter(_filter, _function);
    final Function1<AbstractStringField,Integer> _function_1 = new Function1<AbstractStringField,Integer>() {
      public Integer apply(final AbstractStringField e) {
        int _sluggablePosition = e.getSluggablePosition();
        return Integer.valueOf(_sluggablePosition);
      }
    };
    List<AbstractStringField> _sortBy = IterableExtensions.<AbstractStringField, Integer>sortBy(_filter_1, _function_1);
    return _sortBy;
  }
  
  /**
   * Checks whether the entity contains at least one field with the sortable extension enabled.
   */
  public boolean hasSortableFields(final Entity it) {
    Iterable<IntegerField> _sortableFields = this.getSortableFields(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_sortableFields);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all derived fields with the sortable extension enabled.
   */
  public Iterable<IntegerField> getSortableFields(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<IntegerField> _filter = Iterables.<IntegerField>filter(_fields, IntegerField.class);
    final Function1<IntegerField,Boolean> _function = new Function1<IntegerField,Boolean>() {
      public Boolean apply(final IntegerField e) {
        boolean _isSortablePosition = e.isSortablePosition();
        boolean _equals = (_isSortablePosition == true);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<IntegerField> _filter_1 = IterableExtensions.<IntegerField>filter(_filter, _function);
    return _filter_1;
  }
  
  /**
   * Checks whether the entity contains at least one field with the timestampable extension enabled.
   */
  public boolean hasTimestampableFields(final Entity it) {
    Iterable<AbstractDateField> _timestampableFields = this.getTimestampableFields(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_timestampableFields);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all derived fields with the timestampable extension enabled.
   */
  public Iterable<AbstractDateField> getTimestampableFields(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<AbstractDateField> _filter = Iterables.<AbstractDateField>filter(_fields, AbstractDateField.class);
    final Function1<AbstractDateField,Boolean> _function = new Function1<AbstractDateField,Boolean>() {
      public Boolean apply(final AbstractDateField e) {
        EntityTimestampableType _timestampable = e.getTimestampable();
        boolean _notEquals = (!Objects.equal(_timestampable, EntityTimestampableType.NONE));
        return Boolean.valueOf(_notEquals);
      }
    };
    Iterable<AbstractDateField> _filter_1 = IterableExtensions.<AbstractDateField>filter(_filter, _function);
    return _filter_1;
  }
  
  /**
   * Checks whether the entity contains at least one field with the translatable extension enabled.
   */
  public boolean hasTranslatableFields(final Entity it) {
    Iterable<DerivedField> _translatableFields = this.getTranslatableFields(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_translatableFields);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all derived fields with the translatable extension enabled.
   */
  public Iterable<DerivedField> getTranslatableFields(final Entity it) {
    Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
      public Boolean apply(final DerivedField e) {
        boolean _isTranslatable = e.isTranslatable();
        return Boolean.valueOf(_isTranslatable);
      }
    };
    Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
    return _filter;
  }
  
  /**
   * Returns a list of all editable fields with the translatable extension enabled.
   */
  public Iterable<DerivedField> getEditableTranslatableFields(final Entity it) {
    List<DerivedField> _editableFields = this._modelExtensions.getEditableFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
      public Boolean apply(final DerivedField e) {
        boolean _isTranslatable = e.isTranslatable();
        return Boolean.valueOf(_isTranslatable);
      }
    };
    Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_editableFields, _function);
    return _filter;
  }
  
  /**
   * Returns a list of all editable fields with the translatable extension disabled.
   */
  public Iterable<DerivedField> getEditableNonTranslatableFields(final Entity it) {
    List<DerivedField> _editableFields = this._modelExtensions.getEditableFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
      public Boolean apply(final DerivedField e) {
        boolean _isTranslatable = e.isTranslatable();
        boolean _not = (!_isTranslatable);
        return Boolean.valueOf(_not);
      }
    };
    Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_editableFields, _function);
    return _filter;
  }
  
  /**
   * Checks whether the entity contains at least one field with the translatable extension enabled.
   */
  public boolean hasTranslatableSlug(final Entity it) {
    List<AbstractStringField> _sluggableFields = this.getSluggableFields(it);
    final Function1<AbstractStringField,Boolean> _function = new Function1<AbstractStringField,Boolean>() {
      public Boolean apply(final AbstractStringField e) {
        boolean _isTranslatable = e.isTranslatable();
        return Boolean.valueOf(_isTranslatable);
      }
    };
    Iterable<AbstractStringField> _filter = IterableExtensions.<AbstractStringField>filter(_sluggableFields, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Prints an output string corresponding to the given slug style.
   */
  protected String _asConstant(final EntitySlugStyle slugStyle) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(slugStyle,EntitySlugStyle.LOWERCASE)) {
        _matched=true;
        _switchResult = "lower";
      }
    }
    if (!_matched) {
      if (Objects.equal(slugStyle,EntitySlugStyle.UPPERCASE)) {
        _matched=true;
        _switchResult = "upper";
      }
    }
    if (!_matched) {
      if (Objects.equal(slugStyle,EntitySlugStyle.CAMEL)) {
        _matched=true;
        _switchResult = "camel";
      }
    }
    if (!_matched) {
      _switchResult = "default";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string corresponding to the given timestampable type.
   */
  protected String _asConstant(final EntityTimestampableType tsType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(tsType,EntityTimestampableType.UPDATE)) {
        _matched=true;
        _switchResult = "update";
      }
    }
    if (!_matched) {
      if (Objects.equal(tsType,EntityTimestampableType.CREATE)) {
        _matched=true;
        _switchResult = "create";
      }
    }
    if (!_matched) {
      if (Objects.equal(tsType,EntityTimestampableType.CHANGE)) {
        _matched=true;
        _switchResult = "change";
      }
    }
    if (!_matched) {
      _switchResult = "update";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string corresponding to the given tree type.
   */
  protected String _asConstant(final EntityTreeType treeType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(treeType,EntityTreeType.NONE)) {
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (Objects.equal(treeType,EntityTreeType.NESTED)) {
        _matched=true;
        _switchResult = "nested";
      }
    }
    if (!_matched) {
      if (Objects.equal(treeType,EntityTreeType.CLOSURE)) {
        _matched=true;
        _switchResult = "closure";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  public String asConstant(final Enum<? extends Object> slugStyle) {
    if (slugStyle instanceof EntitySlugStyle) {
      return _asConstant((EntitySlugStyle)slugStyle);
    } else if (slugStyle instanceof EntityTimestampableType) {
      return _asConstant((EntityTimestampableType)slugStyle);
    } else if (slugStyle instanceof EntityTreeType) {
      return _asConstant((EntityTreeType)slugStyle);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(slugStyle).toString());
    }
  }
}
