package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ControllerHelper {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for controller layer");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/ControllerHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.controllerFunctionsBaseImpl(it)), fh.phpFileContent(it, this.controllerFunctionsImpl(it)));
  }
  
  private CharSequence controllerFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((this._modelExtensions.hasUploads(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("use Psr\\Log\\LoggerInterface;");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("use Symfony\\Component\\Filesystem\\Exception\\IOExceptionInterface;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\Filesystem\\Filesystem;");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewActions = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions) {
        _builder.append("use Symfony\\Component\\Form\\FormFactoryInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\RequestStack;");
    _builder.newLine();
    {
      boolean _hasUploads_1 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_1) {
        _builder.append("use Symfony\\Component\\HttpFoundation\\Session\\SessionInterface;");
        _builder.newLine();
        _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
        _builder.newLine();
        _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewActions_1 = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions_1) {
        _builder.append("use Zikula\\Component\\SortableColumns\\SortableColumns;");
        _builder.newLine();
      }
    }
    {
      if (((this._controllerExtensions.hasViewActions(it) || this._controllerExtensions.hasDisplayActions(it)) && this._modelExtensions.hasHookSubscribers(it))) {
        _builder.append("use Zikula\\Core\\RouteUrl;");
        _builder.newLine();
      }
    }
    {
      if ((this._controllerExtensions.hasViewActions(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
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
    {
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        _builder.append("use Zikula\\UsersModule\\Api\\");
        {
          Boolean _targets_1 = this._utils.targets(it, "1.5");
          if ((_targets_1).booleanValue()) {
            _builder.append("ApiInterface\\CurrentUserApiInterface");
          } else {
            _builder.append("CurrentUserApi");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((this._controllerExtensions.hasViewActions(it) && this._modelExtensions.hasUserFields(it))) {
        _builder.append("use Zikula\\UsersModule\\Entity\\UserEntity;");
        _builder.newLine();
      }
    }
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Factory;");
    _builder.newLineIfNotEmpty();
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasUploads_2 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_2) {
        _builder.append("use ");
        String _appNamespace_3 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_3);
        _builder.append("\\Helper\\ImageHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((this._controllerExtensions.hasViewActions(it) && this._controllerExtensions.hasEditActions(it))) {
        _builder.append("use ");
        String _appNamespace_4 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_4);
        _builder.append("\\Helper\\ModelHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for controller layer methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractControllerHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasUploads_3 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_3) {
        _builder.append("    ");
        _builder.append("use TranslatorTrait;");
        _builder.newLine();
        _builder.newLine();
      }
    }
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
    {
      boolean _hasUploads_4 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_4) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var SessionInterface");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $session;");
        _builder.newLine();
      }
    }
    {
      if ((this._modelExtensions.hasUploads(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var LoggerInterface");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $logger;");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewActions_2 = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions_2) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var FormFactoryInterface");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $formFactory;");
        _builder.newLine();
      }
    }
    {
      if ((this._controllerExtensions.hasViewActions(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var VariableApi");
        {
          Boolean _targets_2 = this._utils.targets(it, "1.5");
          if ((_targets_2).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $variableApi;");
        _builder.newLine();
      }
    }
    {
      boolean _hasGeographical_1 = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var CurrentUserApi");
        {
          Boolean _targets_3 = this._utils.targets(it, "1.5");
          if ((_targets_3).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $currentUserApi;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "     ");
    _builder.append("Factory");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $entityFactory;");
    _builder.newLine();
    {
      if ((this._controllerExtensions.hasViewActions(it) && this._controllerExtensions.hasEditActions(it))) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var ModelHelper");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $modelHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads_5 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_5) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var ImageHelper");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $imageHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _needsFeatureActivationHelper_1 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var FeatureActivationHelper");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $featureActivationHelper;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ControllerHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    {
      boolean _hasUploads_6 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_6) {
        _builder.append("     ");
        _builder.append("* @param TranslatorInterface $translator      Translator service instance");
        _builder.newLine();
      }
    }
    _builder.append("     ");
    _builder.append("* @param RequestStack        $requestStack    RequestStack service instance");
    _builder.newLine();
    {
      boolean _hasUploads_7 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_7) {
        _builder.append("     ");
        _builder.append("* @param SessionInterface    $session         Session service instance");
        _builder.newLine();
      }
    }
    {
      if ((this._modelExtensions.hasUploads(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("     ");
        _builder.append("* @param LoggerInterface     $logger          Logger service instance");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewActions_3 = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions_3) {
        _builder.append("     ");
        _builder.append("* @param FormFactoryInterface $formFactory    FormFactory service instance");
        _builder.newLine();
      }
    }
    {
      if ((this._controllerExtensions.hasViewActions(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("     ");
        _builder.append("* @param VariableApi");
        {
          Boolean _targets_4 = this._utils.targets(it, "1.5");
          if ((_targets_4).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("        ");
          }
        }
        _builder.append(" $variableApi     VariableApi service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasGeographical_2 = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical_2) {
        _builder.append("     ");
        _builder.append("* @param CurrentUserApi");
        {
          Boolean _targets_5 = this._utils.targets(it, "1.5");
          if ((_targets_5).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("     ");
          }
        }
        _builder.append(" $currentUserApi  CurrentUserApi service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("     ");
    _builder.append("* @param ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "     ");
    _builder.append("Factory $entityFactory ");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3, "     ");
    _builder.append("Factory service instance");
    _builder.newLineIfNotEmpty();
    {
      if ((this._controllerExtensions.hasViewActions(it) && this._controllerExtensions.hasEditActions(it))) {
        _builder.append("     ");
        _builder.append("* @param ModelHelper         $modelHelper     ModelHelper service instance");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads_8 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_8) {
        _builder.append("     ");
        _builder.append("* @param ImageHelper         $imageHelper     ImageHelper service instance");
        _builder.newLine();
      }
    }
    {
      boolean _needsFeatureActivationHelper_2 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper_2) {
        _builder.append("     ");
        _builder.append("* @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance");
        _builder.newLine();
      }
    }
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(");
    _builder.newLine();
    {
      boolean _hasUploads_9 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_9) {
        _builder.append("        ");
        _builder.append("TranslatorInterface $translator,");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("RequestStack $requestStack,");
    _builder.newLine();
    {
      boolean _hasUploads_10 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_10) {
        _builder.append("        ");
        _builder.append("SessionInterface $session,");
        _builder.newLine();
      }
    }
    {
      if ((this._modelExtensions.hasUploads(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("        ");
        _builder.append("LoggerInterface $logger,");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewActions_4 = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions_4) {
        _builder.append("        ");
        _builder.append("FormFactoryInterface $formFactory,");
        _builder.newLine();
      }
    }
    {
      if ((this._controllerExtensions.hasViewActions(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("        ");
        _builder.append("VariableApi");
        {
          Boolean _targets_6 = this._utils.targets(it, "1.5");
          if ((_targets_6).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append(" $variableApi,");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasGeographical_3 = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical_3) {
        _builder.append("        ");
        _builder.append("CurrentUserApi");
        {
          Boolean _targets_7 = this._utils.targets(it, "1.5");
          if ((_targets_7).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append(" $currentUserApi,");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4, "        ");
    _builder.append("Factory $entityFactory");
    {
      if ((this._controllerExtensions.hasViewActions(it) && this._controllerExtensions.hasEditActions(it))) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("ModelHelper $modelHelper");
      }
    }
    {
      boolean _hasUploads_11 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_11) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("ImageHelper $imageHelper");
      }
    }
    {
      boolean _needsFeatureActivationHelper_3 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper_3) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("FeatureActivationHelper $featureActivationHelper");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    {
      boolean _hasUploads_12 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_12) {
        _builder.append("        ");
        _builder.append("$this->setTranslator($translator);");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->request = $requestStack->getCurrentRequest();");
    _builder.newLine();
    {
      boolean _hasUploads_13 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_13) {
        _builder.append("        ");
        _builder.append("$this->session = $session;");
        _builder.newLine();
      }
    }
    {
      if ((this._modelExtensions.hasUploads(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("        ");
        _builder.append("$this->logger = $logger;");
        _builder.newLine();
      }
    }
    {
      boolean _hasViewActions_5 = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions_5) {
        _builder.append("        ");
        _builder.append("$this->formFactory = $formFactory;");
        _builder.newLine();
      }
    }
    {
      if ((this._controllerExtensions.hasViewActions(it) || this._modelBehaviourExtensions.hasGeographical(it))) {
        _builder.append("        ");
        _builder.append("$this->variableApi = $variableApi;");
        _builder.newLine();
      }
    }
    {
      boolean _hasGeographical_4 = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical_4) {
        _builder.append("        ");
        _builder.append("$this->currentUserApi = $currentUserApi;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->entityFactory = $entityFactory;");
    _builder.newLine();
    {
      if ((this._controllerExtensions.hasViewActions(it) && this._controllerExtensions.hasEditActions(it))) {
        _builder.append("        ");
        _builder.append("$this->modelHelper = $modelHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads_14 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_14) {
        _builder.append("        ");
        _builder.append("$this->imageHelper = $imageHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _needsFeatureActivationHelper_4 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper_4) {
        _builder.append("        ");
        _builder.append("$this->featureActivationHelper = $featureActivationHelper;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasUploads_15 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_15) {
        _builder.append("    ");
        CharSequence _setTranslatorMethod = this._modelBehaviourExtensions.setTranslatorMethod(it);
        _builder.append(_setTranslatorMethod, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _objectTypes = this.getObjectTypes(it);
    _builder.append(_objectTypes, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _defaultObjectType = this.getDefaultObjectType(it);
    _builder.append(_defaultObjectType, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _retrieveIdentifier = this.retrieveIdentifier(it);
    _builder.append(_retrieveIdentifier, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _isValidIdentifier = this.isValidIdentifier(it);
    _builder.append(_isValidIdentifier, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _formatPermalink = this.formatPermalink(it);
    _builder.append(_formatPermalink, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasViewActions_6 = this._controllerExtensions.hasViewActions(it);
      if (_hasViewActions_6) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _processViewActionParameters = this.processViewActionParameters(it);
        _builder.append(_processViewActionParameters, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasDisplayActions = this._controllerExtensions.hasDisplayActions(it);
      if (_hasDisplayActions) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _processDisplayActionParameters = this.processDisplayActionParameters(it);
        _builder.append(_processDisplayActionParameters, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
      if (_hasEditActions) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _processEditActionParameters = this.processEditActionParameters(it);
        _builder.append(_processEditActionParameters, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasDeleteActions = this._controllerExtensions.hasDeleteActions(it);
      if (_hasDeleteActions) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _processDeleteActionParameters = this.processDeleteActionParameters(it);
        _builder.append(_processDeleteActionParameters, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasGeographical_5 = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical_5) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _performGeoCoding = this.performGeoCoding(it);
        _builder.append(_performGeoCoding, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getObjectTypes(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns an array of all allowed object types in ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler, block, contentType, util)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args    Additional arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of allowed object types");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getObjectTypes($context = \'\', $args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, [\'controllerAction\', \'api\', \'helper\', \'actionHandler\', \'block\', \'contentType\', \'util\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedObjectTypes = [];");
    _builder.newLine();
    {
      EList<DataObject> _entities = it.getEntities();
      for(final DataObject entity : _entities) {
        _builder.append("    ");
        _builder.append("$allowedObjectTypes[] = \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $allowedObjectTypes;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getDefaultObjectType(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the default object type in ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler, block, contentType, util)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args    Additional arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The name of the default object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getDefaultObjectType($context = \'\', $args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, [\'controllerAction\', \'api\', \'helper\', \'actionHandler\', \'block\', \'contentType\', \'util\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$defaultObjectType = \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $defaultObjectType;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence retrieveIdentifier(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieve identifier parameters for a given object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Request $request    The current request");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $args       List of arguments used as fallback if request does not contain a field");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType Name of treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of fetched identifiers");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function retrieveIdentifier(Request $request, array $args, $objectType = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idFields = $this->entityFactory->getIdFields($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idValues = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routeParams = $request->get(\'_route_params\', []);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$defaultValue = isset($args[$idField]) && is_numeric($args[$idField]) ? $args[$idField] : 0;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->entityFactory->hasCompositeKeys($objectType)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// composite key may be alphanumeric");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (array_key_exists($idField, $routeParams)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = !empty($routeParams[$idField]) ? $routeParams[$idField] : $defaultValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} elseif ($request->query->has($idField)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = $request->query->getAlnum($idField, $defaultValue);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = $defaultValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// single identifier");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (array_key_exists($idField, $routeParams)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = (int) !empty($routeParams[$idField]) ? $routeParams[$idField] : $defaultValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} elseif ($request->query->has($idField)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = $request->query->getInt($idField, $defaultValue);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = $defaultValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// fallback if id has not been found yet");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$id && $idField != \'id\' && count($idFields) == 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$defaultValue = isset($args[\'id\']) && is_numeric($args[\'id\']) ? $args[\'id\'] : 0;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (array_key_exists(\'id\', $routeParams)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = (int) !empty($routeParams[\'id\']) ? $routeParams[\'id\'] : $defaultValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} elseif ($request->query->has(\'id\')) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = (int) $request->query->getInt(\'id\', $defaultValue);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = $defaultValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idValues[$idField] = $id;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $idValues;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence isValidIdentifier(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Checks if all identifiers are set properly.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $idValues List of identifier field values");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean Whether all identifiers are set or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function isValidIdentifier(array $idValues)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!count($idValues)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($idValues as $idField => $idValue) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$idValue) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formatPermalink(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Create nice permalinks.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $name The given object title");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string processed permalink");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @deprecated made obsolete by Doctrine extensions");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function formatPermalink($name)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$name = str_replace(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("[\'ä\', \'ö\', \'ü\', \'Ä\', \'Ö\', \'Ü\', \'ß\', \'.\', \'?\', \'\"\', \'/\', \':\', \'é\', \'è\', \'â\'],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("[\'ae\', \'oe\', \'ue\', \'Ae\', \'Oe\', \'Ue\', \'ss\', \'\', \'\', \'\', \'-\', \'-\', \'e\', \'e\', \'a\'],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$name");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$name = preg_replace(\"#(\\s*\\/\\s*|\\s*\\+\\s*|\\s+)#\", \'-\', strtolower($name));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $name;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processViewActionParameters(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Processes the parameters for a view action.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This includes handling pagination, quick navigation forms and other aspects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string          $objectType         Name of treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param SortableColumns $sortableColumns    Used SortableColumns instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array           $templateParameters Template data");
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.append(" ");
        _builder.append("* @param boolean         $supportsHooks      Whether hooks are supported or not");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Enriched template parameters used for creating the response");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processViewActionParameters($objectType, SortableColumns $sortableColumns, array $templateParameters = []");
    {
      boolean _hasHookSubscribers_1 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_1) {
        _builder.append(", $supportsHooks = false");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$contextArgs = [\'controller\' => $objectType, \'action\' => \'view\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $this->getObjectTypes(\'controllerAction\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new Exception($this->__(\'Error! Invalid object type received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$request = $this->request;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->setRequest($request);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// parameter for used sorting field");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _defaultSorting = new ControllerHelperFunctions().defaultSorting(it);
    _builder.append(_defaultSorting, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (\'tree\' == $request->query->getAlnum(\'tpl\', \'\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$templateParameters[\'trees\'] = $repository->selectAllTrees();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(");
        {
          boolean _hasUploads = this._modelExtensions.hasUploads(it);
          if (_hasUploads) {
            _builder.append("$this->imageHelper, ");
          }
        }
        _builder.append("\'controllerAction\', $contextArgs));");
        _builder.newLineIfNotEmpty();
        {
          boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
          if (_needsFeatureActivationHelper) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$templateParameters[\'featureActivationHelper\'] = $this->featureActivationHelper;");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $templateParameters;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$showOwnEntries = $request->query->getInt(\'own\', $this->variableApi->get(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\', \'showOnlyOwnEntries\', 0));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$showAllEntries = $request->query->getInt(\'all\', 0);");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _generateCsvTemplates = this._generatorSettingsExtensions.generateCsvTemplates(it);
      if (_generateCsvTemplates) {
        _builder.append("    ");
        _builder.append("if (!$showAllEntries && $request->getRequestFormat() == \'csv\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$showAllEntries = 1;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      boolean _hasHookSubscribers_2 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_2) {
        _builder.append("    ");
        _builder.append("if (true === $supportsHooks) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$currentUrlArgs = [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($showAllEntries == 1) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$currentUrlArgs[\'all\'] = 1;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($showOwnEntries == 1) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$currentUrlArgs[\'own\'] = 1;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$resultsPerPage = 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($showAllEntries != 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// the number of items displayed on a page for pagination");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$resultsPerPage = $request->query->getInt(\'num\', 0);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (in_array($resultsPerPage, [0, 10])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$resultsPerPage = $this->variableApi->get(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "            ");
    _builder.append("\', $objectType . \'EntriesPerPage\', 10);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$additionalParameters = $repository->getAdditionalTemplateParameters(");
    {
      boolean _hasUploads_1 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_1) {
        _builder.append("$this->imageHelper, ");
      }
    }
    _builder.append("\'controllerAction\', $contextArgs);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$additionalUrlParameters = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'all\' => $showAllEntries,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'own\' => $showOwnEntries,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'num\' => $resultsPerPage");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($additionalParameters as $parameterName => $parameterValue) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (false !== stripos($parameterName, \'thumbRuntimeOptions\')) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$additionalUrlParameters[$parameterName] = $parameterValue;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'all\'] = $showAllEntries;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'own\'] = $showOwnEntries;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'num\'] = $resultsPerPage;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'tpl\'] = $request->query->getAlnum(\'tpl\', \'\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$quickNavForm = $this->formFactory->create(\'");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace, "    ");
    _builder.append("\\Form\\Type\\QuickNavigation\\\\\' . ucfirst($objectType) . \'QuickNavType\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($quickNavForm->handleRequest($request) && $quickNavForm->isSubmitted()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$quickNavData = $quickNavForm->getData();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($quickNavData as $fieldName => $fieldValue) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($fieldName == \'routeArea\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($fieldName == \'all\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$showAllEntries = $additionalUrlParameters[\'all\'] = $templateParameters[\'all\'] = $fieldValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} elseif ($fieldName == \'own\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$showOwnEntries = $additionalUrlParameters[\'own\'] = $templateParameters[\'own\'] = $fieldValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} elseif ($fieldName == \'num\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$resultsPerPage = $additionalUrlParameters[\'num\'] = $fieldValue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// set filter as query argument, fetched inside repository");
    _builder.newLine();
    {
      boolean _hasUserFields = this._modelExtensions.hasUserFields(it);
      if (_hasUserFields) {
        _builder.append("                ");
        _builder.append("if ($fieldValue instanceof UserEntity) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("    ");
        _builder.append("$fieldValue = $fieldValue->getUid();");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("$request->query->set($fieldName, $fieldValue);");
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
    _builder.append("    ");
    _builder.append("$sort = $request->query->get(\'sort\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortdir = $request->query->get(\'sortdir\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortableColumns->setOrderBy($sortableColumns->getColumn($sort), strtoupper($sortdir));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortableColumns->setAdditionalUrlParameters($additionalUrlParameters);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'sort\'] = $sort;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'sortdir\'] = $sortdir;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($showAllEntries == 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// retrieve item list without pagination");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entities = $repository->selectWhere($where, $sort . \' \' . $sortdir);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// the current offset which is used to calculate the pagination");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$currentPage = $request->query->getInt(\'pos\', 1);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// retrieve item list with pagination");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("list($entities, $objectCount) = $repository->selectWherePaginated($where, $sort . \' \' . $sortdir, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateParameters[\'currentPage\'] = $currentPage;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateParameters[\'pager\'] = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'amountOfItems\' => $objectCount,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'itemsPerPage\' => $resultsPerPage");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasHookSubscribers_3 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_3) {
        _builder.append("    ");
        _builder.append("if (true === $supportsHooks) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// build RouteUrl instance for display hooks");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$currentUrlArgs[\'_locale\'] = $request->getLocale();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$currentUrlObject = new RouteUrl(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB, "        ");
        _builder.append("_\' . $objectType . \'_\' . /*$templateParameters[\'routeArea\'] . */\'view\', $currentUrlArgs);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$templateParameters[\'items\'] = $entities;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'sort\'] = $sort;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'sortdir\'] = $sortdir;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'num\'] = $resultsPerPage;");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_4 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_4) {
        _builder.append("    ");
        _builder.append("if (true === $supportsHooks) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$templateParameters[\'currentUrlObject\'] = $currentUrlObject;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$templateParameters = array_merge($templateParameters, $additionalParameters);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'sort\'] = $sortableColumns->generateSortableColumns();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'quickNavForm\'] = $quickNavForm->createView();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'showAllEntries\'] = $templateParameters[\'all\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'showOwnEntries\'] = $templateParameters[\'own\'];");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper_1 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper_1) {
        _builder.append("    ");
        _builder.append("$templateParameters[\'featureActivationHelper\'] = $this->featureActivationHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
      if (_hasEditActions) {
        _builder.append("    ");
        _builder.append("$templateParameters[\'canBeCreated\'] = $this->modelHelper->canBeCreated($objectType);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $templateParameters;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processDisplayActionParameters(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Processes the parameters for a display action.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType         Name of treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $templateParameters Template data");
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.append(" ");
        _builder.append("* @param boolean $supportsHooks      Whether hooks are supported or not");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Enriched template parameters used for creating the response");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processDisplayActionParameters($objectType, array $templateParameters = []");
    {
      boolean _hasHookSubscribers_1 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_1) {
        _builder.append(", $supportsHooks = false");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$contextArgs = [\'controller\' => $objectType, \'action\' => \'display\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $this->getObjectTypes(\'controllerAction\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new Exception($this->__(\'Error! Invalid object type received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->setRequest($this->request);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $templateParameters[$objectType];");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_2 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_2) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (true === $supportsHooks) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// build RouteUrl instance for display hooks");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$currentUrlArgs = $entity->createUrlArgs();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$currentUrlArgs[\'_locale\'] = $this->request->getLocale();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$currentUrlObject = new RouteUrl(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB, "        ");
        _builder.append("_\' . $objectType . \'_\' . /*$templateParameters[\'routeArea\'] . */\'display\', $currentUrlArgs);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$templateParameters[\'currentUrlObject\'] = $currentUrlObject;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$additionalParameters = $repository->getAdditionalTemplateParameters(");
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("$this->imageHelper, ");
      }
    }
    _builder.append("\'controllerAction\', $contextArgs);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$templateParameters = array_merge($templateParameters, $additionalParameters);");
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper) {
        _builder.append("    ");
        _builder.append("$templateParameters[\'featureActivationHelper\'] = $this->featureActivationHelper;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $templateParameters;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processEditActionParameters(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Processes the parameters for an edit action.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType         Name of treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $templateParameters Template data");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Enriched template parameters used for creating the response");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processEditActionParameters($objectType, array $templateParameters = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$contextArgs = [\'controller\' => $objectType, \'action\' => \'edit\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $this->getObjectTypes(\'controllerAction\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new Exception($this->__(\'Error! Invalid object type received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->setRequest($this->request);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$additionalParameters = $repository->getAdditionalTemplateParameters(");
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("$this->imageHelper, ");
      }
    }
    _builder.append("\'controllerAction\', $contextArgs);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$templateParameters = array_merge($templateParameters, $additionalParameters);");
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper) {
        _builder.append("    ");
        _builder.append("$templateParameters[\'featureActivationHelper\'] = $this->featureActivationHelper;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $templateParameters;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processDeleteActionParameters(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Processes the parameters for a delete action.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType         Name of treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $templateParameters Template data");
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.append(" ");
        _builder.append("* @param boolean $supportsHooks      Whether hooks are supported or not");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Enriched template parameters used for creating the response");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processDeleteActionParameters($objectType, array $templateParameters = []");
    {
      boolean _hasHookSubscribers_1 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_1) {
        _builder.append(", $supportsHooks = false");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$contextArgs = [\'controller\' => $objectType, \'action\' => \'delete\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $this->getObjectTypes(\'controllerAction\', $contextArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new Exception($this->__(\'Error! Invalid object type received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->setRequest($this->request);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$additionalParameters = $repository->getAdditionalTemplateParameters(");
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("$this->imageHelper, ");
      }
    }
    _builder.append("\'controllerAction\', $contextArgs);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$templateParameters = array_merge($templateParameters, $additionalParameters);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $templateParameters;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence performGeoCoding(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Example method for performing geo coding in PHP.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* To use this please customise it to your needs in the concrete subclass.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Also you have to call this method in a PrePersist-Handler of the");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* corresponding entity class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* There is also a method on JS level available in ");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    _builder.append(_appJsPath, " ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".EditFunctions.js.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $address The address input string");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Array The determined coordinates");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function performGeoCoding($address)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$lang = $this->request->getLocale();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$url = \'https://maps.googleapis.com/maps/api/geocode/json?key=\' . $this->variableApi->get(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("\', \'googleMapsApiKey\', \'\') . \'&address=\' . urlencode($address);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$url .= \'&region=\' . $lang . \'&language=\' . $lang . \'&sensor=false\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$json = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// we can either use Snoopy if available");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//require_once(\'");
    String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(it);
    _builder.append(_relativeAppRootPath, "    ");
    _builder.append("/vendor/Snoopy/Snoopy.class.php\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("//$snoopy = new Snoopy();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$snoopy->fetch($url);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$json = $snoopy->results;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// we can also use curl");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (function_exists(\'curl_version\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$ch = curl_init();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("curl_setopt($ch, CURLOPT_HEADER, 0);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1); // can cause problems with open_basedir");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("curl_setopt($ch, CURLOPT_URL, $url);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$json = curl_exec($ch);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("curl_close($ch);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// or we can use the plain file_get_contents method");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// requires allow_url_fopen = true in php.ini which is NOT good for security");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$json = file_get_contents($url);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// create the result array");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'latitude\' => 0,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'longitude\' => 0");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($json != \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$data = json_decode($json);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (json_last_error() == JSON_ERROR_NONE && $data->status == \'OK\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$jsonResult = reset($data->results);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$location = $jsonResult->geometry->location;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result[\'latitude\'] = str_replace(\',\', \'.\', $location->lat);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result[\'longitude\'] = str_replace(\',\', \'.\', $location->lng);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "            ");
    _builder.append("\', \'user\' => $this->currentUserApi->get(\'uname\'), \'field\' => $field, \'address\' => $address];");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$this->logger->warning(\'{app}: User {user} tried geocoding for address \"{address}\", but failed.\', $logArgs);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence controllerFunctionsImpl(final Application it) {
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
    _builder.append("\\Helper\\Base\\AbstractControllerHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for controller layer methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ControllerHelper extends AbstractControllerHelper");
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
