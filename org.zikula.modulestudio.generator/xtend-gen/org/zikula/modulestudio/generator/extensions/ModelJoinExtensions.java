package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ManyToOneRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship;
import de.guite.modulestudio.metamodel.modulestudio.RelationAutoCompletionUsage;
import de.guite.modulestudio.metamodel.modulestudio.RelationFetchType;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
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
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  /**
   * Extensions related to the model layer.
   */
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  /**
   * Returns the table name for a certain join side, including the application specific prefix.
   */
  public String fullJoinTableName(final JoinRelationship it, final Boolean useTarget, final Entity joinedEntityForeign) {
    Application _xifexpression = null;
    if ((useTarget).booleanValue()) {
      Entity _target = it.getTarget();
      Models _container = _target.getContainer();
      Application _application = _container.getApplication();
      _xifexpression = _application;
    } else {
      Entity _source = it.getSource();
      Models _container_1 = _source.getContainer();
      Application _application_1 = _container_1.getApplication();
      _xifexpression = _application_1;
    }
    String _joinTableName = this.getJoinTableName(it, useTarget, joinedEntityForeign);
    String _tableNameWithPrefix = this._modelExtensions.tableNameWithPrefix(_xifexpression, _joinTableName);
    return _tableNameWithPrefix;
  }
  
  /**
   * Returns the table name for a certain join side.
   */
  private String getJoinTableName(final JoinRelationship it, final Boolean useTarget, final Entity joinedEntityForeign) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        final OneToManyRelationship _oneToManyRelationship = (OneToManyRelationship)it;
        if (useTarget) {
          _matched=true;
          String _sourceAlias = _oneToManyRelationship.getSourceAlias();
          String _formatForDB = this._formattingExtensions.formatForDB(_sourceAlias);
          String _targetAlias = _oneToManyRelationship.getTargetAlias();
          String _formatForDB_1 = this._formattingExtensions.formatForDB(_targetAlias);
          String _plus = (_formatForDB + _formatForDB_1);
          _switchResult = _plus;
        }
      }
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        final ManyToManyRelationship _manyToManyRelationship = (ManyToManyRelationship)it;
        _matched=true;
        Entity _source = _manyToManyRelationship.getSource();
        String _name = _source.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name);
        String _plus = (_formatForDB + "_");
        Entity _target = _manyToManyRelationship.getTarget();
        String _name_1 = _target.getName();
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_1);
        String _plus_1 = (_plus + _formatForDB_1);
        _switchResult = _plus_1;
      }
    }
    if (!_matched) {
      String _name = joinedEntityForeign.getName();
      String _formatForDB = this._formattingExtensions.formatForDB(_name);
      _switchResult = _formatForDB;
    }
    return _switchResult;
  }
  
  /**
   * Returns a list of all join relations (excluding inheritance).
   */
  public Iterable<JoinRelationship> getJoinRelations(final Application it) {
    Iterable<JoinRelationship> _xblockexpression = null;
    {
      EList<Models> _models = it.getModels();
      Models _head = IterableExtensions.<Models>head(_models);
      Iterable<JoinRelationship> relations = this.getJoinRelations(_head);
      EList<Models> _models_1 = it.getModels();
      int _size = _models_1.size();
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        EList<Models> _models_2 = it.getModels();
        Iterable<Models> _tail = IterableExtensions.<Models>tail(_models_2);
        for (final Models model : _tail) {
          Iterable<JoinRelationship> _joinRelations = this.getJoinRelations(model);
          Iterable<JoinRelationship> _plus = Iterables.<JoinRelationship>concat(relations, _joinRelations);
          relations = _plus;
        }
      }
      _xblockexpression = (relations);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all join relations (excluding inheritance).
   */
  public Iterable<JoinRelationship> getJoinRelations(final Models it) {
    EList<Relationship> _relations = it.getRelations();
    Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_relations, JoinRelationship.class);
    return _filter;
  }
  
  /**
   * Returns a list of all outgoing join relations (excluding inheritance).
   */
  public Iterable<JoinRelationship> getOutgoingJoinRelations(final Entity it) {
    EList<Relationship> _outgoing = it.getOutgoing();
    Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_outgoing, JoinRelationship.class);
    return _filter;
  }
  
  /**
   * Returns a list of all incoming join relations (excluding inheritance).
   */
  public Iterable<JoinRelationship> getIncomingJoinRelations(final Entity it) {
    EList<Relationship> _incoming = it.getIncoming();
    Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
    return _filter;
  }
  
  /**
   * Returns a list of all incoming bidirectional join relations (excluding inheritance).
   */
  public Iterable<JoinRelationship> getBidirectionalIncomingJoinRelations(final Entity it) {
    Iterable<JoinRelationship> _incomingJoinRelations = this.getIncomingJoinRelations(it);
    final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
      public Boolean apply(final JoinRelationship it) {
        boolean _isBidirectional = it.isBidirectional();
        return Boolean.valueOf(_isBidirectional);
      }
    };
    Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_incomingJoinRelations, _function);
    return _filter;
  }
  
  /**
   * Returns a list of all incoming join relations which are either one2one or one2many.
   */
  public Iterable<JoinRelationship> getIncomingJoinRelationsWithOneSource(final Entity it) {
    EList<Relationship> _incoming = it.getIncoming();
    Iterable<OneToOneRelationship> _filter = Iterables.<OneToOneRelationship>filter(_incoming, OneToOneRelationship.class);
    EList<Relationship> _incoming_1 = it.getIncoming();
    Iterable<OneToManyRelationship> _filter_1 = Iterables.<OneToManyRelationship>filter(_incoming_1, OneToManyRelationship.class);
    Iterable<JoinRelationship> _plus = Iterables.<JoinRelationship>concat(_filter, _filter_1);
    return _plus;
  }
  
  /**
   * Returns a list of all incoming bidirectional join relations which are either one2one or one2many.
   */
  public Iterable<JoinRelationship> getBidirectionalIncomingJoinRelationsWithOneSource(final Entity it) {
    Iterable<JoinRelationship> _incomingJoinRelationsWithOneSource = this.getIncomingJoinRelationsWithOneSource(it);
    final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
      public Boolean apply(final JoinRelationship it) {
        boolean _isBidirectional = it.isBidirectional();
        return Boolean.valueOf(_isBidirectional);
      }
    };
    Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_incomingJoinRelationsWithOneSource, _function);
    return _filter;
  }
  
  /**
   * Returns a list of all incoming join relations which are either one2one, one2many or many2one.
   */
  public Iterable<JoinRelationship> getIncomingJoinRelationsWithoutManyToMany(final Entity it) {
    Iterable<JoinRelationship> _incomingJoinRelationsWithOneSource = this.getIncomingJoinRelationsWithOneSource(it);
    EList<Relationship> _incoming = it.getIncoming();
    Iterable<ManyToOneRelationship> _filter = Iterables.<ManyToOneRelationship>filter(_incoming, ManyToOneRelationship.class);
    Iterable<JoinRelationship> _plus = Iterables.<JoinRelationship>concat(_incomingJoinRelationsWithOneSource, _filter);
    return _plus;
  }
  
  /**
   * Returns a list of all outgoing join relations which are either one2many or many2many.
   */
  public Iterable<JoinRelationship> getOutgoingCollections(final Entity it) {
    EList<Relationship> _outgoing = it.getOutgoing();
    Iterable<OneToManyRelationship> _filter = Iterables.<OneToManyRelationship>filter(_outgoing, OneToManyRelationship.class);
    EList<Relationship> _outgoing_1 = it.getOutgoing();
    Iterable<ManyToManyRelationship> _filter_1 = Iterables.<ManyToManyRelationship>filter(_outgoing_1, ManyToManyRelationship.class);
    Iterable<JoinRelationship> _plus = Iterables.<JoinRelationship>concat(_filter, _filter_1);
    return _plus;
  }
  
  /**
   * Returns a list of all incoming join relations which are either many2one or many2many.
   */
  public Iterable<JoinRelationship> getIncomingCollections(final Entity it) {
    EList<Relationship> _outgoing = it.getOutgoing();
    Iterable<ManyToOneRelationship> _filter = Iterables.<ManyToOneRelationship>filter(_outgoing, ManyToOneRelationship.class);
    EList<Relationship> _incoming = it.getIncoming();
    Iterable<ManyToManyRelationship> _filter_1 = Iterables.<ManyToManyRelationship>filter(_incoming, ManyToManyRelationship.class);
    Iterable<JoinRelationship> _plus = Iterables.<JoinRelationship>concat(_filter, _filter_1);
    final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
      public Boolean apply(final JoinRelationship it) {
        boolean _isBidirectional = it.isBidirectional();
        return Boolean.valueOf(_isBidirectional);
      }
    };
    Iterable<JoinRelationship> _filter_2 = IterableExtensions.<JoinRelationship>filter(_plus, _function);
    return _filter_2;
  }
  
  /**
   * Returns a list combining all outgoing join relations which are either one2many or many2many
   * with all incoming join relations which are either many2one or many2many.
   */
  public Iterable<JoinRelationship> getCollections(final Entity it) {
    Iterable<JoinRelationship> _outgoingCollections = this.getOutgoingCollections(it);
    Iterable<JoinRelationship> _incomingCollections = this.getIncomingCollections(it);
    Iterable<JoinRelationship> _plus = Iterables.<JoinRelationship>concat(_outgoingCollections, _incomingCollections);
    return _plus;
  }
  
  /**
   * Checks for whether the entity has outgoing join relations which are either one2many or many2many.
   */
  public boolean hasOutgoingCollections(final Entity it) {
    Iterable<JoinRelationship> _outgoingCollections = this.getOutgoingCollections(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_outgoingCollections);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Checks for whether the entity has incoming join relations which are either many2one or many2many.
   */
  public boolean hasIncomingCollections(final Entity it) {
    Iterable<JoinRelationship> _incomingCollections = this.getIncomingCollections(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_incomingCollections);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Checks for whether the entity has either outgoing join relations which are either
   * one2many or many2many, or incoming join relations which are either many2one or many2many.
   */
  public boolean hasCollections(final Entity it) {
    Iterable<JoinRelationship> _collections = this.getCollections(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_collections);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns unified name for relation fields. If we have id or fooid the function returns foo_id.
   * Otherwise it returns the actual field name of the referenced field.
   */
  public String relationFieldName(final Entity it, final String refField) {
    String _xifexpression = null;
    boolean _isDefaultIdFieldName = this._modelExtensions.isDefaultIdFieldName(it, refField);
    if (_isDefaultIdFieldName) {
      String _name = it.getName();
      String _formatForDB = this._formattingExtensions.formatForDB(_name);
      String _plus = (_formatForDB + "_id");
      _xifexpression = _plus;
    } else {
      String _elvis = null;
      EList<EntityField> _fields = it.getFields();
      final Function1<EntityField,Boolean> _function = new Function1<EntityField,Boolean>() {
        public Boolean apply(final EntityField it) {
          String _name = it.getName();
          boolean _equals = Objects.equal(_name, refField);
          return Boolean.valueOf(_equals);
        }
      };
      EntityField _findFirst = IterableExtensions.<EntityField>findFirst(_fields, _function);
      String _name_1 = null;
      if (_findFirst!=null) {
        _name_1=_findFirst.getName();
      }
      String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
      if (_formatForCode != null) {
        _elvis = _formatForCode;
      } else {
        _elvis = ObjectExtensions.<String>operator_elvis(_formatForCode, "");
      }
      _xifexpression = _elvis;
    }
    return _xifexpression;
  }
  
  /**
   * Returns a concatenated list of all source fields.
   */
  public String[] getSourceFields(final JoinRelationship it) {
    String _sourceField = it.getSourceField();
    String[] _split = _sourceField.split(", ");
    return _split;
  }
  
  /**
   * Returns a concatenated list of all target fields.
   */
  public String[] getTargetFields(final JoinRelationship it) {
    String _targetField = it.getTargetField();
    String[] _split = _targetField.split(", ");
    return _split;
  }
  
  /**
   * Checks for whether a certain relationship side has a multiplicity of one or many.
   */
  public boolean isManySide(final JoinRelationship it, final boolean useTarget) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToOneRelationship) {
        final OneToOneRelationship _oneToOneRelationship = (OneToOneRelationship)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        final OneToManyRelationship _oneToManyRelationship = (OneToManyRelationship)it;
        _matched=true;
        _switchResult = useTarget;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        final ManyToOneRelationship _manyToOneRelationship = (ManyToOneRelationship)it;
        _matched=true;
        boolean _not = (!useTarget);
        _switchResult = _not;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        final ManyToManyRelationship _manyToManyRelationship = (ManyToManyRelationship)it;
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
    if (!_matched) {
      if (it instanceof OneToOneRelationship) {
        final OneToOneRelationship _oneToOneRelationship = (OneToOneRelationship)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        final OneToManyRelationship _oneToManyRelationship = (OneToManyRelationship)it;
        _matched=true;
        _switchResult = useTarget;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        final ManyToOneRelationship _manyToOneRelationship = (ManyToOneRelationship)it;
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        final ManyToManyRelationship _manyToManyRelationship = (ManyToManyRelationship)it;
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
  public String getUniqueRelationNameForJs(final JoinRelationship it, final Application app, final Entity targetEntity, final Boolean many, final Boolean incoming, final String relationAliasName) {
    String _prefix = app.getPrefix();
    String _name = targetEntity.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
    String _plus = (_prefix + _formatForCodeCapital);
    String _plus_1 = (_plus + "_");
    String _plus_2 = (_plus_1 + relationAliasName);
    return _plus_2;
  }
  
  /**
   * Returns a constant for the multiplicity of the target side of a join relationship.
   */
  public String getTargetMultiplicity(final JoinRelationship it, final Boolean useTarget) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToOneRelationship) {
        final OneToOneRelationship _oneToOneRelationship = (OneToOneRelationship)it;
        _matched=true;
        _switchResult = "One";
      }
    }
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        final OneToManyRelationship _oneToManyRelationship = (OneToManyRelationship)it;
        _matched=true;
        String _xifexpression = null;
        boolean _not = (!(useTarget).booleanValue());
        if (_not) {
          _xifexpression = "One";
        } else {
          _xifexpression = "Many";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToOneRelationship) {
        final ManyToOneRelationship _manyToOneRelationship = (ManyToOneRelationship)it;
        _matched=true;
        String _xifexpression = null;
        boolean _not = (!(useTarget).booleanValue());
        if (_not) {
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
    final RelationAutoCompletionUsage _switchValue = _useAutoCompletion;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(_switchValue,RelationAutoCompletionUsage.NONE)) {
        _matched=true;
        _switchResult = false;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,RelationAutoCompletionUsage.ONLY_SOURCE_SIDE)) {
        _matched=true;
        boolean _not = (!useTarget);
        _switchResult = _not;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,RelationAutoCompletionUsage.ONLY_TARGET_SIDE)) {
        _matched=true;
        _switchResult = useTarget;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,RelationAutoCompletionUsage.BOTH_SIDES)) {
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
   * Checks whether the entity is target of an indexed relationship.
   * That is true if at least one incoming relation has an indexBy field set.
   */
  public boolean isIndexByTarget(final Entity it) {
    EList<Relationship> _incoming = it.getIncoming();
    final Function1<Relationship,Boolean> _function = new Function1<Relationship,Boolean>() {
      public Boolean apply(final Relationship it) {
        boolean _and = false;
        String _indexByField = ModelJoinExtensions.this.getIndexByField(it);
        boolean _tripleNotEquals = (_indexByField != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _indexByField_1 = ModelJoinExtensions.this.getIndexByField(it);
          boolean _notEquals = (!Objects.equal(_indexByField_1, ""));
          _and = (_tripleNotEquals && _notEquals);
        }
        return Boolean.valueOf(_and);
      }
    };
    Iterable<Relationship> _filter = IterableExtensions.<Relationship>filter(_incoming, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Checks whether this field is used by an indexed relationship.
   * That is true if at least one incoming relation of it's entity has an indexBy field set to it's name.
   */
  public boolean isIndexByField(final DerivedField it) {
    Entity _entity = it.getEntity();
    EList<Relationship> _incoming = _entity.getIncoming();
    final Function1<Relationship,Boolean> _function = new Function1<Relationship,Boolean>() {
      public Boolean apply(final Relationship e) {
        String _indexByField = ModelJoinExtensions.this.getIndexByField(e);
        String _name = it.getName();
        boolean _equals = Objects.equal(_indexByField, _name);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<Relationship> _filter = IterableExtensions.<Relationship>filter(_incoming, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns if the relationship is an indexed relation or not.
   */
  public boolean isIndexed(final Relationship it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        final OneToManyRelationship _oneToManyRelationship = (OneToManyRelationship)it;
        _matched=true;
        boolean _and = false;
        String _indexBy = _oneToManyRelationship.getIndexBy();
        boolean _tripleNotEquals = (_indexBy != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _indexBy_1 = _oneToManyRelationship.getIndexBy();
          boolean _notEquals = (!Objects.equal(_indexBy_1, ""));
          _and = (_tripleNotEquals && _notEquals);
        }
        _switchResult = _and;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        final ManyToManyRelationship _manyToManyRelationship = (ManyToManyRelationship)it;
        _matched=true;
        boolean _and = false;
        String _indexBy = _manyToManyRelationship.getIndexBy();
        boolean _tripleNotEquals = (_indexBy != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _indexBy_1 = _manyToManyRelationship.getIndexBy();
          boolean _notEquals = (!Objects.equal(_indexBy_1, ""));
          _and = (_tripleNotEquals && _notEquals);
        }
        _switchResult = _and;
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
    if (!_matched) {
      if (it instanceof OneToManyRelationship) {
        final OneToManyRelationship _oneToManyRelationship = (OneToManyRelationship)it;
        _matched=true;
        String _indexBy = _oneToManyRelationship.getIndexBy();
        _switchResult = _indexBy;
      }
    }
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        final ManyToManyRelationship _manyToManyRelationship = (ManyToManyRelationship)it;
        _matched=true;
        String _indexBy = _manyToManyRelationship.getIndexBy();
        _switchResult = _indexBy;
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
      String _aggregateFor = it.getAggregateFor();
      final String[] aggregateDetails = _aggregateFor.split("#");
      Entity _entity = it.getEntity();
      EList<Relationship> _outgoing = _entity.getOutgoing();
      Iterable<OneToManyRelationship> _filter = Iterables.<OneToManyRelationship>filter(_outgoing, OneToManyRelationship.class);
      final Function1<OneToManyRelationship,Boolean> _function = new Function1<OneToManyRelationship,Boolean>() {
        public Boolean apply(final OneToManyRelationship it) {
          boolean _and = false;
          boolean _isBidirectional = it.isBidirectional();
          if (!_isBidirectional) {
            _and = false;
          } else {
            String _targetAlias = it.getTargetAlias();
            Object _head = IterableExtensions.<Object>head(((Iterable<Object>)Conversions.doWrapArray(aggregateDetails)));
            boolean _equals = Objects.equal(_targetAlias, _head);
            _and = (_isBidirectional && _equals);
          }
          return Boolean.valueOf(_and);
        }
      };
      OneToManyRelationship _findFirst = IterableExtensions.<OneToManyRelationship>findFirst(_filter, _function);
      _xblockexpression = (_findFirst);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the target entity of the outgoing one2many relationship using this field as aggregate.
   */
  public Entity getAggregateTargetEntity(final IntegerField it) {
    OneToManyRelationship _aggregateRelationship = this.getAggregateRelationship(it);
    Entity _target = _aggregateRelationship.getTarget();
    return _target;
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
      String _aggregateFor = it.getAggregateFor();
      final String[] aggregateDetails = _aggregateFor.split("#");
      Entity _aggregateTargetEntity = this.getAggregateTargetEntity(it);
      EList<EntityField> _fields = _aggregateTargetEntity.getFields();
      Iterable<DerivedField> _filter = Iterables.<DerivedField>filter(_fields, DerivedField.class);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField it) {
          String _name = it.getName();
          Object _get = aggregateDetails[1];
          boolean _equals = Objects.equal(_name, _get);
          return Boolean.valueOf(_equals);
        }
      };
      DerivedField _findFirst = IterableExtensions.<DerivedField>findFirst(_filter, _function);
      _xblockexpression = (_findFirst);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all incoming relationships aggregating this field.
   */
  public Iterable<OneToManyRelationship> getAggregatingRelationships(final DerivedField it) {
    Entity _entity = it.getEntity();
    EList<Relationship> _incoming = _entity.getIncoming();
    Iterable<OneToManyRelationship> _filter = Iterables.<OneToManyRelationship>filter(_incoming, OneToManyRelationship.class);
    final Function1<OneToManyRelationship,Boolean> _function = new Function1<OneToManyRelationship,Boolean>() {
      public Boolean apply(final OneToManyRelationship it) {
        Entity _source = it.getSource();
        Iterable<IntegerField> _aggregateFields = ModelJoinExtensions.this._modelExtensions.getAggregateFields(_source);
        boolean _isEmpty = IterableExtensions.isEmpty(_aggregateFields);
        boolean _not = (!_isEmpty);
        return Boolean.valueOf(_not);
      }
    };
    Iterable<OneToManyRelationship> _filter_1 = IterableExtensions.<OneToManyRelationship>filter(_filter, _function);
    final Function1<OneToManyRelationship,Boolean> _function_1 = new Function1<OneToManyRelationship,Boolean>() {
      public Boolean apply(final OneToManyRelationship it) {
        Entity _source = it.getSource();
        Iterable<IntegerField> _aggregateFields = ModelJoinExtensions.this._modelExtensions.getAggregateFields(_source);
        final Function1<IntegerField,Boolean> _function = new Function1<IntegerField,Boolean>() {
          public Boolean apply(final IntegerField it) {
            DerivedField _aggregateTargetField = ModelJoinExtensions.this.getAggregateTargetField(it);
            boolean _equals = Objects.equal(_aggregateTargetField, it);
            return Boolean.valueOf(_equals);
          }
        };
        Iterable<IntegerField> _filter = IterableExtensions.<IntegerField>filter(_aggregateFields, _function);
        boolean _isEmpty = IterableExtensions.isEmpty(_filter);
        boolean _not = (!_isEmpty);
        return Boolean.valueOf(_not);
      }
    };
    Iterable<OneToManyRelationship> _filter_2 = IterableExtensions.<OneToManyRelationship>filter(_filter_1, _function_1);
    return _filter_2;
  }
  
  /**
   * Returns a list of all incoming relationships aggregating any fields of this entity.
   */
  public Iterable<DerivedField> getAggregators(final Entity it) {
    Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
    final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
      public Boolean apply(final DerivedField it) {
        Iterable<OneToManyRelationship> _aggregatingRelationships = ModelJoinExtensions.this.getAggregatingRelationships(it);
        boolean _isEmpty = IterableExtensions.isEmpty(_aggregatingRelationships);
        boolean _not = (!_isEmpty);
        return Boolean.valueOf(_not);
      }
    };
    Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
    return _filter;
  }
  
  /**
   * Checks whether there is at least one field used as aggregate field.
   */
  public boolean isAggregated(final Entity it) {
    Iterable<DerivedField> _aggregators = this.getAggregators(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_aggregators);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Prints an output string corresponding to the given relation fetch type.
   */
  public String asConstant(final RelationFetchType fetchType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(fetchType,RelationFetchType.LAZY)) {
        _matched=true;
        _switchResult = "LAZY";
      }
    }
    if (!_matched) {
      if (Objects.equal(fetchType,RelationFetchType.EAGER)) {
        _matched=true;
        _switchResult = "EAGER";
      }
    }
    if (!_matched) {
      if (Objects.equal(fetchType,RelationFetchType.EXTRA_LAZY)) {
        _matched=true;
        _switchResult = "EXTRA_LAZY";
      }
    }
    if (!_matched) {
      _switchResult = "LAZY";
    }
    return _switchResult;
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
