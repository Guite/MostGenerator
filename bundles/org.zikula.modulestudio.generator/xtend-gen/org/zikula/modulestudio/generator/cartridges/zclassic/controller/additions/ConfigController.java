package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.IntVar;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ConfigController {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Config controller class");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Controller/ConfigController.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.configControllerBaseClass(it)), fh.phpFileContent(it, this.configControllerImpl(it)));
  }
  
  private CharSequence configControllerBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Controller\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Controller\\AbstractController;");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Form\\AppSettingsType;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Config controller base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractConfigController extends AbstractController");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _configAction = this.configAction(it, Boolean.valueOf(true));
    _builder.append(_configAction, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence configAction(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _configDocBlock = this.configDocBlock(it, isBase);
    _builder.append(_configDocBlock);
    _builder.newLineIfNotEmpty();
    _builder.append("public function configAction(Request $request)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        CharSequence _configBaseImpl = this.configBaseImpl(it);
        _builder.append(_configBaseImpl, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("return parent::configAction($request);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence configDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method takes care of the application configuration.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/config\",");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        methods = {\"GET\", \"POST\"}");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* )");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Theme(\"admin\")");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Request $request Current request instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws AccessDeniedException Thrown if the user doesn\'t have required permissions");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence configBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->hasPermission($this->name . \'::\', \'::\', ACCESS_ADMIN)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$form = $this->createForm(");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("AppSettingsType::class");
      } else {
        _builder.append("\'");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace);
        _builder.append("\\Form\\AppSettingsType\'");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("if ($form->handleRequest($request)->isValid()) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($form->get(\'save\')->isClicked()) {");
    _builder.newLine();
    {
      boolean _hasUserGroupSelectors = this._controllerExtensions.hasUserGroupSelectors(it);
      if (_hasUserGroupSelectors) {
        _builder.append("        ");
        _builder.append("$formData = $form->getData();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("foreach ([\'");
        final Function1<IntVar, String> _function = (IntVar it_1) -> {
          return this._formattingExtensions.formatForCode(it_1.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<IntVar, String>map(this._controllerExtensions.getUserGroupSelectors(it), _function), "\', \'");
        _builder.append(_join, "        ");
        _builder.append("\'] as $groupFieldName) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$formData[$groupFieldName] = is_object($formData[$groupFieldName]) ? $formData[$groupFieldName]->getGid() : $formData[$groupFieldName];");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->setVars($formData);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$this->setVars($form->getData());");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'status\', $this->__(\'Done! Module configuration updated.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$userName = $this->get(\'zikula_users_module.current_user\')->get(\'uname\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->get(\'logger\')->notice(\'{app}: User {user} updated the configuration.\', [\'app\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\', \'user\' => $userName]);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} elseif ($form->get(\'cancel\')->isClicked()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'status\', $this->__(\'Operation cancelled.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// redirect to config page again (to show with GET request)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->redirectToRoute(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("_config_config\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'form\' => $form->createView()");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// render the config form");
    _builder.newLine();
    _builder.append("return $this->render(\'@");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append("/Config/config.html.twig\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence configControllerImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Controller;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Controller\\Base\\AbstractConfigController;");
    _builder.newLineIfNotEmpty();
    _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\Route;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
    _builder.newLine();
    _builder.append("use Zikula\\ThemeModule\\Engine\\Annotation\\Theme;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Config controller implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Route(\"/config\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ConfigController extends AbstractConfigController");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _configAction = this.configAction(it, Boolean.valueOf(false));
    _builder.append(_configAction, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own config controller methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
