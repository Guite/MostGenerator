package org.zikula.modulestudio.generator.cartridges.zclassic.models;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.CalculatedField;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.ObjectField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.Arrays;
import java.util.List;
import java.util.function.Consumer;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Joins;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.LinkTable;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Tree;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.UserDeletion;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Repository {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private ModelInheritanceExtensions _modelInheritanceExtensions = new ModelInheritanceExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private IFileSystemAccess fsa;
  
  private FileHelper fh = new FileHelper();
  
  private Application app;
  
  /**
   * Entry point for Doctrine repository classes.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    this.app = it;
    final Consumer<Entity> _function = (Entity e) -> {
      this.generate(e);
    };
    this._modelExtensions.getAllEntities(it).forEach(_function);
    final LinkTable linkTable = new LinkTable();
    Iterable<ManyToManyRelationship> _filter = Iterables.<ManyToManyRelationship>filter(this._modelJoinExtensions.getJoinRelations(it), ManyToManyRelationship.class);
    for (final ManyToManyRelationship relation : _filter) {
      linkTable.generate(relation, it, fsa);
    }
  }
  
  /**
   * Creates a repository class file for every Entity instance.
   */
  private void generate(final Entity it) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating repository classes for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    final String repositoryPath = (_appSourceLibPath + "Entity/Repository/");
    String fileSuffix = "Repository";
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus_2 = ("Base/Abstract" + _formatForCodeCapital);
    String _plus_3 = (_plus_2 + fileSuffix);
    String fileName = (_plus_3 + ".php");
    if (((!this._modelInheritanceExtensions.isInheriting(it)) && (!this._namingExtensions.shouldBeSkipped(this.app, (repositoryPath + fileName))))) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(this.app, (repositoryPath + fileName));
      if (_shouldBeMarked) {
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        String _plus_4 = ("Base/" + _formatForCodeCapital_1);
        String _plus_5 = (_plus_4 + fileSuffix);
        String _plus_6 = (_plus_5 + ".generated.php");
        fileName = _plus_6;
      }
      this.fsa.generateFile((repositoryPath + fileName), this.fh.phpFileContent(this.app, this.modelRepositoryBaseImpl(it)));
    }
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus_7 = (_formatForCodeCapital_2 + fileSuffix);
    String _plus_8 = (_plus_7 + ".php");
    fileName = _plus_8;
    if (((!this._generatorSettingsExtensions.generateOnlyBaseClasses(this.app)) && (!this._namingExtensions.shouldBeSkipped(this.app, (repositoryPath + fileName))))) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(this.app, (repositoryPath + fileName));
      if (_shouldBeMarked_1) {
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
        String _plus_9 = (_formatForCodeCapital_3 + fileSuffix);
        String _plus_10 = (_plus_9 + ".generated.php");
        fileName = _plus_10;
      }
      this.fsa.generateFile((repositoryPath + fileName), this.fh.phpFileContent(this.app, this.modelRepositoryImpl(it)));
    }
  }
  
  private EntityField getDefaultSortingField(final Entity it) {
    EntityField _xifexpression = null;
    boolean _hasSortableFields = this._modelBehaviourExtensions.hasSortableFields(it);
    if (_hasSortableFields) {
      _xifexpression = IterableExtensions.<IntegerField>head(this._modelBehaviourExtensions.getSortableFields(it));
    } else {
      EntityField _xifexpression_1 = null;
      boolean _isEmpty = this._modelExtensions.getSortingFields(it).isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        EntityField _xifexpression_2 = null;
        if (((this._modelExtensions.getSortingFields(it).size() > 1) && Objects.equal(this._formattingExtensions.formatForCode(IterableExtensions.<EntityField>head(this._modelExtensions.getSortingFields(it)).getName()), "workflowState"))) {
          _xifexpression_2 = this._modelExtensions.getSortingFields(it).get(1);
        } else {
          _xifexpression_2 = IterableExtensions.<EntityField>head(this._modelExtensions.getSortingFields(it));
        }
        _xifexpression_1 = _xifexpression_2;
      } else {
        DerivedField _xblockexpression = null;
        {
          final Function1<StringField, Boolean> _function = (StringField it_1) -> {
            boolean _isPassword = it_1.isPassword();
            return Boolean.valueOf((!_isPassword));
          };
          final Iterable<StringField> stringFields = IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function);
          DerivedField _xifexpression_3 = null;
          boolean _isEmpty_1 = IterableExtensions.isEmpty(stringFields);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            _xifexpression_3 = IterableExtensions.<StringField>head(stringFields);
          } else {
            _xifexpression_3 = IterableExtensions.<DerivedField>head(this._modelExtensions.getDerivedFields(it));
          }
          _xblockexpression = _xifexpression_3;
        }
        _xifexpression_1 = _xblockexpression;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  private CharSequence modelRepositoryBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _imports = this.imports(it);
    _builder.append(_imports);
    _builder.newLineIfNotEmpty();
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
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Repository extends ");
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        String _firstUpper = StringExtensions.toFirstUpper(it.getTree().getLiteral().toLowerCase());
        _builder.append(_firstUpper);
        _builder.append("TreeRepository");
      } else {
        boolean _hasSortableFields = this._modelBehaviourExtensions.hasSortableFields(it);
        if (_hasSortableFields) {
          _builder.append("SortableRepository");
        } else {
          _builder.append("EntityRepository");
        }
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.newLine();
    _builder.append("    ");
    final Function1<StringField, Boolean> _function = (StringField it_1) -> {
      boolean _isPassword = it_1.isPassword();
      return Boolean.valueOf((!_isPassword));
    };
    final Iterable<StringField> stringFields = IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string The default sorting field/expression");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $defaultSortingField = \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this.getDefaultSortingField(it).getName());
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var Request The request object given by the calling controller");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $request;");
    _builder.newLine();
    _builder.append("    ");
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
    _builder.append("* @return array Sorting fields array");
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
    _builder.append("return [");
    _builder.newLine();
    _builder.append("            ");
    {
      List<EntityField> _sortingFields = this._modelExtensions.getSortingFields(it);
      for(final EntityField field : _sortingFields) {
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
    _builder.append("];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "defaultSortingField", "string", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, "request", "Request", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_1, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _fieldNameHelpers = this.fieldNameHelpers(it, stringFields);
    _builder.append(_fieldNameHelpers, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _additionalTemplateParameters = this.getAdditionalTemplateParameters(it);
    _builder.append(_additionalTemplateParameters, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _viewQuickNavParameters = this.getViewQuickNavParameters(it);
    _builder.append(_viewQuickNavParameters, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _truncateTable = this.truncateTable(it);
    _builder.append(_truncateTable, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _generate = new UserDeletion().generate(it);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _selectById = this.selectById(it);
    _builder.append(_selectById, "    ");
    _builder.newLineIfNotEmpty();
    {
      if ((this._modelBehaviourExtensions.hasSluggableFields(it) && it.isSlugUnique())) {
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
    {
      boolean _isOwnerPermission = it.isOwnerPermission();
      if (_isOwnerPermission) {
        _builder.append("    ");
        CharSequence _addCreatorFilter = this.addCreatorFilter(it);
        _builder.append(_addCreatorFilter, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
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
    _builder.newLine();
    _builder.append("    ");
    CharSequence _retrieveCollectionResult = this.retrieveCollectionResult(it);
    _builder.append(_retrieveCollectionResult, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _selectCount = this.selectCount(it);
    _builder.append(_selectCount, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate_1 = new Tree().generate(it, this.app);
    _builder.append(_generate_1, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _detectUniqueState = this.detectUniqueState(it);
    _builder.append(_detectUniqueState, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _genericBaseQuery = this.genericBaseQuery(it);
    _builder.append(_genericBaseQuery, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _genericBaseQueryWhere = this.genericBaseQueryWhere(it);
    _builder.append(_genericBaseQueryWhere, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _genericBaseQueryOrderBy = this.genericBaseQueryOrderBy(it);
    _builder.append(_genericBaseQueryOrderBy, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _intGetQueryFromBuilder = this.intGetQueryFromBuilder(it);
    _builder.append(_intGetQueryFromBuilder, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate_2 = new Joins().generate(it, this.app);
    _builder.append(_generate_2, "    ");
    _builder.newLineIfNotEmpty();
    {
      if ((it.isHasArchive() && (null != this._modelExtensions.getEndDateField(it)))) {
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
  
  private CharSequence imports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Repository\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Doctrine\\Common\\Collections\\ArrayCollection;");
    _builder.newLine();
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.append("use Gedmo\\Tree\\Entity\\Repository\\");
        String _firstUpper = StringExtensions.toFirstUpper(it.getTree().getLiteral().toLowerCase());
        _builder.append(_firstUpper);
        _builder.append("TreeRepository;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use Doctrine\\ORM\\EntityManager;");
        _builder.newLine();
      } else {
        boolean _hasSortableFields = this._modelBehaviourExtensions.hasSortableFields(it);
        if (_hasSortableFields) {
          _builder.append("use Gedmo\\Sortable\\Entity\\Repository\\SortableRepository;");
          _builder.newLine();
        } else {
          _builder.append("use Doctrine\\ORM\\EntityRepository;");
          _builder.newLine();
        }
      }
    }
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\Query;");
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\QueryBuilder;");
    _builder.newLine();
    {
      if (((this._modelExtensions.hasOptimisticLock(it) || this._modelExtensions.hasPessimisticReadLock(it)) || this._modelExtensions.hasPessimisticWriteLock(it))) {
        _builder.append("use Doctrine\\DBAL\\LockMode;");
        _builder.newLine();
      }
    }
    _builder.append("use Doctrine\\ORM\\Tools\\Pagination\\Paginator;");
    _builder.newLine();
    _builder.append("use InvalidArgumentException;");
    _builder.newLine();
    _builder.append("use Psr\\Log\\LoggerInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Zikula\\Component\\FilterUtil\\FilterUtil;");
    _builder.newLine();
    _builder.append("use Zikula\\Component\\FilterUtil\\Config as FilterConfig;");
    _builder.newLine();
    _builder.append("use Zikula\\Component\\FilterUtil\\PluginManager as FilterPluginManager;");
    _builder.newLine();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<AbstractDateField>filter(it.getFields(), AbstractDateField.class));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("use Zikula\\Component\\FilterUtil\\Plugin\\DatePlugin as DateFilter;");
        _builder.newLine();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("use Zikula\\Core\\FilterUtil\\CategoryPlugin as CategoryFilter;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    {
      if ((it.isHasArchive() && (null != this._modelExtensions.getEndDateField(it)))) {
        _builder.append("use Symfony\\Component\\HttpFoundation\\Session\\SessionInterface;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\RouteUrl;");
        _builder.newLine();
        _builder.append("use Zikula\\PermissionsModule\\Api\\");
        {
          Boolean _targets = this._utils.targets(this.app, "1.5");
          if ((_targets).booleanValue()) {
            _builder.append("ApiInterface\\PermissionApiInterface");
          } else {
            _builder.append("PermissionApi");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use Zikula\\UsersModule\\Api\\");
    {
      Boolean _targets_1 = this._utils.targets(this.app, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("ApiInterface\\CurrentUserApiInterface");
      } else {
        _builder.append("CurrentUserApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Entity;");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_2);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (((it.isHasArchive() && (null != this._modelExtensions.getEndDateField(it))) && (!it.isSkipHookSubscribers()))) {
        _builder.append("use ");
        String _appNamespace_3 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_3);
        _builder.append("\\Helper\\HookHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(this.app);
      if (_hasUploads) {
        _builder.append("use ");
        String _appNamespace_4 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_4);
        _builder.append("\\Helper\\ImageHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((it.isHasArchive() && (null != this._modelExtensions.getEndDateField(it)))) {
        _builder.append("use ");
        String _appNamespace_5 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_5);
        _builder.append("\\Helper\\WorkflowHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence fieldNameHelpers(final Entity it, final Iterable<StringField> stringFields) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _titleFieldName = this.getTitleFieldName(it, stringFields);
    _builder.append(_titleFieldName);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _descriptionFieldName = this.getDescriptionFieldName(it, stringFields);
    _builder.append(_descriptionFieldName);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _previewFieldName = this.getPreviewFieldName(it);
    _builder.append(_previewFieldName);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _startDateFieldName = this.getStartDateFieldName(it);
    _builder.append(_startDateFieldName);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence getTitleFieldName(final Entity it, final Iterable<StringField> stringFields) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns name of the field used as title / name for entities of this repository.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Name of field to be used as title");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getTitleFieldName()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'");
    {
      boolean _isEmpty = IterableExtensions.isEmpty(stringFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(stringFields).getName());
        _builder.append(_formatForCode, "    ");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getDescriptionFieldName(final Entity it, final Iterable<StringField> stringFields) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns name of the field used for describing entities of this repository.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Name of field to be used as description");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getDescriptionFieldName()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    final Iterable<TextField> textFields = Iterables.<TextField>filter(it.getFields(), TextField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(textFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("    ");
        _builder.append("return \'");
        String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<TextField>head(textFields).getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isEmpty_1 = IterableExtensions.isEmpty(stringFields);
        boolean _not_1 = (!_isEmpty_1);
        if (_not_1) {
          {
            int _size = IterableExtensions.size(stringFields);
            boolean _greaterThan = (_size > 1);
            if (_greaterThan) {
              _builder.append("    ");
              _builder.append("return \'");
              String _formatForCode_1 = this._formattingExtensions.formatForCode(((StringField[])Conversions.unwrapArray(stringFields, StringField.class))[1].getName());
              _builder.append(_formatForCode_1, "    ");
              _builder.append("\';");
              _builder.newLineIfNotEmpty();
            } else {
              _builder.append("    ");
              _builder.append("return \'");
              String _formatForCode_2 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(stringFields).getName());
              _builder.append(_formatForCode_2, "    ");
              _builder.append("\';");
              _builder.newLineIfNotEmpty();
            }
          }
        } else {
          _builder.append("    ");
          _builder.append("return \'\';");
          _builder.newLine();
        }
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getPreviewFieldName(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns name of first upload field which is capable for handling images.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Name of field to be used for preview images");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getPreviewFieldName()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'");
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<UploadField>head(this._modelExtensions.getImageFieldsEntity(it)).getName());
        _builder.append(_formatForCode, "    ");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getStartDateFieldName(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns name of the date(time) field to be used for representing the start");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* of this object. Used for providing meta data to the tag module.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Name of field to be used as date");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getStartDateFieldName()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fieldName = \'");
    {
      AbstractDateField _startDateField = this._modelExtensions.getStartDateField(it);
      boolean _tripleNotEquals = (null != _startDateField);
      if (_tripleNotEquals) {
        String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getStartDateField(it).getName());
        _builder.append(_formatForCode, "    ");
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
    _builder.append("    ");
    _builder.append("return $fieldName;");
    _builder.newLine();
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
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(this.app);
      if (_hasUploads) {
        _builder.append(" ");
        _builder.append("* @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param array  $args    Additional arguments");
        _builder.newLine();
      } else {
        _builder.append(" ");
        _builder.append("* @param ImageHelper $imageHelper ImageHelper service instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param string      $context     Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param array       $args        Additional arguments");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of template variables to be assigned");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getAdditionalTemplateParameters(");
    {
      boolean _hasUploads_1 = this._modelExtensions.hasUploads(this.app);
      if (_hasUploads_1) {
        _builder.append("ImageHelper $imageHelper, ");
      }
    }
    _builder.append("$context = \'\', $args = [])");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, [\'controllerAction\', \'api\', \'actionHandler\', \'block\', \'contentType\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($context == \'controllerAction\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'action\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'action\'] = $this->getRequest()->query->getAlpha(\'func\', \'index\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (in_array($args[\'action\'], [\'index\', \'view\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$templateParameters = $this->getViewQuickNavParameters($context, $args);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasUploads_2 = this._modelExtensions.hasUploads(this.app);
      if (_hasUploads_2) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// initialise Imagine runtime options");
        _builder.newLine();
        {
          boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
          if (_hasUploadFieldsEntity) {
            _builder.append("        ");
            _builder.append("$objectType = \'");
            String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode, "        ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("$thumbRuntimeOptions = [];");
            _builder.newLine();
            {
              Iterable<UploadField> _uploadFieldsEntity = this._modelExtensions.getUploadFieldsEntity(it);
              for(final UploadField uploadField : _uploadFieldsEntity) {
                _builder.append("        ");
                _builder.append("$thumbRuntimeOptions[$objectType . \'");
                String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(uploadField.getName());
                _builder.append(_formatForCodeCapital, "        ");
                _builder.append("\'] = $imageHelper->getRuntimeOptions($objectType, \'");
                String _formatForCode_1 = this._formattingExtensions.formatForCode(uploadField.getName());
                _builder.append(_formatForCode_1, "        ");
                _builder.append("\', $context, $args);");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("        ");
            _builder.append("$templateParameters[\'thumbRuntimeOptions\'] = $thumbRuntimeOptions;");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("if (in_array($args[\'action\'], [\'display\', \'edit\', \'view\'])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// use separate preset for images in related items");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$templateParameters[\'relationThumbRuntimeOptions\'] = $imageHelper->getCustomRuntimeOptions(\'\', \'\', \'");
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "            ");
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
    _builder.append("// $parameters = parent::getAdditionalTemplateParameters(");
    {
      boolean _hasUploads_3 = this._modelExtensions.hasUploads(this.app);
      if (_hasUploads_3) {
        _builder.append("$imageHelper, ");
      }
    }
    _builder.append("$context, $args);");
    _builder.newLineIfNotEmpty();
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
    return _builder;
  }
  
  private CharSequence getViewQuickNavParameters(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns an array of additional template variables for view quick navigation forms.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args    Additional arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of template variables to be assigned");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getViewQuickNavParameters($context = \'\', $args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, [\'controllerAction\', \'api\', \'actionHandler\', \'block\', \'contentType\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$parameters = [];");
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("    ");
        _builder.append("$categoryHelper = \\ServiceUtil::get(\'");
        String _appService = this._utils.appService(this.app);
        _builder.append(_appService, "    ");
        _builder.append(".category_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$parameters[\'catIdList\'] = $categoryHelper->retrieveCategoriesFromRequest(\'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\', \'GET\');");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isEmpty = IterableExtensions.isEmpty(this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(it));
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          Iterable<JoinRelationship> _bidirectionalIncomingJoinRelationsWithOneSource = this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(it);
          for(final JoinRelationship relation : _bidirectionalIncomingJoinRelationsWithOneSource) {
            _builder.append("    ");
            final String sourceAliasName = this._namingExtensions.getRelationAliasName(relation, Boolean.valueOf(false));
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(sourceAliasName, "    ");
            _builder.append("\'] = $this->getRequest()->query->get(\'");
            _builder.append(sourceAliasName, "    ");
            _builder.append("\', 0);");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity) {
        {
          Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(it);
          for(final ListField field : _listFieldsEntity) {
            _builder.append("    ");
            final String fieldName = this._formattingExtensions.formatForCode(field.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName, "    ");
            _builder.append("\'] = $this->getRequest()->query->get(\'");
            _builder.append(fieldName, "    ");
            _builder.append("\', \'\');");
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
          for(final UserField field_1 : _userFieldsEntity) {
            _builder.append("    ");
            final String fieldName_1 = this._formattingExtensions.formatForCode(field_1.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_1, "    ");
            _builder.append("\'] = (int) $this->getRequest()->query->get(\'");
            _builder.append(fieldName_1, "    ");
            _builder.append("\', 0);");
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
          for(final StringField field_2 : _countryFieldsEntity) {
            _builder.append("    ");
            final String fieldName_2 = this._formattingExtensions.formatForCode(field_2.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_2, "    ");
            _builder.append("\'] = $this->getRequest()->query->get(\'");
            _builder.append(fieldName_2, "    ");
            _builder.append("\', \'\');");
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
          for(final StringField field_3 : _languageFieldsEntity) {
            _builder.append("    ");
            final String fieldName_3 = this._formattingExtensions.formatForCode(field_3.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_3, "    ");
            _builder.append("\'] = $this->getRequest()->query->get(\'");
            _builder.append(fieldName_3, "    ");
            _builder.append("\', \'\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasLocaleFieldsEntity = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity) {
        {
          Iterable<StringField> _localeFieldsEntity = this._modelExtensions.getLocaleFieldsEntity(it);
          for(final StringField field_4 : _localeFieldsEntity) {
            _builder.append("    ");
            final String fieldName_4 = this._formattingExtensions.formatForCode(field_4.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_4, "    ");
            _builder.append("\'] = $this->getRequest()->query->get(\'");
            _builder.append(fieldName_4, "    ");
            _builder.append("\', \'\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _builder.append("    ");
        _builder.append("$parameters[\'q\'] = $this->getRequest()->query->get(\'q\', \'\');");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.newLine();
    {
      boolean _hasBooleanFieldsEntity = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity) {
        {
          Iterable<BooleanField> _booleanFieldsEntity = this._modelExtensions.getBooleanFieldsEntity(it);
          for(final BooleanField field_5 : _booleanFieldsEntity) {
            _builder.append("    ");
            final String fieldName_5 = this._formattingExtensions.formatForCode(field_5.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$parameters[\'");
            _builder.append(fieldName_5, "    ");
            _builder.append("\'] = $this->getRequest()->query->get(\'");
            _builder.append(fieldName_5, "    ");
            _builder.append("\', \'\');");
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
    _builder.append("* @param LoggerInterface $logger Logger service instance");
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
    _builder.append("public function truncateTable(LoggerInterface $logger)");
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
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
        _builder.append(_lockTypeAsConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("\', \'entity\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\'];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logger->debug(\'{app}: Truncated the {entity} entity table.\', $logArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectById(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds an array of id filters to given query instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param mixed        $idList The array of ids to use to retrieve the object");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param QueryBuilder $qb     Query builder to be enhanced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder Enriched query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addIdListFilter($idList, QueryBuilder $qb)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$orX = $qb->expr()->orX();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($idList as $id) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// check id parameter");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($id == 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("throw new InvalidArgumentException(\'Invalid identifier received.\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (is_array($id)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$andX = $qb->expr()->andX();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($id as $fieldName => $fieldValue) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$andX->add($qb->expr()->eq(\'tbl.\' . $fieldName, $fieldValue));");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$orX->add($andX);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$orX->add($qb->expr()->eq(\'tbl.");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCode, "            ");
    _builder.append("\', $id));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->andWhere($orX);");
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
    _builder.append("* Selects an object from the database.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param mixed   $id       The id (or array of ids) to use to retrieve the object (optional) (default=0)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, " ");
    _builder.append("Entity retrieved data array or ");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, " ");
    _builder.append("Entity instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectById($id = 0, $useJoins = true, $slimMode = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$results = $this->selectByIdList(is_array($id) ? $id : [$id], $useJoins, $slimMode);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return count($results) > 0 ? $results[0] : null;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects a list of objects with an array of ids");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param mixed   $idList   The array of ids to use to retrieve the objects (optional) (default=0)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ArrayCollection collection containing retrieved ");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3, " ");
    _builder.append("Entity instances");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectByIdList($idList = [0], $useJoins = true, $slimMode = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->genericBaseQuery(\'\', \'\', $useJoins, $slimMode);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->addIdListFilter($idList, $qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$results = $query->getResult();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return count($results) > 0 ? $results : null;");
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
    _builder.append("* @param boolean $useJoins  Whether to include joining related objects (optional) (default=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $excludeId Optional id to be excluded (used for unique validation)");
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
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
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
    _builder.append("throw new InvalidArgumentException(\'Invalid slug title received.\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->genericBaseQuery(\'\', \'\', $useJoins, $slimMode);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->andWhere(\'tbl.slug = :slug\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'slug\', $slugTitle);");
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
    _builder.append("$results = $query->getResult();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return count($results) > 0 ? $results[0] : null;");
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
    _builder.append("* @param QueryBuilder $qb           Query builder to be enhanced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array        $excludesions Array of ids to be excluded from selection");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder Enriched query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addExclusion(QueryBuilder $qb, array $exclusions = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        _builder.append("    ");
        _builder.append("foreach ($exclusions as $fieldName => $fieldValue) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$exclusion = is_array($fieldValue) ? $fieldValue : [$fieldValue];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (count($exclusion) > 0) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$qb->andWhere(\'tbl.\' . $fieldName . \' NOT IN (:\' . $fieldName . \')\')");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("           ");
        _builder.append("->setParameter($fieldName, $exclusion);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("   ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("if (count($exclusions) > 0) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$qb->andWhere(\'tbl.");
        String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
        _builder.append(_formatForCode, "        ");
        _builder.append(" NOT IN (:excludedIdentifiers)\')");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("->setParameter(\'excludedIdentifiers\', $exclusions);");
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
  
  private CharSequence addCreatorFilter(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a filter for the createdBy field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param QueryBuilder $qb Query builder to be enhanced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer      $userId The user identifier used for filtering (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder Enriched query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function addCreatorFilter(QueryBuilder $qb, $userId = null)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $userId) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$currentUserApi = \\ServiceUtil::get(\'zikula_users_module.current_user\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$userId = $currentUserApi->isLoggedIn() ? $currentUserApi->get(\'uid\') : 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (is_array($userId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->andWhere(\'tbl.createdBy IN (:userIds)\')");
    _builder.newLine();
    _builder.append("           ");
    _builder.append("->setParameter(\'userIds\', $userId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->andWhere(\'tbl.createdBy = :userId\')");
    _builder.newLine();
    _builder.append("           ");
    _builder.append("->setParameter(\'userId\', $userId);");
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
  
  private CharSequence selectWhere(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns query builder for selecting a list of objects with a given where clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $where    The where clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder query builder for the given arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getListQueryBuilder($where = \'\', $orderBy = \'\', $useJoins = true, $slimMode = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->genericBaseQuery($where, $orderBy, $useJoins, $slimMode);");
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
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects a list of objects with a given where clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $where    The where clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ArrayCollection collection containing retrieved ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, " ");
    _builder.append("Entity instances");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectWhere($where = \'\', $orderBy = \'\', $useJoins = true, $slimMode = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getListQueryBuilder($where, $orderBy, $useJoins, $slimMode);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->retrieveCollectionResult($query, $orderBy, false);");
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
    _builder.append("* @param QueryBuilder $qb             Query builder to be enhanced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer      $currentPage    Where to start selection");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer      $resultsPerPage Amount of items to select");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Query Created query instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getSelectWherePaginatedQuery(QueryBuilder $qb, $currentPage = 1, $resultsPerPage = 25)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$offset = ($currentPage-1) * $resultsPerPage;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query->setFirstResult($offset)");
    _builder.newLine();
    _builder.append("          ");
    _builder.append("->setMaxResults($resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $query;");
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
    _builder.append("* @param string  $where          The where clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $currentPage    Where to start selection");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $resultsPerPage Amount of items to select");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins       Whether to include joining related objects (optional) (default=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode       If activated only some basic fields are selected without using any joins (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array with retrieved collection and amount of total records affected by this query");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectWherePaginated($where = \'\', $orderBy = \'\', $currentPage = 1, $resultsPerPage = 25, $useJoins = true, $slimMode = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getListQueryBuilder($where, $orderBy, $useJoins, $slimMode);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->retrieveCollectionResult($query, $orderBy, true);");
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
    _builder.append("* @param QueryBuilder $qb Query builder to be enhanced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder Enriched query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function addCommonViewFilters(QueryBuilder $qb)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $this->getRequest()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// if no request is set we return (#433)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routeName = $this->getRequest()->get(\'_route\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (false !== strpos($routeName, \'edit\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$parameters = $this->getViewQuickNavParameters(\'\', []);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($parameters as $k => $v) {");
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("        ");
        _builder.append("if ($k == \'catId\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// single category filter");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("if ($v > 0) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$qb->andWhere(\'tblCategories.category = :category\')");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("           ");
        _builder.append("->setParameter(\'category\', $v);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("} elseif ($k == \'catIdList\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// multi category filter");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("/* old");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$qb->andWhere(\'tblCategories.category IN (:categories)\')");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("       ");
        _builder.append("->setParameter(\'categories\', $v);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("     ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$categoryHelper = \\ServiceUtil::get(\'");
        String _appService = this._utils.appService(this.app);
        _builder.append(_appService, "            ");
        _builder.append(".category_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$qb = $categoryHelper->buildFilterClauses($qb, \'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "            ");
        _builder.append("\', $v);");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    {
      boolean _isCategorisable_1 = it.isCategorisable();
      if (_isCategorisable_1) {
        _builder.append("} else");
      }
    }
    _builder.append("if (in_array($k, [\'q\', \'searchterm\'])) {");
    _builder.newLineIfNotEmpty();
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
        _builder.append("} elseif (in_array($k, [");
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
            String _formatForCode_1 = this._formattingExtensions.formatForCode(field.getName());
            _builder.append(_formatForCode_1, "        ");
            _builder.append("\'");
          }
        }
        _builder.append("])) {");
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
    _builder.append("} else if (!is_array($v)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// field filter");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ((!is_numeric($v) && $v != \'\') || (is_numeric($v) && $v > 0)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if ($k == \'workflowState\' && substr($v, 0, 1) == \'!\') {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$qb->andWhere(\'tbl.\' . $k . \' != :\' . $k)");
    _builder.newLine();
    _builder.append("                       ");
    _builder.append("->setParameter($k, substr($v, 1, strlen($v)-1));");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} elseif (substr($v, 0, 1) == \'%\') {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$qb->andWhere(\'tbl.\' . $k . \' LIKE :\' . $k)");
    _builder.newLine();
    _builder.append("                       ");
    _builder.append("->setParameter($k, \'%\' . $v . \'%\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} else {");
    _builder.newLine();
    {
      boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity) {
        _builder.append("                    ");
        _builder.append("if (in_array($k, [\'");
        final Function1<UserField, String> _function = (UserField it_1) -> {
          return this._formattingExtensions.formatForCode(it_1.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<UserField, String>map(this._modelExtensions.getUserFieldsEntity(it), _function), "\', \'");
        _builder.append(_join, "                    ");
        _builder.append("\'])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("                    ");
        _builder.append("    ");
        _builder.append("$qb->leftJoin(\'tbl.\' . $k, \'tbl\' . ucfirst($k))");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("       ");
        _builder.append("->andWhere(\'tbl\' . ucfirst($k) . \'.uid = :\' . $k)");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("       ");
        _builder.append("->setParameter($k, $v);");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("    ");
        _builder.append("$qb->andWhere(\'tbl.\' . $k . \' = :\' . $k)");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("       ");
        _builder.append("->setParameter($k, $v);");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("                    ");
        _builder.append("$qb->andWhere(\'tbl.\' . $k . \' = :\' . $k)");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("   ");
        _builder.append("->setParameter($k, $v);");
        _builder.newLine();
      }
    }
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
    _builder.append("* @param QueryBuilder $qb         Query builder to be enhanced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array        $parameters List of determined filter options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder Enriched query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function applyDefaultFilters(QueryBuilder $qb, $parameters = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasVisibleWorkflow = this._workflowExtensions.hasVisibleWorkflow(it);
      if (_hasVisibleWorkflow) {
        _builder.append("    ");
        _builder.append("if (null === $this->getRequest()) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->request = \\ServiceUtil::get(\'request_stack\')->getCurrentRequest();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$routeName = $this->request->get(\'_route\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$isAdminArea = false !== strpos($routeName, \'");
        String _lowerCase = this._utils.appName(this.app).toLowerCase();
        _builder.append(_lowerCase, "    ");
        _builder.append("_");
        String _lowerCase_1 = this._formattingExtensions.formatForDisplay(it.getName()).toLowerCase();
        _builder.append(_lowerCase_1, "    ");
        _builder.append("_admin\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("if ($isAdminArea) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $qb;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!in_array(\'workflowState\', array_keys($parameters)) || empty($parameters[\'workflowState\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// per default we show approved ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay, "        ");
        _builder.append(" only");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$onlineStates = [\'approved\'];");
        _builder.newLine();
        {
          boolean _isOwnerPermission = it.isOwnerPermission();
          if (_isOwnerPermission) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$showOnlyOwnEntries = $this->getRequest()->query->getInt(\'own\', 0);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if ($showOnlyOwnEntries == 1) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("// allow the owner to see his deferred ");
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
            _builder.append(_formatForDisplay_1, "            ");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$onlineStates[] = \'deferred\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$qb->andWhere(\'tbl.workflowState IN (:onlineStates)\')");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("->setParameter(\'onlineStates\', $onlineStates);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
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
      if ((null != startDateField)) {
        _builder.append("$startDate = null !== $this->getRequest() ? $this->getRequest()->query->get(\'");
        String _formatForCode = this._formattingExtensions.formatForCode(startDateField.getName());
        _builder.append(_formatForCode);
        _builder.append("\', ");
        CharSequence _defaultValueForNow = this.defaultValueForNow(startDateField);
        _builder.append(_defaultValueForNow);
        _builder.append(") : ");
        CharSequence _defaultValueForNow_1 = this.defaultValueForNow(startDateField);
        _builder.append(_defaultValueForNow_1);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("$qb->andWhere(\'");
        CharSequence _whereClauseForDateRangeFilter = this.whereClauseForDateRangeFilter(it, "<=", startDateField, "startDate");
        _builder.append(_whereClauseForDateRangeFilter);
        _builder.append("\')");
        _builder.newLineIfNotEmpty();
        _builder.append("   ");
        _builder.append("->setParameter(\'startDate\', $startDate);");
        _builder.newLine();
      }
    }
    {
      if ((null != endDateField)) {
        _builder.append("$endDate = null !== $this->getRequest() ? $this->getRequest()->query->get(\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(endDateField.getName());
        _builder.append(_formatForCode_1);
        _builder.append("\', ");
        CharSequence _defaultValueForNow_2 = this.defaultValueForNow(endDateField);
        _builder.append(_defaultValueForNow_2);
        _builder.append(") : ");
        CharSequence _defaultValueForNow_3 = this.defaultValueForNow(endDateField);
        _builder.append(_defaultValueForNow_3);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("$qb->andWhere(\'");
        CharSequence _whereClauseForDateRangeFilter_1 = this.whereClauseForDateRangeFilter(it, ">=", endDateField, "endDate");
        _builder.append(_whereClauseForDateRangeFilter_1);
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
      final String dateFieldName = this._formattingExtensions.formatForCode(dateField.getName());
      CharSequence _xifexpression = null;
      boolean _isMandatory = dateField.isMandatory();
      if (_isMandatory) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("tbl.");
        _builder.append(dateFieldName);
        _builder.append(" ");
        _builder.append(operator);
        _builder.append(" :");
        _builder.append(paramName);
        _xifexpression = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("(tbl.");
        _builder_1.append(dateFieldName);
        _builder_1.append(" ");
        _builder_1.append(operator);
        _builder_1.append(" :");
        _builder_1.append(paramName);
        _builder_1.append(" OR tbl.");
        _builder_1.append(dateFieldName);
        _builder_1.append(" IS NULL)");
        _xifexpression = _builder_1;
      }
      _xblockexpression = _xifexpression;
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
    _builder.append("* @param string  $fragment       The fragment to search for");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $exclude        List with identifiers to be excluded from search");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $currentPage    Where to start selection");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $resultsPerPage Amount of items to select");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins       Whether to include joining related objects (optional) (default=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array with retrieved collection and amount of total records affected by this query");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectSearch($fragment = \'\', $exclude = [], $orderBy = \'\', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getListQueryBuilder(\'\', $orderBy, $useJoins);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (count($exclude) > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb = $this->addExclusion($qb, $exclude);");
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
    _builder.append("$query = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->retrieveCollectionResult($query, $orderBy, true);");
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
    _builder.append("* @param QueryBuilder $qb       Query builder to be enhanced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string       $fragment The fragment to search for");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder Enriched query builder instance");
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
    _builder.append("$filters = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$parameters = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
      return Boolean.valueOf(this.isContainedInSearch(it_1));
    };
    final Iterable<DerivedField> searchFields = IterableExtensions.<DerivedField>filter(this._modelExtensions.getDisplayFields(it), _function);
    _builder.newLineIfNotEmpty();
    {
      for(final DerivedField field : searchFields) {
        _builder.append("    ");
        _builder.append("$filters[] = \'tbl.");
        String _formatForCode = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append(" ");
        {
          boolean _isTextSearch = this.isTextSearch(field);
          if (_isTextSearch) {
            _builder.append("LIKE");
          } else {
            _builder.append("=");
          }
        }
        _builder.append(" :search");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(field.getName());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$parameters[\'search");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(field.getName());
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("\'] = ");
        {
          boolean _isTextSearch_1 = this.isTextSearch(field);
          if (_isTextSearch_1) {
            _builder.append("\'%\' . $fragment . \'%\'");
          } else {
            _builder.append("$fragment");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->andWhere(\'(\' . implode(\' OR \', $filters) . \')\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($parameters as $parameterName => $parameterValue) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->setParameter($parameterName, $parameterValue);");
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
  
  private CharSequence retrieveCollectionResult(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Performs a given database selection and post-processed the results.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Query   $query       The Query instance to be executed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy     The order-by clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $isPaginated Whether the given query uses a paginator or not (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array with retrieved collection and (for paginated queries) the amount of total records affected");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function retrieveCollectionResult(Query $query, $orderBy = \'\', $isPaginated = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$count = 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$isPaginated) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = $query->getResult();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    {
      boolean _not = (!(IterableExtensions.isEmpty(Iterables.<JoinRelationship>filter(it.getOutgoing(), JoinRelationship.class)) && IterableExtensions.isEmpty(Iterables.<JoinRelationship>filter(it.getIncoming(), JoinRelationship.class))));
      if (_not) {
        _builder.append("        ");
        _builder.append("$paginator = new Paginator($query, true);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$paginator = new Paginator($query, false);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$count = count($paginator);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = $paginator;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$isPaginated) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return [$result, $count];");
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
    _builder.append("* @param string  $where    The where clause to use when retrieving the object count (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder Created query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getCountQuery($where = \'\', $useJoins = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selection = \'COUNT(tbl.");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCode, "    ");
    _builder.append(") AS num");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getNameMultiple());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (true === $useJoins) {");
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
    _builder.append("if (true === $useJoins) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addJoinsToFrom($qb);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->genericBaseQueryAddWhere($qb, $where);");
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
    _builder.append("* @param string  $where      The where clause to use when retrieving the object count (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins   Whether to include joining related objects (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $parameters List of determined filter options");
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
    _builder.append("public function selectCount($where = \'\', $useJoins = false, $parameters = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getCountQuery($where, $useJoins);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->applyDefaultFilters($qb, $parameters);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    {
      boolean _hasPessimisticReadLock = this._modelExtensions.hasPessimisticReadLock(it);
      if (_hasPessimisticReadLock) {
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
        _builder.append(_lockTypeAsConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
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
    _builder.append("* @param string  $fieldName  The name of the property to be checked");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $fieldValue The value of the property to be checked");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $excludeId  Id of ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" to exclude (optional)");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean result of this check, true if the given ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
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
    _builder.append("->setParameter($fieldName, $fieldValue);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->addExclusion($qb, [$excludeId]);");
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
        String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
        _builder.append(_lockTypeAsConstant, "    ");
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
  
  private CharSequence genericBaseQuery(final Entity it) {
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
    _builder.append("* @param string  $where    The where clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder query builder instance to be further processed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function genericBaseQuery($where = \'\', $orderBy = \'\', $useJoins = true, $slimMode = false)");
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
    _builder.append("if (true === $slimMode) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// but for the slim version we select only the basic fields, and no joins");
    _builder.newLine();
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
        String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode, "        ");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _addSelectionPartsForDisplayPattern = this.addSelectionPartsForDisplayPattern(it);
    _builder.append(_addSelectionPartsForDisplayPattern, "        ");
    _builder.newLineIfNotEmpty();
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
    _builder.append("if (true === $useJoins) {");
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
    _builder.append("if (true === $useJoins) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addJoinsToFrom($qb);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->genericBaseQueryAddWhere($qb, $where);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->genericBaseQueryAddOrderBy($qb, $orderBy);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addSelectionPartsForDisplayPattern(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final String[] patternParts = it.getDisplayPattern().split("#");
    _builder.newLineIfNotEmpty();
    {
      for(final String patternPart : patternParts) {
        _builder.newLine();
        final Function1<EntityField, Boolean> _function = (EntityField it_1) -> {
          String _name = it_1.getName();
          return Boolean.valueOf(Objects.equal(_name, patternPart));
        };
        Iterable<EntityField> matchedFields = IterableExtensions.<EntityField>filter(it.getFields(), _function);
        _builder.newLineIfNotEmpty();
        {
          if (((!IterableExtensions.isEmpty(matchedFields)) || (it.isGeographical() && (Objects.equal(patternPart, "latitude") || Objects.equal(patternPart, "longitude"))))) {
            _builder.append("$selection .= \', tbl.");
            String _formatForCode = this._formattingExtensions.formatForCode(patternPart);
            _builder.append(_formatForCode);
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence genericBaseQueryWhere(final Entity it) {
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
    _builder.append("* @param QueryBuilder $qb    Given query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string       $where The where clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder query builder instance to be further processed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function genericBaseQueryAddWhere(QueryBuilder $qb, $where = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($where) || null !== $this->getRequest()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Use FilterUtil to support generic filtering.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Create filter configuration.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filterConfig = new FilterConfig($qb);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Define plugins to be used during filtering.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filterPluginManager = new FilterPluginManager(");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$filterConfig,");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Array of plugins to load.");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// If no plugin with default = true given the compare plugin is loaded and used for unconfigured fields.");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Multiple objects of the same plugin with different configurations are possible.");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("[");
    _builder.newLine();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<AbstractDateField>filter(it.getFields(), AbstractDateField.class));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("                ");
        _builder.append("new DateFilter([");
        {
          Iterable<AbstractDateField> _filter = Iterables.<AbstractDateField>filter(it.getFields(), AbstractDateField.class);
          boolean _hasElements = false;
          for(final AbstractDateField field : _filter) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "                ");
            }
            _builder.append("\'");
            String _formatForCode = this._formattingExtensions.formatForCode(field.getName());
            _builder.append(_formatForCode, "                ");
            _builder.append("\'");
          }
        }
        _builder.append("/*, \'tblJoin.someJoinedField\'*/])");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("            ");
    _builder.append("],");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Allowed operators per field.");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Array in the form \"field name => operator array\".");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// If a field is not set in this array all operators are allowed.");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("[]");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(");");
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// add category plugins dynamically for all existing registry properties");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// we need to create one category plugin instance for each one");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$categoryHelper = \\ServiceUtil::get(\'");
        String _appService = this._utils.appService(this.app);
        _builder.append(_appService, "        ");
        _builder.append(".category_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$categoryProperties = $categoryHelper->getAllProperties(\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "        ");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("foreach ($categoryProperties as $propertyName => $registryId) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$config[\'plugins\'][] = new CategoryFilter(\'");
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "            ");
        _builder.append("\', $propertyName, \'categories\' . ucfirst($propertyName));");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Name of filter variable(s) (filterX).");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filterKey = \'filter\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// initialise FilterUtil and assign both query builder and configuration");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filterUtil = new FilterUtil($filterPluginManager, $this->getRequest(), $filterKey);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// set our given filter");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!empty($where)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$filterUtil->setFilter($where);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// you could add explicit filters at this point, something like");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// $filterUtil->addFilter(\'foo:eq:something,bar:gt:100\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// read more at https://github.com/zikula/core/tree/");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("1.5/src/docs");
      } else {
        _builder.append("1.4/src/docs/Core-2.0");
      }
    }
    _builder.append("/FilterUtil");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// now enrich the query builder");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filterUtil->enrichQuery();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (null === $this->getRequest()) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// if no request is set we return (#783)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $qb;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$showOnlyOwnEntries = $this->getRequest()->query->getInt(\'own\', 0);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($showOnlyOwnEntries == 1) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$userId = $this->getRequest()->getSession()->get(\'uid\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$qb->andWhere(\'tbl.createdBy = :creator\')");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("->setParameter(\'creator\', $userId);");
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
  
  private CharSequence genericBaseQueryOrderBy(final Entity it) {
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
    _builder.append("* @param QueryBuilder $qb      Given query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string       $orderBy The order-by clause to use when retrieving the collection (optional) (default=\'\')");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder query builder instance to be further processed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function genericBaseQueryAddOrderBy(QueryBuilder $qb, $orderBy = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($orderBy == \'RAND()\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// random selection");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->addSelect(\'MOD(tbl.");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCode, "        ");
    _builder.append(", \' . mt_rand(2, 15) . \') AS HIDDEN randomIdentifiers\')");
    _builder.newLineIfNotEmpty();
    _builder.append("           ");
    _builder.append("->add(\'orderBy\', \'randomIdentifiers\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$orderBy = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif (empty($orderBy)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$orderBy = $this->defaultSortingField;");
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
    _builder.append("if (false === strpos($orderBy, \'.\')) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$orderBy = \'tbl.\' . $orderBy;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("        ");
        _builder.append("if (false !== strpos($orderBy, \'tbl.createdBy\')) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$qb->addSelect(\'tblCreator\')");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("       ");
        _builder.append("->leftJoin(\'tbl.createdBy\', \'tblCreator\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$orderBy = str_replace(\'tbl.createdBy\', \'tblCreator.uname\', $orderBy);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (false !== strpos($orderBy, \'tbl.updatedBy\')) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$qb->addSelect(\'tblUpdater\')");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("       ");
        _builder.append("->leftJoin(\'tbl.updatedBy\', \'tblUpdater\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$orderBy = str_replace(\'tbl.updatedBy\', \'tblUpdater.uname\', $orderBy);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
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
    _builder.append("* @param QueryBuilder $qb Query builder instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Query query instance to be further processed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getQueryFromBuilder(QueryBuilder $qb)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$featureActivationHelper = \\ServiceUtil::get(\'");
        String _appService = this._utils.appService(this.app);
        _builder.append(_appService, "    ");
        _builder.append(".feature_activation_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("if ($featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, \'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// set the translation query hint");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$query->setHint(");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("Query::HINT_CUSTOM_OUTPUT_WALKER,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'Gedmo\\\\Translatable\\\\Query\\\\TreeWalker\\\\TranslationWalker\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append(");");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasPessimisticReadLock = this._modelExtensions.hasPessimisticReadLock(it);
      if (_hasPessimisticReadLock) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
        _builder.append(_lockTypeAsConstant, "    ");
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
    if (it instanceof DerivedField) {
      _matched=true;
      CharSequence _xblockexpression = null;
      {
        final Function1<JoinRelationship, Boolean> _function = (JoinRelationship e) -> {
          String _formatForDB = this._formattingExtensions.formatForDB(IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(this._modelJoinExtensions.getSourceFields(e)))));
          String _formatForDB_1 = this._formattingExtensions.formatForDB(((DerivedField)it).getName());
          return Boolean.valueOf(Objects.equal(_formatForDB, _formatForDB_1));
        };
        final Iterable<JoinRelationship> joins = IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(((DerivedField)it).getEntity().getIncoming(), JoinRelationship.class), _function);
        CharSequence _xifexpression = null;
        boolean _isEmpty = IterableExtensions.isEmpty(joins);
        boolean _not = (!_isEmpty);
        if (_not) {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("\'");
          String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<JoinRelationship>head(joins).getSource().getName());
          _builder.append(_formatForCode);
          _builder.append("\',");
          _builder.newLineIfNotEmpty();
          _xifexpression = _builder;
        } else {
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append("\'");
          String _formatForCode_1 = this._formattingExtensions.formatForCode(((DerivedField)it).getName());
          _builder_1.append(_formatForCode_1);
          _builder_1.append("\',");
          _builder_1.newLineIfNotEmpty();
          _xifexpression = _builder_1;
        }
        _xblockexpression = _xifexpression;
      }
      _switchResult = _xblockexpression;
    }
    if (!_matched) {
      if (it instanceof CalculatedField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\'");
        String _formatForCode = this._formattingExtensions.formatForCode(((CalculatedField)it).getName());
        _builder.append(_formatForCode);
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    return _switchResult;
  }
  
  private boolean isContainedInSearch(final DerivedField it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (it instanceof BooleanField) {
      _matched=true;
      _switchResult = false;
    }
    if (!_matched) {
      if (it instanceof UserField) {
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      _switchResult = true;
    }
    return _switchResult;
  }
  
  private boolean isTextSearch(final DerivedField it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (it instanceof StringField) {
      _matched=true;
      _switchResult = true;
    }
    if (!_matched) {
      if (it instanceof TextField) {
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
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("\'createdBy\',");
        _builder.newLine();
        _builder.append("\'createdDate\',");
        _builder.newLine();
        _builder.append("\'updatedBy\',");
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
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" becoming archived.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool If everything went right or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param PermissionApi");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append("       $permissionApi  PermissionApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @param Session             $session        Session service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param WorkflowHelper      $workflowHelper WorkflowHelper service instance");
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append(" ");
        _builder.append("* @param HookHelper          $hookHelper     HookHelper service instance");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if workflow action execution fails");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function archiveObjects(PermissionApi");
    {
      Boolean _targets_1 = this._utils.targets(this.app, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $permissionApi, SessionInterface $session, TranslatorInterface $translator, WorkflowHelper $workflowHelper");
    {
      boolean _isSkipHookSubscribers_1 = it.isSkipHookSubscribers();
      boolean _not_1 = (!_isSkipHookSubscribers_1);
      if (_not_1) {
        _builder.append(", HookHelper $hookHelper");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (true !== $session->get(\'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "    ");
    _builder.append("AutomaticArchiving\', false) && !$permissionApi->hasPermission(\'");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1, "    ");
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
    _builder.append("if (null == $this->getRequest()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// return as no request is given");
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
    _builder.append("$qb = $this->genericBaseQuery(\'\', \'\', false);");
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
    String _formatForCode = this._formattingExtensions.formatForCode(endField.getName());
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
    _builder.append("$action = \'archive\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($affectedEntities as $entity) {");
    _builder.newLine();
    {
      Boolean _targets_2 = this._utils.targets(this.app, "1.5");
      boolean _not_2 = (!(_targets_2).booleanValue());
      if (_not_2) {
        _builder.append("        ");
        _builder.append("$entity->initWorkflow();");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _isSkipHookSubscribers_2 = it.isSkipHookSubscribers();
      boolean _not_3 = (!_isSkipHookSubscribers_2);
      if (_not_3) {
        _builder.append("        ");
        _builder.append("// Let any hooks perform additional validation actions");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$validationHooksPassed = $hookHelper->callValidationHooks($entity, \'validate_edit\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (!$validationHooksPassed) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
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
    _builder.append("$flashBag = $session->getFlashBag();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$flashBag->add(\'error\', $translator->__f(\'Sorry, but an error occured during the %action% action. Please apply the changes again!\', [\'%action%\' => $action]) . \'  \' . $e->getMessage());");
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
    {
      boolean _isSkipHookSubscribers_3 = it.isSkipHookSubscribers();
      boolean _not_4 = (!_isSkipHookSubscribers_3);
      if (_not_4) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// Let any hooks know that we have updated an item");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$urlArgs = $entity->createUrlArgs();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$urlArgs[\'_locale\'] = $this->request->getLocale();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$url = new RouteUrl(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
        _builder.append(_formatForDB, "        ");
        _builder.append("_");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "        ");
        _builder.append("_display\', $urlArgs);");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$hookHelper->callProcessHooks($entity, \'process_edit\', $url);");
        _builder.newLine();
      }
    }
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
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Repository;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Repository\\");
    {
      boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting) {
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._modelInheritanceExtensions.parentType(it).getName());
        _builder.append(_formatForCodeCapital);
      } else {
        _builder.append("Base\\Abstract");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1);
      }
    }
    _builder.append("Repository;");
    _builder.newLineIfNotEmpty();
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
    _builder.append("* This is the concrete repository class for ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Repository extends ");
    {
      boolean _isInheriting_1 = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting_1) {
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(this._modelInheritanceExtensions.parentType(it).getName());
        _builder.append(_formatForCodeCapital_3);
      } else {
        _builder.append("Abstract");
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_4);
      }
    }
    _builder.append("Repository");
    _builder.newLineIfNotEmpty();
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
