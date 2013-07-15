package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.InheritanceRelationship;
import de.guite.modulestudio.metamodel.modulestudio.InheritanceStrategyType;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

/**
 * This class contains model inheritance related extension methods.
 */
@SuppressWarnings("all")
public class ModelInheritanceExtensions {
  /**
   * Checks if this entity has child relations, but no parent.
   */
  public boolean isTopSuperClass(final Entity it) {
    boolean _and = false;
    boolean _isInheriter = this.isInheriter(it);
    if (!_isInheriter) {
      _and = false;
    } else {
      boolean _isInheriting = this.isInheriting(it);
      boolean _not = (!_isInheriting);
      _and = (_isInheriter && _not);
    }
    return _and;
  }
  
  /**
   * Checks if this entity has a parent.
   */
  public boolean isInheriting(final Entity it) {
    EList<Relationship> _outgoing = it.getOutgoing();
    Iterable<InheritanceRelationship> _filter = Iterables.<InheritanceRelationship>filter(_outgoing, InheritanceRelationship.class);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns the relationship pointing to the parent.
   */
  public InheritanceRelationship getRelationToParentType(final Entity it) {
    EList<Relationship> _outgoing = it.getOutgoing();
    Iterable<InheritanceRelationship> _filter = Iterables.<InheritanceRelationship>filter(_outgoing, InheritanceRelationship.class);
    InheritanceRelationship _head = IterableExtensions.<InheritanceRelationship>head(_filter);
    return _head;
  }
  
  /**
   * Returns the parent entity.
   */
  public Entity parentType(final Entity it) {
    InheritanceRelationship _relationToParentType = this.getRelationToParentType(it);
    Entity _target = _relationToParentType.getTarget();
    return _target;
  }
  
  /**
   * Checks if this entity has at least one child.
   */
  public boolean isInheriter(final Entity it) {
    Iterable<InheritanceRelationship> _childRelations = this.getChildRelations(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_childRelations);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all child relationships.
   */
  public Iterable<InheritanceRelationship> getChildRelations(final Entity it) {
    EList<Relationship> _incoming = it.getIncoming();
    Iterable<InheritanceRelationship> _filter = Iterables.<InheritanceRelationship>filter(_incoming, InheritanceRelationship.class);
    return _filter;
  }
  
  /**
   * Prints an output string corresponding to the given inheritance type.
   */
  public String asConstant(final InheritanceStrategyType inheritanceType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(inheritanceType,InheritanceStrategyType.SINGLE_TABLE)) {
        _matched=true;
        _switchResult = "SINGLE_TABLE";
      }
    }
    if (!_matched) {
      if (Objects.equal(inheritanceType,InheritanceStrategyType.JOINED)) {
        _matched=true;
        _switchResult = "JOINED";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
}
