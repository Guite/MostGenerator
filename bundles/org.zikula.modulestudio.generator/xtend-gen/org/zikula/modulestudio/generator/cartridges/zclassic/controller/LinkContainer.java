package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.MenuLinksHelperFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ItemActions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class LinkContainer {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating link container class");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Container/LinkContainer.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.linkContainerBaseImpl(it)), this.fh.phpFileContent(it, this.linkContainerImpl(it)));
    InputOutput.<String>println("Generating item actions menu class");
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath_1 + "Menu/ItemActionsMenu.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus_1, 
      this.fh.phpFileContent(it, this.itemActionsMenuBaseImpl(it)), this.fh.phpFileContent(it, this.itemActionsMenuImpl(it)));
  }
  
  private CharSequence linkContainerBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Container\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Routing\\RouterInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Doctrine\\EntityAccess;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\LinkContainer\\LinkContainerInterface;");
    _builder.newLine();
    {
      boolean _generateAccountApi = this._generatorSettingsExtensions.generateAccountApi(it);
      if (_generateAccountApi) {
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
      }
    }
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
    {
      if ((this._generatorSettingsExtensions.generateAccountApi(it) || this._controllerExtensions.hasEditActions(it))) {
        _builder.append("use Zikula\\UsersModule\\Api\\");
        {
          Boolean _targets_2 = this._utils.targets(it, "1.5");
          if ((_targets_2).booleanValue()) {
            _builder.append("ApiInterface\\CurrentUserApiInterface");
          } else {
            _builder.append("CurrentUserApi");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Helper\\ControllerHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the link container service implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractLinkContainer implements LinkContainerInterface");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("use TranslatorTrait;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var RouterInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $router;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var PermissionApi");
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
    _builder.append("protected $permissionApi;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _generateAccountApi_1 = this._generatorSettingsExtensions.generateAccountApi(it);
      if (_generateAccountApi_1) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var VariableApi");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $variableApi;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateAccountApi(it) || this._controllerExtensions.hasEditActions(it))) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var CurrentUserApi");
        {
          Boolean _targets_4 = this._utils.targets(it, "1.5");
          if ((_targets_4).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("private $currentUserApi;");
        _builder.newLine();
        _builder.newLine();
      }
    }
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
    _builder.append("* LinkContainer constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator       Translator service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Routerinterface     $router           Router service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param PermissionApi");
    {
      Boolean _targets_5 = this._utils.targets(it, "1.5");
      if ((_targets_5).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append("       $permissionApi    PermissionApi service instance");
    _builder.newLineIfNotEmpty();
    {
      boolean _generateAccountApi_2 = this._generatorSettingsExtensions.generateAccountApi(it);
      if (_generateAccountApi_2) {
        _builder.append("     ");
        _builder.append("* @param VariableApi         $variableApi      VariableApi service instance");
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateAccountApi(it) || this._controllerExtensions.hasEditActions(it))) {
        _builder.append("     ");
        _builder.append("* @param CurrentUserApi");
        {
          Boolean _targets_6 = this._utils.targets(it, "1.5");
          if ((_targets_6).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("     ");
          }
        }
        _builder.append(" $currentUserApi   CurrentUserApi service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("     ");
    _builder.append("* @param ControllerHelper    $controllerHelper ControllerHelper service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("TranslatorInterface $translator,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("RouterInterface $router,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("PermissionApi");
    {
      Boolean _targets_7 = this._utils.targets(it, "1.5");
      if ((_targets_7).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $permissionApi,");
    _builder.newLineIfNotEmpty();
    {
      boolean _generateAccountApi_3 = this._generatorSettingsExtensions.generateAccountApi(it);
      if (_generateAccountApi_3) {
        _builder.append("        ");
        _builder.append("VariableApi $variableApi,");
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateAccountApi(it) || this._controllerExtensions.hasEditActions(it))) {
        _builder.append("        ");
        _builder.append("CurrentUserApi");
        {
          Boolean _targets_8 = this._utils.targets(it, "1.5");
          if ((_targets_8).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append(" $currentUserApi,");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("ControllerHelper $controllerHelper");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setTranslator($translator);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->router = $router;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->permissionApi = $permissionApi;");
    _builder.newLine();
    {
      boolean _generateAccountApi_4 = this._generatorSettingsExtensions.generateAccountApi(it);
      if (_generateAccountApi_4) {
        _builder.append("        ");
        _builder.append("$this->variableApi = $variableApi;");
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateAccountApi(it) || this._controllerExtensions.hasEditActions(it))) {
        _builder.append("        ");
        _builder.append("$this->currentUserApi = $currentUserApi;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->controllerHelper = $controllerHelper;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _setTranslatorMethod = this._modelBehaviourExtensions.setTranslatorMethod(it);
    _builder.append(_setTranslatorMethod, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Returns available header links.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $type The type to collect links for");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return array Array of header links");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getLinks($type = LinkContainerInterface::TYPE_ADMIN)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$contextArgs = [\'api\' => \'linkContainer\', \'action\' => \'getLinks\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$allowedObjectTypes = $this->controllerHelper->getObjectTypes(\'api\', $contextArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$permLevel = LinkContainerInterface::TYPE_ADMIN == $type ? ACCESS_ADMIN : ACCESS_READ;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Create an array of links to return");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$links = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (LinkContainerInterface::TYPE_ACCOUNT == $type) {");
    _builder.newLine();
    {
      boolean _generateAccountApi_5 = this._generatorSettingsExtensions.generateAccountApi(it);
      if (_generateAccountApi_5) {
        _builder.append("            ");
        _builder.append("if (!$this->permissionApi->hasPermission($this->getBundleName() . \'::\', \'::\', ACCESS_OVERVIEW)) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("return $links;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        {
          final Function1<Entity, Boolean> _function = (Entity it_1) -> {
            return Boolean.valueOf((this._controllerExtensions.hasViewAction(it_1) && it_1.isStandardFields()));
          };
          Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
          for(final Entity entity : _filter) {
            _builder.append("            ");
            _builder.append("if (true === $this->variableApi->get(\'");
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "            ");
            _builder.append("\', \'linkOwn");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getNameMultiple());
            _builder.append(_formatForCodeCapital, "            ");
            _builder.append("OnAccountPage\', true)) {");
            _builder.newLineIfNotEmpty();
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("$objectType = \'");
            String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode, "                ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("if ($this->permissionApi->hasPermission($this->getBundleName() . \':\' . ucfirst($objectType) . \':\', \'::\', ACCESS_READ)) {");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("        ");
            _builder.append("$links[] = [");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("            ");
            _builder.append("\'url\' => $this->router->generate(\'");
            String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
            _builder.append(_formatForDB, "                        ");
            _builder.append("_\' . strtolower($objectType) . \'_view\', [\'own\' => 1]),");
            _builder.newLineIfNotEmpty();
            _builder.append("            ");
            _builder.append("            ");
            _builder.append("\'text\' => $this->__(\'My ");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
            _builder.append(_formatForDisplay, "                        ");
            _builder.append("\'");
            {
              boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
              boolean _not = (!_isSystemModule);
              if (_not) {
                _builder.append(", \'");
                String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
                _builder.append(_formatForDB_1, "                        ");
                _builder.append("\'");
              }
            }
            _builder.append("),");
            _builder.newLineIfNotEmpty();
            _builder.append("            ");
            _builder.append("            ");
            _builder.append("\'icon\' => \'list-alt\'");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("        ");
            _builder.append("];");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
          }
        }
        _builder.append("            ");
        _builder.append("if ($this->permissionApi->hasPermission($this->getBundleName() . \'::\', \'::\', ACCESS_ADMIN)) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$links[] = [");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("        ");
        _builder.append("\'url\' => $this->router->generate(\'");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_2, "                    ");
        _builder.append("_");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(this._modelExtensions.getLeadingEntity(it).getName());
        _builder.append(_formatForDB_3, "                    ");
        _builder.append("_admin");
        String _primaryAction = this._controllerExtensions.getPrimaryAction(this._modelExtensions.getLeadingEntity(it));
        _builder.append(_primaryAction, "                    ");
        _builder.append("\'),");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("        ");
        _builder.append("\'text\' => $this->__(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital, "                    ");
        _builder.append(" Backend\'");
        {
          boolean _isSystemModule_1 = this._generatorSettingsExtensions.isSystemModule(it);
          boolean _not_1 = (!_isSystemModule_1);
          if (_not_1) {
            _builder.append(", \'");
            String _formatForDB_4 = this._formattingExtensions.formatForDB(this._utils.appName(it));
            _builder.append(_formatForDB_4, "                    ");
            _builder.append("\'");
          }
        }
        _builder.append("),");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("        ");
        _builder.append("\'icon\' => \'wrench\'");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $links;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$routeArea = LinkContainerInterface::TYPE_ADMIN == $type ? \'admin\' : \'\';");
    _builder.newLine();
    _builder.append("        ");
    final MenuLinksHelperFunctions menuLinksHelper = new MenuLinksHelperFunctions();
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _generate = menuLinksHelper.generate(it);
    _builder.append(_generate, "        ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $links;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Returns the name of the providing bundle.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string The bundle name");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getBundleName()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence linkContainerImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Container;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Container\\Base\\AbstractLinkContainer;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the link container service implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class LinkContainer extends AbstractLinkContainer");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add own extensions here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence itemActionsMenuBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Menu\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Knp\\Menu\\FactoryInterface;");
    _builder.newLine();
    _builder.append("use Knp\\Menu\\MenuItem;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\DependencyInjection\\ContainerAwareInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\DependencyInjection\\ContainerAwareTrait;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Entity\\");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("Entity;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the item actions menu implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class AbstractItemActionsMenu implements ContainerAwareInterface");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("use ContainerAwareTrait;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("use TranslatorTrait;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _setTranslatorMethod = this._modelBehaviourExtensions.setTranslatorMethod(it);
    _builder.append(_setTranslatorMethod, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Builds the menu.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param FactoryInterface $factory Menu factory");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param array            $options Additional options");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return MenuItem The assembled menu");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function menu(FactoryInterface $factory, array $options)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$menu = $factory->createItem(\'itemActions\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($options[\'entity\']) || !isset($options[\'area\']) || !isset($options[\'context\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $menu;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setTranslator($this->container->get(\'translator.default\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = $options[\'entity\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$routeArea = $options[\'area\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = $options[\'context\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$permissionApi = $this->container->get(\'zikula_permissions_module.api.permission\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$currentUserApi = $this->container->get(\'zikula_users_module.current_user\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$menu->setChildrenAttribute(\'class\', \'list-inline\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    CharSequence _itemActionsImpl = new ItemActions().itemActionsImpl(it);
    _builder.append(_itemActionsImpl, "        ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $menu;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence itemActionsMenuImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Menu;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Menu\\Base\\AbstractItemActionsMenu;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the item actions menu implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ItemActionsMenu extends AbstractItemActionsMenu");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add own extensions here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
