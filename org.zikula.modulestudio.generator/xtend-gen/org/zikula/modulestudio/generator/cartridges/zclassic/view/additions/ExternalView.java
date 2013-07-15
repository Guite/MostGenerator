package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ExternalView {
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
  
  private SimpleFields fieldHelper = new Function0<SimpleFields>() {
    public SimpleFields apply() {
      SimpleFields _simpleFields = new SimpleFields();
      return _simpleFields;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      {
        String _viewPath = this._namingExtensions.getViewPath(it);
        String _xifexpression = null;
        boolean _targets = this._utils.targets(it, "1.3.5");
        if (_targets) {
          String _name = entity.getName();
          String _formatForCode = this._formattingExtensions.formatForCode(_name);
          String _plus = ("external/" + _formatForCode);
          _xifexpression = _plus;
        } else {
          String _name_1 = entity.getName();
          String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
          String _plus_1 = ("External/" + _formatForCodeCapital);
          _xifexpression = _plus_1;
        }
        String _plus_2 = (_viewPath + _xifexpression);
        final String templatePath = (_plus_2 + "/");
        String _plus_3 = (templatePath + "display.tpl");
        CharSequence _displayTemplate = this.displayTemplate(entity, it);
        fsa.generateFile(_plus_3, _displayTemplate);
        String _plus_4 = (templatePath + "info.tpl");
        CharSequence _itemInfoTemplate = this.itemInfoTemplate(entity, it);
        fsa.generateFile(_plus_4, _itemInfoTemplate);
        String _plus_5 = (templatePath + "find.tpl");
        CharSequence _findTemplate = this.findTemplate(entity, it);
        fsa.generateFile(_plus_5, _findTemplate);
        String _plus_6 = (templatePath + "select.tpl");
        CharSequence _selectTemplate = this.selectTemplate(entity, it);
        fsa.generateFile(_plus_6, _selectTemplate);
      }
    }
  }
  
  private CharSequence displayTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display one certain ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append(" within an external context *}");
    _builder.newLineIfNotEmpty();
    _builder.append("<div id=\"");
    String _name_1 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode, "");
    _builder.append("{$");
    String _name_2 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_1, "");
    _builder.append(".");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_3 = _firstPrimaryKey.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode_2, "");
    _builder.append("}\" class=\"");
    String _prefix = this._utils.prefix(app);
    _builder.append(_prefix, "");
    _builder.append("external");
    String _name_4 = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_4);
    _builder.append(_formatForDB, "");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{if $displayMode eq \'link\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p");
    {
      boolean _hasUserController = this._controllerExtensions.hasUserController(app);
      if (_hasUserController) {
        _builder.append(" class=\"");
        String _prefix_1 = this._utils.prefix(app);
        _builder.append(_prefix_1, "    ");
        _builder.append("externallink\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUserController_1 = this._controllerExtensions.hasUserController(app);
      if (_hasUserController_1) {
        _builder.append("    ");
        _builder.append("<a href=\"{modurl modname=\'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("\' type=\'user\' ");
        String _name_5 = it.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
        String _modUrlDisplay = this._urlExtensions.modUrlDisplay(it, _formatForCode_3, Boolean.valueOf(true));
        _builder.append(_modUrlDisplay, "    ");
        _builder.append("}\" title=\"{$");
        String _name_6 = it.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_4, "    ");
        _builder.append(".");
        DerivedField _leadingField = this._modelExtensions.getLeadingField(it);
        String _name_7 = _leadingField.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_7);
        _builder.append(_formatForCode_5, "    ");
        _builder.append("|replace:\"\\\"\":\"\"}\">");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("{$");
    String _name_8 = it.getName();
    String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_8);
    _builder.append(_formatForCode_6, "    ");
    _builder.append(".");
    DerivedField _leadingField_1 = this._modelExtensions.getLeadingField(it);
    String _name_9 = _leadingField_1.getName();
    String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_9);
    _builder.append(_formatForCode_7, "    ");
    _builder.append("|notifyfilters:\'");
    String _name_10 = app.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_10);
    _builder.append(_formatForDB_1, "    ");
    _builder.append(".filter_hooks.");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_nameMultiple);
    _builder.append(_formatForDB_2, "    ");
    _builder.append(".filter\'}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUserController_2 = this._controllerExtensions.hasUserController(app);
      if (_hasUserController_2) {
        _builder.append("    ");
        _builder.append("</a>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{checkpermissionblock component=\'");
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1, "");
    _builder.append("::\' instance=\'::\' level=\'ACCESS_EDIT\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if $displayMode eq \'embed\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<p class=\"");
    String _prefix_2 = this._utils.prefix(app);
    _builder.append(_prefix_2, "        ");
    _builder.append("externaltitle\">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<strong>{$");
    String _name_11 = it.getName();
    String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_11);
    _builder.append(_formatForCode_8, "            ");
    _builder.append(".");
    DerivedField _leadingField_2 = this._modelExtensions.getLeadingField(it);
    String _name_12 = _leadingField_2.getName();
    String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_12);
    _builder.append(_formatForCode_9, "            ");
    _builder.append("|notifyfilters:\'");
    String _name_13 = app.getName();
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_name_13);
    _builder.append(_formatForDB_3, "            ");
    _builder.append(".filter_hooks.");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForDB_4 = this._formattingExtensions.formatForDB(_nameMultiple_1);
    _builder.append(_formatForDB_4, "            ");
    _builder.append(".filter\'}</strong>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/checkpermissionblock}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{if $displayMode eq \'link\'}");
    _builder.newLine();
    _builder.append("{elseif $displayMode eq \'embed\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    String _prefix_3 = this._utils.prefix(app);
    _builder.append(_prefix_3, "    ");
    _builder.append("externalsnippet\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _displaySnippet = this.displaySnippet(it);
    _builder.append(_displaySnippet, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{* you can distinguish the context like this: *}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{*if $source eq \'contentType\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("...");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{elseif $source eq \'scribite\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("...");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if*}");
    _builder.newLine();
    {
      boolean _or = false;
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _or = true;
      } else {
        boolean _isCategorisable = it.isCategorisable();
        _or = (_hasAbstractStringFieldsEntity || _isCategorisable);
      }
      if (_or) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{* you can enable more details about the item: *}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<p class=\"");
        String _prefix_4 = this._utils.prefix(app);
        _builder.append(_prefix_4, "        ");
        _builder.append("externaldesc\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        CharSequence _displayDescription = this.displayDescription(it, "", "<br />");
        _builder.append(_displayDescription, "            ");
        _builder.newLineIfNotEmpty();
        {
          boolean _isCategorisable_1 = it.isCategorisable();
          if (_isCategorisable_1) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{assignedcategorieslist categories=$");
            String _name_14 = it.getName();
            String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_14);
            _builder.append(_formatForCode_10, "            ");
            _builder.append(".categories doctrine2=true}");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("</p>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("*}");
        _builder.newLine();
      }
    }
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displaySnippet(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        Iterable<UploadField> _imageFieldsEntity = this._modelExtensions.getImageFieldsEntity(it);
        final UploadField imageField = IterableExtensions.<UploadField>head(_imageFieldsEntity);
        _builder.newLineIfNotEmpty();
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        CharSequence _displayField = this.fieldHelper.displayField(imageField, _formatForCode, "display");
        _builder.append(_displayField, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("&nbsp;");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence displayDescription(final Entity it, final String praefix, final String suffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        {
          boolean _hasTextFieldsEntity = this._modelExtensions.hasTextFieldsEntity(it);
          if (_hasTextFieldsEntity) {
            _builder.append("{if $");
            String _name = it.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "");
            _builder.append(".");
            Iterable<TextField> _textFieldsEntity = this._modelExtensions.getTextFieldsEntity(it);
            TextField _head = IterableExtensions.<TextField>head(_textFieldsEntity);
            String _name_1 = _head.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "");
            _builder.append(" ne \'\'}");
            _builder.append(praefix, "");
            _builder.append("{$");
            String _name_2 = it.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
            _builder.append(_formatForCode_2, "");
            _builder.append(".");
            Iterable<TextField> _textFieldsEntity_1 = this._modelExtensions.getTextFieldsEntity(it);
            TextField _head_1 = IterableExtensions.<TextField>head(_textFieldsEntity_1);
            String _name_3 = _head_1.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
            _builder.append(_formatForCode_3, "");
            _builder.append("}");
            _builder.append(suffix, "");
            _builder.append("{/if}");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _hasStringFieldsEntity = this._modelExtensions.hasStringFieldsEntity(it);
            if (_hasStringFieldsEntity) {
              _builder.append("{if $");
              String _name_4 = it.getName();
              String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_4);
              _builder.append(_formatForCode_4, "");
              _builder.append(".");
              Iterable<StringField> _stringFieldsEntity = this._modelExtensions.getStringFieldsEntity(it);
              StringField _head_2 = IterableExtensions.<StringField>head(_stringFieldsEntity);
              String _name_5 = _head_2.getName();
              String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_5);
              _builder.append(_formatForCode_5, "");
              _builder.append(" ne \'\'}");
              _builder.append(praefix, "");
              _builder.append("{$");
              String _name_6 = it.getName();
              String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_6);
              _builder.append(_formatForCode_6, "");
              _builder.append(".");
              Iterable<StringField> _stringFieldsEntity_1 = this._modelExtensions.getStringFieldsEntity(it);
              StringField _head_3 = IterableExtensions.<StringField>head(_stringFieldsEntity_1);
              String _name_7 = _head_3.getName();
              String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_7);
              _builder.append(_formatForCode_7, "");
              _builder.append("}");
              _builder.append(suffix, "");
              _builder.append("{/if}");
              _builder.newLineIfNotEmpty();
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence itemInfoTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display item information for previewing from other modules *}");
    _builder.newLine();
    _builder.append("<dl id=\"");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("{$");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append(".");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_2 = _firstPrimaryKey.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "");
    _builder.append("}\">");
    _builder.newLineIfNotEmpty();
    _builder.append("<dt>{$");
    String _name_3 = it.getName();
    String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode_3, "");
    _builder.append(".");
    DerivedField _leadingField = this._modelExtensions.getLeadingField(it);
    String _name_4 = _leadingField.getName();
    String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_4);
    _builder.append(_formatForCode_4, "");
    _builder.append("|notifyfilters:\'");
    String _name_5 = app.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_5);
    _builder.append(_formatForDB, "");
    _builder.append(".filter_hooks.");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_nameMultiple);
    _builder.append(_formatForDB_1, "");
    _builder.append(".filter\'|htmlentities}</dt>");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        _builder.append("<dd>");
        CharSequence _displaySnippet = this.displaySnippet(it);
        _builder.append(_displaySnippet, "");
        _builder.append("</dd>");
        _builder.newLineIfNotEmpty();
      }
    }
    CharSequence _displayDescription = this.displayDescription(it, "<dd>", "</dd>");
    _builder.append(_displayDescription, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("<dd>{assignedcategorieslist categories=$");
        String _name_6 = it.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_5, "");
        _builder.append(".categories doctrine2=true}</dd>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</dl>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence findTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display a popup selector of ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" for scribite integration *}");
    _builder.newLineIfNotEmpty();
    _builder.append("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">");
    _builder.newLine();
    _builder.append("<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"{lang}\" lang=\"{lang}\">");
    _builder.newLine();
    _builder.append("<head>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<title>{gt text=\'Search and select ");
    String _name = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\'}</title>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<link type=\"text/css\" rel=\"stylesheet\" href=\"{$baseurl}style/core.css\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<link type=\"text/css\" rel=\"stylesheet\" href=\"{$baseurl}modules/");
    String _appName = this._utils.appName(app);
    _builder.append(_appName, "    ");
    _builder.append("/");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("style/");
      } else {
        String _appCssPath = this._namingExtensions.getAppCssPath(app);
        _builder.append(_appCssPath, "    ");
      }
    }
    _builder.append("style.css\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<link type=\"text/css\" rel=\"stylesheet\" href=\"{$baseurl}modules/");
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1, "    ");
    _builder.append("/");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("style/");
      } else {
        String _appCssPath_1 = this._namingExtensions.getAppCssPath(app);
        _builder.append(_appCssPath_1, "    ");
      }
    }
    _builder.append("finder.css\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{assign var=\'ourEntry\' value=$modvars.ZConfig.entrypoint}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\">/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (typeof(Zikula) == \'undefined\') {var Zikula = {};}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Zikula.Config = {\'entrypoint\': \'{{$ourEntry|default:\'index.php\'}}\', \'baseURL\': \'{{$baseurl}}\'}; /* ]]> */</script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/ajax/proto_scriptaculous.combined.min.js\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/helpers/Zikula.js\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/livepipe/livepipe.combined.min.js\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/helpers/Zikula.UI.js\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/helpers/Zikula.ImageViewer.js\"></script>");
    _builder.newLine();
    _builder.append("{*            <script type=\"text/javascript\" src=\"{$baseurl}javascript/ajax/original_uncompressed/prototype.js\"></script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/ajax/original_uncompressed/scriptaculous.js\"></script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/ajax/original_uncompressed/dragdrop.js\"></script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/ajax/original_uncompressed/effects.js\"></script>*}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}modules/");
    String _appName_2 = this._utils.appName(app);
    _builder.append(_appName_2, "    ");
    _builder.append("/");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("javascript/");
      } else {
        String _appJsPath = this._namingExtensions.getAppJsPath(app);
        _builder.append(_appJsPath, "    ");
      }
    }
    String _appName_3 = this._utils.appName(app);
    _builder.append(_appName_3, "    ");
    _builder.append("_finder.js\"></script>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_3 = this._utils.targets(app, "1.3.5");
      if (_targets_3) {
        _builder.append("{if $editorName eq \'tinymce\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}modules/Scribite/includes/tinymce/tiny_mce_popup.js\"></script>");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.append("</head>");
    _builder.newLine();
    _builder.append("<body>");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(app);
      int _size = _allEntities.size();
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        _builder.append("    ");
        _builder.append("<p>{gt text=\'Switch to\'}:");
        _builder.newLine();
        {
          EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(app);
          final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
              public Boolean apply(final Entity e) {
                String _name = e.getName();
                String _name_1 = it.getName();
                boolean _notEquals = (!Objects.equal(_name, _name_1));
                return Boolean.valueOf(_notEquals);
              }
            };
          Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities_1, _function);
          boolean _hasElements = false;
          for(final Entity entity : _filter) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(" | ", "    ");
            }
            _builder.append("    ");
            _builder.append("<a href=\"{modurl modname=\'");
            String _appName_4 = this._utils.appName(app);
            _builder.append(_appName_4, "    ");
            _builder.append("\' type=\'external\' func=\'finder\' objectType=\'");
            String _name_1 = entity.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode, "    ");
            _builder.append("\' editor=$editorName}\" title=\"{gt text=\'Search and select ");
            String _name_2 = entity.getName();
            String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_2);
            _builder.append(_formatForDisplay_2, "    ");
            _builder.append("\'}\">{gt text=\'");
            String _nameMultiple_1 = entity.getNameMultiple();
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_nameMultiple_1);
            _builder.append(_formatForDisplayCapital, "    ");
            _builder.append("\'}</a>");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("</p>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("<form action=\"{$ourEntry|default:\'index.php\'}\" id=\"selectorForm\" method=\"get\" class=\"z-form\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"module\" value=\"");
    String _appName_5 = this._utils.appName(app);
    _builder.append(_appName_5, "        ");
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"type\" value=\"external\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"func\" value=\"finder\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"objectType\" value=\"{$objectType}\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"editor\" id=\"editorName\" value=\"{$editorName}\" />");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<legend>{gt text=\'Search and select ");
    String _name_3 = it.getName();
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_3);
    _builder.append(_formatForDisplay_3, "            ");
    _builder.append("\'}</legend>");
    _builder.newLineIfNotEmpty();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{if $properties ne null && is_array($properties)}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("{gt text=\'All\' assign=\'lblDefault\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("{nocache}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("{foreach key=\'propertyName\' item=\'propertyId\' from=$properties}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("        ");
        _builder.append("<div class=\"z-formrow categoryselector\">");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("{modapifunc modname=\'");
        String _appName_6 = this._utils.appName(app);
        _builder.append(_appName_6, "                        ");
        _builder.append("\' type=\'category\' func=\'hasMultipleSelection\' ot=$objectType registry=$propertyName assign=\'hasMultiSelection\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("{gt text=\'Category\' assign=\'categoryLabel\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorId\' value=\'catid\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorName\' value=\'catid\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorSize\' value=\'1\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("{if $hasMultiSelection eq true}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("                ");
        _builder.append("{gt text=\'Categories\' assign=\'categoryLabel\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorName\' value=\'catids\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorId\' value=\'catids__\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorSize\' value=\'8\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("<label for=\"{$categorySelectorId}{$propertyName}\">{$categoryLabel}</label>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("&nbsp;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("{selector_category name=\"`$categorySelectorName``$propertyName`\" field=\'id\' selectedValue=$catIds.$propertyName categoryRegistryModule=\'");
        String _appName_7 = this._utils.appName(app);
        _builder.append(_appName_7, "                        ");
        _builder.append("\' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("<span class=\"z-sub z-formnote\">{gt text=\'This is an optional filter.\'}</span>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("{/nocache}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<label for=\"");
    String _appName_8 = this._utils.appName(app);
    _builder.append(_appName_8, "                ");
    _builder.append("_pasteas\">{gt text=\'Paste as\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<select id=\"");
    String _appName_9 = this._utils.appName(app);
    _builder.append(_appName_9, "                ");
    _builder.append("_pasteas\" name=\"pasteas\">");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("<option value=\"1\">{gt text=\'Link to the ");
    String _name_4 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_4);
    _builder.append(_formatForCode_1, "                    ");
    _builder.append("\'}</option>");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("<option value=\"2\">{gt text=\'ID of ");
    String _name_5 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_5);
    _builder.append(_formatForCode_2, "                    ");
    _builder.append("\'}</option>");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<br />");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<label for=\"");
    String _appName_10 = this._utils.appName(app);
    _builder.append(_appName_10, "                ");
    _builder.append("_objectid\">{gt text=\'");
    String _name_6 = it.getName();
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_6);
    _builder.append(_formatForDisplayCapital_1, "                ");
    _builder.append("\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<div id=\"");
    String _prefix = this._utils.prefix(app);
    _builder.append(_prefix, "                ");
    _builder.append("itemcontainer\">");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{foreach item=\'");
    String _name_7 = it.getName();
    String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_7);
    _builder.append(_formatForCode_3, "                    ");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("<li>");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("<a href=\"#\" onclick=\"");
    String _name_8 = app.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_8);
    _builder.append(_formatForDB, "                            ");
    _builder.append(".finder.selectItem({$");
    String _name_9 = it.getName();
    String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_9);
    _builder.append(_formatForCode_4, "                            ");
    _builder.append(".");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_10 = _firstPrimaryKey.getName();
    String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_10);
    _builder.append(_formatForCode_5, "                            ");
    _builder.append("})\" onkeypress=\"");
    String _name_11 = app.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_11);
    _builder.append(_formatForDB_1, "                            ");
    _builder.append(".finder.selectItem({$");
    String _name_12 = it.getName();
    String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_12);
    _builder.append(_formatForCode_6, "                            ");
    _builder.append(".");
    DerivedField _firstPrimaryKey_1 = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_13 = _firstPrimaryKey_1.getName();
    String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_13);
    _builder.append(_formatForCode_7, "                            ");
    _builder.append("})\">");
    _builder.newLineIfNotEmpty();
    _builder.append("                                ");
    _builder.append("{$");
    String _name_14 = it.getName();
    String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_14);
    _builder.append(_formatForCode_8, "                                ");
    _builder.append(".");
    DerivedField _leadingField = this._modelExtensions.getLeadingField(it);
    String _name_15 = _leadingField.getName();
    String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_15);
    _builder.append(_formatForCode_9, "                                ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("                            ");
    _builder.append("</a>");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("<input type=\"hidden\" id=\"url{$");
    String _name_16 = it.getName();
    String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_16);
    _builder.append(_formatForCode_10, "                            ");
    _builder.append(".");
    DerivedField _firstPrimaryKey_2 = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_17 = _firstPrimaryKey_2.getName();
    String _formatForCode_11 = this._formattingExtensions.formatForCode(_name_17);
    _builder.append(_formatForCode_11, "                            ");
    _builder.append("}\" value=\"");
    {
      boolean _hasUserController = this._controllerExtensions.hasUserController(app);
      if (_hasUserController) {
        _builder.append("{modurl modname=\'");
        String _appName_11 = this._utils.appName(app);
        _builder.append(_appName_11, "                            ");
        _builder.append("\' type=\'user\' ");
        String _name_18 = it.getName();
        String _formatForCode_12 = this._formattingExtensions.formatForCode(_name_18);
        String _modUrlDisplay = this._urlExtensions.modUrlDisplay(it, _formatForCode_12, Boolean.valueOf(true));
        _builder.append(_modUrlDisplay, "                            ");
        _builder.append(" fqurl=true}");
      }
    }
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("                            ");
    _builder.append("<input type=\"hidden\" id=\"title{$");
    String _name_19 = it.getName();
    String _formatForCode_13 = this._formattingExtensions.formatForCode(_name_19);
    _builder.append(_formatForCode_13, "                            ");
    _builder.append(".");
    DerivedField _firstPrimaryKey_3 = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_20 = _firstPrimaryKey_3.getName();
    String _formatForCode_14 = this._formattingExtensions.formatForCode(_name_20);
    _builder.append(_formatForCode_14, "                            ");
    _builder.append("}\" value=\"{$");
    String _name_21 = it.getName();
    String _formatForCode_15 = this._formattingExtensions.formatForCode(_name_21);
    _builder.append(_formatForCode_15, "                            ");
    _builder.append(".");
    DerivedField _leadingField_1 = this._modelExtensions.getLeadingField(it);
    String _name_22 = _leadingField_1.getName();
    String _formatForCode_16 = this._formattingExtensions.formatForCode(_name_22);
    _builder.append(_formatForCode_16, "                            ");
    _builder.append("|replace:\"\\\"\":\"\"}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("                            ");
    _builder.append("<input type=\"hidden\" id=\"desc{$");
    String _name_23 = it.getName();
    String _formatForCode_17 = this._formattingExtensions.formatForCode(_name_23);
    _builder.append(_formatForCode_17, "                            ");
    _builder.append(".");
    DerivedField _firstPrimaryKey_4 = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_24 = _firstPrimaryKey_4.getName();
    String _formatForCode_18 = this._formattingExtensions.formatForCode(_name_24);
    _builder.append(_formatForCode_18, "                            ");
    _builder.append("}\" value=\"{capture assign=\'description\'}");
    CharSequence _displayDescription = this.displayDescription(it, "", "");
    _builder.append(_displayDescription, "                            ");
    _builder.append("{/capture}{$description|strip_tags|replace:\"\\\"\":\"\"}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("</li>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("<li>{gt text=\'No entries found.\'}</li>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<label for=\"");
    String _appName_12 = this._utils.appName(app);
    _builder.append(_appName_12, "                ");
    _builder.append("_sort\">{gt text=\'Sort by\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<select id=\"");
    String _appName_13 = this._utils.appName(app);
    _builder.append(_appName_13, "                ");
    _builder.append("_sort\" name=\"sort\" style=\"width: 150px\" class=\"z-floatleft\" style=\"margin-right: 10px\">");
    _builder.newLineIfNotEmpty();
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField field : _derivedFields) {
        _builder.append("                ");
        _builder.append("<option value=\"");
        String _name_25 = field.getName();
        String _formatForCode_19 = this._formattingExtensions.formatForCode(_name_25);
        _builder.append(_formatForCode_19, "                ");
        _builder.append("\"{if $sort eq \'");
        String _name_26 = field.getName();
        String _formatForCode_20 = this._formattingExtensions.formatForCode(_name_26);
        _builder.append(_formatForCode_20, "                ");
        _builder.append("\'} selected=\"selected\"{/if}>{gt text=\'");
        String _name_27 = field.getName();
        String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(_name_27);
        _builder.append(_formatForDisplayCapital_2, "                ");
        _builder.append("\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("                ");
        _builder.append("<option value=\"createdDate\"{if $sort eq \'createdDate\'} selected=\"selected\"{/if}>{gt text=\'Creation date\'}</option>");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("<option value=\"createdUserId\"{if $sort eq \'createdUserId\'} selected=\"selected\"{/if}>{gt text=\'Creator\'}</option>");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("<option value=\"updatedDate\"{if $sort eq \'updatedDate\'} selected=\"selected\"{/if}>{gt text=\'Update date\'}</option>");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<select id=\"");
    String _appName_14 = this._utils.appName(app);
    _builder.append(_appName_14, "                ");
    _builder.append("_sortdir\" name=\"sortdir\" style=\"width: 100px\">");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("<option value=\"asc\"{if $sortdir eq \'asc\'} selected=\"selected\"{/if}>{gt text=\'ascending\'}</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"desc\"{if $sortdir eq \'desc\'} selected=\"selected\"{/if}>{gt text=\'descending\'}</option>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<label for=\"");
    String _appName_15 = this._utils.appName(app);
    _builder.append(_appName_15, "                ");
    _builder.append("_pagesize\">{gt text=\'Page size\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<select id=\"");
    String _appName_16 = this._utils.appName(app);
    _builder.append(_appName_16, "                ");
    _builder.append("_pagesize\" name=\"num\" style=\"width: 50px; text-align: right\">");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("<option value=\"5\"{if $pager.itemsperpage eq 5} selected=\"selected\"{/if}>5</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"10\"{if $pager.itemsperpage eq 10} selected=\"selected\"{/if}>10</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"15\"{if $pager.itemsperpage eq 15} selected=\"selected\"{/if}>15</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"20\"{if $pager.itemsperpage eq 20} selected=\"selected\"{/if}>20</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"30\"{if $pager.itemsperpage eq 30} selected=\"selected\"{/if}>30</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"50\"{if $pager.itemsperpage eq 50} selected=\"selected\"{/if}>50</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"100\"{if $pager.itemsperpage eq 100} selected=\"selected\"{/if}>100</option>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _builder.append("            ");
        _builder.append("<div class=\"z-formrow\">");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("<label for=\"");
        String _appName_17 = this._utils.appName(app);
        _builder.append(_appName_17, "                ");
        _builder.append("_searchterm\">{gt text=\'Search for\'}:</label>");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("<input type=\"text\" id=\"");
        String _appName_18 = this._utils.appName(app);
        _builder.append(_appName_18, "                ");
        _builder.append("_searchterm\" name=\"searchterm\" style=\"width: 150px\" class=\"z-floatleft\" style=\"margin-right: 10px\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("<input type=\"button\" id=\"");
        String _appName_19 = this._utils.appName(app);
        _builder.append(_appName_19, "                ");
        _builder.append("_gosearch\" name=\"gosearch\" value=\"{gt text=\'Filter\'}\" style=\"width: 80px\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("<div style=\"margin-left: 6em\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{pager display=\'page\' rowcount=$pager.numitems limit=$pager.itemsperpage posvar=\'pos\' template=\'pagercss.tpl\' maxpages=\'10\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<input type=\"submit\" id=\"");
    String _appName_20 = this._utils.appName(app);
    _builder.append(_appName_20, "            ");
    _builder.append("_submit\" name=\"submitButton\" value=\"{gt text=\'Change selection\'}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<input type=\"button\" id=\"");
    String _appName_21 = this._utils.appName(app);
    _builder.append(_appName_21, "            ");
    _builder.append("_cancel\" name=\"cancelButton\" value=\"{gt text=\'Cancel\'}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<br />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</form>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("            ");
    String _name_28 = app.getName();
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_name_28);
    _builder.append(_formatForDB_2, "            ");
    _builder.append(".finder.onLoad();");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</script>");
    _builder.newLine();
    _builder.newLine();
    {
      Iterable<AdminController> _allAdminControllers = this._controllerExtensions.getAllAdminControllers(app);
      boolean _isEmpty = IterableExtensions.isEmpty(_allAdminControllers);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("    ");
        _builder.append("{*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"");
        String _prefix_1 = this._utils.prefix(app);
        _builder.append(_prefix_1, "    ");
        _builder.append("form\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<fieldset>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("{modfunc modname=\'");
        String _appName_22 = this._utils.appName(app);
        _builder.append(_appName_22, "            ");
        _builder.append("\' type=\'admin\' func=\'edit\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("</fieldset>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("*}");
        _builder.newLine();
      }
    }
    _builder.append("</body>");
    _builder.newLine();
    _builder.append("</html>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display a popup selector for Forms and Content integration *}");
    _builder.newLine();
    _builder.append("{assign var=\'baseID\' value=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("<div id=\"{$baseID}_preview\" style=\"float: right; width: 300px; border: 1px dotted #a3a3a3; padding: .2em .5em; margin-right: 1em\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p><strong>{gt text=\'");
    String _name_1 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append(" information\'}</strong></p>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{img id=\'ajax_indicator\' modname=\'core\' set=\'ajax\' src=\'indicator_circle.gif\' alt=\'\' class=\'z-hide\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div id=\"{$baseID}_previewcontainer\">&nbsp;</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("<br />");
    _builder.newLine();
    _builder.append("<br />");
    _builder.newLine();
    _builder.append("{assign var=\'leftSide\' value=\' style=\"float: left; width: 10em\"\'}");
    _builder.newLine();
    _builder.append("{assign var=\'rightSide\' value=\' style=\"float: left\"\'}");
    _builder.newLine();
    _builder.append("{assign var=\'break\' value=\' style=\"clear: left\"\'}");
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.newLine();
        _builder.append("{if $properties ne null && is_array($properties)}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{gt text=\'All\' assign=\'lblDefault\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{nocache}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{foreach key=\'propertyName\' item=\'propertyId\' from=$properties}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<p>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{modapifunc modname=\'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "            ");
        _builder.append("\' type=\'category\' func=\'hasMultipleSelection\' ot=\'");
        String _name_2 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "            ");
        _builder.append("\' registry=$propertyName assign=\'hasMultiSelection\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("{gt text=\'Category\' assign=\'categoryLabel\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorId\' value=\'catid\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorName\' value=\'catid\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorSize\' value=\'1\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{if $hasMultiSelection eq true}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{gt text=\'Categories\' assign=\'categoryLabel\'}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorName\' value=\'catids\'}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorId\' value=\'catids__\'}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorSize\' value=\'8\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<label for=\"{$baseID}_{$categorySelectorId}{$propertyName}\"{$leftSide}>{$categoryLabel}:</label>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("&nbsp;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{selector_category name=\"`$baseID`_`$categorySelectorName``$propertyName`\" field=\'id\' selectedValue=$catIds.$propertyName categoryRegistryModule=\'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "            ");
        _builder.append("\' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("<br{$break} />");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</p>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{/nocache}");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"{$baseID}_id\"{$leftSide}>{gt text=\'");
    String _name_3 = it.getName();
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_3);
    _builder.append(_formatForDisplayCapital_1, "    ");
    _builder.append("\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<select id=\"{$baseID}_id\" name=\"id\"{$rightSide}>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{foreach item=\'");
    String _name_4 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_4);
    _builder.append(_formatForCode_2, "        ");
    _builder.append("\' from=$items}{strip}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<option value=\"{$");
    String _name_5 = it.getName();
    String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
    _builder.append(_formatForCode_3, "            ");
    _builder.append(".");
    DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_6 = _firstPrimaryKey.getName();
    String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_6);
    _builder.append(_formatForCode_4, "            ");
    _builder.append("}\"{if $selectedId eq $");
    String _name_7 = it.getName();
    String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_7);
    _builder.append(_formatForCode_5, "            ");
    _builder.append(".");
    DerivedField _firstPrimaryKey_1 = this._modelExtensions.getFirstPrimaryKey(it);
    String _name_8 = _firstPrimaryKey_1.getName();
    String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_8);
    _builder.append(_formatForCode_6, "            ");
    _builder.append("} selected=\"selected\"{/if}>");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("{$");
    String _name_9 = it.getName();
    String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_9);
    _builder.append(_formatForCode_7, "                ");
    _builder.append(".");
    DerivedField _leadingField = this._modelExtensions.getLeadingField(it);
    String _name_10 = _leadingField.getName();
    String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_10);
    _builder.append(_formatForCode_8, "                ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("</option>{/strip}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<option value=\"0\">{gt text=\'No entries found.\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<br{$break} />");
    _builder.newLine();
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"{$baseID}_sort\"{$leftSide}>{gt text=\'Sort by\'}:</label>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<select id=\"{$baseID}_sort\" name=\"sort\"{$rightSide}>");
    _builder.newLine();
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField field : _derivedFields) {
        _builder.append("        ");
        _builder.append("<option value=\"");
        String _name_11 = field.getName();
        String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_11);
        _builder.append(_formatForCode_9, "        ");
        _builder.append("\"{if $sort eq \'");
        String _name_12 = field.getName();
        String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_12);
        _builder.append(_formatForCode_10, "        ");
        _builder.append("\'} selected=\"selected\"{/if}>{gt text=\'");
        String _name_13 = field.getName();
        String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(_name_13);
        _builder.append(_formatForDisplayCapital_2, "        ");
        _builder.append("\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("        ");
        _builder.append("<option value=\"createdDate\"{if $sort eq \'createdDate\'} selected=\"selected\"{/if}>{gt text=\'Creation date\'}</option>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<option value=\"createdUserId\"{if $sort eq \'createdUserId\'} selected=\"selected\"{/if}>{gt text=\'Creator\'}</option>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<option value=\"updatedDate\"{if $sort eq \'updatedDate\'} selected=\"selected\"{/if}>{gt text=\'Update date\'}</option>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<select id=\"{$baseID}_sortdir\" name=\"sortdir\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"asc\"{if $sortdir eq \'asc\'} selected=\"selected\"{/if}>{gt text=\'ascending\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"desc\"{if $sortdir eq \'desc\'} selected=\"selected\"{/if}>{gt text=\'descending\'}</option>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<br{$break} />");
    _builder.newLine();
    _builder.append("</p>");
    _builder.newLine();
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _builder.append("<p>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<label for=\"{$baseID}_searchterm\"{$leftSide}>{gt text=\'Search for\'}:</label>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<input type=\"text\" id=\"{$baseID}_searchterm\" name=\"searchterm\"{$rightSide} />");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<input type=\"button\" id=\"");
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "    ");
        _builder.append("_gosearch\" name=\"gosearch\" value=\"{gt text=\'Filter\'}\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<br{$break} />");
        _builder.newLine();
        _builder.append("</p>");
        _builder.newLine();
      }
    }
    _builder.append("<br />");
    _builder.newLine();
    _builder.append("<br />");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("        ");
    String _name_14 = app.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_14);
    _builder.append(_formatForDB, "        ");
    _builder.append(".itemSelector.onLoad(\'{{$baseID}}\', {{$selectedId|default:0}});");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
}
