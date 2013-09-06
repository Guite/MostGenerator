package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
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
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Styles {
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
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
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
  
  /**
   * Entry point for application styles.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appCssPath = this._namingExtensions.getAppCssPath(it);
    String _plus = (_appCssPath + "style.css");
    CharSequence _appStyles = this.appStyles(it);
    fsa.generateFile(_plus, _appStyles);
    String _appCssPath_1 = this._namingExtensions.getAppCssPath(it);
    String _plus_1 = (_appCssPath_1 + "finder.css");
    CharSequence _finderStyles = this.finderStyles(it);
    fsa.generateFile(_plus_1, _finderStyles);
  }
  
  private CharSequence appStyles(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/* view pages */");
    _builder.newLine();
    _builder.append("div#z-maincontent.z-module-");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append(" table tbody tr td {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("vertical-align: top;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/* display pages */");
    _builder.newLine();
    _builder.append(".");
    String _appName = this._utils.appName(it);
    String _lowerCase = _appName.toLowerCase();
    _builder.append(_lowerCase, "");
    _builder.append("-display.withrightbox div.z-panel-content {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("float: left;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("width: 79%;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append(".");
    String _appName_1 = this._utils.appName(it);
    String _lowerCase_1 = _appName_1.toLowerCase();
    _builder.append(_lowerCase_1, "");
    _builder.append("-display div.");
    String _appName_2 = this._utils.appName(it);
    String _lowerCase_2 = _appName_2.toLowerCase();
    _builder.append(_lowerCase_2, "");
    _builder.append("rightbox {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("float: right;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("margin: 0 1em;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("padding: .5em;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("width: 20%;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/*border: 1px solid #666;*/");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append(".");
    String _appName_3 = this._utils.appName(it);
    String _lowerCase_3 = _appName_3.toLowerCase();
    _builder.append(_lowerCase_3, "");
    _builder.append("-display div.");
    String _appName_4 = this._utils.appName(it);
    String _lowerCase_4 = _appName_4.toLowerCase();
    _builder.append(_lowerCase_4, "");
    _builder.append("rightbox h3 {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("color: #333;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("font-weight: 400;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("border-bottom: 1px solid #CCC;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("padding-bottom: 8px;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append(".");
    String _appName_5 = this._utils.appName(it);
    String _lowerCase_5 = _appName_5.toLowerCase();
    _builder.append(_lowerCase_5, "");
    _builder.append("-display div.");
    String _appName_6 = this._utils.appName(it);
    String _lowerCase_6 = _appName_6.toLowerCase();
    _builder.append(_lowerCase_6, "");
    _builder.append("rightbox p.manageLink {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("margin-left: 18px;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        _builder.newLine();
        _builder.append("div.");
        String _appName_7 = this._utils.appName(it);
        String _lowerCase_7 = _appName_7.toLowerCase();
        _builder.append(_lowerCase_7, "");
        _builder.append("mapcontainer {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("height: 400px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.newLine();
        _builder.append(".z-treecontainer {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("border: 1px solid #ccc;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("width: 400px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("float: left;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("margin-right: 16px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields) {
        _builder.append(".");
        String _appName_8 = this._utils.appName(it);
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_8);
        _builder.append(_formatForDB_1, "");
        _builder.append("ColourPicker {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("cursor: pointer;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    CharSequence _validationStyles = this.validationStyles(it);
    _builder.append(_validationStyles, "");
    _builder.newLineIfNotEmpty();
    CharSequence _autoCompletion = this.autoCompletion(it);
    _builder.append(_autoCompletion, "");
    _builder.newLineIfNotEmpty();
    CharSequence _viewFilterForm = this.viewFilterForm(it);
    _builder.append(_viewFilterForm, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isInteractiveInstallation = it.isInteractiveInstallation();
      if (_isInteractiveInstallation) {
        _builder.newLine();
        _builder.append("dl#");
        String _name_1 = it.getName();
        String _formatForDB_2 = this._formattingExtensions.formatForDB(_name_1);
        _builder.append(_formatForDB_2, "");
        _builder.append("featurelist {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("margin-left: 50px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append("dl#");
        String _name_2 = it.getName();
        String _formatForDB_3 = this._formattingExtensions.formatForDB(_name_2);
        _builder.append(_formatForDB_3, "");
        _builder.append("featurelist dt {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("font-weight: 700;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence validationStyles(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/* validation */");
    _builder.newLine();
    _builder.append("div.z-formrow input.required, div.z-formrow textarea.required {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("border: 1px solid #00a8e6;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("div.z-formrow input.validation-failed, div.z-formrow textarea.validation-failed {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("border: 1px solid #f30;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("color: #f30;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("div.z-formrow input.validation-passed, div.z-formrow textarea.validation-passed {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("border: 1px solid #0c0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("color: #000;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append(".validation-advice {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("margin: 5px 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("padding: 5px;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("background-color: #f90;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("color: #fff;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("font-weight: 700;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence autoCompletion(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    final boolean hasUserFields = this._modelExtensions.hasUserFields(it);
    _builder.newLineIfNotEmpty();
    final boolean hasImageFields = this._modelExtensions.hasImageFields(it);
    _builder.newLineIfNotEmpty();
    final Iterable<JoinRelationship> joinRelations = this._modelJoinExtensions.getJoinRelations(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _or = false;
      boolean _isEmpty = IterableExtensions.isEmpty(joinRelations);
      boolean _not = (!_isEmpty);
      if (_not) {
        _or = true;
      } else {
        _or = (_not || hasUserFields);
      }
      if (_or) {
        _builder.newLine();
        _builder.append("/* edit pages */");
        _builder.newLine();
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(joinRelations);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            _builder.append("div.");
            String _prefix = it.getPrefix();
            _builder.append(_prefix, "");
            _builder.append("RelationLeftSide {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("float: left;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("width: 25%;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
            _builder.append("div.");
            String _prefix_1 = it.getPrefix();
            _builder.append(_prefix_1, "");
            _builder.append("RelationRightSide {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("float: right;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("width: 65%;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
          }
        }
        _builder.append("/* hide legends if z-panels are used as both contain the same labels */");
        _builder.newLine();
        _builder.append("div.");
        String _name = it.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name);
        _builder.append(_formatForDB, "");
        _builder.append("-edit .z-panel-content legend {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("display: none;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        {
          if (hasUserFields) {
            _builder.append("div.");
            String _prefix_2 = it.getPrefix();
            _builder.append(_prefix_2, "");
            _builder.append("LiveSearchUser {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("margin: 0;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("div.");
        String _prefix_3 = it.getPrefix();
        _builder.append(_prefix_3, "");
        _builder.append("AutoCompleteWrap {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("position: absolute;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("height: 40px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("margin: 0;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("padding: 0;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("left: 260px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("top: 10px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("div.");
        String _prefix_4 = it.getPrefix();
        _builder.append(_prefix_4, "");
        _builder.append("AutoComplete");
        {
          if (hasUserFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_5 = it.getPrefix();
            _builder.append(_prefix_5, "");
            _builder.append("AutoCompleteUser");
          }
        }
        {
          if (hasImageFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_6 = it.getPrefix();
            _builder.append(_prefix_6, "");
            _builder.append("AutoCompleteWithImage");
          }
        }
        _builder.append(" {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("position: relative !important;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("top: 2px !important;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("width: 191px !important;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("background-color: #fff;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("border: 1px solid #888;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("margin: 0;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("padding: 0;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("div.");
        String _prefix_7 = it.getPrefix();
        _builder.append(_prefix_7, "");
        _builder.append("AutoComplete");
        {
          if (hasImageFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_8 = it.getPrefix();
            _builder.append(_prefix_8, "");
            _builder.append("AutoCompleteWithImage");
          }
        }
        _builder.append(" {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("left: 0 !important;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        {
          if (hasUserFields) {
            _builder.append("div.");
            String _prefix_9 = it.getPrefix();
            _builder.append(_prefix_9, "");
            _builder.append("AutoCompleteUser {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("left: 29% !important;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
          }
        }
        _builder.append("div.");
        String _prefix_10 = it.getPrefix();
        _builder.append(_prefix_10, "");
        _builder.append("AutoComplete ul");
        {
          if (hasUserFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_11 = it.getPrefix();
            _builder.append(_prefix_11, "");
            _builder.append("AutoCompleteUser ul");
          }
        }
        {
          if (hasImageFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_12 = it.getPrefix();
            _builder.append(_prefix_12, "");
            _builder.append("AutoCompleteWithImage ul");
          }
        }
        _builder.append(" {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("margin: 0;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("padding: 0;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("div.");
        String _prefix_13 = it.getPrefix();
        _builder.append(_prefix_13, "");
        _builder.append("AutoComplete ul li");
        {
          if (hasUserFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_14 = it.getPrefix();
            _builder.append(_prefix_14, "");
            _builder.append("AutoCompleteUser ul li");
          }
        }
        {
          if (hasImageFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_15 = it.getPrefix();
            _builder.append(_prefix_15, "");
            _builder.append("AutoCompleteWithImage ul li");
          }
        }
        _builder.append(" {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("margin: 0;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("padding: 0.2em 0 0.2em 20px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("list-style-type: none;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("line-height: 1.4em;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("cursor: pointer;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("display: block;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("background-position: 2px 2px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("background-repeat: no-repeat;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("div.");
        String _prefix_16 = it.getPrefix();
        _builder.append(_prefix_16, "");
        _builder.append("AutoComplete ul li {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("background-image: url(\"../../../images/icons/extrasmall/tab_right.png\");");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        {
          if (hasUserFields) {
            _builder.append("div.");
            String _prefix_17 = it.getPrefix();
            _builder.append(_prefix_17, "");
            _builder.append("AutoCompleteUser ul li {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("background-image: url(\"../../../images/icons/extrasmall/user.png\");");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          if (hasImageFields) {
            _builder.append("div.");
            String _prefix_18 = it.getPrefix();
            _builder.append(_prefix_18, "");
            _builder.append("AutoCompleteWithImage ul li {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("background-image: url(\"../../../images/icons/extrasmall/agt_Multimedia.png\");");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("div.");
        String _prefix_19 = it.getPrefix();
        _builder.append(_prefix_19, "");
        _builder.append("AutoComplete ul li.selected");
        {
          if (hasUserFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_20 = it.getPrefix();
            _builder.append(_prefix_20, "");
            _builder.append("AutoCompleteUser ul li.selected");
          }
        }
        {
          if (hasImageFields) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("div.");
            String _prefix_21 = it.getPrefix();
            _builder.append(_prefix_21, "");
            _builder.append("AutoCompleteWithImage ul li.selected");
          }
        }
        _builder.append(" {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("background-color: #ffb;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        {
          boolean _or_1 = false;
          if (hasImageFields) {
            _or_1 = true;
          } else {
            boolean _isEmpty_2 = IterableExtensions.isEmpty(joinRelations);
            boolean _not_2 = (!_isEmpty_2);
            _or_1 = (hasImageFields || _not_2);
          }
          if (_or_1) {
            _builder.append("div.");
            String _prefix_22 = it.getPrefix();
            _builder.append(_prefix_22, "");
            _builder.append("AutoComplete ul li div.itemtitle");
            {
              if (hasImageFields) {
                _builder.append(",");
                _builder.newLineIfNotEmpty();
                _builder.append("div.");
                String _prefix_23 = it.getPrefix();
                _builder.append(_prefix_23, "");
                _builder.append("AutoCompleteWithImage ul li div.itemtitle");
              }
            }
            _builder.append(" {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("font-weight: 700;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("font-size: 12px;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("line-height: 1.2em;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
            _builder.append("div.");
            String _prefix_24 = it.getPrefix();
            _builder.append(_prefix_24, "");
            _builder.append("AutoComplete ul li div.itemdesc");
            {
              if (hasImageFields) {
                _builder.append(",");
                _builder.newLineIfNotEmpty();
                _builder.append("div.");
                String _prefix_25 = it.getPrefix();
                _builder.append(_prefix_25, "");
                _builder.append("AutoCompleteWithImage ul li div.itemdesc");
              }
            }
            _builder.append(" {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("font-size: 10px;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("color: #888;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
            {
              boolean _isEmpty_3 = IterableExtensions.isEmpty(joinRelations);
              boolean _not_3 = (!_isEmpty_3);
              if (_not_3) {
                _builder.append("button.");
                String _prefix_26 = it.getPrefix();
                _builder.append(_prefix_26, "");
                _builder.append("InlineButton {");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("margin-top: 1em;");
                _builder.newLine();
                _builder.append("}");
                _builder.newLine();
              }
            }
          }
        }
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence viewFilterForm(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(it);
      final Function1<Controller,Boolean> _function = new Function1<Controller,Boolean>() {
        public Boolean apply(final Controller e) {
          boolean _hasActions = Styles.this._controllerExtensions.hasActions(e, "view");
          return Boolean.valueOf(_hasActions);
        }
      };
      List<Boolean> _map = ListExtensions.<Controller, Boolean>map(_allControllers, _function);
      boolean _isEmpty = _map.isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("div.");
        String _appName = this._utils.appName(it);
        String _lowerCase = _appName.toLowerCase();
        _builder.append(_lowerCase, "");
        _builder.append("-view form.");
        String _prefix = it.getPrefix();
        _builder.append(_prefix, "");
        _builder.append("QuickNavForm {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("margin: 10px 0;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("padding: 8px 12px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("border: 1px solid #ccc;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("div.");
        String _appName_1 = this._utils.appName(it);
        String _lowerCase_1 = _appName_1.toLowerCase();
        _builder.append(_lowerCase_1, "");
        _builder.append("-view form.");
        String _prefix_1 = it.getPrefix();
        _builder.append(_prefix_1, "");
        _builder.append("QuickNavForm fieldset {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("padding: 3px 10px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("margin-bottom: 0;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("div.");
        String _appName_2 = this._utils.appName(it);
        String _lowerCase_2 = _appName_2.toLowerCase();
        _builder.append(_lowerCase_2, "");
        _builder.append("-view form.");
        String _prefix_2 = it.getPrefix();
        _builder.append(_prefix_2, "");
        _builder.append("QuickNavForm fieldset h3 {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("margin-top: 0;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("div.");
        String _appName_3 = this._utils.appName(it);
        String _lowerCase_3 = _appName_3.toLowerCase();
        _builder.append(_lowerCase_3, "");
        _builder.append("-view form.");
        String _prefix_3 = it.getPrefix();
        _builder.append(_prefix_3, "");
        _builder.append("QuickNavForm fieldset #num {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("width: 50px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("text-align: right;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence finderStyles(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("body {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("background-color: #ddd;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("margin: 10px;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("text-align: left;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append(".");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "");
    _builder.append("form fieldset,");
    _builder.newLineIfNotEmpty();
    _builder.append(".");
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "");
    _builder.append("form fieldset legend {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("background-color: #fff;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("border: none;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("#");
    String _prefix_2 = this._utils.prefix(it);
    _builder.append(_prefix_2, "");
    _builder.append("itemcontainer {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("background-color: #eee;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("height: 300px;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("overflow: auto;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("padding: 5px;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("#");
    String _prefix_3 = this._utils.prefix(it);
    _builder.append(_prefix_3, "");
    _builder.append("itemcontainer ul {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("list-style: none;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("margin: 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("padding: 0;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("#");
    String _prefix_4 = this._utils.prefix(it);
    _builder.append(_prefix_4, "");
    _builder.append("itemcontainer a {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("color: #000;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("margin: 0.1em 0.2em;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("text-decoration: underline;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("#");
    String _prefix_5 = this._utils.prefix(it);
    _builder.append(_prefix_5, "");
    _builder.append("itemcontainer a:hover,");
    _builder.newLineIfNotEmpty();
    _builder.append("#");
    String _prefix_6 = this._utils.prefix(it);
    _builder.append(_prefix_6, "");
    _builder.append("itemcontainer a:focus,");
    _builder.newLineIfNotEmpty();
    _builder.append("#");
    String _prefix_7 = this._utils.prefix(it);
    _builder.append(_prefix_7, "");
    _builder.append("itemcontainer a:active {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("color: #900;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("text-decoration: none;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("#");
    String _prefix_8 = this._utils.prefix(it);
    _builder.append(_prefix_8, "");
    _builder.append("itemcontainer a img {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("border: none;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("#");
    String _prefix_9 = this._utils.prefix(it);
    _builder.append(_prefix_9, "");
    _builder.append("itemcontainer a img {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("border: 1px solid #ccc;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("background-color: #f5f5f5;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("padding: 0.5em;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("#");
    String _prefix_10 = this._utils.prefix(it);
    _builder.append(_prefix_10, "");
    _builder.append("itemcontainer a:hover img,");
    _builder.newLineIfNotEmpty();
    _builder.append("#");
    String _prefix_11 = this._utils.prefix(it);
    _builder.append(_prefix_11, "");
    _builder.append("itemcontainer a:focus img,");
    _builder.newLineIfNotEmpty();
    _builder.append("#");
    String _prefix_12 = this._utils.prefix(it);
    _builder.append(_prefix_12, "");
    _builder.append("itemcontainer a:active img {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("background-color: #fff;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
