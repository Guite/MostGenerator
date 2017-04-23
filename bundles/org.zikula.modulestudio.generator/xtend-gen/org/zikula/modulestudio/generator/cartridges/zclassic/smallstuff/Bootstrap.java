package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Bootstrap {
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    final String basePath = (_appSourcePath + "Base/bootstrap.php");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, basePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, basePath);
      if (_shouldBeMarked) {
        fsa.generateFile(basePath.replace(".php", ".generated.php"), this.bootstrapFile(it, Boolean.valueOf(true)));
      } else {
        fsa.generateFile(basePath, this.bootstrapFile(it, Boolean.valueOf(true)));
      }
    }
    String _appSourcePath_1 = this._namingExtensions.getAppSourcePath(it);
    final String concretePath = (_appSourcePath_1 + "bootstrap.php");
    if (((!this._generatorSettingsExtensions.generateOnlyBaseClasses(it)) && (!this._namingExtensions.shouldBeSkipped(it, concretePath)))) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, concretePath);
      if (_shouldBeMarked_1) {
        fsa.generateFile(concretePath.replace(".php", ".generated.php"), this.bootstrapFile(it, Boolean.valueOf(false)));
      } else {
        fsa.generateFile(concretePath, this.bootstrapFile(it, Boolean.valueOf(false)));
      }
    }
  }
  
  private CharSequence bootstrapFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeaderBootstrapFile = this.fh.phpFileHeaderBootstrapFile(it);
    _builder.append(_phpFileHeaderBootstrapFile);
    _builder.newLineIfNotEmpty();
    {
      if ((isBase).booleanValue()) {
        CharSequence _bootstrapBaseImpl = this.bootstrapBaseImpl(it);
        _builder.append(_bootstrapBaseImpl);
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _bootstrapImpl = this.bootstrapImpl(it);
        _builder.append(_bootstrapImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence bootstrapDocs() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Bootstrap called when application is first initialised at runtime.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is only called once, and only if the core has reason to initialise this module,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* usually to dispatch a controller request or API.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence bootstrapBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _bootstrapDocs = this.bootstrapDocs();
    _builder.append(_bootstrapDocs);
    _builder.newLineIfNotEmpty();
    {
      if ((this._modelBehaviourExtensions.hasLoggable(it) || this._modelBehaviourExtensions.hasAutomaticArchiving(it))) {
        _builder.append("$container = \\ServiceUtil::get(\'service_container\');");
        _builder.newLine();
        _builder.newLine();
      }
    }
    CharSequence _initExtensions = this.initExtensions(it);
    _builder.append(_initExtensions);
    _builder.newLineIfNotEmpty();
    CharSequence _archiveObjectsCall = this.archiveObjectsCall(it);
    _builder.append(_archiveObjectsCall);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initExtensions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasLoggable = this._modelBehaviourExtensions.hasLoggable(it);
      if (_hasLoggable) {
        _builder.append("$currentUserApi = $container->get(\'zikula_users_module.current_user\');");
        _builder.newLine();
        _builder.append("$userName = $currentUserApi->isLoggedIn() ? $currentUserApi->get(\'uname\') : __(\'Guest\');");
        _builder.newLine();
        _builder.newLine();
        _builder.append("// set current user name to loggable listener");
        _builder.newLine();
        _builder.append("$loggableListener = $container->get(\'doctrine_extensions.listener.loggable\');");
        _builder.newLine();
        _builder.append("$loggableListener->setUsername($userName);");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence archiveObjectsCall(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasAutomaticArchiving = this._modelBehaviourExtensions.hasAutomaticArchiving(it);
      if (_hasAutomaticArchiving) {
        _builder.newLine();
        _builder.append("// check if own service exists (which is not true if the module is not installed yet)");
        _builder.newLine();
        _builder.append("if ($container->has(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService);
        _builder.append(".archive_helper\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$container->get(\'");
        String _appService_1 = this._utils.appService(it);
        _builder.append(_appService_1, "    ");
        _builder.append(".archive_helper\')->archiveObjects();");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence bootstrapImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _bootstrapDocs = this.bootstrapDocs();
    _builder.append(_bootstrapDocs);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("include_once \'Base/bootstrap.php\';");
    _builder.newLine();
    return _builder;
  }
}
