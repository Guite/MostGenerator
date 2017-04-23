package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class SearchView {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    Boolean _targets = this._utils.targets(it, "1.5");
    if ((_targets).booleanValue()) {
      return;
    }
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Search/");
    final String templateExtension = ".html.twig";
    String fileName = ("options" + templateExtension);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = ("options.generated" + templateExtension);
      }
      fsa.generateFile((templatePath + fileName), this.optionsTemplate(it));
    }
  }
  
  private CharSequence optionsTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display search options #}");
    _builder.newLine();
    _builder.append("<input type=\"hidden\" id=\"");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower);
    _builder.append("Active\" name=\"active[");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("]\" value=\"1\" />");
    _builder.newLineIfNotEmpty();
    final String appLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.newLineIfNotEmpty();
    {
      final Function1<Entity, Boolean> _function = (Entity it_1) -> {
        return Boolean.valueOf(this._modelExtensions.hasAbstractStringFieldsEntity(it_1));
      };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
      for(final Entity entity : _filter) {
        final String nameMulti = this._formattingExtensions.formatForCodeCapital(entity.getNameMultiple());
        _builder.newLineIfNotEmpty();
        _builder.append("{% if active_");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode);
        _builder.append(" is defined %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<div>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<input type=\"checkbox\" id=\"active_");
        _builder.append(appLower, "        ");
        _builder.append(nameMulti, "        ");
        _builder.append("\" name=\"");
        _builder.append(appLower, "        ");
        _builder.append("SearchTypes[]\" value=\"");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode_1, "        ");
        _builder.append("\"{% if active_");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode_2, "        ");
        _builder.append(" %} checked=\"checked\"{% endif %} />");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<label for=\"active_");
        _builder.append(appLower, "        ");
        _builder.append(nameMulti, "        ");
        _builder.append("\">{{ __(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(entity.getNameMultiple());
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\', \'");
        String _formatForDB = this._formattingExtensions.formatForDB(appLower);
        _builder.append(_formatForDB, "        ");
        _builder.append("\') }}</label>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
}
