package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * This class creates additional artifacts which can be helpful for Scribite integration.
 */
@SuppressWarnings("all")
public class Scribite {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private IFileSystemAccess fsa;
  
  private String docPath;
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating Scribite support");
    this.fsa = fsa;
    String _appDocPath = this._namingExtensions.getAppDocPath(it);
    String _plus = (_appDocPath + "scribite/");
    this.docPath = _plus;
    String fileName = "integration.md";
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (this.docPath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (this.docPath + fileName));
      if (_shouldBeMarked) {
        fileName = "integration.generated.md";
      }
      fsa.generateFile((this.docPath + fileName), this.integration(it));
    }
    this.docPath = (this.docPath + "plugins/");
    this.pluginAloha(it);
    this.pluginCk(it);
    this.pluginTinyMce(it);
  }
  
  private Object pluginAloha(final Application it) {
    return null;
  }
  
  private void pluginCk(final Application it) {
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    String _plus = ((this.docPath + "CKEditor/vendor/ckeditor/plugins/") + _formatForDB);
    final String pluginPath = (_plus + "/");
    String fileName = "plugin.js";
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked) {
        fileName = "plugin.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.ckPlugin(it));
    }
    fileName = "lang/de.js";
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not_1 = (!_shouldBeSkipped_1);
    if (_not_1) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked_1) {
        fileName = "lang/de.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.ckLangDe(it));
    }
    fileName = "lang/en.js";
    boolean _shouldBeSkipped_2 = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not_2 = (!_shouldBeSkipped_2);
    if (_not_2) {
      boolean _shouldBeMarked_2 = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked_2) {
        fileName = "lang/en.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.ckLangEn(it));
    }
    fileName = "lang/nl.js";
    boolean _shouldBeSkipped_3 = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not_3 = (!_shouldBeSkipped_3);
    if (_not_3) {
      boolean _shouldBeMarked_3 = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked_3) {
        fileName = "lang/nl.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.ckLangNl(it));
    }
    this._utils.createPlaceholder(it, this.fsa, (pluginPath + "images/"));
  }
  
  private void pluginTinyMce(final Application it) {
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    String _plus = ((this.docPath + "TinyMce/vendor/tinymce/plugins/") + _formatForDB);
    String pluginPath = (_plus + "/");
    String fileName = "plugin.js";
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked) {
        fileName = "plugin.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.tinyPlugin(it));
    }
    fileName = "plugin.min.js";
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not_1 = (!_shouldBeSkipped_1);
    if (_not_1) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked_1) {
        fileName = "plugin.min.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.tinyPlugin(it));
    }
    fileName = "langs/de.js";
    boolean _shouldBeSkipped_2 = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not_2 = (!_shouldBeSkipped_2);
    if (_not_2) {
      boolean _shouldBeMarked_2 = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked_2) {
        fileName = "langs/de.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.tinyLangDe(it));
    }
    fileName = "langs/en.js";
    boolean _shouldBeSkipped_3 = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not_3 = (!_shouldBeSkipped_3);
    if (_not_3) {
      boolean _shouldBeMarked_3 = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked_3) {
        fileName = "langs/en.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.tinyLangEn(it));
    }
    fileName = "langs/nl.js";
    boolean _shouldBeSkipped_4 = this._namingExtensions.shouldBeSkipped(it, (pluginPath + fileName));
    boolean _not_4 = (!_shouldBeSkipped_4);
    if (_not_4) {
      boolean _shouldBeMarked_4 = this._namingExtensions.shouldBeMarked(it, (pluginPath + fileName));
      if (_shouldBeMarked_4) {
        fileName = "langs/nl.generated.js";
      }
      this.fsa.generateFile((pluginPath + fileName), this.tinyLangNl(it));
    }
    this._utils.createPlaceholder(it, this.fsa, (pluginPath + "images/"));
  }
  
  private CharSequence integration(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("# SCRIBITE INTEGRATION");
    _builder.newLine();
    _builder.newLine();
    _builder.append("It is easy to include ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append(" in your [Scribite editors](https://github.com/zikula-modules/Scribite/).");
    _builder.newLineIfNotEmpty();
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append(" contains already the a popup for selecting ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(this._modelExtensions.getLeadingEntity(it).getNameMultiple());
    _builder.append(_formatForDisplay);
    {
      int _size = it.getEntities().size();
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        _builder.append(" and other items");
      }
    }
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append("Please note that Scribite 5.0+ is required for this.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("To activate the popup for the editor of your choice (currently supported: CKEditor, TinyMCE)");
    _builder.newLine();
    _builder.append("you only need to add the plugin to the list of extra plugins in the editor configuration.");
    _builder.newLine();
    _builder.newLine();
    _builder.append("If such a configuration is not available for an editor check if the plugins for");
    _builder.newLine();
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2);
    _builder.append(" are in Scribite/plugins/EDITOR/vendor/plugins. If not then copy the directories from");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(it);
    _builder.append(_relativeAppRootPath, "    ");
    _builder.append("/");
    String _appDocPath = this._namingExtensions.getAppDocPath(it);
    _builder.append(_appDocPath, "    ");
    _builder.append("/scribite/plugins into modules/Scribite/plugins.");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence ckPlugin(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CKEDITOR.plugins.add(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB);
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("requires: \'popup\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("lang: \'en,nl,de\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("init: function (editor) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("editor.addCommand(\'insert");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("exec: function (editor) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("var url = Routing.generate(\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "                ");
    _builder.append("_external_finder\', { objectType: \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode, "                ");
    _builder.append("\', editor: \'ckeditor\' });");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("// call method in ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "                ");
    _builder.append(".Finder.js and provide current editor");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "                ");
    _builder.append("FinderCKEditor(editor, url);");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("editor.ui.addButton(\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_2, "        ");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("label: editor.lang.");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_3, "            ");
    _builder.append(".title,");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("command: \'insert");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "            ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("icon: this.path.replace(\'docs/scribite/plugins/CKEditor/vendor/ckeditor/plugins/");
    String _formatForDB_4 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_4, "            ");
    _builder.append("\', \'public/images\') + \'admin.png\'");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence ckLangDe(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CKEDITOR.plugins.setLang(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB);
    _builder.append("\', \'de\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("title: unescape(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("-Objekt einf%FCgen\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("alt: unescape(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("-Objekt einf%FCgen\')");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence ckLangEn(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CKEDITOR.plugins.setLang(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB);
    _builder.append("\', \'en\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("title: \'Insert ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(" object\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("alt: \'Insert ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append(" object\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence ckLangNl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CKEDITOR.plugins.setLang(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB);
    _builder.append("\', \'nl\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("title: \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(" Object invoegen\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("alt: \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append(" Object invoegen\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tinyPlugin(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* plugin.js");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Copyright 2009, Moxiecode Systems AB");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Released under LGPL License.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* License: http://tinymce.moxiecode.com/license");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Contributing: http://tinymce.moxiecode.com/contributing");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("(function () {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Load plugin specific language pack");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tinymce.PluginManager.requireLangPack(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("\', \'de,en,nl\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tinymce.create(\'tinymce.plugins.");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("Plugin\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* Initializes the plugin, this will be executed after the plugin has been created.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* This call is done before the editor instance has finished it\'s initialization so use the onInit event");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* of the editor instance to intercept that event.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @param {tinymce.Editor} ed Editor instance that the plugin is initialised in");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @param {string} url Absolute URL to where the plugin is located");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("init: function (ed, url) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Register the command so that it can be invoked by using tinyMCE.activeEditor.execCommand(\'mce");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "            ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("ed.addCommand(\'mce");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "            ");
    _builder.append("\', function () {");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("ed.windowManager.open({");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("file: Routing.generate(\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "                    ");
    _builder.append("_external_finder\', { objectType: \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode, "                    ");
    _builder.append("\', editor: \'tinymce\' }),");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("width: (screen.width * 0.75),");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("height: (screen.height * 0.66),");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("inline: 1,");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("scrollbars: true,");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("resizable: true");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}, {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("plugin_url: url, // Plugin absolute URL");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("some_custom_arg: \'custom arg\' // Custom argument");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Register ");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_2, "            ");
    _builder.append(" button");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("ed.addButton(\'");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_3, "            ");
    _builder.append("\', {");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("title: \'");
    String _formatForDB_4 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_4, "                ");
    _builder.append(".desc\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("cmd: \'mce");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("image: Zikula.Config.baseURL + \'");
    String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(it);
    _builder.append(_relativeAppRootPath, "                ");
    String _resourcesPath = this._namingExtensions.getResourcesPath(it);
    _builder.append(_resourcesPath, "                ");
    _builder.append("public/images/admin.png\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("onPostRender: function() {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("var ctrl = this;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("// Add a node change handler, selects the button in the UI when an anchor or an image is selected");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("ed.on(\'NodeChange\', function(e) {");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("ctrl.active(e.element.nodeName == \'A\' || e.element.nodeName == \'IMG\');");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* Creates control instances based in the incomming name. This method is normally not");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* needed since the addButton method of the tinymce.Editor class is a more easy way of adding buttons");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* but you sometimes need to create more complex controls like listboxes, split buttons etc then this");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* method can be used to create those.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @param {String} n Name of the control to create");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @param {tinymce.ControlManager} cm Control manager to use in order to create new control");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @return {tinymce.ui.Control} New control instance or null if no control was created");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("createControl: function (n, cm) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return null;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* Returns information about the plugin as a name/value array.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* The current keys are longname, author, authorurl, infourl and version.");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("* @return {Object} Name/value array containing information about the plugin");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("getInfo: function () {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("longname: \'");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "                ");
    _builder.append(" for tinymce\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("author: \'");
    String _author = it.getAuthor();
    _builder.append(_author, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("authorurl: \'");
    String _url = it.getUrl();
    _builder.append(_url, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("infourl: \'");
    String _url_1 = it.getUrl();
    _builder.append(_url_1, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("version: \'");
    String _version = it.getVersion();
    _builder.append(_version, "                ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("};");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Register plugin");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("tinymce.PluginManager.add(\'");
    String _formatForDB_5 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_5, "    ");
    _builder.append("\', tinymce.plugins.");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "    ");
    _builder.append("Plugin);");
    _builder.newLineIfNotEmpty();
    _builder.append("}());");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tinyLangDe(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("tinymce.addI18n(\'de\', {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append(".desc\': unescape(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("-Objekt einf%FCgen\')");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tinyLangEn(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("tinymce.addI18n(\'en\', {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append(".desc\': \'Insert ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(" object\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence tinyLangNl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("tinymce.addI18n(\'nl\', {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append(".desc\': \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(" Object invoegen\'");
    _builder.newLineIfNotEmpty();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
}
