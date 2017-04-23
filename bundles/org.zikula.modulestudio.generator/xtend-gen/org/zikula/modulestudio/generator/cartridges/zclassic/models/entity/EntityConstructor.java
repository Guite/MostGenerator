package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Association;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class EntityConstructor {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence constructor(final Entity it, final Boolean isInheriting) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, " ");
    _builder.append("Entity constructor.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Will not be called by Doctrine and can therefore be used");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* for own implementation purposes. It is also possible to add");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* arbitrary arguments as with every other class method.");
    _builder.newLine();
    {
      if (((this._modelJoinExtensions.isIndexByTarget(it) || this._modelJoinExtensions.isAggregated(it)) || this._modelExtensions.hasCompositeKeys(it))) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        {
          boolean _isIndexByTarget = this._modelJoinExtensions.isIndexByTarget(it);
          if (_isIndexByTarget) {
            _builder.append(" ");
            _builder.append("* @param string $");
            String _formatForCode = this._formattingExtensions.formatForCode(this._modelJoinExtensions.getIndexByField(this.getIndexByRelation(it)));
            _builder.append(_formatForCode, " ");
            _builder.append(" Indexing field");
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append("* @param string $");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(this.getIndexByRelation(it), Boolean.valueOf(false)));
            _builder.append(_formatForCode_1, " ");
            _builder.append(" Indexing relationship");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _isAggregated = this._modelJoinExtensions.isAggregated(it);
            if (_isAggregated) {
              {
                Iterable<DerivedField> _aggregators = this._modelJoinExtensions.getAggregators(it);
                boolean _hasElements = false;
                for(final DerivedField aggregator : _aggregators) {
                  if (!_hasElements) {
                    _hasElements = true;
                  } else {
                    _builder.appendImmediate(", ", " ");
                  }
                  {
                    Iterable<OneToManyRelationship> _aggregatingRelationships = this._modelJoinExtensions.getAggregatingRelationships(aggregator);
                    boolean _hasElements_1 = false;
                    for(final OneToManyRelationship relation : _aggregatingRelationships) {
                      if (!_hasElements_1) {
                        _hasElements_1 = true;
                      } else {
                        _builder.appendImmediate(", ", " ");
                      }
                      _builder.append(" ");
                      _builder.append("@param string $");
                      String _relationAliasName = this._namingExtensions.getRelationAliasName(relation, Boolean.valueOf(false));
                      _builder.append(_relationAliasName, " ");
                      _builder.append(" Aggregating relationship");
                      _builder.newLineIfNotEmpty();
                      _builder.append(" ");
                      _builder.append("@param string $");
                      String _formatForCode_2 = this._formattingExtensions.formatForCode(this._modelJoinExtensions.getAggregateTargetField(IterableExtensions.<IntegerField>head(this._modelExtensions.getAggregateFields(relation.getSource()))).getName());
                      _builder.append(_formatForCode_2, " ");
                      _builder.append(" Aggregate target field");
                      _builder.newLineIfNotEmpty();
                    }
                  }
                }
              }
            }
          }
        }
        {
          boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
          if (_hasCompositeKeys) {
            {
              Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
              boolean _hasElements_2 = false;
              for(final DerivedField pkField : _primaryKeyFields) {
                if (!_hasElements_2) {
                  _hasElements_2 = true;
                } else {
                  _builder.appendImmediate(", ", " ");
                }
                _builder.append(" ");
                _builder.append("* @param integer $");
                String _formatForCode_3 = this._formattingExtensions.formatForCode(pkField.getName());
                _builder.append(_formatForCode_3, " ");
                _builder.append(" Composite primary key");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function __construct(");
    CharSequence _constructorArguments = this.constructorArguments(it, Boolean.valueOf(true));
    _builder.append(_constructorArguments);
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _constructorImpl = this.constructorImpl(it, isInheriting);
    _builder.append(_constructorImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence constructorArgumentsDefault(final Entity it, final Boolean hasPreviousArgs) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        {
          if ((hasPreviousArgs).booleanValue()) {
            _builder.append(", ");
          }
        }
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            _builder.append("$");
            String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode);
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence constructorArguments(final Entity it, final Boolean withTypeHints) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isIndexByTarget = this._modelJoinExtensions.isIndexByTarget(it);
      if (_isIndexByTarget) {
        final JoinRelationship indexRelation = this.getIndexByRelation(it);
        _builder.newLineIfNotEmpty();
        final String sourceAlias = this._namingExtensions.getRelationAliasName(indexRelation, Boolean.valueOf(false));
        _builder.newLineIfNotEmpty();
        final String indexBy = this._modelJoinExtensions.getIndexByField(indexRelation);
        _builder.newLineIfNotEmpty();
        _builder.append("$");
        String _formatForCode = this._formattingExtensions.formatForCode(indexBy);
        _builder.append(_formatForCode);
        _builder.append(",");
        {
          if ((withTypeHints).booleanValue()) {
            _builder.append(" ");
            String _entityClassName = this._namingExtensions.entityClassName(indexRelation.getSource(), "", Boolean.valueOf(false));
            _builder.append(_entityClassName);
          }
        }
        _builder.append(" $");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode_1);
        CharSequence _constructorArgumentsDefault = this.constructorArgumentsDefault(it, Boolean.valueOf(true));
        _builder.append(_constructorArgumentsDefault);
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isAggregated = this._modelJoinExtensions.isAggregated(it);
        if (_isAggregated) {
          {
            Iterable<DerivedField> _aggregators = this._modelJoinExtensions.getAggregators(it);
            boolean _hasElements = false;
            for(final DerivedField aggregator : _aggregators) {
              if (!_hasElements) {
                _hasElements = true;
              } else {
                _builder.appendImmediate(", ", "");
              }
              {
                Iterable<OneToManyRelationship> _aggregatingRelationships = this._modelJoinExtensions.getAggregatingRelationships(aggregator);
                boolean _hasElements_1 = false;
                for(final OneToManyRelationship relation : _aggregatingRelationships) {
                  if (!_hasElements_1) {
                    _hasElements_1 = true;
                  } else {
                    _builder.appendImmediate(", ", "");
                  }
                  CharSequence _constructorArgumentsAggregate = this.constructorArgumentsAggregate(relation);
                  _builder.append(_constructorArgumentsAggregate);
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
          CharSequence _constructorArgumentsDefault_1 = this.constructorArgumentsDefault(it, Boolean.valueOf(true));
          _builder.append(_constructorArgumentsDefault_1);
          _builder.newLineIfNotEmpty();
        } else {
          CharSequence _constructorArgumentsDefault_2 = this.constructorArgumentsDefault(it, Boolean.valueOf(false));
          _builder.append(_constructorArgumentsDefault_2);
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private JoinRelationship getIndexByRelation(final Entity it) {
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      return Boolean.valueOf(this._modelJoinExtensions.isIndexed(it_1));
    };
    return IterableExtensions.<JoinRelationship>head(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelations(it), _function));
  }
  
  private CharSequence constructorArgumentsAggregate(final OneToManyRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(IterableExtensions.<IntegerField>head(this._modelExtensions.getAggregateFields(it.getSource())));
    _builder.newLineIfNotEmpty();
    _builder.append("$");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.append(_relationAliasName);
    _builder.append(", $");
    String _formatForCode = this._formattingExtensions.formatForCode(targetField.getName());
    _builder.append(_formatForCode);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence constructorImpl(final Entity it, final Boolean isInheriting) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isInheriting).booleanValue()) {
        _builder.append("parent::__construct(");
        CharSequence _constructorArguments = this.constructorArguments(it, Boolean.valueOf(false));
        _builder.append(_constructorArguments);
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          for(final DerivedField pkField : _primaryKeyFields) {
            _builder.append("$this->");
            String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode);
            _builder.append(" = $");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode_1);
            _builder.append(";");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _isIndexByTarget = this._modelJoinExtensions.isIndexByTarget(it);
      if (_isIndexByTarget) {
        _builder.newLine();
        final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
          return Boolean.valueOf(this._modelJoinExtensions.isIndexed(it_1));
        };
        final JoinRelationship indexRelation = IterableExtensions.<JoinRelationship>head(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getIncoming(), JoinRelationship.class), _function));
        _builder.newLineIfNotEmpty();
        final String sourceAlias = this._namingExtensions.getRelationAliasName(indexRelation, Boolean.valueOf(false));
        _builder.newLineIfNotEmpty();
        final String targetAlias = this._namingExtensions.getRelationAliasName(indexRelation, Boolean.valueOf(true));
        _builder.newLineIfNotEmpty();
        final String indexBy = this._modelJoinExtensions.getIndexByField(indexRelation);
        _builder.newLineIfNotEmpty();
        _builder.append("$this->");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(indexBy);
        _builder.append(_formatForCode_2);
        _builder.append(" = $");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(indexBy);
        _builder.append(_formatForCode_3);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("$this->");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode_4);
        _builder.append(" = $");
        String _formatForCode_5 = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode_5);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("$");
        String _formatForCode_6 = this._formattingExtensions.formatForCode(sourceAlias);
        _builder.append(_formatForCode_6);
        _builder.append("->add");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(targetAlias);
        _builder.append(_formatForCodeCapital);
        _builder.append("($this);");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isAggregated = this._modelJoinExtensions.isAggregated(it);
        if (_isAggregated) {
          _builder.newLine();
          {
            Iterable<DerivedField> _aggregators = this._modelJoinExtensions.getAggregators(it);
            for(final DerivedField aggregator : _aggregators) {
              {
                Iterable<OneToManyRelationship> _aggregatingRelationships = this._modelJoinExtensions.getAggregatingRelationships(aggregator);
                for(final OneToManyRelationship relation : _aggregatingRelationships) {
                  CharSequence _constructorAssignmentAggregate = this.constructorAssignmentAggregate(relation);
                  _builder.append(_constructorAssignmentAggregate);
                  _builder.newLineIfNotEmpty();
                }
              }
            }
          }
        } else {
        }
      }
    }
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("$this->initWorkflow();");
        _builder.newLine();
      }
    }
    CharSequence _initCollections = new Association().initCollections(it);
    _builder.append(_initCollections);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence constructorAssignmentAggregate(final OneToManyRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    final DerivedField targetField = this._modelJoinExtensions.getAggregateTargetField(IterableExtensions.<IntegerField>head(this._modelExtensions.getAggregateFields(it.getSource())));
    _builder.newLineIfNotEmpty();
    _builder.append("$this->");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.append(_relationAliasName);
    _builder.append(" = $");
    String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.append(_relationAliasName_1);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->");
    String _formatForCode = this._formattingExtensions.formatForCode(targetField.getName());
    _builder.append(_formatForCode);
    _builder.append(" = $");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(targetField.getName());
    _builder.append(_formatForCode_1);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
