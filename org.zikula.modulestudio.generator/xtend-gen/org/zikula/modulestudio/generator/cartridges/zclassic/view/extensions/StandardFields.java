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
public class StandardFields {
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
      String _plus_1 = (templatePath + "include_standardfields_display.tpl");
      CharSequence _standardFieldsViewImpl = this.standardFieldsViewImpl(it, controller);
      fsa.generateFile(_plus_1, _standardFieldsViewImpl);
    }
    boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "edit");
    if (_hasActions_2) {
      String _plus_2 = (templatePath + "include_standardfields_edit.tpl");
      CharSequence _standardFieldsEditImpl = this.standardFieldsEditImpl(it, controller);
      fsa.generateFile(_plus_2, _standardFieldsEditImpl);
    }
  }
  
  private CharSequence standardFieldsViewImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: reusable display of standard fields *}");
    _builder.newLine();
    _builder.append("{if (isset($obj.createdUserId) && $obj.createdUserId) || (isset($obj.updatedUserId) && $obj.updatedUserId)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"standardfields z-panel-header z-panel-indicator z-pointer\">{gt text=\'Creation and update\'}</h3>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"standardfields z-panel-content\" style=\"display: none\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"standardfields\">{gt text=\'Creation and update\'}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dl class=\"propertylist\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($obj.createdUserId) && $obj.createdUserId}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Creation\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{usergetvar name=\'uname\' uid=$obj.createdUserId assign=\'cr_uname\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{if $modvars.ZConfig.profilemodule ne \'\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{* if we have a profile module link to the user profile *}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{modurl modname=$modvars.ZConfig.profilemodule type=\'user\' func=\'view\' uname=$cr_uname assign=\'profileLink\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{assign var=\'profileLink\' value=$profileLink|safetext}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{assign var=\'profileLink\' value=\"<a href=\\\"`$profileLink`\\\">`$cr_uname`</a>\"}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{* else just show the user name *}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{assign var=\'profileLink\' value=$cr_uname}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{gt text=\'Created by %1$s on %2$s\' tag1=$profileLink tag2=$obj.createdDate|dateformat html=true}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($obj.updatedUserId) && $obj.updatedUserId}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Last update\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{usergetvar name=\'uname\' uid=$obj.updatedUserId assign=\'lu_uname\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{if $modvars.ZConfig.profilemodule ne \'\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{* if we have a profile module link to the user profile *}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{modurl modname=$modvars.ZConfig.profilemodule type=\'user\' func=\'view\' uname=$lu_uname assign=\'profileLink\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{assign var=\'profileLink\' value=$profileLink|safetext}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{assign var=\'profileLink\' value=\"<a href=\\\"`$profileLink`\\\">`$lu_uname`</a>\"}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{* else just show the user name *}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{assign var=\'profileLink\' value=$lu_uname}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{gt text=\'Updated by %1$s on %2$s\' tag1=$profileLink tag2=$obj.updatedDate|dateformat html=true}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
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
  
  private CharSequence standardFieldsEditImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: reusable editing of standard fields *}");
    _builder.newLine();
    _builder.append("{if (isset($obj.createdUserId) && $obj.createdUserId) || (isset($obj.updatedUserId) && $obj.updatedUserId)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"standardfields z-panel-header z-panel-indicator z-pointer\">{gt text=\'Creation and update\'}</h3>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset class=\"standardfields z-panel-content\" style=\"display: none\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset class=\"standardfields\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<legend>{gt text=\'Creation and update\'}</legend>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($obj.createdUserId) && $obj.createdUserId}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{usergetvar name=\'uname\' uid=$obj.createdUserId assign=\'username\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<li>{gt text=\'Created by %s\' tag1=$username}</li>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<li>{gt text=\'Created on %s\' tag1=$obj.createdDate|dateformat}</li>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($obj.updatedUserId) && $obj.updatedUserId}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{usergetvar name=\'uname\' uid=$obj.updatedUserId assign=\'username\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<li>{gt text=\'Updated by %s\' tag1=$username}</li>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<li>{gt text=\'Updated on %s\' tag1=$obj.updatedDate|dateformat}</li>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
}
