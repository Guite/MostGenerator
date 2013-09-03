package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import de.guite.modulestudio.metamodel.modulestudio.Variable;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class InstallerView {
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "init";
    } else {
      _xifexpression = "Init";
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    String _plus_1 = (templatePath + "interactive.tpl");
    CharSequence _tplInit = this.tplInit(it);
    fsa.generateFile(_plus_1, _tplInit);
    boolean _needsConfig = this._utils.needsConfig(it);
    if (_needsConfig) {
      String _plus_2 = (templatePath + "step2.tpl");
      CharSequence _tplInitStep2 = this.tplInitStep2(it);
      fsa.generateFile(_plus_2, _tplInitStep2);
    }
    String _plus_3 = (templatePath + "step3.tpl");
    CharSequence _tplInitStep3 = this.tplInitStep3(it);
    fsa.generateFile(_plus_3, _tplInitStep3);
    String _plus_4 = (templatePath + "update.tpl");
    CharSequence _tplUpdate = this.tplUpdate(it);
    fsa.generateFile(_plus_4, _tplUpdate);
    String _plus_5 = (templatePath + "delete.tpl");
    CharSequence _tplDelete = this.tplDelete(it);
    fsa.generateFile(_plus_5, _tplDelete);
  }
  
  private CharSequence tplInit(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: 1st step of init process: welcome and information *}");
    _builder.newLine();
    _builder.append("<h2>{gt text=\'Installation of ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append("\'}</h2>");
    _builder.newLineIfNotEmpty();
    _builder.append("<p>{gt text=\'Welcome to the installation of ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append("\'}</p>");
    _builder.newLineIfNotEmpty();
    _builder.append("<p>{gt text=\'Generated by <a href=\"");
    String _msUrl = this._utils.msUrl();
    _builder.append(_msUrl, "");
    _builder.append("\" title=\"");
    String _msUrl_1 = this._utils.msUrl();
    _builder.append(_msUrl_1, "");
    _builder.append("\">ModuleStudio ");
    String _msVersion = this._utils.msVersion();
    _builder.append(_msVersion, "");
    _builder.append("</a>.\'}</p>");
    _builder.newLineIfNotEmpty();
    _builder.append("<p>{gt text=\'Many features are contained in ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "");
    _builder.append(" as for example:\'}</p>");
    _builder.newLineIfNotEmpty();
    _builder.append("<dl id=\"");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append("featurelist\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dt>{gt text=\'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _name_1 = _leadingEntity.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append(" management.\'}</dt>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dd>{gt text=\'Easy management of ");
    Entity _leadingEntity_1 = this._modelExtensions.getLeadingEntity(it);
    String _nameMultiple = _leadingEntity_1.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "    ");
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      int _size = _allEntities.size();
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        _builder.append(" and ");
        {
          EList<Models> _models = it.getModels();
          final Function1<Models,EList<Relationship>> _function = new Function1<Models,EList<Relationship>>() {
              public EList<Relationship> apply(final Models e) {
                EList<Relationship> _relations = e.getRelations();
                return _relations;
              }
            };
          List<EList<Relationship>> _map = ListExtensions.<Models, EList<Relationship>>map(_models, _function);
          int _size_1 = _map.size();
          boolean _greaterThan_1 = (_size_1 > 1);
          if (_greaterThan_1) {
            _builder.append("related");
          } else {
            _builder.append("other");
          }
        }
        _builder.append(" artifacts");
      }
    }
    _builder.append(".\'}</dd>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dd>{gt text=\'Included workflow support.\'}</dd>");
    _builder.newLine();
    {
      boolean _or = false;
      boolean _or_1 = false;
      boolean _or_2 = false;
      boolean _or_3 = false;
      boolean _or_4 = false;
      boolean _or_5 = false;
      boolean _or_6 = false;
      boolean _or_7 = false;
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
      if (_hasAttributableEntities) {
        _or_7 = true;
      } else {
        boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
        _or_7 = (_hasAttributableEntities || _hasCategorisableEntities);
      }
      if (_or_7) {
        _or_6 = true;
      } else {
        boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
        boolean _not = (!_hasGeographical);
        _or_6 = (_or_7 || _not);
      }
      if (_or_6) {
        _or_5 = true;
      } else {
        boolean _hasLoggable = this._modelBehaviourExtensions.hasLoggable(it);
        _or_5 = (_or_6 || _hasLoggable);
      }
      if (_or_5) {
        _or_4 = true;
      } else {
        boolean _hasMetaDataEntities = this._modelBehaviourExtensions.hasMetaDataEntities(it);
        _or_4 = (_or_5 || _hasMetaDataEntities);
      }
      if (_or_4) {
        _or_3 = true;
      } else {
        boolean _hasSortable = this._modelBehaviourExtensions.hasSortable(it);
        _or_3 = (_or_4 || _hasSortable);
      }
      if (_or_3) {
        _or_2 = true;
      } else {
        boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
        _or_2 = (_or_3 || _hasStandardFieldEntities);
      }
      if (_or_2) {
        _or_1 = true;
      } else {
        boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
        _or_1 = (_or_2 || _hasTranslatable);
      }
      if (_or_1) {
        _or = true;
      } else {
        boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
        _or = (_or_1 || _hasTrees);
      }
      if (_or) {
        _builder.append("    ");
        _builder.append("<dt>{gt text=\'Behaviours and extensions\'}</dt>");
        _builder.newLine();
        {
          boolean _hasAttributableEntities_1 = this._modelBehaviourExtensions.hasAttributableEntities(it);
          if (_hasAttributableEntities_1) {
            _builder.append("<dd>{gt text=\'Automatic handling of generic attributes.\'}</dd>");
            _builder.newLine();
          }
        }
        {
          boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
          if (_hasCategorisableEntities_1) {
            _builder.append("<dd>{gt text=\'Automatic handling of related categories.\'}</dd>");
            _builder.newLine();
          }
        }
        {
          boolean _hasGeographical_1 = this._modelBehaviourExtensions.hasGeographical(it);
          if (_hasGeographical_1) {
            _builder.append("<dd>{gt text=\'Coordinates handling including html5 geolocation support.\'}</dd>");
            _builder.newLine();
          }
        }
        {
          boolean _hasLoggable_1 = this._modelBehaviourExtensions.hasLoggable(it);
          if (_hasLoggable_1) {
            _builder.append("<dd>{gt text=\'Entity changes can be logged automatically by creating corresponding version log entries.\'}</dd>");
            _builder.newLine();
          }
        }
        {
          boolean _hasMetaDataEntities_1 = this._modelBehaviourExtensions.hasMetaDataEntities(it);
          if (_hasMetaDataEntities_1) {
            _builder.append("<dd>{gt text=\'Automatic handling of attached meta data.\'}</dd>");
            _builder.newLine();
          }
        }
        {
          boolean _hasStandardFieldEntities_1 = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
          if (_hasStandardFieldEntities_1) {
            _builder.append("<dd>{gt text=\'Automatic handling of standard fields, that are user id and date for creation and last update.\'}</dd>");
            _builder.newLine();
          }
        }
        {
          boolean _hasTranslatable_1 = this._modelBehaviourExtensions.hasTranslatable(it);
          if (_hasTranslatable_1) {
            _builder.append("<dd>{gt text=\'Translation management for data fields.\'}</dd>");
            _builder.newLine();
          }
        }
        {
          boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
          if (_hasTrees_1) {
            _builder.append("<dd>{gt text=\'Tree structures can be managed in a hierarchy view with the help of ajax.\'}</dd>");
            _builder.newLine();
          }
        }
      }
    }
    {
      EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(it);
      final Function1<Controller,Boolean> _function_1 = new Function1<Controller,Boolean>() {
          public Boolean apply(final Controller e) {
            boolean _or = false;
            boolean _hasActions = InstallerView.this._controllerExtensions.hasActions(e, "view");
            if (_hasActions) {
              _or = true;
            } else {
              boolean _hasActions_1 = InstallerView.this._controllerExtensions.hasActions(e, "display");
              _or = (_hasActions || _hasActions_1);
            }
            return Boolean.valueOf(_or);
          }
        };
      Iterable<Controller> _filter = IterableExtensions.<Controller>filter(_allControllers, _function_1);
      boolean _isEmpty = IterableExtensions.isEmpty(_filter);
      boolean _not_1 = (!_isEmpty);
      if (_not_1) {
        _builder.append("<dt>{gt text=\'Output formats\'}</dt>");
        _builder.newLine();
        _builder.append("<dd>{gt text=\'Beside the normal templates ");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "");
        _builder.append(" includes also templates for various other output formats, like for example xml (which is only accessible for administrators per default), json");
        {
          EList<Controller> _allControllers_1 = this._controllerExtensions.getAllControllers(it);
          final Function1<Controller,Boolean> _function_2 = new Function1<Controller,Boolean>() {
              public Boolean apply(final Controller e) {
                boolean _hasActions = InstallerView.this._controllerExtensions.hasActions(e, "view");
                return Boolean.valueOf(_hasActions);
              }
            };
          Iterable<Controller> _filter_1 = IterableExtensions.<Controller>filter(_allControllers_1, _function_2);
          boolean _isEmpty_1 = IterableExtensions.isEmpty(_filter_1);
          boolean _not_2 = (!_isEmpty_1);
          if (_not_2) {
            _builder.append(", rss, atom");
          }
        }
        {
          EList<Controller> _allControllers_2 = this._controllerExtensions.getAllControllers(it);
          final Function1<Controller,Boolean> _function_3 = new Function1<Controller,Boolean>() {
              public Boolean apply(final Controller e) {
                boolean _hasActions = InstallerView.this._controllerExtensions.hasActions(e, "display");
                return Boolean.valueOf(_hasActions);
              }
            };
          Iterable<Controller> _filter_2 = IterableExtensions.<Controller>filter(_allControllers_2, _function_3);
          boolean _isEmpty_2 = IterableExtensions.isEmpty(_filter_2);
          boolean _not_3 = (!_isEmpty_2);
          if (_not_3) {
            _builder.append(", csv");
          }
        }
        _builder.append(".\'}</dd>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("<dt>{gt text=\'Integration\'}</dt>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dd>{gt text=\'");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "    ");
    _builder.append(" offers a generic block allowing you to display arbitrary content elements in a block.\'}</dd>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dd>{gt text=\'It is possible to integrate ");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "    ");
    _builder.append(" with Content. There is a corresponding content type available.\'}</dd>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("<dd>{gt text=\'There is also a Mailz plugin for getting ");
        String _appName_6 = this._utils.appName(it);
        _builder.append(_appName_6, "    ");
        _builder.append(" content into mailings and newsletters.\'}</dd>");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("<dd>{gt text=\'There are also Newsletter and Mailz plugins for getting ");
        String _appName_7 = this._utils.appName(it);
        _builder.append(_appName_7, "    ");
        _builder.append(" content into mailings and newsletters.\'}</dd>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("<dd>{gt text=\'All these artifacts reuse the same templates for easier customisation. They can be extended by overriding and the addition of other template sets.\'}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dd>{gt text=\'");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "    ");
    _builder.append(" integrates into the Zikula search module, too, of course.\'}</dd>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dt>{gt text=\'State-of-the-art technology\'}</dt>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dd>{gt text=\'All parts of ");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "    ");
    _builder.append(" are always up to the latest version of the Zikula core.\'}</dd>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dd>{gt text=\'Entities, controllers, hooks, templates, plugins and more.\'}</dd>");
    _builder.newLine();
    _builder.append("</dl>");
    _builder.newLine();
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{modurl modname=\'");
    String _appName_10 = this._utils.appName(it);
    _builder.append(_appName_10, "    ");
    _builder.append("\' type=\'init\' func=\'interactiveinitstep");
    {
      boolean _needsConfig = this._utils.needsConfig(it);
      if (_needsConfig) {
        _builder.append("2");
      } else {
        _builder.append("3");
      }
    }
    _builder.append("\'}\" title=\"{gt text=\'Continue\'}\">{gt text=\'Continue\'}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("</p>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tplInitStep2(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: 2nd step of init process: initial settings *}");
    _builder.newLine();
    _builder.append("<h2>{gt text=\'Installation of ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append("\'}</h2>");
    _builder.newLineIfNotEmpty();
    _builder.append("<form action=\"{modurl modname=\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append("\' type=\'init\' func=\'interactiveinitstep2\'}\" method=\"post\" enctype=\"application/x-www-form-urlencoded\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<legend>{gt text=\'Settings\'}</legend>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"csrftoken\" value=\"{insert name=\'csrftoken\'}\" />");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    {
      List<Variable> _allVariables = this._utils.getAllVariables(it);
      for(final Variable modvar : _allVariables) {
        CharSequence _tplInitStep2Var = this.tplInitStep2Var(modvar, it);
        _builder.append(_tplInitStep2Var, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<legend>{gt text=\'Action\'}</legend>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<label for=\"");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "        ");
    _builder.append("_activate\">{gt text=\'Activate ");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "        ");
    _builder.append(" after installation?\'}</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<input id=\"");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "        ");
    _builder.append("_activate\" name=\"activate\" type=\"checkbox\" value=\"1\" checked=\"checked\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<br /><br />");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input name=\"submit\" type=\"submit\" value=\"{gt text=\'Submit\'}\" style=\"margin-left: 17em\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("</form>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tplInitStep2Var(final Variable it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<label for=\"");
    String _name = app.getName();
    String _plus = (_name + "_");
    String _name_1 = it.getName();
    String _plus_1 = (_plus + _name_1);
    String _formatForCode = this._formattingExtensions.formatForCode(_plus_1);
    _builder.append(_formatForCode, "");
    _builder.append("\" style=\"float: left; width: 20em\">{gt text=\'");
    String _name_2 = it.getName();
    _builder.append(_name_2, "");
    _builder.append("\'}</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("<input id=\"");
    String _name_3 = app.getName();
    String _plus_2 = (_name_3 + "_");
    String _name_4 = it.getName();
    String _plus_3 = (_plus_2 + _name_4);
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_plus_3);
    _builder.append(_formatForCode_1, "");
    _builder.append("\" type=\"text\" name=\"");
    String _name_5 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_5);
    _builder.append(_formatForCode_2, "");
    _builder.append("\" value=\"");
    String _value = it.getValue();
    _builder.append(_value, "");
    _builder.append("\" size=\"40\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("<br style=\"clear: left\" /><br />");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tplInitStep3(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: 3rd step of init process: thanks *}");
    _builder.newLine();
    _builder.append("<h2>{gt text=\'Installation of ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append("\'}</h2>");
    _builder.newLineIfNotEmpty();
    _builder.append("<p>{gt text=\'Last installation step\'}</p>");
    _builder.newLine();
    _builder.append("<p>{gt text=\'Thank you for installing ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append(".<br />Click on the bottom link to finish the installation.\' html=\'1\'}</p>");
    _builder.newLineIfNotEmpty();
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{insert name=\'csrftoken\' assign=\'csrftoken\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{modurl modname=\'Extensions\' type=\'admin\' func=\'initialise\' csrftoken=$csrftoken activate=$activate}\" title=\"{gt text=\'Continue\'}\">{gt text=\'Continue\'}</a>");
    _builder.newLine();
    _builder.append("</p>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tplUpdate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tplDelete(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: delete process *}");
    _builder.newLine();
    _builder.append("<h2>{gt text=\'Uninstall of ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append("\'}</h2>");
    _builder.newLineIfNotEmpty();
    _builder.append("<p>{gt text=\'Thank you for using ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append(".<br />This application is going to be removed now!\' html=\'1\'}</p>");
    _builder.newLineIfNotEmpty();
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{insert name=\'csrftoken\' assign=\'csrftoken\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{modurl modname=\'Extensions\' type=\'admin\' func=\'remove\' csrftoken=$csrftoken}\" title=\"{gt text=\'Uninstall ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append("\'}\">{gt text=\'Uninstall ");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "    ");
    _builder.append("\'}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{modurl modname=\'Extensions\' type=\'admin\' func=\'view\'}\" title=\"{gt text=\'Cancel uninstallation\'}\">{gt text=\'Cancel\'}</a>");
    _builder.newLine();
    _builder.append("</p>");
    _builder.newLine();
    return _builder;
  }
}
