package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ItemActionsView {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Entity it, final String context) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% set itemActions = knp_menu_get(\'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append(":ItemActionsMenu:menu\', [], { entity: ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(", area: routeArea, context: \'");
    _builder.append(context);
    _builder.append("\' }) %}");
    _builder.newLineIfNotEmpty();
    CharSequence _markup = this.markup(it, context);
    _builder.append(_markup);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence markup(final Entity it, final String context) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"dropdown\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a id=\"");
    CharSequence _itemActionContainerViewId = this.itemActionContainerViewId(it);
    _builder.append(_itemActionContainerViewId, "    ");
    _builder.append("DropDownToggle\" role=\"button\" data-toggle=\"dropdown\" data-target=\"#\" href=\"javascript:void(0);\" class=\"hidden dropdown-toggle\"><i class=\"fa fa-tasks\"></i>");
    {
      boolean _equals = Objects.equal(context, "display");
      if (_equals) {
        _builder.append(" {{ __(\'Actions\') }}");
      }
    }
    _builder.append(" <span class=\"caret\"></span></a>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ knp_menu_render(itemActions, { template: \'ZikulaMenuModule:Override:actions.html.twig\' }) }}");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence itemActionContainerViewId(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("itemActions");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("_", "");
        }
        _builder.append("{{ ");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append(".");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode_1);
        _builder.append(" }}");
      }
    }
    return _builder;
  }
}
