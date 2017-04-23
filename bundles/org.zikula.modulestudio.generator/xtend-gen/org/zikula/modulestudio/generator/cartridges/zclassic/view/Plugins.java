package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import de.guite.modulestudio.metamodel.Application;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatGeoData;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.FormatIcalText;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetCountryName;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetFileSize;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.GetListEntry;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ModerationObjects;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectState;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.ObjectTypeSelector;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TemplateSelector;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeData;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.TreeSelection;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form.ItemSelector;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Plugins {
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
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private IFileSystemAccess fsa;
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.fsa = fsa;
    InputOutput.<String>println("Generating Twig extension class");
    final FileHelper fh = new FileHelper();
    final String twigFolder = "Twig";
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + twigFolder);
    String _plus_1 = (_plus + "/TwigExtension.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus_1, 
      fh.phpFileContent(it, this.twigExtensionBaseImpl(it)), fh.phpFileContent(it, this.twigExtensionImpl(it)));
  }
  
  public String generateInternal(final Application it) {
    String _xblockexpression = null;
    {
      final ArrayList<String> result = CollectionLiterals.<String>newArrayList();
      String _viewPlugins = this.viewPlugins(it);
      result.add(_viewPlugins);
      if ((this._generatorSettingsExtensions.generateListContentType(it) || this._generatorSettingsExtensions.generateDetailContentType(it))) {
        new ObjectTypeSelector().generate(it, this.fsa, Boolean.valueOf(true));
      }
      boolean _generateListContentType = this._generatorSettingsExtensions.generateListContentType(it);
      if (_generateListContentType) {
        new TemplateSelector().generate(it, this.fsa, Boolean.valueOf(true));
      }
      boolean _generateDetailContentType = this._generatorSettingsExtensions.generateDetailContentType(it);
      if (_generateDetailContentType) {
        new ItemSelector().generate(it, this.fsa);
      }
      String _otherPlugins = this.otherPlugins(it);
      result.add(_otherPlugins);
      _xblockexpression = IterableExtensions.join(result, "\n\n");
    }
    return _xblockexpression;
  }
  
  private CharSequence twigExtensionBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Twig\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((this._generatorSettingsExtensions.generateIcsTemplates(it) && this._modelBehaviourExtensions.hasEntitiesWithIcsTemplates(it))) {
        _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpFoundation\\RequestStack;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.append("use Symfony\\Component\\Routing\\RouterInterface;");
        _builder.newLine();
      }
    }
    _builder.append("use Twig_Extension;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
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
    {
      boolean _needsUserAvatarSupport = this._modelBehaviourExtensions.needsUserAvatarSupport(it);
      if (_needsUserAvatarSupport) {
        _builder.append("use Zikula\\UsersModule\\Entity\\RepositoryInterface\\UserRepositoryInterface;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_1) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Entity\\Factory\\");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("Factory;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasListFields = this._modelExtensions.hasListFields(it);
      if (_hasListFields) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2);
        _builder.append("\\Helper\\ListEntriesHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use ");
    String _appNamespace_3 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_3);
    _builder.append("\\Helper\\WorkflowHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Twig extension base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractTwigExtension extends Twig_Extension");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _twigExtensionBody = this.twigExtensionBody(it);
    _builder.append(_twigExtensionBody, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence twigExtensionBody(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    final String appNameLower = this._utils.appName(it).toLowerCase();
    _builder.newLineIfNotEmpty();
    _builder.append("use TranslatorTrait;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var RouterInterface");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $router;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateIcsTemplates(it) && this._modelBehaviourExtensions.hasEntitiesWithIcsTemplates(it))) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var Request");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $request;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var VariableApi");
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
    _builder.append("protected $variableApi;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _needsUserAvatarSupport = this._modelBehaviourExtensions.needsUserAvatarSupport(it);
      if (_needsUserAvatarSupport) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var UserRepositoryInterface");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $userRepository;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees_1 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_1) {
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
        _builder.append("protected $entityFactory;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var WorkflowHelper");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $workflowHelper;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasListFields = this._modelExtensions.hasListFields(it);
      if (_hasListFields) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var ListEntriesHelper");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $listHelper;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* TwigExtension constructor.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    {
      boolean _hasTrees_2 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_2) {
        _builder.append(" ");
        _builder.append("* @param Routerinterface     $router         Router service instance");
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateIcsTemplates(it) && this._modelBehaviourExtensions.hasEntitiesWithIcsTemplates(it))) {
        _builder.append(" ");
        _builder.append("* @param RequestStack        $requestStack   RequestStack service instance");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @param VariableApi");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("        ");
      }
    }
    _builder.append(" $variableApi    VariableApi service instance");
    _builder.newLineIfNotEmpty();
    {
      boolean _needsUserAvatarSupport_1 = this._modelBehaviourExtensions.needsUserAvatarSupport(it);
      if (_needsUserAvatarSupport_1) {
        _builder.append(" ");
        _builder.append("* @param UserRepositoryInterface $userRepository UserRepository service instance");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees_3 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_3) {
        _builder.append(" ");
        _builder.append("* @param ");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1, " ");
        _builder.append("Factory $entityFactory ");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_2, " ");
        _builder.append("Factory service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* @param WorkflowHelper      $workflowHelper WorkflowHelper service instance");
    _builder.newLine();
    {
      boolean _hasListFields_1 = this._modelExtensions.hasListFields(it);
      if (_hasListFields_1) {
        _builder.append(" ");
        _builder.append("* @param ListEntriesHelper   $listHelper     ListEntriesHelper service instance");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function __construct(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("TranslatorInterface $translator");
    {
      boolean _hasTrees_4 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_4) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("RouterInterface $router");
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateIcsTemplates(it) && this._modelBehaviourExtensions.hasEntitiesWithIcsTemplates(it))) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("RequestStack $requestStack");
      }
    }
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("VariableApi");
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $variableApi,");
    _builder.newLineIfNotEmpty();
    {
      boolean _needsUserAvatarSupport_2 = this._modelBehaviourExtensions.needsUserAvatarSupport(it);
      if (_needsUserAvatarSupport_2) {
        _builder.append("    ");
        _builder.append("UserRepositoryInterface $userRepository,");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees_5 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_5) {
        _builder.append("    ");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_3, "    ");
        _builder.append("Factory $entityFactory,");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("WorkflowHelper $workflowHelper");
    {
      boolean _hasListFields_2 = this._modelExtensions.hasListFields(it);
      if (_hasListFields_2) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("ListEntriesHelper $listHelper");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->setTranslator($translator);");
    _builder.newLine();
    {
      boolean _hasTrees_6 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_6) {
        _builder.append("    ");
        _builder.append("$this->router = $router;");
        _builder.newLine();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateIcsTemplates(it) && this._modelBehaviourExtensions.hasEntitiesWithIcsTemplates(it))) {
        _builder.append("    ");
        _builder.append("$this->request = $requestStack->getCurrentRequest();");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$this->variableApi = $variableApi;");
    _builder.newLine();
    {
      boolean _needsUserAvatarSupport_3 = this._modelBehaviourExtensions.needsUserAvatarSupport(it);
      if (_needsUserAvatarSupport_3) {
        _builder.append("    ");
        _builder.append("$this->userRepository = $userRepository;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees_7 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_7) {
        _builder.append("    ");
        _builder.append("$this->entityFactory = $entityFactory;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$this->workflowHelper = $workflowHelper;");
    _builder.newLine();
    {
      boolean _hasListFields_3 = this._modelExtensions.hasListFields(it);
      if (_hasListFields_3) {
        _builder.append("    ");
        _builder.append("$this->listHelper = $listHelper;");
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
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns a list of custom Twig functions.");
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
    _builder.append("public function getFunctions()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return [");
    _builder.newLine();
    {
      boolean _hasTrees_8 = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees_8) {
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFunction(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_treeData\', [$this, \'getTreeData\'], [\'is_safe\' => [\'html\']]),");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFunction(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_treeSelection\', [$this, \'getTreeSelection\']),");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateModerationPanel(it) && this._workflowExtensions.needsApproval(it))) {
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFunction(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_moderationObjects\', [$this, \'getModerationObjects\']),");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("new \\Twig_SimpleFunction(\'");
    _builder.append(appNameLower, "        ");
    _builder.append("_objectTypeSelector\', [$this, \'getObjectTypeSelector\']),");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("new \\Twig_SimpleFunction(\'");
    _builder.append(appNameLower, "        ");
    _builder.append("_templateSelector\', [$this, \'getTemplateSelector\'])");
    {
      boolean _needsUserAvatarSupport_4 = this._modelBehaviourExtensions.needsUserAvatarSupport(it);
      if (_needsUserAvatarSupport_4) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFunction(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_userAvatar\', [$this, \'getUserAvatar\'], [\'is_safe\' => [\'html\']])");
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
    _builder.append("* Returns a list of custom Twig filters.");
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
    _builder.append("public function getFilters()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return [");
    _builder.newLine();
    {
      boolean _hasCountryFields = this._modelExtensions.hasCountryFields(it);
      if (_hasCountryFields) {
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFilter(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_countryName\', [$this, \'getCountryName\']),");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFilter(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_fileSize\', [$this, \'getFileSize\'], [\'is_safe\' => [\'html\']]),");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasListFields_4 = this._modelExtensions.hasListFields(it);
      if (_hasListFields_4) {
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFilter(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_listEntry\', [$this, \'getListEntry\']),");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFilter(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_geoData\', [$this, \'formatGeoData\']),");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasEntitiesWithIcsTemplates = this._modelBehaviourExtensions.hasEntitiesWithIcsTemplates(it);
      if (_hasEntitiesWithIcsTemplates) {
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleFilter(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_icalText\', [$this, \'formatIcalText\']),");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("new \\Twig_SimpleFilter(\'");
    _builder.append(appNameLower, "        ");
    _builder.append("_objectState\', [$this, \'getObjectState\'], [\'is_safe\' => [\'html\']])");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasLoggable = this._modelBehaviourExtensions.hasLoggable(it);
      if (_hasLoggable) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Returns a list of custom Twig tests.");
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
        _builder.append("public function getTests()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("new \\Twig_SimpleTest(\'");
        _builder.append(appNameLower, "        ");
        _builder.append("_instanceOf\', function ($var, $instance) {");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("return $var instanceof $instance;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("})");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    String _generateInternal = this.generateInternal(it);
    _builder.append(_generateInternal);
    _builder.newLineIfNotEmpty();
    {
      boolean _needsUserAvatarSupport_5 = this._modelBehaviourExtensions.needsUserAvatarSupport(it);
      if (_needsUserAvatarSupport_5) {
        _builder.newLine();
        CharSequence _userAvatar = this.getUserAvatar(it);
        _builder.append(_userAvatar);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence getUserAvatar(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Display the avatar of a user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int|string $uid    The user\'s id or name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int        $width  Image width (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int        $height Image height (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int        $size   Gravatar size (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string     $rating Gravatar self-rating [g|pg|r|x] see: http://en.gravatar.com/site/implement/images/ (optional)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getUserAvatar($uid = 0, $width = 0, $height = 0, $size = 0, $rating = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_numeric($uid)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$limit = 1;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filter = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'uname\' => [\'operator\' => \'=\', \'operand\' => $uid]");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$results = $this->userRepository->query($filter, [], $limit);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!count($results)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$uid = $results->getIterator()->getArrayCopy()[0]->getUname();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$params = [\'uid\' => $uid];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($width > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$params[\'width\'] = $width;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($height > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$params[\'height\'] = $height;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($size > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$params[\'size\'] = $size;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($rating != \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$params[\'rating\'] = $rating;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("include_once \'lib/legacy/viewplugins/function.useravatar.php\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view = \\Zikula_View::getInstance(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$result = smarty_function_useravatar($params, $view);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence twigExtensionImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Twig;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Twig\\Base\\AbstractTwigExtension;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Twig extension implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class TwigExtension extends AbstractTwigExtension");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own Twig extension methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private String viewPlugins(final Application it) {
    String _xblockexpression = null;
    {
      final ArrayList<CharSequence> result = CollectionLiterals.<CharSequence>newArrayList();
      CharSequence _generate = new ObjectState().generate(it, this.fsa);
      result.add(_generate);
      boolean _hasCountryFields = this._modelExtensions.hasCountryFields(it);
      if (_hasCountryFields) {
        CharSequence _generate_1 = new GetCountryName().generate(it, this.fsa);
        result.add(_generate_1);
      }
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        CharSequence _generate_2 = new GetFileSize().generate(it, this.fsa);
        result.add(_generate_2);
      }
      boolean _hasListFields = this._modelExtensions.hasListFields(it);
      if (_hasListFields) {
        CharSequence _generate_3 = new GetListEntry().generate(it, this.fsa);
        result.add(_generate_3);
      }
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        CharSequence _generate_4 = new FormatGeoData().generate(it, this.fsa);
        result.add(_generate_4);
      }
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        CharSequence _generate_5 = new TreeData().generate(it, this.fsa);
        result.add(_generate_5);
        CharSequence _generate_6 = new TreeSelection().generate(it, this.fsa);
        result.add(_generate_6);
      }
      if ((this._generatorSettingsExtensions.generateModerationPanel(it) && this._workflowExtensions.needsApproval(it))) {
        CharSequence _generate_7 = new ModerationObjects().generate(it, this.fsa);
        result.add(_generate_7);
      }
      if ((this._generatorSettingsExtensions.generateIcsTemplates(it) && this._modelBehaviourExtensions.hasEntitiesWithIcsTemplates(it))) {
        CharSequence _generate_8 = new FormatIcalText().generate(it, this.fsa);
        result.add(_generate_8);
      }
      _xblockexpression = IterableExtensions.join(result, "\n\n");
    }
    return _xblockexpression;
  }
  
  private String otherPlugins(final Application it) {
    String _xblockexpression = null;
    {
      final ArrayList<CharSequence> result = CollectionLiterals.<CharSequence>newArrayList();
      boolean _generateDetailContentType = this._generatorSettingsExtensions.generateDetailContentType(it);
      if (_generateDetailContentType) {
        new ItemSelector().generate(it, this.fsa);
      }
      CharSequence _generate = new ObjectTypeSelector().generate(it, this.fsa, Boolean.valueOf(false));
      result.add(_generate);
      CharSequence _generate_1 = new TemplateSelector().generate(it, this.fsa, Boolean.valueOf(false));
      result.add(_generate_1);
      _xblockexpression = IterableExtensions.join(result, "\n\n");
    }
    return _xblockexpression;
  }
}
