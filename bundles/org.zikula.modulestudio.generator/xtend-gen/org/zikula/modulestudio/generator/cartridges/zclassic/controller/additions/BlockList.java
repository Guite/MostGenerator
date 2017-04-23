package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.ListBlock;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlocksView;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class BlockList {
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
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating block for multiple objects");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Block/ItemListBlock.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.listBlockBaseClass(it)), this.fh.phpFileContent(it, this.listBlockImpl(it)));
    new BlocksView().generate(it, fsa);
    new ListBlock().generate(it, fsa);
  }
  
  private CharSequence listBlockBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Block\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Zikula\\BlocksModule\\AbstractBlockHandler;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\AbstractBundle;");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2);
        _builder.append("\\Block\\Form\\Type\\ItemListBlockType;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Generic item list block base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractItemListBlock extends AbstractBlockHandler");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _listBlockBaseImpl = this.listBlockBaseImpl(it);
    _builder.append(_listBlockBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listBlockBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* List of object types allowing categorisation.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var array");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $categorisableObjectTypes;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* ItemListBlock constructor.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param AbstractBundle $bundle An AbstractBundle instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @throws \\InvalidArgumentException");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function __construct(AbstractBundle $bundle)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("parent::__construct($bundle);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->categorisableObjectTypes = [");
        {
          Iterable<Entity> _categorisableEntities = this._modelBehaviourExtensions.getCategorisableEntities(it);
          boolean _hasElements = false;
          for(final Entity entity : _categorisableEntities) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "    ");
            }
            _builder.append("\'");
            String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode, "    ");
            _builder.append("\'");
          }
        }
        _builder.append("];");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    CharSequence _display = this.display(it);
    _builder.append(_display);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _displayTemplate = this.getDisplayTemplate(it);
    _builder.append(_displayTemplate);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _sortParam = this.getSortParam(it);
    _builder.append(_sortParam);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _modify = this.modify(it);
    _builder.append(_modify);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns default settings for this block.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The default settings");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDefaults()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$defaults = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'objectType\' => \'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'sorting\' => \'default\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'amount\' => 5,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'template\' => \'itemlist_display.html.twig\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'customTemplate\' => \'\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'filter\' => \'\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $defaults;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_2 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_2) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Resolves category filter ids.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param array $properties The block properties array");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return array The updated block properties");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function resolveCategoryIds(array $properties)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!isset($properties[\'catIds\'])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$categoryHelper = $this->get(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService, "        ");
        _builder.append(".category_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$primaryRegistry = $categoryHelper->getPrimaryProperty($properties[\'objectType\']);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$properties[\'catIds\'] = [$primaryRegistry => []];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} elseif (!is_array($properties[\'catIds\'])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$properties[\'catIds\'] = explode(\',\', $properties[\'catIds\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $properties;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence display(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Display the block content.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $properties The block properties array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|string");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function display(array $properties)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// only show block content if the user has the required permissions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(":ItemListBlock:\', \"$properties[title]::\", ACCESS_OVERVIEW)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set default values for all params which are not properly set");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$defaults = $this->getDefaults();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$properties = array_merge($defaults, $properties);");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$featureActivationHelper = $this->get(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService, "    ");
        _builder.append(".feature_activation_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties[\'objectType\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$properties = $this->resolveCategoryIds($properties);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService_1 = this._utils.appService(it);
    _builder.append(_appService_1, "    ");
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$contextArgs = [\'name\' => \'list\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($properties[\'objectType\']) || !in_array($properties[\'objectType\'], $controllerHelper->getObjectTypes(\'block\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$properties[\'objectType\'] = $controllerHelper->getDefaultObjectType(\'block\', $contextArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $properties[\'objectType\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->get(\'");
    String _appService_2 = this._utils.appService(it);
    _builder.append(_appService_2, "    ");
    _builder.append(".entity_factory\')->getRepository($objectType);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// create query");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = $properties[\'filter\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$orderBy = $this->getSortParam($properties, $repository);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $repository->genericBaseQuery($where, $orderBy);");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// fetch category registries");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$catProperties = null;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (in_array($objectType, $this->categorisableObjectTypes)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties[\'objectType\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$categoryHelper = $this->get(\'");
        String _appService_3 = this._utils.appService(it);
        _builder.append(_appService_3, "            ");
        _builder.append(".category_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$catProperties = $categoryHelper->getAllProperties($objectType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("// apply category filters");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("if (is_array($properties[\'catIds\']) && count($properties[\'catIds\']) > 0) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("            ");
        _builder.append("$qb = $categoryHelper->buildFilterClauses($qb, $objectType, $properties[\'catIds\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
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
    _builder.append("// get objects from database");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentPage = 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = $properties[\'amount\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = $repository->retrieveCollectionResult($query, $orderBy, true);");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_2 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_2) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entities = $this->get(\'");
        String _appService_4 = this._utils.appService(it);
        _builder.append(_appService_4, "        ");
        _builder.append(".category_helper\')->filterEntitiesByPermission($entities);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set a block title");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($properties[\'title\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$properties[\'title\'] = $this->__(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append(" items\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template = $this->getDisplayTemplate($properties);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'vars\' => $properties,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'objectType\' => $objectType,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'items\' => $entities");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_3 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_3) {
        _builder.append("    ");
        _builder.append("if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties[\'objectType\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$templateParameters[\'properties\'] = $properties;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("    ");
        _builder.append("$imageHelper = $this->get(\'");
        String _appService_5 = this._utils.appService(it);
        _builder.append(_appService_5, "    ");
        _builder.append(".image_helper\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(");
    {
      boolean _hasUploads_1 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_1) {
        _builder.append("$imageHelper, ");
      }
    }
    _builder.append("\'block\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->renderView($template, $templateParameters);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getDisplayTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the template used for output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $properties The block properties array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the template path");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDisplayTemplate(array $properties)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateFile = $properties[\'template\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($templateFile == \'custom\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateFile = $properties[\'customTemplate\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateForObjectType = str_replace(\'itemlist_\', \'itemlist_\' . $properties[\'objectType\'] . \'_\', $templateFile);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templating = $this->get(\'templating\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateOptions = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'ContentType/\' . $templateForObjectType,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'Block/\' . $templateForObjectType,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'ContentType/\' . $templateFile,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'Block/\' . $templateFile,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'Block/itemlist.html.twig\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($templateOptions as $templatePath) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($templating->exists(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("/\' . $templatePath)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$template = \'@");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "            ");
    _builder.append("/\' . $templatePath;");
    _builder.newLineIfNotEmpty();
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
    _builder.append("return $template;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getSortParam(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines the order by parameter for item selection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array               $properties The block properties array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine_Repository $repository The repository used for data fetching");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the sorting clause");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getSortParam(array $properties, $repository)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($properties[\'sorting\'] == \'random\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'RAND()\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortParam = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($properties[\'sorting\'] == \'newest\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entityFactory = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService, "        ");
    _builder.append(".entity_factory\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$idFields = $entityFactory->getIdFields($properties[\'objectType\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (count($idFields) == 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$sortParam = $idFields[0] . \' DESC\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (!empty($sortParam)) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$sortParam .= \', \';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$sortParam .= $idField . \' DESC\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($properties[\'sorting\'] == \'default\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sortParam = $repository->getDefaultSortingField() . \' ASC\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $sortParam;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence modify(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the fully qualified class name of the block\'s form class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Template path");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getFormClassName()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("ItemListBlockType::class");
      } else {
        _builder.append("\'");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\Block\\Form\\Type\\ItemListBlockType\'");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns any array of form options.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Options array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getFormOptions()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$request = $this->get(\'request_stack\')->getCurrentRequest();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($request->attributes->has(\'blockEntity\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$blockEntity = $request->attributes->get(\'blockEntity\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (is_object($blockEntity) && method_exists($blockEntity, \'getContent\')) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$blockProperties = $blockEntity->getContent();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (isset($blockProperties[\'objectType\'])) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$objectType = $blockProperties[\'objectType\'];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'object_type\' => $objectType");
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("\'is_categorisable\' => in_array($objectType, $this->categorisableObjectTypes),");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'category_helper\' => $this->get(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService, "        ");
        _builder.append(".category_helper\'),");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("\'feature_activation_helper\' => $this->get(\'");
        String _appService_1 = this._utils.appService(it);
        _builder.append(_appService_1, "        ");
        _builder.append(".feature_activation_helper\')");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the template used for rendering the editing form.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Template path");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getFormTemplate()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("/Block/itemlist_modify.html.twig\';");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listBlockImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Block;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Block\\Base\\AbstractItemListBlock;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Generic item list block implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ItemListBlock extends AbstractItemListBlock");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the item list block here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
