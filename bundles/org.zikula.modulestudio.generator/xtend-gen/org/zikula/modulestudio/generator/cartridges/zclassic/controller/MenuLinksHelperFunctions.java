package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class MenuLinksHelperFunctions {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _menuLinksBetweenControllers = this.menuLinksBetweenControllers(it);
    _builder.append(_menuLinksBetweenControllers);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      final Function1<Entity, Boolean> _function = (Entity it_1) -> {
        return Boolean.valueOf(this._controllerExtensions.hasViewAction(it_1));
      };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
      for(final Entity entity : _filter) {
        CharSequence _menuLinkToViewAction = this.menuLinkToViewAction(entity);
        _builder.append(_menuLinkToViewAction);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsConfig = this._utils.needsConfig(it);
      if (_needsConfig) {
        _builder.append("if ($routeArea == \'admin\' && $this->permissionApi->hasPermission($this->getBundleName() . \'::\', \'::\', ACCESS_ADMIN)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$links[] = [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'url\' => $this->router->generate(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB, "        ");
        _builder.append("_config_config\'),");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("\'text\' => ");
        CharSequence _translate = this.translate(it, "Configuration");
        _builder.append(_translate, "        ");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("\'title\' => ");
        CharSequence _translate_1 = this.translate(it, "Manage settings for this application");
        _builder.append(_translate_1, "        ");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("\'icon\' => \'wrench\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence menuLinkToViewAction(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (in_array(\'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\', $allowedObjectTypes)");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("&& $this->permissionApi->hasPermission($this->getBundleName() . \':");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append(":\', \'::\', $permLevel)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$links[] = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'url\' => $this->router->generate(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getApplication()));
    _builder.append(_formatForDB, "        ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1, "        ");
    _builder.append("_\' . $routeArea . \'view\'");
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.append(", [\'tpl\' => \'tree\']");
      }
    }
    _builder.append("),");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'text\' => ");
    CharSequence _translate = this.translate(it.getApplication(), this._formattingExtensions.formatForDisplayCapital(it.getNameMultiple()));
    _builder.append(_translate, "        ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'title\' => ");
    Application _application = it.getApplication();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    String _plus = (_formatForDisplayCapital + " list");
    CharSequence _translate_1 = this.translate(_application, _plus);
    _builder.append(_translate_1, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence menuLinksBetweenControllers(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (LinkContainerInterface::TYPE_ADMIN == $type) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->permissionApi->hasPermission($this->getBundleName() . \'::\', \'::\', ACCESS_READ)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$links[] = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'url\' => $this->router->generate(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "            ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForDB_1, "            ");
    _builder.append("_");
    String _primaryAction = this._controllerExtensions.getPrimaryAction(this._modelExtensions.getLeadingEntity(it));
    _builder.append(_primaryAction, "            ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'text\' => ");
    CharSequence _translate = this.translate(it, "Frontend");
    _builder.append(_translate, "            ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'title\' => ");
    CharSequence _translate_1 = this.translate(it, "Switch to user area.");
    _builder.append(_translate_1, "            ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'icon\' => \'home\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->permissionApi->hasPermission($this->getBundleName() . \'::\', \'::\', ACCESS_ADMIN)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$links[] = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'url\' => $this->router->generate(\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_2, "            ");
    _builder.append("_");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForDB_3, "            ");
    _builder.append("_admin");
    String _primaryAction_1 = this._controllerExtensions.getPrimaryAction(this._modelExtensions.getLeadingEntity(it));
    _builder.append(_primaryAction_1, "            ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'text\' => ");
    CharSequence _translate_2 = this.translate(it, "Backend");
    _builder.append(_translate_2, "            ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'title\' => ");
    CharSequence _translate_3 = this.translate(it, "Switch to administration area.");
    _builder.append(_translate_3, "            ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'icon\' => \'wrench\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence translate(final Application it, final String text) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$this->__(\'");
    _builder.append(text);
    _builder.append("\'");
    {
      boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
      boolean _not = (!_isSystemModule);
      if (_not) {
        _builder.append(", \'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB);
        _builder.append("\'");
      }
    }
    _builder.append(")");
    return _builder;
  }
}
