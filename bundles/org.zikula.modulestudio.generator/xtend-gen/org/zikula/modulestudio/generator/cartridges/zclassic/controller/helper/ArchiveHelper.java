package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ArchiveHelper {
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
    InputOutput.<String>println("Generating helper class for automatic archiving");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/ArchiveHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.categoryHelperBaseClass(it)), fh.phpFileContent(it, this.categoryHelperImpl(it)));
  }
  
  private CharSequence categoryHelperBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Psr\\Log\\LoggerInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Session\\SessionInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\PermissionsModule\\Api\\");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("ApiInterface\\PermissionApiInterface");
      } else {
        _builder.append("PermissionApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Factory;");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2);
        _builder.append("\\Helper\\HookHelper;");
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
    _builder.append("* Archive helper base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractArchiveHelper");
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
    _builder.append("* @var LoggerInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $logger;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var PermissionApi");
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
    _builder.append("protected $permissionApi;");
    _builder.newLine();
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
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var WorkflowHelper");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $workflowHelper;");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_1 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var HookHelper");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $hookHelper;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ArchiveHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param SessionInterface    $session        Session service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param LoggerInterface     $logger         Logger service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param PermissionApi");
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append("       $permissionApi  PermissionApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("* @param ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "     ");
    _builder.append("Factory $entityFactory ");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3, "     ");
    _builder.append("Factory service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("* @param WorkflowHelper      $workflowHelper WorkflowHelper service instance");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_2 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_2) {
        _builder.append("     ");
        _builder.append("* @param HookHelper          $hookHelper     HookHelper service instance");
        _builder.newLine();
      }
    }
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
    _builder.append("LoggerInterface $logger,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("PermissionApi");
    {
      Boolean _targets_3 = this._utils.targets(it, "1.5");
      if ((_targets_3).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $permissionApi,");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4, "        ");
    _builder.append("Factory $entityFactory,");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WorkflowHelper $workflowHelper");
    {
      boolean _hasHookSubscribers_3 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_3) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("HookHelper $hookHelper");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->translator = $translator;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->session = $session;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->logger = $logger;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->permissionApi = $permissionApi;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->entityFactory = $entityFactory;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->workflowHelper = $workflowHelper;");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_4 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_4) {
        _builder.append("        ");
        _builder.append("$this->hookHelper = $hookHelper;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _archiveHelperBaseImpl = this.archiveHelperBaseImpl(it);
    _builder.append(_archiveHelperBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence archiveHelperBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Moves obsolete data into the archive.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function archiveObjects()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$randProbability = mt_rand(1, 1000);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($randProbability < 750) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->session->set(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("AutomaticArchiving\', true);");
    _builder.newLineIfNotEmpty();
    {
      Iterable<Entity> _archivingEntities = this._modelBehaviourExtensions.getArchivingEntities(it);
      for(final Entity entity : _archivingEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// perform update for ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
        _builder.append(_formatForDisplay, "    ");
        _builder.append(" becoming archived");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$logArgs = [\'app\' => \'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("\', \'entity\' => \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\'];");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$this->logger->notice(\'{app}: Automatic archiving for the {entity} entity started.\', $logArgs);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$repository = $this->entityFactory->getRepository(\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$repository->archiveObjects($this->permissionApi, $this->session, $this->translator, $this->workflowHelper");
        {
          boolean _isSkipHookSubscribers = entity.isSkipHookSubscribers();
          boolean _not = (!_isSkipHookSubscribers);
          if (_not) {
            _builder.append(", $this->hookHelper");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$this->logger->notice(\'{app}: Automatic archiving for the {entity} entity completed.\', $logArgs);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->session->del(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append("AutomaticArchiving\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence categoryHelperImpl(final Application it) {
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
    _builder.append("\\Helper\\Base\\AbstractArchiveHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Archive helper implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ArchiveHelper extends AbstractArchiveHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the archive helper here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
