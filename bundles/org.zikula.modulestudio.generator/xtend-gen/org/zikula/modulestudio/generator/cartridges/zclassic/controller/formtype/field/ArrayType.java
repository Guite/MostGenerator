package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ArrayType {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Form/Type/Field/ArrayType.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.arrayTypeBaseImpl(it)), this.fh.phpFileContent(it, this.arrayTypeImpl(it)));
  }
  
  private CharSequence arrayTypeBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type\\Field\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\AbstractType;");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("use Symfony\\Component\\Form\\Extension\\Core\\Type\\TextareaType;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\Form\\FormBuilderInterface;");
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\DataTransformer\\ArrayFieldTransformer;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Array field type base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractArrayType extends AbstractType");
    _builder.newLine();
    _builder.append("{");
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
    _builder.append("$transformer = new ArrayFieldTransformer();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$builder->addModelTransformer($transformer);");
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
    _builder.append("public function getParent()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("TextareaType::class");
      } else {
        _builder.append("\'Symfony\\Component\\Form\\Extension\\Core\\Type\\TextareaType\'");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
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
    _builder.append("_field_array\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence arrayTypeImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type\\Field;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Type\\Field\\Base\\AbstractArrayType;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Array field type implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ArrayType extends AbstractArrayType");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your customisation here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
