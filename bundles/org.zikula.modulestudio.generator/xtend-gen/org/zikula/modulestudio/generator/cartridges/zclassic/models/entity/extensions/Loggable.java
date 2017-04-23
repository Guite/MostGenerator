package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.ObjectField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.AbstractExtension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Loggable extends AbstractExtension implements EntityExtensionInterface {
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
    _builder.append("* @Gedmo\\Loggable(logEntryClass=\"\\");
    String _entityClassName = this._namingExtensions.entityClassName(it, "logEntry", Boolean.valueOf(false));
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
      if ((((it.getEntity() instanceof Entity) && ((Entity) it.getEntity()).isLoggable()) && (!(it instanceof ObjectField)))) {
        _builder.append(" * @Gedmo\\Versioned");
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
    return _builder;
  }
  
  /**
   * Generates additional accessor methods.
   */
  @Override
  public CharSequence accessors(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  /**
   * Returns the extension class type.
   */
  @Override
  public String extensionClassType(final Entity it) {
    return "logEntry";
  }
  
  /**
   * Returns the extension class import statements.
   */
  @Override
  public String extensionClassImports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use Gedmo\\Loggable\\Entity\\MappedSuperclass\\");
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
    return "AbstractLogEntry";
  }
  
  /**
   * Returns the extension class description.
   */
  @Override
  public String extensionClassDescription(final Entity it) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Entity extension domain class storing " + _formatForDisplay);
    return (_plus + " log entries.");
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
    _builder.append("_log_entry\",");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*     indexes={");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*         @ORM\\Index(name=\"log_class_lookup_idx\", columns={\"object_class\"}),");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*         @ORM\\Index(name=\"log_date_lookup_idx\", columns={\"logged_at\"}),");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*         @ORM\\Index(name=\"log_user_lookup_idx\", columns={\"username\"})");
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
