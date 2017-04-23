package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.UserField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class AjaxController {
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
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Ajax controller class");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Controller/AjaxController.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.ajaxControllerBaseClass(it)), fh.phpFileContent(it, this.ajaxControllerImpl(it)));
  }
  
  private CharSequence ajaxControllerBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Controller\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(this._modelExtensions.getAllUserFields(it));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("use Doctrine\\ORM\\AbstractQuery;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\HttpFoundation\\JsonResponse;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    {
      if ((this._modelBehaviourExtensions.hasTrees(it) && this._controllerExtensions.hasEditActions(it))) {
        _builder.append("use Symfony\\Component\\Routing\\Generator\\UrlGeneratorInterface;");
        _builder.newLine();
      }
    }
    {
      if (((this.needsDuplicateCheck(it) || this._modelExtensions.hasBooleansWithAjaxToggle(it)) || this._modelBehaviourExtensions.hasTrees(it))) {
        _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.append("use RuntimeException;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Controller\\AbstractController;");
    _builder.newLine();
    {
      if ((((this._generatorSettingsExtensions.generateExternalControllerAndFinder(it) || this.needsDuplicateCheck(it)) || this._modelExtensions.hasBooleansWithAjaxToggle(it)) || this._modelBehaviourExtensions.hasTrees(it))) {
        _builder.append("use Zikula\\Core\\Response\\Ajax\\AjaxResponse;");
        _builder.newLine();
      }
    }
    {
      if ((this.needsDuplicateCheck(it) || this._modelExtensions.hasBooleansWithAjaxToggle(it))) {
        _builder.append("use Zikula\\Core\\Response\\Ajax\\BadDataResponse;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_1) {
        _builder.append("use Zikula\\Core\\Response\\Ajax\\FatalResponse;");
        _builder.newLine();
      }
    }
    {
      boolean _hasBooleansWithAjaxToggle = this._modelExtensions.hasBooleansWithAjaxToggle(it);
      if (_hasBooleansWithAjaxToggle) {
        _builder.append("use Zikula\\Core\\Response\\Ajax\\NotFoundResponse;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Ajax controller base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractAjaxController extends AbstractController");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _additionalAjaxFunctionsBase = this.additionalAjaxFunctionsBase(it);
    _builder.append(_additionalAjaxFunctionsBase, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence additionalAjaxFunctionsBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _userSelectorsBase = this.userSelectorsBase(it);
    _builder.append(_userSelectorsBase);
    _builder.newLineIfNotEmpty();
    {
      boolean _generateExternalControllerAndFinder = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
      if (_generateExternalControllerAndFinder) {
        _builder.newLine();
        CharSequence _itemListFinderBase = this.getItemListFinderBase(it);
        _builder.append(_itemListFinderBase);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(it);
      if (_needsAutoCompletion) {
        _builder.newLine();
        CharSequence _itemListAutoCompletionBase = this.getItemListAutoCompletionBase(it);
        _builder.append(_itemListAutoCompletionBase);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsDuplicateCheck = this.needsDuplicateCheck(it);
      if (_needsDuplicateCheck) {
        _builder.newLine();
        CharSequence _checkForDuplicateBase = this.checkForDuplicateBase(it);
        _builder.append(_checkForDuplicateBase);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasBooleansWithAjaxToggle = this._modelExtensions.hasBooleansWithAjaxToggle(it);
      if (_hasBooleansWithAjaxToggle) {
        _builder.newLine();
        CharSequence _ggleFlagBase = this.toggleFlagBase(it);
        _builder.append(_ggleFlagBase);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _handleTreeOperationBase = this.handleTreeOperationBase(it);
        _builder.append(_handleTreeOperationBase, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence userSelectorsBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<UserField> userFields = this._modelExtensions.getAllUserFields(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(userFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          for(final UserField userField : userFields) {
            _builder.newLine();
            _builder.append("/**");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("* Retrieves a list of users.");
            _builder.newLine();
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
            _builder.append("* @return JsonResponse");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("*/");
            _builder.newLine();
            _builder.append("public function get");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(userField.getEntity().getName());
            _builder.append(_formatForCodeCapital);
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(userField.getName());
            _builder.append(_formatForCodeCapital_1);
            _builder.append("UsersAction(Request $request)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return $this->getCommonUsersListAction($request);");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _needsUserAutoCompletion = this._modelBehaviourExtensions.needsUserAutoCompletion(it);
      if (_needsUserAutoCompletion) {
        _builder.newLine();
        CharSequence _commonUsersListBase = this.getCommonUsersListBase(it);
        _builder.append(_commonUsersListBase);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence getCommonUsersListBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _commonUsersListDocBlock = this.getCommonUsersListDocBlock(it, Boolean.valueOf(true));
    _builder.append(_commonUsersListDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _commonUsersListSignature = this.getCommonUsersListSignature(it);
    _builder.append(_commonUsersListSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _commonUsersListBaseImpl = this.getCommonUsersListBaseImpl(it);
    _builder.append(_commonUsersListBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCommonUsersListDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieves a general purpose list of users.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/getCommonUsersList\", options={\"expose\"=true})");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Method(\"GET\")");
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
    _builder.append("* @return JsonResponse");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/ ");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCommonUsersListSignature(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function getCommonUsersListAction(Request $request)");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCommonUsersListBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("::Ajax\', \'::\', ACCESS_EDIT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$fragment = $request->query->get(\'fragment\', \'\');");
    _builder.newLine();
    _builder.append("$userRepository = $this->get(\'zikula_users_module.user_repository\');");
    _builder.newLine();
    _builder.append("$limit = 50;");
    _builder.newLine();
    _builder.append("$filter = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'uname\' => [\'operator\' => \'like\', \'operand\' => \'%\' . $fragment . \'%\']");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.append("$results = $userRepository->query($filter, [\'uname\' => \'asc\'], $limit);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// load avatar plugin");
    _builder.newLine();
    _builder.append("include_once \'lib/legacy/viewplugins/function.useravatar.php\';");
    _builder.newLine();
    _builder.append("$view = \\Zikula_View::getInstance(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append("\', false);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("$resultItems = [];");
    _builder.newLine();
    _builder.append("if (count($results) > 0) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($results as $result) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$resultItems[] = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'uid\' => $result->getUid(),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'uname\' => $result->getUname(),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'avatar\' => smarty_function_useravatar([\'uid\' => $result->getUid(), \'rating\' => \'g\'], $view)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("return new JsonResponse($resultItems);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListFinderBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _itemListFinderDocBlock = this.getItemListFinderDocBlock(it, Boolean.valueOf(true));
    _builder.append(_itemListFinderDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _itemListFinderSignature = this.getItemListFinderSignature(it);
    _builder.append(_itemListFinderSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _itemListFinderBaseImpl = this.getItemListFinderBaseImpl(it);
    _builder.append(_itemListFinderBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    CharSequence _itemListFinderPrepareSlimItem = this.getItemListFinderPrepareSlimItem(it);
    _builder.append(_itemListFinderPrepareSlimItem);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence getItemListFinderDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieve item list for finder selections in Forms, Content type plugin and Scribite.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/getItemListFinder\", options={\"expose\"=true})");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Method(\"POST\")");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $ot      Name of currently used object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $sort    Sorting field");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $sortdir Sorting direction");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return AjaxResponse");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListFinderSignature(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function getItemListFinderAction(Request $request)");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListFinderBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("::Ajax\', \'::\', ACCESS_EDIT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$objectType = $request->request->getAlnum(\'ot\', \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService);
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$contextArgs = [\'controller\' => \'ajax\', \'action\' => \'getItemListFinder\'];");
    _builder.newLine();
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerAction\', $contextArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$repository = $this->get(\'");
    String _appService_1 = this._utils.appService(it);
    _builder.append(_appService_1);
    _builder.append(".entity_factory\')->getRepository($objectType);");
    _builder.newLineIfNotEmpty();
    _builder.append("$repository->setRequest($request);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$descriptionField = $repository->getDescriptionFieldName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$sort = $request->request->getAlnum(\'sort\', \'\');");
    _builder.newLine();
    _builder.append("if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sort = $repository->getDefaultSortingField();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$sdir = strtolower($request->request->getAlpha(\'sortdir\', \'\'));");
    _builder.newLine();
    _builder.append("if ($sdir != \'asc\' && $sdir != \'desc\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sdir = \'asc\';");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$where = \'\'; // filters are processed inside the repository class");
    _builder.newLine();
    _builder.append("$searchTerm = $request->request->get(\'q\', \'\');");
    _builder.newLine();
    _builder.append("$sortParam = $sort . \' \' . $sdir;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entities = [];");
    _builder.newLine();
    _builder.append("if ($searchTerm != \'\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list ($entities, $totalAmount) = $repository->selectSearch($searchTerm, [], $sortParam, 1, 50);");
    _builder.newLine();
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entities = $repository->selectWhere($where, $sortParam);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$slimItems = [];");
    _builder.newLine();
    _builder.append("$component = \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append(":\' . ucfirst($objectType) . \':\';");
    _builder.newLineIfNotEmpty();
    _builder.append("foreach ($entities as $item) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$itemId = $item->createCompositeIdentifier();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$this->hasPermission($component, $itemId . \'::\', ACCESS_READ)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$slimItems[] = $this->prepareSlimItem($repository, $objectType, $item, $itemId, $descriptionField);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("return new AjaxResponse($slimItems);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListFinderPrepareSlimItem(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Builds and returns a slim data array from a given entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param EntityRepository $repository       Repository for the treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string           $objectType       The currently treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param object           $item             The currently treated entity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string           $itemId           Data item identifier(s)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string           $descriptionField Name of item description field");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The slim data representation");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function prepareSlimItem($repository, $objectType, $item, $itemId, $descriptionField)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$previewParameters = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectType => $item");
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append(",");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.append("        ");
        _builder.append("\'featureActivationHelper\' => $this->get(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService, "        ");
        _builder.append(".feature_activation_helper\')");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$contextArgs = [\'controller\' => $objectType, \'action\' => \'display\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$additionalParameters = $repository->getAdditionalTemplateParameters(");
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("$this->get(\'");
        String _appService_1 = this._utils.appService(it);
        _builder.append(_appService_1, "    ");
        _builder.append(".image_helper\'), ");
      }
    }
    _builder.append("\'controllerAction\', $contextArgs);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$previewParameters = array_merge($previewParameters, $additionalParameters);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$previewInfo = base64_encode($this->get(\'twig\')->render(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("/External/\' . ucfirst($objectType) . \'/info.html.twig\', $previewParameters));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$title = $item->getTitleFromDisplayPattern();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$description = $descriptionField != \'\' ? $item[$descriptionField] : \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'id\'          => $itemId,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'title\'       => str_replace(\'&amp;\', \'&\', $title),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'description\' => $description,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'previewInfo\' => $previewInfo");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListAutoCompletionBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _itemListAutoCompletionDocBlock = this.getItemListAutoCompletionDocBlock(it, Boolean.valueOf(true));
    _builder.append(_itemListAutoCompletionDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _itemListAutoCompletionSignature = this.getItemListAutoCompletionSignature(it);
    _builder.append(_itemListAutoCompletionSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _itemListAutoCompletionBaseImpl = this.getItemListAutoCompletionBaseImpl(it);
    _builder.append(_itemListAutoCompletionBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListAutoCompletionDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Searches for entities for auto completion usage.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/getItemListAutoCompletion\", options={\"expose\"=true})");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Method(\"GET\")");
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
    _builder.append("* @return JsonResponse");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListAutoCompletionSignature(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function getItemListAutoCompletionAction(Request $request)");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListAutoCompletionBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("::Ajax\', \'::\', ACCESS_EDIT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$objectType = $request->query->getAlnum(\'ot\', \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService);
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$contextArgs = [\'controller\' => \'ajax\', \'action\' => \'getItemListAutoCompletion\'];");
    _builder.newLine();
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerAction\', $contextArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$repository = $this->get(\'");
    String _appService_1 = this._utils.appService(it);
    _builder.append(_appService_1);
    _builder.append(".entity_factory\')->getRepository($objectType);");
    _builder.newLineIfNotEmpty();
    _builder.append("$repository->setRequest($request);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$fragment = $request->query->get(\'fragment\', \'\');");
    _builder.newLine();
    _builder.append("$exclude = $request->query->get(\'exclude\', \'\');");
    _builder.newLine();
    _builder.append("$exclude = !empty($exclude) ? explode(\',\', str_replace(\', \', \',\', $exclude)) : [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// parameter for used sorting field");
    _builder.newLine();
    CharSequence _defaultSorting = new ControllerHelperFunctions().defaultSorting(it);
    _builder.append(_defaultSorting);
    _builder.newLineIfNotEmpty();
    _builder.append("$sortParam = $sort . \' asc\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$currentPage = 1;");
    _builder.newLine();
    _builder.append("$resultsPerPage = 20;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// get objects from database");
    _builder.newLine();
    _builder.append("list($entities, $objectCount) = $repository->selectSearch($fragment, $exclude, $sortParam, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$resultItems = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if ((is_array($entities) || is_object($entities)) && count($entities) > 0) {");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _prepareForAutoCompletionProcessing = this.prepareForAutoCompletionProcessing(it);
    _builder.append(_prepareForAutoCompletionProcessing, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("foreach ($entities as $item) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$itemTitle = $item->getTitleFromDisplayPattern();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$itemTitleStripped = str_replace(\'\"\', \'\', $itemTitle);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$itemDescription = isset($item[$descriptionFieldName]) && !empty($item[$descriptionFieldName]) ? $item[$descriptionFieldName] : \'\';//$this->__(\'No description yet.\')");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!empty($itemDescription)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$itemDescription = substr($itemDescription, 0, 50) . \'&hellip;\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$resultItem = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'id\' => $item->createCompositeIdentifier(),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'title\' => $item->getTitleFromDisplayPattern(),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'description\' => $itemDescription,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'image\' => \'\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// check for preview image");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (!empty($previewFieldName) && !empty($item[$previewFieldName])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$thumbImagePath = $imagineCacheManager->getThumb($item[$previewFieldName]->getPathname(), \'zkroot\', $thumbRuntimeOptions);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$resultItem[\'image\'] = \'<img src=\"\' . $thumbImagePath . \'\" width=\"50\" height=\"50\" alt=\"\' . $itemTitleStripped . \'\" />\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$resultItems[] = $resultItem;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("return new JsonResponse($resultItems);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence prepareForAutoCompletionProcessing(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$descriptionFieldName = $repository->getDescriptionFieldName();");
    _builder.newLine();
    _builder.append("$previewFieldName = $repository->getPreviewFieldName();");
    _builder.newLine();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.append("$imagineCacheManager = $this->get(\'liip_imagine.cache.manager\');");
        _builder.newLine();
        _builder.append("$imageHelper = $this->get(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService);
        _builder.append(".image_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("$thumbRuntimeOptions = $imageHelper->getRuntimeOptions($objectType, $previewFieldName, \'controllerAction\', $contextArgs);");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence checkForDuplicateBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _checkForDuplicateDocBlock = this.checkForDuplicateDocBlock(it, Boolean.valueOf(true));
    _builder.append(_checkForDuplicateDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _checkForDuplicateSignature = this.checkForDuplicateSignature(it);
    _builder.append(_checkForDuplicateSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _checkForDuplicateBaseImpl = this.checkForDuplicateBaseImpl(it);
    _builder.append(_checkForDuplicateBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence checkForDuplicateDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Checks whether a field value is a duplicate or not.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/checkForDuplicate\", options={\"expose\"=true})");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Method(\"POST\")");
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
    _builder.append("* @return AjaxResponse");
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
  
  private CharSequence checkForDuplicateSignature(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function checkForDuplicateAction(Request $request)");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence checkForDuplicateBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("::Ajax\', \'::\', ACCESS_EDIT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    CharSequence _prepareDuplicateCheckParameters = this.prepareDuplicateCheckParameters(it);
    _builder.append(_prepareDuplicateCheckParameters);
    _builder.newLineIfNotEmpty();
    _builder.append("/* can probably be removed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* $createMethod = \'create\' . ucfirst($objectType);");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* $object = $repository = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService, " ");
    _builder.append(".entity_factory\')->$createMethod();");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$result = false;");
    _builder.newLine();
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
          boolean _isPrimaryKey = it_1.isPrimaryKey();
          return Boolean.valueOf((!_isPrimaryKey));
        };
        final Iterable<DerivedField> uniqueFields = IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(entity), _function);
        _builder.newLineIfNotEmpty();
        {
          if (((!IterableExtensions.isEmpty(uniqueFields)) || (this._modelBehaviourExtensions.hasSluggableFields(entity) && entity.isSlugUnique()))) {
            _builder.append("case \'");
            String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode);
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$repository = $this->get(\'");
            String _appService_1 = this._utils.appService(it);
            _builder.append(_appService_1, "    ");
            _builder.append(".entity_factory\')->getRepository($objectType);");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("switch ($fieldName) {");
            _builder.newLine();
            {
              for(final DerivedField uniqueField : uniqueFields) {
                _builder.append("    ");
                _builder.append("case \'");
                String _formatForCode_1 = this._formattingExtensions.formatForCode(uniqueField.getName());
                _builder.append(_formatForCode_1, "    ");
                _builder.append("\':");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$result = $repository->detectUniqueState(\'");
                String _formatForCode_2 = this._formattingExtensions.formatForCode(uniqueField.getName());
                _builder.append(_formatForCode_2, "            ");
                _builder.append("\', $value, $exclude");
                {
                  final Function1<DataObject, Boolean> _function_1 = (DataObject it_1) -> {
                    return Boolean.valueOf(this._modelExtensions.hasCompositeKeys(it_1));
                  };
                  boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<DataObject>filter(it.getEntities(), _function_1));
                  boolean _not = (!_isEmpty);
                  if (_not) {
                    _builder.append("[0]");
                  }
                }
                _builder.append(");");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("break;");
                _builder.newLine();
              }
            }
            {
              if ((this._modelBehaviourExtensions.hasSluggableFields(entity) && entity.isSlugUnique())) {
                _builder.append("    ");
                _builder.append("case \'slug\':");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$entity = $repository->selectBySlug($value, false, $exclude);");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$result = null !== $entity && isset($entity[\'slug\']);");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("break;");
                _builder.newLine();
              }
            }
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("break;");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// return response");
    _builder.newLine();
    _builder.append("$result = [\'isDuplicate\' => $result];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("return new AjaxResponse($result);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence prepareDuplicateCheckParameters(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$postData = $request->request;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$objectType = $postData->getAlnum(\'ot\', \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService);
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$contextArgs = [\'controller\' => \'ajax\', \'action\' => \'checkForDuplicate\'];");
    _builder.newLine();
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerAction\', $contextArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$fieldName = $postData->getAlnum(\'fn\', \'\');");
    _builder.newLine();
    _builder.append("$value = $postData->get(\'v\', \'\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (empty($fieldName) || empty($value)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new BadDataResponse($this->__(\'Error: invalid input.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// check if the given field is existing and unique");
    _builder.newLine();
    _builder.append("$uniqueFields = [];");
    _builder.newLine();
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("    ");
        final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
          boolean _isPrimaryKey = it_1.isPrimaryKey();
          return Boolean.valueOf((!_isPrimaryKey));
        };
        final Iterable<DerivedField> uniqueFields = IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(entity), _function);
        _builder.newLineIfNotEmpty();
        {
          if (((!IterableExtensions.isEmpty(uniqueFields)) || (this._modelBehaviourExtensions.hasSluggableFields(entity) && entity.isSlugUnique()))) {
            _builder.append("    ");
            _builder.append("case \'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode_1, "    ");
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("$uniqueFields = [");
            {
              boolean _hasElements = false;
              for(final DerivedField uniqueField : uniqueFields) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate(", ", "            ");
                }
                _builder.append("\'");
                String _formatForCode_2 = this._formattingExtensions.formatForCode(uniqueField.getName());
                _builder.append(_formatForCode_2, "            ");
                _builder.append("\'");
              }
            }
            {
              if ((this._modelBehaviourExtensions.hasSluggableFields(entity) && entity.isSlugUnique())) {
                {
                  boolean _isEmpty = IterableExtensions.isEmpty(uniqueFields);
                  boolean _not = (!_isEmpty);
                  if (_not) {
                    _builder.append(", ");
                  }
                }
                _builder.append("\'slug\'");
              }
            }
            _builder.append("];");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("break;");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.append("if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new BadDataResponse($this->__(\'Error: invalid input.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$exclude = $postData->get(\'ex\', \'\');");
    _builder.newLine();
    {
      final Function1<DataObject, Boolean> _function_1 = (DataObject it_1) -> {
        return Boolean.valueOf(this._modelExtensions.hasCompositeKeys(it_1));
      };
      boolean _isEmpty_1 = IterableExtensions.isEmpty(IterableExtensions.<DataObject>filter(it.getEntities(), _function_1));
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.append("if (false !== strpos($exclude, \'_\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$exclude = explode(\'_\', $exclude);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence toggleFlagBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _ggleFlagDocBlock = this.toggleFlagDocBlock(it, Boolean.valueOf(true));
    _builder.append(_ggleFlagDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _ggleFlagSignature = this.toggleFlagSignature(it);
    _builder.append(_ggleFlagSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _ggleFlagBaseImpl = this.toggleFlagBaseImpl(it);
    _builder.append(_ggleFlagBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence toggleFlagDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Changes a given flag (boolean field) by switching between true and false.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/toggleFlag\", options={\"expose\"=true})");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Method(\"POST\")");
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
    _builder.append("* @return AjaxResponse");
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
  
  private CharSequence toggleFlagSignature(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function toggleFlagAction(Request $request)");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence toggleFlagBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("::Ajax\', \'::\', ACCESS_EDIT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$postData = $request->request;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$objectType = $postData->getAlnum(\'ot\', \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$field = $postData->getAlnum(\'field\', \'\');");
    _builder.newLine();
    _builder.append("$id = $postData->getInt(\'id\', 0);");
    _builder.newLine();
    _builder.newLine();
    final Iterable<DataObject> entities = this._modelExtensions.getEntitiesWithAjaxToggle(it);
    _builder.newLineIfNotEmpty();
    _builder.append("if ($id == 0");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("|| (");
    {
      boolean _hasElements = false;
      for(final DataObject entity : entities) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" && ", "    ");
        }
        _builder.append("$objectType != \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\'");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    {
      for(final DataObject entity_1 : entities) {
        _builder.append("|| ($objectType == \'");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(entity_1.getName());
        _builder.append(_formatForCode_2);
        _builder.append("\' && !in_array($field, [");
        {
          Iterable<BooleanField> _booleansWithAjaxToggleEntity = this._modelExtensions.getBooleansWithAjaxToggleEntity(entity_1, "");
          boolean _hasElements_1 = false;
          for(final BooleanField field : _booleansWithAjaxToggleEntity) {
            if (!_hasElements_1) {
              _hasElements_1 = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            _builder.append("\'");
            String _formatForCode_3 = this._formattingExtensions.formatForCode(field.getName());
            _builder.append(_formatForCode_3);
            _builder.append("\'");
          }
        }
        _builder.append("]))");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(") {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new BadDataResponse($this->__(\'Error: invalid input.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// select data from data source");
    _builder.newLine();
    _builder.append("$entityFactory = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService);
    _builder.append(".entity_factory\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$repository = $entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.append("$entity = $repository->selectById($id, false);");
    _builder.newLine();
    _builder.append("if (null === $entity) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new NotFoundResponse($this->__(\'No such item.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// toggle the flag");
    _builder.newLine();
    _builder.append("$entity[$field] = !$entity[$field];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// save entity back to database");
    _builder.newLine();
    _builder.append("$entityFactory->getObjectManager()->flush();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$logger = $this->get(\'logger\');");
    _builder.newLine();
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append("\', \'user\' => $this->get(\'zikula_users_module.current_user\')->get(\'uname\'), \'field\' => $field, \'entity\' => $objectType, \'id\' => $id];");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger->notice(\'{app}: User {user} toggled the {field} flag the {entity} with id {id}.\', $logArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// return response");
    _builder.newLine();
    _builder.append("return new AjaxResponse([");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'id\' => $id,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'state\' => $entity[$field],");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'message\' => $this->__(\'The setting has been successfully changed.\')");
    _builder.newLine();
    _builder.append("]);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleTreeOperationBase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _handleTreeOperationDocBlock = this.handleTreeOperationDocBlock(it, Boolean.valueOf(true));
    _builder.append(_handleTreeOperationDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _handleTreeOperationSignature = this.handleTreeOperationSignature(it);
    _builder.append(_handleTreeOperationSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _handleTreeOperationBaseImpl = this.handleTreeOperationBaseImpl(it);
    _builder.append(_handleTreeOperationBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleTreeOperationDocBlock(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Performs different operations on tree hierarchies.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/handleTreeOperation\", options={\"expose\"=true})");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Method(\"POST\")");
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
    _builder.append("* @return AjaxResponse");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws AccessDeniedException Thrown if the user doesn\'t have required permissions");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws FatalResponse");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if tree verification or executing the workflow action fails");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleTreeOperationSignature(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("public function handleTreeOperationAction(Request $request)");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleTreeOperationBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("::Ajax\', \'::\', ACCESS_EDIT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$postData = $request->request;");
    _builder.newLine();
    _builder.newLine();
    final Iterable<Entity> treeEntities = this._modelBehaviourExtensions.getTreeEntities(it);
    _builder.newLineIfNotEmpty();
    _builder.append("// parameter specifying which type of objects we are treating");
    _builder.newLine();
    _builder.append("$objectType = $postData->getAlnum(\'ot\', \'");
    String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<Entity>head(treeEntities).getName());
    _builder.append(_formatForCode);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("// ensure that we use only object types with tree extension enabled");
    _builder.newLine();
    _builder.append("if (!in_array($objectType, [");
    {
      boolean _hasElements = false;
      for(final Entity treeEntity : treeEntities) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "");
        }
        _builder.append("\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(treeEntity.getName());
        _builder.append(_formatForCode_1);
        _builder.append("\'");
      }
    }
    _builder.append("])) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$objectType = \'");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(IterableExtensions.<Entity>head(treeEntities).getName());
    _builder.append(_formatForCode_2, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    CharSequence _prepareTreeOperationParameters = this.prepareTreeOperationParameters(it);
    _builder.append(_prepareTreeOperationParameters);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("$returnValue = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'data\'    => [],");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'result\'  => \'success\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'message\' => \'\'");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$createMethod = \'create\' . ucfirst($objectType);");
    _builder.newLine();
    _builder.append("$repository = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService);
    _builder.append(".entity_factory\')->getRepository($objectType);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("$rootId = 1;");
    _builder.newLine();
    _builder.append("if (!in_array($op, [\'addRootNode\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$rootId = $postData->getInt(\'root\', 0);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$rootId) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'Error: invalid root node.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
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
    _builder.append("$repository->setRequest($request);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// recover any broken tree nodes");
    _builder.newLine();
    _builder.append("$entityManager = $entityFactory->getObjectManager();");
    _builder.newLine();
    _builder.append("$repository->recover();");
    _builder.newLine();
    _builder.append("// flush recovered nodes");
    _builder.newLine();
    _builder.append("$entityManager->flush();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// verify tree state");
    _builder.newLine();
    _builder.append("$verificationResult = $repository->verify();");
    _builder.newLine();
    _builder.append("if (is_array($verificationResult)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$errorMessages = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($verificationResult as $errorMsg) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$errorMessages[] = $errorMsg;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = implode(\'<br />\', $errorMessages);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("$entityManager->clear(); // clear cached nodes");
    _builder.newLine();
    _builder.newLine();
    CharSequence _treeOperationDetermineEntityFields = this.treeOperationDetermineEntityFields(it);
    _builder.append(_treeOperationDetermineEntityFields);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _treeOperationSwitch = this.treeOperationSwitch(it);
    _builder.append(_treeOperationSwitch);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("$returnValue[\'message\'] = $this->__(\'The operation was successful.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// Renew tree");
    _builder.newLine();
    _builder.append("/** postponed, for now we do a page reload");
    _builder.newLine();
    _builder.append("$returnValue[\'data\'] = $repository->selectTree($rootId);");
    _builder.newLine();
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence prepareTreeOperationParameters(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$op = $postData->getAlpha(\'op\', \'\');");
    _builder.newLine();
    _builder.append("if (!in_array($op, [\'addRootNode\', \'addChildNode\', \'deleteNode\', \'moveNode\', \'moveNodeTo\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'Error: invalid operation.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// Get id of treated node");
    _builder.newLine();
    _builder.append("$id = 0;");
    _builder.newLine();
    _builder.append("if (!in_array($op, [\'addRootNode\', \'addChildNode\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$id = $postData->getInt(\'id\', 0);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$id) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'Error: invalid node.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeOperationDetermineEntityFields(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$titleFieldName = $descriptionFieldName = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      Iterable<Entity> _treeEntities = this._modelBehaviourExtensions.getTreeEntities(it);
      for(final Entity entity : _treeEntities) {
        _builder.append("    ");
        _builder.append("case \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        final Function1<StringField, Boolean> _function = (StringField it_1) -> {
          return Boolean.valueOf(((((((it_1.getLength() >= 20) && (!it_1.isNospace())) && (!it_1.isCountry())) && (!it_1.isHtmlcolour())) && (!it_1.isLanguage())) && (!it_1.isLocale())));
        };
        final Iterable<StringField> stringFields = IterableExtensions.<StringField>filter(Iterables.<StringField>filter(entity.getFields(), StringField.class), _function);
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$titleFieldName = \'");
        {
          boolean _isEmpty = IterableExtensions.isEmpty(stringFields);
          boolean _not = (!_isEmpty);
          if (_not) {
            String _formatForCode_1 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(stringFields).getName());
            _builder.append(_formatForCode_1, "            ");
          }
        }
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        final Function1<TextField, Boolean> _function_1 = (TextField it_1) -> {
          return Boolean.valueOf((it_1.isMandatory() && (it_1.getLength() >= 50)));
        };
        final Iterable<TextField> textFields = IterableExtensions.<TextField>filter(Iterables.<TextField>filter(entity.getFields(), TextField.class), _function_1);
        _builder.newLineIfNotEmpty();
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(textFields);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("$descriptionFieldName = \'");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(IterableExtensions.<TextField>head(textFields).getName());
            _builder.append(_formatForCode_2, "            ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("        ");
            final Function1<StringField, Boolean> _function_2 = (StringField it_1) -> {
              return Boolean.valueOf(((((((it_1.isMandatory() && (it_1.getLength() >= 50)) && (!it_1.isNospace())) && (!it_1.isCountry())) && (!it_1.isHtmlcolour())) && (!it_1.isLanguage())) && (!it_1.isLocale())));
            };
            final Iterable<StringField> textStringFields = IterableExtensions.<StringField>filter(Iterables.<StringField>filter(entity.getFields(), StringField.class), _function_2);
            _builder.newLineIfNotEmpty();
            {
              int _length = ((Object[])Conversions.unwrapArray(textStringFields, Object.class)).length;
              boolean _greaterThan = (_length > 1);
              if (_greaterThan) {
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$descriptionFieldName = \'");
                String _formatForCode_3 = this._formattingExtensions.formatForCode(((StringField[])Conversions.unwrapArray(textStringFields, StringField.class))[1].getName());
                _builder.append(_formatForCode_3, "            ");
                _builder.append("\';");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeOperationSwitch(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$currentUserApi = $this->get(\'zikula_users_module.current_user\');");
    _builder.newLine();
    _builder.append("$logger = $this->get(\'logger\');");
    _builder.newLine();
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("\', \'user\' => $currentUserApi->get(\'uname\'), \'entity\' => $objectType];");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
      if (_hasStandardFieldEntities) {
        _builder.newLine();
        _builder.append("$currentUserId = $currentUserApi->isLoggedIn() ? $currentUserApi->get(\'uid\') : 1;");
        _builder.newLine();
        _builder.append("$currentUser = $this->get(\'zikula_users_module.user_repository\')->find($currentUserId);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("switch ($op) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("case \'addRootNode\':");
    _builder.newLine();
    _builder.append("                    ");
    CharSequence _treeOperationAddRootNode = this.treeOperationAddRootNode(it);
    _builder.append(_treeOperationAddRootNode, "                    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$logger->notice(\'{app}: User {user} added a new root node in the {entity} tree.\', $logArgs);");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("case \'addChildNode\':");
    _builder.newLine();
    _builder.append("                    ");
    CharSequence _treeOperationAddChildNode = this.treeOperationAddChildNode(it);
    _builder.append(_treeOperationAddChildNode, "                    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$logger->notice(\'{app}: User {user} added a new child node in the {entity} tree.\', $logArgs);");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("case \'deleteNode\':");
    _builder.newLine();
    _builder.append("                    ");
    CharSequence _treeOperationDeleteNode = this.treeOperationDeleteNode(it);
    _builder.append(_treeOperationDeleteNode, "                    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$logger->notice(\'{app}: User {user} deleted a node from the {entity} tree.\', $logArgs);");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("case \'moveNode\':");
    _builder.newLine();
    _builder.append("                    ");
    CharSequence _treeOperationMoveNode = this.treeOperationMoveNode(it);
    _builder.append(_treeOperationMoveNode, "                    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$logger->notice(\'{app}: User {user} moved a node in the {entity} tree.\', $logArgs);");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("case \'moveNodeTo\':");
    _builder.newLine();
    _builder.append("                    ");
    CharSequence _treeOperationMoveNodeTo = this.treeOperationMoveNodeTo(it);
    _builder.append(_treeOperationMoveNodeTo, "                    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$logger->notice(\'{app}: User {user} moved a node in the {entity} tree.\', $logArgs);");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeOperationAddRootNode(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("//$entityManager->transactional(function($entityManager) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService, "    ");
    _builder.append(".entity_factory\')->$createMethod();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!empty($titleFieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity[$titleFieldName] = $this->__(\'New root node\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($descriptionFieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity[$descriptionFieldName] = $this->__(\'This is a new root node\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
      if (_hasStandardFieldEntities) {
        _builder.append("    ");
        _builder.append("if (method_exists($entity, \'setCreatedBy\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entity->setCreatedBy($currentUser);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entity->setUpdatedBy($currentUser);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// save new object to set the root id");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$action = \'submit\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$workflowHelper = $this->get(\'");
    String _appService_1 = this._utils.appService(it);
    _builder.append(_appService_1, "        ");
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$success) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'message\'] = $this->__f(\'Sorry, but an error occured during the %action% action. Please apply the changes again!\', [\'%action%\' => $action]) . \'  \' . $e->getMessage();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("//});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeOperationAddChildNode(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$parentId = $postData->getInt(\'pid\', 0);");
    _builder.newLine();
    _builder.append("if (!$parentId) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'Error: invalid parent node.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("//$entityManager->transactional(function($entityManager) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$childEntity = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService, "    ");
    _builder.append(".entity_factory\')->$createMethod();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$childEntity[$titleFieldName] = $this->__(\'New child node\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($descriptionFieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$childEntity[$descriptionFieldName] = $this->__(\'This is a new child node\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
      if (_hasStandardFieldEntities) {
        _builder.append("    ");
        _builder.append("if (method_exists($childEntity, \'setCreatedBy\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$childEntity->setCreatedBy($currentUser);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$childEntity->setUpdatedBy($currentUser);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$parentEntity = $repository->selectById($parentId, false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $parentEntity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'No such item.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$childEntity->setParent($parentEntity);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// save new object");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$action = \'submit\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$workflowHelper = $this->get(\'");
    String _appService_1 = this._utils.appService(it);
    _builder.append(_appService_1, "        ");
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$success = $workflowHelper->executeAction($childEntity, $action);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$success) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    {
      boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
      if (_hasEditActions) {
        _builder.append("            ");
        _builder.append("if (in_array($objectType, [\'");
        final Function1<Entity, Boolean> _function = (Entity it_1) -> {
          return Boolean.valueOf(((!Objects.equal(it_1.getTree(), EntityTreeType.NONE)) && this._controllerExtensions.hasEditAction(it_1)));
        };
        final Function1<Entity, String> _function_1 = (Entity it_1) -> {
          return this._formattingExtensions.formatForCode(it_1.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<Entity, String>map(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function), _function_1), "\', \'");
        _builder.append(_join, "            ");
        _builder.append("\'])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$returnValue[\'returnUrl\'] = $this->get(\'router\')->generate(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB, "                ");
        _builder.append("_\' . strtolower($objectType) . \'_edit\', $childEntity->createUrlArgs(), UrlGeneratorInterface::ABSOLUTE_URL);");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'message\'] = $this->__f(\'Sorry, but an error occured during the %action% action. Please apply the changes again!\', [\'%action%\' => $action]) . \'  \' . $e->getMessage();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("//});");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeOperationDeleteNode(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// remove node from tree and reparent all children");
    _builder.newLine();
    _builder.append("$entity = $repository->selectById($id, false);");
    _builder.newLine();
    _builder.append("if (null === $entity) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'No such item.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
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
    _builder.append("// delete the object");
    _builder.newLine();
    _builder.append("$action = \'delete\';");
    _builder.newLine();
    _builder.append("try {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService, "    ");
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$success) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__f(\'Sorry, but an error occured during the %action% action. Please apply the changes again!\', [\'%action%\' => $action]) . \'  \' . $e->getMessage();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$repository->removeFromTree($entity);");
    _builder.newLine();
    _builder.append("$entityManager->clear(); // clear cached nodes");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeOperationMoveNode(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$moveDirection = $postData->getAlpha(\'direction\', \'\');");
    _builder.newLine();
    _builder.append("if (!in_array($moveDirection, [\'top\', \'up\', \'down\', \'bottom\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'Error: invalid direction.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entity = $repository->selectById($id, false);");
    _builder.newLine();
    _builder.append("if (null === $entity) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'No such item.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if ($moveDirection == \'top\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->moveUp($entity, true);");
    _builder.newLine();
    _builder.append("} elseif ($moveDirection == \'up\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->moveUp($entity, 1);");
    _builder.newLine();
    _builder.append("} elseif ($moveDirection == \'down\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->moveDown($entity, 1);");
    _builder.newLine();
    _builder.append("} elseif ($moveDirection == \'bottom\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->moveDown($entity, true);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("$entityManager->flush();");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeOperationMoveNodeTo(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$moveDirection = $postData->getAlpha(\'direction\', \'\');");
    _builder.newLine();
    _builder.append("if (!in_array($moveDirection, [\'after\', \'before\', \'bottom\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'Error: invalid direction.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$destId = $postData->getInt(\'destid\', 0);");
    _builder.newLine();
    _builder.append("if (!$destId) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'Error: invalid destination node.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entityManager->clear();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("//$entityManager->transactional(function($entityManager) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $repository->selectById($id, false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$destEntity = $repository->selectById($destId, false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $entity || null === $destEntity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'result\'] = \'failure\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'No such item.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new AjaxResponse($returnValue);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager->persist($destEntity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager->persist($currentUser);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($moveDirection == \'after\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$repository->persistAsNextSiblingOf($entity, $destEntity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($moveDirection == \'before\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$repository->persistAsPrevSiblingOf($entity, $destEntity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($moveDirection == \'bottom\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$repository->persistAsLastChildOf($entity, $destEntity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager->flush();");
    _builder.newLine();
    _builder.append("//});");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence additionalAjaxFunctions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _userSelectorsImpl = this.userSelectorsImpl(it);
    _builder.append(_userSelectorsImpl);
    _builder.newLineIfNotEmpty();
    {
      boolean _generateExternalControllerAndFinder = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
      if (_generateExternalControllerAndFinder) {
        _builder.newLine();
        CharSequence _itemListFinderImpl = this.getItemListFinderImpl(it);
        _builder.append(_itemListFinderImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(it);
      if (_needsAutoCompletion) {
        _builder.newLine();
        CharSequence _itemListAutoCompletionImpl = this.getItemListAutoCompletionImpl(it);
        _builder.append(_itemListAutoCompletionImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsDuplicateCheck = this.needsDuplicateCheck(it);
      if (_needsDuplicateCheck) {
        _builder.newLine();
        CharSequence _checkForDuplicateImpl = this.checkForDuplicateImpl(it);
        _builder.append(_checkForDuplicateImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasBooleansWithAjaxToggle = this._modelExtensions.hasBooleansWithAjaxToggle(it);
      if (_hasBooleansWithAjaxToggle) {
        _builder.newLine();
        CharSequence _ggleFlagImpl = this.toggleFlagImpl(it);
        _builder.append(_ggleFlagImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.newLine();
        CharSequence _handleTreeOperationImpl = this.handleTreeOperationImpl(it);
        _builder.append(_handleTreeOperationImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence userSelectorsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<UserField> userFields = this._modelExtensions.getAllUserFields(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(userFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          for(final UserField userField : userFields) {
            _builder.newLine();
            _builder.append("/**");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("* Retrieves a list of users.");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("*");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("* @Route(\"/get");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(userField.getEntity().getName());
            _builder.append(_formatForCodeCapital, " ");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(userField.getName());
            _builder.append(_formatForCodeCapital_1, " ");
            _builder.append("Users\", options={\"expose\"=true})");
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append("* @Method(\"GET\")");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("*/");
            _builder.newLine();
            _builder.append("public function get");
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(userField.getEntity().getName());
            _builder.append(_formatForCodeCapital_2);
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(userField.getName());
            _builder.append(_formatForCodeCapital_3);
            _builder.append("UsersAction(Request $request)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return parent::get");
            String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(userField.getEntity().getName());
            _builder.append(_formatForCodeCapital_4, "    ");
            String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(userField.getName());
            _builder.append(_formatForCodeCapital_5, "    ");
            _builder.append("UsersAction($request);");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _needsUserAutoCompletion = this._modelBehaviourExtensions.needsUserAutoCompletion(it);
      if (_needsUserAutoCompletion) {
        _builder.newLine();
        CharSequence _commonUsersListImpl = this.getCommonUsersListImpl(it);
        _builder.append(_commonUsersListImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence getCommonUsersListImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _commonUsersListDocBlock = this.getCommonUsersListDocBlock(it, Boolean.valueOf(false));
    _builder.append(_commonUsersListDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _commonUsersListSignature = this.getCommonUsersListSignature(it);
    _builder.append(_commonUsersListSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::getCommonUsersListAction($request);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListFinderImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _itemListFinderDocBlock = this.getItemListFinderDocBlock(it, Boolean.valueOf(false));
    _builder.append(_itemListFinderDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _itemListFinderSignature = this.getItemListFinderSignature(it);
    _builder.append(_itemListFinderSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::getItemListFinderAction($request);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListAutoCompletionImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _itemListAutoCompletionDocBlock = this.getItemListAutoCompletionDocBlock(it, Boolean.valueOf(false));
    _builder.append(_itemListAutoCompletionDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _itemListAutoCompletionSignature = this.getItemListAutoCompletionSignature(it);
    _builder.append(_itemListAutoCompletionSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::getItemListAutoCompletionAction($request);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence checkForDuplicateImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _checkForDuplicateDocBlock = this.checkForDuplicateDocBlock(it, Boolean.valueOf(false));
    _builder.append(_checkForDuplicateDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _checkForDuplicateSignature = this.checkForDuplicateSignature(it);
    _builder.append(_checkForDuplicateSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::checkForDuplicateAction($request);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence toggleFlagImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _ggleFlagDocBlock = this.toggleFlagDocBlock(it, Boolean.valueOf(false));
    _builder.append(_ggleFlagDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _ggleFlagSignature = this.toggleFlagSignature(it);
    _builder.append(_ggleFlagSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::toggleFlagAction($request);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleTreeOperationImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _handleTreeOperationDocBlock = this.handleTreeOperationDocBlock(it, Boolean.valueOf(false));
    _builder.append(_handleTreeOperationDocBlock);
    _builder.newLineIfNotEmpty();
    CharSequence _handleTreeOperationSignature = this.handleTreeOperationSignature(it);
    _builder.append(_handleTreeOperationSignature);
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::handleTreeOperationAction($request);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence ajaxControllerImpl(final Application it) {
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
    _builder.append("\\Controller\\Base\\AbstractAjaxController;");
    _builder.newLineIfNotEmpty();
    _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\Method;");
    _builder.newLine();
    _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\Route;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\JsonResponse;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    {
      if (((this.needsDuplicateCheck(it) || this._modelExtensions.hasBooleansWithAjaxToggle(it)) || this._modelBehaviourExtensions.hasTrees(it))) {
        _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.append("use RuntimeException;");
        _builder.newLine();
      }
    }
    {
      if ((((this._generatorSettingsExtensions.generateExternalControllerAndFinder(it) || this.needsDuplicateCheck(it)) || this._modelExtensions.hasBooleansWithAjaxToggle(it)) || this._modelBehaviourExtensions.hasTrees(it))) {
        _builder.append("use Zikula\\Core\\Response\\Ajax\\AjaxResponse;");
        _builder.newLine();
      }
    }
    {
      if ((this.needsDuplicateCheck(it) || this._modelExtensions.hasBooleansWithAjaxToggle(it))) {
        _builder.append("use Zikula\\Core\\Response\\Ajax\\BadDataResponse;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_1) {
        _builder.append("use Zikula\\Core\\Response\\Ajax\\FatalResponse;");
        _builder.newLine();
      }
    }
    {
      boolean _hasBooleansWithAjaxToggle = this._modelExtensions.hasBooleansWithAjaxToggle(it);
      if (_hasBooleansWithAjaxToggle) {
        _builder.append("use Zikula\\Core\\Response\\Ajax\\NotFoundResponse;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Ajax controller implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Route(\"/ajax\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class AjaxController extends AbstractAjaxController");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _additionalAjaxFunctions = this.additionalAjaxFunctions(it);
    _builder.append(_additionalAjaxFunctions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own ajax controller methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private boolean needsDuplicateCheck(final Application it) {
    return (IterableExtensions.<DataObject>exists(it.getEntities(), ((Function1<DataObject, Boolean>) (DataObject it_1) -> {
      final Function1<DerivedField, Boolean> _function = (DerivedField it_2) -> {
        boolean _isPrimaryKey = it_2.isPrimaryKey();
        return Boolean.valueOf((!_isPrimaryKey));
      };
      int _size = IterableExtensions.size(IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(it_1), _function));
      return Boolean.valueOf((_size > 0));
    })) || (this._modelBehaviourExtensions.hasSluggable(it) && (!IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), ((Function1<Entity, Boolean>) (Entity it_1) -> {
      return Boolean.valueOf((this._modelBehaviourExtensions.hasSluggableFields(it_1) && it_1.isSlugUnique()));
    }))))));
  }
}
