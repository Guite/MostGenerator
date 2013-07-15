package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Variable;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ModVars;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * Entry point for interactive installer implementation.
 */
@SuppressWarnings("all")
public class Interactive {
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
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
  
  public CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    ControllerHelper _controllerHelper = new ControllerHelper();
    CharSequence _controllerPostInitialize = _controllerHelper.controllerPostInitialize(it, Boolean.valueOf(false), "");
    _builder.append(_controllerPostInitialize, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcInteractiveInit = this.funcInteractiveInit(it);
    _builder.append(_funcInteractiveInit, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _needsConfig = this._utils.needsConfig(it);
      if (_needsConfig) {
        CharSequence _funcInteractiveInitStep2 = this.funcInteractiveInitStep2(it);
        _builder.append(_funcInteractiveInitStep2, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _funcInteractiveInitStep3 = this.funcInteractiveInitStep3(it);
    _builder.append(_funcInteractiveInitStep3, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcInteractiveUpdate = this.funcInteractiveUpdate(it);
    _builder.append(_funcInteractiveUpdate, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcInteractiveDelete = this.funcInteractiveDelete(it);
    _builder.append(_funcInteractiveDelete, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence funcInteractiveInit(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Interactive installation procedure.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string|boolean Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function install");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission(\'::\', \'::\', ACCESS_ADMIN));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("    ");
        _builder.append("return $this->view->fetch(\'init/interactive.tpl\');");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return $this->response($this->view->fetch(\'Init/interactive.tpl\'));");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence funcInteractiveInitStep2(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Interactive installation procedure step 2.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string|boolean Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function interactiveinitstep2");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission(\'::\', \'::\', ACCESS_ADMIN));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$submit = $this->request->request->get(\'submit\', null);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$submit) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("        ");
        _builder.append("return $this->view->fetch(\'init/step2.tpl\');");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("return $this->response($this->view->fetch(\'Init/step2.tpl\'));");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->checkCsrfToken();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    ModVars _modVars = new ModVars();
    final ModVars modVarHelper = _modVars;
    _builder.newLineIfNotEmpty();
    {
      List<Variable> _allVariables = this._utils.getAllVariables(it);
      for(final Variable modvar : _allVariables) {
        _builder.append("    ");
        _builder.append("$formValue = $this->request->request->get(\'");
        String _name = modvar.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append("\', ");
        CharSequence _valForm2SessionDefault = modVarHelper.valForm2SessionDefault(modvar);
        _builder.append(_valForm2SessionDefault, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("SessionUtil::setVar(\'");
        String _name_1 = it.getName();
        String _plus = (_name_1 + "_");
        String _name_2 = modvar.getName();
        String _plus_1 = (_plus + _name_2);
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_plus_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\', $formValue);");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$activate = (bool) $this->request->request->filter(\'activate\', false, FILTER_VALIDATE_BOOLEAN);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$activate = (!empty($activate)) ? true : false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->redirect(ModUtil::url(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\', \'init\', \'interactiveinitstep3\', array(\'activate\' => $activate)));");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence funcInteractiveInitStep3(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Interactive installation procedure step 3");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string|boolean Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function interactiveinitstep3");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission(\'::\', \'::\', ACCESS_ADMIN));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$activate = (bool) $this->request->request->filter(\'activate\', false, FILTER_VALIDATE_BOOLEAN);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign activation flag");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign(\'activate\', $activate);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("    ");
        _builder.append("return $this->view->fetch(\'init/step3.tpl\');");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return $this->response($this->view->fetch(\'Init/step3.tpl\'));");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence funcInteractiveUpdate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Interactive update procedure");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string|boolean Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function upgrade");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission(\'::\', \'::\', ACCESS_ADMIN));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// TODO");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence funcInteractiveDelete(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Interactive delete.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function uninstall");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission(\'::\', \'::\', ACCESS_ADMIN));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("    ");
        _builder.append("return $this->view->fetch(\'init/delete.tpl\');");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return $this->response($this->view->fetch(\'Init/delete.tpl\'));");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
