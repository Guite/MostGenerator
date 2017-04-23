package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class DeleteEntity {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  private String nsSymfonyFormType = "Symfony\\Component\\Form\\Extension\\Core\\Type\\";
  
  /**
   * Entry point for entity deletion form type.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    if (((!this._controllerExtensions.hasDeleteActions(it)) || (this._utils.targets(it, "1.5")).booleanValue())) {
      return;
    }
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Form/DeleteEntityType.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.deleteEntityTypeBaseImpl(it)), this.fh.phpFileContent(it, this.deleteEntityTypeImpl(it)));
  }
  
  private CharSequence deleteEntityTypeBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\AbstractType;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\FormBuilderInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Entity deletion form type base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractDeleteEntityType extends AbstractType");
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
    _builder.append("* DeleteEntityType constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator Translator service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(TranslatorInterface $translator)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->translator = $translator;");
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
    _builder.append("public function buildForm(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$builder");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->add(\'delete\', \'");
    _builder.append(this.nsSymfonyFormType, "            ");
    _builder.append("SubmitType\', [");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'label\' => $this->translator->__(\'Delete\'),");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'icon\' => \'fa-trash-o\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'class\' => \'btn btn-danger\'");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->add(\'cancel\', \'");
    _builder.append(this.nsSymfonyFormType, "            ");
    _builder.append("SubmitType\', [");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'label\' => $this->translator->__(\'Cancel\'),");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'icon\' => \'fa-times\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'class\' => \'btn btn-default\',");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'formnovalidate\' => \'formnovalidate\'");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(";");
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
    _builder.append("public function getBlockPrefix()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "        ");
    _builder.append("_deleteentity\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence deleteEntityTypeImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Base\\AbstractDeleteEntityType;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Entity deletion form type implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class DeleteEntityType extends AbstractDeleteEntityType");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the base form type class here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
