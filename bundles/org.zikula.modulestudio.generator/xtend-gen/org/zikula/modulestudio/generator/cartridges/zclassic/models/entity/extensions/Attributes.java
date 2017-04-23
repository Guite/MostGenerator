package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.AbstractExtension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Attributes extends AbstractExtension implements EntityExtensionInterface {
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
    return _builder;
  }
  
  /**
   * Additional field annotations.
   */
  @Override
  public CharSequence columnAnnotations(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
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
    _builder.append("* @ORM\\OneToMany(targetEntity=\"\\");
    String _entityClassName = this._namingExtensions.entityClassName(it, "attribute", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.append("\", ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*                mappedBy=\"entity\", cascade={\"all\"}, ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*                orphanRemoval=true, indexBy=\"name\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var \\");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "attribute", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $attributes = null;");
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
    CharSequence _terMethod = fh.getterMethod(it, "attributes", "array", Boolean.valueOf(true));
    _builder.append(_terMethod);
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Set attribute.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $name  Attribute name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $value Attribute value");
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
    _builder.append("public function setAttribute($name, $value)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($this->attributes[$name])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (null === $value) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->attributes->remove($name);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->attributes[$name]->setValue($value);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->attributes[$name] = new \\");
    String _entityClassName = this._namingExtensions.entityClassName(it, "attribute", Boolean.valueOf(false));
    _builder.append(_entityClassName, "        ");
    _builder.append("($name, $value, $this);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  /**
   * Returns the extension class type.
   */
  @Override
  public String extensionClassType(final Entity it) {
    return "attribute";
  }
  
  /**
   * Returns the extension class import statements.
   */
  @Override
  public String extensionClassImports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use Doctrine\\ORM\\Mapping as ORM;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Doctrine\\Entity\\");
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
    String _firstUpper = StringExtensions.toFirstUpper(this.extensionClassType(it));
    return ("AbstractEntity" + _firstUpper);
  }
  
  /**
   * Returns the extension class description.
   */
  @Override
  public String extensionClassDescription(final Entity it) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Entity extension domain class storing " + _formatForDisplay);
    return (_plus + " attributes.");
  }
  
  /**
   * Returns the extension base class ORM annotations.
   */
  @Override
  public String extensionClassBaseAnnotations(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\ManyToOne(targetEntity=\"\\");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.append("\", inversedBy=\"attributes\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\JoinColumn(name=\"entityId\", referencedColumnName=\"");
    String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<DerivedField>head(this._modelExtensions.getPrimaryKeyFields(it)).getName());
    _builder.append(_formatForCode, " ");
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var \\");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $entity;");
    _builder.newLine();
    _builder.newLine();
    CharSequence _extensionClassEntityAccessors = this.extensionClassEntityAccessors(it);
    _builder.append(_extensionClassEntityAccessors);
    _builder.newLineIfNotEmpty();
    return _builder.toString();
  }
  
  /**
   * Returns the extension implementation class ORM annotations.
   */
  @Override
  public String extensionClassImplAnnotations(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("* @ORM\\Entity(repositoryClass=\"\\");
    String _repositoryClass = this.repositoryClass(it, this.extensionClassType(it));
    _builder.append(_repositoryClass);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\Table(name=\"");
    String _fullEntityTableName = this._modelExtensions.fullEntityTableName(it);
    _builder.append(_fullEntityTableName);
    _builder.append("_attribute\",");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*     uniqueConstraints={");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*         @ORM\\UniqueConstraint(name=\"cat_unq\", columns={\"name\", \"entityId\"})");
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
