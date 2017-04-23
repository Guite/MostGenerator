package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.AbstractStringField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.StringField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.SearchView;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class SearchHelper {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for search integration");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/SearchHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.searchHelperBaseClass(it)), fh.phpFileContent(it, this.searchHelperImpl(it)));
    new SearchView().generate(it, fsa);
  }
  
  private CharSequence searchHelperBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\QueryBuilder;");
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\Query\\Expr\\Composite;");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("use Symfony\\Component\\Form\\Extension\\Core\\Type\\CheckboxType;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\Form\\Extension\\Core\\Type\\HiddenType;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\Form\\FormBuilderInterface;");
        _builder.newLine();
      } else {
        _builder.append("use Symfony\\Bundle\\FrameworkBundle\\Templating\\EngineInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\RequestStack;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Session\\SessionInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\RouteUrl;");
    _builder.newLine();
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
    _builder.append("use Zikula\\SearchModule\\Entity\\SearchResultEntity;");
    _builder.newLine();
    _builder.append("use Zikula\\SearchModule\\SearchableInterface;");
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Factory;");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2);
        _builder.append("\\Helper\\CategoryHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use ");
    String _appNamespace_3 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_3);
    _builder.append("\\Helper\\ControllerHelper;");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.append("use ");
        String _appNamespace_4 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_4);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Search helper base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractSearchHelper implements SearchableInterface");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _searchHelperBaseImpl = this.searchHelperBaseImpl(it);
    _builder.append(_searchHelperBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence searchHelperBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use TranslatorTrait;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var PermissionApi");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $permissionApi;");
    _builder.newLine();
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      boolean _not = (!(_targets_1).booleanValue());
      if (_not) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var EngineInterface");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("private $templateEngine;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var SessionInterface");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("private $session;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var Request");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("private $request;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var ");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, " ");
    _builder.append("Factory");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("private $entityFactory;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var ControllerHelper");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("private $controllerHelper;");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var FeatureActivationHelper");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("private $featureActivationHelper;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var CategoryHelper");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("private $categoryHelper;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* SearchHelper constructor.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator   Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param PermissionApi");
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append("    $permissionApi   PermissionApi service instance");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets_3 = this._utils.targets(it, "1.5");
      boolean _not_1 = (!(_targets_3).booleanValue());
      if (_not_1) {
        _builder.append(" ");
        _builder.append("* @param EngineInterface  $templateEngine  Template engine service instance");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @param SessionInterface $session         Session service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param RequestStack     $requestStack    RequestStack service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, " ");
    _builder.append("Factory $entityFactory EntityFactory service instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @param ControllerHelper $controllerHelper ControllerHelper service instance");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.append(" ");
        _builder.append("* @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param CategoryHelper   $categoryHelper CategoryHelper service instance");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function __construct(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("TranslatorInterface $translator,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("PermissionApi");
    {
      Boolean _targets_4 = this._utils.targets(it, "1.5");
      if ((_targets_4).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $permissionApi,");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets_5 = this._utils.targets(it, "1.5");
      boolean _not_2 = (!(_targets_5).booleanValue());
      if (_not_2) {
        _builder.append("    ");
        _builder.append("EngineInterface $templateEngine,");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("SessionInterface $session,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("RequestStack $requestStack,");
    _builder.newLine();
    _builder.append("    ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "    ");
    _builder.append("Factory $entityFactory,");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("ControllerHelper $controllerHelper");
    {
      boolean _hasCategorisableEntities_2 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_2) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("FeatureActivationHelper $featureActivationHelper,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("CategoryHelper $categoryHelper");
        _builder.newLine();
      }
    }
    _builder.append(") {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->setTranslator($translator);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->permissionApi = $permissionApi;");
    _builder.newLine();
    {
      Boolean _targets_6 = this._utils.targets(it, "1.5");
      boolean _not_3 = (!(_targets_6).booleanValue());
      if (_not_3) {
        _builder.append("    ");
        _builder.append("$this->templateEngine = $templateEngine;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$this->session = $session;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->request = $requestStack->getCurrentRequest();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->entityFactory = $entityFactory;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->controllerHelper = $controllerHelper;");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_3 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_3) {
        _builder.append("    ");
        _builder.append("$this->featureActivationHelper = $featureActivationHelper;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->categoryHelper = $categoryHelper;");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    CharSequence _setTranslatorMethod = this._modelBehaviourExtensions.setTranslatorMethod(it);
    _builder.append(_setTranslatorMethod);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Boolean _targets_7 = this._utils.targets(it, "1.5");
      if ((_targets_7).booleanValue()) {
        CharSequence _amendForm = this.amendForm(it);
        _builder.append(_amendForm);
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _options = this.getOptions(it);
        _builder.append(_options);
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    CharSequence _results = this.getResults(it);
    _builder.append(_results);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this._modelExtensions.hasAbstractStringFieldsEntity(it_1));
    };
    final Iterable<Entity> entitiesWithStrings = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns list of supported search types.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getSearchTypes()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$searchTypes = [");
    _builder.newLine();
    {
      for(final Entity entity : entitiesWithStrings) {
        _builder.append("        ");
        _builder.append("\'");
        String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
        _builder.append(_firstLower, "        ");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(entity.getNameMultiple());
        _builder.append(_formatForCodeCapital_3, "        ");
        _builder.append("\' => [");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("\'value\' => \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode, "            ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("\'label\' => $this->__(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(entity.getNameMultiple());
        _builder.append(_formatForDisplayCapital, "            ");
        _builder.append("\')");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("]");
        {
          Entity _last = IterableExtensions.<Entity>last(entitiesWithStrings);
          boolean _notEquals = (!Objects.equal(entity, _last));
          if (_notEquals) {
            _builder.append(",");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedTypes = $this->controllerHelper->getObjectTypes(\'helper\', [\'helper\' => \'search\', \'action\' => \'getSearchTypes\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedSearchTypes = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($searchTypes as $searchType => $typeInfo) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!in_array($typeInfo[\'value\'], $allowedTypes)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$allowedSearchTypes[$searchType] = $typeInfo;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $allowedSearchTypes;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    CharSequence _errors = this.getErrors(it);
    _builder.append(_errors);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _formatWhere = this.formatWhere(it);
    _builder.append(_formatWhere);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence amendForm(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function amendForm(FormBuilderInterface $form)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$this->permissionApi->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("::\', \'::\', ACCESS_READ)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'active\', HiddenType::class, [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'data\' => true");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$searchTypes = $this->getSearchTypes();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($searchTypes as $searchType => $typeInfo) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$builder->add(\'active_\' . $searchType, CheckboxType::class, [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'value\' => $typeInfo[\'value\'],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'label\' => $typeInfo[\'label\'],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'label_attr\' => [\'class\' => \'checkbox-inline\'],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'required\' => false");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getOptions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getOptions($active, $modVars = null)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$this->permissionApi->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("::\', \'::\', ACCESS_READ)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$searchTypes = $this->getSearchTypes();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($searchTypes as $searchType => $typeInfo) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateParameters[\'active_\' . $searchType] = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->templateEngine->renderResponse(\'@");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("/Search/options.html.twig\', $templateParameters)->getContent();");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getResults(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getResults(array $words, $searchType = \'AND\', $modVars = null)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$this->permissionApi->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("::\', \'::\', ACCESS_READ)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise array for results");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$results = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// retrieve list of activated object types");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("    ");
        _builder.append("$searchTypes = $this->getSearchTypes();");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$searchTypes = isset($modVars[\'objectTypes\']) ? (array)$modVars[\'objectTypes\'] : [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!is_array($searchTypes) || !count($searchTypes)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($this->request->isMethod(\'GET\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$searchTypes = $this->request->query->get(\'");
        String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
        _builder.append(_firstLower, "            ");
        _builder.append("SearchTypes\', []);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("} elseif ($this->request->isMethod(\'POST\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$searchTypes = $this->request->request->get(\'");
        String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
        _builder.append(_firstLower_1, "            ");
        _builder.append("SearchTypes\', []);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($searchTypes as ");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("$searchTypeCode => $typeInfo");
      } else {
        _builder.append("$objectType");
      }
    }
    _builder.append(") {");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("        ");
        _builder.append("$objectType = $typeInfo[\'value\'];");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$isActivated = false;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if ($this->request->isMethod(\'GET\')) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$isActivated = $this->request->query->get(\'active_\' . $searchTypeCode, false);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("} elseif ($this->request->isMethod(\'POST\')) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$isActivated = $this->request->request->get(\'active_\' . $searchTypeCode, false);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (!$isActivated) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$whereArray = [];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$languageField = null;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
        return Boolean.valueOf(this._modelExtensions.hasAbstractStringFieldsEntity(it_1));
      };
      Iterable<DataObject> _filter = IterableExtensions.<DataObject>filter(it.getEntities(), _function);
      for(final DataObject entity : _filter) {
        _builder.append("            ");
        _builder.append("case \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode, "            ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        {
          Iterable<AbstractStringField> _abstractStringFieldsEntity = this._modelExtensions.getAbstractStringFieldsEntity(entity);
          for(final AbstractStringField field : _abstractStringFieldsEntity) {
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("$whereArray[] = \'tbl.");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(field.getName());
            _builder.append(_formatForCode_1, "                ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasLanguageFieldsEntity = this._modelExtensions.hasLanguageFieldsEntity(entity);
          if (_hasLanguageFieldsEntity) {
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("$languageField = \'");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(this._modelExtensions.getLanguageFieldsEntity(entity)).getName());
            _builder.append(_formatForCode_2, "                ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$repository = $this->entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// build the search query without any joins");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb = $repository->genericBaseQuery(\'\', \'\', false);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// build where expression for given search type");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$whereExpr = $this->formatWhere($qb, $words, $whereArray, $searchType);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$qb->andWhere($whereExpr);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// set a sensitive limit");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$query->setFirstResult(0)");
    _builder.newLine();
    _builder.append("              ");
    _builder.append("->setMaxResults(250);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// fetch the results");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entities = $query->getResult();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (count($entities) == 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$descriptionField = $repository->getDescriptionFieldName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entitiesWithDisplayAction = [\'");
    final Function1<Entity, Boolean> _function_1 = (Entity it_1) -> {
      return Boolean.valueOf(this._controllerExtensions.hasDisplayAction(it_1));
    };
    final Function1<Entity, String> _function_2 = (Entity it_1) -> {
      return this._formattingExtensions.formatForCode(it_1.getName());
    };
    String _join = IterableExtensions.join(IterableExtensions.<Entity, String>map(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function_1), _function_2), "\', \'");
    _builder.append(_join, "        ");
    _builder.append("\'];");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($entities as $entity) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$urlArgs = $entity->createUrlArgs();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$hasDisplayAction = in_array($objectType, $entitiesWithDisplayAction);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$instanceId = $entity->createCompositeIdentifier();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// perform permission check");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!$this->permissionApi->hasPermission(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "            ");
    _builder.append(":\' . ucfirst($objectType) . \':\', $instanceId . \'::\', ACCESS_OVERVIEW)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("            ");
        _builder.append("if (in_array($objectType, [\'");
        final Function1<Entity, String> _function_3 = (Entity e) -> {
          return this._formattingExtensions.formatForCode(e.getName());
        };
        String _join_1 = IterableExtensions.join(IterableExtensions.<Entity, String>map(this._modelBehaviourExtensions.getCategorisableEntities(it), _function_3), "\', \'");
        _builder.append(_join_1, "            ");
        _builder.append("\'])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("        ");
        _builder.append("if (!$this->categoryHelper->hasPermission($entity)) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("            ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$description = !empty($descriptionField) ? $entity[$descriptionField] : \'\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$created = isset($entity[\'createdDate\']) ? $entity[\'createdDate\'] : null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$urlArgs[\'_locale\'] = (null !== $languageField && !empty($entity[$languageField])) ? $entity[$languageField] : $this->request->getLocale();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$displayUrl = $hasDisplayAction ? new RouteUrl(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "            ");
    _builder.append("_\' . $objectType . \'_display\', $urlArgs) : \'\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result = new SearchResultEntity();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result->setTitle($entity->getTitleFromDisplayPattern())");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("->setText($description)");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("->setModule(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "                ");
    _builder.append("\')");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("->setCreated($created)");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("->setSesid($this->session->getId())");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("->setUrl($displayUrl);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$results[] = $result;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $results;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getErrors(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getErrors()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return [];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formatWhere(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Construct a QueryBuilder Where orX|andX Expr instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param QueryBuilder $qb");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $words the words to query for");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $fields");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $searchtype AND|OR|EXACT");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return null|Composite");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function formatWhere(QueryBuilder $qb, array $words, array $fields, $searchtype = \'AND\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($words) || empty($fields)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$method = ($searchtype == \'OR\') ? \'orX\' : \'andX\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/** @var $where Composite */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = $qb->expr()->$method();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$i = 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($words as $word) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$subWhere = $qb->expr()->orX();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($fields as $field) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$expr = $qb->expr()->like($field, \"?$i\");");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$subWhere->add($expr);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$qb->setParameter($i, \'%\' . $word . \'%\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$i++;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$where->add($subWhere);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $where;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence searchHelperImpl(final Application it) {
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
    _builder.append("\\Helper\\Base\\AbstractSearchHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Search helper implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class SearchHelper extends AbstractSearchHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the search helper here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
