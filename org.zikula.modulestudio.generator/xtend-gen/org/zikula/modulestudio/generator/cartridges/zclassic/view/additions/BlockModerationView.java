package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class BlockModerationView {
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
      _xifexpression = "block";
    } else {
      _xifexpression = "Block";
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    String _plus_1 = (templatePath + "moderation.tpl");
    CharSequence _displayTemplate = this.displayTemplate(it);
    fsa.generateFile(_plus_1, _displayTemplate);
  }
  
  private CharSequence displayTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: show moderation block *}");
    _builder.newLine();
    _builder.append("{if count($moderationObjects) gt 0}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach item=\'modItem\' from=$moderationObjects}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<li><a href=\"{modurl modname=\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\' type=\'admin\' func=\'view\' ot=$modItem.objectType workflowState=$modItem.state}\" class=\"");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("z-");
      }
    }
    _builder.append("bold\">{$modItem.message}</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
}
