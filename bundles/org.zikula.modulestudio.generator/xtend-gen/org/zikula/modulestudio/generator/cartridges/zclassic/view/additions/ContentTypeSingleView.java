package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ContentTypeSingleView {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "ContentType/");
    String fileName = "item_edit.tpl";
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = "item_edit.generated.tpl";
      }
      fsa.generateFile((templatePath + fileName), this.editTemplate(it));
    }
  }
  
  private CharSequence editTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: edit view of specific item detail view content type *}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div style=\"margin-left: 80px\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formlabel for=\'");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "        ");
    _builder.append("ObjectType\' __text=\'Object type\' cssClass=\'col-sm-3 control-label\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "            ");
    _builder.append("ObjectTypeSelector assign=\'allObjectTypes\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{formdropdownlist id=\'");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "            ");
    _builder.append("ObjectType\' dataField=\'objectType\' group=\'data\' mandatory=true items=$allObjectTypes cssClass=\'form-control\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<span class=\"help-block\">{gt text=\'If you change this please save the element once to reload the parameters below.\'}</span>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div{* class=\"form-group\"*}>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<p>{gt text=\'Please select your item here. You can resort the dropdown list and reduce it\\\'s entries by applying filters. On the right side you will see a preview of the selected entry.\'}</p>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "        ");
    _builder.append("ItemSelector id=\'id\' group=\'data\' objectType=$objectType}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div{* class=\"form-group\"*}>");
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
