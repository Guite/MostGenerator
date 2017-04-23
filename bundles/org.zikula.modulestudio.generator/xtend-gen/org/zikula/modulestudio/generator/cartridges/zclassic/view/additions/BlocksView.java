package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class BlocksView {
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Block/");
    final String templateExtension = ".html.twig";
    String fileName = ("itemlist" + templateExtension);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = ("itemlist.generated" + templateExtension);
      }
      fsa.generateFile((templatePath + fileName), this.displayTemplate(it));
    }
    fileName = ("itemlist_modify" + templateExtension);
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not_1 = (!_shouldBeSkipped_1);
    if (_not_1) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked_1) {
        fileName = ("itemlist_modify.generated" + templateExtension);
      }
      fsa.generateFile((templatePath + fileName), this.editTemplate(it));
    }
  }
  
  private CharSequence displayTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display items within a block (fallback template) #}");
    _builder.newLine();
    _builder.append("Default block for generic item list.");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Edit block for generic item list #}");
    _builder.newLine();
    _builder.append("{{ form_row(form.objectType) }}");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("{% if is_categorisable %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ form_row(form.categories) }}");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("{{ form_row(form.sorting) }}");
    _builder.newLine();
    _builder.append("{{ form_row(form.amount) }}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{{ form_row(form.template) }}");
    _builder.newLine();
    _builder.append("<div id=\"customTemplateArea\" data-switch=\"zikulablocksmodule_block[properties][template]\" data-switch-value=\"custom\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(form.customTemplate) }}");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{{ form_row(form.filter) }}");
    _builder.newLine();
    _builder.append("<p class=\"col-sm-offset-3 help-block small\"><a class=\"fa fa-filter\" data-toggle=\"modal\" data-target=\"#filterSyntaxModal\">{{ __(\'Show syntax examples\') }}</a></p>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{{ include(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("/includeFilterSyntaxDialog.html.twig\') }}");
    _builder.newLineIfNotEmpty();
    CharSequence _editTemplateJs = this.editTemplateJs(it);
    _builder.append(_editTemplateJs);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence editTemplateJs(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ pageAddAsset(\'stylesheet\', asset(\'bootstrap/css/bootstrap.min.css\')) }}");
    _builder.newLine();
    _builder.append("{{ pageAddAsset(\'stylesheet\', asset(\'bootstrap/css/bootstrap-theme.min.css\')) }}");
    _builder.newLine();
    _builder.append("{{ pageAddAsset(\'javascript\', asset(\'bootstrap/js/bootstrap.min.js\')) }}");
    _builder.newLine();
    return _builder;
  }
}
