package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ContentTypeSingleView {
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
      _xifexpression = "contenttype";
    } else {
      _xifexpression = "ContentType";
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    String _plus_1 = (templatePath + "item_edit.tpl");
    CharSequence _editTemplate = this.editTemplate(it);
    fsa.generateFile(_plus_1, _editTemplate);
  }
  
  private CharSequence editTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: edit view of specific item detail view content type *}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div style=\"margin-left: 80px\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formlabel for=\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("_objecttype\' __text=\'Object type\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB, "        ");
    _builder.append("ObjectTypeSelector assign=\'allObjectTypes\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formdropdownlist id=\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "        ");
    _builder.append("_objecttype\' dataField=\'objectType\' group=\'data\' mandatory=true items=$allObjectTypes}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<span class=\"z-sub z-formnote\">{gt text=\'If you change this please save the element once to reload the parameters below.\'}</span>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div{* class=\"z-formrow\"*}>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<p>{gt text=\'Please select your item here. You can resort the dropdown list and reduce it\\\'s entries by applying filters. On the right side you will see a preview of the selected entry.\'}</p>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    String _appName_3 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_3);
    _builder.append(_formatForDB_1, "        ");
    _builder.append("ItemSelector id=\'id\' group=\'data\' objectType=$objectType}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div{* class=\"z-formrow\"*}>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formradiobutton id=\'linkButton\' value=\'link\' dataField=\'displayMode\' group=\'data\' mandatory=1}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formlabel for=\'linkButton\' __text=\'Link to object\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formradiobutton id=\'embedButton\' value=\'embed\' dataField=\'displayMode\' group=\'data\' mandatory=1}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formlabel for=\'embedButton\' __text=\'Embed object display\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
}
