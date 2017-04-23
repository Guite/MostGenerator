package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.AbstractStringField;
import de.guite.modulestudio.metamodel.AccountDeletionHandler;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityBlameableType;
import de.guite.modulestudio.metamodel.EntityIpTraceableType;
import de.guite.modulestudio.metamodel.EntitySlugStyle;
import de.guite.modulestudio.metamodel.EntityTimestampableType;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * This class contains model behaviour related extension methods.
 */
@SuppressWarnings("all")
public class ModelBehaviourExtensions {
  /**
   * Extensions related to generator settings.
   */
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  /**
   * Extensions related to the model layer.
   */
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Checks whether the feature activation helper class should be generated or not.
   */
  public boolean needsFeatureActivationHelper(final Application it) {
    return (((this.hasCategorisableEntities(it) || this.hasAttributableEntities(it)) || this.hasTranslatable(it)) || this.hasTrees(it));
  }
  
  /**
   * Checks whether the application contains at least one entity with the loggable extension enabled.
   */
  public boolean hasLoggable(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getLoggableEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with the loggable extension enabled.
   */
  public Iterable<Entity> getLoggableEntities(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(it_1.isLoggable());
    };
    return IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with the geographical extension enabled.
   */
  public boolean hasGeographical(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getGeographicalEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with the geographical extension enabled.
   */
  public Iterable<Entity> getGeographicalEntities(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(it_1.isGeographical());
    };
    return IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the generation of ics templates is needed or not.
   */
  public boolean hasEntitiesWithIcsTemplates(final Application it) {
    return (this._generatorSettingsExtensions.generateIcsTemplates(it) && IterableExtensions.<Entity>exists(this._modelExtensions.getAllEntities(it), ((Function1<Entity, Boolean>) (Entity it_1) -> {
      return Boolean.valueOf(this.supportsIcsTemplates(it_1));
    })));
  }
  
  /**
   * Checks whether the application contains at least one entity with the sluggable extension enabled.
   */
  public boolean hasSluggable(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this.hasSluggableFields(it_1));
    };
    return IterableExtensions.<Entity>exists(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with the sortable extension enabled.
   */
  public boolean hasSortable(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this.hasSortableFields(it_1));
    };
    return IterableExtensions.<Entity>exists(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with the timestampable extension enabled.
   */
  public boolean hasTimestampable(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this.hasTimestampableFields(it_1));
    };
    return IterableExtensions.<Entity>exists(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with the translatable extension enabled.
   */
  public boolean hasTranslatable(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getTranslatableEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with the translatable extension enabled.
   */
  public Iterable<Entity> getTranslatableEntities(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this.hasTranslatableFields(it_1));
    };
    return IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with the tree extension enabled.
   */
  public boolean hasTrees(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getTreeEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with the tree extension enabled.
   */
  public Iterable<Entity> getTreeEntities(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      EntityTreeType _tree = it_1.getTree();
      return Boolean.valueOf((!Objects.equal(_tree, EntityTreeType.NONE)));
    };
    return IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with the categorisable extension enabled.
   */
  public boolean hasCategorisableEntities(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getCategorisableEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with the categorisable extension enabled.
   */
  public Iterable<Entity> getCategorisableEntities(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(it_1.isCategorisable());
    };
    return IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with the attributable extension enabled.
   */
  public boolean hasAttributableEntities(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getAttributableEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities with the attributable extension enabled.
   */
  public Iterable<Entity> getAttributableEntities(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(it_1.isAttributable());
    };
    return IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the application contains at least one entity with the standard field extension enabled.
   */
  public boolean hasStandardFieldEntities(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getStandardFieldEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether an avatar plugin is required or not.
   */
  public boolean needsUserAvatarSupport(final Application it) {
    return ((this.hasStandardFieldEntities(it) || this._modelExtensions.hasUserFields(it)) || this.hasLoggable(it));
  }
  
  /**
   * Checks whether dynamic user field functionality is needed or not.
   */
  public boolean needsUserAutoCompletion(final Application it) {
    return (this._modelExtensions.hasUserFields(it) || this.hasStandardFieldEntities(it));
  }
  
  /**
   * Checks whether custom datetime field is needed or not.
   */
  public boolean needsDatetimeType(final Application it) {
    return (this.hasStandardFieldEntities(it) || (!IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), ((Function1<Entity, Boolean>) (Entity it_1) -> {
      boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<DatetimeField>filter(it_1.getFields(), DatetimeField.class));
      return Boolean.valueOf((!_isEmpty));
    })))));
  }
  
  /**
   * Returns a list of all entities with the standard field extension enabled.
   */
  public Iterable<Entity> getStandardFieldEntities(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(it_1.isStandardFields());
    };
    return IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the entity contains at least one field with the blameable extension enabled.
   */
  public boolean hasBlameableFields(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getBlameableFields(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all derived fields with the blameable extension enabled.
   */
  public Iterable<UserField> getBlameableFields(final Entity it) {
    final Function1<DataObject, Iterable<UserField>> _function = (DataObject it_1) -> {
      final Function1<UserField, Boolean> _function_1 = (UserField it_2) -> {
        EntityBlameableType _blameable = it_2.getBlameable();
        return Boolean.valueOf((!Objects.equal(_blameable, EntityBlameableType.NONE)));
      };
      return IterableExtensions.<UserField>filter(Iterables.<UserField>filter(it_1.getFields(), UserField.class), _function_1);
    };
    return Iterables.<UserField>concat(IterableExtensions.<DataObject, Iterable<UserField>>map(this._modelExtensions.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether the entity contains at least one field with the ipTraceable extension enabled.
   */
  public boolean hasIpTraceableFields(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getIpTraceableFields(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all derived fields with the ipTraceable extension enabled.
   */
  public Iterable<StringField> getIpTraceableFields(final Entity it) {
    final Function1<DataObject, Iterable<StringField>> _function = (DataObject it_1) -> {
      final Function1<StringField, Boolean> _function_1 = (StringField it_2) -> {
        EntityIpTraceableType _ipTraceable = it_2.getIpTraceable();
        return Boolean.valueOf((!Objects.equal(_ipTraceable, EntityIpTraceableType.NONE)));
      };
      return IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it_1.getFields(), StringField.class), _function_1);
    };
    return Iterables.<StringField>concat(IterableExtensions.<DataObject, Iterable<StringField>>map(this._modelExtensions.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether the application provides automatic archiving.
   */
  public boolean hasAutomaticArchiving(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getArchivingEntities(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all entities supporting automatic archiving.
   */
  public Iterable<Entity> getArchivingEntities(final Application it) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf((it_1.isHasArchive() && (null != this._modelExtensions.getEndDateField(it_1))));
    };
    return IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
  }
  
  /**
   * Checks whether the entity supports ics templates.
   */
  public boolean supportsIcsTemplates(final Entity it) {
    return ((null != this._modelExtensions.getStartDateField(it)) && (null != this._modelExtensions.getEndDateField(it)));
  }
  
  /**
   * Checks whether the entity contains at least one field with the sluggable extension enabled.
   */
  public boolean hasSluggableFields(final Entity it) {
    boolean _isEmpty = this.getSluggableFields(it).isEmpty();
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all string type fields with the sluggable extension enabled.
   */
  public List<AbstractStringField> getSluggableFields(final Entity it) {
    final Function1<AbstractStringField, Boolean> _function = (AbstractStringField it_1) -> {
      int _sluggablePosition = it_1.getSluggablePosition();
      return Boolean.valueOf((_sluggablePosition > 0));
    };
    final Function1<AbstractStringField, Integer> _function_1 = (AbstractStringField it_1) -> {
      return Integer.valueOf(it_1.getSluggablePosition());
    };
    return IterableExtensions.<AbstractStringField, Integer>sortBy(IterableExtensions.<AbstractStringField>filter(Iterables.<AbstractStringField>filter(this._modelExtensions.getDerivedFields(it), AbstractStringField.class), _function), _function_1);
  }
  
  /**
   * Checks whether the entity contains at least one field with the sortable extension enabled.
   */
  public boolean hasSortableFields(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getSortableFields(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all derived fields with the sortable extension enabled.
   */
  public Iterable<IntegerField> getSortableFields(final Entity it) {
    final Function1<DataObject, Iterable<IntegerField>> _function = (DataObject it_1) -> {
      final Function1<IntegerField, Boolean> _function_1 = (IntegerField it_2) -> {
        return Boolean.valueOf(it_2.isSortablePosition());
      };
      return IterableExtensions.<IntegerField>filter(Iterables.<IntegerField>filter(it_1.getFields(), IntegerField.class), _function_1);
    };
    return Iterables.<IntegerField>concat(IterableExtensions.<DataObject, Iterable<IntegerField>>map(this._modelExtensions.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Returns whether form input fields for slug elements can be used or not.
   */
  public boolean supportsSlugInputFields(final Application it) {
    return false;
  }
  
  /**
   * Checks whether the entity contains at least one field with the timestampable extension enabled.
   */
  public boolean hasTimestampableFields(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getTimestampableFields(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all derived fields with the timestampable extension enabled.
   */
  public Iterable<AbstractDateField> getTimestampableFields(final Entity it) {
    final Function1<DataObject, Iterable<AbstractDateField>> _function = (DataObject it_1) -> {
      final Function1<AbstractDateField, Boolean> _function_1 = (AbstractDateField it_2) -> {
        EntityTimestampableType _timestampable = it_2.getTimestampable();
        return Boolean.valueOf((!Objects.equal(_timestampable, EntityTimestampableType.NONE)));
      };
      return IterableExtensions.<AbstractDateField>filter(Iterables.<AbstractDateField>filter(it_1.getFields(), AbstractDateField.class), _function_1);
    };
    return Iterables.<AbstractDateField>concat(IterableExtensions.<DataObject, Iterable<AbstractDateField>>map(this._modelExtensions.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Checks whether the entity contains at least one field with the translatable extension enabled.
   */
  public boolean hasTranslatableFields(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getTranslatableFields(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all derived fields with the translatable extension enabled.
   */
  public Iterable<DerivedField> getTranslatableFields(final Entity it) {
    final Function1<DataObject, Iterable<DerivedField>> _function = (DataObject it_1) -> {
      final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_2) -> {
        return Boolean.valueOf(it_2.isTranslatable());
      };
      return IterableExtensions.<DerivedField>filter(this._modelExtensions.getDerivedFields(it_1), _function_1);
    };
    return Iterables.<DerivedField>concat(IterableExtensions.<DataObject, Iterable<DerivedField>>map(this._modelExtensions.getSelfAndParentDataObjects(it), _function));
  }
  
  /**
   * Returns a list of all editable fields with the translatable extension enabled.
   */
  public Iterable<DerivedField> getEditableTranslatableFields(final Entity it) {
    final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
      return Boolean.valueOf(it_1.isTranslatable());
    };
    return IterableExtensions.<DerivedField>filter(this._modelExtensions.getEditableFields(it), _function);
  }
  
  /**
   * Returns a list of all editable fields with the translatable extension disabled.
   */
  public Iterable<DerivedField> getEditableNonTranslatableFields(final DataObject it) {
    Iterable<DerivedField> _xifexpression = null;
    if ((it instanceof Entity)) {
      final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
        boolean _isTranslatable = it_1.isTranslatable();
        return Boolean.valueOf((!_isTranslatable));
      };
      _xifexpression = IterableExtensions.<DerivedField>filter(this._modelExtensions.getEditableFields(it), _function);
    } else {
      _xifexpression = this._modelExtensions.getEditableFields(it);
    }
    return _xifexpression;
  }
  
  /**
   * Checks whether the entity contains at least one field with the translatable extension enabled.
   */
  public boolean hasTranslatableSlug(final Entity it) {
    final Function1<AbstractStringField, Boolean> _function = (AbstractStringField it_1) -> {
      return Boolean.valueOf(it_1.isTranslatable());
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<AbstractStringField>filter(this.getSluggableFields(it), _function));
    return (!_isEmpty);
  }
  
  /**
   * Prints an output string corresponding to the given slug style.
   */
  public String slugStyleAsConstant(final EntitySlugStyle slugStyle) {
    String _switchResult = null;
    if (slugStyle != null) {
      switch (slugStyle) {
        case LOWERCASE:
          _switchResult = "lower";
          break;
        case UPPERCASE:
          _switchResult = "upper";
          break;
        case CAMEL:
          _switchResult = "camel";
          break;
        default:
          _switchResult = "default";
          break;
      }
    } else {
      _switchResult = "default";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string corresponding to the given account deletion handler type.
   */
  public String adhAsConstant(final AccountDeletionHandler handler) {
    String _switchResult = null;
    if (handler != null) {
      switch (handler) {
        case ADMIN:
          _switchResult = "admin";
          break;
        case GUEST:
          _switchResult = "guest";
          break;
        case DELETE:
          _switchResult = "delete";
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
   * Returns the user identifier fitting to a certain account deletion handler type.
   */
  public Object adhUid(final Application it, final AccountDeletionHandler handler) {
    Object _switchResult = null;
    if (handler != null) {
      switch (handler) {
        case ADMIN:
          Object _xifexpression = null;
          Boolean _targets = this._utils.targets(it, "1.5");
          if ((_targets).booleanValue()) {
            _xifexpression = "UsersConstant::USER_ID_ADMIN";
          } else {
            _xifexpression = Integer.valueOf(2);
          }
          _switchResult = ((Object)_xifexpression);
          break;
        case GUEST:
          Object _xifexpression_1 = null;
          Boolean _targets_1 = this._utils.targets(it, "1.5");
          if ((_targets_1).booleanValue()) {
            _xifexpression_1 = "UsersConstant::USER_ID_ANONYMOUS";
          } else {
            _xifexpression_1 = Integer.valueOf(1);
          }
          _switchResult = ((Object)_xifexpression_1);
          break;
        case DELETE:
          _switchResult = Integer.valueOf(0);
          break;
        default:
          _switchResult = Integer.valueOf(0);
          break;
      }
    } else {
      _switchResult = Integer.valueOf(0);
    }
    return _switchResult;
  }
  
  public CharSequence setTranslatorMethod(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sets the translator.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function setTranslator(/*TranslatorInterface */$translator)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->translator = $translator;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
