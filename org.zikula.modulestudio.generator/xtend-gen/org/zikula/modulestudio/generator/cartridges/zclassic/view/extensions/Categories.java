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
public class Categories {
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
      String _plus_1 = (templatePath + "include_categories_display.tpl");
      CharSequence _categoriesViewImpl = this.categoriesViewImpl(it, controller);
      fsa.generateFile(_plus_1, _categoriesViewImpl);
    }
    boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "edit");
    if (_hasActions_2) {
      String _plus_2 = (templatePath + "include_categories_edit.tpl");
      CharSequence _categoriesEditImpl = this.categoriesEditImpl(it, controller);
      fsa.generateFile(_plus_2, _categoriesEditImpl);
    }
  }
  
  private CharSequence categoriesViewImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: reusable display of entity categories *}");
    _builder.newLine();
    _builder.append("{if isset($obj.categories)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"categories z-panel-header z-panel-indicator z-pointer\">{gt text=\'Categories\'}</h3>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"categories z-panel-content\" style=\"display: none\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"categories\">{gt text=\'Categories\'}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{*");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dl class=\"propertylist\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach key=\'propName\' item=\'catMapping\' from=$obj.categories}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{$propName}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$catMapping.category.name|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</dl>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("*}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assignedcategorieslist categories=$obj.categories doctrine2=true}");
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
  
  private CharSequence categoriesEditImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: reusable editing of entity attributes *}");
    _builder.newLine();
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<h3 class=\"categories z-panel-header z-panel-indicator z-pointer\">{gt text=\'Categories\'}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset class=\"categories z-panel-content\" style=\"display: none\">");
    _builder.newLine();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset class=\"categories\">");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{gt text=\'Categories\'}</legend>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{formvolatile}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach key=\'registryId\' item=\'registryCid\' from=$registries}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{gt text=\'Category\' assign=\'categorySelectorLabel\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{assign var=\'selectionMode\' value=\'single\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{if $multiSelectionPerRegistry.$registryId eq true}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{gt text=\'Categories\' assign=\'categorySelectorLabel\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{assign var=\'selectionMode\' value=\'multiple\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{formlabel for=\"category_`$registryId`\" text=$categorySelectorLabel}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{formcategoryselector id=\"category_`$registryId`\" category=$registryCid");
    _builder.newLine();
    _builder.append("                                  ");
    _builder.append("dataField=\'categories\' group=$groupName registryId=$registryId doctrine2=true");
    _builder.newLine();
    _builder.append("                                  ");
    _builder.append("selectionMode=$selectionMode}");
    _builder.newLine();
    _builder.append("        ");
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
