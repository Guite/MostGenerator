package org.zikula.modulestudio.generator.extensions;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.InheritanceRelationship;
import java.util.ArrayList;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

/**
 * This class contains model inheritance related extension methods.
 */
@SuppressWarnings("all")
public class ModelInheritanceExtensions {
  /**
   * Checks if this entity has child relations, but no parent.
   */
  public boolean isTopSuperClass(final DataObject it) {
    return (this.isInheriter(it) && (!this.isInheriting(it)));
  }
  
  /**
   * Checks if this entity has a parent.
   */
  public boolean isInheriting(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<InheritanceRelationship>filter(it.getOutgoing(), InheritanceRelationship.class));
    return (!_isEmpty);
  }
  
  /**
   * Returns the relationship pointing to the parent.
   */
  public InheritanceRelationship getRelationToParentType(final DataObject it) {
    return IterableExtensions.<InheritanceRelationship>head(Iterables.<InheritanceRelationship>filter(it.getOutgoing(), InheritanceRelationship.class));
  }
  
  /**
   * Returns the parent entity.
   */
  public DataObject parentType(final DataObject it) {
    return this.getRelationToParentType(it).getTarget();
  }
  
  /**
   * Checks if this entity has at least one child.
   */
  public boolean isInheriter(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getChildRelations(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all child relationships.
   */
  public Iterable<InheritanceRelationship> getChildRelations(final DataObject it) {
    return Iterables.<InheritanceRelationship>filter(it.getIncoming(), InheritanceRelationship.class);
  }
  
  /**
   * Returns a list of all inheriting entities.
   */
  public ArrayList<Entity> getInheritingEntities(final DataObject it) {
    ArrayList<Entity> _xblockexpression = null;
    {
      ArrayList<Entity> children = CollectionLiterals.<Entity>newArrayList();
      Iterable<InheritanceRelationship> _childRelations = this.getChildRelations(it);
      for (final InheritanceRelationship child : _childRelations) {
        {
          final DataObject entity = child.getSource();
          boolean _contains = children.contains(entity);
          boolean _not = (!_contains);
          if (_not) {
            children.add(((Entity) entity));
            ArrayList<Entity> _inheritingEntities = this.getInheritingEntities(entity);
            Iterables.<Entity>addAll(children, _inheritingEntities);
          }
        }
      }
      _xblockexpression = children;
    }
    return _xblockexpression;
  }
}
