package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import de.guite.modulestudio.metamodel.AbstractStringField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.AbstractExtension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;

@SuppressWarnings("all")
public class Sluggable extends AbstractExtension implements EntityExtensionInterface {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
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
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatableSlug = this._modelBehaviourExtensions.hasTranslatableSlug(it);
      if (_hasTranslatableSlug) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Translatable");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @Gedmo\\Slug(fields={");
    {
      List<AbstractStringField> _sluggableFields = this._modelBehaviourExtensions.getSluggableFields(it);
      boolean _hasElements = false;
      for(final AbstractStringField field : _sluggableFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", " ");
        }
        _builder.append("\"");
        String _formatForCode = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode, " ");
        _builder.append("\"");
      }
    }
    _builder.append("}, updatable=");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isSlugUpdatable()));
    _builder.append(_displayBool, " ");
    _builder.append(", unique=");
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(it.isSlugUnique()));
    _builder.append(_displayBool_1, " ");
    _builder.append(", separator=\"");
    String _slugSeparator = it.getSlugSeparator();
    _builder.append(_slugSeparator, " ");
    _builder.append("\", style=\"");
    String _slugStyleAsConstant = this._modelBehaviourExtensions.slugStyleAsConstant(it.getSlugStyle());
    _builder.append(_slugStyleAsConstant, " ");
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"string\", length=");
    int _slugLength = it.getSlugLength();
    _builder.append(_slugLength, " ");
    _builder.append(", unique=");
    String _displayBool_2 = this._formattingExtensions.displayBool(Boolean.valueOf(it.isSlugUnique()));
    _builder.append(_displayBool_2, " ");
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Length(min=\"1\", max=\"");
    int _slugLength_1 = it.getSlugLength();
    _builder.append(_slugLength_1, " ");
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var string $slug");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $slug;");
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
    CharSequence _terAndSetterMethods = fh.getterAndSetterMethods(it, "slug", "string", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
