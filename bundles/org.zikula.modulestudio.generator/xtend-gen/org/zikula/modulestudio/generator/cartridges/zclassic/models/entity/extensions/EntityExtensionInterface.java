package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtext.generator.IFileSystemAccess;

@SuppressWarnings("all")
public interface EntityExtensionInterface {
  /**
   * Generates additional annotations on class level.
   */
  public abstract CharSequence classAnnotations(final Entity it);
  
  /**
   * Additional field annotations.
   */
  public abstract CharSequence columnAnnotations(final DerivedField it);
  
  /**
   * Generates additional entity properties.
   */
  public abstract CharSequence properties(final Entity it);
  
  /**
   * Generates additional accessor methods.
   */
  public abstract CharSequence accessors(final Entity it);
  
  /**
   * Generates separate extension classes.
   */
  public abstract void extensionClasses(final Entity it, final IFileSystemAccess fsa);
  
  /**
   * Returns the extension class type.
   */
  public abstract String extensionClassType(final Entity it);
  
  /**
   * Returns the extension class import statements.
   */
  public abstract String extensionClassImports(final Entity it);
  
  /**
   * Returns the extension base class.
   */
  public abstract String extensionBaseClass(final Entity it);
  
  /**
   * Returns the extension class description.
   */
  public abstract String extensionClassDescription(final Entity it);
  
  /**
   * Returns the extension base class ORM annotations.
   */
  public abstract String extensionClassBaseAnnotations(final Entity it);
  
  /**
   * Returns the extension implementation class ORM annotations.
   */
  public abstract String extensionClassImplAnnotations(final Entity it);
}
