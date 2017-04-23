package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class StandardFieldsTrait {
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
    final String filePath = (_plus_1 + "StandardFieldsTrait.php");
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
    _builder.append("use Gedmo\\Mapping\\Annotation as Gedmo;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Validator\\Constraints as Assert;");
    _builder.newLine();
    _builder.append("use Zikula\\UsersModule\\Entity\\UserEntity;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append("Loggable s");
      } else {
        _builder.append("S");
      }
    }
    _builder.append("tandard fields trait implementation class.");
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
    _builder.append("StandardFieldsTrait");
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
    _builder.append("* @Gedmo\\Blameable(on=\"create\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\ManyToOne(targetEntity=\"Zikula\\UsersModule\\Entity\\UserEntity\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\JoinColumn(referencedColumnName=\"uid\")");
    _builder.newLine();
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @var UserEntity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $createdBy;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"datetime\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Gedmo\\Timestampable(on=\"create\")");
    _builder.newLine();
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @Assert\\DateTime()");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var \\DateTime $createdDate");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $createdDate;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Gedmo\\Blameable(on=\"update\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\ManyToOne(targetEntity=\"Zikula\\UsersModule\\Entity\\UserEntity\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\JoinColumn(referencedColumnName=\"uid\")");
    _builder.newLine();
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @var UserEntity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $updatedBy;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"datetime\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Gedmo\\Timestampable(on=\"update\")");
    _builder.newLine();
    {
      if ((this.isLoggable).booleanValue()) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @Assert\\DateTime()");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var \\DateTime $updatedDate");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $updatedDate;");
    _builder.newLine();
    _builder.newLine();
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "createdBy", "UserEntity", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods);
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, "createdDate", "datetime", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_1);
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_2 = this.fh.getterAndSetterMethods(it, "updatedBy", "UserEntity", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_2);
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_3 = this.fh.getterAndSetterMethods(it, "updatedDate", "datetime", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_3);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
