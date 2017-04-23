package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import de.guite.modulestudio.metamodel.AbstractIntegerField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.AbstractExtension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;

@SuppressWarnings("all")
public class Sortable extends AbstractExtension implements EntityExtensionInterface {
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
      boolean _isSortableGroup = it.isSortableGroup();
      if (_isSortableGroup) {
        _builder.append(" * @Gedmo\\SortableGroup");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (((it instanceof AbstractIntegerField) && ((AbstractIntegerField) it).isSortablePosition())) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\SortablePosition");
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
}
