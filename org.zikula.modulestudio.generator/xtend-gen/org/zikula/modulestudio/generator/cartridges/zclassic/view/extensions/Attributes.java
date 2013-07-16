package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Attributes {
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
  
  public void generate(final Application it, final Controller controller, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _formattedName = this._controllerExtensions.formattedName(controller);
      _xifexpression = _formattedName;
    } else {
      String _formattedName_1 = this._controllerExtensions.formattedName(controller);
      String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
      _xifexpression = _firstUpper;
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    boolean _or = false;
    boolean _hasActions = this._controllerExtensions.hasActions(controller, "view");
    if (_hasActions) {
      _or = true;
    } else {
      boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "display");
      _or = (_hasActions || _hasActions_1);
    }
    if (_or) {
      String _plus_1 = (templatePath + "include_attributes_display.tpl");
      CharSequence _attributesViewImpl = this.attributesViewImpl(it, controller);
      fsa.generateFile(_plus_1, _attributesViewImpl);
    }
    boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "edit");
    if (_hasActions_2) {
      String _plus_2 = (templatePath + "include_attributes_edit.tpl");
      CharSequence _attributesEditImpl = this.attributesEditImpl(it, controller);
      fsa.generateFile(_plus_2, _attributesEditImpl);
    }
  }
  
  private CharSequence attributesViewImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: reusable display of entity attributes *}");
    _builder.newLine();
    _builder.append("{if isset($obj.attributes)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"attributes z-panel-header z-panel-indicator z-pointer\">{gt text=\'Attributes\'}</h3>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"attributes z-panel-content\" style=\"display: none\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"attributes\">{gt text=\'Attributes\'}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dl class=\"propertylist\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach key=\'fieldName\' item=\'fieldInfo\' from=$obj.attributes}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{$fieldName|safetext}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$fieldInfo.value|default:\'\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</dl>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence attributesEditImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: reusable editing of entity attributes *}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"attributes z-panel-header z-panel-indicator z-pointer\">{gt text=\'Attributes\'}</h3>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset class=\"attributes z-panel-content\" style=\"display: none\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset class=\"attributes\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{gt text=\'Attributes\'}</legend>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{formvolatile}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach key=\'fieldName\' item=\'fieldValue\' from=$attributes}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formlabel for=\"attributes`$fieldName`\"\' text=$fieldName}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formtextinput id=\"attributes`$fieldName`\" group=\'attributes\' dataField=$fieldName maxLength=255}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/formvolatile}");
    _builder.newLine();
    _builder.append("</fieldset>");
    _builder.newLine();
    return _builder;
  }
}
