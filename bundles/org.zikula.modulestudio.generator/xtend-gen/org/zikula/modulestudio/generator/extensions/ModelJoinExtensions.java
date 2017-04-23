package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CascadeType;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.ManyToOneRelationship;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import de.guite.modulestudio.metamodel.OneToOneRelationship;
import de.guite.modulestudio.metamodel.RelationAutoCompletionUsage;
import de.guite.modulestudio.metamodel.Relationship;
import java.util.Arrays;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * This class contains model join relationship related extension methods.
 */
@SuppressWarnings("all")
public class ModelJoinExtensions {
  /**
   * Extensions used for formatting element names.
   */
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  /**
   * Extensions related to the model layer.
   */
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  /**
   * Returns the table name for a certain join side, including the application specific prefix.
   */
  public String fullJoinTableName(final JoinRelationship it, final Boolean useTarget, final DataObject joinedEntityForeign) {
    Application _xifexpression = null;
    if ((useTarget).booleanValue()) {
      _xifexpression = it.getTarget().getApplication();
    } else {
      _xifexpression = it.getSource().getApplication();
    }
    return this._modelExtensions.tableNameWithPrefix(_xifexpression, this.getJoinTableName(it, useTarget, joinedEntityForeign));
  }
  
  /**
   * Returns the table name for a certain join side.
   */
  private String getJoinTableName(final JoinRelationship it, final Boolean useTarget, final DataObject joinedEntityForeign) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof OneToManyRelationship) {
      if (useTarget) {
        _matched=true;
        String _formatForDB = this._formattingExtensions.formatForDB(((OneToManyRelationship)it).getSourceAlias());
        String _formatForDB_1 = this._formattingExtensions.formatForDB(((OneToManyRelationship)it).getTargetAlias());
        _switchResult = (_formatForDB + _formatForDB_1);
      }
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        _matched=true;
        String _formatForDB = this._formattingExtensions.formatForDB(((ManyToManyRelationship)it).getSource().getName());
        String _plus = (_formatForDB + "_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(((ManyToManyRelationship)it).getTarget().getName());
        _switchResult = (_plus + _formatForDB_1);
      }
    }
    if (!_matched) {
      _switchResult = this._formattingExtensions.formatForDB(joinedEntityForeign.getName());
    }
    return _switchResult;
  }
  
  /**
   * Returns a list of all join relations (excluding inheritance).
   */
  public Iterable<JoinRelationship> getJoinRelations(final Application it) {
    return Iterables.<JoinRelationship>filter(it.getRelations(), JoinRelationship.class);
  }
  
  /**
   * Returns a list of all outgoing join relations (excluding inheritance).
   */
  public Iterable<JoinRelationship> getOutgoingJoinRelations(final DataObject it) {
    return Iterables.<JoinRelationship>filter(it.getOutgoing(), JoinRelationship.class);
  }
  
  /**
   * Returns a list of all incoming join relations (excluding inheritance).
   */
  public Iterable<JoinRelationship> getIncomingJoinRelations(final DataObject it) {
    return Iterables.<JoinRelationship>filter(it.getIncoming(), JoinRelationship.class);
  }
  
  /**
   * Whether the application contains any relationships using auto completion.
   */
  public boolean needsAutoCompletion(final Application it) {
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      RelationAutoCompletionUsage _useAutoCompletion = it_1.getUseAutoCompletion();
      return Boolean.valueOf((!Objects.equal(_useAutoCompletion, RelationAutoCompletionUsage.NONE)));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getRelations(), JoinRelationship.class), _function));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all incoming bidirectional join relations.
   */
  public Iterable<JoinRelationship> getBidirectionalIncomingJoinRelations(final DataObject it) {
    final Function1<OneToOneRelationship, Boolean> _function = (OneToOneRelationship it_1) -> {
      return Boolean.valueOf(it_1.isBidirectional());
    };
    Iterable<OneToOneRelationship> _filter = IterableExtensions.<OneToOneRelationship>filter(Iterables.<OneToOneRelationship>filter(it.getIncoming(), OneToOneRelationship.class), _function);
    final Function1<OneToManyRelationship, Boolean> _function_1 = (OneToManyRelationship it_1) -> {
      return Boolean.valueOf(it_1.isBidirectional());
    };
    Iterable<OneToManyRelationship> _filter_1 = IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function_1);
    Iterable<JoinRelationship> _plus = Iterables.<JoinRelationship>concat(_filter, _filter_1);
    final Function1<ManyToManyRelationship, Boolean> _function_2 = (ManyToManyRelationship it_1) -> {
      return Boolean.valueOf(it_1.isBidirectional());
    };
    Iterable<ManyToManyRelationship> _filter_2 = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(it.getIncoming(), ManyToManyRelationship.class), _function_2);
    return Iterables.<JoinRelationship>concat(_plus, _filter_2);
  }
  
  /**
   * Returns a list of all incoming bidirectional join relations (excluding inheritance)
   * which are not nullable.
   */
  public Iterable<JoinRelationship> getBidirectionalIncomingAndMandatoryJoinRelations(final DataObject it) {
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      boolean _isNullable = it_1.isNullable();
      return Boolean.valueOf((!_isNullable));
    };
    return IterableExtensions.<JoinRelationship>filter(this.getBidirectionalIncomingJoinRelations(it), _function);
  }
  
  /**
   * Returns a list of all incoming join relations which are either one2one or one2many.
   */
  public Iterable<JoinRelationship> getIncomingJoinRelationsWithOneSource(final DataObject it) {
    Iterable<OneToOneRelationship> _filter = Iterables.<OneToOneRelationship>filter(it.getIncoming(), OneToOneRelationship.class);
    Iterable<OneToManyRelationship> _filter_1 = Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class);
    return Iterables.<JoinRelationship>concat(_filter, _filter_1);
  }
  
  /**
   * Returns a list of all incoming bidirectional join relations which are either one2one or one2many.
   */
  public Iterable<JoinRelationship> getBidirectionalIncomingJoinRelationsWithOneSource(final DataObject it) {
    final Function1<OneToOneRelationship, Boolean> _function = (OneToOneRelationship it_1) -> {
      return Boolean.valueOf(it_1.isBidirectional());
    };
    Iterable<OneToOneRelationship> _filter = IterableExtensions.<OneToOneRelationship>filter(Iterables.<OneToOneRelationship>filter(it.getIncoming(), OneToOneRelationship.class), _function);
    final Function1<OneToManyRelationship, Boolean> _function_1 = (OneToManyRelationship it_1) -> {
      return Boolean.valueOf(it_1.isBidirectional());
    };
    Iterable<OneToManyRelationship> _filter_1 = IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function_1);
    return Iterables.<JoinRelationship>concat(_filter, _filter_1);
  }
  
  /**
   * Returns a list of all incoming join relations which are either one2one, one2many or many2one.
   */
  public Iterable<JoinRelationship> getIncomingJoinRelationsWithoutManyToMany(final DataObject it) {
    Iterable<JoinRelationship> _incomingJoinRelationsWithOneSource = this.getIncomingJoinRelationsWithOneSource(it);
    Iterable<ManyToOneRelationship> _filter = Iterables.<ManyToOneRelationship>filter(it.getIncoming(), ManyToOneRelationship.class);
    return Iterables.<JoinRelationship>concat(_incomingJoinRelationsWithOneSource, _filter);
  }
  
  /**
   * Returns a list of all incoming bidirectional join relations (excluding inheritance)
   * which have the many cardinality on the source side and cascade persist active.
   */
  public Iterable<JoinRelationship> getIncomingJoinRelationsForCloning(final DataObject it) {
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      return Boolean.valueOf((this.isManySide(it_1, false) && this.hasCascadePersist(it_1)));
    };
    return IterableExtensions.<JoinRelationship>filter(this.getBidirectionalIncomingJoinRelations(it), _function);
  }
  
  /**
   * Returns a list of all outgoing join relations (excluding inheritance)
   * which have the many cardinality on the target side and cascade persist active.
   */
  public Iterable<JoinRelationship> getOutgoingJoinRelationsForCloning(final DataObject it) {
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      return Boolean.valueOf((this.isManySide(it_1, true) && this.hasCascadePersist(it_1)));
    };
    return IterableExtensions.<JoinRelationship>filter(this.getOutgoingJoinRelations(it), _function);
  }
  
  /**
   * Returns a list of all relationships for a given data object which should be included into editing.
   */
  public Iterable<JoinRelationship> getEditableJoinRelations(final DataObject it, final Boolean incoming) {
    Iterable<JoinRelationship> _xifexpression = null;
    if ((incoming).booleanValue()) {
      final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
        return Boolean.valueOf((Objects.equal(it_1.getSource().getApplication(), it_1.getApplication()) && (it_1.getSource() instanceof Entity)));
      };
      _xifexpression = IterableExtensions.<JoinRelationship>filter(this.getBidirectionalIncomingJoinRelations(it), _function);
    } else {
      final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship it_1) -> {
        return Boolean.valueOf((Objects.equal(it_1.getTarget().getApplication(), it_1.getApplication()) && (it_1.getTarget() instanceof Entity)));
      };
      _xifexpression = IterableExtensions.<JoinRelationship>filter(this.getOutgoingJoinRelations(it), _function_1);
    }
    return _xifexpression;
  }
  
  public boolean hasCascadePersist(final JoinRelationship it) {
    return CollectionLiterals.<Integer>newArrayList(
      Integer.valueOf(CascadeType.PERSIST_VALUE), 
      Integer.valueOf(CascadeType.PERSIST_REMOVE_VALUE), 
      Integer.valueOf(CascadeType.PERSIST_MERGE_VALUE), 
      Integer.valueOf(CascadeType.PERSIST_DETACH_VALUE), 
      Integer.valueOf(CascadeType.PERSIST_REMOVE_MERGE_VALUE), 
      Integer.valueOf(CascadeType.PERSIST_REMOVE_DETACH_VALUE), 
      Integer.valueOf(CascadeType.PERSIST_MERGE_DETACH_VALUE), 
      Integer.valueOf(CascadeType.ALL_VALUE)).contains(Integer.valueOf(it.getCascade().getValue()));
  }
  
  /**
   * Returns a list of all outgoing join relations which are either one2many or many2many.
   */
  public Iterable<JoinRelationship> getOutgoingCollections(final DataObject it) {
    Iterable<OneToManyRelationship> _filter = Iterables.<OneToManyRelationship>filter(it.getOutgoing(), OneToManyRelationship.class);
    Iterable<ManyToManyRelationship> _filter_1 = Iterables.<ManyToManyRelationship>filter(it.getOutgoing(), ManyToManyRelationship.class);
    return Iterables.<JoinRelationship>concat(_filter, _filter_1);
  }
  
  /**
   * Returns a list of all incoming join relations which are either many2one or many2many.
   */
  public Iterable<JoinRelationship> getIncomingCollections(final DataObject it) {
    Iterable<ManyToOneRelationship> _filter = Iterables.<ManyToOneRelationship>filter(it.getOutgoing(), ManyToOneRelationship.class);
    final Function1<ManyToManyRelationship, Boolean> _function = (ManyToManyRelationship it_1) -> {
      return Boolean.valueOf(it_1.isBidirectional());
    };
    Iterable<ManyToManyRelationship> _filter_1 = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(it.getIncoming(), ManyToManyRelationship.class), _function);
    return Iterables.<JoinRelationship>concat(_filter, _filter_1);
  }
  
  /**
   * Returns a list combining all outgoing join relations which are either one2many or many2many
   * with all incoming join relations which are either many2one or many2many.
   */
  public Iterable<JoinRelationship> getCollections(final DataObject it) {
    Iterable<JoinRelationship> _outgoingCollections = this.getOutgoingCollections(it);
    Iterable<JoinRelationship> _incomingCollections = this.getIncomingCollections(it);
    return Iterables.<JoinRelationship>concat(_outgoingCollections, _incomingCollections);
  }
  
  /**
   * Checks for whether the entity has outgoing join relations which are either one2many or many2many.
   */
  public boolean hasOutgoingCollections(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getOutgoingCollections(it));
    return (!_isEmpty);
  }
  
  /**
   * Checks for whether the entity has incoming join relations which are either many2one or many2many.
   */
  public boolean hasIncomingCollections(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getIncomingCollections(it));
    return (!_isEmpty);
  }
  
  /**
   * Checks for whether the entity has either outgoing join relations which are either
   * one2many or many2many, or incoming join relations which are either many2one or many2many.
   */
  public boolean hasCollections(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getCollections(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns unified name for relation fields. If we have id or fooid the function returns foo_id.
   * Otherwise it returns the actual field name of the referenced field.
   */
  public String relationFieldName(final DataObject it, final String refField) {
    String _xifexpression = null;
    boolean _isDefaultIdFieldName = this._modelExtensions.isDefaultIdFieldName(it, refField);
    if (_isDefaultIdFieldName) {
      String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
      _xifexpression = (_formatForDB + "_id");
    } else {
      String _elvis = null;
      final Function1<EntityField, Boolean> _function = (EntityField it_1) -> {
        String _name = it_1.getName();
        return Boolean.valueOf(Objects.equal(_name, refField));
      };
      EntityField _findFirst = IterableExtensions.<EntityField>findFirst(it.getFields(), _function);
      String _name = null;
      if (_findFirst!=null) {
        _name=_findFirst.getName();
      }
      String _formatForCode = null;
      if (_name!=null) {
        _formatForCode=this._formattingExtensions.formatForCode(_name);
      }
      if (_formatForCode != null) {
        _elvis = _formatForCode;
      } else {
        _elvis = "";
      }
      _xifexpression = _elvis;
    }
    return _xifexpression;
  }
  
  /**
   * Returns a concatenated list of all source fields.
   */
  public String[] getSourceFields(final JoinRelationship it) {
    return it.getSourceField().split(", ");
  }
  
  /**
   * Returns a concatenated list of all target fields.
   */
  public String[] getTargetFields(final JoinRelationship it) {
    return it.getTargetField().split(", ");
  }
  
  /**
   * Checks for whether a certain relationship side has a multiplicity of one or many.
   */
  public boolean isManySide(final JoinRelationship it, final boolean useTarget) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (it instanceof OneToOneRelationship) {
      _matched=true;
      _switchResult = false;
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        _matched=true;
        _switchResult = useTarget;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        _matched=true;
        _switchResult = (!useTarget);
      }
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  /**
   * Checks for whether a certain relationship side has a multiplicity of one or many.
   * Special version used in view.pagecomponents.Relations to decide about template visibility.
   */
  public boolean isManySideDisplay(final JoinRelationship it, final boolean useTarget) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (it instanceof OneToOneRelationship) {
      _matched=true;
      _switchResult = false;
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        _matched=true;
        _switchResult = useTarget;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  /**
   * Returns a unique name for a relationship used by JavaScript during editing entities with auto completion fields.
   * The name is concatenated from the edited entity as well as the relation alias name.
   */
  public String getUniqueRelationNameForJs(final JoinRelationship it, final Application app, final DataObject targetEntity, final Boolean many, final Boolean incoming, final String relationAliasName) {
    String _prefix = app.getPrefix();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(targetEntity.getName());
    String _plus = (_prefix + _formatForCodeCapital);
    String _plus_1 = (_plus + "_");
    return (_plus_1 + relationAliasName);
  }
  
  /**
   * Returns a constant for the multiplicity of the target side of a join relationship.
   */
  public String getTargetMultiplicity(final JoinRelationship it, final Boolean useTarget) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof OneToOneRelationship) {
      _matched=true;
      _switchResult = "One";
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        _matched=true;
        String _xifexpression = null;
        if ((!(useTarget).booleanValue())) {
          _xifexpression = "One";
        } else {
          _xifexpression = "Many";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        _matched=true;
        String _xifexpression = null;
        if ((!(useTarget).booleanValue())) {
          _xifexpression = "Many";
        } else {
          _xifexpression = "One";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      _switchResult = "Many";
    }
    return _switchResult;
  }
  
  /**
   * Checks for whether a certain relationship side has a multiplicity of one or many.
   */
  public boolean usesAutoCompletion(final JoinRelationship it, final boolean useTarget) {
    boolean _switchResult = false;
    RelationAutoCompletionUsage _useAutoCompletion = it.getUseAutoCompletion();
    if (_useAutoCompletion != null) {
      switch (_useAutoCompletion) {
        case NONE:
          _switchResult = false;
          break;
        case ONLY_SOURCE_SIDE:
          _switchResult = (!useTarget);
          break;
        case ONLY_TARGET_SIDE:
          _switchResult = useTarget;
          break;
        case BOTH_SIDES:
          _switchResult = true;
          break;
        default:
          _switchResult = false;
          break;
      }
    } else {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  /**
   * Checks whether the entity is target of an indexed relationship.
   * That is true if at least one incoming relation has an indexBy field set.
   */
  public boolean isIndexByTarget(final DataObject it) {
    final Function1<Relationship, Boolean> _function = (Relationship it_1) -> {
      return Boolean.valueOf(((null != this.getIndexByField(it_1)) && (!Objects.equal(this.getIndexByField(it_1), ""))));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Relationship>filter(it.getIncoming(), _function));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether this field is used by an indexed relationship.
   * That is true if at least one incoming relation of it's entity has an indexBy field set to it's name.
   */
  public boolean isIndexByField(final DerivedField it) {
    final Function1<Relationship, Boolean> _function = (Relationship e) -> {
      String _indexByField = this.getIndexByField(e);
      String _name = it.getName();
      return Boolean.valueOf(Objects.equal(_indexByField, _name));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Relationship>filter(it.getEntity().getIncoming(), _function));
    return (!_isEmpty);
  }
  
  /**
   * Returns if the relationship is an indexed relation or not.
   */
  public boolean isIndexed(final Relationship it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (it instanceof OneToManyRelationship) {
      _matched=true;
      _switchResult = ((null != ((OneToManyRelationship)it).getIndexBy()) && (!Objects.equal(((OneToManyRelationship)it).getIndexBy(), "")));
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        _matched=true;
        _switchResult = ((null != ((ManyToManyRelationship)it).getIndexBy()) && (!Objects.equal(((ManyToManyRelationship)it).getIndexBy(), "")));
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  /**
   * Returns the name of the index field.
   */
  public String getIndexByField(final Relationship it) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof OneToManyRelationship) {
      _matched=true;
      _switchResult = ((OneToManyRelationship)it).getIndexBy();
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        _matched=true;
        _switchResult = ((ManyToManyRelationship)it).getIndexBy();
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Returns the outgoing one2many relationship using this field as aggregate.
   */
  public OneToManyRelationship getAggregateRelationship(final IntegerField it) {
    OneToManyRelationship _xblockexpression = null;
    {
      final String[] aggregateDetails = it.getAggregateFor().split("#");
      final Function1<OneToManyRelationship, Boolean> _function = (OneToManyRelationship it_1) -> {
        return Boolean.valueOf((it_1.isBidirectional() && Objects.equal(it_1.getTargetAlias(), IterableExtensions.<Object>head(((Iterable<Object>)Conversions.doWrapArray(aggregateDetails))))));
      };
      _xblockexpression = IterableExtensions.<OneToManyRelationship>findFirst(Iterables.<OneToManyRelationship>filter(it.getEntity().getOutgoing(), OneToManyRelationship.class), _function);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the target entity of the outgoing one2many relationship using this field as aggregate.
   */
  public DataObject getAggregateTargetEntity(final IntegerField it) {
    return this.getAggregateRelationship(it).getTarget();
  }
  
  /**
   * Returns the target field of the outgoing one2many relationship using this field as aggregate.
   */
  protected DerivedField _getAggregateTargetField(final DerivedField it) {
    return null;
  }
  
  /**
   * Returns the target field of the outgoing one2many relationship using this field as aggregate.
   */
  protected DerivedField _getAggregateTargetField(final IntegerField it) {
    DerivedField _xblockexpression = null;
    {
      final String[] aggregateDetails = it.getAggregateFor().split("#");
      final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
        String _name = it_1.getName();
        Object _get = aggregateDetails[1];
        return Boolean.valueOf(Objects.equal(_name, _get));
      };
      _xblockexpression = IterableExtensions.<DerivedField>findFirst(Iterables.<DerivedField>filter(this.getAggregateTargetEntity(it).getFields(), DerivedField.class), _function);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all incoming relationships aggregating this field.
   */
  public Iterable<OneToManyRelationship> getAggregatingRelationships(final DerivedField it) {
    final Function1<OneToManyRelationship, Boolean> _function = (OneToManyRelationship it_1) -> {
      boolean _isEmpty = IterableExtensions.isEmpty(this._modelExtensions.getAggregateFields(it_1.getSource()));
      return Boolean.valueOf((!_isEmpty));
    };
    final Function1<OneToManyRelationship, Boolean> _function_1 = (OneToManyRelationship it_1) -> {
      final Function1<IntegerField, Boolean> _function_2 = (IntegerField it_2) -> {
        DerivedField _aggregateTargetField = this.getAggregateTargetField(it_2);
        return Boolean.valueOf(Objects.equal(_aggregateTargetField, it_2));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<IntegerField>filter(this._modelExtensions.getAggregateFields(it_1.getSource()), _function_2));
      return Boolean.valueOf((!_isEmpty));
    };
    return IterableExtensions.<OneToManyRelationship>filter(IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getEntity().getIncoming(), OneToManyRelationship.class), _function), _function_1);
  }
  
  /**
   * Returns a list of all incoming relationships aggregating any fields of this entity.
   */
  public Iterable<DerivedField> getAggregators(final DataObject it) {
    final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
      boolean _isEmpty = IterableExtensions.isEmpty(this.getAggregatingRelationships(it_1));
      return Boolean.valueOf((!_isEmpty));
    };
    return IterableExtensions.<DerivedField>filter(this._modelExtensions.getDerivedFields(it), _function);
  }
  
  /**
   * Checks whether there is at least one field used as aggregate field.
   */
  public boolean isAggregated(final DataObject it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getAggregators(it));
    return (!_isEmpty);
  }
  
  public DerivedField getAggregateTargetField(final DerivedField it) {
    if (it instanceof IntegerField) {
      return _getAggregateTargetField((IntegerField)it);
    } else if (it != null) {
      return _getAggregateTargetField(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
