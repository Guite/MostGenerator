package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityIpTraceableType;
import de.guite.modulestudio.metamodel.StringField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.AbstractExtension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;

@SuppressWarnings("all")
public class IpTraceable extends AbstractExtension implements EntityExtensionInterface {
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
      if (((it instanceof StringField) && (!Objects.equal(((StringField) it).getIpTraceable(), EntityIpTraceableType.NONE)))) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\IpTraceable(on=\"");
        String _lowerCase = ((StringField) it).getIpTraceable().getLiteral().toLowerCase();
        _builder.append(_lowerCase);
        _builder.append("\"");
        CharSequence _ipTraceableDetails = this.ipTraceableDetails(((StringField) it));
        _builder.append(_ipTraceableDetails);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence ipTraceableDetails(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EntityIpTraceableType _ipTraceable = it.getIpTraceable();
      boolean _equals = Objects.equal(_ipTraceable, EntityIpTraceableType.CHANGE);
      if (_equals) {
        _builder.append(", field=\"");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getIpTraceableChangeTriggerField());
        _builder.append(_formatForCode);
        _builder.append("\"");
        {
          if (((null != it.getIpTraceableChangeTriggerValue()) && (!Objects.equal(it.getIpTraceableChangeTriggerValue(), "")))) {
            _builder.append(", value=\"");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getIpTraceableChangeTriggerValue());
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
