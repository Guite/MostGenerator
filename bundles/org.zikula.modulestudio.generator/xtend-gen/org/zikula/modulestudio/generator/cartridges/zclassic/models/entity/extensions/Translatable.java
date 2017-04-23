package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.AbstractExtension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Translatable extends AbstractExtension implements EntityExtensionInterface {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  /**
   * Generates additional annotations on class level.
   */
  @Override
  public CharSequence classAnnotations(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("* @Gedmo\\TranslationEntity(class=\"");
    String _entityClassName = this._namingExtensions.entityClassName(it, "translation", Boolean.valueOf(false));
    _builder.append(_entityClassName);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Additional field annotations.
   */
  @Override
  public CharSequence columnAnnotations(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isTranslatable = it.isTranslatable();
      if (_isTranslatable) {
        _builder.append(" * @Gedmo\\Translatable");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  /**
   * Generates additional entity properties.
   */
  @Override
  public CharSequence properties(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Used locale to override Translation listener\'s locale.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* this is not a mapped field of entity metadata, just a simple property.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @Assert\\Locale()");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Gedmo\\Locale");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var string $locale");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $locale;");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * Generates additional accessor methods.
   */
  @Override
  public CharSequence accessors(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final FileHelper fh = new FileHelper();
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods = fh.getterAndSetterMethods(it, "locale", "string", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Returns the extension class type.
   */
  @Override
  public String extensionClassType(final Entity it) {
    return "translation";
  }
  
  /**
   * Returns the extension class import statements.
   */
  @Override
  public String extensionClassImports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use Gedmo\\Translatable\\Entity\\MappedSuperclass\\");
    String _extensionBaseClass = this.extensionBaseClass(it);
    _builder.append(_extensionBaseClass);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    return _builder.toString();
  }
  
  /**
   * Returns the extension base class.
   */
  @Override
  public String extensionBaseClass(final Entity it) {
    return "AbstractTranslation";
  }
  
  /**
   * Returns the extension class description.
   */
  @Override
  public String extensionClassDescription(final Entity it) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Entity extension domain class storing " + _formatForDisplay);
    return (_plus + " translations.");
  }
  
  /**
   * Returns the extension implementation class ORM annotations.
   */
  @Override
  public String extensionClassImplAnnotations(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\Entity(repositoryClass=\"");
    String _repositoryClass = this.repositoryClass(it, this.extensionClassType(it));
    _builder.append(_repositoryClass);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\Table(name=\"");
    String _fullEntityTableName = this._modelExtensions.fullEntityTableName(it);
    _builder.append(_fullEntityTableName);
    _builder.append("_translation\",");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*     indexes={");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*         @ORM\\Index(name=\"translations_lookup_idx\", columns={");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*             \"locale\", \"object_class\", \"foreign_key\"");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*         })");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*     }");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* )");
    _builder.newLineIfNotEmpty();
    return _builder.toString();
  }
}
