package org.zikula.modulestudio.generator.cartridges.zclassic.models;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ArrayField;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.CalculatedField;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.EntityLockType;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.ObjectField;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Joins;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.LinkTable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Tree;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Repository {
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
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
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
  
  private IFileSystemAccess fsa;
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  private Application app;
  
  /**
   * Entry point for Doctrine repository classes.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    this.app = it;
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          boolean _isMappedSuperClass = e.isMappedSuperClass();
          boolean _not = (!_isMappedSuperClass);
          return Boolean.valueOf(_not);
        }
      };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    final Procedure1<Entity> _function_1 = new Procedure1<Entity>() {
        public void apply(final Entity e) {
          Repository.this.generate(e);
        }
      };
    IterableExtensions.<Entity>forEach(_filter, _function_1);
    LinkTable _linkTable = new LinkTable();
    final LinkTable linkTable = _linkTable;
    Iterable<JoinRelationship> _joinRelations = this._modelJoinExtensions.getJoinRelations(it);
    Iterable<ManyToManyRelationship> _filter_1 = Iterables.<ManyToManyRelationship>filter(_joinRelations, ManyToManyRelationship.class);
    for (final ManyToManyRelationship relation : _filter_1) {
      linkTable.generate(relation, it, fsa);
    }
  }
  
  /**
   * Creates a repository class file for every Entity instance.
   */
  private void generate(final Entity it) {
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus = ("Generating repository classes for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    final String repositoryPath = (_appSourceLibPath + "Entity/Repository/");
    String _name_1 = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
    final String repositoryFileName = (_formatForCodeCapital + ".php");
    boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
    boolean _not = (!_isInheriting);
    if (_not) {
      String _plus_2 = (repositoryPath + "Base/");
      String _plus_3 = (_plus_2 + repositoryFileName);
      CharSequence _modelRepositoryBaseFile = this.modelRepositoryBaseFile(it);
      this.fsa.generateFile(_plus_3, _modelRepositoryBaseFile);
    }
    String _plus_4 = (repositoryPath + repositoryFileName);
    CharSequence _modelRepositoryFile = this.modelRepositoryFile(it);
    this.fsa.generateFile(_plus_4, _modelRepositoryFile);
  }
  
  private CharSequence modelRepositoryBaseFile(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _modelRepositoryBaseImpl = this.modelRepositoryBaseImpl(it);
    _builder.append(_modelRepositoryBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelRepositoryFile(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _modelRepositoryImpl = this.modelRepositoryImpl(it);
    _builder.append(_modelRepositoryImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelRepositoryBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "");
        _builder.append("\\Entity\\Repository\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _hasUploads = this._modelExtensions.hasUploads(this.app);
          if (_hasUploads) {
            _builder.append("use ");
            String _appName_1 = this._utils.appName(this.app);
            _builder.append(_appName_1, "");
            _builder.append("\\Util\\ImageUtil;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
          if (_hasListFieldsEntity) {
            _builder.append("use ");
            String _appName_2 = this._utils.appName(this.app);
            _builder.append(_appName_2, "");
            _builder.append("\\Util\\ListEntriesUtil;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        String _appName_3 = this._utils.appName(this.app);
        _builder.append(_appName_3, "");
        _builder.append("\\Util\\WorkflowUtil;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.append("use Gedmo\\Tree\\Entity\\Repository\\");
        EntityTreeType _tree_1 = it.getTree();
        String _asConstant = this._modelBehaviourExtensions.asConstant(_tree_1);
        String _firstUpper = StringExtensions.toFirstUpper(_asConstant);
        _builder.append(_firstUpper, "");
        _builder.append("TreeRepository;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Doctrine\\ORM\\EntityRepository;");
        _builder.newLine();
      }
    }
    _builder.append("use Doctrine\\ORM\\Query;");
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\QueryBuilder;");
    _builder.newLine();
    {
      boolean _or = false;
      boolean _or_1 = false;
      boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
      if (_hasOptimisticLock) {
        _or_1 = true;
      } else {
        boolean _hasPessimisticReadLock = this._modelExtensions.hasPessimisticReadLock(it);
        _or_1 = (_hasOptimisticLock || _hasPessimisticReadLock);
      }
      if (_or_1) {
        _or = true;
      } else {
        boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
        _or = (_or_1 || _hasPessimisticWriteLock);
      }
      if (_or) {
        _builder.append("use Doctrine\\DBAL\\LockMode;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        _builder.append("use DoctrineExtensions\\Paginate\\Paginate;");
        _builder.newLine();
      } else {
        _builder.append("use Doctrine\\ORM\\Tools\\Pagination\\Paginator;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      boolean _not_1 = (!_targets_2);
      if (_not_1) {
        _builder.append("use DataUtil;");
        _builder.newLine();
        _builder.append("use FilterUtil;");
        _builder.newLine();
        _builder.append("use FormUtil;");
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use UserUtil;");
        _builder.newLine();
        {
          boolean _and = false;
          boolean _isHasArchive = it.isHasArchive();
          if (!_isHasArchive) {
            _and = false;
          } else {
            AbstractDateField _endDateField = this._modelExtensions.getEndDateField(it);
            boolean _tripleNotEquals = (_endDateField != null);
            _and = (_isHasArchive && _tripleNotEquals);
          }
          if (_and) {
            _builder.append("use ZLanguage;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\ModUrl;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Hook\\ProcessHook;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Hook\\ValidationHook;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Hook\\ValidationProviders;");
            _builder.newLine();
          }
        }
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
    _builder.append("* This is the base repository class for ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
      if (_targets_3) {
        _builder.append("class ");
        String _appName_4 = this._utils.appName(this.app);
        _builder.append(_appName_4, "");
        _builder.append("_Entity_Repository_Base_");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
        _builder.append(" extends ");
        {
          EntityTreeType _tree_2 = it.getTree();
          boolean _notEquals_1 = (!Objects.equal(_tree_2, EntityTreeType.NONE));
          if (_notEquals_1) {
            EntityTreeType _tree_3 = it.getTree();
            String _asConstant_1 = this._modelBehaviourExtensions.asConstant(_tree_3);
            String _firstUpper_1 = StringExtensions.toFirstUpper(_asConstant_1);
            _builder.append(_firstUpper_1, "");
            _builder.append("TreeRepository");
          } else {
            _builder.append("EntityRepository");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_2 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append(" extends ");
        {
          EntityTreeType _tree_4 = it.getTree();
          boolean _notEquals_2 = (!Objects.equal(_tree_4, EntityTreeType.NONE));
          if (_notEquals_2) {
            EntityTreeType _tree_5 = it.getTree();
            String _asConstant_2 = this._modelBehaviourExtensions.asConstant(_tree_5);
            String _firstUpper_2 = StringExtensions.toFirstUpper(_asConstant_2);
            _builder.append(_firstUpper_2, "");
            _builder.append("TreeRepository");
          } else {
            _builder.append("EntityRepository");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string The default sorting field/expression.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $defaultSortingField = \'");
    DerivedField _xifexpression = null;
    boolean _hasSortableFields = this._modelBehaviourExtensions.hasSortableFields(it);
    if (_hasSortableFields) {
      Iterable<IntegerField> _sortableFields = this._modelBehaviourExtensions.getSortableFields(it);
      IntegerField _head = IterableExtensions.<IntegerField>head(_sortableFields);
      _xifexpression = _head;
    } else {
      DerivedField _leadingField = this._modelExtensions.getLeadingField(it);
      _xifexpression = _leadingField;
    }
    String _name_3 = _xifexpression.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array Additional arguments given by the calling controller.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $controllerArguments = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Retrieves an array with all fields which can be used for sorting instances.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return array");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getAllowedSortingFields()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return array(");
    _builder.newLine();
    _builder.append("            ");
    {
      EList<EntityField> _fields = it.getFields();
      for(final EntityField field : _fields) {
        CharSequence _singleSortingField = this.singleSortingField(field);
        _builder.append(_singleSortingField, "            ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    CharSequence _extensionSortingFields = this.extensionSortingFields(it);
    _builder.append(_extensionSortingFields, "            ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "defaultSortingField", "string", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, "controllerArguments", "array", Boolean.valueOf(false), Boolean.valueOf(true), "Array()", "");
    _builder.append(_terAndSetterMethods_1, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Returns name of the field used as title / name for entities of this repository.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string Name of field to be used as title.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getTitleFieldName()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$fieldName = \'");
    {
      boolean _tripleNotEquals_1 = (leadingField != null);
      if (_tripleNotEquals_1) {
        String _name_4 = leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_1, "        ");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $fieldName;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Returns name of the field used for describing entities of this repository.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string Name of field to be used as description.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getDescriptionFieldName()");
    _builder.newLine();
    _builder.append("   ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    EList<EntityField> _fields_1 = it.getFields();
    Iterable<TextField> _filter = Iterables.<TextField>filter(_fields_1, TextField.class);
    final Function1<TextField,Boolean> _function = new Function1<TextField,Boolean>() {
        public Boolean apply(final TextField e) {
          boolean _isLeading = e.isLeading();
          boolean _not = (!_isLeading);
          return Boolean.valueOf(_not);
        }
      };
    final Iterable<TextField> textFields = IterableExtensions.<TextField>filter(_filter, _function);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    EList<EntityField> _fields_2 = it.getFields();
    Iterable<StringField> _filter_1 = Iterables.<StringField>filter(_fields_2, StringField.class);
    final Function1<StringField,Boolean> _function_1 = new Function1<StringField,Boolean>() {
        public Boolean apply(final StringField e) {
          boolean _and = false;
          boolean _isLeading = e.isLeading();
          boolean _not = (!_isLeading);
          if (!_not) {
            _and = false;
          } else {
            boolean _isPassword = e.isPassword();
            boolean _not_1 = (!_isPassword);
            _and = (_not && _not_1);
          }
          return Boolean.valueOf(_and);
        }
      };
    final Iterable<StringField> stringFields = IterableExtensions.<StringField>filter(_filter_1, _function_1);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(textFields);
      boolean _not_2 = (!_isEmpty);
      if (_not_2) {
        _builder.append("        ");
        _builder.append("$fieldName = \'");
        TextField _head_1 = IterableExtensions.<TextField>head(textFields);
        String _name_5 = _head_1.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode_2, "        ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isEmpty_1 = IterableExtensions.isEmpty(stringFields);
        boolean _not_3 = (!_isEmpty_1);
        if (_not_3) {
          _builder.append("        ");
          _builder.append("$fieldName = \'");
          StringField _head_2 = IterableExtensions.<StringField>head(stringFields);
          String _name_6 = _head_2.getName();
          String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_6);
          _builder.append(_formatForCode_3, "        ");
          _builder.append("\';");
          _builder.newLineIfNotEmpty();
        } else {
          _builder.append("        ");
          _builder.append("$fieldName = \'\';");
          _builder.newLine();
        }
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $fieldName;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Returns name of first upload field which is capable for handling images.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string Name of field to be used for preview images.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getPreviewFieldName()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$fieldName = \'");
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        Iterable<UploadField> _imageFieldsEntity = this._modelExtensions.getImageFieldsEntity(it);
        UploadField _head_3 = IterableExtensions.<UploadField>head(_imageFieldsEntity);
        String _name_7 = _head_3.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_7);
        _builder.append(_formatForCode_4, "        ");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $fieldName;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Returns name of the date(time) field to be used for representing the start");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* of this object. Used for providing meta data to the tag module.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string Name of field to be used as date.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getStartDateFieldName()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$fieldName = \'");
    {
      AbstractDateField _startDateField = this._modelExtensions.getStartDateField(it);
      boolean _tripleNotEquals_2 = (_startDateField != null);
      if (_tripleNotEquals_2) {
        AbstractDateField _startDateField_1 = this._modelExtensions.getStartDateField(it);
        String _name_8 = _startDateField_1.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_8);
        _builder.append(_formatForCode_5, "        ");
      } else {
        boolean _isStandardFields = it.isStandardFields();
        if (_isStandardFields) {
          _builder.append("createdDate");
        }
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $fieldName;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _additionalTemplateParameters = this.getAdditionalTemplateParameters(it);
    _builder.append(_additionalTemplateParameters, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _truncateTable = this.truncateTable(it);
    _builder.append(_truncateTable, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _or_2 = false;
      boolean _isStandardFields_1 = it.isStandardFields();
      if (_isStandardFields_1) {
        _or_2 = true;
      } else {
        boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
        _or_2 = (_isStandardFields_1 || _hasUserFieldsEntity);
      }
      if (_or_2) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _userDeleteFunctions = this.userDeleteFunctions(it);
        _builder.append(_userDeleteFunctions, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    CharSequence _selectById = this.selectById(it);
    _builder.append(_selectById, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _and_1 = false;
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (!_hasSluggableFields) {
        _and_1 = false;
      } else {
        boolean _isSlugUnique = it.isSlugUnique();
        _and_1 = (_hasSluggableFields && _isSlugUnique);
      }
      if (_and_1) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _selectBySlug = this.selectBySlug(it);
        _builder.append(_selectBySlug, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addExclusion = this.addExclusion(it);
    _builder.append(_addExclusion, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _selectWhere = this.selectWhere(it);
    _builder.append(_selectWhere, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _selectWherePaginated = this.selectWherePaginated(it);
    _builder.append(_selectWherePaginated, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _selectSearch = this.selectSearch(it);
    _builder.append(_selectSearch, "    ");
    _builder.newLineIfNotEmpty();
    {
      Iterable<DerivedField> _uniqueDerivedFields = this._modelExtensions.getUniqueDerivedFields(it);
      boolean _isEmpty_2 = IterableExtensions.isEmpty(_uniqueDerivedFields);
      boolean _not_4 = (!_isEmpty_2);
      if (_not_4) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _selectCount = this.selectCount(it);
        _builder.append(_selectCount, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    Tree _tree_6 = new Tree();
    CharSequence _generate = _tree_6.generate(it, this.app);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _detectUniqueState = this.detectUniqueState(it);
    _builder.append(_detectUniqueState, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _intBaseQuery = this.intBaseQuery(it);
    _builder.append(_intBaseQuery, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _intBaseQueryWhere = this.intBaseQueryWhere(it);
    _builder.append(_intBaseQueryWhere, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _intBaseQueryOrderBy = this.intBaseQueryOrderBy(it);
    _builder.append(_intBaseQueryOrderBy, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      boolean _not_5 = (!_hasCompositeKeys);
      if (_not_5) {
        _builder.append("    ");
        CharSequence _identifierListForRandomSorting = this.getIdentifierListForRandomSorting(it);
        _builder.append(_identifierListForRandomSorting, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _intGetQueryFromBuilder = this.intGetQueryFromBuilder(it);
    _builder.append(_intGetQueryFromBuilder, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    Joins _joins = new Joins();
    CharSequence _generate_1 = _joins.generate(it, this.app);
    _builder.append(_generate_1, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _and_2 = false;
      boolean _isHasArchive_1 = it.isHasArchive();
      if (!_isHasArchive_1) {
        _and_2 = false;
      } else {
        AbstractDateField _endDateField_1 = this._modelExtensions.getEndDateField(it);
        boolean _tripleNotEquals_3 = (_endDateField_1 != null);
        _and_2 = (_isHasArchive_1 && _tripleNotEquals_3);
      }
      if (_and_2) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _archiveObjects = this.archiveObjects(it);
        _builder.append(_archiveObjects, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getAdditionalTemplateParameters(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns an array of additional template variables which are specific to the object type treated by this repository.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args    Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of template variables to be assigned.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getAdditionalTemplateParameters($context = \'\', $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, array(\'controllerAction\', \'api\', \'actionHandler\', \'block\', \'contentType\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($context == \'controllerAction\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'action\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'action\'] = FormUtil::getPassedValue(\'func\', \'");
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\', \'GETPOST\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (in_array($args[\'action\'], array(\'");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\', \'view\'))) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$templateParameters = $this->getViewQuickNavParameters($context, $args);");
    _builder.newLine();
    {
      boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity) {
        _builder.append("            ");
        _builder.append("$listHelper = new ");
        {
          boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
          if (_targets_2) {
            Models _container = it.getContainer();
            Application _application = _container.getApplication();
            String _appName = this._utils.appName(_application);
            _builder.append(_appName, "            ");
            _builder.append("_Util_ListEntries");
          } else {
            _builder.append("ListEntriesUtil");
          }
        }
        _builder.append("(ServiceUtil::getManager()");
        {
          boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
          boolean _not = (!_targets_3);
          if (_not) {
            _builder.append(", ModUtil::getModule(\'");
            String _appName_1 = this._utils.appName(this.app);
            _builder.append(_appName_1, "            ");
            _builder.append("\')");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        {
          Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(it);
          for(final ListField field : _listFieldsEntity) {
            _builder.append("            ");
            String _name = field.getName();
            String fieldName = this._formattingExtensions.formatForCode(_name);
            _builder.newLineIfNotEmpty();
            _builder.append("            ");
            _builder.append("$templateParameters[\'");
            _builder.append(fieldName, "            ");
            _builder.append("Items\'] = $listHelper->getEntries(\'");
            String _name_1 = it.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode, "            ");
            _builder.append("\', \'");
            _builder.append(fieldName, "            ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasBooleanFieldsEntity = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity) {
        _builder.append("            ");
        _builder.append("$booleanSelectorItems = array(");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("array(\'value\' => \'no\', \'text\' => __(\'No\')),");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("array(\'value\' => \'yes\', \'text\' => __(\'Yes\'))");
        _builder.newLine();
        _builder.append("            ");
        _builder.append(");");
        _builder.newLine();
        {
          Iterable<BooleanField> _booleanFieldsEntity = this._modelExtensions.getBooleanFieldsEntity(it);
          for(final BooleanField field_1 : _booleanFieldsEntity) {
            _builder.append("            ");
            String _name_2 = field_1.getName();
            final String fieldName_1 = this._formattingExtensions.formatForCode(_name_2);
            _builder.newLineIfNotEmpty();
            _builder.append("            ");
            _builder.append("$templateParameters[\'");
            _builder.append(fieldName_1, "            ");
            _builder.append("Items\'] = $booleanSelectorItems;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(this.app);
      if (_hasUploads) {
        _builder.append("        ");
        _builder.append("// initialise Imagine preset instances");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$imageHelper = new ");
        {
          boolean _targets_4 = this._utils.targets(this.app, "1.3.5");
          if (_targets_4) {
            Models _container_1 = it.getContainer();
            Application _application_1 = _container_1.getApplication();
            String _appName_2 = this._utils.appName(_application_1);
            _builder.append(_appName_2, "        ");
            _builder.append("_Util_Image");
          } else {
            _builder.append("ImageUtil");
          }
        }
        _builder.append("(ServiceUtil::getManager()");
        {
          boolean _targets_5 = this._utils.targets(this.app, "1.3.5");
          boolean _not_1 = (!_targets_5);
          if (_not_1) {
            _builder.append(", ModUtil::getModule(\'");
            String _appName_3 = this._utils.appName(this.app);
            _builder.append(_appName_3, "        ");
            _builder.append("\')");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
          if (_hasUploadFieldsEntity) {
            _builder.newLine();
            _builder.append("        ");
            _builder.append("$objectType = \'");
            String _name_3 = it.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_3);
            _builder.append(_formatForCode_1, "        ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
            {
              Iterable<UploadField> _uploadFieldsEntity = this._modelExtensions.getUploadFieldsEntity(it);
              for(final UploadField uploadField : _uploadFieldsEntity) {
                _builder.append("        ");
                _builder.append("$templateParameters[$objectType . \'ThumbPreset");
                String _name_4 = uploadField.getName();
                String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_4);
                _builder.append(_formatForCodeCapital, "        ");
                _builder.append("\'] = $imageHelper->getPreset($objectType, \'");
                String _name_5 = uploadField.getName();
                String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_5);
                _builder.append(_formatForCode_2, "        ");
                _builder.append("\', $context, $args);");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        _builder.append("        ");
        _builder.append("if (in_array($args[\'action\'], array(\'display\', \'view\'))) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// use separate preset for images in related items");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$templateParameters[\'relationThumbPreset\'] = $imageHelper->getCustomPreset(\'\', \'\', \'");
        Models _container_2 = it.getContainer();
        Application _application_2 = _container_2.getApplication();
        String _appName_4 = this._utils.appName(_application_2);
        _builder.append(_appName_4, "            ");
        _builder.append("_relateditem\', $context, $args);");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// in the concrete child class you could do something like");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// $parameters = parent::getAdditionalTemplateParameters($context, $args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// $parameters[\'myvar\'] = \'myvalue\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return $parameters;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $templateParameters;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns an array of additional template variables for view quick navigation forms.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args    Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of template variables to be assigned.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getViewQuickNavParameters($context = \'\', $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, array(\'controllerAction\', \'api\', \'actionHandler\', \'block\', \'contentType\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$parameters = array();");
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("    ");
        _builder.append("$parameters[\'catIdList\'] = ModUtil::apiFunc(\'");
        Models _container_3 = it.getContainer();
        Application _application_3 = _container_3.getApplication();
        String _appName_5 = this._utils.appName(_application_3);
        _builder.append(_appName_5, "    ");
        _builder.append("\', \'category\', \'retrieveCategoriesFromRequest\', array(\'ot\' => \'");
        String _name_6 = it.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_3, "    ");
        _builder.append("\', \'source\' => \'GET\', \'controllerArgs\' => $this->controllerArguments));");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelationsWithOneSource = this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(it);
      boolean _isEmpty = IterableExtensions.isEmpty(_bidirectionalIncomingJoinRelationsWithOneSource);
      boolean _not_2 = (!_isEmpty);
      if (_not_2) {
        {
          Iterable<JoinRelationship> _bidirectionalIncomingJoinRelationsWithOneSource_1 = this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(it);
          for(final JoinRelationship relation : _bidirectionalIncomingJoinRelationsWithOneSource_1) {
            _builder.append("    ");
            final String sourceAliasName = this._namingExtensions.getRelationAliasName(relation, Boolean.valueOf(false));
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(sourceAliasName, "    ");
            _builder.append("\'] = isset($this->controllerArguments[\'");
            _builder.append(sourceAliasName, "    ");
            _builder.append("\']) ? $this->controllerArguments[\'");
            _builder.append(sourceAliasName, "    ");
            _builder.append("\'] : FormUtil::getPassedValue(\'");
            _builder.append(sourceAliasName, "    ");
            _builder.append("\', 0, \'GET\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasListFieldsEntity_1 = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity_1) {
        {
          Iterable<ListField> _listFieldsEntity_1 = this._modelExtensions.getListFieldsEntity(it);
          for(final ListField field_2 : _listFieldsEntity_1) {
            _builder.append("    ");
            String _name_7 = field_2.getName();
            final String fieldName_2 = this._formattingExtensions.formatForCode(_name_7);
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_2, "    ");
            _builder.append("\'] = isset($this->controllerArguments[\'");
            _builder.append(fieldName_2, "    ");
            _builder.append("\']) ? $this->controllerArguments[\'");
            _builder.append(fieldName_2, "    ");
            _builder.append("\'] : FormUtil::getPassedValue(\'");
            _builder.append(fieldName_2, "    ");
            _builder.append("\', \'\', \'GET\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity) {
        {
          Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
          for(final UserField field_3 : _userFieldsEntity) {
            _builder.append("    ");
            String _name_8 = field_3.getName();
            final String fieldName_3 = this._formattingExtensions.formatForCode(_name_8);
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_3, "    ");
            _builder.append("\'] = isset($this->controllerArguments[\'");
            _builder.append(fieldName_3, "    ");
            _builder.append("\']) ? $this->controllerArguments[\'");
            _builder.append(fieldName_3, "    ");
            _builder.append("\'] : (int) FormUtil::getPassedValue(\'");
            _builder.append(fieldName_3, "    ");
            _builder.append("\', 0, \'GET\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasCountryFieldsEntity = this._modelExtensions.hasCountryFieldsEntity(it);
      if (_hasCountryFieldsEntity) {
        {
          Iterable<StringField> _countryFieldsEntity = this._modelExtensions.getCountryFieldsEntity(it);
          for(final StringField field_4 : _countryFieldsEntity) {
            _builder.append("    ");
            String _name_9 = field_4.getName();
            final String fieldName_4 = this._formattingExtensions.formatForCode(_name_9);
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_4, "    ");
            _builder.append("\'] = isset($this->controllerArguments[\'");
            _builder.append(fieldName_4, "    ");
            _builder.append("\']) ? $this->controllerArguments[\'");
            _builder.append(fieldName_4, "    ");
            _builder.append("\'] : FormUtil::getPassedValue(\'");
            _builder.append(fieldName_4, "    ");
            _builder.append("\', \'\', \'GET\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasLanguageFieldsEntity = this._modelExtensions.hasLanguageFieldsEntity(it);
      if (_hasLanguageFieldsEntity) {
        {
          Iterable<StringField> _languageFieldsEntity = this._modelExtensions.getLanguageFieldsEntity(it);
          for(final StringField field_5 : _languageFieldsEntity) {
            _builder.append("    ");
            String _name_10 = field_5.getName();
            final String fieldName_5 = this._formattingExtensions.formatForCode(_name_10);
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_5, "    ");
            _builder.append("\'] = isset($this->controllerArguments[\'");
            _builder.append(fieldName_5, "    ");
            _builder.append("\']) ? $this->controllerArguments[\'");
            _builder.append(fieldName_5, "    ");
            _builder.append("\'] : FormUtil::getPassedValue(\'");
            _builder.append(fieldName_5, "    ");
            _builder.append("\', \'\', \'GET\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _builder.append("    ");
        _builder.append("$parameters[\'searchterm\'] = isset($this->controllerArguments[\'searchterm\']) ? $this->controllerArguments[\'searchterm\'] : FormUtil::getPassedValue(\'searchterm\', \'\', \'GET\');");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.newLine();
    {
      boolean _hasBooleanFieldsEntity_1 = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity_1) {
        {
          Iterable<BooleanField> _booleanFieldsEntity_1 = this._modelExtensions.getBooleanFieldsEntity(it);
          for(final BooleanField field_6 : _booleanFieldsEntity_1) {
            _builder.append("    ");
            String _name_11 = field_6.getName();
            final String fieldName_6 = this._formattingExtensions.formatForCode(_name_11);
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_6, "    ");
            _builder.append("\'] = isset($this->controllerArguments[\'");
            _builder.append(fieldName_6, "    ");
            _builder.append("\']) ? $this->controllerArguments[\'");
            _builder.append(fieldName_6, "    ");
            _builder.append("\'] : FormUtil::getPassedValue(\'");
            _builder.append(fieldName_6, "    ");
            _builder.append("\', \'\', \'GET\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// in the concrete child class you could do something like");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// $parameters = parent::getViewQuickNavParameters($context, $args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// $parameters[\'myvar\'] = \'myvalue\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return $parameters;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $parameters;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence truncateTable(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper method for truncating the table.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Used during installation when inserting default data.");
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
    _builder.append("public function truncateTable()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->delete(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "    ");
    _builder.append("\', \'tbl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    {
      boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
      if (_hasPessimisticWriteLock) {
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        EntityLockType _lockType = it.getLockType();
        String _asConstant = this._modelExtensions.asConstant(_lockType);
        _builder.append(_asConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence userDeleteFunctions(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Deletes all objects created by a certain user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $userId The userid of the creator to be removed.");
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
        _builder.append("public function deleteCreator($userId)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check id parameter");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($userId == 0 || !is_numeric($userId)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return LogUtil::registerArgsError();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb->delete(\'");
        String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName, "    ");
        _builder.append("\', \'tbl\')");
        _builder.newLineIfNotEmpty();
        _builder.append("       ");
        _builder.append("->where(\'tbl.createdUserId = :creator\')");
        _builder.newLine();
        _builder.append("       ");
        _builder.append("->setParameter(\'creator\', DataUtil::formatForStore($userId));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$query = $qb->getQuery();");
        _builder.newLine();
        {
          boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
          if (_hasPessimisticWriteLock) {
            _builder.append("    ");
            _builder.append("$query->setLockMode(LockMode::");
            EntityLockType _lockType = it.getLockType();
            String _asConstant = this._modelExtensions.asConstant(_lockType);
            _builder.append(_asConstant, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("$query->execute();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Deletes all objects updated by a certain user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $userId The userid of the last editor to be removed.");
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
        _builder.append("public function deleteLastEditor($userId)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check id parameter");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($userId == 0 || !is_numeric($userId)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return LogUtil::registerArgsError();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb->delete(\'");
        String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_1, "    ");
        _builder.append("\', \'tbl\')");
        _builder.newLineIfNotEmpty();
        _builder.append("       ");
        _builder.append("->where(\'tbl.updatedUserId = :editor\')");
        _builder.newLine();
        _builder.append("       ");
        _builder.append("->setParameter(\'editor\', DataUtil::formatForStore($userId));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$query = $qb->getQuery();");
        _builder.newLine();
        {
          boolean _hasPessimisticWriteLock_1 = this._modelExtensions.hasPessimisticWriteLock(it);
          if (_hasPessimisticWriteLock_1) {
            _builder.append("    ");
            _builder.append("$query->setLockMode(LockMode::");
            EntityLockType _lockType_1 = it.getLockType();
            String _asConstant_1 = this._modelExtensions.asConstant(_lockType_1);
            _builder.append(_asConstant_1, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("$query->execute();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Updates the creator of all objects created by a certain user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $userId    The userid of the creator to be replaced.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $newUserId The new userid of the creator as replacement.");
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
        _builder.append("public function updateCreator($userId, $newUserId)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check id parameter");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($userId == 0 || !is_numeric($userId)");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("|| $newUserId == 0 || !is_numeric($newUserId)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return LogUtil::registerArgsError();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb->update(\'");
        String _entityClassName_2 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_2, "    ");
        _builder.append("\', \'tbl\')");
        _builder.newLineIfNotEmpty();
        _builder.append("       ");
        _builder.append("->set(\'tbl.createdUserId\', $newUserId)");
        _builder.newLine();
        _builder.append("       ");
        _builder.append("->where(\'tbl.createdUserId = :creator\')");
        _builder.newLine();
        _builder.append("       ");
        _builder.append("->setParameter(\'creator\', DataUtil::formatForStore($userId));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$query = $qb->getQuery();");
        _builder.newLine();
        {
          boolean _hasPessimisticWriteLock_2 = this._modelExtensions.hasPessimisticWriteLock(it);
          if (_hasPessimisticWriteLock_2) {
            _builder.append("    ");
            _builder.append("$query->setLockMode(LockMode::");
            EntityLockType _lockType_2 = it.getLockType();
            String _asConstant_2 = this._modelExtensions.asConstant(_lockType_2);
            _builder.append(_asConstant_2, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("$query->execute();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Updates the last editor of all objects updated by a certain user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $userId    The userid of the last editor to be replaced.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $newUserId The new userid of the last editor as replacement.");
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
        _builder.append("public function updateLastEditor($userId, $newUserId)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check id parameter");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($userId == 0 || !is_numeric($userId)");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("|| $newUserId == 0 || !is_numeric($newUserId)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return LogUtil::registerArgsError();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb->update(\'");
        String _entityClassName_3 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_3, "    ");
        _builder.append("\', \'tbl\')");
        _builder.newLineIfNotEmpty();
        _builder.append("       ");
        _builder.append("->set(\'tbl.updatedUserId\', $newUserId)");
        _builder.newLine();
        _builder.append("       ");
        _builder.append("->where(\'tbl.updatedUserId = :editor\')");
        _builder.newLine();
        _builder.append("       ");
        _builder.append("->setParameter(\'editor\', DataUtil::formatForStore($userId));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$query = $qb->getQuery();");
        _builder.newLine();
        {
          boolean _hasPessimisticWriteLock_3 = this._modelExtensions.hasPessimisticWriteLock(it);
          if (_hasPessimisticWriteLock_3) {
            _builder.append("    ");
            _builder.append("$query->setLockMode(LockMode::");
            EntityLockType _lockType_3 = it.getLockType();
            String _asConstant_3 = this._modelExtensions.asConstant(_lockType_3);
            _builder.append(_asConstant_3, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("$query->execute();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity) {
        {
          boolean _isStandardFields_1 = it.isStandardFields();
          if (_isStandardFields_1) {
            _builder.newLine();
          }
        }
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Updates a user field value of all objects affected by a certain user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param string  $fieldName The name of the user field.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $userId    The userid to be replaced.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $newUserId The new userid as replacement.");
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
        _builder.append("public function updateUserField($userFieldName, $userId, $newUserId)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check field parameter");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (empty($userFieldName) || !in_array($userFieldName, array(");
        {
          Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
          boolean _hasElements = false;
          for(final UserField field : _userFieldsEntity) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "    ");
            }
            _builder.append("\'");
            String _name = field.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "    ");
            _builder.append("\'");
          }
        }
        _builder.append("))) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("return LogUtil::registerArgsError();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check id parameter");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($userId == 0 || !is_numeric($userId)");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("|| $newUserId == 0 || !is_numeric($newUserId)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return LogUtil::registerArgsError();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb->update(\'");
        String _entityClassName_4 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_4, "    ");
        _builder.append("\', \'tbl\')");
        _builder.newLineIfNotEmpty();
        _builder.append("       ");
        _builder.append("->set(\'tbl.\' . $userFieldName, $newUserId)");
        _builder.newLine();
        _builder.append("       ");
        _builder.append("->where(\'tbl.\' . $userFieldName . \' = :user\')");
        _builder.newLine();
        _builder.append("       ");
        _builder.append("->setParameter(\'user\', DataUtil::formatForStore($userId));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$query = $qb->getQuery();");
        _builder.newLine();
        {
          boolean _hasPessimisticWriteLock_4 = this._modelExtensions.hasPessimisticWriteLock(it);
          if (_hasPessimisticWriteLock_4) {
            _builder.append("    ");
            _builder.append("$query->setLockMode(LockMode::");
            EntityLockType _lockType_4 = it.getLockType();
            String _asConstant_4 = this._modelExtensions.asConstant(_lockType_4);
            _builder.append(_asConstant_4, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("$query->execute();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence selectById(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds id filters to given query instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param mixed                     $id The id (or array of ids) to use to retrieve the object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb Query builder to be enhanced.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder Enriched query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addIdFilter($id, QueryBuilder $qb)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (is_array($id)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($id as $fieldName => $fieldValue) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$qb->andWhere(\'tbl.\' . $fieldName . \' = :\' . $fieldName)");
    _builder.newLine();
    _builder.append("               ");
    _builder.append("->setParameter($fieldName, DataUtil::formatForStore($fieldValue));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->andWhere(\'tbl.");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name = _firstPrimaryKey.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "        ");
    _builder.append(" = :id\')");
    _builder.newLineIfNotEmpty();
    _builder.append("           ");
    _builder.append("->setParameter(\'id\', DataUtil::formatForStore($id));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects an object from the database.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param mixed   $id       The id (or array of ids) to use to retrieve the object (optional) (default=0).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.append(" retrieved data array or ");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, " ");
    _builder.append(" instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectById($id = 0, $useJoins = true, $slimMode = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check id parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($id == 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerArgsError();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->_intBaseQuery(\'\', \'\', $useJoins, $slimMode);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->addIdFilter($id, $qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$results = $query->getResult();//OneOrNullResult();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return (count($results) > 0) ? $results[0] : null;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectBySlug(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects an object by slug field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $slugTitle The slug value");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins  Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $excludeId Optional id to be excluded (used for unique validation).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.append(" retrieved instance of ");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectBySlug($slugTitle = \'\', $useJoins = true, $slimMode = false, $excludeId = 0)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check input parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($slugTitle == \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerArgsError();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->_intBaseQuery(\'\', \'\', $useJoins, $slimMode);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->andWhere(\'tbl.slug = :slug\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'slug\', DataUtil::formatForStore($slugTitle));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->addExclusion($qb, $excludeId);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$results = $query->getResult();//OneOrNullResult();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return (count($results) > 0) ? $results[0] : null;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addExclusion(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds where clauses excluding desired identifiers from selection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb        Query builder to be enhanced.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        _builder.append("mixed  ");
      } else {
        _builder.append("integer");
      }
    }
    _builder.append("                   $excludeId The id (or array of ids) to be excluded from selection.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder Enriched query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addExclusion(QueryBuilder $qb, $excludeId)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasCompositeKeys_1 = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys_1) {
        _builder.append("    ");
        _builder.append("if (is_array($excludeId)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("foreach ($id as $fieldName => $fieldValue) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$qb->andWhere(\'tbl.\' . $fieldName . \' != :\' . $fieldName)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("           ");
        _builder.append("->setParameter($fieldName, DataUtil::formatForStore($fieldValue));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} elseif ($excludeId > 0) {");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("if ($excludeId > 0) {");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$qb->andWhere(\'tbl.id != :excludeId\')");
    _builder.newLine();
    _builder.append("           ");
    _builder.append("->setParameter(\'excludeId\', DataUtil::formatForStore($excludeId));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectWhere(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects a list of objects with a given where clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $where    The where clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ArrayCollection collection containing retrieved ");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.append(" instances");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectWhere($where = \'\', $orderBy = \'\', $useJoins = true, $slimMode = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->_intBaseQuery($where, $orderBy, $useJoins, $slimMode);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$useJoins || !$slimMode) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb = $this->addCommonViewFilters($qb);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $query->getResult();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectWherePaginated(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns query builder instance for retrieving a list of objects with a given where clause and pagination parameters.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb             Query builder to be enhanced.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer                   $currentPage    Where to start selection");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer                   $resultsPerPage Amount of items to select");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Created query instance and amount of affected items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getSelectWherePaginatedQuery(QueryBuilder $qb, $currentPage = 1, $resultsPerPage = 25)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->addCommonViewFilters($qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$offset = ($currentPage-1) * $resultsPerPage;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("// count the total number of affected items");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$count = Paginate::getTotalQueryResults($query);");
        _builder.newLine();
        _builder.newLine();
        {
          boolean _and = false;
          EList<Relationship> _outgoing = it.getOutgoing();
          Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_outgoing, JoinRelationship.class);
          boolean _isEmpty = IterableExtensions.isEmpty(_filter);
          if (!_isEmpty) {
            _and = false;
          } else {
            EList<Relationship> _incoming = it.getIncoming();
            Iterable<JoinRelationship> _filter_1 = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
            boolean _isEmpty_1 = IterableExtensions.isEmpty(_filter_1);
            _and = (_isEmpty && _isEmpty_1);
          }
          boolean _not = (!_and);
          if (_not) {
            _builder.append("    ");
            _builder.append("// prefetch unique relationship ids for given pagination frame");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$query = Paginate::getPaginateQuery($query, $offset, $resultsPerPage);");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$query->setFirstResult($offset)");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("      ");
            _builder.append("->setMaxResults($resultsPerPage);");
            _builder.newLine();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("$query->setFirstResult($offset)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("      ");
        _builder.append("->setMaxResults($resultsPerPage);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$count = 0; // will be set at a later stage (in calling method)");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array($query, $count);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects a list of objects with a given where clause and pagination parameters.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $where          The where clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $currentPage    Where to start selection");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $resultsPerPage Amount of items to select");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins       Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Array with retrieved collection and amount of total records affected by this query.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectWherePaginated($where = \'\', $orderBy = \'\', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->_intBaseQuery($where, $orderBy, $useJoins);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($query, $count) = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        _builder.append("    ");
        _builder.append("$result = $query->getResult();");
        _builder.newLine();
      } else {
        {
          boolean _and_1 = false;
          EList<Relationship> _outgoing_1 = it.getOutgoing();
          Iterable<JoinRelationship> _filter_2 = Iterables.<JoinRelationship>filter(_outgoing_1, JoinRelationship.class);
          boolean _isEmpty_2 = IterableExtensions.isEmpty(_filter_2);
          if (!_isEmpty_2) {
            _and_1 = false;
          } else {
            EList<Relationship> _incoming_1 = it.getIncoming();
            Iterable<JoinRelationship> _filter_3 = Iterables.<JoinRelationship>filter(_incoming_1, JoinRelationship.class);
            boolean _isEmpty_3 = IterableExtensions.isEmpty(_filter_3);
            _and_1 = (_isEmpty_2 && _isEmpty_3);
          }
          boolean _not_1 = (!_and_1);
          if (_not_1) {
            _builder.append("    ");
            _builder.append("$paginator = new Paginator($query, true);");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$paginator = new Paginator($query, false);");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$count = count($paginator);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result = $paginator;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array($result, $count);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds quick navigation related filter options as where clauses.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb Query builder to be enhanced.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder Enriched query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addCommonViewFilters(QueryBuilder $qb)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/* commented out to allow default filters also for other calls, like content types and mailz");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentFunc = FormUtil::getPassedValue(\'func\', \'");
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      if (_targets_2) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\', \'GETPOST\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!in_array($currentFunc, array(\'main\', \'view\', \'finder\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$parameters = $this->getViewQuickNavParameters(\'\', array());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($parameters as $k => $v) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($k == \'catId\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// single category filter");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($v > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$qb->andWhere(\'tblCategories.category = :category\')");
    _builder.newLine();
    _builder.append("                   ");
    _builder.append("->setParameter(\'category\', DataUtil::formatForStore($v));");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} elseif ($k == \'catIdList\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// multi category filter");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("/* old");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$qb->andWhereIn(\'tblCategories.category IN (:categories)\')");
    _builder.newLine();
    _builder.append("               ");
    _builder.append("->setParameter(\'categories\', DataUtil::formatForStore($v));");
    _builder.newLine();
    _builder.append("             ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$categoryFiltersPerRegistry = ModUtil::apiFunc(\'");
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    _builder.append(_appName, "            ");
    _builder.append("\', \'category\', \'buildFilterClauses\', array(\'ot\' => \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "            ");
    _builder.append("\', \'catids\' => $v));");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("if (count($categoryFiltersPerRegistry) > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$qb->andWhere(\'(\' . implode(\' OR \', $categoryFiltersPerRegistry) . \')\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} elseif ($k == \'searchterm\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// quick search");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!empty($v)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$qb = $this->addSearchFilter($qb, $v);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasBooleanFieldsEntity = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity) {
        _builder.append("        ");
        _builder.append("} elseif (in_array($k, array(");
        {
          Iterable<BooleanField> _booleanFieldsEntity = this._modelExtensions.getBooleanFieldsEntity(it);
          boolean _hasElements = false;
          for(final BooleanField field : _booleanFieldsEntity) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "        ");
            }
            _builder.append("\'");
            String _name_1 = field.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "        ");
            _builder.append("\'");
          }
        }
        _builder.append("))) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// boolean filter");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("if ($v == \'no\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$qb->andWhere(\'tbl.\' . $k . \' = 0\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("} elseif ($v == \'yes\' || $v == \'1\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$qb->andWhere(\'tbl.\' . $k . \' = 1\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// field filter");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($v != \'\' || (is_numeric($v) && $v > 0)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if ($k == \'workflowState\' && substr($v, 0, 1) == \'!\') {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$qb->andWhere(\'tbl.\' . $k . \' != :\' . $k)");
    _builder.newLine();
    _builder.append("                       ");
    _builder.append("->setParameter($k, DataUtil::formatForStore(substr($v, 1, strlen($v)-1)));");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} elseif (substr($v, 0, 1) == \'%\') {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$qb->andWhere(\'tbl.\' . $k . \' LIKE :\' . $k)");
    _builder.newLine();
    _builder.append("                       ");
    _builder.append("->setParameter($k, \'%\' . DataUtil::formatForStore($v) . \'%\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$qb->andWhere(\'tbl.\' . $k . \' = :\' . $k)");
    _builder.newLine();
    _builder.append("                       ");
    _builder.append("->setParameter($k, DataUtil::formatForStore($v));");
    _builder.newLine();
    _builder.append("               ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->applyDefaultFilters($qb, $parameters);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds default filters as where clauses.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb         Query builder to be enhanced.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array                     $parameters List of determined filter options.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder Enriched query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function applyDefaultFilters(QueryBuilder $qb, $parameters)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentModule = ModUtil::getName();//FormUtil::getPassedValue(\'module\', \'\', \'GETPOST\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentType = FormUtil::getPassedValue(\'type\', \'user\', \'GETPOST\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($currentType == \'admin\' && $currentModule == \'");
    Models _container_1 = it.getContainer();
    Application _application_1 = _container_1.getApplication();
    String _appName_1 = this._utils.appName(_application_1);
    _builder.append(_appName_1, "    ");
    _builder.append("\') {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array(\'workflowState\', array_keys($parameters)) || empty($parameters[\'workflowState\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// per default we show approved ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "        ");
    _builder.append(" only");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$onlineStates = array(\'approved\');");
    _builder.newLine();
    {
      boolean _isOwnerPermission = it.isOwnerPermission();
      if (_isOwnerPermission) {
        _builder.append("        ");
        _builder.append("$onlyOwn = (int) FormUtil::getPassedValue(\'own\', 0, \'GETPOST\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if ($onlyOwn == 1) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// allow the owner to see his deferred ");
        String _nameMultiple_1 = it.getNameMultiple();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple_1);
        _builder.append(_formatForDisplay_1, "            ");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$onlineStates[] = \'deferred\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$qb->andWhere(\'tbl.workflowState IN (:onlineStates)\')");
    _builder.newLine();
    _builder.append("           ");
    _builder.append("->setParameter(\'onlineStates\', DataUtil::formatForStore($onlineStates));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _applyDefaultDateRangeFilter = this.applyDefaultDateRangeFilter(it);
    _builder.append(_applyDefaultDateRangeFilter, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence applyDefaultDateRangeFilter(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final AbstractDateField startDateField = this._modelExtensions.getStartDateField(it);
    _builder.newLineIfNotEmpty();
    final AbstractDateField endDateField = this._modelExtensions.getEndDateField(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (startDateField != null);
      if (_tripleNotEquals) {
        _builder.append("$startDate = FormUtil::getPassedValue(\'");
        String _name = startDateField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\', ");
        CharSequence _defaultValueForNow = this.defaultValueForNow(startDateField);
        _builder.append(_defaultValueForNow, "");
        _builder.append(", \'GET\');");
        _builder.newLineIfNotEmpty();
        _builder.append("$qb->andWhere(\'");
        CharSequence _whereClauseForDateRangeFilter = this.whereClauseForDateRangeFilter(it, "<=", startDateField, "startDate");
        _builder.append(_whereClauseForDateRangeFilter, "");
        _builder.append("\')");
        _builder.newLineIfNotEmpty();
        _builder.append("   ");
        _builder.append("->setParameter(\'startDate\', $startDate);");
        _builder.newLine();
      }
    }
    {
      boolean _tripleNotEquals_1 = (endDateField != null);
      if (_tripleNotEquals_1) {
        _builder.append("$endDate = FormUtil::getPassedValue(\'");
        String _name_1 = endDateField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("\', ");
        CharSequence _defaultValueForNow_1 = this.defaultValueForNow(endDateField);
        _builder.append(_defaultValueForNow_1, "");
        _builder.append(", \'GET\');");
        _builder.newLineIfNotEmpty();
        _builder.append("$qb->andWhere(\'");
        CharSequence _whereClauseForDateRangeFilter_1 = this.whereClauseForDateRangeFilter(it, ">=", endDateField, "endDate");
        _builder.append(_whereClauseForDateRangeFilter_1, "");
        _builder.append("\')");
        _builder.newLineIfNotEmpty();
        _builder.append("   ");
        _builder.append("->setParameter(\'endDate\', $endDate);");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _defaultValueForNow(final EntityField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"\"");
    return _builder;
  }
  
  private CharSequence _defaultValueForNow(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("date(\'Y-m-d H:i:s\')");
    return _builder;
  }
  
  private CharSequence _defaultValueForNow(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("date(\'Y-m-d\')");
    return _builder;
  }
  
  private CharSequence whereClauseForDateRangeFilter(final Entity it, final String operator, final DerivedField dateField, final String paramName) {
    CharSequence _xblockexpression = null;
    {
      String _name = dateField.getName();
      final String dateFieldName = this._formattingExtensions.formatForCode(_name);
      CharSequence _xifexpression = null;
      boolean _isMandatory = dateField.isMandatory();
      if (_isMandatory) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("tbl.");
        _builder.append(dateFieldName, "");
        _builder.append(" ");
        _builder.append(operator, "");
        _builder.append(" :");
        _builder.append(paramName, "");
        _xifexpression = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("(tbl.");
        _builder_1.append(dateFieldName, "");
        _builder_1.append(" ");
        _builder_1.append(operator, "");
        _builder_1.append(" :");
        _builder_1.append(paramName, "");
        _builder_1.append(" OR tbl.");
        _builder_1.append(dateFieldName, "");
        _builder_1.append(" IS NULL)");
        _xifexpression = _builder_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  private CharSequence selectSearch(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects entities by a given search fragment.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $fragment       The fragment to search for.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $exclude        Comma separated list with ids to be excluded from search.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $currentPage    Where to start selection");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $resultsPerPage Amount of items to select");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins       Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Array with retrieved collection and amount of total records affected by this query.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectSearch($fragment = \'\', $exclude = array(), $orderBy = \'\', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->_intBaseQuery(\'\', $orderBy, $useJoins);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (count($exclude) > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$exclude = implode(\', \', $exclude);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->andWhere(\'tbl.");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name = _firstPrimaryKey.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "        ");
    _builder.append(" NOT IN (:excludeList)\')");
    _builder.newLineIfNotEmpty();
    _builder.append("           ");
    _builder.append("->setParameter(\'excludeList\', DataUtil::formatForStore($exclude));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->addSearchFilter($qb, $fragment);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($query, $count) = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$result = $query->getResult();");
        _builder.newLine();
      } else {
        {
          boolean _and = false;
          EList<Relationship> _outgoing = it.getOutgoing();
          Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_outgoing, JoinRelationship.class);
          boolean _isEmpty = IterableExtensions.isEmpty(_filter);
          if (!_isEmpty) {
            _and = false;
          } else {
            EList<Relationship> _incoming = it.getIncoming();
            Iterable<JoinRelationship> _filter_1 = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
            boolean _isEmpty_1 = IterableExtensions.isEmpty(_filter_1);
            _and = (_isEmpty && _isEmpty_1);
          }
          boolean _not = (!_and);
          if (_not) {
            _builder.append("    ");
            _builder.append("$paginator = new Paginator($query, true);");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$paginator = new Paginator($query, false);");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$count = count($paginator);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result = $paginator;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array($result, $count);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds where clause for search query.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb       Query builder to be enhanced.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string                    $fragment The fragment to search for.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder Enriched query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addSearchFilter(QueryBuilder $qb, $fragment = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($fragment == \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fragment = DataUtil::formatForStore($fragment);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fragmentIsNumeric = is_numeric($fragment);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    Iterable<DerivedField> _displayFields = this._modelExtensions.getDisplayFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          boolean _isContainedInTextualSearch = Repository.this.isContainedInTextualSearch(e);
          return Boolean.valueOf(_isContainedInTextualSearch);
        }
      };
    final Iterable<DerivedField> searchFields = IterableExtensions.<DerivedField>filter(_displayFields, _function);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    Iterable<DerivedField> _displayFields_1 = this._modelExtensions.getDisplayFields(it);
    final Function1<DerivedField,Boolean> _function_1 = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          boolean _isContainedInNumericSearch = Repository.this.isContainedInNumericSearch(e);
          return Boolean.valueOf(_isContainedInNumericSearch);
        }
      };
    final Iterable<DerivedField> searchFieldsNumeric = IterableExtensions.<DerivedField>filter(_displayFields_1, _function_1);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$where = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$fragmentIsNumeric) {");
    _builder.newLine();
    {
      for(final DerivedField field : searchFields) {
        _builder.append("    ");
        _builder.append("$where .= ((!empty($where)) ? \' OR \' : \'\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$where .= \'tbl.");
        String _name_1 = field.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append(" ");
        {
          boolean _isTextSearch = this.isTextSearch(field);
          if (_isTextSearch) {
            _builder.append("LIKE \\\'%\' . $fragment . \'%\\\'\'");
          } else {
            _builder.append("= \\\'\' . $fragment . \'\\\'\'");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    {
      for(final DerivedField field_1 : searchFieldsNumeric) {
        _builder.append("    ");
        _builder.append("$where .= ((!empty($where)) ? \' OR \' : \'\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$where .= \'tbl.");
        String _name_2 = field_1.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "    ");
        _builder.append(" ");
        {
          boolean _isTextSearch_1 = this.isTextSearch(field_1);
          if (_isTextSearch_1) {
            _builder.append("LIKE \\\'%\' . $fragment . \'%\\\'\'");
          } else {
            _builder.append("= \\\'\' . $fragment . \'\\\'\'");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = \'(\' . $where . \')\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->andWhere($where);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectCount(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns query builder instance for a count query.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $where    The where clause to use when retrieving the object count (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder Created query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @TODO fix usage of joins; please remove the first line and test.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getCountQuery($where = \'\', $useJoins = true)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$useJoins = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selection = \'COUNT(tbl.");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name = _firstPrimaryKey.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append(") AS num");
    String _nameMultiple = it.getNameMultiple();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_nameMultiple);
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($useJoins === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$selection .= $this->addJoinsToSelection();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->select($selection)");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->from(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "       ");
    _builder.append("\', \'tbl\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($useJoins === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addJoinsToFrom($qb);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($where)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->where($where);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects entity count with a given where clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $where    The where clause to use when retrieving the object count (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return integer amount of affected records");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectCount($where = \'\', $useJoins = true)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getCountQuery($where, $useJoins);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    {
      boolean _hasPessimisticReadLock = this._modelExtensions.hasPessimisticReadLock(it);
      if (_hasPessimisticReadLock) {
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        EntityLockType _lockType = it.getLockType();
        String _asConstant = this._modelExtensions.asConstant(_lockType);
        _builder.append(_asConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("return $query->getSingleScalarResult();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence detectUniqueState(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Checks for unique values.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  The name of the property to be checked");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldValue The value of the property to be checked");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int    $excludeId  Id of ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" to exclude (optional).");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean result of this check, true if the given ");
    String _name = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" does not already exist");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function detectUniqueState($fieldName, $fieldValue, $excludeId = 0)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getCountQuery(\'\', false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->andWhere(\'tbl.\' . $fieldName . \' = :\' . $fieldName)");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter($fieldName, DataUtil::formatForStore($fieldValue));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->addExclusion($qb, $excludeId);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasPessimisticReadLock = this._modelExtensions.hasPessimisticReadLock(it);
      if (_hasPessimisticReadLock) {
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        EntityLockType _lockType = it.getLockType();
        String _asConstant = this._modelExtensions.asConstant(_lockType);
        _builder.append(_asConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$count = $query->getSingleScalarResult();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ($count == 0);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence intBaseQuery(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Builds a generic Doctrine query supporting WHERE and ORDER BY.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $where    The where clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder query builder instance to be further processed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function _intBaseQuery($where = \'\', $orderBy = \'\', $useJoins = true, $slimMode = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// normally we select the whole table");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selection = \'tbl\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($slimMode === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// but for the slim version we select only the basic fields, and no joins");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$titleField = $this->getTitleFieldName();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$selection = \'");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "        ");
        }
        _builder.append("tbl.");
        String _name = pkField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("if ($titleField != \'\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$selection .= \', tbl.\' . $titleField;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (_hasSluggableFields) {
        _builder.append("        ");
        _builder.append("$selection .= \', tbl.slug\';");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$useJoins = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($useJoins === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$selection .= $this->addJoinsToSelection();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->select($selection)");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->from(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "       ");
    _builder.append("\', \'tbl\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($useJoins === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addJoinsToFrom($qb);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->_intBaseQueryAddWhere($qb, $where);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->_intBaseQueryAddOrderBy($qb, $orderBy);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence intBaseQueryWhere(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds WHERE clause to given query builder.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb    Given query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string                    $where The where clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder query builder instance to be further processed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function _intBaseQueryAddWhere(QueryBuilder $qb, $where = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($where)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->where($where);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$onlyOwn = (int) FormUtil::getPassedValue(\'own\', 0, \'GETPOST\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($onlyOwn == 1) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$uid = UserUtil::getVar(\'uid\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$qb->andWhere(\'tbl.createdUserId = :creator\')");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("->setParameter(\'creator\', DataUtil::formatForStore($uid));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence intBaseQueryOrderBy(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds ORDER BY clause to given query builder.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb      Given query builder instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string                    $orderBy The order-by clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\QueryBuilder query builder instance to be further processed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function _intBaseQueryAddOrderBy(QueryBuilder $qb, $orderBy = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($orderBy == \'RAND()\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// random selection");
    _builder.newLine();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        _builder.append("        ");
        _builder.append("// not supported for composite keys yet");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$idValues = $this->getIdentifierListForRandomSorting();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$qb->andWhere(\'tbl.");
        DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
        String _name = _firstPrimaryKey.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append(" IN (:idValues)\')");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("   ");
        _builder.append("->setParameter(\'idValues\', DataUtil::formatForStore($idValues));");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// no specific ordering in the main query for random items");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$orderBy = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// add order by clause");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($orderBy)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (strpos($orderBy, \'.\') === false) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$orderBy = \'tbl.\' . $orderBy;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->add(\'orderBy\', $orderBy);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getIdentifierListForRandomSorting(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieves a random list of identifiers.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Collected identifiers.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getIdentifierListForRandomSorting()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idList = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// query all primary keys in slim mode without any joins");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allEntities = $this->selectWhere(\'\', \'\', false, true);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$allEntities || !is_array($allEntities) || !count($allEntities)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $idList;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($allEntities as $entity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idList[] = $entity[\'");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name = _firstPrimaryKey.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "        ");
    _builder.append("\'];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// shuffle the id array");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("shuffle($idList);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $idList;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence intGetQueryFromBuilder(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieves Doctrine query from query builder, applying FilterUtil and other common actions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb Query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Doctrine\\ORM\\Query query instance to be further processed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getQueryFromBuilder(QueryBuilder $qb)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// TODO - see https://github.com/zikula/core/issues/118");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// use FilterUtil to support generic filtering");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$fu = new FilterUtil(\'");
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    _builder.append(_appName, "    ");
    _builder.append("\', $this);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// you could set explicit filters at this point, something like");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// $fu->setFilter(\'type:eq:\' . $args[\'type\'] . \',id:eq:\' . $args[\'id\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// supported operators: eq, ne, like, lt, le, gt, ge, null, notnull");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// process request input filters and add them to the query.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$fu->enrichQuery($query);");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.append("    ");
        _builder.append("// set the translation query hint");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$query->setHint(");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("Query::HINT_CUSTOM_OUTPUT_WALKER,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'Gedmo\\\\Translatable\\\\Query\\\\TreeWalker\\\\TranslationWalker\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(");");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasPessimisticReadLock = this._modelExtensions.hasPessimisticReadLock(it);
      if (_hasPessimisticReadLock) {
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        EntityLockType _lockType = it.getLockType();
        String _asConstant = this._modelExtensions.asConstant(_lockType);
        _builder.append(_asConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $query;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence singleSortingField(final EntityField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof DerivedField) {
        final DerivedField _derivedField = (DerivedField)it;
        _matched=true;
        CharSequence _xblockexpression = null;
        {
          Entity _entity = _derivedField.getEntity();
          EList<Relationship> _incoming = _entity.getIncoming();
          Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
          final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
              public Boolean apply(final JoinRelationship e) {
                String[] _sourceFields = Repository.this._modelJoinExtensions.getSourceFields(e);
                String _head = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(_sourceFields)));
                String _formatForDB = Repository.this._formattingExtensions.formatForDB(_head);
                String _name = _derivedField.getName();
                String _formatForDB_1 = Repository.this._formattingExtensions.formatForDB(_name);
                boolean _equals = Objects.equal(_formatForDB, _formatForDB_1);
                return Boolean.valueOf(_equals);
              }
            };
          final Iterable<JoinRelationship> joins = IterableExtensions.<JoinRelationship>filter(_filter, _function);
          CharSequence _xifexpression = null;
          boolean _isEmpty = IterableExtensions.isEmpty(joins);
          boolean _not = (!_isEmpty);
          if (_not) {
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("\'");
            JoinRelationship _head = IterableExtensions.<JoinRelationship>head(joins);
            Entity _source = _head.getSource();
            String _name = _source.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "");
            _builder.append("\',");
            _builder.newLineIfNotEmpty();
            _xifexpression = _builder;
          } else {
            StringConcatenation _builder_1 = new StringConcatenation();
            _builder_1.append("\'");
            String _name_1 = _derivedField.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder_1.append(_formatForCode_1, "");
            _builder_1.append("\',");
            _builder_1.newLineIfNotEmpty();
            _xifexpression = _builder_1;
          }
          _xblockexpression = (_xifexpression);
        }
        _switchResult = _xblockexpression;
      }
    }
    if (!_matched) {
      if (it instanceof CalculatedField) {
        final CalculatedField _calculatedField = (CalculatedField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\'");
        String _name = _calculatedField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    return _switchResult;
  }
  
  private boolean isContainedInTextualSearch(final DerivedField it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BooleanField) {
        final BooleanField _booleanField = (BooleanField)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        final AbstractIntegerField _abstractIntegerField = (AbstractIntegerField)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        final FloatField _floatField = (FloatField)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        final ArrayField _arrayField = (ArrayField)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        final ObjectField _objectField = (ObjectField)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      _switchResult = true;
    }
    return _switchResult;
  }
  
  private boolean isContainedInNumericSearch(final DerivedField it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        final AbstractIntegerField _abstractIntegerField = (AbstractIntegerField)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        final FloatField _floatField = (FloatField)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      boolean _isContainedInTextualSearch = this.isContainedInTextualSearch(it);
      _switchResult = _isContainedInTextualSearch;
    }
    return _switchResult;
  }
  
  private boolean isTextSearch(final DerivedField it) {
    boolean _switchResult = false;
    boolean _matched = false;
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
  
  private CharSequence extensionSortingFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        _builder.append("\'latitude\',");
        _builder.newLine();
        _builder.append("\'longitude\',");
        _builder.newLine();
      }
    }
    {
      boolean _and = false;
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      if (!_isSoftDeleteable) {
        _and = false;
      } else {
        Models _container = it.getContainer();
        Application _application = _container.getApplication();
        boolean _targets = this._utils.targets(_application, "1.3.5");
        boolean _not = (!_targets);
        _and = (_isSoftDeleteable && _not);
      }
      if (_and) {
        _builder.append("\'deletedAt\',");
        _builder.newLine();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("\'createdUserId\',");
        _builder.newLine();
        _builder.append("\'updatedUserId\',");
        _builder.newLine();
        _builder.append("\'createdDate\',");
        _builder.newLine();
        _builder.append("\'updatedDate\',");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence archiveObjects(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Update for ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" becoming archived.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool If everything went right or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function archiveObjects()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!SecurityUtil::checkPermission(\'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "    ");
    _builder.append("\', \'.*\', ACCESS_EDIT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// current user has no permission for executing the archive workflow action");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    final AbstractDateField endField = this._modelExtensions.getEndDateField(it);
    _builder.newLineIfNotEmpty();
    {
      if ((endField instanceof DatetimeField)) {
        _builder.append("    ");
        _builder.append("$today = date(\'Y-m-d H:i:s\');");
        _builder.newLine();
      } else {
        if ((endField instanceof DateField)) {
          _builder.append("    ");
          _builder.append("$today = date(\'Y-m-d\') . \' 00:00:00\';");
          _builder.newLine();
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->_intBaseQuery(\'\', \'\', false);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/*$qb->andWhere(\'tbl.workflowState != :archivedState\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'archivedState\', \'archived\');*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->andWhere(\'tbl.workflowState = :approvedState\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'approvedState\', \'approved\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->andWhere(\'tbl.");
    String _name = endField.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append(" < :today\')");
    _builder.newLineIfNotEmpty();
    _builder.append("       ");
    _builder.append("->setParameter(\'today\', $today);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$affectedEntities = $query->getResult();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentType = FormUtil::getPassedValue(\'type\', \'user\', \'GETPOST\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$action = \'archive\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        String _appName_1 = this._utils.appName(this.app);
        _builder.append(_appName_1, "    ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($serviceManager");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule(\'");
        String _appName_2 = this._utils.appName(this.app);
        _builder.append(_appName_2, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($affectedEntities as $entity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->initWorkflow();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hookAreaPrefix = $entity->getHookAreaPrefix();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Let any hooks perform additional validation actions");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hookType = \'validate_edit\';");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      if (_targets_2) {
        _builder.append("        ");
        _builder.append("$hook = new Zikula_ValidationHook($hookAreaPrefix . \'.\' . $hookType, new Zikula_Hook_ValidationProviders());");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$validators = $serviceManager->getService(\'zikula.hookmanager\')->notify($hook)->getValidators();");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$hook = new ValidationHook(new ValidationProviders());");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$validators = $serviceManager->getService(\'hook_dispatcher\')->dispatch($hookAreaPrefix . \'.\' . $hookType, $hook)->getValidators();");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("if ($validators->hasErrors()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$success = false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerError($this->__f(\'Sorry, but an unknown error occured during the %s action. Please apply the changes again!\', array($action)));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$success) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Let any hooks know that we have updated an item");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hookType = \'process_edit\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$urlArgs = $entity->createUrlArgs();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$url = new ");
    {
      boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
      if (_targets_3) {
        _builder.append("Zikula_");
      }
    }
    _builder.append("ModUrl($this->name, $currentType, \'display\', ZLanguage::getLanguageCode(), $urlArgs);");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_4 = this._utils.targets(this.app, "1.3.5");
      if (_targets_4) {
        _builder.append("        ");
        _builder.append("$hook = new Zikula_ProcessHook($hookAreaPrefix . \'.\' . $hookType, $entity->createCompositeIdentifier(), $url);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$serviceManager->getService(\'zikula.hookmanager\')->notify($hook);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$hook = new ProcessHook($entity->createCompositeIdentifier(), $url);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$serviceManager->getService(\'hook_dispatcher\')->dispatch($hookAreaPrefix . \'.\' . $hookType, $hook);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// An item was updated, so we clear all cached pages for this item.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$cacheArgs = array(\'ot\' => $entity[\'_objectType\'], \'item\' => $entity);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("ModUtil::apiFunc(\'");
    String _appName_3 = this._utils.appName(this.app);
    _builder.append(_appName_3, "        ");
    _builder.append("\', \'cache\', \'clearItemCache\', $cacheArgs);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence modelRepositoryImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "");
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
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(this.app);
        _builder.append(_appName_1, "");
        _builder.append("_Entity_Repository_");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
        _builder.append(" extends ");
        {
          boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting) {
            String _appName_2 = this._utils.appName(this.app);
            _builder.append(_appName_2, "");
            _builder.append("_Entity_Repository_");
            Entity _parentType = this._modelInheritanceExtensions.parentType(it);
            String _name_2 = _parentType.getName();
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
            _builder.append(_formatForCodeCapital_1, "");
          } else {
            String _appName_3 = this._utils.appName(this.app);
            _builder.append(_appName_3, "");
            _builder.append("_Entity_Repository_Base_");
            String _name_3 = it.getName();
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_3);
            _builder.append(_formatForCodeCapital_2, "");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_4 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append(" extends ");
        {
          boolean _isInheriting_1 = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting_1) {
            Entity _parentType_1 = this._modelInheritanceExtensions.parentType(it);
            String _name_5 = _parentType_1.getName();
            String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_5);
            _builder.append(_formatForCodeCapital_4, "");
          } else {
            _builder.append("Base\\");
            String _name_6 = it.getName();
            String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(_name_6);
            _builder.append(_formatForCodeCapital_5, "");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own methods here, like for example reusable DQL queries");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence defaultValueForNow(final EntityField it) {
    if (it instanceof DateField) {
      return _defaultValueForNow((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _defaultValueForNow((DatetimeField)it);
    } else if (it != null) {
      return _defaultValueForNow(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
