package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.HookBundles;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class HookHelper {
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
    boolean _not = (!_hasHookSubscribers);
    if (_not) {
      return;
    }
    final FileHelper fh = new FileHelper();
    InputOutput.<String>println("Generating helper class for hook calls");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/HookHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.hookFunctionsBaseImpl(it)), fh.phpFileContent(it, this.hookFunctionsImpl(it)));
    InputOutput.<String>println("Generating helper class for hook bundles");
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath_1 + "Container/HookContainer.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus_1, 
      fh.phpFileContent(it, this.hookContainerBaseImpl(it)), fh.phpFileContent(it, this.hookContainerImpl(it)));
  }
  
  private CharSequence hookFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Zikula\\Component\\HookDispatcher\\Hook;");
    _builder.newLine();
    _builder.append("use Zikula\\Component\\HookDispatcher\\HookDispatcher;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Doctrine\\EntityAccess;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Hook\\ProcessHook;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Hook\\ValidationHook;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Hook\\ValidationProviders;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\RouteUrl;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for hook related methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractHookHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var HookDispatcher");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $hookDispatcher;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* HookHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param HookDispatcher $hookDispatcher Hook dispatcher service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct($hookDispatcher)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->hookDispatcher = $hookDispatcher;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _callValidationHooks = this.callValidationHooks(it);
    _builder.append(_callValidationHooks, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _callProcessHooks = this.callProcessHooks(it);
    _builder.append(_callProcessHooks, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _dispatchHooks = this.dispatchHooks(it);
    _builder.append(_dispatchHooks, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence callValidationHooks(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Calls validation hooks.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param EntityAccess $entity   The currently processed entity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string       $hookType Name of hook type to be called");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean Whether validation is passed or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function callValidationHooks($entity, $hookType)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hookAreaPrefix = $entity->getHookAreaPrefix();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hook = new ValidationHook(new ValidationProviders());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$validators = $this->dispatchHooks($hookAreaPrefix . \'.\' . $hookType, $hook)->getValidators();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return !$validators->hasErrors();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence callProcessHooks(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Calls process hooks.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param EntityAccess $entity The currently processed entity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string       $hookType Name of hook type to be called");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param RouteUrl     $url      The url object");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function callProcessHooks($entity, $hookType, $url)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hookAreaPrefix = $entity->getHookAreaPrefix();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hook = new ProcessHook($entity->createCompositeIdentifier(), $url);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->dispatchHooks($hookAreaPrefix . \'.\' . $hookType, $hook);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence dispatchHooks(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Dispatch hooks.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $name Hook event name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Hook   $hook Hook interface");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Hook");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function dispatchHooks($name, Hook $hook)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->hookDispatcher->dispatch($name, $hook);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence hookFunctionsImpl(final Application it) {
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
    _builder.append("\\Helper\\Base\\AbstractHookHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for hook related methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class HookHelper extends AbstractHookHelper");
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
  
  private CharSequence hookContainerBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Container\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Zikula\\Bundle\\HookBundle\\AbstractHookContainer as ZikulaHookContainer;");
    _builder.newLine();
    _builder.append("use Zikula\\Bundle\\HookBundle\\Bundle\\SubscriberBundle;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Base class for hook container methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractHookContainer extends ZikulaHookContainer");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _setup = this.setup(it);
    _builder.append(_setup, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence setup(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Define the hook bundles supported by this module.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function setupHookBundles()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    final HookBundles hookHelper = new HookBundles();
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _setup = hookHelper.setup(it);
    _builder.append(_setup, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence hookContainerImpl(final Application it) {
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
    _builder.append("\\Container\\Base\\AbstractHookContainer;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Implementation class for hook container methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class HookContainer extends AbstractHookContainer");
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
