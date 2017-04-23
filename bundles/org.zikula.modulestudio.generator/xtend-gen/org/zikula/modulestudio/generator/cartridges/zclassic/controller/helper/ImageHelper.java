package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ImageHelper {
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for image handling");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/ImageHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.imageFunctionsBaseImpl(it)), fh.phpFileContent(it, this.imageFunctionsImpl(it)));
    boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
    if (_hasImageFields) {
      String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
      String _plus_1 = (_appSourceLibPath_1 + "Imagine/Cache/DummySigner.php");
      this._namingExtensions.generateClassPair(it, fsa, _plus_1, 
        fh.phpFileContent(it, this.dummySignerBaseImpl(it)), fh.phpFileContent(it, this.dummySignerImpl(it)));
    }
  }
  
  private CharSequence imageFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Session\\SessionInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
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
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for image methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractImageHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var TranslatorInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $translator;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var SessionInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $session;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var VariableApi");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
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
    _builder.append("* Name of the application.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $name;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ImageHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator  Translator service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param SessionInterface    $session     Session service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param VariableApi");
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("        ");
      }
    }
    _builder.append(" $variableApi VariableApi service instance");
    _builder.newLineIfNotEmpty();
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
    _builder.append("SessionInterface $session,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("VariableApi");
    {
      Boolean _targets_3 = this._utils.targets(it, "1.5");
      if ((_targets_3).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $variableApi");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->translator = $translator;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->session = $session;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->variableApi = $variableApi;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->name = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _runtimeOptions = this.getRuntimeOptions(it);
    _builder.append(_runtimeOptions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _customRuntimeOptions = this.getCustomRuntimeOptions(it);
    _builder.append(_customRuntimeOptions, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _checkIfImagineCacheDirectoryExists = this.checkIfImagineCacheDirectoryExists(it);
        _builder.append(_checkIfImagineCacheDirectoryExists, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getRuntimeOptions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method returns an Imagine runtime options array for the given arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Currently treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  Name of upload field");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args       Additional arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The selected runtime options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getRuntimeOptions($objectType = \'\', $fieldName = \'\', $context = \'\', $args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.append("    ");
        _builder.append("$this->checkIfImagineCacheDirectoryExists();");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("if (!in_array($context, [\'controllerAction\', \'api\', \'actionHandler\', \'block\', \'contentType\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$contextName = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($context == \'controllerAction\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'controller\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'controller\'] = \'user\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'action\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'action\'] = \'index\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(it);
      if (_needsAutoCompletion) {
        _builder.append("        ");
        _builder.append("if ($args[\'controller\'] == \'ajax\' && $args[\'action\'] == \'getItemListAutoCompletion\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$contextName = $this->name . \'_ajax_autocomplete\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$contextName = $this->name . \'_\' . $args[\'controller\'] . \'_\' . $args[\'action\'];");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$contextName = $this->name . \'_\' . $args[\'controller\'] . \'_\' . $args[\'action\'];");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($contextName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$contextName = $this->name . \'_default\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->getCustomRuntimeOptions($objectType, $fieldName, $contextName, $context, $args);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCustomRuntimeOptions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method returns an Imagine runtime options array for the given arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Currently treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  Name of upload field");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $contextName Name of desired context");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args       Additional arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The selected runtime options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getCustomRuntimeOptions($objectType = \'\', $fieldName = \'\', $contextName = \'\', $context = \'\', $args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$options = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'thumbnail\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'size\'      => [100, 100], // thumbnail width and height in pixels");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'mode\'      => $this->variableApi->get(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "            ");
    _builder.append("\', \'thumbnailMode\' . ucfirst($objectType) . ucfirst($fieldName), \'inset\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'extension\' => null        // file extension for thumbnails (jpg, png, gif; null for original file type)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(it);
      if (_needsAutoCompletion) {
        _builder.append("    ");
        _builder.append("if ($contextName == $this->name . \'_ajax_autocomplete\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$options[\'thumbnail\'][\'size\'] = [100, 75];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $options;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("if ($contextName == $this->name . \'_relateditem\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$options[\'thumbnail\'][\'size\'] = [100, 75];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($context == \'controllerAction\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (in_array($args[\'action\'], [\'view\', \'display\', \'edit\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$fieldSuffix = ucfirst($objectType) . ucfirst($fieldName) . ucfirst($args[\'action\']);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$defaultWidth = $args[\'action\'] == \'view\' ? 32 : 240;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$defaultHeight = $args[\'action\'] == \'view\' ? 24 : 180;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$options[\'thumbnail\'][\'size\'] = [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->variableApi->get(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "                ");
    _builder.append("\', \'thumbnailWidth\' . $fieldSuffix, $defaultWidth),");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("$this->variableApi->get(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "                ");
    _builder.append("\', \'thumbnailHeight\' . $fieldSuffix, $defaultHeight)");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $options;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence imageFunctionsImpl(final Application it) {
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
    _builder.append("\\Helper\\Base\\AbstractImageHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for image methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ImageHelper extends AbstractImageHelper");
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
  
  private CharSequence checkIfImagineCacheDirectoryExists(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Check if cache directory exists and create it if needed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function checkIfImagineCacheDirectoryExists()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$cachePath = \'web/imagine/cache\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (file_exists($cachePath)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->session->getFlashBag()->add(\'warning\', $this->translator->__f(\'The cache directory \"%directory%\" does not exist. Please create it and make it writable for the webserver.\', [\'%directory%\' => $cachePath]));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence dummySignerBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Imagine\\Cache\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Liip\\ImagineBundle\\Imagine\\Cache\\SignerInterface;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Temporary dummy signer until https://github.com/liip/LiipImagineBundle/issues/837 has been resolved.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractDummySigner implements SignerInterface");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("private $secret;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string $secret");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct($secret)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->secret = $secret;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function sign($path, array $runtimeConfig = null)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($runtimeConfig) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("array_walk_recursive($runtimeConfig, function (&$value) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$value = (string) $value;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return substr(preg_replace(\'/[^a-zA-Z0-9-_]/\', \'\', base64_encode(hash_hmac(\'sha256\', ltrim($path, \'/\').(null === $runtimeConfig ?: serialize($runtimeConfig)), $this->secret, true))), 0, 8);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function check($hash, $path, array $runtimeConfig = null)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return true;//$hash === $this->sign($path, $runtimeConfig);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence dummySignerImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Imagine\\Cache;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Imagine\\Cache\\Base\\AbstractDummySigner;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Temporary dummy signer until https://github.com/liip/LiipImagineBundle/issues/837 has been resolved.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class DummySigner extends AbstractDummySigner");
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
