package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class GeographicalTrait {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  private Boolean isLoggable;
  
  public void generate(final Application it, final IFileSystemAccess fsa, final Boolean loggable) {
    this.isLoggable = loggable;
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Traits/");
    String _xifexpression = null;
    if ((loggable).booleanValue()) {
      _xifexpression = "Loggable";
    } else {
      _xifexpression = "";
    }
    String _plus_1 = (_plus + _xifexpression);
    final String filePath = (_plus_1 + "GeographicalTrait.php");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, filePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, filePath);
      if (_shouldBeMarked) {
        fsa.generateFile(filePath.replace(".php", ".generated.php"), this.fh.phpFileContent(it, this.traitFile(it)));
      } else {
        fsa.generateFile(filePath, this.fh.phpFileContent(it, this.traitFile(it)));
      }
    }
  }
  
  private CharSequence traitFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Traits;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Doctrine\\ORM\\Mapping as ORM;");
    _builder.newLine();
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append("use Gedmo\\Mapping\\Annotation as Gedmo;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\Validator\\Constraints as Assert;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append("Loggable g");
      } else {
        _builder.append("G");
      }
    }
    _builder.append("eographical trait implementation class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("trait ");
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append("Loggable");
      }
    }
    _builder.append("GeographicalTrait");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _traitImpl = this.traitImpl(it);
    _builder.append(_traitImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence traitImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The coordinate\'s latitude part.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"decimal\", precision=12, scale=7)");
    _builder.newLine();
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @var float $latitude");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $latitude = 0.00;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The coordinate\'s longitude part.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"decimal\", precision=12, scale=7)");
    _builder.newLine();
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @var float $longitude");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $longitude = 0.00;");
    _builder.newLine();
    _builder.newLine();
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "latitude", "float", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods);
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, "longitude", "float", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
