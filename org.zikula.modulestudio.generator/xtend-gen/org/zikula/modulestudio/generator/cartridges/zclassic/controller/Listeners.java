package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Core;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Errors;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.FrontController;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Group;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Mailer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleDispatch;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleInstaller;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Page;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Theme;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThirdParty;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.User;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogin;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogout;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserRegistration;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Users;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.View;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Listeners {
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
  
  @Inject
  @Extension
  private WorkflowExtensions _workflowExtensions = new Function0<WorkflowExtensions>() {
    public WorkflowExtensions apply() {
      WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
      return _workflowExtensions;
    }
  }.apply();
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for persistent event listeners.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating event listener base classes");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String listenerBasePath = (_appSourceLibPath + "Listener/Base/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Listener";
    }
    final String listenerSuffix = (_xifexpression + ".php");
    String _plus = (listenerBasePath + "Core");
    String _plus_1 = (_plus + listenerSuffix);
    CharSequence _listenersCoreFile = this.listenersCoreFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_1, _listenersCoreFile);
    String _plus_2 = (listenerBasePath + "FrontController");
    String _plus_3 = (_plus_2 + listenerSuffix);
    CharSequence _listenersFrontControllerFile = this.listenersFrontControllerFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_3, _listenersFrontControllerFile);
    String _plus_4 = (listenerBasePath + "Installer");
    String _plus_5 = (_plus_4 + listenerSuffix);
    CharSequence _listenersInstallerFile = this.listenersInstallerFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_5, _listenersInstallerFile);
    String _plus_6 = (listenerBasePath + "ModuleDispatch");
    String _plus_7 = (_plus_6 + listenerSuffix);
    CharSequence _listenersModuleDispatchFile = this.listenersModuleDispatchFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_7, _listenersModuleDispatchFile);
    String _plus_8 = (listenerBasePath + "Mailer");
    String _plus_9 = (_plus_8 + listenerSuffix);
    CharSequence _listenersMailerFile = this.listenersMailerFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_9, _listenersMailerFile);
    String _plus_10 = (listenerBasePath + "Page");
    String _plus_11 = (_plus_10 + listenerSuffix);
    CharSequence _listenersPageFile = this.listenersPageFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_11, _listenersPageFile);
    String _plus_12 = (listenerBasePath + "Errors");
    String _plus_13 = (_plus_12 + listenerSuffix);
    CharSequence _listenersErrorsFile = this.listenersErrorsFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_13, _listenersErrorsFile);
    String _plus_14 = (listenerBasePath + "Theme");
    String _plus_15 = (_plus_14 + listenerSuffix);
    CharSequence _listenersThemeFile = this.listenersThemeFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_15, _listenersThemeFile);
    String _plus_16 = (listenerBasePath + "View");
    String _plus_17 = (_plus_16 + listenerSuffix);
    CharSequence _listenersViewFile = this.listenersViewFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_17, _listenersViewFile);
    String _plus_18 = (listenerBasePath + "UserLogin");
    String _plus_19 = (_plus_18 + listenerSuffix);
    CharSequence _listenersUserLoginFile = this.listenersUserLoginFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_19, _listenersUserLoginFile);
    String _plus_20 = (listenerBasePath + "UserLogout");
    String _plus_21 = (_plus_20 + listenerSuffix);
    CharSequence _listenersUserLogoutFile = this.listenersUserLogoutFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_21, _listenersUserLogoutFile);
    String _plus_22 = (listenerBasePath + "User");
    String _plus_23 = (_plus_22 + listenerSuffix);
    CharSequence _listenersUserFile = this.listenersUserFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_23, _listenersUserFile);
    String _plus_24 = (listenerBasePath + "UserRegistration");
    String _plus_25 = (_plus_24 + listenerSuffix);
    CharSequence _listenersUserRegistrationFile = this.listenersUserRegistrationFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_25, _listenersUserRegistrationFile);
    String _plus_26 = (listenerBasePath + "Users");
    String _plus_27 = (_plus_26 + listenerSuffix);
    CharSequence _listenersUsersFile = this.listenersUsersFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_27, _listenersUsersFile);
    String _plus_28 = (listenerBasePath + "Group");
    String _plus_29 = (_plus_28 + listenerSuffix);
    CharSequence _listenersGroupFile = this.listenersGroupFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_29, _listenersGroupFile);
    String _plus_30 = (listenerBasePath + "ThirdParty");
    String _plus_31 = (_plus_30 + listenerSuffix);
    CharSequence _listenersThirdPartyFile = this.listenersThirdPartyFile(it, Boolean.valueOf(true));
    fsa.generateFile(_plus_31, _listenersThirdPartyFile);
    InputOutput.<String>println("Generating event listener implementation classes");
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    final String listenerPath = (_appSourceLibPath_1 + "Listener/");
    String _plus_32 = (listenerPath + "Core");
    String _plus_33 = (_plus_32 + listenerSuffix);
    CharSequence _listenersCoreFile_1 = this.listenersCoreFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_33, _listenersCoreFile_1);
    String _plus_34 = (listenerPath + "FrontController");
    String _plus_35 = (_plus_34 + listenerSuffix);
    CharSequence _listenersFrontControllerFile_1 = this.listenersFrontControllerFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_35, _listenersFrontControllerFile_1);
    String _plus_36 = (listenerPath + "Installer");
    String _plus_37 = (_plus_36 + listenerSuffix);
    CharSequence _listenersInstallerFile_1 = this.listenersInstallerFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_37, _listenersInstallerFile_1);
    String _plus_38 = (listenerPath + "ModuleDispatch");
    String _plus_39 = (_plus_38 + listenerSuffix);
    CharSequence _listenersModuleDispatchFile_1 = this.listenersModuleDispatchFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_39, _listenersModuleDispatchFile_1);
    String _plus_40 = (listenerPath + "Mailer");
    String _plus_41 = (_plus_40 + listenerSuffix);
    CharSequence _listenersMailerFile_1 = this.listenersMailerFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_41, _listenersMailerFile_1);
    String _plus_42 = (listenerPath + "Page");
    String _plus_43 = (_plus_42 + listenerSuffix);
    CharSequence _listenersPageFile_1 = this.listenersPageFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_43, _listenersPageFile_1);
    String _plus_44 = (listenerPath + "Errors");
    String _plus_45 = (_plus_44 + listenerSuffix);
    CharSequence _listenersErrorsFile_1 = this.listenersErrorsFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_45, _listenersErrorsFile_1);
    String _plus_46 = (listenerPath + "Theme");
    String _plus_47 = (_plus_46 + listenerSuffix);
    CharSequence _listenersThemeFile_1 = this.listenersThemeFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_47, _listenersThemeFile_1);
    String _plus_48 = (listenerPath + "View");
    String _plus_49 = (_plus_48 + listenerSuffix);
    CharSequence _listenersViewFile_1 = this.listenersViewFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_49, _listenersViewFile_1);
    String _plus_50 = (listenerPath + "UserLogin");
    String _plus_51 = (_plus_50 + listenerSuffix);
    CharSequence _listenersUserLoginFile_1 = this.listenersUserLoginFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_51, _listenersUserLoginFile_1);
    String _plus_52 = (listenerPath + "UserLogout");
    String _plus_53 = (_plus_52 + listenerSuffix);
    CharSequence _listenersUserLogoutFile_1 = this.listenersUserLogoutFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_53, _listenersUserLogoutFile_1);
    String _plus_54 = (listenerPath + "User");
    String _plus_55 = (_plus_54 + listenerSuffix);
    CharSequence _listenersUserFile_1 = this.listenersUserFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_55, _listenersUserFile_1);
    String _plus_56 = (listenerPath + "UserRegistration");
    String _plus_57 = (_plus_56 + listenerSuffix);
    CharSequence _listenersUserRegistrationFile_1 = this.listenersUserRegistrationFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_57, _listenersUserRegistrationFile_1);
    String _plus_58 = (listenerPath + "Users");
    String _plus_59 = (_plus_58 + listenerSuffix);
    CharSequence _listenersUsersFile_1 = this.listenersUsersFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_59, _listenersUsersFile_1);
    String _plus_60 = (listenerPath + "Group");
    String _plus_61 = (_plus_60 + listenerSuffix);
    CharSequence _listenersGroupFile_1 = this.listenersGroupFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_61, _listenersGroupFile_1);
    String _plus_62 = (listenerPath + "ThirdParty");
    String _plus_63 = (_plus_62 + listenerSuffix);
    CharSequence _listenersThirdPartyFile_1 = this.listenersThirdPartyFile(it, Boolean.valueOf(false));
    fsa.generateFile(_plus_63, _listenersThirdPartyFile_1);
  }
  
  private CharSequence listenersCoreFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\CoreListener as BaseCoreListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for core events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_Core extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_Core");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class CoreListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseCoreListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Core _core = new Core();
    CharSequence _generate = _core.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersFrontControllerFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\FrontControllerListener as BaseFrontControllerListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for frontend controller interaction events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_FrontController extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_FrontController");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class FrontControllerListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseFrontControllerListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    FrontController _frontController = new FrontController();
    CharSequence _generate = _frontController.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersInstallerFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\InstallerListener as BaseInstallerListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_Installer extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_Installer");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class InstallerListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseInstallerListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    ModuleInstaller _moduleInstaller = new ModuleInstaller();
    CharSequence _generate = _moduleInstaller.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersModuleDispatchFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\ModuleDispatchListener as BaseModuleDispatchListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if ((isBase).booleanValue()) {
            _builder.append("use ModUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_ModuleDispatch extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_ModuleDispatch");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ModuleDispatchListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseModuleDispatchListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    ModuleDispatch _moduleDispatch = new ModuleDispatch();
    CharSequence _generate = _moduleDispatch.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersMailerFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\MailerListener as BaseMailerListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_Mailer extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_Mailer");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class MailerListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseMailerListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Mailer _mailer = new Mailer();
    CharSequence _generate = _mailer.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersPageFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\PageListener as BasePageListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for page-related events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_Page extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_Page");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class PageListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BasePageListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Page _page = new Page();
    CharSequence _generate = _page.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersErrorsFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\ErrorsListener as BaseErrorsListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for error-related events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_Errors extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_Errors");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ErrorsListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseErrorsListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Errors _errors = new Errors();
    CharSequence _generate = _errors.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersThemeFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\ThemeListener as BaseThemeListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_Theme extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_Theme");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ThemeListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseThemeListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Theme _theme = new Theme();
    CharSequence _generate = _theme.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersViewFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\ViewListener as BaseViewListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
        _builder.append("base");
      } else {
        _builder.append("implementation");
      }
    }
    _builder.append(" class for view-related events.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_View extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_View");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ViewListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseViewListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    View _view = new View();
    CharSequence _generate = _view.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUserLoginFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\UserLoginListener as BaseUserLoginListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_UserLogin extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_UserLogin");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class UserLoginListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseUserLoginListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    UserLogin _userLogin = new UserLogin();
    CharSequence _generate = _userLogin.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUserLogoutFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\UserLogoutListener as BaseUserLogoutListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_UserLogout extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_UserLogout");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class UserLogoutListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseUserLogoutListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    UserLogout _userLogout = new UserLogout();
    CharSequence _generate = _userLogout.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUserFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          if ((isBase).booleanValue()) {
            {
              boolean _or = false;
              boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
              if (_hasStandardFieldEntities) {
                _or = true;
              } else {
                boolean _hasUserFields = this._modelExtensions.hasUserFields(it);
                _or = (_hasStandardFieldEntities || _hasUserFields);
              }
              if (_or) {
                _builder.append("use ModUtil;");
                _builder.newLine();
                _builder.append("use ServiceUtil;");
                _builder.newLine();
              }
            }
          } else {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\UserListener as BaseUserListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_User extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_User");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class UserListener");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            _builder.append(" extends BaseUserListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    User _user = new User();
    CharSequence _generate = _user.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUserRegistrationFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\UserRegistrationListener as BaseUserRegistrationListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_UserRegistration extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_UserRegistration");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class UserRegistrationListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseUserRegistrationListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    UserRegistration _userRegistration = new UserRegistration();
    CharSequence _generate = _userRegistration.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersUsersFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\UsersListener as BaseUsersListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler ");
    {
      if ((isBase).booleanValue()) {
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
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_Users extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_Users");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class UsersListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseUsersListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Users _users = new Users();
    CharSequence _generate = _users.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersGroupFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\GroupListener as BaseGroupListener;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler implementation class for group-related events.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_Group extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_Group");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class GroupListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseGroupListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Group _group = new Group();
    CharSequence _generate = _group.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listenersThirdPartyFile(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Listener");
        {
          if ((isBase).booleanValue()) {
            _builder.append("\\Base");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _not_1 = (!(isBase).booleanValue());
          if (_not_1) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Listener\\Base\\ThirdPartyListener as BaseThirdPartyListener;");
            _builder.newLineIfNotEmpty();
          } else {
            {
              boolean _needsApproval = this._workflowExtensions.needsApproval(it);
              if (_needsApproval) {
                _builder.append("use ");
                String _appNamespace_2 = this._utils.appNamespace(it);
                _builder.append(_appNamespace_2, "");
                _builder.append("\\Util\\WorkflowUtil;");
                _builder.newLineIfNotEmpty();
                _builder.append("use ServiceUtil;");
                _builder.newLine();
                _builder.append("use Zikula\\Collection\\Container;");
                _builder.newLine();
              }
            }
          }
        }
        _builder.append("use Zikula\\Core\\Event\\GenericEvent;");
        _builder.newLine();
        {
          if ((isBase).booleanValue()) {
            {
              boolean _needsApproval_1 = this._workflowExtensions.needsApproval(it);
              if (_needsApproval_1) {
                _builder.append("use Zikula\\Provider\\AggregateItem;");
                _builder.newLine();
              }
            }
          }
        }
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Event handler implementation class for special purposes and 3rd party api support.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        {
          boolean _not_2 = (!(isBase).booleanValue());
          if (_not_2) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Listener_ThirdParty extends ");
          }
        }
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Listener_Base_ThirdParty");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ThirdPartyListener");
        {
          boolean _not_3 = (!(isBase).booleanValue());
          if (_not_3) {
            _builder.append(" extends BaseThirdPartyListener");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    ThirdParty _thirdParty = new ThirdParty();
    CharSequence _generate = _thirdParty.generate(it, isBase);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
