package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.Finder;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ExternalView;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ExternalController {
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
    InputOutput.<String>println("Generating external controller");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Controller/ExternalController.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.externalBaseClass(it)), this.fh.phpFileContent(it, this.externalImpl(it)));
    new Finder().generate(it, fsa);
    new ExternalView().generate(it, fsa);
  }
  
  private CharSequence externalBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Controller\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\Route;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Response;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Controller\\AbstractController;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Response\\PlainResponse;");
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
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Controller for external calls base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractExternalController extends AbstractController");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _externalBaseImpl = this.externalBaseImpl(it);
    _builder.append(_externalBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence externalBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _displayBase = this.displayBase(it);
    _builder.append(_displayBase);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _finderBase = this.finderBase(it);
    _builder.append(_finderBase);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _displayDocBlock = this.displayDocBlock(it, Boolean.valueOf(true));
    _builder.append(_displayDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _displaySignature = this.displaySignature(it);
    _builder.append(_displaySignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _displayBaseImpl = this.displayBaseImpl(it);
    _builder.append(_displayBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Displays one item of a certain object type using a separate template for external usages.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/display/{objectType}/{id}/{source}/{displayMode}\",");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        requirements = {");
        {
          final Function1<Entity, Boolean> _function = (Entity it_1) -> {
            return Boolean.valueOf(this._modelExtensions.hasCompositeKeys(it_1));
          };
          boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function));
          if (_isEmpty) {
            _builder.append("\"id\" = \"\\d+\", ");
          }
        }
        _builder.append("\"source\" = \"contentType|scribite\", \"displayMode\" = \"link|embed\"},");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*        defaults = {\"source\" = \"contentType\", \"contentType\" = \"embed\"},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        methods = {\"GET\"}");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* )");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType  The currently treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int    $id          Identifier of the entity to be shown");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $source      Source of this call (contentType or scribite)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $displayMode Display mode (link or embed)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Desired data output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displaySignature(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function displayAction($objectType, $id, $source, $displayMode)");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService);
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$contextArgs = [\'controller\' => \'external\', \'action\' => \'display\'];");
    _builder.newLine();
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerAction\', $contextArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$component = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append(":\' . ucfirst($objectType) . \':\';");
    _builder.newLineIfNotEmpty();
    _builder.append("if (!$this->hasPermission($component, $id . \'::\', ACCESS_READ)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entityFactory = $this->get(\'");
    String _appService_1 = this._utils.appService(it);
    _builder.append(_appService_1);
    _builder.append(".entity_factory\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$repository = $entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.append("$repository->setRequest($this->get(\'request_stack\')->getCurrentRequest());");
    _builder.newLine();
    _builder.append("$idValues = $controllerHelper->retrieveIdentifier($request, [], $objectType);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$hasIdentifier = $controllerHelper->isValidIdentifier($idValues);");
    _builder.newLine();
    _builder.append("if (!$hasIdentifier) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new Response($this->__(\'Error! Invalid identifier received.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// assign object data fetched from the database");
    _builder.newLine();
    _builder.append("$entity = $repository->selectById($idValues);");
    _builder.newLine();
    _builder.append("if (null === $entity) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new Response($this->__(\'No such item.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("$entity->initWorkflow();");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("$instance = $entity->createCompositeIdentifier() . \'::\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'objectType\' => $objectType,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'source\' => $source,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType => $entity,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'displayMode\' => $displayMode");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$contextArgs = [\'controller\' => $objectType, \'action\' => \'display\'];");
    _builder.newLine();
    _builder.append("$additionalParameters = $repository->getAdditionalTemplateParameters(");
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("$this->get(\'");
        String _appService_2 = this._utils.appService(it);
        _builder.append(_appService_2);
        _builder.append(".image_helper\'), ");
      }
    }
    _builder.append("\'controllerAction\', $contextArgs);");
    _builder.newLineIfNotEmpty();
    _builder.append("$templateParameters = array_merge($templateParameters, $additionalParameters);");
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper) {
        _builder.newLine();
        _builder.append("$templateParameters[\'featureActivationHelper\'] = $this->get(\'");
        String _appService_3 = this._utils.appService(it);
        _builder.append(_appService_3);
        _builder.append(".feature_activation_helper\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("return $this->render(\'@");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append("/External/\' . ucfirst($objectType) . \'/display.html.twig\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence finderBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _finderDocBlock = this.finderDocBlock(it, Boolean.valueOf(true));
    _builder.append(_finderDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _finderSignature = this.finderSignature(it);
    _builder.append(_finderSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _finderBaseImpl = this.finderBaseImpl(it);
    _builder.append(_finderBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence finderDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Popup selector for Scribite plugins.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Finds items of a certain object type.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/finder/{objectType}/{editor}/{sort}/{sortdir}/{pos}/{num}\",");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        requirements = {\"editor\" = \"ckeditor|tinymce\", \"sortdir\" = \"asc|desc\", \"pos\" = \"\\d+\", \"num\" = \"\\d+\"},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        defaults = {\"sort\" = \"\", \"sortdir\" = \"asc\", \"pos\" = 1, \"num\" = 0},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        methods = {\"GET\"},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        options={\"expose\"=true}");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* )");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Request $request    The current request");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType The object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $editor     Name of used Scribite editor");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $sort       Sorting field");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $sortdir    Sorting direction");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int     $pos        Current pager position");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int     $num        Amount of entries to display");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return output The external item finder page");
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
  
  private CharSequence finderSignature(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function finderAction(Request $request, $objectType, $editor, $sort, $sortdir, $pos = 1, $num = 0)");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence finderBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$assetHelper = $this->get(\'zikula_core.common.theme.asset_helper\');");
    _builder.newLine();
    _builder.append("$cssAssetBag = $this->get(\'zikula_core.common.theme.assets_css\');");
    _builder.newLine();
    _builder.append("$cssAssetBag->add($assetHelper->resolve(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append(":css/style.css\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("$activatedObjectTypes = $this->getVar(\'enabledFinderTypes\', []);");
    _builder.newLine();
    _builder.append("if (!in_array($objectType, $activatedObjectTypes)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (!$this->hasPermission(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append(":\' . ucfirst($objectType) . \':\', \'::\', ACCESS_COMMENT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (empty($editor) || !in_array($editor, [\'ckeditor\', \'tinymce\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new Response($this->__(\'Error: Invalid editor context given for external controller action.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$repository = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService);
    _builder.append(".entity_factory\')->getRepository($objectType);");
    _builder.newLineIfNotEmpty();
    _builder.append("$repository->setRequest($request);");
    _builder.newLine();
    _builder.append("if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sort = $repository->getDefaultSortingField();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$sdir = strtolower($sortdir);");
    _builder.newLine();
    _builder.append("if ($sdir != \'asc\' && $sdir != \'desc\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sdir = \'asc\';");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// the current offset which is used to calculate the pagination");
    _builder.newLine();
    _builder.append("$currentPage = (int) $pos;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// the number of items displayed on a page for pagination");
    _builder.newLine();
    _builder.append("$resultsPerPage = (int) $num;");
    _builder.newLine();
    _builder.append("if ($resultsPerPage == 0) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = $this->getVar(\'pageSize\', 20);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'editorName\' => $editor,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'objectType\' => $objectType,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'sort\' => $sort,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'sortdir\' => $sdir,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'currentPage\' => $currentPage");
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.append(",");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFields_1 = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields_1) {
        _builder.append("    ");
        _builder.append("\'onlyImages\' => false,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'imageField\' => \'\'");
        _builder.newLine();
      }
    }
    _builder.append("];");
    _builder.newLine();
    _builder.append("$searchTerm = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$formOptions = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'objectType\' => $objectType,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'editorName\' => $editor");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.append("$form = $this->createForm(\'");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type\\Finder\\\\\' . ucfirst($objectType) . \'FinderType\', $templateParameters, $formOptions);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("if ($form->handleRequest($request)->isValid()) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$formData = $form->getData();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters = array_merge($templateParameters, $formData);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentPage = $formData[\'currentPage\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = $formData[\'num\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sort = $formData[\'sort\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sdir = $formData[\'sortdir\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$searchTerm = $formData[\'q\'];");
    _builder.newLine();
    {
      boolean _hasImageFields_2 = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields_2) {
        _builder.append("    ");
        _builder.append("$templateParameters[\'onlyImages\'] = isset($formData[\'onlyImages\']) ? (bool)$formData[\'onlyImages\'] : false;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$templateParameters[\'imageField\'] = isset($formData[\'imageField\']) ? $formData[\'imageField\'] : \'\';");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$where = \'\';");
    _builder.newLine();
    _builder.append("$sortParam = $sort . \' \' . $sdir;");
    _builder.newLine();
    {
      boolean _hasImageFields_3 = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields_3) {
        _builder.newLine();
        _builder.append("if (true === $templateParameters[\'onlyImages\'] && $templateParameters[\'imageField\'] != \'\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$searchTerm = \'\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$imageField = $templateParameters[\'imageField\'];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$whereParts = [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ([\'gif\', \'jpg\', \'jpeg\', \'jpe\', \'png\', \'bmp\'] as $imageExtension) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$whereParts[] = \'tbl.\' . $imageField . \':like:%.\' . $imageExtension;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$where = \'(\' . implode(\'*\', $whereParts) . \')\';");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("if ($searchTerm != \'\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = $repository->selectSearch($searchTerm, [], $sortParam, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = $repository->selectWherePaginated($where, $sortParam, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("if (in_array($objectType, [\'");
        final Function1<Entity, String> _function = (Entity e) -> {
          return this._formattingExtensions.formatForCode(e.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<Entity, String>map(this._modelBehaviourExtensions.getCategorisableEntities(it), _function), "\', \'");
        _builder.append(_join);
        _builder.append("\'])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$featureActivationHelper = $this->get(\'");
        String _appService_1 = this._utils.appService(it);
        _builder.append(_appService_1, "    ");
        _builder.append(".feature_activation_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$entities = $this->get(\'");
        String _appService_2 = this._utils.appService(it);
        _builder.append(_appService_2, "        ");
        _builder.append(".category_helper\')->filterEntitiesByPermission($entities);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("foreach ($entities as $k => $entity) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity->initWorkflow();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("$templateParameters[\'items\'] = $entities;");
    _builder.newLine();
    _builder.append("$templateParameters[\'finderForm\'] = $form->createView();");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasImageFields_4 = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields_4) {
        _builder.append("$imageHelper = $this->get(\'");
        String _appService_3 = this._utils.appService(it);
        _builder.append(_appService_3);
        _builder.append(".image_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("$templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters($imageHelper, \'controllerAction\', [\'action\' => \'display\']));");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper) {
        _builder.append("$templateParameters[\'featureActivationHelper\'] = $this->get(\'");
        String _appService_4 = this._utils.appService(it);
        _builder.append(_appService_4);
        _builder.append(".feature_activation_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("$templateParameters[\'pager\'] = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'numitems\' => $objectCount,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'itemsperpage\' => $resultsPerPage");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$output = $this->renderView(\'@");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2);
    _builder.append("/External/\' . ucfirst($objectType) . \'/find.html.twig\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("return new PlainResponse($output);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence externalImpl(final Application it) {
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
    _builder.append("\\Controller\\Base\\AbstractExternalController;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\Route;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Controller for external calls implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Route(\"/external\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ExternalController extends AbstractExternalController");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _displayImpl = this.displayImpl(it);
    _builder.append(_displayImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _finderImpl = this.finderImpl(it);
    _builder.append(_finderImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the external controller here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _displayDocBlock = this.displayDocBlock(it, Boolean.valueOf(false));
    _builder.append(_displayDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _displaySignature = this.displaySignature(it);
    _builder.append(_displaySignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::displayAction($objectType, $id, $source, $displayMode);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence finderImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _finderDocBlock = this.finderDocBlock(it, Boolean.valueOf(false));
    _builder.append(_finderDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _finderSignature = this.finderSignature(it);
    _builder.append(_finderSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::finderAction($request, $objectType, $editor, $sort, $sortdir, $pos, $num);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
