package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.JoinRelationship;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Styles {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private String cssPrefix;
  
  /**
   * Entry point for application styles.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.cssPrefix = this._utils.appName(it).toLowerCase();
    String fileName = "style.css";
    String _appCssPath = this._namingExtensions.getAppCssPath(it);
    String _plus = (_appCssPath + fileName);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _appCssPath_1 = this._namingExtensions.getAppCssPath(it);
      String _plus_1 = (_appCssPath_1 + fileName);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, _plus_1);
      if (_shouldBeMarked) {
        fileName = "style.generated.css";
      }
      String _appCssPath_2 = this._namingExtensions.getAppCssPath(it);
      String _plus_2 = (_appCssPath_2 + fileName);
      fsa.generateFile(_plus_2, this.appStyles(it));
    }
    fileName = "finder.css";
    if ((this._generatorSettingsExtensions.generateExternalControllerAndFinder(it) && (!this._namingExtensions.shouldBeSkipped(it, (this._namingExtensions.getAppCssPath(it) + fileName))))) {
      String _appCssPath_3 = this._namingExtensions.getAppCssPath(it);
      String _plus_3 = (_appCssPath_3 + fileName);
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, _plus_3);
      if (_shouldBeMarked_1) {
        fileName = "finder.generated.css";
      }
      String _appCssPath_4 = this._namingExtensions.getAppCssPath(it);
      String _plus_4 = (_appCssPath_4 + fileName);
      fsa.generateFile(_plus_4, this.finderStyles(it));
    }
  }
  
  private CharSequence appStyles(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasViewActions = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions) {
        _builder.append("/* view pages */");
        _builder.newLine();
        _builder.append("div#z-maincontent.z-module-");
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB);
        _builder.append(" table tbody tr td {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("vertical-align: top;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append(".table-responsive > .fixed-columns {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("position: absolute;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("display: inline-block;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("width: auto;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("border-right: 1px solid #ddd;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("background-color: #fff;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasDisplayActions = this._controllerExtensions.hasDisplayActions(it);
      if (_hasDisplayActions) {
        _builder.append("/* display pages */");
        _builder.newLine();
        _builder.append(".");
        _builder.append(this.cssPrefix);
        _builder.append("-display div.col-sm-3 h3 {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("color: #333;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("font-weight: 400;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("border-bottom: 1px solid #ccc;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("padding-bottom: 8px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append(".");
        _builder.append(this.cssPrefix);
        _builder.append("-display div.col-sm-3 p.managelink {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("margin-left: 18px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        _builder.append("div.");
        _builder.append(this.cssPrefix);
        _builder.append("-mapcontainer {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("height: 400px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.append(".tree-container {");
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
        _builder.newLine();
      }
    }
    {
      boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields) {
        _builder.append(".");
        _builder.append(this.cssPrefix);
        _builder.append("ColourPicker {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("cursor: pointer;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.newLine();
    CharSequence _validationStyles = this.validationStyles(it);
    _builder.append(_validationStyles);
    _builder.newLineIfNotEmpty();
    CharSequence _autoCompletion = this.autoCompletion(it);
    _builder.append(_autoCompletion);
    _builder.newLineIfNotEmpty();
    CharSequence _viewAdditions = this.viewAdditions(it);
    _builder.append(_viewAdditions);
    _builder.newLineIfNotEmpty();
    {
      boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_1) {
        _builder.newLine();
        _builder.append(".vakata-context, .vakata-context ul {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("z-index: 100;");
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
    _builder.append("div.form-group input:required, div.form-group textarea:required, div.form-group select:required {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/*border: 1px solid #00a8e6;*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("background-color: #fff;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("div.form-group input:required:valid, div.form-group textarea:required:valid, div.form-group select:required:valid {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/*border: 1px solid green;*/");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("div.form-group input:required:invalid, div.form-group textarea:required:invalid, div.form-group select:required:invalid {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("border: 1px solid red;");
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
      if (((!IterableExtensions.isEmpty(joinRelations)) || hasUserFields)) {
        _builder.newLine();
        _builder.append("/* edit pages */");
        _builder.newLine();
        {
          boolean _isEmpty = IterableExtensions.isEmpty(joinRelations);
          boolean _not = (!_isEmpty);
          if (_not) {
            _builder.append("div.");
            _builder.append(this.cssPrefix);
            _builder.append("-relation-leftside {");
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
            _builder.append(this.cssPrefix);
            _builder.append("-relation-rightside {");
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
        _builder.append("/* hide legends if tabs are used as both contain the same labels */");
        _builder.newLine();
        _builder.append("div.");
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB);
        _builder.append("-edit .tab-pane legend {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("display: none;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append(".tt-menu {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("max-height: 150px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("overflow-y: auto;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append(".tt-menu .tt-suggestion {");
        _builder.newLine();
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
        _builder.append("    ");
        _builder.append("background-color: #fff;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append(".tt-menu .empty-message {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("background-color: #fff;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("div.");
        _builder.append(this.cssPrefix);
        _builder.append("-autocomplete .tt-menu .tt-suggestion {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("background-image: url(\"../../../../../../images/icons/extrasmall/tab_right.png\");");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        {
          if (hasUserFields) {
            _builder.append("div.");
            _builder.append(this.cssPrefix);
            _builder.append("-autocomplete-user .tt-menu .tt-suggestion {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("background-image: url(\"../../../../../../images/icons/extrasmall/user.png\");");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          if (hasImageFields) {
            _builder.append("div.");
            _builder.append(this.cssPrefix);
            _builder.append("-autocomplete-with-image .tt-menu .tt-suggestion {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("background-image: url(\"../../../../../../images/icons/extrasmall/agt_Multimedia.png\");");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.append(".tt-menu .tt-suggestion img {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("max-width: 20px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("max-height: 20px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append(".tt-menu .tt-suggestion.tt-cursor {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("background-color: #ffb;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append(".tt-menu .empty-message {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("padding: 5px 10px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("text-align: center;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append(".tt-menu .tt-suggestion .media-body {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("font-size: 10px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("color: #888;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append(".tt-menu .tt-suggestion .media-body .media-heading {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("font-size: 12px;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("line-height: 1.2em;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence viewAdditions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasViewActions = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions) {
        _builder.newLine();
        _builder.append("/** fix dropdown visibility inside responsive tables */");
        _builder.newLine();
        _builder.append("div.");
        _builder.append(this.cssPrefix);
        _builder.append("-view .table-responsive {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("min-height: 300px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        CharSequence _viewFilterForm = this.viewFilterForm(it);
        _builder.append(_viewFilterForm);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("div.");
        _builder.append(this.cssPrefix);
        _builder.append("-view .avatar img {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("width: auto;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("max-height: 24px;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasLoggable = this._modelBehaviourExtensions.hasLoggable(it);
      if (_hasLoggable) {
        _builder.newLine();
        _builder.append("div.");
        _builder.append(this.cssPrefix);
        _builder.append("-history .table-responsive .table > tbody > tr > td.diff-old {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("background-color: #ffecec !important;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append("div.");
        _builder.append(this.cssPrefix);
        _builder.append("-history .table-responsive .table > tbody > tr > td.diff-new {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("background-color: #eaffea !important;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence viewFilterForm(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("div.");
    _builder.append(this.cssPrefix);
    _builder.append("-view form.");
    _builder.append(this.cssPrefix);
    _builder.append("-quicknav {");
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
    _builder.append(this.cssPrefix);
    _builder.append("-view form.");
    _builder.append(this.cssPrefix);
    _builder.append("-quicknav fieldset {");
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
    _builder.append(this.cssPrefix);
    _builder.append("-view form.");
    _builder.append(this.cssPrefix);
    _builder.append("-quicknav fieldset h3 {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("margin-top: 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("display: none;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("div.");
    _builder.append(this.cssPrefix);
    _builder.append("-view form.");
    _builder.append(this.cssPrefix);
    _builder.append("-quicknav fieldset label {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("margin-right: 5px;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("div.");
    _builder.append(this.cssPrefix);
    _builder.append("-view form.");
    _builder.append(this.cssPrefix);
    _builder.append("-quicknav fieldset #num {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("width: 50px;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("text-align: right;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
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
    _builder.append("#");
    _builder.append(this.cssPrefix);
    _builder.append("ItemContainer {");
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
    _builder.append(this.cssPrefix);
    _builder.append("ItemContainer ul {");
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
    _builder.append(this.cssPrefix);
    _builder.append("ItemContainer a {");
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
    _builder.append(this.cssPrefix);
    _builder.append("ItemContainer a:hover,");
    _builder.newLineIfNotEmpty();
    _builder.append("#");
    _builder.append(this.cssPrefix);
    _builder.append("ItemContainer a:focus,");
    _builder.newLineIfNotEmpty();
    _builder.append("#");
    _builder.append(this.cssPrefix);
    _builder.append("ItemContainer a:active {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("color: #900;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("text-decoration: none;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.newLine();
        _builder.append("#");
        _builder.append(this.cssPrefix);
        _builder.append("ItemContainer a img {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("border: none;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("#");
        _builder.append(this.cssPrefix);
        _builder.append("ItemContainer a img {");
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
        _builder.append(this.cssPrefix);
        _builder.append("ItemContainer a:hover img,");
        _builder.newLineIfNotEmpty();
        _builder.append("#");
        _builder.append(this.cssPrefix);
        _builder.append("ItemContainer a:focus img,");
        _builder.newLineIfNotEmpty();
        _builder.append("#");
        _builder.append(this.cssPrefix);
        _builder.append("ItemContainer a:active img {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("background-color: #fff;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append(".");
    _builder.append(this.cssPrefix);
    _builder.append("-finderform fieldset,");
    _builder.newLineIfNotEmpty();
    _builder.append(".");
    _builder.append(this.cssPrefix);
    _builder.append("-finderform fieldset legend {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("background-color: #fff;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("border: none;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
