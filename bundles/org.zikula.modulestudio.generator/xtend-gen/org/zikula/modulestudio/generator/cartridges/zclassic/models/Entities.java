package org.zikula.modulestudio.generator.cartridges.zclassic.models;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityChangeTrackingPolicy;
import de.guite.modulestudio.metamodel.EntityIndex;
import de.guite.modulestudio.metamodel.EntityIndexItem;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.InheritanceRelationship;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.MappedSuperClass;
import java.util.Arrays;
import java.util.function.Consumer;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ListEntryValidator;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Association;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityConstructor;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityMethods;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityWorkflowTrait;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ExtensionManager;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.GeographicalTrait;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.StandardFieldsTrait;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.event.LifecycleListener;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Entities {
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
  
  private FileHelper fh = new FileHelper();
  
  private Association thAssoc = new Association();
  
  private ExtensionManager extMan;
  
  private Property thProp;
  
  /**
   * Entry point for Doctrine entity classes.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    final Consumer<DataObject> _function = (DataObject e) -> {
      this.generate(e, it, fsa);
    };
    it.getEntities().forEach(_function);
    new LifecycleListener().generate(it, fsa);
    new EntityWorkflowTrait().generate(it, fsa);
    boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
    if (_hasGeographical) {
      final Function1<Entity, Boolean> _function_1 = (Entity it_1) -> {
        return Boolean.valueOf(it_1.isLoggable());
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelBehaviourExtensions.getGeographicalEntities(it), _function_1));
      boolean _not = (!_isEmpty);
      if (_not) {
        new GeographicalTrait().generate(it, fsa, Boolean.valueOf(true));
      }
      final Function1<Entity, Boolean> _function_2 = (Entity it_1) -> {
        boolean _isLoggable = it_1.isLoggable();
        return Boolean.valueOf((!_isLoggable));
      };
      boolean _isEmpty_1 = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelBehaviourExtensions.getGeographicalEntities(it), _function_2));
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        new GeographicalTrait().generate(it, fsa, Boolean.valueOf(false));
      }
    }
    boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
    if (_hasStandardFieldEntities) {
      final Function1<Entity, Boolean> _function_3 = (Entity it_1) -> {
        return Boolean.valueOf(it_1.isLoggable());
      };
      boolean _isEmpty_2 = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelBehaviourExtensions.getStandardFieldEntities(it), _function_3));
      boolean _not_2 = (!_isEmpty_2);
      if (_not_2) {
        new StandardFieldsTrait().generate(it, fsa, Boolean.valueOf(true));
      }
      final Function1<Entity, Boolean> _function_4 = (Entity it_1) -> {
        boolean _isLoggable = it_1.isLoggable();
        return Boolean.valueOf((!_isLoggable));
      };
      boolean _isEmpty_3 = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelBehaviourExtensions.getStandardFieldEntities(it), _function_4));
      boolean _not_3 = (!_isEmpty_3);
      if (_not_3) {
        new StandardFieldsTrait().generate(it, fsa, Boolean.valueOf(false));
      }
    }
    boolean _hasListFields = this._modelExtensions.hasListFields(it);
    if (_hasListFields) {
      new ListEntryValidator().generate(it, fsa);
    }
    Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      {
        ExtensionManager _extensionManager = new ExtensionManager(entity);
        this.extMan = _extensionManager;
        this.extMan.extensionClasses(fsa);
      }
    }
  }
  
  /**
   * Creates an entity class file for every Entity instance.
   */
  private void generate(final DataObject it, final Application app, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating entity classes for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    if ((it instanceof Entity)) {
      ExtensionManager _extensionManager = new ExtensionManager(((Entity)it));
      this.extMan = _extensionManager;
    }
    Property _property = new Property(this.extMan);
    this.thProp = _property;
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(app);
    final String entityPath = (_appSourceLibPath + "Entity/");
    final String entityClassSuffix = "Entity";
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    final String entityFileName = (_formatForCodeCapital + entityClassSuffix);
    String fileName = "";
    boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
    boolean _not = (!_isInheriting);
    if (_not) {
      fileName = (("Abstract" + entityFileName) + ".php");
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(app, ((entityPath + "Base/") + fileName));
      boolean _not_1 = (!_shouldBeSkipped);
      if (_not_1) {
        boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(app, ((entityPath + "Base/") + fileName));
        if (_shouldBeMarked) {
          fileName = (entityFileName + ".generated.php");
        }
        fsa.generateFile(((entityPath + "Base/") + fileName), this.fh.phpFileContent(app, this.modelEntityBaseImpl(it, app)));
      }
    }
    fileName = (entityFileName + ".php");
    if (((!this._generatorSettingsExtensions.generateOnlyBaseClasses(app)) && (!this._namingExtensions.shouldBeSkipped(app, (entityPath + fileName))))) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(app, (entityPath + fileName));
      if (_shouldBeMarked_1) {
        fileName = (entityFileName + ".generated.php");
      }
      fsa.generateFile((entityPath + fileName), this.fh.phpFileContent(app, this.modelEntityImpl(it, app)));
    }
  }
  
  private CharSequence _imports(final MappedSuperClass it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use Doctrine\\ORM\\Mapping as ORM;");
    _builder.newLine();
    {
      if (((isBase).booleanValue() && this._modelJoinExtensions.hasCollections(it))) {
        _builder.append("use Doctrine\\Common\\Collections\\ArrayCollection;");
        _builder.newLine();
      }
    }
    {
      if ((isBase).booleanValue()) {
        _builder.append("use Gedmo\\Mapping\\Annotation as Gedmo;");
        _builder.newLine();
      }
    }
    {
      if ((isBase).booleanValue()) {
        {
          boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
          if (_hasUploadFieldsEntity) {
            _builder.append("use Symfony\\Component\\HttpFoundation\\File\\File;");
            _builder.newLine();
          }
        }
        _builder.append("use Symfony\\Component\\Validator\\Constraints as Assert;");
        _builder.newLine();
      }
    }
    {
      if ((((!IterableExtensions.isEmpty(IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(it), ((Function1<DerivedField, Boolean>) (DerivedField it_1) -> {
        boolean _isPrimaryKey = it_1.isPrimaryKey();
        return Boolean.valueOf((!_isPrimaryKey));
      })))) || (!IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelations(it), ((Function1<JoinRelationship, Boolean>) (JoinRelationship it_1) -> {
        return Boolean.valueOf(it_1.isUnique());
      }))))) || (!IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), ((Function1<JoinRelationship, Boolean>) (JoinRelationship it_1) -> {
        return Boolean.valueOf(it_1.isUnique());
      })))))) {
        _builder.append("use Symfony\\Bridge\\Doctrine\\Validator\\Constraints\\UniqueEntity;");
        _builder.newLine();
      }
    }
    {
      if ((isBase).booleanValue()) {
        {
          boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
          if (_hasUserFieldsEntity) {
            _builder.append("use Zikula\\UsersModule\\Entity\\UserEntity;");
            _builder.newLine();
          }
        }
        {
          Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
          boolean _not = (!(_targets).booleanValue());
          if (_not) {
            _builder.append("use ");
            String _appNamespace = this._utils.appNamespace(it.getApplication());
            _builder.append(_appNamespace);
            _builder.append("\\Traits\\EntityWorkflowTrait;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
          if (_hasListFieldsEntity) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it.getApplication());
            _builder.append(_appNamespace_1);
            _builder.append("\\Validator\\Constraints as ");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
            _builder.append(_formatForCodeCapital);
            _builder.append("Assert;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _imports(final Entity it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use Doctrine\\ORM\\Mapping as ORM;");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        {
          if (((this._modelJoinExtensions.hasCollections(it) || it.isAttributable()) || it.isCategorisable())) {
            _builder.append("use Doctrine\\Common\\Collections\\ArrayCollection;");
            _builder.newLine();
          }
        }
      }
    }
    {
      if (((((isBase).booleanValue() || it.isLoggable()) || this._modelBehaviourExtensions.hasTranslatableFields(it)) || (!Objects.equal(it.getTree(), EntityTreeType.NONE)))) {
        _builder.append("use Gedmo\\Mapping\\Annotation as Gedmo;");
        _builder.newLine();
      }
    }
    {
      if ((isBase).booleanValue()) {
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
          boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
          if (_hasTranslatableFields) {
            _builder.append("use Gedmo\\Translatable\\Translatable;");
            _builder.newLine();
          }
        }
        {
          boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
          if (_hasUploadFieldsEntity) {
            _builder.append("use Symfony\\Component\\HttpFoundation\\File\\File;");
            _builder.newLine();
          }
        }
        _builder.append("use Symfony\\Component\\Validator\\Constraints as Assert;");
        _builder.newLine();
      }
    }
    {
      if ((((((!IterableExtensions.isEmpty(IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(it), ((Function1<DerivedField, Boolean>) (DerivedField it_1) -> {
        boolean _isPrimaryKey = it_1.isPrimaryKey();
        return Boolean.valueOf((!_isPrimaryKey));
      })))) || (this._modelBehaviourExtensions.hasSluggableFields(it) && it.isSlugUnique())) || (!IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelations(it), ((Function1<JoinRelationship, Boolean>) (JoinRelationship it_1) -> {
        return Boolean.valueOf(it_1.isUnique());
      }))))) || (!IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), ((Function1<JoinRelationship, Boolean>) (JoinRelationship it_1) -> {
        return Boolean.valueOf(it_1.isUnique());
      }))))) || (!IterableExtensions.isEmpty(this._modelExtensions.getUniqueIndexes(it))))) {
        _builder.append("use Symfony\\Bridge\\Doctrine\\Validator\\Constraints\\UniqueEntity;");
        _builder.newLine();
      }
    }
    {
      if ((isBase).booleanValue()) {
        _builder.append("use Zikula\\Core\\Doctrine\\EntityAccess;");
        _builder.newLine();
        {
          boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
          if (_hasUserFieldsEntity) {
            _builder.append("use Zikula\\UsersModule\\Entity\\UserEntity;");
            _builder.newLine();
          }
        }
        {
          Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
          boolean _not = (!(_targets).booleanValue());
          if (_not) {
            _builder.append("use ");
            String _appNamespace = this._utils.appNamespace(it.getApplication());
            _builder.append(_appNamespace);
            _builder.append("\\Traits\\EntityWorkflowTrait;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isGeographical = it.isGeographical();
          if (_isGeographical) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it.getApplication());
            _builder.append(_appNamespace_1);
            _builder.append("\\Traits\\");
            {
              boolean _isLoggable = it.isLoggable();
              if (_isLoggable) {
                _builder.append("Loggable");
              }
            }
            _builder.append("GeographicalTrait;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isStandardFields = it.isStandardFields();
          if (_isStandardFields) {
            _builder.append("use ");
            String _appNamespace_2 = this._utils.appNamespace(it.getApplication());
            _builder.append(_appNamespace_2);
            _builder.append("\\Traits\\");
            {
              boolean _isLoggable_1 = it.isLoggable();
              if (_isLoggable_1) {
                _builder.append("Loggable");
              }
            }
            _builder.append("StandardFieldsTrait;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
          if (_hasListFieldsEntity) {
            _builder.append("use ");
            String _appNamespace_3 = this._utils.appNamespace(it.getApplication());
            _builder.append(_appNamespace_3);
            _builder.append("\\Validator\\Constraints as ");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
            _builder.append(_formatForCodeCapital);
            _builder.append("Assert;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence modelEntityBaseImpl(final DataObject it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _imports = this.imports(it, Boolean.valueOf(true));
    _builder.append(_imports);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _modelEntityBaseImplClass = this.modelEntityBaseImplClass(it, app);
    _builder.append(_modelEntityBaseImplClass);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelEntityBaseImplClass(final DataObject it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
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
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* The following annotation marks it as a mapped superclass so subclasses");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* inherit orm properties.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\MappedSuperclass");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @abstract");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Entity extends EntityAccess");
    {
      if (((it instanceof Entity) && (this._modelExtensions.hasNotifyPolicy(((Entity) it)) || this._modelBehaviourExtensions.hasTranslatableFields(((Entity) it))))) {
        _builder.append(" implements");
        {
          boolean _hasNotifyPolicy = this._modelExtensions.hasNotifyPolicy(((Entity) it));
          if (_hasNotifyPolicy) {
            _builder.append(" NotifyPropertyChanged");
          }
        }
        {
          boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(((Entity) it));
          if (_hasTranslatableFields) {
            {
              boolean _hasNotifyPolicy_1 = this._modelExtensions.hasNotifyPolicy(((Entity) it));
              if (_hasNotifyPolicy_1) {
                _builder.append(",");
              }
            }
            _builder.append(" Translatable");
          }
        }
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Hook entity workflow field and behaviour.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("use EntityWorkflowTrait;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && ((Entity) it).isGeographical())) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Hook geographical behaviour embedding latitude and longitude fields.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("use ");
        {
          boolean _isLoggable = ((Entity) it).isLoggable();
          if (_isLoggable) {
            _builder.append("Loggable");
          }
        }
        _builder.append("GeographicalTrait;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && ((Entity) it).isStandardFields())) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Hook standard fields behaviour embedding createdBy, updatedBy, createdDate, updatedDate fields.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("use ");
        {
          boolean _isLoggable_1 = ((Entity) it).isLoggable();
          if (_isLoggable_1) {
            _builder.append("Loggable");
          }
        }
        _builder.append("StandardFieldsTrait;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _modelEntityBaseImplBody = this.modelEntityBaseImplBody(it, app);
    _builder.append(_modelEntityBaseImplBody, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence modelEntityBaseImplBody(final DataObject it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _memberVars = this.memberVars(it);
    _builder.append(_memberVars);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((it instanceof Entity)) {
        CharSequence _constructor = new EntityConstructor().constructor(((Entity)it), Boolean.valueOf(false));
        _builder.append(_constructor);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _accessors = this.accessors(it);
    _builder.append(_accessors);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _generate = new EntityMethods().generate(it, app, this.thProp);
    _builder.append(_generate);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence memberVars(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var string The tablename this object maps to");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $_objectType = \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    {
      if (((it instanceof Entity) && this._modelExtensions.hasNotifyPolicy(((Entity) it)))) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Assert\\Type(type=\"array\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var array List of change notification listeners");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $_propertyChangedListeners = [];");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField field : _derivedFields) {
        CharSequence _persistentProperty = this.thProp.persistentProperty(field);
        _builder.append(_persistentProperty);
      }
    }
    _builder.newLineIfNotEmpty();
    CharSequence _additionalProperties = this.extMan.additionalProperties();
    _builder.append(_additionalProperties);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      for(final JoinRelationship relation : _bidirectionalIncomingJoinRelations) {
        CharSequence _generate = this.thAssoc.generate(relation, Boolean.valueOf(false));
        _builder.append(_generate);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      for(final JoinRelationship relation_1 : _outgoingJoinRelations) {
        CharSequence _generate_1 = this.thAssoc.generate(relation_1, Boolean.valueOf(true));
        _builder.append(_generate_1);
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence accessors(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "_objectType", "string", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField field : _derivedFields) {
        CharSequence _fieldAccessor = this.thProp.fieldAccessor(field);
        _builder.append(_fieldAccessor);
      }
    }
    _builder.newLineIfNotEmpty();
    CharSequence _additionalAccessors = this.extMan.additionalAccessors();
    _builder.append(_additionalAccessors);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      for(final JoinRelationship relation : _bidirectionalIncomingJoinRelations) {
        CharSequence _relationAccessor = this.thAssoc.relationAccessor(relation, Boolean.valueOf(false));
        _builder.append(_relationAccessor);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      for(final JoinRelationship relation_1 : _outgoingJoinRelations) {
        CharSequence _relationAccessor_1 = this.thAssoc.relationAccessor(relation_1, Boolean.valueOf(true));
        _builder.append(_relationAccessor_1);
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelEntityImpl(final DataObject it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\");
    {
      boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting) {
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._modelInheritanceExtensions.parentType(it).getName());
        _builder.append(_formatForCodeCapital);
      } else {
        _builder.append("Base\\Abstract");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append("Entity");
      }
    }
    _builder.append(" as BaseEntity;");
    _builder.newLineIfNotEmpty();
    CharSequence _imports = this.imports(it, Boolean.valueOf(this._modelInheritanceExtensions.isInheriting(it)));
    _builder.append(_imports);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _entityImplClassDocblock = this.entityImplClassDocblock(it, app);
    _builder.append(_entityImplClassDocblock);
    _builder.newLineIfNotEmpty();
    _builder.append("class ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Entity extends BaseEntity");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own methods here");
    _builder.newLine();
    {
      boolean _isInheriting_1 = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting_1) {
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
        CharSequence _additionalProperties = this.extMan.additionalProperties();
        _builder.append(_additionalProperties, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        {
          Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
          for(final JoinRelationship relation : _bidirectionalIncomingJoinRelations) {
            CharSequence _generate = this.thAssoc.generate(relation, Boolean.valueOf(false));
            _builder.append(_generate, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        {
          Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
          for(final JoinRelationship relation_1 : _outgoingJoinRelations) {
            CharSequence _generate_1 = this.thAssoc.generate(relation_1, Boolean.valueOf(true));
            _builder.append(_generate_1, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        {
          if ((it instanceof Entity)) {
            _builder.append("    ");
            CharSequence _constructor = new EntityConstructor().constructor(((Entity)it), Boolean.valueOf(true));
            _builder.append(_constructor, "    ");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
          }
        }
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
        CharSequence _additionalAccessors = this.extMan.additionalAccessors();
        _builder.append(_additionalAccessors, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        {
          Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations_1 = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
          for(final JoinRelationship relation_2 : _bidirectionalIncomingJoinRelations_1) {
            CharSequence _relationAccessor = this.thAssoc.relationAccessor(relation_2, Boolean.valueOf(false));
            _builder.append(_relationAccessor, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        {
          Iterable<JoinRelationship> _outgoingJoinRelations_1 = this._modelJoinExtensions.getOutgoingJoinRelations(it);
          for(final JoinRelationship relation_3 : _outgoingJoinRelations_1) {
            CharSequence _relationAccessor_1 = this.thAssoc.relationAccessor(relation_3, Boolean.valueOf(true));
            _builder.append(_relationAccessor_1, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence entityImplClassDocblock(final DataObject it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
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
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    CharSequence _classAnnotations = this.extMan.classAnnotations();
    _builder.append(_classAnnotations, " ");
    _builder.newLineIfNotEmpty();
    {
      if ((it instanceof MappedSuperClass)) {
        _builder.append(" ");
        _builder.append("* @ORM\\MappedSuperclass");
        _builder.newLine();
      } else {
        if ((it instanceof Entity)) {
          _builder.append(" ");
          _builder.append("* @ORM\\Entity(repositoryClass=\"");
          String _appNamespace = this._utils.appNamespace(app);
          _builder.append(_appNamespace, " ");
          _builder.append("\\Entity\\Repository\\");
          String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
          _builder.append(_formatForCodeCapital, " ");
          _builder.append("Repository\"");
          {
            boolean _isReadOnly = ((Entity) it).isReadOnly();
            if (_isReadOnly) {
              _builder.append(", readOnly=true");
            }
          }
          _builder.append(")");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    {
      if ((it instanceof Entity)) {
        CharSequence _entityImplClassDocblockAdditions = this.entityImplClassDocblockAdditions(((Entity)it), app);
        _builder.append(_entityImplClassDocblockAdditions);
        _builder.newLineIfNotEmpty();
      }
    }
    CharSequence _classAnnotations_1 = new ValidationConstraints().classAnnotations(it);
    _builder.append(_classAnnotations_1);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence entityImplClassDocblockAdditions(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isEmpty = it.getIndexes().isEmpty();
      if (_isEmpty) {
        _builder.append(" ");
        _builder.append("* @ORM\\Table(name=\"");
        String _fullEntityTableName = this._modelExtensions.fullEntityTableName(it);
        _builder.append(_fullEntityTableName);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" ");
        _builder.append("* @ORM\\Table(name=\"");
        String _fullEntityTableName_1 = this._modelExtensions.fullEntityTableName(it);
        _builder.append(_fullEntityTableName_1, " ");
        _builder.append("\",");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasNormalIndexes = this._modelExtensions.hasNormalIndexes(it);
          if (_hasNormalIndexes) {
            _builder.append(" ");
            _builder.append("*     indexes={");
            _builder.newLine();
            {
              Iterable<EntityIndex> _normalIndexes = this._modelExtensions.getNormalIndexes(it);
              boolean _hasElements = false;
              for(final EntityIndex index : _normalIndexes) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate(",", "");
                }
                CharSequence _index = this.index(index, "Index");
                _builder.append(_index);
              }
            }
            _builder.newLineIfNotEmpty();
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
            _builder.append("*     uniqueConstraints={");
            _builder.newLine();
            {
              Iterable<EntityIndex> _uniqueIndexes = this._modelExtensions.getUniqueIndexes(it);
              boolean _hasElements_1 = false;
              for(final EntityIndex index_1 : _uniqueIndexes) {
                if (!_hasElements_1) {
                  _hasElements_1 = true;
                } else {
                  _builder.appendImmediate(",", "");
                }
                CharSequence _index_1 = this.index(index_1, "UniqueConstraint");
                _builder.append(_index_1);
              }
            }
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append("*     }");
            _builder.newLine();
          }
        }
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
        String _literal = IterableExtensions.<InheritanceRelationship>head(this._modelInheritanceExtensions.getChildRelations(it)).getStrategy().getLiteral();
        _builder.append(_literal);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @ORM\\DiscriminatorColumn(name=\"");
        String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<InheritanceRelationship>head(this._modelInheritanceExtensions.getChildRelations(it)).getDiscriminatorColumn());
        _builder.append(_formatForCode);
        _builder.append("\"");
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @ORM\\Discriminatormap[{\"");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1);
        _builder.append("\" = \"");
        String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName);
        _builder.append("\"");
        {
          Iterable<InheritanceRelationship> _childRelations = this._modelInheritanceExtensions.getChildRelations(it);
          for(final InheritanceRelationship relation : _childRelations) {
            CharSequence _discriminatorInfo = this.discriminatorInfo(relation);
            _builder.append(_discriminatorInfo);
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
        String _literal_1 = it.getChangeTrackingPolicy().getLiteral();
        _builder.append(_literal_1);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence index(final EntityIndex it, final String indexType) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*         @ORM\\");
    String _firstUpper = StringExtensions.toFirstUpper(indexType);
    _builder.append(_firstUpper);
    _builder.append("(name=\"");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
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
        _builder.append(_indexField);
      }
    }
    _builder.append("})");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence indexField(final EntityIndexItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\"");
    return _builder;
  }
  
  private CharSequence discriminatorInfo(final InheritanceRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(", \"");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getSource().getName());
    _builder.append(_formatForCode);
    _builder.append("\" = \"");
    String _entityClassName = this._namingExtensions.entityClassName(it.getSource(), "", Boolean.valueOf(false));
    _builder.append(_entityClassName);
    _builder.append("\"");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence imports(final DataObject it, final Boolean isBase) {
    if (it instanceof Entity) {
      return _imports((Entity)it, isBase);
    } else if (it instanceof MappedSuperClass) {
      return _imports((MappedSuperClass)it, isBase);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, isBase).toString());
    }
  }
}
