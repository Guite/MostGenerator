package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Attributes;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Blameable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Categories;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.IpTraceable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Loggable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Sluggable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Sortable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Timestampable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Translatable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Tree;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;

@SuppressWarnings("all")
public class ExtensionManager {
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  private Entity entity;
  
  private List<EntityExtensionInterface> extensions;
  
  public ExtensionManager(final Entity entity) {
    this.entity = entity;
    this.extensions = CollectionLiterals.<EntityExtensionInterface>newArrayList();
    boolean _hasBlameableFields = this._modelBehaviourExtensions.hasBlameableFields(entity);
    if (_hasBlameableFields) {
      Blameable _blameable = new Blameable();
      this.extensions.add(_blameable);
    }
    boolean _hasIpTraceableFields = this._modelBehaviourExtensions.hasIpTraceableFields(entity);
    if (_hasIpTraceableFields) {
      IpTraceable _ipTraceable = new IpTraceable();
      this.extensions.add(_ipTraceable);
    }
    boolean _isLoggable = entity.isLoggable();
    if (_isLoggable) {
      Loggable _loggable = new Loggable();
      this.extensions.add(_loggable);
    }
    boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(entity);
    if (_hasSluggableFields) {
      Sluggable _sluggable = new Sluggable();
      this.extensions.add(_sluggable);
    }
    boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(entity);
    if (_hasTranslatableFields) {
      Translatable _translatable = new Translatable();
      this.extensions.add(_translatable);
    }
    boolean _hasSortableFields = this._modelBehaviourExtensions.hasSortableFields(entity);
    if (_hasSortableFields) {
      Sortable _sortable = new Sortable();
      this.extensions.add(_sortable);
    }
    boolean _hasTimestampableFields = this._modelBehaviourExtensions.hasTimestampableFields(entity);
    if (_hasTimestampableFields) {
      Timestampable _timestampable = new Timestampable();
      this.extensions.add(_timestampable);
    }
    EntityTreeType _tree = entity.getTree();
    boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
    if (_notEquals) {
      Tree _tree_1 = new Tree();
      this.extensions.add(_tree_1);
    }
    boolean _isAttributable = entity.isAttributable();
    if (_isAttributable) {
      Attributes _attributes = new Attributes();
      this.extensions.add(_attributes);
    }
    boolean _isCategorisable = entity.isCategorisable();
    if (_isCategorisable) {
      Categories _categories = new Categories();
      this.extensions.add(_categories);
    }
  }
  
  /**
   * Generates separate extension classes.
   */
  public CharSequence extensionClasses(final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    {
      for(final EntityExtensionInterface ext : this.extensions) {
        ext.extensionClasses(this.entity, fsa);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  /**
   * Additional class annotations.
   */
  public CharSequence classAnnotations() {
    StringConcatenation _builder = new StringConcatenation();
    {
      for(final EntityExtensionInterface ext : this.extensions) {
        CharSequence _classAnnotations = ext.classAnnotations(this.entity);
        _builder.append(_classAnnotations);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  /**
   * Additional field annotations.
   */
  public CharSequence columnAnnotations(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      for(final EntityExtensionInterface ext : this.extensions) {
        CharSequence _columnAnnotations = ext.columnAnnotations(it);
        _builder.append(_columnAnnotations);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  /**
   * Additional column definitions.
   */
  public CharSequence additionalProperties() {
    StringConcatenation _builder = new StringConcatenation();
    {
      for(final EntityExtensionInterface ext : this.extensions) {
        CharSequence _properties = ext.properties(this.entity);
        _builder.append(_properties);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  /**
   * Additional accessor methods.
   */
  public CharSequence additionalAccessors() {
    StringConcatenation _builder = new StringConcatenation();
    {
      for(final EntityExtensionInterface ext : this.extensions) {
        CharSequence _accessors = ext.accessors(this.entity);
        _builder.append(_accessors);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
}
