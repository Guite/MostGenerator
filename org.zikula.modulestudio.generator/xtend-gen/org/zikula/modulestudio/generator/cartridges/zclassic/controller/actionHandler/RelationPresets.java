package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class RelationPresets {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  public CharSequence memberFields(final Controller it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* List of identifiers for predefined relationships.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var mixed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $relationPresets = array();");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence initPresets(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    final Iterable<JoinRelationship> owningAssociations = this.getOwningAssociations(it, _application);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(owningAssociations);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append("// assign identifiers of predefined incoming relationships");
        _builder.newLine();
        {
          for(final JoinRelationship relation : owningAssociations) {
            {
              boolean _isEditable = this.isEditable(relation, Boolean.valueOf(false));
              boolean _not_1 = (!_isEditable);
              if (_not_1) {
                _builder.append("// non-editable relation, we store the id and assign it in handleCommand");
                _builder.newLine();
              } else {
                _builder.append("// editable relation, we store the id and assign it now to show it in UI");
                _builder.newLine();
              }
            }
            CharSequence _initSinglePreset = this.initSinglePreset(relation, Boolean.valueOf(false));
            _builder.append(_initSinglePreset, "");
            _builder.newLineIfNotEmpty();
            {
              boolean _isEditable_1 = this.isEditable(relation, Boolean.valueOf(false));
              if (_isEditable_1) {
                CharSequence _saveSinglePreset = this.saveSinglePreset(relation, Boolean.valueOf(false));
                _builder.append(_saveSinglePreset, "");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    Models _container_1 = it.getContainer();
    Application _application_1 = _container_1.getApplication();
    final Iterable<ManyToManyRelationship> ownedMMAssociations = this.getOwnedMMAssociations(it, _application_1);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty_1 = IterableExtensions.isEmpty(ownedMMAssociations);
      boolean _not_2 = (!_isEmpty_1);
      if (_not_2) {
        _builder.newLine();
        _builder.append("// assign identifiers of predefined outgoing many to many relationships");
        _builder.newLine();
        {
          for(final ManyToManyRelationship relation_1 : ownedMMAssociations) {
            {
              boolean _isEditable_2 = this.isEditable(relation_1, Boolean.valueOf(true));
              boolean _not_3 = (!_isEditable_2);
              if (_not_3) {
                _builder.append("// non-editable relation, we store the id and assign it in handleCommand");
                _builder.newLine();
              } else {
                _builder.append("// editable relation, we store the id and assign it now to show it in UI");
                _builder.newLine();
              }
            }
            CharSequence _initSinglePreset_1 = this.initSinglePreset(relation_1, Boolean.valueOf(true));
            _builder.append(_initSinglePreset_1, "");
            _builder.newLineIfNotEmpty();
            {
              boolean _isEditable_3 = this.isEditable(relation_1, Boolean.valueOf(true));
              if (_isEditable_3) {
                CharSequence _saveSinglePreset_1 = this.saveSinglePreset(relation_1, Boolean.valueOf(true));
                _builder.append(_saveSinglePreset_1, "");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence initSinglePreset(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String alias = this._namingExtensions.getRelationAliasName(it, useTarget);
    _builder.newLineIfNotEmpty();
    _builder.append("$this->relationPresets[\'");
    _builder.append(alias, "");
    _builder.append("\'] = FormUtil::getPassedValue(\'");
    _builder.append(alias, "");
    _builder.append("\', \'\', \'GET\');");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private Iterable<JoinRelationship> getOwningAssociations(final Entity it, final Application refApp) {
    Iterable<JoinRelationship> _incomingJoinRelations = this._modelJoinExtensions.getIncomingJoinRelations(it);
    final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
        public Boolean apply(final JoinRelationship e) {
          Entity _source = e.getSource();
          Models _container = _source.getContainer();
          Application _application = _container.getApplication();
          boolean _equals = Objects.equal(_application, refApp);
          return Boolean.valueOf(_equals);
        }
      };
    Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_incomingJoinRelations, _function);
    return _filter;
  }
  
  private Iterable<ManyToManyRelationship> getOwnedMMAssociations(final Entity it, final Application refApp) {
    Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
    Iterable<ManyToManyRelationship> _filter = Iterables.<ManyToManyRelationship>filter(_outgoingJoinRelations, ManyToManyRelationship.class);
    final Function1<ManyToManyRelationship,Boolean> _function = new Function1<ManyToManyRelationship,Boolean>() {
        public Boolean apply(final ManyToManyRelationship e) {
          Entity _source = e.getSource();
          Models _container = _source.getContainer();
          Application _application = _container.getApplication();
          boolean _equals = Objects.equal(_application, refApp);
          return Boolean.valueOf(_equals);
        }
      };
    Iterable<ManyToManyRelationship> _filter_1 = IterableExtensions.<ManyToManyRelationship>filter(_filter, _function);
    return _filter_1;
  }
  
  private boolean isEditable(final JoinRelationship it, final Boolean useTarget) {
    boolean _not = (!(useTarget).booleanValue());
    int _editStageCode = this._controllerExtensions.getEditStageCode(it, Boolean.valueOf(_not));
    boolean _greaterThan = (_editStageCode > 0);
    return _greaterThan;
  }
  
  public CharSequence saveNonEditablePresets(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    Iterable<JoinRelationship> _owningAssociations = this.getOwningAssociations(it, app);
    final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
        public Boolean apply(final JoinRelationship e) {
          boolean _isEditable = RelationPresets.this.isEditable(e, Boolean.valueOf(false));
          boolean _not = (!_isEditable);
          return Boolean.valueOf(_not);
        }
      };
    final Iterable<JoinRelationship> owningAssociationsNonEditable = IterableExtensions.<JoinRelationship>filter(_owningAssociations, _function);
    _builder.newLineIfNotEmpty();
    Iterable<ManyToManyRelationship> _ownedMMAssociations = this.getOwnedMMAssociations(it, app);
    final Function1<ManyToManyRelationship,Boolean> _function_1 = new Function1<ManyToManyRelationship,Boolean>() {
        public Boolean apply(final ManyToManyRelationship e) {
          boolean _isEditable = RelationPresets.this.isEditable(e, Boolean.valueOf(true));
          boolean _not = (!_isEditable);
          return Boolean.valueOf(_not);
        }
      };
    final Iterable<ManyToManyRelationship> ownedMMAssociationsNonEditable = IterableExtensions.<ManyToManyRelationship>filter(_ownedMMAssociations, _function_1);
    _builder.newLineIfNotEmpty();
    {
      boolean _or = false;
      boolean _isEmpty = IterableExtensions.isEmpty(owningAssociationsNonEditable);
      boolean _not = (!_isEmpty);
      if (_not) {
        _or = true;
      } else {
        boolean _isEmpty_1 = IterableExtensions.isEmpty(ownedMMAssociationsNonEditable);
        boolean _not_1 = (!_isEmpty_1);
        _or = (_not || _not_1);
      }
      if (_or) {
        _builder.newLine();
        _builder.append("if ($args[\'commandName\'] == \'create\') {");
        _builder.newLine();
        {
          boolean _isEmpty_2 = IterableExtensions.isEmpty(owningAssociationsNonEditable);
          boolean _not_2 = (!_isEmpty_2);
          if (_not_2) {
            _builder.append("    ");
            _builder.append("// save predefined incoming relationship from parent entity");
            _builder.newLine();
            {
              for(final JoinRelationship relation : owningAssociationsNonEditable) {
                _builder.append("    ");
                CharSequence _saveSinglePreset = this.saveSinglePreset(relation, Boolean.valueOf(false));
                _builder.append(_saveSinglePreset, "    ");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        {
          boolean _isEmpty_3 = IterableExtensions.isEmpty(ownedMMAssociationsNonEditable);
          boolean _not_3 = (!_isEmpty_3);
          if (_not_3) {
            _builder.append("    ");
            _builder.append("// save predefined outgoing relationship to child entity");
            _builder.newLine();
            {
              for(final ManyToManyRelationship relation_1 : ownedMMAssociationsNonEditable) {
                _builder.append("    ");
                CharSequence _saveSinglePreset_1 = this.saveSinglePreset(relation_1, Boolean.valueOf(true));
                _builder.append(_saveSinglePreset_1, "    ");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        _builder.append("    ");
        _builder.append("$this->entityManager->flush();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence saveSinglePreset(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String alias = this._namingExtensions.getRelationAliasName(it, useTarget);
    _builder.newLineIfNotEmpty();
    boolean _not = (!(useTarget).booleanValue());
    final String aliasInverse = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(_not));
    _builder.newLineIfNotEmpty();
    Entity _xifexpression = null;
    if ((useTarget).booleanValue()) {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    } else {
      Entity _source = it.getSource();
      _xifexpression = _source;
    }
    String _name = _xifexpression.getName();
    final String otherObjectType = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("if (!empty($this->relationPresets[\'");
    _builder.append(alias, "");
    _builder.append("\'])) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$relObj = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => \'");
    _builder.append(otherObjectType, "    ");
    _builder.append("\', \'id\' => $this->relationPresets[\'");
    _builder.append(alias, "    ");
    _builder.append("\']));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($relObj != null) {");
    _builder.newLine();
    {
      boolean _and = false;
      boolean _not_1 = (!(useTarget).booleanValue());
      if (!_not_1) {
        _and = false;
      } else {
        _and = (_not_1 && (it instanceof ManyToManyRelationship));
      }
      if (_and) {
        _builder.append("        ");
        _builder.append("$entity->");
        {
          boolean _isManySide = this._modelJoinExtensions.isManySide(it, (useTarget).booleanValue());
          if (_isManySide) {
            _builder.append("add");
          } else {
            _builder.append("set");
          }
        }
        String _firstUpper = StringExtensions.toFirstUpper(alias);
        _builder.append(_firstUpper, "        ");
        _builder.append("($relObj);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("        ");
        _builder.append("$relObj->");
        {
          boolean _not_2 = (!(useTarget).booleanValue());
          boolean _isManySide_1 = this._modelJoinExtensions.isManySide(it, _not_2);
          if (_isManySide_1) {
            _builder.append("add");
          } else {
            _builder.append("set");
          }
        }
        String _firstUpper_1 = StringExtensions.toFirstUpper(aliasInverse);
        _builder.append(_firstUpper_1, "        ");
        _builder.append("($entity);");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
