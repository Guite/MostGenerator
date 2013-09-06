package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Atom {
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
  
  public void generate(final Entity it, final String appName, final Controller controller, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " atom view templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    String _name_1 = it.getName();
    String _templateFileWithExtension = this._namingExtensions.templateFileWithExtension(controller, _name_1, "view", "atom");
    CharSequence _atomView = this.atomView(it, appName, controller);
    fsa.generateFile(_templateFileWithExtension, _atomView);
  }
  
  private CharSequence atomView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" atom feed in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("TemplateHeaders contentType=\'application/atom+xml\'}<?xml version=\"1.0\" encoding=\"{charset assign=\'charset\'}{if $charset eq \'ISO-8859-15\'}ISO-8859-1{else}{$charset}{/if}\" ?>");
    _builder.newLineIfNotEmpty();
    _builder.append("<feed xmlns=\"http://www.w3.org/2005/Atom\">");
    _builder.newLine();
    _builder.append("{gt text=\'Latest ");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("\' assign=\'channelTitle\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{gt text=\'A direct feed showing the list of ");
    String _nameMultiple_2 = it.getNameMultiple();
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_nameMultiple_2);
    _builder.append(_formatForDisplay_2, "");
    _builder.append("\' assign=\'channelDesc\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<title type=\"text\">{$channelTitle}</title>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<subtitle type=\"text\">{$channelDesc} - {$modvars.ZConfig.slogan}</subtitle>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<author>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<name>{$modvars.ZConfig.sitename}</name>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</author>");
    _builder.newLine();
    _builder.append("{assign var=\'numItems\' value=$items|@count}");
    _builder.newLine();
    _builder.append("{if $numItems}");
    _builder.newLine();
    _builder.append("{capture assign=\'uniqueID\'}tag:{$baseurl|replace:\'http://\':\'\'|replace:\'/\':\'\'},{$items[0].createdDate|dateformat|default:$smarty.now|dateformat:\'%Y-%m-%d\'}:{modurl modname=\'");
    _builder.append(appName, "");
    _builder.append("\' type=\'");
    String _formattedName_1 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_1, "");
    _builder.append("\' ");
    {
      boolean _hasActions = this._controllerExtensions.hasActions(controller, "display");
      if (_hasActions) {
        String _modUrlDisplay = this._urlExtensions.modUrlDisplay(it, "items[0]", Boolean.valueOf(true));
        _builder.append(_modUrlDisplay, "");
      } else {
        _builder.append("func=\'");
        {
          boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "view");
          if (_hasActions_1) {
            _builder.append("view");
          } else {
            {
              Models _container = it.getContainer();
              Application _application = _container.getApplication();
              boolean _targets = this._utils.targets(_application, "1.3.5");
              if (_targets) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
          }
        }
        _builder.append("\' ot=\'");
        String _name_1 = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode, "");
        _builder.append("\'");
      }
    }
    _builder.append("}{/capture}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<id>{$uniqueID}</id>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<updated>{$items[0].updatedDate|default:$smarty.now|dateformat:\'%Y-%m-%dT%H:%M:%SZ\'}</updated>");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<link rel=\"alternate\" type=\"text/html\" hreflang=\"{lang}\" href=\"{modurl modname=\'");
    _builder.append(appName, "    ");
    _builder.append("\' type=\'");
    String _formattedName_2 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_2, "    ");
    _builder.append("\' func=\'");
    {
      boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "index");
      if (_hasActions_2) {
        {
          Models _container_1 = it.getContainer();
          Application _application_1 = _container_1.getApplication();
          boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
          if (_targets_1) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
      } else {
        EList<Action> _actions = controller.getActions();
        Action _head = IterableExtensions.<Action>head(_actions);
        String _name_2 = _head.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "    ");
      }
    }
    _builder.append("\' fqurl=1}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<link rel=\"self\" type=\"application/atom+xml\" href=\"{php}echo substr(\\System::getBaseURL(), 0, strlen(\\System::getBaseURL())-1);{/php}{getcurrenturi}\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<rights>Copyright (c) {php}echo date(\'Y\');{/php}, {$baseurl}</rights>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{foreach item=\'");
    _builder.append(objName, "");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<entry>");
    _builder.newLine();
    _builder.append("        ");
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("        ");
        _builder.append("<title type=\"html\">{$");
        _builder.append(objName, "        ");
        _builder.append(".");
        String _name_3 = leadingField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_2, "        ");
        _builder.append("|notifyfilters:\'");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_1, "        ");
        _builder.append(".filterhook.");
        String _nameMultiple_3 = it.getNameMultiple();
        String _formatForDB_2 = this._formattingExtensions.formatForDB(_nameMultiple_3);
        _builder.append(_formatForDB_2, "        ");
        _builder.append("\'}</title>");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("        ");
        _builder.append("<title type=\"html\">{gt text=\'");
        String _name_4 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("\'}</title>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("<link rel=\"alternate\" type=\"text/html\" href=\"{modurl modname=\'");
    _builder.append(appName, "        ");
    _builder.append("\' type=\'");
    String _formattedName_3 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_3, "        ");
    _builder.append("\' ");
    {
      boolean _hasActions_3 = this._controllerExtensions.hasActions(controller, "display");
      if (_hasActions_3) {
        String _modUrlDisplay_1 = this._urlExtensions.modUrlDisplay(it, objName, Boolean.valueOf(true));
        _builder.append(_modUrlDisplay_1, "        ");
      } else {
        _builder.append("func=\'");
        {
          boolean _hasActions_4 = this._controllerExtensions.hasActions(controller, "view");
          if (_hasActions_4) {
            _builder.append("view");
          } else {
            {
              Models _container_2 = it.getContainer();
              Application _application_2 = _container_2.getApplication();
              boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
              if (_targets_2) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
          }
        }
        _builder.append("\' ot=\'");
        String _name_5 = it.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode_3, "        ");
        _builder.append("\'");
      }
    }
    _builder.append(" fqurl=\'1\'}\" />");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{capture assign=\'uniqueID\'}tag:{$baseurl|replace:\'http://\':\'\'|replace:\'/\':\'\'},{$");
    _builder.append(objName, "        ");
    _builder.append(".createdDate|dateformat|default:$smarty.now|dateformat:\'%Y-%m-%d\'}:{modurl modname=\'");
    _builder.append(appName, "        ");
    _builder.append("\' type=\'");
    String _formattedName_4 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_4, "        ");
    _builder.append("\' ");
    {
      boolean _hasActions_5 = this._controllerExtensions.hasActions(controller, "display");
      if (_hasActions_5) {
        String _modUrlDisplay_2 = this._urlExtensions.modUrlDisplay(it, objName, Boolean.valueOf(true));
        _builder.append(_modUrlDisplay_2, "        ");
      } else {
        _builder.append("func=\'");
        {
          boolean _hasActions_6 = this._controllerExtensions.hasActions(controller, "view");
          if (_hasActions_6) {
            _builder.append("view");
          } else {
            {
              Models _container_3 = it.getContainer();
              Application _application_3 = _container_3.getApplication();
              boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
              if (_targets_3) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
          }
        }
        _builder.append("\' ot=\'");
        String _name_6 = it.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_4, "        ");
        _builder.append("\'");
      }
    }
    _builder.append("}{/capture}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<id>{$uniqueID}</id>");
    _builder.newLine();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("        ");
        _builder.append("{if isset($");
        _builder.append(objName, "        ");
        _builder.append(".updatedDate) && $");
        _builder.append(objName, "        ");
        _builder.append(".updatedDate ne null}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<updated>{$");
        _builder.append(objName, "            ");
        _builder.append(".updatedDate|dateformat:\'%Y-%m-%dT%H:%M:%SZ\'}</updated>");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{if isset($");
        _builder.append(objName, "        ");
        _builder.append(".createdDate) && $");
        _builder.append(objName, "        ");
        _builder.append(".createdDate ne null}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<published>{$");
        _builder.append(objName, "            ");
        _builder.append(".createdDate|dateformat:\'%Y-%m-%dT%H:%M:%SZ\'}</published>");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    {
      boolean _isStandardFields_1 = it.isStandardFields();
      boolean _not = (!_isStandardFields_1);
      if (_not) {
        {
          boolean _isMetaData = it.isMetaData();
          if (_isMetaData) {
            _builder.append("        ");
            _builder.append("{if isset($");
            _builder.append(objName, "        ");
            _builder.append(".__META__) && isset($");
            _builder.append(objName, "        ");
            _builder.append(".__META__.author)}");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<author>{$");
            _builder.append(objName, "            ");
            _builder.append(".__META__.author}</author>");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("{/if}");
            _builder.newLine();
          }
        }
      } else {
        _builder.append("        ");
        _builder.append("{if isset($");
        _builder.append(objName, "        ");
        _builder.append(".createdUserId)}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{usergetvar name=\'uname\' uid=$");
        _builder.append(objName, "            ");
        _builder.append(".createdUserId assign=\'cr_uname\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{usergetvar name=\'name\' uid=$");
        _builder.append(objName, "            ");
        _builder.append(".createdUserId assign=\'cr_name\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<author>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("       ");
        _builder.append("<name>{$cr_name|default:$cr_uname}</name>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("       ");
        _builder.append("<uri>{usergetvar name=\'_UYOURHOMEPAGE\' uid=$");
        _builder.append(objName, "               ");
        _builder.append(".createdUserId assign=\'homepage\'}{$homepage|default:\'-\'}</uri>");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("       ");
        _builder.append("<email>{usergetvar name=\'email\' uid=$");
        _builder.append(objName, "               ");
        _builder.append(".createdUserId}</email>");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("</author>");
        _builder.newLine();
        {
          boolean _isMetaData_1 = it.isMetaData();
          if (_isMetaData_1) {
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("{elseif isset($");
            _builder.append(objName, "            ");
            _builder.append(".__META__) && isset($");
            _builder.append(objName, "            ");
            _builder.append(".__META__.author)}");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<author>{$");
            _builder.append(objName, "            ");
            _builder.append(".__META__.author}</author>");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("        ");
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    EList<EntityField> _fields = it.getFields();
    Iterable<TextField> _filter = Iterables.<TextField>filter(_fields, TextField.class);
    final Function1<TextField,Boolean> _function = new Function1<TextField,Boolean>() {
      public Boolean apply(final TextField e) {
        boolean _isLeading = e.isLeading();
        boolean _not = (!_isLeading);
        return Boolean.valueOf(_not);
      }
    };
    final Iterable<TextField> textFields = IterableExtensions.<TextField>filter(_filter, _function);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    EList<EntityField> _fields_1 = it.getFields();
    Iterable<StringField> _filter_1 = Iterables.<StringField>filter(_fields_1, StringField.class);
    final Function1<StringField,Boolean> _function_1 = new Function1<StringField,Boolean>() {
      public Boolean apply(final StringField e) {
        boolean _isLeading = e.isLeading();
        boolean _not = (!_isLeading);
        return Boolean.valueOf(_not);
      }
    };
    final Iterable<StringField> stringFields = IterableExtensions.<StringField>filter(_filter_1, _function_1);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<summary type=\"html\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<![CDATA[");
    _builder.newLine();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(textFields);
      boolean _not_1 = (!_isEmpty);
      if (_not_1) {
        _builder.append("            ");
        _builder.append("{$");
        _builder.append(objName, "            ");
        _builder.append(".");
        TextField _head_1 = IterableExtensions.<TextField>head(textFields);
        String _name_7 = _head_1.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_7);
        _builder.append(_formatForCode_5, "            ");
        _builder.append("|truncate:150:\"&hellip;\"|default:\'-\'}");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isEmpty_1 = IterableExtensions.isEmpty(stringFields);
        boolean _not_2 = (!_isEmpty_1);
        if (_not_2) {
          _builder.append("            ");
          _builder.append("{$");
          _builder.append(objName, "            ");
          _builder.append(".");
          StringField _head_2 = IterableExtensions.<StringField>head(stringFields);
          String _name_8 = _head_2.getName();
          String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_8);
          _builder.append(_formatForCode_6, "            ");
          _builder.append("|truncate:150:\"&hellip;\"|default:\'-\'}");
          _builder.newLineIfNotEmpty();
        } else {
          {
            boolean _tripleNotEquals_1 = (leadingField != null);
            if (_tripleNotEquals_1) {
              _builder.append("            ");
              _builder.append("{$");
              _builder.append(objName, "            ");
              _builder.append(".");
              String _name_9 = leadingField.getName();
              String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_9);
              _builder.append(_formatForCode_7, "            ");
              _builder.append("|truncate:150:\"&hellip;\"|default:\'-\'}");
              _builder.newLineIfNotEmpty();
            }
          }
        }
      }
    }
    _builder.append("            ");
    _builder.append("]]>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</summary>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<content type=\"html\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<![CDATA[");
    _builder.newLine();
    {
      int _size = IterableExtensions.size(textFields);
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        _builder.append("            ");
        _builder.append("{$");
        _builder.append(objName, "            ");
        _builder.append(".");
        Iterable<TextField> _tail = IterableExtensions.<TextField>tail(textFields);
        TextField _head_3 = IterableExtensions.<TextField>head(_tail);
        String _name_10 = _head_3.getName();
        String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_10);
        _builder.append(_formatForCode_8, "            ");
        _builder.append("|replace:\'<br>\':\'<br />\'}");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _and = false;
        boolean _isEmpty_2 = IterableExtensions.isEmpty(textFields);
        boolean _not_3 = (!_isEmpty_2);
        if (!_not_3) {
          _and = false;
        } else {
          boolean _isEmpty_3 = IterableExtensions.isEmpty(stringFields);
          boolean _not_4 = (!_isEmpty_3);
          _and = (_not_3 && _not_4);
        }
        if (_and) {
          _builder.append("            ");
          _builder.append("{$");
          _builder.append(objName, "            ");
          _builder.append(".");
          StringField _head_4 = IterableExtensions.<StringField>head(stringFields);
          String _name_11 = _head_4.getName();
          String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_11);
          _builder.append(_formatForCode_9, "            ");
          _builder.append("|replace:\'<br>\':\'<br />\'}");
          _builder.newLineIfNotEmpty();
        } else {
          int _size_1 = IterableExtensions.size(stringFields);
          boolean _greaterThan_1 = (_size_1 > 1);
          if (_greaterThan_1) {
            _builder.append("            ");
            _builder.append("{$");
            _builder.append(objName, "            ");
            _builder.append(".");
            Iterable<StringField> _tail_1 = IterableExtensions.<StringField>tail(stringFields);
            StringField _head_5 = IterableExtensions.<StringField>head(_tail_1);
            String _name_12 = _head_5.getName();
            String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_12);
            _builder.append(_formatForCode_10, "            ");
            _builder.append("|replace:\'<br>\':\'<br />\'}");
            _builder.newLineIfNotEmpty();
          } else {
            {
              boolean _tripleNotEquals_2 = (leadingField != null);
              if (_tripleNotEquals_2) {
                _builder.append("            ");
                _builder.append("{$");
                _builder.append(objName, "            ");
                _builder.append(".");
                String _name_13 = leadingField.getName();
                String _formatForCode_11 = this._formattingExtensions.formatForCode(_name_13);
                _builder.append(_formatForCode_11, "            ");
                _builder.append("|replace:\'<br>\':\'<br />\'}");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    _builder.append("            ");
    _builder.append("]]>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</content>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</entry>");
    _builder.newLine();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("</feed>");
    _builder.newLine();
    return _builder;
  }
}
