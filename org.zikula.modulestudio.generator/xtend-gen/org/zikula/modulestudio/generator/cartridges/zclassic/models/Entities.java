package org.zikula.modulestudio.generator.cartridges.zclassic.models;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityChangeTrackingPolicy;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndex;
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexItem;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.InheritanceRelationship;
import de.guite.modulestudio.metamodel.modulestudio.InheritanceStrategyType;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import de.guite.modulestudio.metamodel.modulestudio.TimeField;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.EventListener;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.Validator;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Association;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Extensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Entities {
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
  private UrlExtensions _urlExtensions = new Function0<UrlExtensions>() {
    public UrlExtensions apply() {
      UrlExtensions _urlExtensions = new UrlExtensions();
      return _urlExtensions;
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
  
  private Association thAssoc = new Function0<Association>() {
    public Association apply() {
      Association _association = new Association();
      return _association;
    }
  }.apply();
  
  private Extensions thExt = new Function0<Extensions>() {
    public Extensions apply() {
      Extensions _extensions = new Extensions();
      return _extensions;
    }
  }.apply();
  
  private EventListener thEvLi = new Function0<EventListener>() {
    public EventListener apply() {
      EventListener _eventListener = new EventListener();
      return _eventListener;
    }
  }.apply();
  
  private Property thProp = new Function0<Property>() {
    public Property apply() {
      Property _property = new Property();
      return _property;
    }
  }.apply();
  
  /**
   * Entry point for Doctrine entity classes.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    final Procedure1<Entity> _function = new Procedure1<Entity>() {
        public void apply(final Entity e) {
          Entities.this.generate(e, it, fsa);
        }
      };
    IterableExtensions.<Entity>forEach(_allEntities, _function);
    Validator _validator = new Validator();
    final Validator validator = _validator;
    validator.generateCommon(it, fsa);
    EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities_1) {
      validator.generateWrapper(entity, it, fsa);
    }
    this.thExt.extensionClasses(it, fsa);
  }
  
  /**
   * Creates an entity class file for every Entity instance.
   */
  private void generate(final Entity it, final Application app, final IFileSystemAccess fsa) {
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus = ("Generating entity classes for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(app);
    final String entityPath = (_appSourceLibPath + "Entity/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(app, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Entity";
    } else {
      _xifexpression = "";
    }
    final String entityClassSuffix = _xifexpression;
    String _name_1 = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
    String _plus_2 = (_formatForCodeCapital + entityClassSuffix);
    final String entityFileName = (_plus_2 + ".php");
    boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
    boolean _not_1 = (!_isInheriting);
    if (_not_1) {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        String _plus_3 = (entityPath + "Base/");
        String _plus_4 = (_plus_3 + entityFileName);
        CharSequence _modelEntityBaseFile = this.modelEntityBaseFile(it, app);
        fsa.generateFile(_plus_4, _modelEntityBaseFile);
      } else {
        String _plus_5 = (entityPath + "Base/Abstract");
        String _plus_6 = (_plus_5 + entityFileName);
        CharSequence _modelEntityBaseFile_1 = this.modelEntityBaseFile(it, app);
        fsa.generateFile(_plus_6, _modelEntityBaseFile_1);
      }
    }
    String _plus_7 = (entityPath + entityFileName);
    CharSequence _modelEntityFile = this.modelEntityFile(it, app);
    fsa.generateFile(_plus_7, _modelEntityFile);
  }
  
  private CharSequence modelEntityBaseFile(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _modelEntityBaseImpl = this.modelEntityBaseImpl(it, app);
    _builder.append(_modelEntityBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelEntityFile(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _modelEntityImpl = this.modelEntityImpl(it, app);
    _builder.append(_modelEntityImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelEntityBaseImpl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("\\Entity\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _imports = this.imports(it);
    _builder.append(_imports, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.newLine();
        _builder.append("use ");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("\\UploadHandler;");
        _builder.newLineIfNotEmpty();
        _builder.append("use ");
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.append("use ");
        String _appName_3 = this._utils.appName(app);
        _builder.append(_appName_3, "");
        _builder.append("\\Util\\WorkflowUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use DataUtil;");
        _builder.newLine();
        _builder.append("use FormUtil;");
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use System;");
        _builder.newLine();
        _builder.append("use UserUtil;");
        _builder.newLine();
        _builder.append("use Zikula_EntityAccess;");
        _builder.newLine();
        _builder.append("use Zikula_Exception;");
        _builder.newLine();
        _builder.append("use Zikula_Workflow_Util;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Entity class that defines the entity structure and behaviours.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the base entity class for ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @abstract");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("abstract class ");
        String _appName_4 = this._utils.appName(app);
        _builder.append(_appName_4, "");
        _builder.append("_Entity_Base_");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
        _builder.append(" extends Zikula_EntityAccess");
        {
          boolean _hasNotifyPolicy = this._modelExtensions.hasNotifyPolicy(it);
          if (_hasNotifyPolicy) {
            _builder.append(" implements NotifyPropertyChanged");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("abstract class Abstract");
        String _name_2 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Entity extends Zikula_EntityAccess");
        {
          boolean _hasNotifyPolicy_1 = this._modelExtensions.hasNotifyPolicy(it);
          if (_hasNotifyPolicy_1) {
            _builder.append(" implements");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("NotifyPropertyChanged");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _entityInfo = this.entityInfo(it, app);
    _builder.append(_entityInfo, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generateBase = this.thEvLi.generateBase(it);
    _builder.append(_generateBase, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _stringImpl = this.toStringImpl(it, app);
    _builder.append(_stringImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _cloneImpl = this.cloneImpl(it, app);
    _builder.append(_cloneImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence imports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use Doctrine\\ORM\\Mapping as ORM;");
    _builder.newLine();
    {
      boolean _or = false;
      boolean _or_1 = false;
      boolean _hasCollections = this._modelJoinExtensions.hasCollections(it);
      if (_hasCollections) {
        _or_1 = true;
      } else {
        boolean _isAttributable = it.isAttributable();
        _or_1 = (_hasCollections || _isAttributable);
      }
      if (_or_1) {
        _or = true;
      } else {
        boolean _isCategorisable = it.isCategorisable();
        _or = (_or_1 || _isCategorisable);
      }
      if (_or) {
        _builder.append("use Doctrine\\Common\\Collections\\ArrayCollection;");
        _builder.newLine();
      }
    }
    CharSequence _imports = this.thExt.imports(it);
    _builder.append(_imports, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasNotifyPolicy = this._modelExtensions.hasNotifyPolicy(it);
      if (_hasNotifyPolicy) {
        _builder.append("use Doctrine\\Common\\NotifyPropertyChanged;");
        _builder.newLine();
        _builder.append("use Doctrine\\Common\\PropertyChangedListener;");
        _builder.newLine();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("use DoctrineExtensions\\StandardFields\\Mapping\\Annotation as ZK;");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence index(final EntityIndex it, final String indexType) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("*         @ORM\\");
    String _firstUpper = StringExtensions.toFirstUpper(indexType);
    _builder.append(_firstUpper, "");
    _builder.append("(name=\"");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append("\", columns={");
    {
      EList<EntityIndexItem> _items = it.getItems();
      boolean _hasElements = false;
      for(final EntityIndexItem item : _items) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(",", "");
        }
        CharSequence _indexField = this.indexField(item);
        _builder.append(_indexField, "");
      }
    }
    _builder.append("})");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence indexField(final EntityIndexItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\"");
    return _builder;
  }
  
  private CharSequence discriminatorInfo(final InheritanceRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(", \"");
    Entity _source = it.getSource();
    String _name = _source.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\" = \"");
    Entity _source_1 = it.getSource();
    String _entityClassName = this._namingExtensions.entityClassName(_source_1, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "");
    _builder.append("\"");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelEntityImpl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("\\Entity;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _imports = this.imports(it);
    _builder.append(_imports, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Entity class that defines the entity structure and behaviours.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the concrete entity class for ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    CharSequence _classExtensions = this.thExt.classExtensions(it);
    _builder.append(_classExtensions, " ");
    _builder.newLineIfNotEmpty();
    {
      boolean _isMappedSuperClass = it.isMappedSuperClass();
      if (_isMappedSuperClass) {
        _builder.append(" ");
        _builder.append("* @ORM\\MappedSuperclass");
        _builder.newLine();
      } else {
        _builder.append(" ");
        _builder.append("* @ORM\\Entity(repositoryClass=\"");
        {
          boolean _targets_1 = this._utils.targets(app, "1.3.5");
          if (_targets_1) {
            String _appName_1 = this._utils.appName(app);
            _builder.append(_appName_1, " ");
            _builder.append("_Entity_Repository_");
            String _name_1 = it.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
            _builder.append(_formatForCodeCapital, " ");
          } else {
            _builder.append("\\");
            String _appName_2 = this._utils.appName(app);
            _builder.append(_appName_2, " ");
            _builder.append("\\Entity\\Repository\\");
            String _name_2 = it.getName();
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
            _builder.append(_formatForCodeCapital_1, " ");
          }
        }
        _builder.append("\"");
        {
          boolean _isReadOnly = it.isReadOnly();
          if (_isReadOnly) {
            _builder.append(", readOnly=true");
          }
        }
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      EList<EntityIndex> _indexes = it.getIndexes();
      boolean _isEmpty = _indexes.isEmpty();
      if (_isEmpty) {
        _builder.append(" ");
        _builder.append("* @ORM\\Table(name=\"");
        String _fullEntityTableName = this._modelExtensions.fullEntityTableName(it);
        _builder.append(_fullEntityTableName, " ");
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" ");
        _builder.append(" ");
        _builder.append("* @ORM\\Table(name=\"");
        String _fullEntityTableName_1 = this._modelExtensions.fullEntityTableName(it);
        _builder.append(_fullEntityTableName_1, "  ");
        _builder.append("\",");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasNormalIndexes = this._modelExtensions.hasNormalIndexes(it);
          if (_hasNormalIndexes) {
            _builder.append(" ");
            _builder.append(" ");
            _builder.append("*     indexes={");
            _builder.newLine();
            _builder.append(" ");
            {
              Iterable<EntityIndex> _normalIndexes = this._modelExtensions.getNormalIndexes(it);
              boolean _hasElements = false;
              for(final EntityIndex index : _normalIndexes) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate(",", " ");
                }
                CharSequence _index = this.index(index, "Index");
                _builder.append(_index, " ");
              }
            }
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append(" ");
            _builder.append("*     }");
            {
              boolean _hasUniqueIndexes = this._modelExtensions.hasUniqueIndexes(it);
              if (_hasUniqueIndexes) {
                _builder.append(",");
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasUniqueIndexes_1 = this._modelExtensions.hasUniqueIndexes(it);
          if (_hasUniqueIndexes_1) {
            _builder.append(" ");
            _builder.append(" ");
            _builder.append("*     uniqueConstraints={");
            _builder.newLine();
            _builder.append(" ");
            {
              Iterable<EntityIndex> _uniqueIndexes = this._modelExtensions.getUniqueIndexes(it);
              boolean _hasElements_1 = false;
              for(final EntityIndex index_1 : _uniqueIndexes) {
                if (!_hasElements_1) {
                  _hasElements_1 = true;
                } else {
                  _builder.appendImmediate(",", " ");
                }
                CharSequence _index_1 = this.index(index_1, "UniqueConstraint");
                _builder.append(_index_1, " ");
              }
            }
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append(" ");
            _builder.append("*     }");
            _builder.newLine();
          }
        }
        _builder.append(" ");
        _builder.append(" ");
        _builder.append("* )");
        _builder.newLine();
      }
    }
    {
      boolean _isTopSuperClass = this._modelInheritanceExtensions.isTopSuperClass(it);
      if (_isTopSuperClass) {
        _builder.append(" ");
        _builder.append("* @ORM\\InheritanceType(\"");
        Iterable<InheritanceRelationship> _childRelations = this._modelInheritanceExtensions.getChildRelations(it);
        InheritanceRelationship _head = IterableExtensions.<InheritanceRelationship>head(_childRelations);
        InheritanceStrategyType _strategy = _head.getStrategy();
        String _asConstant = this._modelInheritanceExtensions.asConstant(_strategy);
        _builder.append(_asConstant, " ");
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @ORM\\DiscriminatorColumn(name=\"");
        Iterable<InheritanceRelationship> _childRelations_1 = this._modelInheritanceExtensions.getChildRelations(it);
        InheritanceRelationship _head_1 = IterableExtensions.<InheritanceRelationship>head(_childRelations_1);
        String _discriminatorColumn = _head_1.getDiscriminatorColumn();
        String _formatForCode = this._formattingExtensions.formatForCode(_discriminatorColumn);
        _builder.append(_formatForCode, " ");
        _builder.append("\"");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @ORM\\DiscriminatorMap({\"");
        String _name_3 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_1, " ");
        _builder.append("\" = \"");
        String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName, " ");
        _builder.append("\"");
        {
          Iterable<InheritanceRelationship> _childRelations_2 = this._modelInheritanceExtensions.getChildRelations(it);
          for(final InheritanceRelationship relation : _childRelations_2) {
            CharSequence _discriminatorInfo = this.discriminatorInfo(relation);
            _builder.append(_discriminatorInfo, " ");
          }
        }
        _builder.append("})");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      EntityChangeTrackingPolicy _changeTrackingPolicy = it.getChangeTrackingPolicy();
      boolean _notEquals = (!Objects.equal(_changeTrackingPolicy, EntityChangeTrackingPolicy.DEFERRED_IMPLICIT));
      if (_notEquals) {
        _builder.append(" ");
        _builder.append("* @ORM\\ChangeTrackingPolicy(\"");
        EntityChangeTrackingPolicy _changeTrackingPolicy_1 = it.getChangeTrackingPolicy();
        String _asConstant_1 = this._modelExtensions.asConstant(_changeTrackingPolicy_1);
        _builder.append(_asConstant_1, " ");
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @ORM\\HasLifecycleCallbacks");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("class ");
        String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName_1, "");
        _builder.append(" extends ");
        {
          boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting) {
            Entity _parentType = this._modelInheritanceExtensions.parentType(it);
            String _entityClassName_2 = this._namingExtensions.entityClassName(_parentType, "", Boolean.valueOf(false));
            _builder.append(_entityClassName_2, "");
          } else {
            String _entityClassName_3 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(true));
            _builder.append(_entityClassName_3, "");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_4 = it.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append("Entity extends ");
        {
          boolean _isInheriting_1 = this._modelInheritanceExtensions.isInheriting(it);
          if (_isInheriting_1) {
            Entity _parentType_1 = this._modelInheritanceExtensions.parentType(it);
            String _name_5 = _parentType_1.getName();
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_5);
            _builder.append(_formatForCodeCapital_3, "");
          } else {
            _builder.append("Base\\Abstract");
            String _name_6 = it.getName();
            String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_6);
            _builder.append(_formatForCodeCapital_4, "");
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
    {
      boolean _isInheriting_2 = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting_2) {
        _builder.append("    ");
        {
          Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
          for(final DerivedField field : _derivedFields) {
            CharSequence _persistentProperty = this.thProp.persistentProperty(field);
            _builder.append(_persistentProperty, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _additionalProperties = this.thExt.additionalProperties(it);
        _builder.append(_additionalProperties, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        {
          Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
          for(final JoinRelationship relation_1 : _bidirectionalIncomingJoinRelations) {
            CharSequence _generate = this.thAssoc.generate(relation_1, Boolean.valueOf(false));
            _builder.append(_generate, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        {
          Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
          for(final JoinRelationship relation_2 : _outgoingJoinRelations) {
            CharSequence _generate_1 = this.thAssoc.generate(relation_2, Boolean.valueOf(true));
            _builder.append(_generate_1, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _constructor = this.constructor(it, Boolean.valueOf(true));
        _builder.append(_constructor, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        {
          Iterable<DerivedField> _derivedFields_1 = this._modelExtensions.getDerivedFields(it);
          for(final DerivedField field_1 : _derivedFields_1) {
            CharSequence _fieldAccessor = this.thProp.fieldAccessor(field_1);
            _builder.append(_fieldAccessor, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _additionalAccessors = this.thExt.additionalAccessors(it);
        _builder.append(_additionalAccessors, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        {
          Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations_1 = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
          for(final JoinRelationship relation_3 : _bidirectionalIncomingJoinRelations_1) {
            CharSequence _relationAccessor = this.thAssoc.relationAccessor(relation_3, Boolean.valueOf(false));
            _builder.append(_relationAccessor, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        {
          Iterable<JoinRelationship> _outgoingJoinRelations_1 = this._modelJoinExtensions.getOutgoingJoinRelations(it);
          for(final JoinRelationship relation_4 : _outgoingJoinRelations_1) {
            CharSequence _relationAccessor_1 = this.thAssoc.relationAccessor(relation_4, Boolean.valueOf(true));
            _builder.append(_relationAccessor_1, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generateImpl = this.thEvLi.generateImpl(it);
    _builder.append(_generateImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence entityInfo(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var string The tablename this object maps to.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $_objectType = \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var array List of primary key field names.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $_idFields = array();");
    _builder.newLine();
    _builder.newLine();
    String _xifexpression = null;
    boolean _targets = this._utils.targets(app, "1.3.5");
    if (_targets) {
      String _appName = this._utils.appName(app);
      String _plus = (_appName + "_Entity_Validator_");
      String _name_1 = it.getName();
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
      String _plus_1 = (_plus + _formatForCodeCapital);
      _xifexpression = _plus_1;
    } else {
      String _appName_1 = this._utils.appName(app);
      String _plus_2 = ("\\" + _appName_1);
      String _plus_3 = (_plus_2 + "\\Entity\\Validator\\");
      String _name_2 = it.getName();
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
      String _plus_4 = (_plus_3 + _formatForCodeCapital_1);
      String _plus_5 = (_plus_4 + "Validator");
      _xifexpression = _plus_5;
    }
    final String validatorClass = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var ");
    _builder.append(validatorClass, " ");
    _builder.append(" The validator for this entity.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $_validator = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var boolean Option to bypass validation if needed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $_bypassValidation = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var boolean Whether this entity supports unique slugs.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $_hasUniqueSlug = ");
    {
      boolean _and = false;
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (!_hasSluggableFields) {
        _and = false;
      } else {
        boolean _isSlugUnique = it.isSlugUnique();
        _and = (_hasSluggableFields && _isSlugUnique);
      }
      if (_and) {
        _builder.append("true");
      } else {
        _builder.append("false");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasNotifyPolicy = this._modelExtensions.hasNotifyPolicy(it);
      if (_hasNotifyPolicy) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var array List of change notification listeners.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $_propertyChangedListeners = array();");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var array List of available item actions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $_actions = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var array The current workflow data of this object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $__WORKFLOW__ = array();");
    _builder.newLine();
    _builder.newLine();
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField field : _derivedFields) {
        CharSequence _persistentProperty = this.thProp.persistentProperty(field);
        _builder.append(_persistentProperty, "");
      }
    }
    _builder.newLineIfNotEmpty();
    CharSequence _additionalProperties = this.thExt.additionalProperties(it);
    _builder.append(_additionalProperties, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      for(final JoinRelationship relation : _bidirectionalIncomingJoinRelations) {
        CharSequence _generate = this.thAssoc.generate(relation, Boolean.valueOf(false));
        _builder.append(_generate, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      for(final JoinRelationship relation_1 : _outgoingJoinRelations) {
        CharSequence _generate_1 = this.thAssoc.generate(relation_1, Boolean.valueOf(true));
        _builder.append(_generate_1, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _constructor = this.constructor(it, Boolean.valueOf(false));
    _builder.append(_constructor, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "_objectType", "string", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods, "");
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, "_idFields", "array", Boolean.valueOf(false), Boolean.valueOf(true), "Array()", "");
    _builder.append(_terAndSetterMethods_1, "");
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_2 = this.fh.getterAndSetterMethods(it, "_validator", validatorClass, Boolean.valueOf(false), Boolean.valueOf(true), "null", "");
    _builder.append(_terAndSetterMethods_2, "");
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_3 = this.fh.getterAndSetterMethods(it, "_bypassValidation", "boolean", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_3, "");
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_4 = this.fh.getterAndSetterMethods(it, "_hasUniqueSlug", "boolean", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_4, "");
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_5 = this.fh.getterAndSetterMethods(it, "_actions", "array", Boolean.valueOf(false), Boolean.valueOf(true), "Array()", "");
    _builder.append(_terAndSetterMethods_5, "");
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_6 = this.fh.getterAndSetterMethods(it, "__WORKFLOW__", "array", Boolean.valueOf(false), Boolean.valueOf(true), "Array()", "");
    _builder.append(_terAndSetterMethods_6, "");
    _builder.newLineIfNotEmpty();
    CharSequence _propertyChangedListener = this.propertyChangedListener(it);
    _builder.append(_propertyChangedListener, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Iterable<DerivedField> _derivedFields_1 = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField field_1 : _derivedFields_1) {
        CharSequence _fieldAccessor = this.thProp.fieldAccessor(field_1);
        _builder.append(_fieldAccessor, "");
      }
    }
    _builder.newLineIfNotEmpty();
    CharSequence _additionalAccessors = this.thExt.additionalAccessors(it);
    _builder.append(_additionalAccessors, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations_1 = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      for(final JoinRelationship relation_2 : _bidirectionalIncomingJoinRelations_1) {
        CharSequence _relationAccessor = this.thAssoc.relationAccessor(relation_2, Boolean.valueOf(false));
        _builder.append(_relationAccessor, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _outgoingJoinRelations_1 = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      for(final JoinRelationship relation_3 : _outgoingJoinRelations_1) {
        CharSequence _relationAccessor_1 = this.thAssoc.relationAccessor(relation_3, Boolean.valueOf(true));
        _builder.append(_relationAccessor_1, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise validator and return it\'s instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    _builder.append(validatorClass, " ");
    _builder.append(" The validator for this entity.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function initValidator()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_null($this->_validator)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->_validator;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->_validator = new ");
    _builder.append(validatorClass, "    ");
    _builder.append("($this);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->_validator;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sets/retrieves the workflow details.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function initWorkflow()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentFunc = FormUtil::getPassedValue(\'func\', \'");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\', \'GETPOST\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _loadWorkflow = this.loadWorkflow(it);
    _builder.append(_loadWorkflow, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Resets workflow data back to initial state.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* To be used after cloning an entity object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function resetWorkflow()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->setWorkflowState(\'initial\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "    ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("(ServiceUtil::getManager()");
    {
      boolean _targets_3 = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets_3);
      if (_not) {
        _builder.append(", ModUtil::getModule(\'");
        String _appName_3 = this._utils.appName(app);
        _builder.append(_appName_3, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$schemaName = $workflowHelper->getWorkflowName($this[\'_objectType\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this[\'__WORKFLOW__\'] = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'state\' => $this[\'workflowState\'],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'obj_table\' => $this[\'_objectType\'],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'obj_idcolumn\' => \'");
    Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
    DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields);
    String _name_3 = _head.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'obj_id\' => 0,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'schemaname\' => $schemaName);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Start validation and raise exception if invalid data is found.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws Zikula_Exception");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function validate()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->_bypassValidation === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    Iterable<DerivedField> _derivedFields_2 = this._modelExtensions.getDerivedFields(it);
    final Iterable<EmailField> emailFields = Iterables.<EmailField>filter(_derivedFields_2, EmailField.class);
    _builder.newLineIfNotEmpty();
    {
      int _size = IterableExtensions.size(emailFields);
      boolean _greaterThan = (_size > 0);
      if (_greaterThan) {
        _builder.append("    ");
        _builder.append("// decode possibly encoded mail addresses (#201)");
        _builder.newLine();
        {
          for(final EmailField emailField : emailFields) {
            _builder.append("if (strpos($this[\'");
            String _name_4 = emailField.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_4);
            _builder.append(_formatForCode_2, "");
            _builder.append("\'], \'&#\') !== false) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$this[\'");
            String _name_5 = emailField.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
            _builder.append(_formatForCode_3, "    ");
            _builder.append("\'] = html_entity_decode($this[\'");
            String _name_6 = emailField.getName();
            String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_6);
            _builder.append(_formatForCode_4, "    ");
            _builder.append("\']);");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("$result = $this->initValidator()->validateAll();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (is_array($result)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new Zikula_Exception($result[\'message\'], $result[\'code\'], $result[\'debugArray\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return entity data in JSON format.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string JSON-encoded data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function toJson()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return json_encode($this->toArray());");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Collect available actions for this entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function prepareItemActions()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($this->_actions)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentType = FormUtil::getPassedValue(\'type\', \'user\', \'GETPOST\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentFunc = FormUtil::getPassedValue(\'func\', \'");
    {
      boolean _targets_4 = this._utils.targets(app, "1.3.5");
      if (_targets_4) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\', \'GETPOST\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    final String appName = this._utils.appName(app);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    _builder.append(appName, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    {
      Iterable<Controller> _adminAndUserControllers = this._controllerExtensions.getAdminAndUserControllers(app);
      for(final Controller controller : _adminAndUserControllers) {
        _builder.append("    ");
        _builder.append("if ($currentType == \'");
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "    ");
        _builder.append("\') {");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasActions = this._controllerExtensions.hasActions(controller, "view");
          if (_hasActions) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (in_array($currentFunc, array(\'");
            {
              boolean _targets_5 = this._utils.targets(app, "1.3.5");
              if (_targets_5) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
            _builder.append("\', \'view\'))) {");
            _builder.newLineIfNotEmpty();
            {
              boolean _and_1 = false;
              boolean _and_2 = false;
              boolean _tempIsAdminController = this.tempIsAdminController(controller);
              if (!_tempIsAdminController) {
                _and_2 = false;
              } else {
                Models _container = it.getContainer();
                Application _application = _container.getApplication();
                boolean _hasUserController = this._controllerExtensions.hasUserController(_application);
                _and_2 = (_tempIsAdminController && _hasUserController);
              }
              if (!_and_2) {
                _and_1 = false;
              } else {
                Models _container_1 = it.getContainer();
                Application _application_1 = _container_1.getApplication();
                UserController _mainUserController = this._controllerExtensions.getMainUserController(_application_1);
                boolean _hasActions_1 = this._controllerExtensions.hasActions(_mainUserController, "display");
                _and_1 = (_and_2 && _hasActions_1);
              }
              if (_and_1) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$this->_actions[] = array(");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'url\' => array(\'type\' => \'user\', \'func\' => \'display\', \'arguments\' => array(\'ot\' => \'");
                String _name_7 = it.getName();
                String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_7);
                _builder.append(_formatForCode_5, "                ");
                _builder.append("\'");
                CharSequence _modUrlPrimaryKeyParams = this._urlExtensions.modUrlPrimaryKeyParams(it, "this", Boolean.valueOf(false));
                _builder.append(_modUrlPrimaryKeyParams, "                ");
                {
                  boolean _hasSluggableFields_1 = this._modelBehaviourExtensions.hasSluggableFields(it);
                  if (_hasSluggableFields_1) {
                    _builder.append(", \'slug\' => $this->slug");
                  }
                }
                _builder.append(")),");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'icon\' => \'preview\',");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'linkTitle\' => __(\'Open preview page\', $dom),");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'linkText\' => __(\'Preview\', $dom)");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append(");");
                _builder.newLine();
              }
            }
            {
              boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "display");
              if (_hasActions_2) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$this->_actions[] = array(");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'url\' => array(\'type\' => \'");
                String _formattedName_1 = this._controllerExtensions.formattedName(controller);
                _builder.append(_formattedName_1, "                ");
                _builder.append("\', \'func\' => \'display\', \'arguments\' => array(\'ot\' => \'");
                String _name_8 = it.getName();
                String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_8);
                _builder.append(_formatForCode_6, "                ");
                _builder.append("\'");
                CharSequence _modUrlPrimaryKeyParams_1 = this._urlExtensions.modUrlPrimaryKeyParams(it, "this", Boolean.valueOf(false));
                _builder.append(_modUrlPrimaryKeyParams_1, "                ");
                {
                  boolean _hasSluggableFields_2 = this._modelBehaviourExtensions.hasSluggableFields(it);
                  if (_hasSluggableFields_2) {
                    _builder.append(", \'slug\' => $this->slug");
                  }
                }
                _builder.append(")),");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'icon\' => \'display\',");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'linkTitle\' => ");
                {
                  boolean _tripleNotEquals = (leadingField != null);
                  if (_tripleNotEquals) {
                    _builder.append("str_replace(\'\"\', \'\', $this[\'");
                    String _name_9 = leadingField.getName();
                    String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_9);
                    _builder.append(_formatForCode_7, "                ");
                    _builder.append("\'])");
                  } else {
                    _builder.append("__(\'Open detail page\', $dom)");
                  }
                }
                _builder.append(",");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'linkText\' => __(\'Details\', $dom)");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append(");");
                _builder.newLine();
              }
            }
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          boolean _or = false;
          boolean _hasActions_3 = this._controllerExtensions.hasActions(controller, "view");
          if (_hasActions_3) {
            _or = true;
          } else {
            boolean _hasActions_4 = this._controllerExtensions.hasActions(controller, "display");
            _or = (_hasActions_3 || _hasActions_4);
          }
          if (_or) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (in_array($currentFunc, array(\'");
            {
              boolean _targets_6 = this._utils.targets(app, "1.3.5");
              if (_targets_6) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
            _builder.append("\', \'view\', \'display\'))) {");
            _builder.newLineIfNotEmpty();
            {
              boolean _or_1 = false;
              boolean _hasActions_5 = this._controllerExtensions.hasActions(controller, "edit");
              if (_hasActions_5) {
                _or_1 = true;
              } else {
                boolean _hasActions_6 = this._controllerExtensions.hasActions(controller, "delete");
                _or_1 = (_hasActions_5 || _hasActions_6);
              }
              if (_or_1) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$component = \'");
                _builder.append(appName, "            ");
                _builder.append(":");
                String _name_10 = it.getName();
                String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_10);
                _builder.append(_formatForCodeCapital_2, "            ");
                _builder.append(":\';");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$instance = ");
                CharSequence _idFieldsAsParameterCode = this._modelExtensions.idFieldsAsParameterCode(it, "this");
                _builder.append(_idFieldsAsParameterCode, "            ");
                _builder.append(" . \'::\';");
                _builder.newLineIfNotEmpty();
              }
            }
            {
              boolean _hasActions_7 = this._controllerExtensions.hasActions(controller, "edit");
              if (_hasActions_7) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {");
                _builder.newLine();
                {
                  boolean _and_3 = false;
                  boolean _isOwnerPermission = it.isOwnerPermission();
                  if (!_isOwnerPermission) {
                    _and_3 = false;
                  } else {
                    boolean _isStandardFields = it.isStandardFields();
                    _and_3 = (_isOwnerPermission && _isStandardFields);
                  }
                  if (_and_3) {
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("// only allow editing for the owner or people with higher permissions");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("if ($this[\'createdUserId\'] == UserUtil::getVar(\'uid\') || SecurityUtil::checkPermission($component, $instance, ACCESS_ADD)) {");
                    _builder.newLine();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    CharSequence _itemActionsForEditAction = this.itemActionsForEditAction(it, controller);
                    _builder.append(_itemActionsForEditAction, "                    ");
                    _builder.newLineIfNotEmpty();
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("}");
                    _builder.newLine();
                  } else {
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    _builder.append("    ");
                    CharSequence _itemActionsForEditAction_1 = this.itemActionsForEditAction(it, controller);
                    _builder.append(_itemActionsForEditAction_1, "                ");
                    _builder.newLineIfNotEmpty();
                  }
                }
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("}");
                _builder.newLine();
              }
            }
            {
              boolean _hasActions_8 = this._controllerExtensions.hasActions(controller, "delete");
              if (_hasActions_8) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_DELETE)) {");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$this->_actions[] = array(");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("\'url\' => array(\'type\' => \'");
                String _formattedName_2 = this._controllerExtensions.formattedName(controller);
                _builder.append(_formattedName_2, "                    ");
                _builder.append("\', \'func\' => \'delete\', \'arguments\' => array(\'ot\' => \'");
                String _name_11 = it.getName();
                String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_11);
                _builder.append(_formatForCode_8, "                    ");
                _builder.append("\'");
                CharSequence _modUrlPrimaryKeyParams_2 = this._urlExtensions.modUrlPrimaryKeyParams(it, "this", Boolean.valueOf(false));
                _builder.append(_modUrlPrimaryKeyParams_2, "                    ");
                _builder.append(")),");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("\'icon\' => \'delete\',");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("\'linkTitle\' => __(\'Delete\', $dom),");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("\'linkText\' => __(\'Delete\', $dom)");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append(");");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("}");
                _builder.newLine();
              }
            }
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          boolean _hasActions_9 = this._controllerExtensions.hasActions(controller, "display");
          if (_hasActions_9) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if ($currentFunc == \'display\') {");
            _builder.newLine();
            {
              boolean _hasActions_10 = this._controllerExtensions.hasActions(controller, "view");
              if (_hasActions_10) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$this->_actions[] = array(");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'url\' => array(\'type\' => \'");
                String _formattedName_3 = this._controllerExtensions.formattedName(controller);
                _builder.append(_formattedName_3, "                ");
                _builder.append("\', \'func\' => \'view\', \'arguments\' => array(\'ot\' => \'");
                String _name_12 = it.getName();
                String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_12);
                _builder.append(_formatForCode_9, "                ");
                _builder.append("\')),");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'icon\' => \'back\',");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'linkTitle\' => __(\'Back to overview\', $dom),");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'linkText\' => __(\'Back to overview\', $dom)");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append(");");
                _builder.newLine();
              }
            }
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Creates url arguments array for easy creation of display urls.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Array The resulting arguments list. ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function createUrlArgs()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$args = array(\'ot\' => $this[\'_objectType\']);");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        {
          Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
          for(final DerivedField pkField : _primaryKeyFields_1) {
            _builder.append("    ");
            _builder.append("$args[\'");
            String _name_13 = pkField.getName();
            String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_13);
            _builder.append(_formatForCode_10, "    ");
            _builder.append("\'] = $this[\'");
            String _name_14 = pkField.getName();
            String _formatForCode_11 = this._formattingExtensions.formatForCode(_name_14);
            _builder.append(_formatForCode_11, "    ");
            _builder.append("\'];");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("$args[\'");
        DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
        String _name_15 = _firstPrimaryKey.getName();
        String _formatForCode_12 = this._formattingExtensions.formatForCode(_name_15);
        _builder.append(_formatForCode_12, "    ");
        _builder.append("\'] = $this[\'");
        DerivedField _firstPrimaryKey_1 = this._modelExtensions.getFirstPrimaryKey(it);
        String _name_16 = _firstPrimaryKey_1.getName();
        String _formatForCode_13 = this._formattingExtensions.formatForCode(_name_16);
        _builder.append(_formatForCode_13, "    ");
        _builder.append("\'];");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($this[\'slug\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'slug\'] = $this[\'slug\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $args;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Create concatenated identifier string (for composite keys).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String concatenated identifiers.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function createCompositeIdentifier()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasCompositeKeys_1 = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys_1) {
        _builder.append("    ");
        _builder.append("$itemId = \'\';");
        _builder.newLine();
        {
          Iterable<DerivedField> _primaryKeyFields_2 = this._modelExtensions.getPrimaryKeyFields(it);
          for(final DerivedField pkField_1 : _primaryKeyFields_2) {
            _builder.append("    ");
            _builder.append("$itemId .= ((!empty($itemId)) ? \'_\' : \'\') . $this[\'");
            String _name_17 = pkField_1.getName();
            String _formatForCode_14 = this._formattingExtensions.formatForCode(_name_17);
            _builder.append(_formatForCode_14, "    ");
            _builder.append("\'];");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("$itemId = $this[\'");
        DerivedField _firstPrimaryKey_2 = this._modelExtensions.getFirstPrimaryKey(it);
        String _name_18 = _firstPrimaryKey_2.getName();
        String _formatForCode_15 = this._formattingExtensions.formatForCode(_name_18);
        _builder.append(_formatForCode_15, "    ");
        _builder.append("\'];");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $itemId;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return lower case name of multiple items needed for hook areas.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getHookAreaPrefix()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'");
    String _name_19 = app.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_19);
    _builder.append(_formatForDB, "    ");
    _builder.append(".ui_hooks.");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_nameMultiple);
    _builder.append(_formatForDB_1, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private boolean tempIsAdminController(final Controller it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  private CharSequence itemActionsForEditAction(final Entity it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isReadOnly = it.isReadOnly();
      boolean _not = (!_isReadOnly);
      if (_not) {
        _builder.append("$this->_actions[] = array(");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'url\' => array(\'type\' => \'");
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "    ");
        _builder.append("\', \'func\' => \'edit\', \'arguments\' => array(\'ot\' => \'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append("\'");
        CharSequence _modUrlPrimaryKeyParams = this._urlExtensions.modUrlPrimaryKeyParams(it, "this", Boolean.valueOf(false));
        _builder.append(_modUrlPrimaryKeyParams, "    ");
        _builder.append(")),");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'icon\' => \'edit\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'linkTitle\' => __(\'Edit\', $dom),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'linkText\' => __(\'Edit\', $dom)");
        _builder.newLine();
        _builder.append(");");
        _builder.newLine();
      }
    }
    {
      EntityTreeType _tree = it.getTree();
      boolean _equals = Objects.equal(_tree, EntityTreeType.NONE);
      if (_equals) {
        _builder.append("$this->_actions[] = array(");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'url\' => array(\'type\' => \'");
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_1, "    ");
        _builder.append("\', \'func\' => \'edit\', \'arguments\' => array(\'ot\' => \'");
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\'");
        String _modUrlPrimaryKeyParams_1 = this._urlExtensions.modUrlPrimaryKeyParams(it, "this", Boolean.valueOf(false), "astemplate");
        _builder.append(_modUrlPrimaryKeyParams_1, "    ");
        _builder.append(")),");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'icon\' => \'saveas\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'linkTitle\' => __(\'Reuse for new item\', $dom),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'linkText\' => __(\'Reuse\', $dom)");
        _builder.newLine();
        _builder.append(");");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence loadWorkflow(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    Models _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    _builder.append("// apply workflow with most important information");
    _builder.newLine();
    _builder.append("$idColumn = \'");
    Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
    DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields);
    String _name = _head.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("(ServiceUtil::getManager()");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule(\'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("\')");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$schemaName = $workflowHelper->getWorkflowName($this[\'_objectType\']);");
    _builder.newLine();
    _builder.append("$this[\'__WORKFLOW__\'] = array(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'state\' => $this[\'workflowState\'],");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'obj_table\' => $this[\'_objectType\'],");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'obj_idcolumn\' => $idColumn,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'obj_id\' => $this[$idColumn],");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'schemaname\' => $schemaName);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// load the real workflow only when required (e. g. when func is edit or delete)");
    _builder.newLine();
    _builder.append("if (!in_array($currentFunc, array(\'");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\', \'view\', \'display\'))) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$result = Zikula_Workflow_Util::getWorkflowForObject($this, $this[\'_objectType\'], $idColumn, \'");
    String _appName_2 = this._utils.appName(app);
    _builder.append(_appName_2, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!$result) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName_3 = this._utils.appName(app);
    _builder.append(_appName_3, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("LogUtil::registerError(__(\'Error! Could not load the associated workflow.\', $dom));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (!is_object($this[\'__WORKFLOW__\']) && !isset($this[\'__WORKFLOW__\'][\'schemaname\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflow = $this[\'__WORKFLOW__\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflow[\'schemaname\'] = $schemaName;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this[\'__WORKFLOW__\'] = $workflow;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence constructor(final Entity it, final Boolean isInheriting) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Constructor.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Will not be called by Doctrine and can therefore be used");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* for own implementation purposes. It is also possible to add");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* arbitrary arguments as with every other class method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TODO");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function __construct(");
    CharSequence _constructorArguments = this.constructorArguments(it, Boolean.valueOf(true));
    _builder.append(_constructorArguments, "");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _constructorImpl = this.constructorImpl(it, isInheriting);
    _builder.append(_constructorImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence constructorArgumentsDefault(final Entity it, final Boolean hasPreviousArgs) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        {
          if ((hasPreviousArgs).booleanValue()) {
            _builder.append(", ");
          }
        }
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            _builder.append("$");
            String _name = pkField.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence constructorArguments(final Entity it, final Boolean withTypeHints) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isIndexByTarget = this._modelJoinExtensions.isIndexByTarget(it);
      if (_isIndexByTarget) {
        Iterable<JoinRelationship> _incomingJoinRelations = this._modelJoinExtensions.getIncomingJoinRelations(it);
        final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
            public Boolean apply(final JoinRelationship e) {
              boolean _isIndexed = Entities.this._modelJoinExtensions.isIndexed(e);
              return Boolean.valueOf(_isIndexed);
            }
          };
        Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_incomingJoinRelations, _function);
        final JoinRelationship indexRelation = IterableExtensions.<JoinRelationship>head(_filter);
        _builder.newLineIfNotEmpty();
        final String sourceAlias = this._namingExtensions.getRelationAliasName(indexRelation, Boolean.valueOf(false));
        _builder.newLineIfNotEmpty();
        final String indexBy = this._modelJoinExtensions.getIndexByField(indexRelation);
        _builder.newLineIfNotEmpty();
        _builder.append("$");
        String _formatForCode = this._formattingExtensions.formatForCode(indexBy);
        _builder.append(_formatForCode, "");
        _builder.append(",");
        {
          if ((withTypeHints).booleanValue()) {
            _builder.append(" ");
            Entity _source = indexRelation.getSource();
            String _entityClassName = this._namingExtensions.entityClassName(_source, "", Boolean.valueOf(false));
            _builder.append(_entityClassName, "");
          }
        }
        _builder.append(" $");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode_1, "");
        CharSequence _constructorArgumentsDefault = this.constructorArgumentsDefault(it, Boolean.valueOf(true));
        _builder.append(_constructorArgumentsDefault, "");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isAggregated = this._modelJoinExtensions.isAggregated(it);
        if (_isAggregated) {
          {
            Iterable<DerivedField> _aggregators = this._modelJoinExtensions.getAggregators(it);
            boolean _hasElements = false;
            for(final DerivedField aggregator : _aggregators) {
              if (!_hasElements) {
                _hasElements = true;
              } else {
                _builder.appendImmediate(", ", "");
              }
              {
                Iterable<OneToManyRelationship> _aggregatingRelationships = this._modelJoinExtensions.getAggregatingRelationships(aggregator);
                boolean _hasElements_1 = false;
                for(final OneToManyRelationship relation : _aggregatingRelationships) {
                  if (!_hasElements_1) {
                    _hasElements_1 = true;
                  } else {
                    _builder.appendImmediate(", ", "");
                  }
                  CharSequence _constructorArgumentsAggregate = this.constructorArgumentsAggregate(relation);
                  _builder.append(_constructorArgumentsAggregate, "");
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
          CharSequence _constructorArgumentsDefault_1 = this.constructorArgumentsDefault(it, Boolean.valueOf(true));
          _builder.append(_constructorArgumentsDefault_1, "");
          _builder.newLineIfNotEmpty();
        } else {
          CharSequence _constructorArgumentsDefault_2 = this.constructorArgumentsDefault(it, Boolean.valueOf(false));
          _builder.append(_constructorArgumentsDefault_2, "");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence constructorArgumentsAggregate(final OneToManyRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _source = it.getSource();
    Iterable<IntegerField> _aggregateFields = this._modelExtensions.getAggregateFields(_source);
    IntegerField _head = IterableExtensions.<IntegerField>head(_aggregateFields);
    final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(_head);
    _builder.newLineIfNotEmpty();
    _builder.append("$");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.append(_relationAliasName, "");
    _builder.append(", $");
    String _name = targetField.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence constructorImpl(final Entity it, final Boolean isInheriting) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isInheriting).booleanValue()) {
        _builder.append("parent::__construct(");
        CharSequence _constructorArguments = this.constructorArguments(it, Boolean.valueOf(false));
        _builder.append(_constructorArguments, "");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          for(final DerivedField pkField : _primaryKeyFields) {
            _builder.append("$this->");
            String _name = pkField.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "");
            _builder.append(" = $");
            String _name_1 = pkField.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "");
            _builder.append(";");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          boolean _and = false;
          boolean _isMandatory = e.isMandatory();
          if (!_isMandatory) {
            _and = false;
          } else {
            boolean _isPrimaryKey = e.isPrimaryKey();
            boolean _not = (!_isPrimaryKey);
            _and = (_isMandatory && _not);
          }
          return Boolean.valueOf(_and);
        }
      };
    final Iterable<DerivedField> mandatoryFields = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
    _builder.newLineIfNotEmpty();
    {
      Iterable<IntegerField> _filter = Iterables.<IntegerField>filter(mandatoryFields, IntegerField.class);
      final Function1<IntegerField,Boolean> _function_1 = new Function1<IntegerField,Boolean>() {
          public Boolean apply(final IntegerField e) {
            boolean _or = false;
            boolean _or_1 = false;
            String _defaultValue = e.getDefaultValue();
            boolean _tripleEquals = (_defaultValue == null);
            if (_tripleEquals) {
              _or_1 = true;
            } else {
              String _defaultValue_1 = e.getDefaultValue();
              boolean _equals = Objects.equal(_defaultValue_1, "");
              _or_1 = (_tripleEquals || _equals);
            }
            if (_or_1) {
              _or = true;
            } else {
              String _defaultValue_2 = e.getDefaultValue();
              boolean _equals_1 = Objects.equal(_defaultValue_2, "0");
              _or = (_or_1 || _equals_1);
            }
            return Boolean.valueOf(_or);
          }
        };
      Iterable<IntegerField> _filter_1 = IterableExtensions.<IntegerField>filter(_filter, _function_1);
      for(final IntegerField mandatoryField : _filter_1) {
        _builder.append("$this->");
        String _name_2 = mandatoryField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "");
        _builder.append(" = 1;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Iterable<UserField> _filter_2 = Iterables.<UserField>filter(mandatoryFields, UserField.class);
      final Function1<UserField,Boolean> _function_2 = new Function1<UserField,Boolean>() {
          public Boolean apply(final UserField e) {
            boolean _or = false;
            boolean _or_1 = false;
            String _defaultValue = e.getDefaultValue();
            boolean _tripleEquals = (_defaultValue == null);
            if (_tripleEquals) {
              _or_1 = true;
            } else {
              String _defaultValue_1 = e.getDefaultValue();
              boolean _equals = Objects.equal(_defaultValue_1, "");
              _or_1 = (_tripleEquals || _equals);
            }
            if (_or_1) {
              _or = true;
            } else {
              String _defaultValue_2 = e.getDefaultValue();
              boolean _equals_1 = Objects.equal(_defaultValue_2, "0");
              _or = (_or_1 || _equals_1);
            }
            return Boolean.valueOf(_or);
          }
        };
      Iterable<UserField> _filter_3 = IterableExtensions.<UserField>filter(_filter_2, _function_2);
      for(final UserField mandatoryField_1 : _filter_3) {
        _builder.append("$this->");
        String _name_3 = mandatoryField_1.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_3, "");
        _builder.append(" = UserUtil::getVar(\'uid\');");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Iterable<DecimalField> _filter_4 = Iterables.<DecimalField>filter(mandatoryFields, DecimalField.class);
      final Function1<DecimalField,Boolean> _function_3 = new Function1<DecimalField,Boolean>() {
          public Boolean apply(final DecimalField e) {
            boolean _or = false;
            boolean _or_1 = false;
            String _defaultValue = e.getDefaultValue();
            boolean _tripleEquals = (_defaultValue == null);
            if (_tripleEquals) {
              _or_1 = true;
            } else {
              String _defaultValue_1 = e.getDefaultValue();
              boolean _equals = Objects.equal(_defaultValue_1, "");
              _or_1 = (_tripleEquals || _equals);
            }
            if (_or_1) {
              _or = true;
            } else {
              String _defaultValue_2 = e.getDefaultValue();
              boolean _equals_1 = Objects.equal(_defaultValue_2, "0");
              _or = (_or_1 || _equals_1);
            }
            return Boolean.valueOf(_or);
          }
        };
      Iterable<DecimalField> _filter_5 = IterableExtensions.<DecimalField>filter(_filter_4, _function_3);
      for(final DecimalField mandatoryField_2 : _filter_5) {
        _builder.append("$this->");
        String _name_4 = mandatoryField_2.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_4, "");
        _builder.append(" = 1;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Iterable<AbstractDateField> _filter_6 = Iterables.<AbstractDateField>filter(mandatoryFields, AbstractDateField.class);
      final Function1<AbstractDateField,Boolean> _function_4 = new Function1<AbstractDateField,Boolean>() {
          public Boolean apply(final AbstractDateField e) {
            boolean _or = false;
            boolean _or_1 = false;
            String _defaultValue = e.getDefaultValue();
            boolean _tripleEquals = (_defaultValue == null);
            if (_tripleEquals) {
              _or_1 = true;
            } else {
              String _defaultValue_1 = e.getDefaultValue();
              boolean _equals = Objects.equal(_defaultValue_1, "");
              _or_1 = (_tripleEquals || _equals);
            }
            if (_or_1) {
              _or = true;
            } else {
              String _defaultValue_2 = e.getDefaultValue();
              int _length = _defaultValue_2.length();
              boolean _equals_1 = (_length == 0);
              _or = (_or_1 || _equals_1);
            }
            return Boolean.valueOf(_or);
          }
        };
      Iterable<AbstractDateField> _filter_7 = IterableExtensions.<AbstractDateField>filter(_filter_6, _function_4);
      for(final AbstractDateField mandatoryField_3 : _filter_7) {
        _builder.append("$this->");
        String _name_5 = mandatoryField_3.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode_5, "");
        _builder.append(" = ");
        CharSequence _defaultAssignment = this.defaultAssignment(mandatoryField_3);
        _builder.append(_defaultAssignment, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Iterable<FloatField> _filter_8 = Iterables.<FloatField>filter(mandatoryFields, FloatField.class);
      final Function1<FloatField,Boolean> _function_5 = new Function1<FloatField,Boolean>() {
          public Boolean apply(final FloatField e) {
            boolean _or = false;
            boolean _or_1 = false;
            String _defaultValue = e.getDefaultValue();
            boolean _tripleEquals = (_defaultValue == null);
            if (_tripleEquals) {
              _or_1 = true;
            } else {
              String _defaultValue_1 = e.getDefaultValue();
              boolean _equals = Objects.equal(_defaultValue_1, "");
              _or_1 = (_tripleEquals || _equals);
            }
            if (_or_1) {
              _or = true;
            } else {
              String _defaultValue_2 = e.getDefaultValue();
              boolean _equals_1 = Objects.equal(_defaultValue_2, "0");
              _or = (_or_1 || _equals_1);
            }
            return Boolean.valueOf(_or);
          }
        };
      Iterable<FloatField> _filter_9 = IterableExtensions.<FloatField>filter(_filter_8, _function_5);
      for(final FloatField mandatoryField_4 : _filter_9) {
        _builder.append("$this->");
        String _name_6 = mandatoryField_4.getName();
        String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_6, "");
        _builder.append(" = 1;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("$this->workflowState = \'initial\';");
    _builder.newLine();
    {
      boolean _isIndexByTarget = this._modelJoinExtensions.isIndexByTarget(it);
      if (_isIndexByTarget) {
        EList<Relationship> _incoming = it.getIncoming();
        Iterable<JoinRelationship> _filter_10 = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
        final Function1<JoinRelationship,Boolean> _function_6 = new Function1<JoinRelationship,Boolean>() {
            public Boolean apply(final JoinRelationship e) {
              boolean _isIndexed = Entities.this._modelJoinExtensions.isIndexed(e);
              return Boolean.valueOf(_isIndexed);
            }
          };
        Iterable<JoinRelationship> _filter_11 = IterableExtensions.<JoinRelationship>filter(_filter_10, _function_6);
        final JoinRelationship indexRelation = IterableExtensions.<JoinRelationship>head(_filter_11);
        _builder.newLineIfNotEmpty();
        final String sourceAlias = this._namingExtensions.getRelationAliasName(indexRelation, Boolean.valueOf(false));
        _builder.newLineIfNotEmpty();
        final String targetAlias = this._namingExtensions.getRelationAliasName(indexRelation, Boolean.valueOf(true));
        _builder.newLineIfNotEmpty();
        final String indexBy = this._modelJoinExtensions.getIndexByField(indexRelation);
        _builder.newLineIfNotEmpty();
        _builder.append("$this->");
        String _formatForCode_7 = this._formattingExtensions.formatForCode(indexBy);
        _builder.append(_formatForCode_7, "");
        _builder.append(" = $");
        String _formatForCode_8 = this._formattingExtensions.formatForCode(indexBy);
        _builder.append(_formatForCode_8, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("$this->");
        String _formatForCode_9 = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode_9, "");
        _builder.append(" = $");
        String _formatForCode_10 = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode_10, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("$");
        String _formatForCode_11 = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode_11, "");
        _builder.append("->add");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(targetAlias);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("($this);");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isAggregated = this._modelJoinExtensions.isAggregated(it);
        if (_isAggregated) {
          {
            Iterable<DerivedField> _aggregators = this._modelJoinExtensions.getAggregators(it);
            for(final DerivedField aggregator : _aggregators) {
              {
                Iterable<OneToManyRelationship> _aggregatingRelationships = this._modelJoinExtensions.getAggregatingRelationships(aggregator);
                for(final OneToManyRelationship relation : _aggregatingRelationships) {
                  CharSequence _constructorAssignmentAggregate = this.constructorAssignmentAggregate(relation);
                  _builder.append(_constructorAssignmentAggregate, "");
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
        } else {
        }
      }
    }
    _builder.append("$this->_idFields = array(");
    {
      Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField_1 : _primaryKeyFields_1) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "");
        }
        _builder.append("\'");
        String _name_7 = pkField_1.getName();
        String _formatForCode_12 = this._formattingExtensions.formatForCode(_name_7);
        _builder.append(_formatForCode_12, "");
        _builder.append("\'");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->initValidator();");
    _builder.newLine();
    _builder.append("$this->initWorkflow();");
    _builder.newLine();
    _builder.append("$this->_hasUniqueSlug = ");
    {
      boolean _and = false;
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (!_hasSluggableFields) {
        _and = false;
      } else {
        boolean _isSlugUnique = it.isSlugUnique();
        _and = (_hasSluggableFields && _isSlugUnique);
      }
      if (_and) {
        _builder.append("true");
      } else {
        _builder.append("false");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    CharSequence _initCollections = this.thAssoc.initCollections(it);
    _builder.append(_initCollections, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence constructorAssignmentAggregate(final OneToManyRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _source = it.getSource();
    Iterable<IntegerField> _aggregateFields = this._modelExtensions.getAggregateFields(_source);
    IntegerField _head = IterableExtensions.<IntegerField>head(_aggregateFields);
    final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(_head);
    _builder.newLineIfNotEmpty();
    _builder.append("$this->");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.append(_relationAliasName, "");
    _builder.append(" = $");
    String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.append(_relationAliasName_1, "");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->");
    String _name = targetField.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append(" = $");
    String _name_1 = targetField.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence defaultAssignment(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\\DateTime::createFromFormat(\'");
    CharSequence _defaultFormat = this.defaultFormat(it);
    _builder.append(_defaultFormat, "");
    _builder.append("\', date(\'");
    CharSequence _defaultFormat_1 = this.defaultFormat(it);
    _builder.append(_defaultFormat_1, "");
    _builder.append("\'))");
    return _builder;
  }
  
  private CharSequence _defaultFormat(final AbstractDateField it) {
    return null;
  }
  
  private CharSequence _defaultFormat(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Y-m-d H:i:s");
    return _builder;
  }
  
  private CharSequence _defaultFormat(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Y-m-d");
    return _builder;
  }
  
  private CharSequence _defaultFormat(final TimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("H:i:s");
    return _builder;
  }
  
  private CharSequence propertyChangedListener(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasNotifyPolicy = this._modelExtensions.hasNotifyPolicy(it);
      if (_hasNotifyPolicy) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Adds a property change listener.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param PropertyChangedListener $listener The listener to be added");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function addPropertyChangedListener(PropertyChangedListener $listener)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->_propertyChangedListeners[] = $listener;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Notify all registered listeners about a changed property.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param String $propName Name of property which has been changed");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param mixed  $oldValue The old property value");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param mixed  $newValue The new property value");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function _onPropertyChanged($propName, $oldValue, $newValue)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->_propertyChangedListeners) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("foreach ($this->_propertyChangedListeners as $listener) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$listener->propertyChanged($this, $propName, $oldValue, $newValue);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence toStringImpl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ToString interceptor implementation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method is useful for debugging purposes.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function __toString()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        _builder.append("    ");
        _builder.append("$output = \'\';");
        _builder.newLine();
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          for(final DerivedField field : _primaryKeyFields) {
            _builder.append("    ");
            _builder.append("if (!empty($output)) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$output .= \"\\n\";");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$output .= $this->get");
            String _name = field.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
            _builder.append(_formatForCodeCapital, "    ");
            _builder.append("();");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $output;");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return $this->get");
        Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
        DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields_1);
        String _name_1 = _head.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("();");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence cloneImpl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<JoinRelationship> joinsIn = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
    _builder.newLineIfNotEmpty();
    final Iterable<JoinRelationship> joinsOut = this._modelJoinExtensions.getOutgoingJoinRelations(it);
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Clone interceptor implementation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method is for example called by the reuse functionality.");
    _builder.newLine();
    {
      boolean _and = false;
      boolean _isEmpty = IterableExtensions.isEmpty(joinsIn);
      if (!_isEmpty) {
        _and = false;
      } else {
        boolean _isEmpty_1 = IterableExtensions.isEmpty(joinsOut);
        _and = (_isEmpty && _isEmpty_1);
      }
      if (_and) {
        _builder.append(" ");
        _builder.append("* Performs a quite simple shallow copy.");
        _builder.newLine();
      } else {
        _builder.append(" ");
        _builder.append("* Performs a deep copy. ");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* See also:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* (1) http://docs.doctrine-project.org/en/latest/cookbook/implementing-wakeup-or-clone.html");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* (2) http://www.sunilb.com/php/php5-oops-tutorial-magic-methods-__clone-method");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* (3) http://stackoverflow.com/questions/185934/how-do-i-create-a-copy-of-an-object-in-php");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function __clone()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// If the entity has an identity, proceed as normal.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField field : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" && ", "    ");
        }
        _builder.append("$this->");
        String _name = field.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
      }
    }
    _builder.append(") {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// create new instance");
    _builder.newLine();
    _builder.append("        ");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = new \\");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "        ");
    _builder.append("();");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// unset identifiers");
    _builder.newLine();
    {
      Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
      for(final DerivedField field_1 : _primaryKeyFields_1) {
        _builder.append("        ");
        _builder.append("$entity->set");
        String _name_1 = field_1.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("(null);");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("// copy simple fields");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->set_objectType($this->get_objectType());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->set_idFields($this->get_idFields());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->set_hasUniqueSlug($this->get_hasUniqueSlug());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->set_actions($this->get_actions());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->initValidator();");
    _builder.newLine();
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
          public Boolean apply(final DerivedField e) {
            boolean _and = false;
            boolean _isPrimaryKey = e.isPrimaryKey();
            boolean _not = (!_isPrimaryKey);
            if (!_not) {
              _and = false;
            } else {
              String _name = e.getName();
              boolean _notEquals = (!Objects.equal(_name, "workflowState"));
              _and = (_not && _notEquals);
            }
            return Boolean.valueOf(_and);
          }
        };
      Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
      for(final DerivedField field_2 : _filter) {
        _builder.append("        ");
        _builder.append("$entity->set");
        String _name_2 = field_2.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_1, "        ");
        _builder.append("($this->get");
        String _name_3 = field_2.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_2, "        ");
        _builder.append("());");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    {
      boolean _or = false;
      boolean _isEmpty_2 = IterableExtensions.isEmpty(joinsIn);
      boolean _not = (!_isEmpty_2);
      if (_not) {
        _or = true;
      } else {
        boolean _isEmpty_3 = IterableExtensions.isEmpty(joinsOut);
        boolean _not_1 = (!_isEmpty_3);
        _or = (_not || _not_1);
      }
      if (_or) {
        _builder.append("        ");
        _builder.append("// handle related objects");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// prevent shared references by doing a deep copy - see (2) and (3) for more information");
        _builder.newLine();
        {
          for(final JoinRelationship relation : joinsIn) {
            _builder.append("        ");
            String aliasName = this._namingExtensions.getRelationAliasName(relation, Boolean.valueOf(false));
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("if ($this->get");
            String _firstUpper = StringExtensions.toFirstUpper(aliasName);
            _builder.append(_firstUpper, "        ");
            _builder.append("() != null) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$this->");
            _builder.append(aliasName, "            ");
            _builder.append(" = clone $this->");
            _builder.append(aliasName, "            ");
            _builder.append(";");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$entity->set");
            String _firstUpper_1 = StringExtensions.toFirstUpper(aliasName);
            _builder.append(_firstUpper_1, "            ");
            _builder.append("($this->");
            _builder.append(aliasName, "            ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          for(final JoinRelationship relation_1 : joinsOut) {
            _builder.append("        ");
            String aliasName_1 = this._namingExtensions.getRelationAliasName(relation_1, Boolean.valueOf(true));
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("if ($this->get");
            String _firstUpper_2 = StringExtensions.toFirstUpper(aliasName_1);
            _builder.append(_firstUpper_2, "        ");
            _builder.append("() != null) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$this->");
            _builder.append(aliasName_1, "            ");
            _builder.append(" = clone $this->");
            _builder.append(aliasName_1, "            ");
            _builder.append(";");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$entity->set");
            String _firstUpper_3 = StringExtensions.toFirstUpper(aliasName_1);
            _builder.append(_firstUpper_3, "            ");
            _builder.append("($this->");
            _builder.append(aliasName_1, "            ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $entity;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// otherwise do nothing, do NOT throw an exception!");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence defaultFormat(final AbstractDateField it) {
    if (it instanceof DateField) {
      return _defaultFormat((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _defaultFormat((DatetimeField)it);
    } else if (it instanceof TimeField) {
      return _defaultFormat((TimeField)it);
    } else if (it != null) {
      return _defaultFormat(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
