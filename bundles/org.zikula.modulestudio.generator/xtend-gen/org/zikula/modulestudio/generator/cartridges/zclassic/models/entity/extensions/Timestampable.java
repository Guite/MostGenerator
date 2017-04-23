package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTimestampableType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.AbstractExtension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;

@SuppressWarnings("all")
public class Timestampable extends AbstractExtension implements EntityExtensionInterface {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
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
    {
      if (((it instanceof AbstractDateField) && (!Objects.equal(((AbstractDateField) it).getTimestampable(), EntityTimestampableType.NONE)))) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Timestampable(on=\"");
        String _lowerCase = ((AbstractDateField) it).getTimestampable().getLiteral().toLowerCase();
        _builder.append(_lowerCase);
        _builder.append("\"");
        CharSequence _timestampableDetails = this.timestampableDetails(((AbstractDateField) it));
        _builder.append(_timestampableDetails);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence timestampableDetails(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EntityTimestampableType _timestampable = it.getTimestampable();
      boolean _equals = Objects.equal(_timestampable, EntityTimestampableType.CHANGE);
      if (_equals) {
        _builder.append(", field=\"");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getTimestampableChangeTriggerField());
        _builder.append(_formatForCode);
        _builder.append("\"");
        {
          if (((null != it.getTimestampableChangeTriggerValue()) && (!Objects.equal(it.getTimestampableChangeTriggerValue(), "")))) {
            _builder.append(", value=\"");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getTimestampableChangeTriggerValue());
            _builder.append(_formatForCode_1);
            _builder.append("\"");
          }
        }
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
}
