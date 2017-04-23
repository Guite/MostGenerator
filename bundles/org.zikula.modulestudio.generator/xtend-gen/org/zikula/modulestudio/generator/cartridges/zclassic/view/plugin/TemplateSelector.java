package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class TemplateSelector {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private Boolean generateSmartyPlugin;
  
  public CharSequence generate(final Application it, final IFileSystemAccess fsa, final Boolean enforceLegacy) {
    CharSequence _xblockexpression = null;
    {
      this.generateSmartyPlugin = enforceLegacy;
      CharSequence _xifexpression = null;
      if ((this.generateSmartyPlugin).booleanValue()) {
        final String pluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "TemplateSelector");
        boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, pluginFilePath);
        boolean _not = (!_shouldBeSkipped);
        if (_not) {
          fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, this.selectorTemplatesImpl(it)));
        }
      } else {
        _xifexpression = this.selectorTemplatesImpl(it);
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  private CharSequence selectorTemplatesImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, " ");
    {
      if ((this.generateSmartyPlugin).booleanValue()) {
        _builder.append("TemplateSelector plugin");
      } else {
        _builder.append("_templateSelector function");
      }
    }
    _builder.append(" provides items for a dropdown selector.");
    _builder.newLineIfNotEmpty();
    {
      if ((this.generateSmartyPlugin).booleanValue()) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* Available parameters:");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*   - assign: If set, the results are assigned to the corresponding variable instead of printed out.");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @param  array            $params All attributes passed to this function from the template");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @param  Zikula_Form_View $view   Reference to the view object");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The output of the plugin");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      if ((!(this.generateSmartyPlugin).booleanValue())) {
        _builder.append("public ");
      }
    }
    _builder.append("function ");
    {
      if ((this.generateSmartyPlugin).booleanValue()) {
        _builder.append("smarty_function_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_1);
      } else {
        _builder.append("get");
      }
    }
    _builder.append("TemplateSelector(");
    {
      if ((this.generateSmartyPlugin).booleanValue()) {
        _builder.append("$params, $view");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    final String templateExtension = ".html.twig";
    _builder.newLineIfNotEmpty();
    {
      if ((this.generateSmartyPlugin).booleanValue()) {
        _builder.append("    ");
        _builder.append("$dom = ZLanguage::getModuleDomain(\'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$result = [];");
    _builder.newLine();
    _builder.newLine();
    {
      if ((this.generateSmartyPlugin).booleanValue()) {
        _builder.append("    ");
        _builder.append("$result[] = [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'text\' => __(\'Only item titles\', $dom),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'value\' => \'itemlist_display");
        _builder.append(templateExtension, "        ");
        _builder.append("\'");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result[] = [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'text\' => __(\'With description\', $dom),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'value\' => \'itemlist_display_description");
        _builder.append(templateExtension, "        ");
        _builder.append("\'");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result[] = [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'text\' => __(\'Custom template\', $dom),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'value\' => \'custom\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$result[] = [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'text\' => $this->__(\'Only item titles\'),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'value\' => \'itemlist_display");
        _builder.append(templateExtension, "        ");
        _builder.append("\'");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result[] = [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'text\' => $this->__(\'With description\'),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'value\' => \'itemlist_display_description");
        _builder.append(templateExtension, "        ");
        _builder.append("\'");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result[] = [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'text\' => $this->__(\'Custom template\'),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'value\' => \'custom\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      if ((this.generateSmartyPlugin).booleanValue()) {
        _builder.append("    ");
        _builder.append("if (array_key_exists(\'assign\', $params)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$view->assign($params[\'assign\'], $result);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
