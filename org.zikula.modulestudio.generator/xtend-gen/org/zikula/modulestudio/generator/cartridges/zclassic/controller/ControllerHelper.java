package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;

@SuppressWarnings("all")
public class ControllerHelper {
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  public CharSequence controllerPostInitialize(final Object it, final Boolean caching, final String additionalCommands) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post initialise.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Run after construction.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function postInitialize()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Set caching to ");
    String _displayBool = this._formattingExtensions.displayBool(caching);
    _builder.append(_displayBool, "    ");
    _builder.append(" by default.");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->view->setCaching(Zikula_View::CACHE_");
    {
      if ((caching).booleanValue()) {
        _builder.append("ENABLED");
      } else {
        _builder.append("DISABLED");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    {
      boolean _notEquals = (!Objects.equal(additionalCommands, ""));
      if (_notEquals) {
        _builder.append("    ");
        _builder.append(additionalCommands, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence defaultSorting(final Object it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sort = $repository->getDefaultSortingField();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
