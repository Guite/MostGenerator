package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class DependencyInjection {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus = (_formatForCodeCapital + _formatForCodeCapital_1);
    final String extensionFileName = (_plus + "Extension.php");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath + "DependencyInjection/");
    String _plus_2 = (_plus_1 + extensionFileName);
    this._namingExtensions.generateClassPair(it, fsa, _plus_2, 
      this.fh.phpFileContent(it, this.extensionBaseImpl(it)), this.fh.phpFileContent(it, this.extensionImpl(it)));
  }
  
  private CharSequence extensionBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\DependencyInjection\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Config\\FileLocator;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\DependencyInjection\\ContainerBuilder;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\DependencyInjection\\Loader\\YamlFileLoader;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpKernel\\DependencyInjection\\Extension;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Base class for service definition loader using the DependencyInjection extension.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Extension extends Extension");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Loads service definition file containing persistent event handlers.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Responds to the app.config configuration parameter.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param array            $configs");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param ContainerBuilder $container");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function load(array $configs, ContainerBuilder $container)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$loader = new YamlFileLoader($container, new FileLocator(__DIR__ . \'/../../Resources/config\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$loader->load(\'services.yml\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence extensionImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\DependencyInjection;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\DependencyInjection\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Extension;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Implementation class for service definition loader using the DependencyInjection extension.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2);
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Extension extends Abstract");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_4);
    String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_5);
    _builder.append("Extension");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// custom enhancements can go here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
