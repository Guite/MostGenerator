package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class LinkTable {
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
  
  /**
   * Creates a reference table class file for every many-to-many relationship instance.
   */
  public void generate(final ManyToManyRelationship it, final Application app, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(app);
    final String repositoryPath = (_appSourceLibPath + "Entity/Repository/");
    String _refClass = it.getRefClass();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_refClass);
    final String repositoryFile = (_formatForCodeCapital + ".php");
    String _plus = (repositoryPath + "Base/");
    String _plus_1 = (_plus + repositoryFile);
    CharSequence _modelRefRepositoryBaseFile = this.modelRefRepositoryBaseFile(it, app);
    fsa.generateFile(_plus_1, _modelRefRepositoryBaseFile);
    String _plus_2 = (repositoryPath + repositoryFile);
    CharSequence _modelRefRepositoryFile = this.modelRefRepositoryFile(it, app);
    fsa.generateFile(_plus_2, _modelRefRepositoryFile);
  }
  
  private CharSequence modelRefRepositoryBaseFile(final ManyToManyRelationship it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _modelRefRepositoryBaseImpl = this.modelRefRepositoryBaseImpl(it, app);
    _builder.append(_modelRefRepositoryBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelRefRepositoryFile(final ManyToManyRelationship it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _modelRefRepositoryImpl = this.modelRefRepositoryImpl(it, app);
    _builder.append(_modelRefRepositoryImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelRefRepositoryBaseImpl(final ManyToManyRelationship it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("\\Entity\\Repository\\Base;");
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
    _builder.append("* This is the base repository class for the many to many relationship");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* between ");
    Entity _source = it.getSource();
    String _name = _source.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" and ");
    Entity _target = it.getTarget();
    String _name_1 = _target.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
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
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Entity_Repository_Base_");
        String _refClass = it.getRefClass();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_refClass);
        _builder.append(_formatForCodeCapital, "");
        _builder.append(" extends EntityRepository");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _refClass_1 = it.getRefClass();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_refClass_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append(" extends \\EntityRepository");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function truncateTable()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("        ");
        _builder.append("$qb->delete(\'");
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "        ");
        _builder.append("_Entity_");
        String _refClass_2 = it.getRefClass();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_refClass_2);
        _builder.append(_formatForCodeCapital_2, "        ");
        _builder.append("\', \'tbl\');");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("        ");
        _builder.append("$qb->delete(\'\\\\");
        String _appName_3 = this._utils.appName(app);
        _builder.append(_appName_3, "        ");
        _builder.append("\\\\Entity\\\\");
        String _refClass_3 = it.getRefClass();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_refClass_3);
        _builder.append(_formatForCodeCapital_3, "        ");
        _builder.append("\', \'tbl\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence modelRefRepositoryImpl(final ManyToManyRelationship it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(app);
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
    _builder.append("* This is the concrete repository class for the many to many relationship");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* between ");
    Entity _source = it.getSource();
    String _name = _source.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" and ");
    Entity _target = it.getTarget();
    String _name_1 = _target.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
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
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Entity_Repository_");
        String _refClass = it.getRefClass();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_refClass);
        _builder.append(_formatForCodeCapital, "");
        _builder.append(" extends ");
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "");
        _builder.append("_Entity_Repository_Base_");
        String _refClass_1 = it.getRefClass();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_refClass_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _refClass_2 = it.getRefClass();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_refClass_2);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append(" extends Base\\");
        String _refClass_3 = it.getRefClass();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_refClass_3);
        _builder.append(_formatForCodeCapital_3, "");
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
}
