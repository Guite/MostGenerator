package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.CustomAction;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.Attributes;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.Categories;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.MetaData;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.StandardFields;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.Relations;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Config;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Custom;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Delete;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Display;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Index;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.View;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.ViewHierarchy;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Csv;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Json;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Kml;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Xml;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed.Atom;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed.Rss;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Views {
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
  
  private IFileSystemAccess fsa;
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    Relations _relations = new Relations();
    final Relations relationHelper = _relations;
    EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(it);
    for (final Controller controller : _allControllers) {
      {
        boolean _or = false;
        boolean _tempIsUserController = this.tempIsUserController(controller);
        if (_tempIsUserController) {
          _or = true;
        } else {
          boolean _tempIsAdminController = this.tempIsAdminController(controller);
          _or = (_tempIsUserController || _tempIsAdminController);
        }
        if (_or) {
          this.headerFooterFile(it, controller);
          boolean _hasActions = this._controllerExtensions.hasActions(controller, "index");
          if (_hasActions) {
            Index _index = new Index();
            Index pageHelper = _index;
            EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
            for (final Entity entity : _allEntities) {
              pageHelper.generate(entity, controller, fsa);
            }
          }
          boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "view");
          if (_hasActions_1) {
            View _view = new View();
            View pageHelperView = _view;
            EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_1 : _allEntities_1) {
              String _appName = this._utils.appName(it);
              pageHelperView.generate(entity_1, _appName, controller, Integer.valueOf(3), fsa);
            }
            ViewHierarchy _viewHierarchy = new ViewHierarchy();
            ViewHierarchy pageHelperViewTree = _viewHierarchy;
            Iterable<Entity> _treeEntities = this._modelBehaviourExtensions.getTreeEntities(it);
            for (final Entity entity_2 : _treeEntities) {
              String _appName_1 = this._utils.appName(it);
              pageHelperViewTree.generate(entity_2, _appName_1, controller, fsa);
            }
            Csv _csv = new Csv();
            Csv pageHelperCsv = _csv;
            EList<Entity> _allEntities_2 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_3 : _allEntities_2) {
              String _appName_2 = this._utils.appName(it);
              pageHelperCsv.generate(entity_3, _appName_2, controller, fsa);
            }
            Rss _rss = new Rss();
            Rss pageHelperRss = _rss;
            EList<Entity> _allEntities_3 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_4 : _allEntities_3) {
              String _appName_3 = this._utils.appName(it);
              pageHelperRss.generate(entity_4, _appName_3, controller, fsa);
            }
            Atom _atom = new Atom();
            Atom pageHelperAtom = _atom;
            EList<Entity> _allEntities_4 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_5 : _allEntities_4) {
              String _appName_4 = this._utils.appName(it);
              pageHelperAtom.generate(entity_5, _appName_4, controller, fsa);
            }
          }
          boolean _or_1 = false;
          boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "view");
          if (_hasActions_2) {
            _or_1 = true;
          } else {
            boolean _hasActions_3 = this._controllerExtensions.hasActions(controller, "display");
            _or_1 = (_hasActions_2 || _hasActions_3);
          }
          if (_or_1) {
            Xml _xml = new Xml();
            Xml pageHelperXml = _xml;
            EList<Entity> _allEntities_5 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_6 : _allEntities_5) {
              String _appName_5 = this._utils.appName(it);
              pageHelperXml.generate(entity_6, _appName_5, controller, fsa);
            }
            Json _json = new Json();
            Json pageHelperJson = _json;
            EList<Entity> _allEntities_6 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_7 : _allEntities_6) {
              String _appName_6 = this._utils.appName(it);
              pageHelperJson.generate(entity_7, _appName_6, controller, fsa);
            }
            boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
            if (_hasGeographical) {
              Kml _kml = new Kml();
              Kml pageHelperKml = _kml;
              EList<Entity> _allEntities_7 = this._modelExtensions.getAllEntities(it);
              for (final Entity entity_8 : _allEntities_7) {
                String _appName_7 = this._utils.appName(it);
                pageHelperKml.generate(entity_8, _appName_7, controller, fsa);
              }
            }
          }
          boolean _hasActions_4 = this._controllerExtensions.hasActions(controller, "display");
          if (_hasActions_4) {
            Display _display = new Display();
            Display pageHelper_1 = _display;
            EList<Entity> _allEntities_8 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_9 : _allEntities_8) {
              String _appName_8 = this._utils.appName(it);
              pageHelper_1.generate(entity_9, _appName_8, controller, fsa);
            }
          }
          boolean _hasActions_5 = this._controllerExtensions.hasActions(controller, "delete");
          if (_hasActions_5) {
            Delete _delete = new Delete();
            Delete pageHelper_2 = _delete;
            EList<Entity> _allEntities_9 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_10 : _allEntities_9) {
              String _appName_9 = this._utils.appName(it);
              pageHelper_2.generate(entity_10, _appName_9, controller, fsa);
            }
          }
          Custom _custom = new Custom();
          Custom customHelper = _custom;
          EList<Action> _actions = controller.getActions();
          Iterable<CustomAction> _filter = Iterables.<CustomAction>filter(_actions, CustomAction.class);
          for (final CustomAction action : _filter) {
            customHelper.generate(action, it, controller, fsa);
          }
          boolean _hasActions_6 = this._controllerExtensions.hasActions(controller, "display");
          if (_hasActions_6) {
            EList<Entity> _allEntities_10 = this._modelExtensions.getAllEntities(it);
            for (final Entity entity_11 : _allEntities_10) {
              {
                relationHelper.displayItemList(entity_11, it, controller, Boolean.valueOf(false), fsa);
                relationHelper.displayItemList(entity_11, it, controller, Boolean.valueOf(true), fsa);
                relationHelper.displayItemList(entity_11, it, controller, Boolean.valueOf(false), fsa);
                relationHelper.displayItemList(entity_11, it, controller, Boolean.valueOf(true), fsa);
              }
            }
          }
        }
        boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
        if (_hasAttributableEntities) {
          Attributes _attributes = new Attributes();
          _attributes.generate(it, controller, fsa);
        }
        boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
        if (_hasCategorisableEntities) {
          Categories _categories = new Categories();
          _categories.generate(it, controller, fsa);
        }
        boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
        if (_hasStandardFieldEntities) {
          StandardFields _standardFields = new StandardFields();
          _standardFields.generate(it, controller, fsa);
        }
        boolean _hasMetaDataEntities = this._modelBehaviourExtensions.hasMetaDataEntities(it);
        if (_hasMetaDataEntities) {
          MetaData _metaData = new MetaData();
          _metaData.generate(it, controller, fsa);
        }
      }
    }
    boolean _needsConfig = this._utils.needsConfig(it);
    if (_needsConfig) {
      Config _config = new Config();
      _config.generate(it, fsa);
    }
    this.pdfHeaderFile(it);
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
  
  private boolean tempIsUserController(final Controller it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof UserController) {
        final UserController _userController = (UserController)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  private void headerFooterFile(final Application it, final Controller controller) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _formattedName = this._controllerExtensions.formattedName(controller);
      _xifexpression = _formattedName;
    } else {
      String _formattedName_1 = this._controllerExtensions.formattedName(controller);
      String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
      _xifexpression = _firstUpper;
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    String _plus_1 = (templatePath + "header.tpl");
    CharSequence _headerImpl = this.headerImpl(it, controller);
    this.fsa.generateFile(_plus_1, _headerImpl);
    String _plus_2 = (templatePath + "footer.tpl");
    CharSequence _footerImpl = this.footerImpl(it, controller);
    this.fsa.generateFile(_plus_2, _footerImpl);
  }
  
  private CharSequence headerImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: header for ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{pageaddvar name=\'javascript\' value=\'prototype\'}");
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'validation\'}");
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'zikula\'}");
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'livepipe\'}");
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'zikula.ui\'}");
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'zikula.imageviewer\'}");
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'modules/");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append("/");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("javascript/");
      } else {
        String _appJsPath = this._namingExtensions.getAppJsPath(it);
        _builder.append(_appJsPath, "");
      }
    }
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append(".js\'}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
    _builder.newLine();
    {
      boolean _tempIsAdminController = this.tempIsAdminController(controller);
      if (_tempIsAdminController) {
        _builder.append("    ");
        _builder.append("{adminheader}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("<div class=\"z-frontendbox\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<h2>{gt text=\'");
        String _appName_2 = this._utils.appName(it);
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_appName_2);
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\' comment=\'This is the title of the header template\'}</h2>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("{modulelinks modname=\'");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "        ");
        _builder.append("\' type=\'");
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_1, "        ");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    {
      boolean _and = false;
      boolean _needsApproval = this._workflowExtensions.needsApproval(it);
      if (!_needsApproval) {
        _and = false;
      } else {
        boolean _tempIsUserController = this.tempIsUserController(controller);
        _and = (_needsApproval && _tempIsUserController);
      }
      if (_and) {
        _builder.append("    ");
        _builder.append("{nocache}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("{");
        String _appName_4 = this._utils.appName(it);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName_4);
        _builder.append(_formatForDB, "        ");
        _builder.append("ModerationObjects assign=\'moderationObjects\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("{if count($moderationObjects) gt 0}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("{foreach item=\'modItem\' from=$moderationObjects}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("            ");
        _builder.append("<p class=\"z-informationmsg z-center\"><a href=\"{modurl modname=\'");
        String _appName_5 = this._utils.appName(it);
        _builder.append(_appName_5, "                ");
        _builder.append("\' type=\'admin\' func=\'view\' ot=$modItem.objectType workflowState=$modItem.state}\" class=\"z-bold\">{$modItem.message}</a></p>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{/nocache}");
        _builder.newLine();
      }
    }
    _builder.append("{/if}");
    _builder.newLine();
    {
      boolean _tempIsAdminController_1 = this.tempIsAdminController(controller);
      if (_tempIsAdminController_1) {
      } else {
        _builder.append("{insert name=\'getstatusmsg\'}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence footerImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: footer for ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
    _builder.newLine();
    _builder.append("    ");
    FileHelper _fileHelper = new FileHelper();
    CharSequence _msWeblink = _fileHelper.msWeblink(it);
    _builder.append(_msWeblink, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _tempIsAdminController = this.tempIsAdminController(controller);
      if (_tempIsAdminController) {
        _builder.append("    ");
        _builder.append("{adminfooter}");
        _builder.newLine();
      }
    }
    {
      boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
      if (_hasEditActions) {
        _builder.append("{elseif isset($smarty.get.func) && $smarty.get.func eq \'edit\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{pageaddvar name=\'stylesheet\' value=\'styles/core.css\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{pageaddvar name=\'stylesheet\' value=\'modules/");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("/");
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          if (_targets) {
            _builder.append("style");
          } else {
            String _appCssPath = this._namingExtensions.getAppCssPath(it);
            _builder.append(_appCssPath, "    ");
          }
        }
        _builder.append("/style.css\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{pageaddvar name=\'stylesheet\' value=\'system/Theme/style/form/style.css\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{pageaddvar name=\'stylesheet\' value=\'themes/Andreas08/style/fluid960gs/reset.css\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{capture assign=\'pageStyles\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<style type=\"text/css\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("body {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("font-size: 70%;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</style>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{/capture}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{pageaddvar name=\'header\' value=$pageStyles}");
        _builder.newLine();
      }
    }
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private void pdfHeaderFile(final Application it) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _plus = (_viewPath + "include_pdfheader.tpl");
    CharSequence _pdfHeaderImpl = this.pdfHeaderImpl(it);
    this.fsa.generateFile(_plus, _pdfHeaderImpl);
  }
  
  private CharSequence pdfHeaderImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">");
    _builder.newLine();
    _builder.append("<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"{lang}\" lang=\"{lang}\">");
    _builder.newLine();
    _builder.append("<head>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<title>{pagegetvar name=\'title\'}</title>");
    _builder.newLine();
    _builder.append("<style>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("body {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("margin: 0 2cm 1cm 1cm;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("img {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("border-width: 0;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("vertical-align: middle;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("</style>");
    _builder.newLine();
    _builder.append("</head>");
    _builder.newLine();
    _builder.append("<body>");
    _builder.newLine();
    return _builder;
  }
}
