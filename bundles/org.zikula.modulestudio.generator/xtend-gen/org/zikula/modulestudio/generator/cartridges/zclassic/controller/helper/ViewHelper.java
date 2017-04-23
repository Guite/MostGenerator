package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.ViewExtensions;

@SuppressWarnings("all")
public class ViewHelper {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private ViewExtensions _viewExtensions = new ViewExtensions();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for view layer");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/ViewHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.viewFunctionsBaseImpl(it)), fh.phpFileContent(it, this.viewFunctionsImpl(it)));
  }
  
  private CharSequence viewFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Bundle\\TwigBundle\\Loader\\FilesystemLoader;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\RequestStack;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Response;");
    _builder.newLine();
    _builder.append("use Twig_Environment;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Response\\PlainResponse;");
    _builder.newLine();
    _builder.append("use Zikula\\ExtensionsModule\\Api\\");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("ApiInterface\\VariableApiInterface");
      } else {
        _builder.append("VariableApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("use Zikula\\PermissionsModule\\Api\\");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("ApiInterface\\PermissionApiInterface");
      } else {
        _builder.append("PermissionApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("use Zikula\\ThemeModule\\Engine\\ParameterBag;");
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Helper\\ControllerHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for view layer methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractViewHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var Twig_Environment");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $twig;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var FilesystemLoader");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $twigLoader;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var Request");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $request;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var PermissionApi");
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $permissionApi;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var VariableApi");
    {
      Boolean _targets_3 = this._utils.targets(it, "1.5");
      if ((_targets_3).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $variableApi;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ParameterBag");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $pageVars;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ControllerHelper");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $controllerHelper;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ViewHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Twig_Environment $twig             Twig service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param FilesystemLoader $twigLoader       Twig loader service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param RequestStack     $requestStack     RequestStack service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param PermissionApi");
    {
      Boolean _targets_4 = this._utils.targets(it, "1.5");
      if ((_targets_4).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append("    $permissionApi    PermissionApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("* @param VariableApi");
    {
      Boolean _targets_5 = this._utils.targets(it, "1.5");
      if ((_targets_5).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("     ");
      }
    }
    _builder.append(" $variableApi      VariableApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("* @param ParameterBag     $pageVars         ParameterBag for theme page variables");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param ControllerHelper $controllerHelper ControllerHelper service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Twig_Environment $twig,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("FilesystemLoader $twigLoader,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("RequestStack $requestStack,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("PermissionApi");
    {
      Boolean _targets_6 = this._utils.targets(it, "1.5");
      if ((_targets_6).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $permissionApi,");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("VariableApi");
    {
      Boolean _targets_7 = this._utils.targets(it, "1.5");
      if ((_targets_7).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $variableApi,");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("ParameterBag $pageVars,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("ControllerHelper $controllerHelper");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->twig = $twig;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->twigLoader = $twigLoader;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->request = $requestStack->getCurrentRequest();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->permissionApi = $permissionApi;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->variableApi = $variableApi;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->pageVars = $pageVars;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->controllerHelper = $controllerHelper;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
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
    _builder.append("* @param string $type Current controller (name of currently treated entity)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $func Current function (index, view, ...)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string name of template file");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getViewTemplate($type, $func)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// create the base template name");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template = \'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("/\' . ucfirst($type) . \'/\' . $func;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check for template extension");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateExtension = \'.\' . $this->determineExtension($type, $func);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check whether a special template is used");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tpl = $this->request->query->getAlnum(\'tpl\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($tpl)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// check if custom template exists");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$customTemplate = $template . ucfirst($tpl);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->twigLoader->exists($customTemplate . $templateExtension)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$template = $customTemplate;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template .= $templateExtension;");
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
    _builder.append("* Helper method for managing view templates.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $type               Current controller (name of currently treated entity)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $func               Current function (index, view, ...)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $templateParameters Template data");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $template           Optional assignment of precalculated template file");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processTemplate($type, $func, array $templateParameters = [], $template = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateExtension = $this->determineExtension($type, $func);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($template)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$template = $this->getViewTemplate($type, $func);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($templateExtension == \'pdf.twig\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$template = str_replace(\'.pdf\', \'.html\', $template);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->processPdf($templateParameters, $template);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// look whether we need output with or without the theme");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$raw = $this->request->query->getBoolean(\'raw\', false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$raw && $templateExtension != \'html.twig\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$raw = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$output = $this->twig->render($template, $templateParameters);");
    _builder.newLine();
    _builder.append("    ");
    ArrayList<String> _listOfViewFormats = this._viewExtensions.getListOfViewFormats(it);
    ArrayList<String> _listOfDisplayFormats = this._viewExtensions.getListOfDisplayFormats(it);
    final Iterable<String> supportedFormats = Iterables.<String>concat(_listOfViewFormats, _listOfDisplayFormats);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$response = null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (true === $raw) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// standalone output");
    _builder.newLine();
    {
      final Function1<String, Boolean> _function = (String e) -> {
        return Boolean.valueOf(Objects.equal(e, "csv"));
      };
      boolean _exists = IterableExtensions.<String>exists(supportedFormats, _function);
      if (_exists) {
        _builder.append("        ");
        _builder.append("if ($templateExtension == \'csv.twig\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// convert to UTF-16 for improved excel compatibility");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// see http://stackoverflow.com/questions/4348802/how-can-i-output-a-utf-8-csv-in-php-that-excel-will-read-properly");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$output = chr(255) . chr(254) . mb_convert_encoding($output, \'UTF-16LE\', \'UTF-8\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$response = new PlainResponse($output);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// normal output");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$response = new Response($output);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if we need to set any custom headers");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($templateExtension) {");
    _builder.newLine();
    {
      final Function1<String, Boolean> _function_1 = (String e) -> {
        return Boolean.valueOf(Objects.equal(e, "csv"));
      };
      boolean _exists_1 = IterableExtensions.<String>exists(supportedFormats, _function_1);
      if (_exists_1) {
        _builder.append("        ");
        _builder.append("case \'csv.twig\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Encoding\', \'UTF-8\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Type\', \'text/csv; charset=UTF-8\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Disposition\', \'attachment; filename=\' . $type . \'-list.csv\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      final Function1<String, Boolean> _function_2 = (String e) -> {
        return Boolean.valueOf(Objects.equal(e, "ics"));
      };
      boolean _exists_2 = IterableExtensions.<String>exists(supportedFormats, _function_2);
      if (_exists_2) {
        _builder.append("        ");
        _builder.append("case \'ics.twig\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Type\', \'text/calendar; charset=utf-8\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      final Function1<String, Boolean> _function_3 = (String e) -> {
        return Boolean.valueOf(Objects.equal(e, "json"));
      };
      boolean _exists_3 = IterableExtensions.<String>exists(supportedFormats, _function_3);
      if (_exists_3) {
        _builder.append("        ");
        _builder.append("case \'json.twig\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Type\', \'application/json\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      final Function1<String, Boolean> _function_4 = (String e) -> {
        return Boolean.valueOf(Objects.equal(e, "kml"));
      };
      boolean _exists_4 = IterableExtensions.<String>exists(supportedFormats, _function_4);
      if (_exists_4) {
        _builder.append("        ");
        _builder.append("case \'kml.twig\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Type\', \'application/vnd.google-earth.kml+xml\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      final Function1<String, Boolean> _function_5 = (String e) -> {
        return Boolean.valueOf(Objects.equal(e, "xml"));
      };
      boolean _exists_5 = IterableExtensions.<String>exists(supportedFormats, _function_5);
      if (_exists_5) {
        _builder.append("        ");
        _builder.append("case \'xml.twig\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Type\', \'text/xml\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      final Function1<String, Boolean> _function_6 = (String e) -> {
        return Boolean.valueOf(Objects.equal(e, "atom"));
      };
      boolean _exists_6 = IterableExtensions.<String>exists(supportedFormats, _function_6);
      if (_exists_6) {
        _builder.append("        ");
        _builder.append("case \'atom.twig\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Type\', \'application/atom+xml\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      final Function1<String, Boolean> _function_7 = (String e) -> {
        return Boolean.valueOf(Objects.equal(e, "rss"));
      };
      boolean _exists_7 = IterableExtensions.<String>exists(supportedFormats, _function_7);
      if (_exists_7) {
        _builder.append("        ");
        _builder.append("case \'rss.twig\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Type\', \'application/rss+xml\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $response;");
    _builder.newLine();
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
    _builder.append("* @param string $type Current controller (name of currently treated entity)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $func Current function (index, view, ...)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Template extension");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function determineExtension($type, $func)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateExtension = \'html.twig\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($func, [\'view\', \'display\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $templateExtension;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extensions = $this->availableExtensions($type, $func);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$format = $this->request->getRequestFormat();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($format != \'html\' && in_array($format, $extensions)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateExtension = $format . \'.twig\';");
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
    _builder.append("* @param string $type Current controller (name of currently treated entity)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $func Current function (index, view, ...)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of allowed template extensions");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function availableExtensions($type, $func)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$extensions = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hasAdminAccess = $this->permissionApi->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(":\' . ucfirst($type) . \':\', \'::\', ACCESS_ADMIN);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($func == \'view\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($hasAdminAccess) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$extensions = [");
    {
      ArrayList<String> _listOfViewFormats = this._viewExtensions.getListOfViewFormats(it);
      boolean _hasElements = false;
      for(final String format : _listOfViewFormats) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "            ");
        }
        _builder.append("\'");
        _builder.append(format, "            ");
        _builder.append("\'");
      }
    }
    _builder.append("];");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$extensions = [");
    {
      final Function1<String, Boolean> _function = (String it_1) -> {
        return Boolean.valueOf(((Objects.equal(it_1, "rss") || Objects.equal(it_1, "atom")) || Objects.equal(it_1, "pdf")));
      };
      Iterable<String> _filter = IterableExtensions.<String>filter(this._viewExtensions.getListOfViewFormats(it), _function);
      boolean _hasElements_1 = false;
      for(final String format_1 : _filter) {
        if (!_hasElements_1) {
          _hasElements_1 = true;
        } else {
          _builder.appendImmediate(", ", "            ");
        }
        _builder.append("\'");
        _builder.append(format_1, "            ");
        _builder.append("\'");
      }
    }
    _builder.append("];");
    _builder.newLineIfNotEmpty();
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
    _builder.append("$extensions = [");
    {
      ArrayList<String> _listOfDisplayFormats = this._viewExtensions.getListOfDisplayFormats(it);
      boolean _hasElements_2 = false;
      for(final String format_2 : _listOfDisplayFormats) {
        if (!_hasElements_2) {
          _hasElements_2 = true;
        } else {
          _builder.appendImmediate(", ", "            ");
        }
        _builder.append("\'");
        _builder.append(format_2, "            ");
        _builder.append("\'");
      }
    }
    _builder.append("];");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$extensions = [");
    {
      final Function1<String, Boolean> _function_1 = (String it_1) -> {
        return Boolean.valueOf((Objects.equal(it_1, "ics") || Objects.equal(it_1, "pdf")));
      };
      Iterable<String> _filter_1 = IterableExtensions.<String>filter(this._viewExtensions.getListOfDisplayFormats(it), _function_1);
      boolean _hasElements_3 = false;
      for(final String format_3 : _filter_1) {
        if (!_hasElements_3) {
          _hasElements_3 = true;
        } else {
          _builder.appendImmediate(", ", "            ");
        }
        _builder.append("\'");
        _builder.append(format_3, "            ");
        _builder.append("\'");
      }
    }
    _builder.append("];");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $extensions;");
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
    _builder.append("* @param array  $templateParameters Template data");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $template           Name of template to use");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function processPdf(array $templateParameters = [], $template)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// first the content, to set page vars");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$output = $this->twig->render($template, $templateParameters);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// make local images absolute");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$output = str_replace(\'img src=\"/\', \'img src=\"\' . $this->request->server->get(\'DOCUMENT_ROOT\') . \'/\', $output);");
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
    _builder.append("$output = $this->twig->render(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("/includePdfHeader.html.twig\') . $output . \'</body></html>\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// create name of the pdf output file");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$siteName = $this->variableApi->getSystemVar(\'sitename\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$pageTitle = $this->controllerHelper->formatPermalink($this->themePageVars->get(\'title\', \'\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fileTitle = $this->controllerHelper->formatPermalink($siteName)");
    _builder.newLine();
    _builder.append("               ");
    _builder.append(". \'-\'");
    _builder.newLine();
    _builder.append("               ");
    _builder.append(". ($pageTitle != \'\' ? $pageTitle . \'-\' : \'\')");
    _builder.newLine();
    _builder.append("               ");
    _builder.append(". date(\'Ymd\') . \'.pdf\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/*");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (true === $this->request->query->getBoolean(\'dbg\', false)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("die($output);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// instantiate pdf object");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$pdf = new \\DOMPDF();");
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
    _builder.append("return new Response();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence viewFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Helper\\Base\\AbstractViewHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for view layer methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ViewHelper extends AbstractViewHelper");
    _builder.newLine();
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
