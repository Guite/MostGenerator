package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public abstract class AbstractExtension implements EntityExtensionInterface {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelInheritanceExtensions _modelInheritanceExtensions = new ModelInheritanceExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private Application app;
  
  private String classType = "";
  
  private FileHelper fh = new FileHelper();
  
  protected IFileSystemAccess fsa;
  
  /**
   * Generates separate extension classes.
   */
  @Override
  public void extensionClasses(final Entity it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    String _extensionClassType = this.extensionClassType(it);
    boolean _notEquals = (!Objects.equal(_extensionClassType, ""));
    if (_notEquals) {
      this.extensionClasses(it, this.extensionClassType(it));
    }
  }
  
  /**
   * Single extension class.
   */
  protected void extensionClasses(final Entity it, final String classType) {
    this.app = it.getApplication();
    this.classType = classType;
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    final String entityPath = (_appSourceLibPath + "Entity/");
    final String entitySuffix = "Entity";
    final String repositorySuffix = "Repository";
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(classType);
    String classPrefix = (_formatForCodeCapital + _formatForCodeCapital_1);
    final String repositoryPath = (entityPath + "Repository/");
    String fileName = "";
    boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
    boolean _not = (!_isInheriting);
    if (_not) {
      fileName = ((("Base/Abstract" + classPrefix) + entitySuffix) + ".php");
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(this.app, (entityPath + fileName));
      boolean _not_1 = (!_shouldBeSkipped);
      if (_not_1) {
        boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(this.app, (entityPath + fileName));
        if (_shouldBeMarked) {
          fileName = ((("Base/Abstract" + classPrefix) + entitySuffix) + ".generated.php");
        }
        this.fsa.generateFile((entityPath + fileName), this.fh.phpFileContent(this.app, this.extensionClassBaseImpl(it)));
      }
      fileName = ((("Base/Abstract" + classPrefix) + repositorySuffix) + ".php");
      if (((!Objects.equal(classType, "closure")) && (!this._namingExtensions.shouldBeSkipped(this.app, (repositoryPath + fileName))))) {
        boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(this.app, (repositoryPath + fileName));
        if (_shouldBeMarked_1) {
          fileName = ((("Base/Abstract" + classPrefix) + repositorySuffix) + ".generated.php");
        }
        this.fsa.generateFile((repositoryPath + fileName), this.fh.phpFileContent(this.app, this.extensionClassRepositoryBaseImpl(it)));
      }
    }
    boolean _generateOnlyBaseClasses = this._generatorSettingsExtensions.generateOnlyBaseClasses(this.app);
    boolean _not_2 = (!_generateOnlyBaseClasses);
    if (_not_2) {
      fileName = ((classPrefix + entitySuffix) + ".php");
      boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(this.app, (entityPath + fileName));
      boolean _not_3 = (!_shouldBeSkipped_1);
      if (_not_3) {
        boolean _shouldBeMarked_2 = this._namingExtensions.shouldBeMarked(this.app, (entityPath + fileName));
        if (_shouldBeMarked_2) {
          fileName = ((classPrefix + entitySuffix) + ".generated.php");
        }
        this.fsa.generateFile((entityPath + fileName), this.fh.phpFileContent(this.app, this.extensionClassImpl(it)));
      }
      fileName = ((classPrefix + repositorySuffix) + ".php");
      if (((!Objects.equal(classType, "closure")) && (!this._namingExtensions.shouldBeSkipped(this.app, (repositoryPath + fileName))))) {
        boolean _shouldBeMarked_3 = this._namingExtensions.shouldBeMarked(this.app, (repositoryPath + fileName));
        if (_shouldBeMarked_3) {
          fileName = ((classPrefix + repositorySuffix) + ".generated.php");
        }
        this.fsa.generateFile((repositoryPath + fileName), this.fh.phpFileContent(this.app, this.extensionClassRepositoryImpl(it)));
      }
    }
  }
  
  protected CharSequence extensionClassBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    String _extensionClassImports = this.extensionClassImports(it);
    _builder.append(_extensionClassImports);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _extensionClassDescription = this.extensionClassDescription(it);
    _builder.append(_extensionClassDescription, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the base ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(this.classType);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" class for ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(this.classType);
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Entity extends ");
    String _extensionBaseClass = this.extensionBaseClass(it);
    _builder.append(_extensionBaseClass);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    String _extensionClassBaseAnnotations = this.extensionClassBaseAnnotations(it);
    _builder.append(_extensionClassBaseAnnotations, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * Returns the extension class type.
   */
  @Override
  public String extensionClassType(final Entity it) {
    return "";
  }
  
  /**
   * Returns the extension class import statements.
   */
  @Override
  public String extensionClassImports(final Entity it) {
    return "";
  }
  
  /**
   * Returns the extension base class.
   */
  @Override
  public String extensionBaseClass(final Entity it) {
    return "";
  }
  
  /**
   * Returns the extension class description.
   */
  @Override
  public String extensionClassDescription(final Entity it) {
    return "";
  }
  
  /**
   * Returns the extension base class ORM annotations.
   */
  @Override
  public String extensionClassBaseAnnotations(final Entity it) {
    return "";
  }
  
  protected CharSequence extensionClassEntityAccessors(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get reference to owning entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return \\");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getEntity()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->entity;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Set reference to owning entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param \\");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, " ");
    _builder.append(" $entity");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function setEntity(/*\\");
    String _entityClassName_2 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_2);
    _builder.append(" */$entity)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->entity = $entity;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  protected CharSequence extensionClassImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\");
    {
      boolean _isInheriting = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting) {
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._modelInheritanceExtensions.parentType(it).getName());
        _builder.append(_formatForCodeCapital);
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(this.classType);
        _builder.append(_formatForCodeCapital_1);
        _builder.append("Entity");
      } else {
        _builder.append("Base\\Abstract");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_2);
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(this.classType);
        _builder.append(_formatForCodeCapital_3);
        _builder.append("Entity");
      }
    }
    _builder.append(" as BaseEntity;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\Mapping as ORM;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _extensionClassDescription = this.extensionClassDescription(it);
    _builder.append(_extensionClassDescription, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the concrete ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(this.classType);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" class for ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    String _extensionClassImplAnnotations = this.extensionClassImplAnnotations(it);
    _builder.append(_extensionClassImplAnnotations);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(this.classType);
    _builder.append(_formatForCodeCapital_5);
    _builder.append("Entity extends BaseEntity");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * Returns the extension implementation class ORM annotations.
   */
  @Override
  public String extensionClassImplAnnotations(final Entity it) {
    return "";
  }
  
  protected String repositoryClass(final Entity it, final String classType) {
    String _xblockexpression = null;
    {
      if ((null == this.app)) {
        this.app = it.getApplication();
      }
      String _appNamespace = this._utils.appNamespace(this.app);
      String _plus = (_appNamespace + "\\Entity\\Repository\\");
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
      String _plus_1 = (_plus + _formatForCodeCapital);
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(classType);
      String _plus_2 = (_plus_1 + _formatForCodeCapital_1);
      _xblockexpression = (_plus_2 + "Repository");
    }
    return _xblockexpression;
  }
  
  protected CharSequence extensionClassRepositoryBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Entity\\Repository\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _equals = Objects.equal(this.classType, "translation");
      if (_equals) {
        _builder.append("use Gedmo\\Translatable\\Entity\\Repository\\TranslationRepository;");
        _builder.newLine();
      } else {
        boolean _equals_1 = Objects.equal(this.classType, "logEntry");
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
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(this.classType);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(this.classType);
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Repository extends ");
    {
      boolean _equals_2 = Objects.equal(this.classType, "translation");
      if (_equals_2) {
        _builder.append("Translation");
      } else {
        boolean _equals_3 = Objects.equal(this.classType, "logEntry");
        if (_equals_3) {
          _builder.append("LogEntry");
        } else {
          _builder.append("Entity");
        }
      }
    }
    _builder.append("Repository");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  protected CharSequence extensionClassRepositoryImpl(final Entity it) {
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
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(this.classType);
        _builder.append(_formatForCodeCapital_1);
      } else {
        _builder.append("Base\\Abstract");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_2);
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(this.classType);
        _builder.append(_formatForCodeCapital_3);
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
    _builder.append(" ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(this.classType);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" entities.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(this.classType);
    _builder.append(_formatForCodeCapital_5);
    _builder.append("Repository extends ");
    {
      boolean _isInheriting_1 = this._modelInheritanceExtensions.isInheriting(it);
      if (_isInheriting_1) {
        String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(this._modelInheritanceExtensions.parentType(it).getName());
        _builder.append(_formatForCodeCapital_6);
        String _formatForCodeCapital_7 = this._formattingExtensions.formatForCodeCapital(this.classType);
        _builder.append(_formatForCodeCapital_7);
      } else {
        _builder.append("Abstract");
        String _formatForCodeCapital_8 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_8);
        String _formatForCodeCapital_9 = this._formattingExtensions.formatForCodeCapital(this.classType);
        _builder.append(_formatForCodeCapital_9);
      }
    }
    _builder.append("Repository");
    _builder.newLineIfNotEmpty();
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
