package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntitySlugStyle;
import de.guite.modulestudio.metamodel.modulestudio.EntityTimestampableType;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Extensions {
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
  private ModelInheritanceExtensions _modelInheritanceExtensions = new Function0<ModelInheritanceExtensions>() {
    public ModelInheritanceExtensions apply() {
      ModelInheritanceExtensions _modelInheritanceExtensions = new ModelInheritanceExtensions();
      return _modelInheritanceExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  public CharSequence imports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use Gedmo\\Mapping\\Annotation as Gedmo;");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * Class annotations.
   */
  public CharSequence classExtensions(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Loggable(logEntryClass=\"");
        {
          Models _container = it.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          boolean _not = (!_targets);
          if (_not) {
            _builder.append("\\");
          }
        }
        String _entityClassName = this._namingExtensions.entityClassName(it, "logEntry", Boolean.valueOf(false));
        _builder.append(_entityClassName, " ");
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _and = false;
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      if (!_isSoftDeleteable) {
        _and = false;
      } else {
        Models _container_1 = it.getContainer();
        Application _application_1 = _container_1.getApplication();
        boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
        boolean _not_1 = (!_targets_1);
        _and = (_isSoftDeleteable && _not_1);
      }
      if (_and) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\SoftDeleteable(fieldName=\"deletedAt\")");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\TranslationEntity(class=\"");
        {
          Models _container_2 = it.getContainer();
          Application _application_2 = _container_2.getApplication();
          boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
          boolean _not_2 = (!_targets_2);
          if (_not_2) {
            _builder.append("\\");
          }
        }
        String _entityClassName_1 = this._namingExtensions.entityClassName(it, "translation", Boolean.valueOf(false));
        _builder.append(_entityClassName_1, " ");
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Tree(type=\"");
        EntityTreeType _tree_1 = it.getTree();
        String _asConstant = this._modelBehaviourExtensions.asConstant(_tree_1);
        _builder.append(_asConstant, " ");
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
        {
          EntityTreeType _tree_2 = it.getTree();
          boolean _equals = Objects.equal(_tree_2, EntityTreeType.CLOSURE);
          if (_equals) {
            _builder.append(" ");
            _builder.append("   ");
            _builder.append("* @Gedmo\\TreeClosure(class=\"");
            {
              Models _container_3 = it.getContainer();
              Application _application_3 = _container_3.getApplication();
              boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
              boolean _not_3 = (!_targets_3);
              if (_not_3) {
                _builder.append("\\");
              }
            }
            String _entityClassName_2 = this._namingExtensions.entityClassName(it, "closure", Boolean.valueOf(false));
            _builder.append(_entityClassName_2, "    ");
            _builder.append("\")");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _lessThan = (3 < 2);
      if (_lessThan) {
        _builder.append("dummy for indentation");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Column annotations.
   */
  private CharSequence columnExtensionsDefault(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isTranslatable = it.isTranslatable();
      if (_isTranslatable) {
        _builder.append(" * @Gedmo\\Translatable");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _and = false;
      boolean _and_1 = false;
      if (!(it instanceof AbstractStringField)) {
        _and_1 = false;
      } else {
        int _sluggablePosition = ((AbstractStringField) it).getSluggablePosition();
        boolean _greaterThan = (_sluggablePosition > 0);
        _and_1 = ((it instanceof AbstractStringField) && _greaterThan);
      }
      if (!_and_1) {
        _and = false;
      } else {
        Entity _entity = it.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        boolean _targets = this._utils.targets(_application, "1.3.5");
        _and = (_and_1 && _targets);
      }
      if (_and) {
        _builder.append(" * @Gedmo\\Sluggable(slugField=\"slug\", position=");
        int _sluggablePosition_1 = ((AbstractStringField) it).getSluggablePosition();
        _builder.append(_sluggablePosition_1, "");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isSortableGroup = it.isSortableGroup();
      if (_isSortableGroup) {
        _builder.append(" * @Gedmo\\SortableGroup");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  public CharSequence columnExtensions(final DerivedField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        final AbstractIntegerField _abstractIntegerField = (AbstractIntegerField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        CharSequence _columnExtensionsDefault = this.columnExtensionsDefault(_abstractIntegerField);
        _builder.append(_columnExtensionsDefault, "");
        _builder.newLineIfNotEmpty();
        {
          boolean _isSortablePosition = _abstractIntegerField.isSortablePosition();
          if (_isSortablePosition) {
            _builder.append(" ");
            _builder.append("* @Gedmo\\SortablePosition");
            _builder.newLine();
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractDateField) {
        final AbstractDateField _abstractDateField = (AbstractDateField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        CharSequence _columnExtensionsDefault = this.columnExtensionsDefault(_abstractDateField);
        _builder.append(_columnExtensionsDefault, "");
        _builder.newLineIfNotEmpty();
        {
          EntityTimestampableType _timestampable = _abstractDateField.getTimestampable();
          boolean _notEquals = (!Objects.equal(_timestampable, EntityTimestampableType.NONE));
          if (_notEquals) {
            _builder.append(" ");
            _builder.append("* @Gedmo\\Timestampable(on=\"");
            EntityTimestampableType _timestampable_1 = _abstractDateField.getTimestampable();
            String _asConstant = this._modelBehaviourExtensions.asConstant(_timestampable_1);
            _builder.append(_asConstant, " ");
            _builder.append("\"");
            CharSequence _timestampableDetails = this.timestampableDetails(_abstractDateField);
            _builder.append(_timestampableDetails, " ");
            _builder.append(")");
            _builder.newLineIfNotEmpty();
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      CharSequence _columnExtensionsDefault = this.columnExtensionsDefault(it);
      _switchResult = _columnExtensionsDefault;
    }
    return _switchResult;
  }
  
  private CharSequence timestampableDetails(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EntityTimestampableType _timestampable = it.getTimestampable();
      boolean _equals = Objects.equal(_timestampable, EntityTimestampableType.CHANGE);
      if (_equals) {
        _builder.append(", field=\"");
        String _timestampableChangeTriggerField = it.getTimestampableChangeTriggerField();
        String _formatForCode = this._formattingExtensions.formatForCode(_timestampableChangeTriggerField);
        _builder.append(_formatForCode, "");
        _builder.append("\"");
        {
          boolean _and = false;
          String _timestampableChangeTriggerValue = it.getTimestampableChangeTriggerValue();
          boolean _tripleNotEquals = (_timestampableChangeTriggerValue != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            String _timestampableChangeTriggerValue_1 = it.getTimestampableChangeTriggerValue();
            boolean _notEquals = (!Objects.equal(_timestampableChangeTriggerValue_1, ""));
            _and = (_tripleNotEquals && _notEquals);
          }
          if (_and) {
            _builder.append(", value=\"");
            String _timestampableChangeTriggerValue_2 = it.getTimestampableChangeTriggerValue();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_timestampableChangeTriggerValue_2);
            _builder.append(_formatForCode_1, "");
            _builder.append("\"");
          }
        }
      }
    }
    return _builder;
  }
  
  /**
   * Additional column definitions.
   */
  public CharSequence additionalProperties(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The coordinate\'s latitude part.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"decimal\", precision=10, scale=7)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var decimal $latitude.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $latitude = 0.00;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The coordinate\'s longitude part.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"decimal\", precision=10, scale=7)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var decimal $longitude.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $longitude = 0.00;");
        _builder.newLine();
      }
    }
    {
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      if (_isSoftDeleteable) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Date of when this item has been marked as deleted.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"datetime\", nullable=true)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var datetime $deletedAt.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $deletedAt;");
        _builder.newLine();
      }
    }
    {
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (_hasSluggableFields) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        {
          boolean _hasTranslatableSlug = this._modelBehaviourExtensions.hasTranslatableSlug(it);
          if (_hasTranslatableSlug) {
            _builder.append(" ");
            _builder.append("* @Gedmo\\Translatable");
            _builder.newLine();
          }
        }
        {
          Models _container = it.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          if (_targets) {
            _builder.append(" ");
            _builder.append("* @Gedmo\\Slug(style=\"");
            EntitySlugStyle _slugStyle = it.getSlugStyle();
            String _asConstant = this._modelBehaviourExtensions.asConstant(_slugStyle);
            _builder.append(_asConstant, " ");
            _builder.append("\", separator=\"");
            String _slugSeparator = it.getSlugSeparator();
            _builder.append(_slugSeparator, " ");
            _builder.append("\"");
            {
              boolean _isSlugUnique = it.isSlugUnique();
              boolean _not = (!_isSlugUnique);
              if (_not) {
                _builder.append(", unique=false");
              }
            }
            {
              boolean _isSlugUpdatable = it.isSlugUpdatable();
              boolean _not_1 = (!_isSlugUpdatable);
              if (_not_1) {
                _builder.append(", updatable=false");
              }
            }
            _builder.append(")");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append(" ");
            _builder.append("* @Gedmo\\Slug(fields={");
            {
              List<AbstractStringField> _sluggableFields = this._modelBehaviourExtensions.getSluggableFields(it);
              boolean _hasElements = false;
              for(final AbstractStringField field : _sluggableFields) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate(", ", " ");
                }
                _builder.append("\"");
                String _name = field.getName();
                String _formatForCode = this._formattingExtensions.formatForCode(_name);
                _builder.append(_formatForCode, " ");
                _builder.append("\"");
              }
            }
            _builder.append("}");
            {
              boolean _isSlugUpdatable_1 = it.isSlugUpdatable();
              boolean _not_2 = (!_isSlugUpdatable_1);
              if (_not_2) {
                _builder.append(", updatable=false");
              }
            }
            {
              boolean _isSlugUnique_1 = it.isSlugUnique();
              boolean _not_3 = (!_isSlugUnique_1);
              if (_not_3) {
                _builder.append(", unique=false");
              }
            }
            _builder.append(", separator=\"");
            String _slugSeparator_1 = it.getSlugSeparator();
            _builder.append(_slugSeparator_1, " ");
            _builder.append("\", style=\"");
            EntitySlugStyle _slugStyle_1 = it.getSlugStyle();
            String _asConstant_1 = this._modelBehaviourExtensions.asConstant(_slugStyle_1);
            _builder.append(_asConstant_1, " ");
            _builder.append("\")");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"string\", length=");
        int _slugLength = it.getSlugLength();
        _builder.append(_slugLength, " ");
        {
          boolean _isSlugUnique_2 = it.isSlugUnique();
          boolean _not_4 = (!_isSlugUnique_2);
          if (_not_4) {
            _builder.append(", unique=false");
          }
        }
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @var string $slug.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $slug;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Field for storing the locale of this entity.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Overrides the locale set in translationListener (as pointed out in https://github.com/l3pp4rd/DoctrineExtensions/issues/130#issuecomment-1790206 ).");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Gedmo\\Locale");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var string $locale.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $locale;");
        _builder.newLine();
      }
    }
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Gedmo\\TreeLeft");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"integer\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var integer $lft.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $lft;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Gedmo\\TreeLevel");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"integer\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var integer $lvl.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $lvl;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Gedmo\\TreeRight");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"integer\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var integer $rgt.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $rgt;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Gedmo\\TreeRoot");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"integer\", nullable=true)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var integer $root.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $root;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Bidirectional - Many children [");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, " ");
        _builder.append("] are linked by one parent [");
        String _name_2 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_2);
        _builder.append(_formatForDisplay_1, " ");
        _builder.append("] (OWNING SIDE).");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Gedmo\\TreeParent");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\ManyToOne(targetEntity=\"");
        {
          Models _container_1 = it.getContainer();
          Application _application_1 = _container_1.getApplication();
          boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
          boolean _not_5 = (!_targets_1);
          if (_not_5) {
            _builder.append("\\");
          }
        }
        String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName, " ");
        _builder.append("\", inversedBy=\"children\")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @ORM\\JoinColumn(name=\"parent_id\", referencedColumnName=\"");
        Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
        DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields);
        String _name_3 = _head.getName();
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_3);
        _builder.append(_formatForDisplay_2, " ");
        _builder.append("\", onDelete=\"SET NULL\")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @var ");
        {
          Models _container_2 = it.getContainer();
          Application _application_2 = _container_2.getApplication();
          boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
          boolean _not_6 = (!_targets_2);
          if (_not_6) {
            _builder.append("\\");
          }
        }
        String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_1, " ");
        _builder.append(" $parent.");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $parent;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Bidirectional - One parent [");
        String _name_4 = it.getName();
        String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_4);
        _builder.append(_formatForDisplay_3, " ");
        _builder.append("] has many children [");
        String _name_5 = it.getName();
        String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(_name_5);
        _builder.append(_formatForDisplay_4, " ");
        _builder.append("] (INVERSE SIDE).");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\OneToMany(targetEntity=\"");
        {
          Models _container_3 = it.getContainer();
          Application _application_3 = _container_3.getApplication();
          boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
          boolean _not_7 = (!_targets_3);
          if (_not_7) {
            _builder.append("\\");
          }
        }
        String _entityClassName_2 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_2, " ");
        _builder.append("\", mappedBy=\"parent\")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @ORM\\OrderBy({\"lft\" = \"ASC\"})");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var ");
        {
          Models _container_4 = it.getContainer();
          Application _application_4 = _container_4.getApplication();
          boolean _targets_4 = this._utils.targets(_application_4, "1.3.5");
          boolean _not_8 = (!_targets_4);
          if (_not_8) {
            _builder.append("\\");
          }
        }
        String _entityClassName_3 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_3, " ");
        _builder.append(" $children.");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $children;");
        _builder.newLine();
      }
    }
    {
      boolean _isMetaData = it.isMetaData();
      if (_isMetaData) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\OneToOne(targetEntity=\"");
        {
          Models _container_5 = it.getContainer();
          Application _application_5 = _container_5.getApplication();
          boolean _targets_5 = this._utils.targets(_application_5, "1.3.5");
          boolean _not_9 = (!_targets_5);
          if (_not_9) {
            _builder.append("\\");
          }
        }
        String _entityClassName_4 = this._namingExtensions.entityClassName(it, "metaData", Boolean.valueOf(false));
        _builder.append(_entityClassName_4, " ");
        _builder.append("\", ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*               mappedBy=\"entity\", cascade={\"all\"},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*               orphanRemoval=true)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var ");
        {
          Models _container_6 = it.getContainer();
          Application _application_6 = _container_6.getApplication();
          boolean _targets_6 = this._utils.targets(_application_6, "1.3.5");
          boolean _not_10 = (!_targets_6);
          if (_not_10) {
            _builder.append("\\");
          }
        }
        String _entityClassName_5 = this._namingExtensions.entityClassName(it, "metaData", Boolean.valueOf(false));
        _builder.append(_entityClassName_5, " ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $metadata;");
        _builder.newLine();
      }
    }
    {
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\OneToMany(targetEntity=\"");
        {
          Models _container_7 = it.getContainer();
          Application _application_7 = _container_7.getApplication();
          boolean _targets_7 = this._utils.targets(_application_7, "1.3.5");
          boolean _not_11 = (!_targets_7);
          if (_not_11) {
            _builder.append("\\");
          }
        }
        String _entityClassName_6 = this._namingExtensions.entityClassName(it, "attribute", Boolean.valueOf(false));
        _builder.append(_entityClassName_6, " ");
        _builder.append("\", ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*                mappedBy=\"entity\", cascade={\"all\"}, ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*                orphanRemoval=true, indexBy=\"name\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var ");
        {
          Models _container_8 = it.getContainer();
          Application _application_8 = _container_8.getApplication();
          boolean _targets_8 = this._utils.targets(_application_8, "1.3.5");
          boolean _not_12 = (!_targets_8);
          if (_not_12) {
            _builder.append("\\");
          }
        }
        String _entityClassName_7 = this._namingExtensions.entityClassName(it, "attribute", Boolean.valueOf(false));
        _builder.append(_entityClassName_7, " ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $attributes;");
        _builder.newLine();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\OneToMany(targetEntity=\"");
        {
          Models _container_9 = it.getContainer();
          Application _application_9 = _container_9.getApplication();
          boolean _targets_9 = this._utils.targets(_application_9, "1.3.5");
          boolean _not_13 = (!_targets_9);
          if (_not_13) {
            _builder.append("\\");
          }
        }
        String _entityClassName_8 = this._namingExtensions.entityClassName(it, "category", Boolean.valueOf(false));
        _builder.append(_entityClassName_8, " ");
        _builder.append("\", ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*                mappedBy=\"entity\", cascade={\"all\"}, ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*                orphanRemoval=true, indexBy=\"categoryRegistryId\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var ");
        {
          Models _container_10 = it.getContainer();
          Application _application_10 = _container_10.getApplication();
          boolean _targets_10 = this._utils.targets(_application_10, "1.3.5");
          boolean _not_14 = (!_targets_10);
          if (_not_14) {
            _builder.append("\\");
          }
        }
        String _entityClassName_9 = this._namingExtensions.entityClassName(it, "category", Boolean.valueOf(false));
        _builder.append(_entityClassName_9, " ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $categories;");
        _builder.newLine();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"integer\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ZK\\StandardFields(type=\"userid\", on=\"create\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var integer $createdUserId.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $createdUserId;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"integer\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ZK\\StandardFields(type=\"userid\", on=\"update\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var integer $updatedUserId.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $updatedUserId;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"datetime\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Gedmo\\Timestampable(on=\"create\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var datetime $createdDate.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $createdDate;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @ORM\\Column(type=\"datetime\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Gedmo\\Timestampable(on=\"update\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var datetime $updatedDate.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $updatedDate;");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public CharSequence additionalAccessors(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "latitude", "decimal", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods, "");
        _builder.newLineIfNotEmpty();
        CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, "longitude", "decimal", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_1, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      if (_isSoftDeleteable) {
        CharSequence _terAndSetterMethods_2 = this.fh.getterAndSetterMethods(it, "deletedAt", "datetime", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_2, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (_hasSluggableFields) {
        {
          Models _container = it.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          if (_targets) {
            CharSequence _terMethod = this.fh.getterMethod(it, "slug", "string", Boolean.valueOf(false));
            _builder.append(_terMethod, "");
            _builder.newLineIfNotEmpty();
          } else {
            CharSequence _terAndSetterMethods_3 = this.fh.getterAndSetterMethods(it, "slug", "string", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
            _builder.append(_terAndSetterMethods_3, "");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        CharSequence _terAndSetterMethods_4 = this.fh.getterAndSetterMethods(it, "lft", "integer", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_4, "");
        _builder.newLineIfNotEmpty();
        CharSequence _terAndSetterMethods_5 = this.fh.getterAndSetterMethods(it, "lvl", "integer", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_5, "");
        _builder.newLineIfNotEmpty();
        CharSequence _terAndSetterMethods_6 = this.fh.getterAndSetterMethods(it, "rgt", "integer", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_6, "");
        _builder.newLineIfNotEmpty();
        CharSequence _terAndSetterMethods_7 = this.fh.getterAndSetterMethods(it, "root", "integer", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_7, "");
        _builder.newLineIfNotEmpty();
        String _xifexpression = null;
        Models _container_1 = it.getContainer();
        Application _application_1 = _container_1.getApplication();
        boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
        boolean _not = (!_targets_1);
        if (_not) {
          _xifexpression = "\\";
        }
        String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        String _plus = (_xifexpression + _entityClassName);
        CharSequence _terAndSetterMethods_8 = this.fh.getterAndSetterMethods(it, "parent", _plus, Boolean.valueOf(false), Boolean.valueOf(true), "null", "");
        _builder.append(_terAndSetterMethods_8, "");
        _builder.newLineIfNotEmpty();
        CharSequence _terAndSetterMethods_9 = this.fh.getterAndSetterMethods(it, "children", "array", Boolean.valueOf(true), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_9, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        CharSequence _terAndSetterMethods_10 = this.fh.getterAndSetterMethods(it, "locale", "string", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_10, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isMetaData = it.isMetaData();
      if (_isMetaData) {
        String _xifexpression_1 = null;
        Models _container_2 = it.getContainer();
        Application _application_2 = _container_2.getApplication();
        boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
        boolean _not_1 = (!_targets_2);
        if (_not_1) {
          _xifexpression_1 = "\\";
        }
        String _entityClassName_1 = this._namingExtensions.entityClassName(it, "metaData", Boolean.valueOf(false));
        String _plus_1 = (_xifexpression_1 + _entityClassName_1);
        CharSequence _terAndSetterMethods_11 = this.fh.getterAndSetterMethods(it, "metadata", _plus_1, Boolean.valueOf(false), Boolean.valueOf(true), "null", "");
        _builder.append(_terAndSetterMethods_11, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        CharSequence _terMethod_1 = this.fh.getterMethod(it, "attributes", "array", Boolean.valueOf(true));
        _builder.append(_terMethod_1, "");
        _builder.newLineIfNotEmpty();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Set attribute.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param string $name.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param string $value.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return void");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function setAttribute($name, $value)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if(isset($this->attributes[$name])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if($value == null) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$this->attributes->remove($name);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$this->attributes[$name]->setValue($value);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->attributes[$name] = new ");
        {
          Models _container_3 = it.getContainer();
          Application _application_3 = _container_3.getApplication();
          boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
          boolean _not_2 = (!_targets_3);
          if (_not_2) {
            _builder.append("\\");
          }
        }
        String _entityClassName_2 = this._namingExtensions.entityClassName(it, "attribute", Boolean.valueOf(false));
        _builder.append(_entityClassName_2, "        ");
        _builder.append("($name, $value, $this);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        CharSequence _terAndSetterMethods_12 = this.fh.getterAndSetterMethods(it, "categories", "array", Boolean.valueOf(true), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_12, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        CharSequence _terAndSetterMethods_13 = this.fh.getterAndSetterMethods(it, "createdUserId", "integer", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_13, "");
        _builder.newLineIfNotEmpty();
        CharSequence _terAndSetterMethods_14 = this.fh.getterAndSetterMethods(it, "updatedUserId", "integer", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_14, "");
        _builder.newLineIfNotEmpty();
        CharSequence _terAndSetterMethods_15 = this.fh.getterAndSetterMethods(it, "createdDate", "datetime", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_15, "");
        _builder.newLineIfNotEmpty();
        CharSequence _terAndSetterMethods_16 = this.fh.getterAndSetterMethods(it, "updatedDate", "datetime", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods_16, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  /**
   * Separate extension classes.
   */
  public void extensionClasses(final Application it, final IFileSystemAccess fsa) {
    boolean _hasLoggable = this._modelBehaviourExtensions.hasLoggable(it);
    if (_hasLoggable) {
      Iterable<Entity> _loggableEntities = this._modelBehaviourExtensions.getLoggableEntities(it);
      for (final Entity entity : _loggableEntities) {
        this.extensionClasses(entity, it, "logEntry", fsa);
      }
    }
    boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
    if (_hasTranslatable) {
      Iterable<Entity> _translatableEntities = this._modelBehaviourExtensions.getTranslatableEntities(it);
      for (final Entity entity_1 : _translatableEntities) {
        this.extensionClasses(entity_1, it, "translation", fsa);
      }
    }
    boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
    if (_hasTrees) {
      Iterable<Entity> _treeEntities = this._modelBehaviourExtensions.getTreeEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            EntityTreeType _tree = e.getTree();
            boolean _equals = Objects.equal(_tree, EntityTreeType.CLOSURE);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_treeEntities, _function);
      for (final Entity entity_2 : _filter) {
        this.extensionClasses(entity_2, it, "closure", fsa);
      }
    }
    boolean _hasMetaDataEntities = this._modelBehaviourExtensions.hasMetaDataEntities(it);
    if (_hasMetaDataEntities) {
      Iterable<Entity> _metaDataEntities = this._modelBehaviourExtensions.getMetaDataEntities(it);
      for (final Entity entity_3 : _metaDataEntities) {
        this.extensionClasses(entity_3, it, "metaData", fsa);
      }
    }
    boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
    if (_hasAttributableEntities) {
      Iterable<Entity> _attributableEntities = this._modelBehaviourExtensions.getAttributableEntities(it);
      for (final Entity entity_4 : _attributableEntities) {
        this.extensionClasses(entity_4, it, "attribute", fsa);
      }
    }
    boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
    if (_hasCategorisableEntities) {
      Iterable<Entity> _categorisableEntities = this._modelBehaviourExtensions.getCategorisableEntities(it);
      for (final Entity entity_5 : _categorisableEntities) {
        this.extensionClasses(entity_5, it, "category", fsa);
      }
    }
  }
  
  /**
   * Single extension class.
   */
  private void extensionClasses(final Entity it, final Application app, final String classType, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(app);
    final String entityPath = (_appSourceLibPath + "Entity/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(app, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Abstract";
    }
    final String entityPrefix = _xifexpression;
    String _xifexpression_1 = null;
    boolean _targets_1 = this._utils.targets(app, "1.3.5");
    if (_targets_1) {
      _xifexpression_1 = "";
    } else {
      _xifexpression_1 = "Entity";
    }
    final String entitySuffix = _xifexpression_1;
    String _name = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(classType);
    String _plus = (_formatForCodeCapital + _formatForCodeCapital_1);
    String _plus_1 = (_plus + entitySuffix);
    final String entityFileName = (_plus_1 + ".php");
    final String repositoryPath = (entityPath + "Repository/");
    String _name_1 = it.getName();
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_1);
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(classType);
    String _plus_2 = (_formatForCodeCapital_2 + _formatForCodeCapital_3);
    final String repositoryFileName = (_plus_2 + ".php");
    boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
    boolean _not = (!_isInheriting);
    if (_not) {
      String _plus_3 = (entityPath + "Base/");
      String _plus_4 = (_plus_3 + entityPrefix);
      String _plus_5 = (_plus_4 + entityFileName);
      CharSequence _extensionClassBaseFile = this.extensionClassBaseFile(it, app, classType);
      fsa.generateFile(_plus_5, _extensionClassBaseFile);
      boolean _notEquals = (!Objects.equal(classType, "closure"));
      if (_notEquals) {
        String _plus_6 = (repositoryPath + "Base/");
        String _plus_7 = (_plus_6 + repositoryFileName);
        CharSequence _extensionClassRepositoryBaseFile = this.extensionClassRepositoryBaseFile(it, app, classType);
        fsa.generateFile(_plus_7, _extensionClassRepositoryBaseFile);
      }
    }
    String _plus_8 = (entityPath + entityFileName);
    CharSequence _extensionClassFile = this.extensionClassFile(it, app, classType);
    fsa.generateFile(_plus_8, _extensionClassFile);
    boolean _notEquals_1 = (!Objects.equal(classType, "closure"));
    if (_notEquals_1) {
      String _plus_9 = (repositoryPath + repositoryFileName);
      CharSequence _extensionClassRepositoryFile = this.extensionClassRepositoryFile(it, app, classType);
      fsa.generateFile(_plus_9, _extensionClassRepositoryFile);
    }
  }
  
  private CharSequence extensionClassBaseFile(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _extensionClassBaseImpl = this.extensionClassBaseImpl(it, app, classType);
    _builder.append(_extensionClassBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence extensionClassFile(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _extensionClassImpl = this.extensionClassImpl(it, app, classType);
    _builder.append(_extensionClassImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence extensionClassRepositoryBaseFile(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _extensionClassRepositoryBaseImpl = this.extensionClassRepositoryBaseImpl(it, app, classType);
    _builder.append(_extensionClassRepositoryBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence extensionClassRepositoryFile(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _extensionClassRepositoryImpl = this.extensionClassRepositoryImpl(it, app, classType);
    _builder.append(_extensionClassRepositoryImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence extensionClassBaseImpl(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Entity\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _equals = Objects.equal(classType, "closure");
      if (_equals) {
        _builder.append("use Gedmo\\Tree\\Entity\\");
        {
          boolean _targets_1 = this._utils.targets(app, "1.3.5");
          boolean _not_1 = (!_targets_1);
          if (_not_1) {
            _builder.append("MappedSuperclass\\");
          }
        }
        _builder.append("AbstractClosure;");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _equals_1 = Objects.equal(classType, "translation");
        if (_equals_1) {
          _builder.append("use Gedmo\\Translatable\\Entity\\");
          {
            boolean _targets_2 = this._utils.targets(app, "1.3.5");
            boolean _not_2 = (!_targets_2);
            if (_not_2) {
              _builder.append("MappedSuperclass\\");
            }
          }
          _builder.append("AbstractTranslation;");
          _builder.newLineIfNotEmpty();
        } else {
          boolean _equals_2 = Objects.equal(classType, "logEntry");
          if (_equals_2) {
            _builder.append("use Gedmo\\Loggable\\Entity\\");
            {
              boolean _targets_3 = this._utils.targets(app, "1.3.5");
              boolean _not_3 = (!_targets_3);
              if (_not_3) {
                _builder.append("MappedSuperclass\\");
              }
            }
            _builder.append("AbstractLogEntry;");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _or = false;
            boolean _or_1 = false;
            boolean _equals_3 = Objects.equal(classType, "metaData");
            if (_equals_3) {
              _or_1 = true;
            } else {
              boolean _equals_4 = Objects.equal(classType, "attribute");
              _or_1 = (_equals_3 || _equals_4);
            }
            if (_or_1) {
              _or = true;
            } else {
              boolean _equals_5 = Objects.equal(classType, "category");
              _or = (_or_1 || _equals_5);
            }
            if (_or) {
              _builder.append("use Doctrine\\ORM\\Mapping as ORM;");
              _builder.newLine();
              {
                boolean _targets_4 = this._utils.targets(app, "1.3.5");
                boolean _not_4 = (!_targets_4);
                if (_not_4) {
                  {
                    boolean _equals_6 = Objects.equal(classType, "metaData");
                    if (_equals_6) {
                      _builder.append("use Zikula\\Core\\Doctrine\\Entity\\AbstractEntityMetadata;");
                      _builder.newLine();
                    } else {
                      boolean _or_2 = false;
                      boolean _equals_7 = Objects.equal(classType, "attribute");
                      if (_equals_7) {
                        _or_2 = true;
                      } else {
                        boolean _equals_8 = Objects.equal(classType, "category");
                        _or_2 = (_equals_7 || _equals_8);
                      }
                      if (_or_2) {
                        _builder.append("use Zikula\\Core\\Doctrine\\Entity\\AbstractEntity");
                        String _firstUpper = StringExtensions.toFirstUpper(classType);
                        _builder.append(_firstUpper, "");
                        _builder.append(";");
                        _builder.newLineIfNotEmpty();
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    CharSequence _extensionClassDesc = this.extensionClassDesc(it, classType);
    _builder.append(_extensionClassDesc, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the base ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(classType);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" class for ");
    String _name = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_5 = this._utils.targets(app, "1.3.5");
      boolean _not_5 = (!_targets_5);
      if (_not_5) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      boolean _targets_6 = this._utils.targets(app, "1.3.5");
      boolean _not_6 = (!_targets_6);
      if (_not_6) {
        _builder.append("Abstract");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(classType);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Entity");
      } else {
        String _entityClassName = this._namingExtensions.entityClassName(it, classType, Boolean.valueOf(true));
        _builder.append(_entityClassName, "");
      }
    }
    _builder.append(" extends ");
    CharSequence _extensionBaseClass = this.extensionBaseClass(it, app, classType);
    _builder.append(_extensionBaseClass, "");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _or_3 = false;
      boolean _or_4 = false;
      boolean _equals_9 = Objects.equal(classType, "metaData");
      if (_equals_9) {
        _or_4 = true;
      } else {
        boolean _equals_10 = Objects.equal(classType, "attribute");
        _or_4 = (_equals_9 || _equals_10);
      }
      if (_or_4) {
        _or_3 = true;
      } else {
        boolean _equals_11 = Objects.equal(classType, "category");
        _or_3 = (_or_4 || _equals_11);
      }
      if (_or_3) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        {
          boolean _equals_12 = Objects.equal(classType, "metaData");
          if (_equals_12) {
            _builder.append("     * @ORM\\OneToOne(targetEntity=\"");
            {
              boolean _targets_7 = this._utils.targets(app, "1.3.5");
              boolean _not_7 = (!_targets_7);
              if (_not_7) {
                _builder.append("\\");
              }
            }
            String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
            _builder.append(_entityClassName_1, "");
            _builder.append("\", inversedBy=\"metadata\")");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _equals_13 = Objects.equal(classType, "attribute");
            if (_equals_13) {
              _builder.append("     * @ORM\\ManyToOne(targetEntity=\"");
              {
                boolean _targets_8 = this._utils.targets(app, "1.3.5");
                boolean _not_8 = (!_targets_8);
                if (_not_8) {
                  _builder.append("\\");
                }
              }
              String _entityClassName_2 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
              _builder.append(_entityClassName_2, "");
              _builder.append("\", inversedBy=\"attributes\")");
              _builder.newLineIfNotEmpty();
            } else {
              boolean _equals_14 = Objects.equal(classType, "category");
              if (_equals_14) {
                _builder.append("     * @ORM\\ManyToOne(targetEntity=\"");
                {
                  boolean _targets_9 = this._utils.targets(app, "1.3.5");
                  boolean _not_9 = (!_targets_9);
                  if (_not_9) {
                    _builder.append("\\");
                  }
                }
                String _entityClassName_3 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
                _builder.append(_entityClassName_3, "");
                _builder.append("\", inversedBy=\"categories\")");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        _builder.append("     ");
        _builder.append("* @ORM\\JoinColumn(name=\"entityId\", referencedColumnName=\"");
        Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
        DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields);
        String _name_2 = _head.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode, "     ");
        _builder.append("\"");
        {
          boolean _equals_15 = Objects.equal(classType, "metaData");
          if (_equals_15) {
            _builder.append(", unique=true");
          }
        }
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        _builder.append("     ");
        _builder.append("* @var ");
        {
          boolean _targets_10 = this._utils.targets(app, "1.3.5");
          boolean _not_10 = (!_targets_10);
          if (_not_10) {
            _builder.append("\\");
          }
        }
        String _entityClassName_4 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_4, "     ");
        _builder.newLineIfNotEmpty();
        _builder.append("     ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $entity;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("* Get reference to owning entity.");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("* @return ");
        {
          boolean _targets_11 = this._utils.targets(app, "1.3.5");
          boolean _not_11 = (!_targets_11);
          if (_not_11) {
            _builder.append("\\");
          }
        }
        String _entityClassName_5 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_5, "     ");
        _builder.newLineIfNotEmpty();
        _builder.append("     ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function getEntity()");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return $this->entity;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("* Set reference to owning entity.");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("* @param ");
        {
          boolean _targets_12 = this._utils.targets(app, "1.3.5");
          boolean _not_12 = (!_targets_12);
          if (_not_12) {
            _builder.append("\\");
          }
        }
        String _entityClassName_6 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_6, "     ");
        _builder.append(" $entity");
        _builder.newLineIfNotEmpty();
        _builder.append("     ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function setEntity(/*");
        {
          boolean _targets_13 = this._utils.targets(app, "1.3.5");
          boolean _not_13 = (!_targets_13);
          if (_not_13) {
            _builder.append("\\");
          }
        }
        String _entityClassName_7 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_7, "    ");
        _builder.append(" */$entity)");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->entity = $entity;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence extensionBaseClass(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _equals = Objects.equal(classType, "closure");
      if (_equals) {
        _builder.append("AbstractClosure");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _equals_1 = Objects.equal(classType, "translation");
        if (_equals_1) {
          _builder.append("AbstractTranslation");
          _builder.newLineIfNotEmpty();
        } else {
          boolean _equals_2 = Objects.equal(classType, "logEntry");
          if (_equals_2) {
            _builder.append("AbstractLogEntry");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _equals_3 = Objects.equal(classType, "metaData");
            if (_equals_3) {
              {
                boolean _targets = this._utils.targets(app, "1.3.5");
                boolean _not = (!_targets);
                if (_not) {
                  _builder.append("AbstractEntityMetadata");
                } else {
                  _builder.append("Zikula_Doctrine2_Entity_EntityMetadata");
                }
              }
              _builder.newLineIfNotEmpty();
            } else {
              boolean _or = false;
              boolean _equals_4 = Objects.equal(classType, "attribute");
              if (_equals_4) {
                _or = true;
              } else {
                boolean _equals_5 = Objects.equal(classType, "category");
                _or = (_equals_4 || _equals_5);
              }
              if (_or) {
                {
                  boolean _targets_1 = this._utils.targets(app, "1.3.5");
                  if (_targets_1) {
                    _builder.append("Zikula_Doctrine2_Entity_");
                  } else {
                    _builder.append("Abstract");
                  }
                }
                _builder.append("Entity");
                String _firstUpper = StringExtensions.toFirstUpper(classType);
                _builder.append(_firstUpper, "");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence extensionClassImpl(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Entity;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("use Doctrine\\ORM\\Mapping as ORM;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    CharSequence _extensionClassDesc = this.extensionClassDesc(it, classType);
    _builder.append(_extensionClassDesc, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the concrete ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(classType);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" class for ");
    String _name = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    {
      boolean _equals = Objects.equal(classType, "closure");
      if (_equals) {
      } else {
        boolean _equals_1 = Objects.equal(classType, "translation");
        if (_equals_1) {
          _builder.append("*");
          _builder.newLine();
          _builder.append("* @ORM\\Entity(repositoryClass=\"");
          String _repositoryClass = this.repositoryClass(it, app, classType);
          _builder.append(_repositoryClass, "");
          _builder.append("\")");
          _builder.newLineIfNotEmpty();
          _builder.append("* @ORM\\Table(name=\"");
          String _fullEntityTableName = this._modelExtensions.fullEntityTableName(it);
          _builder.append(_fullEntityTableName, "");
          _builder.append("_translation\",");
          _builder.newLineIfNotEmpty();
          _builder.append("*     indexes={");
          _builder.newLine();
          _builder.append("*         @ORM\\Index(name=\"translations_lookup_idx\", columns={");
          _builder.newLine();
          _builder.append("*             \"locale\", \"object_class\", \"foreign_key\"");
          _builder.newLine();
          _builder.append("*         })");
          _builder.newLine();
          _builder.append("*     }");
          _builder.newLine();
          _builder.append("* )");
          _builder.newLine();
        } else {
          boolean _equals_2 = Objects.equal(classType, "logEntry");
          if (_equals_2) {
            _builder.append("*");
            _builder.newLine();
            _builder.append("* @ORM\\Entity(repositoryClass=\"");
            String _repositoryClass_1 = this.repositoryClass(it, app, classType);
            _builder.append(_repositoryClass_1, "");
            _builder.append("\")");
            _builder.newLineIfNotEmpty();
            _builder.append("* @ORM\\Table(name=\"");
            String _fullEntityTableName_1 = this._modelExtensions.fullEntityTableName(it);
            _builder.append(_fullEntityTableName_1, "");
            _builder.append("_log_entry\",");
            _builder.newLineIfNotEmpty();
            _builder.append("*     indexes={");
            _builder.newLine();
            _builder.append("*         @ORM\\Index(name=\"log_class_lookup_idx\", columns={\"object_class\"}),");
            _builder.newLine();
            _builder.append("*         @ORM\\Index(name=\"log_date_lookup_idx\", columns={\"logged_at\"}),");
            _builder.newLine();
            _builder.append("*         @ORM\\Index(name=\"log_user_lookup_idx\", columns={\"username\"})");
            _builder.newLine();
            _builder.append("*     }");
            _builder.newLine();
            _builder.append("* )");
            _builder.newLine();
          } else {
            boolean _or = false;
            boolean _or_1 = false;
            boolean _equals_3 = Objects.equal(classType, "metaData");
            if (_equals_3) {
              _or_1 = true;
            } else {
              boolean _equals_4 = Objects.equal(classType, "attribute");
              _or_1 = (_equals_3 || _equals_4);
            }
            if (_or_1) {
              _or = true;
            } else {
              boolean _equals_5 = Objects.equal(classType, "category");
              _or = (_or_1 || _equals_5);
            }
            if (_or) {
              _builder.append("* @ORM\\Entity(repositoryClass=\"");
              {
                boolean _targets_1 = this._utils.targets(app, "1.3.5");
                boolean _not_1 = (!_targets_1);
                if (_not_1) {
                  _builder.append("\\");
                }
              }
              String _repositoryClass_2 = this.repositoryClass(it, app, classType);
              _builder.append(_repositoryClass_2, "");
              _builder.append("\")");
              _builder.newLineIfNotEmpty();
              {
                boolean _equals_6 = Objects.equal(classType, "metaData");
                if (_equals_6) {
                  _builder.append("   ");
                  _builder.append("* @ORM\\Table(name=\"");
                  String _fullEntityTableName_2 = this._modelExtensions.fullEntityTableName(it);
                  _builder.append(_fullEntityTableName_2, "   ");
                  _builder.append("_metadata\")");
                  _builder.newLineIfNotEmpty();
                } else {
                  boolean _equals_7 = Objects.equal(classType, "attribute");
                  if (_equals_7) {
                    _builder.append("   ");
                    _builder.append("* @ORM\\Table(name=\"");
                    String _fullEntityTableName_3 = this._modelExtensions.fullEntityTableName(it);
                    _builder.append(_fullEntityTableName_3, "   ");
                    _builder.append("_attribute\",");
                    _builder.newLineIfNotEmpty();
                    _builder.append("   ");
                    _builder.append("*     uniqueConstraints={");
                    _builder.newLine();
                    _builder.append("   ");
                    _builder.append("*         @ORM\\UniqueConstraint(name=\"cat_unq\", columns={\"name\", \"entityId\"})");
                    _builder.newLine();
                    _builder.append("   ");
                    _builder.append("*     }");
                    _builder.newLine();
                    _builder.append("   ");
                    _builder.append("* )");
                    _builder.newLine();
                  } else {
                    boolean _equals_8 = Objects.equal(classType, "category");
                    if (_equals_8) {
                      _builder.append("   ");
                      _builder.append("* @ORM\\Table(name=\"");
                      String _fullEntityTableName_4 = this._modelExtensions.fullEntityTableName(it);
                      _builder.append(_fullEntityTableName_4, "   ");
                      _builder.append("_category\",");
                      _builder.newLineIfNotEmpty();
                      _builder.append("   ");
                      _builder.append("*     uniqueConstraints={");
                      _builder.newLine();
                      _builder.append("   ");
                      _builder.append("*         @ORM\\UniqueConstraint(name=\"cat_unq\", columns={\"registryId\", \"categoryId\", \"entityId\"})");
                      _builder.newLine();
                      _builder.append("   ");
                      _builder.append("*     }");
                      _builder.newLine();
                      _builder.append("   ");
                      _builder.append("* )");
                      _builder.newLine();
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("class ");
        String _entityClassName = this._namingExtensions.entityClassName(it, classType, Boolean.valueOf(false));
        _builder.append(_entityClassName, "");
        _builder.append(" extends ");
        {
          boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting) {
            Entity _parentType = this._modelInheritanceExtensions.parentType(it);
            String _entityClassName_1 = this._namingExtensions.entityClassName(_parentType, classType, Boolean.valueOf(false));
            _builder.append(_entityClassName_1, "");
          } else {
            String _entityClassName_2 = this._namingExtensions.entityClassName(it, classType, Boolean.valueOf(true));
            _builder.append(_entityClassName_2, "");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(classType);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Entity extends ");
        {
          boolean _isInheriting_1 = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting_1) {
            Entity _parentType_1 = this._modelInheritanceExtensions.parentType(it);
            String _name_2 = _parentType_1.getName();
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_2);
            _builder.append(_formatForCodeCapital_2, "");
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(classType);
            _builder.append(_formatForCodeCapital_3, "");
            _builder.append("Entity");
          } else {
            _builder.append("Base\\Abstract");
            String _name_3 = it.getName();
            String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_3);
            _builder.append(_formatForCodeCapital_4, "");
            String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(classType);
            _builder.append(_formatForCodeCapital_5, "");
            _builder.append("Entity");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private String repositoryClass(final Entity it, final Application app, final String classType) {
    String _appName = this._utils.appName(app);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(app, "1.3.5");
    if (_targets) {
      _xifexpression = "_Entity_Repository_";
    } else {
      _xifexpression = "\\Entity\\Repository\\";
    }
    String _plus = (_appName + _xifexpression);
    String _name = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
    String _plus_1 = (_plus + _formatForCodeCapital);
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(classType);
    String _plus_2 = (_plus_1 + _formatForCodeCapital_1);
    return _plus_2;
  }
  
  private CharSequence extensionClassDesc(final Entity it, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _equals = Objects.equal(classType, "closure");
      if (_equals) {
        _builder.append("Entity extension domain class storing ");
        String _name = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
        _builder.append(_formatForDisplay, "");
        _builder.append(" tree closures.");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _equals_1 = Objects.equal(classType, "translation");
        if (_equals_1) {
          _builder.append("Entity extension domain class storing ");
          String _name_1 = it.getName();
          String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
          _builder.append(_formatForDisplay_1, "");
          _builder.append(" translations.");
          _builder.newLineIfNotEmpty();
        } else {
          boolean _equals_2 = Objects.equal(classType, "logEntry");
          if (_equals_2) {
            _builder.append("Entity extension domain class storing ");
            String _name_2 = it.getName();
            String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_2);
            _builder.append(_formatForDisplay_2, "");
            _builder.append(" log entries.");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _equals_3 = Objects.equal(classType, "metaData");
            if (_equals_3) {
              _builder.append("Entity extension domain class storing ");
              String _name_3 = it.getName();
              String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_3);
              _builder.append(_formatForDisplay_3, "");
              _builder.append(" meta data.");
              _builder.newLineIfNotEmpty();
            } else {
              boolean _equals_4 = Objects.equal(classType, "attribute");
              if (_equals_4) {
                _builder.append("Entity extension domain class storing ");
                String _name_4 = it.getName();
                String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(_name_4);
                _builder.append(_formatForDisplay_4, "");
                _builder.append(" attributes.");
                _builder.newLineIfNotEmpty();
              } else {
                boolean _equals_5 = Objects.equal(classType, "category");
                if (_equals_5) {
                  _builder.append("Entity extension domain class storing ");
                  String _name_5 = it.getName();
                  String _formatForDisplay_5 = this._formattingExtensions.formatForDisplay(_name_5);
                  _builder.append(_formatForDisplay_5, "");
                  _builder.append(" categories.");
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence extensionClassRepositoryBaseImpl(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Entity\\Repository\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _equals = Objects.equal(classType, "translation");
      if (_equals) {
        _builder.append("use Gedmo\\Translatable\\Entity\\Repository\\TranslationRepository;");
        _builder.newLine();
      } else {
        boolean _equals_1 = Objects.equal(classType, "logEntry");
        if (_equals_1) {
          _builder.append("use Gedmo\\Loggable\\Entity\\Repository\\LogEntryRepository;");
          _builder.newLine();
        } else {
          _builder.append("use Doctrine\\ORM\\EntityRepository;");
          _builder.newLine();
        }
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Repository class used to implement own convenience methods for performing certain DQL queries.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the base repository class for ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(classType);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Entity_Repository_Base_");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(classType);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append(" extends ");
        {
          boolean _equals_2 = Objects.equal(classType, "translation");
          if (_equals_2) {
            _builder.append("Translation");
          } else {
            boolean _equals_3 = Objects.equal(classType, "logEntry");
            if (_equals_3) {
              _builder.append("LogEntry");
            } else {
              _builder.append("Entity");
            }
          }
        }
        _builder.append("Repository");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_2 = it.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_2, "");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(classType);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append(" extends ");
        {
          boolean _equals_4 = Objects.equal(classType, "translation");
          if (_equals_4) {
            _builder.append("Translation");
          } else {
            boolean _equals_5 = Objects.equal(classType, "logEntry");
            if (_equals_5) {
              _builder.append("LogEntry");
            } else {
              _builder.append("Entity");
            }
          }
        }
        _builder.append("Repository");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence extensionClassRepositoryImpl(final Entity it, final Application app, final String classType) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Entity\\Repository;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Repository class used to implement own convenience methods for performing certain DQL queries.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the concrete repository class for ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(classType);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Entity_Repository_");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(classType);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append(" extends ");
        {
          boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting) {
            String _appName_1 = this._utils.appName(app);
            _builder.append(_appName_1, "");
            _builder.append("_Entity_Repository_");
            Entity _parentType = this._modelInheritanceExtensions.parentType(it);
            String _name_2 = _parentType.getName();
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_2);
            _builder.append(_formatForCodeCapital_2, "");
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(classType);
            _builder.append(_formatForCodeCapital_3, "");
          } else {
            String _appName_2 = this._utils.appName(app);
            _builder.append(_appName_2, "");
            _builder.append("_Entity_Repository_Base_");
            String _name_3 = it.getName();
            String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_3);
            _builder.append(_formatForCodeCapital_4, "");
            String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(classType);
            _builder.append(_formatForCodeCapital_5, "");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_4 = it.getName();
        String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital_6, "");
        String _formatForCodeCapital_7 = this._formattingExtensions.formatForCodeCapital(classType);
        _builder.append(_formatForCodeCapital_7, "");
        _builder.append(" extends ");
        {
          boolean _isInheriting_1 = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting_1) {
            Entity _parentType_1 = this._modelInheritanceExtensions.parentType(it);
            String _name_5 = _parentType_1.getName();
            String _formatForCodeCapital_8 = this._formattingExtensions.formatForCodeCapital(_name_5);
            _builder.append(_formatForCodeCapital_8, "");
            String _formatForCodeCapital_9 = this._formattingExtensions.formatForCodeCapital(classType);
            _builder.append(_formatForCodeCapital_9, "");
          } else {
            _builder.append("Base\\");
            String _name_6 = it.getName();
            String _formatForCodeCapital_10 = this._formattingExtensions.formatForCodeCapital(_name_6);
            _builder.append(_formatForCodeCapital_10, "");
            String _formatForCodeCapital_11 = this._formattingExtensions.formatForCodeCapital(classType);
            _builder.append(_formatForCodeCapital_11, "");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
