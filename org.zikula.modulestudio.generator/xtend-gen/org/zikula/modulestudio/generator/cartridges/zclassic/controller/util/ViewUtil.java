package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ViewUtil {
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for the utility class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating utility class for view layer");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String utilPath = (_appSourceLibPath + "Util/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Util";
    }
    final String utilSuffix = _xifexpression;
    String _plus = (utilPath + "Base/View");
    String _plus_1 = (_plus + utilSuffix);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _viewFunctionsBaseFile = this.viewFunctionsBaseFile(it);
    fsa.generateFile(_plus_2, _viewFunctionsBaseFile);
    String _plus_3 = (utilPath + "View");
    String _plus_4 = (_plus_3 + utilSuffix);
    String _plus_5 = (_plus_4 + ".php");
    CharSequence _viewFunctionsFile = this.viewFunctionsFile(it);
    fsa.generateFile(_plus_5, _viewFunctionsFile);
  }
  
  private CharSequence viewFunctionsBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _viewFunctionsBaseImpl = this.viewFunctionsBaseImpl(it);
    _builder.append(_viewFunctionsBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence viewFunctionsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _viewFunctionsImpl = this.viewFunctionsImpl(it);
    _builder.append(_viewFunctionsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence viewFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Util\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\ControllerUtil as ConcreteControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use DataUtil;");
        _builder.newLine();
        _builder.append("use FormUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use PageUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use System;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpFoundation\\Response;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractBase;");
        _builder.newLine();
        _builder.append("use Zikula_View;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\Response\\PlainResponse;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility base class for view helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Util_Base_View");
      } else {
        _builder.append("ViewUtil");
      }
    }
    _builder.append(" extends Zikula_AbstractBase");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _viewTemplate = this.getViewTemplate(it);
    _builder.append(_viewTemplate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _processTemplate = this.processTemplate(it);
    _builder.append(_processTemplate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _determineExtension = this.determineExtension(it);
    _builder.append(_determineExtension, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _availableExtensions = this.availableExtensions(it);
    _builder.append(_availableExtensions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _processPdf = this.processPdf(it);
    _builder.append(_processPdf, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _readableFileSize = this.getReadableFileSize(it);
        _builder.append(_readableFileSize, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getViewTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines the view template for a certain method with given parameters.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_View $view       Reference to view object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $type       Current type (admin, user, ...).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $objectType Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $func       Current function (");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append(", view, ...).");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @param array       $args       Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string name of template file.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getViewTemplate(Zikula_View $view, $type, $objectType, $func, $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// create the base template name");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template = DataUtil::formatForOS(");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("$type . \'/\' . $objectType");
      } else {
        _builder.append("ucwords($type) . \'/\' . ucwords($objectType)");
      }
    }
    _builder.append(" . \'/\' . $func);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check for template extension");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateExtension = $this->determineExtension($view, $type, $objectType, $func, $args);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check whether a special template is used");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tpl = (isset($args[\'tpl\']) && !empty($args[\'tpl\'])) ? $args[\'tpl\'] : FormUtil::getPassedValue(\'tpl\', \'\', \'GETPOST\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($tpl) && $view->template_exists[$template . \'_\' . DataUtil::formatForOS($tpl) . \'.\' . $templateExtension)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$template .= \'_\' . DataUtil::formatForOS($tpl);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template .= \'.\' . $templateExtension;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $template;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility method for managing view templates.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_View $view       Reference to view object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $type       Current type (admin, user, ...).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $objectType Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $func       Current function (");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append(", view, ...).");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @param string      $template   Optional assignment of precalculated template file.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array       $args       Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processTemplate(Zikula_View $view, $type, $objectType, $func, $args = array(), $template = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateExtension = $this->determineExtension($view, $type, $objectType, $func, $args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($template)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$template = $this->getViewTemplate($view, $type, $objectType, $func, $args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// look whether we need output with or without the theme");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$raw = (bool) (isset($args[\'raw\']) && !empty($args[\'raw\'])) ? $args[\'raw\'] : FormUtil::getPassedValue(\'raw\', false, \'GETPOST\', FILTER_VALIDATE_BOOLEAN);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$raw && in_array($templateExtension, array(\'csv\', \'rss\', \'atom\', \'xml\', \'pdf\', \'vcard\', \'ical\', \'json\', \'kml\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$raw = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($raw == true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// standalone output");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($templateExtension == \'pdf\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$template = str_replace(\'.pdf\', \'.tpl\', $template);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $this->processPdf($view, $template);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("            ");
        _builder.append("$view->display($template);");
        _builder.newLine();
      } else {
        _builder.append("            ");
        _builder.append("return new PlainResponse($view->display($template));");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("        ");
        _builder.append("System::shutDown();");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// normal output");
    _builder.newLine();
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("    ");
        _builder.append("return $view->fetch($template);");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return new Response($view->fetch($template));");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence determineExtension(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get extension of the currently treated template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_View $view       Reference to view object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $type       Current type (admin, user, ...).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $objectType Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $func       Current function (");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append(", view, ...).");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @param array       $args       Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of allowed template extensions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function determineExtension(Zikula_View $view, $type, $objectType, $func, $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateExtension = \'tpl\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($func, array(\'view\', \'display\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $templateExtension;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extParams = $this->availableExtensions($type, $objectType, $func, $args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($extParams as $extension) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$extensionVar = \'use\' . $extension . \'ext\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$extensionCheck = (isset($args[$extensionVar]) && !empty($extensionVar)) ? $extensionVar : 0;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($extensionCheck != 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$extensionCheck = (int)FormUtil::getPassedValue($extensionVar, 0, \'GET\', FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("//$extensionCheck = (int)$this->request->query->filter($extensionVar, 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($extensionCheck == 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$templateExtension = $extension;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $templateExtension;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence availableExtensions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get list of available template extensions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $type       Current type (admin, user, ...).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $func       Current function (");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append(", view, ...).");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @param array  $args       Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of allowed template extensions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function availableExtensions($type, $objectType, $func, $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extParams = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hasAdminAccess = SecurityUtil::checkPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(":\' . ucwords($objectType) . \':\', \'::\', ACCESS_ADMIN);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($func == \'view\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($hasAdminAccess) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$extParams = array(\'csv\', \'rss\', \'atom\', \'xml\', \'json\', \'kml\'/*, \'pdf\'*/);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$extParams = array(\'rss\', \'atom\'/*, \'pdf\'*/);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($func == \'display\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($hasAdminAccess) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$extParams = array(\'xml\', \'json\', \'kml\'/*, \'pdf\'*/);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $extParams;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processPdf(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Processes a template file using dompdf (LGPL).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_View $view     Reference to view object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string      $template Name of template to use.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function processPdf(Zikula_View $view, $template)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// first the content, to set page vars");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$output = $view->fetch($template);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// make local images absolute");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$output = str_replace(\'img src=\"/\', \'img src=\"\' . dirname(ZLOADER_PATH) . \'/\', $output);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// see http://codeigniter.com/forums/viewthread/69388/P15/#561214");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$output = utf8_decode($output);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// then the surrounding");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$output = $view->fetch(\'include_pdfheader.tpl\') . $output . \'</body></html>\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ConcreteControllerUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// create name of the pdf output file");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileTitle = $controllerHelper->formatPermalink(System::getVar(\'sitename\'))");
    _builder.newLine();
    _builder.append("               ");
    _builder.append(". \'-\'");
    _builder.newLine();
    _builder.append("               ");
    _builder.append(". $controllerHelper->formatPermalink(PageUtil::getVar(\'title\'))");
    _builder.newLine();
    _builder.append("               ");
    _builder.append(". \'-\' . date(\'Ymd\') . \'.pdf\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if ($_GET[\'dbg\'] == 1) die($output);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// instantiate pdf object");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$pdf = new DOMPDF();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// define page properties");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$pdf->set_paper(\'A4\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// load html input data");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$pdf->load_html($output);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// create the actual pdf file");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$pdf->render();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// stream output to browser");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$pdf->stream($fileTitle);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// prevent additional output by shutting down the system");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("System::shutDown();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getReadableFileSize(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Display a given file size in a readable format");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $size     File size in bytes.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $nodesc   If set to true the description will not be appended.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $onlydesc If set to true only the description will be returned.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string File size in a readable form.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getReadableFileSize($size, $nodesc = false, $onlydesc = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sizeDesc = $this->__(\'Bytes\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($size >= 1024) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$size /= 1024;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sizeDesc = $this->__(\'KB\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($size >= 1024) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$size /= 1024;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sizeDesc = $this->__(\'MB\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($size >= 1024) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$size /= 1024;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sizeDesc = $this->__(\'GB\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sizeDesc = \'&nbsp;\' . $sizeDesc;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// format number");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dec_point = \',\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$thousands_separator = \'.\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($size - number_format($size, 0) >= 0.005) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$size = number_format($size, 2, $dec_point, $thousands_separator);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$size = number_format($size, 0, \'\', $thousands_separator);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// append size descriptor if desired");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$nodesc) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$size .= $sizeDesc;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return either only the description or the complete string");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = ($onlydesc) ? $sizeDesc : $size;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence viewFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Util;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\Base\\ViewUtil as BaseViewUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility implementation class for view helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Util_View extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_Base_View");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ViewUtil extends BaseViewUtil");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own convenience methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
