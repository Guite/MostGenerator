package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Categories {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Helper/");
    final String templateExtension = ".html.twig";
    String fileName = "";
    if ((this._controllerExtensions.hasViewActions(it) || this._controllerExtensions.hasDisplayActions(it))) {
      fileName = ("includeCategoriesDisplay" + templateExtension);
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
      boolean _not = (!_shouldBeSkipped);
      if (_not) {
        boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
        if (_shouldBeMarked) {
          fileName = ("includeCategoriesDisplay.generated" + templateExtension);
        }
        fsa.generateFile((templatePath + fileName), this.categoriesViewImpl(it));
      }
    }
    boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
    if (_hasEditActions) {
      fileName = ("includeCategoriesEdit" + templateExtension);
      boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
      boolean _not_1 = (!_shouldBeSkipped_1);
      if (_not_1) {
        boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
        if (_shouldBeMarked_1) {
          fileName = ("includeCategoriesEdit.generated" + templateExtension);
        }
        fsa.generateFile((templatePath + fileName), this.categoriesEditImpl(it));
      }
    }
  }
  
  private CharSequence categoriesViewImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: reusable display of entity categories #}");
    _builder.newLine();
    _builder.append("{% if obj.categories is defined %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabCategories\" aria-labelledby=\"categoriesTab\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h3>{{ __(\'Categories\') }}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"categories\">{{ __(\'Categories\') }}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _viewBody = this.viewBody(it);
    _builder.append(_viewBody, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence viewBody(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<ul class=\"category-list\">");
    _builder.newLine();
    _builder.append("{% for catMapping in obj.categories %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<li>{{ catMapping.category.display_name[app.request.locale]|default(catMapping.category.name) }}</li>");
    _builder.newLine();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("</ul>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence categoriesEditImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: reusable editing of entity categories #}");
    _builder.newLine();
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabCategories\" aria-labelledby=\"categoriesTab\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3>{{ __(\'Categories\') }}</h3>");
    _builder.newLine();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset class=\"categories\">");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{{ __(\'Categories\') }}</legend>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(form.categories) }}");
    _builder.newLine();
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
}
