package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Group;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.IpTrace;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Kernel;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Mailer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleDispatch;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleInstaller;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Theme;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThirdParty;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.User;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogin;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogout;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserRegistration;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Users;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.WorkflowEvents;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Listeners {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private FileHelper fh = new FileHelper();
  
  private IFileSystemAccess fsa;
  
  private Application app;
  
  private Boolean isBase;
  
  private Boolean needsThirdPartyListener;
  
  private String listenerPath;
  
  private String listenerSuffix;
  
  /**
   * Entry point for event subscribers.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    this.app = it;
    this.listenerSuffix = "Listener.php";
    final boolean needsDetailContentType = (this._generatorSettingsExtensions.generateDetailContentType(it) && this._controllerExtensions.hasDisplayActions(it));
    this.needsThirdPartyListener = Boolean.valueOf((((this._generatorSettingsExtensions.generatePendingContentSupport(it) || this._generatorSettingsExtensions.generateListContentType(it)) || needsDetailContentType) || this._generatorSettingsExtensions.generateScribitePlugins(it)));
    InputOutput.<String>println("Generating event listener base classes");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Listener/Base/");
    this.listenerPath = _plus;
    this.isBase = Boolean.valueOf(true);
    this.generateListenerClasses(it);
    boolean _generateOnlyBaseClasses = this._generatorSettingsExtensions.generateOnlyBaseClasses(it);
    if (_generateOnlyBaseClasses) {
      return;
    }
    InputOutput.<String>println("Generating event listener implementation classes");
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath_1 + "Listener/");
    this.listenerPath = _plus_1;
    this.isBase = Boolean.valueOf(false);
    this.generateListenerClasses(it);
  }
  
  private void generateListenerClasses(final Application it) {
    this.listenerFile("Kernel", this.listenersKernelFile(it));
    this.listenerFile("Installer", this.listenersInstallerFile(it));
    this.listenerFile("ModuleDispatch", this.listenersModuleDispatchFile(it));
    this.listenerFile("Mailer", this.listenersMailerFile(it));
    this.listenerFile("Theme", this.listenersThemeFile(it));
    this.listenerFile("UserLogin", this.listenersUserLoginFile(it));
    this.listenerFile("UserLogout", this.listenersUserLogoutFile(it));
    this.listenerFile("User", this.listenersUserFile(it));
    this.listenerFile("UserRegistration", this.listenersUserRegistrationFile(it));
    this.listenerFile("Users", this.listenersUsersFile(it));
    this.listenerFile("Group", this.listenersGroupFile(it));
    if ((this.needsThirdPartyListener).booleanValue()) {
      this.listenerFile("ThirdParty", this.listenersThirdPartyFile(it));
    }
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this._modelBehaviourExtensions.hasIpTraceableFields(it_1));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function));
    boolean _not = (!_isEmpty);
    if (_not) {
      this.listenerFile("IpTrace", this.listenersIpTraceFile(it));
    }
    Boolean _targets = this._utils.targets(it, "1.5");
    if ((_targets).booleanValue()) {
      this.listenerFile("WorkflowEvents", this.listenersWorkflowEventsFile(it));
    }
  }
  
  private void listenerFile(final String name, final CharSequence content) {
    String _xifexpression = null;
    if ((this.isBase).booleanValue()) {
      _xifexpression = "Abstract";
    } else {
      _xifexpression = "";
    }
    String _plus = (this.listenerPath + _xifexpression);
    String _plus_1 = (_plus + name);
    String filePath = (_plus_1 + this.listenerSuffix);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(this.app, filePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(this.app, filePath);
      if (_shouldBeMarked) {
        String _replace = this.listenerSuffix.replace(".php", ".generated.php");
        String _plus_2 = ((this.listenerPath + name) + _replace);
        filePath = _plus_2;
      }
      this.fsa.generateFile(filePath, this.fh.phpFileContent(this.app, content));
    }
  }
  
  private CharSequence listenersInstallerFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractInstallerListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\CoreEvents;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Event\\ModuleStateEvent;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for module installer events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("InstallerListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractInstallerListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new ModuleInstaller().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersKernelFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractKernelListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpKernel\\KernelEvents;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\HttpKernel\\Event\\FilterControllerEvent;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpKernel\\Event\\FilterResponseEvent;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpKernel\\Event\\FinishRequestEvent;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpKernel\\Event\\GetResponseEvent;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpKernel\\Event\\GetResponseForControllerResultEvent;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpKernel\\Event\\GetResponseForExceptionEvent;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpKernel\\Event\\PostResponseEvent;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for Symfony kernel events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("KernelListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractKernelListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new Kernel().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersModuleDispatchFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractModuleDispatchListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for dispatching modules.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("ModuleDispatchListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractModuleDispatchListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new ModuleDispatch().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersMailerFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractMailerListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
        _builder.append("use Zikula\\MailerModule\\MailerEvents;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for mailing events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("MailerListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractMailerListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new Mailer().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersThemeFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractThemeListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
        _builder.append("use Zikula\\ThemeModule\\ThemeEvents;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\ThemeModule\\Bridge\\Event\\TwigPostRenderEvent;");
    _builder.newLine();
    _builder.append("use Zikula\\ThemeModule\\Bridge\\Event\\TwigPreRenderEvent;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for theme-related events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("ThemeListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractThemeListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new Theme().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUserLoginFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractUserLoginListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("use Zikula\\UsersModule\\AccessEvents;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for user login events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("UserLoginListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractUserLoginListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new UserLogin().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUserLogoutFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractUserLogoutListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("use Zikula\\UsersModule\\AccessEvents;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for user logout events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("UserLogoutListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractUserLogoutListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new UserLogout().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUserFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractUserListener;");
        _builder.newLineIfNotEmpty();
      } else {
        {
          if ((this._modelBehaviourExtensions.hasStandardFieldEntities(it) || this._modelExtensions.hasUserFields(it))) {
            _builder.append("use Psr\\Log\\LoggerInterface;");
            _builder.newLine();
          }
        }
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
        {
          if ((this._modelBehaviourExtensions.hasStandardFieldEntities(it) || this._modelExtensions.hasUserFields(it))) {
            _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        {
          if ((this._modelBehaviourExtensions.hasStandardFieldEntities(it) || this._modelExtensions.hasUserFields(it))) {
            _builder.append("use Zikula\\UsersModule\\Api\\");
            {
              Boolean _targets = this._utils.targets(it, "1.5");
              if ((_targets).booleanValue()) {
                _builder.append("ApiInterface\\CurrentUserApiInterface");
              } else {
                _builder.append("CurrentUserApi");
              }
            }
            _builder.append(";");
            _builder.newLineIfNotEmpty();
            {
              Boolean _targets_1 = this._utils.targets(it, "1.5");
              if ((_targets_1).booleanValue()) {
                _builder.append("use Zikula\\UsersModule\\Constant as UsersConstant;");
                _builder.newLine();
              }
            }
          }
        }
        _builder.append("use Zikula\\UsersModule\\UserEvents;");
        _builder.newLine();
        {
          if ((this._modelBehaviourExtensions.hasStandardFieldEntities(it) || this._modelExtensions.hasUserFields(it))) {
            _builder.append("use ");
            String _appNamespace_2 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_2);
            _builder.append("\\Entity\\Factory\\");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
            _builder.append(_formatForCodeCapital);
            _builder.append("Factory;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for user-related events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("UserListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractUserListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new User().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUserRegistrationFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractUserRegistrationListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("use Zikula\\UsersModule\\RegistrationEvents;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for user registration events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("UserRegistrationListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractUserRegistrationListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new UserRegistration().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUsersFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractUsersListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("use Zikula\\UsersModule\\UserEvents;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for events of the Users module.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("UsersListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractUsersListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new Users().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersGroupFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractGroupListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("use Zikula\\GroupsModule\\GroupEvents;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler implementation class for group-related events.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("GroupListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractGroupListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new Group().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersThirdPartyFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractThirdPartyListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpKernel\\HttpKernelInterface;");
        _builder.newLine();
        {
          if ((this._workflowExtensions.needsApproval(it) && this._generatorSettingsExtensions.generatePendingContentSupport(it))) {
            _builder.append("use Zikula\\Collection\\Container;");
            _builder.newLine();
            _builder.append("use ");
            String _appNamespace_2 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_2);
            _builder.append("\\Helper\\WorkflowHelper;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        {
          if ((this._workflowExtensions.needsApproval(it) && this._generatorSettingsExtensions.generatePendingContentSupport(it))) {
            _builder.append("use Zikula\\Provider\\AggregateItem;");
            _builder.newLine();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler implementation class for special purposes and 3rd party api support.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("ThirdPartyListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractThirdPartyListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new ThirdParty().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersIpTraceFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractIpTraceListener;");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("use Gedmo\\IpTraceable\\IpTraceableListener;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpFoundation\\RequestStack;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpKernel\\Event\\GetResponseEvent;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpKernel\\KernelEvents;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler implementation class for ip traceable support.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("IpTraceListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractIpTraceListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new IpTrace().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersWorkflowEventsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Listener");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("\\Base");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Listener\\Base\\AbstractWorkflowEventsListener;");
        _builder.newLineIfNotEmpty();
        _builder.append("use Symfony\\Component\\Workflow\\Event\\Event;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\Workflow\\Event\\GuardEvent;");
        _builder.newLine();
      } else {
        _builder.append("use Symfony\\Component\\EventDispatcher\\EventSubscriberInterface;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\Workflow\\Event\\Event;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\Workflow\\Event\\GuardEvent;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\Doctrine\\EntityAccess;");
        _builder.newLine();
        _builder.append("use Zikula\\PermissionsModule\\Api\\ApiInterface\\PermissionApiInterface;");
        _builder.newLine();
        {
          boolean _needsApproval = this._workflowExtensions.needsApproval(it);
          if (_needsApproval) {
            _builder.append("use ");
            String _appNamespace_2 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_2);
            _builder.append("\\Helper\\NotificationHelper;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler implementation class for workflow events.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see /src/docs/Core-2.0/Workflows/WorkflowEvents.md");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("abstract ");
      }
    }
    _builder.append("class ");
    {
      if ((this.isBase).booleanValue()) {
        _builder.append("Abstract");
      }
    }
    _builder.append("WorkflowEventsListener");
    {
      if ((!(this.isBase).booleanValue())) {
        _builder.append(" extends AbstractWorkflowEventsListener");
      } else {
        _builder.append(" implements EventSubscriberInterface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _generate = new WorkflowEvents().generate(it, this.isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
