package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class RelationPresets {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  public CharSequence memberFields(final Application it) {
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
    _builder.append("protected $relationPresets = [];");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence baseMethod(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialises relationship presets.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function initRelationPresets()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// to be customised in sub classes");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence callBaseMethod(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("$this->initRelationPresets();");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence childMethod(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<JoinRelationship> owningAssociations = this.getOwningAssociations(it, it.getApplication());
    _builder.newLineIfNotEmpty();
    final Iterable<ManyToManyRelationship> ownedMMAssociations = this.getOwnedMMAssociations(it, it.getApplication());
    _builder.newLineIfNotEmpty();
    {
      if (((!IterableExtensions.isEmpty(owningAssociations)) || (!IterableExtensions.isEmpty(ownedMMAssociations)))) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initialises relationship presets.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function initRelationPresets()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity = $this->entityRef;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _initPresets = this.initPresets(it);
        _builder.append(_initPresets, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// save entity reference for later reuse");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->entityRef = $entity;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public CharSequence initPresets(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<JoinRelationship> owningAssociations = this.getOwningAssociations(it, it.getApplication());
    _builder.newLineIfNotEmpty();
    final Iterable<ManyToManyRelationship> ownedMMAssociations = this.getOwnedMMAssociations(it, it.getApplication());
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
            _builder.append(_initSinglePreset);
            _builder.newLineIfNotEmpty();
            {
              boolean _isEditable_1 = this.isEditable(relation, Boolean.valueOf(false));
              if (_isEditable_1) {
                CharSequence _saveSinglePreset = this.saveSinglePreset(relation, Boolean.valueOf(false));
                _builder.append(_saveSinglePreset);
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
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
            _builder.append(_initSinglePreset_1);
            _builder.newLineIfNotEmpty();
            {
              boolean _isEditable_3 = this.isEditable(relation_1, Boolean.valueOf(true));
              if (_isEditable_3) {
                CharSequence _saveSinglePreset_1 = this.saveSinglePreset(relation_1, Boolean.valueOf(true));
                _builder.append(_saveSinglePreset_1);
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
    _builder.append(alias);
    _builder.append("\'] = $this->request->get(\'");
    _builder.append(alias);
    _builder.append("\', \'\');");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private Iterable<JoinRelationship> getOwningAssociations(final Entity it, final Application refApp) {
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      Application _application = it_1.getSource().getApplication();
      return Boolean.valueOf(Objects.equal(_application, refApp));
    };
    return IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it), _function);
  }
  
  private Iterable<ManyToManyRelationship> getOwnedMMAssociations(final Entity it, final Application refApp) {
    final Function1<ManyToManyRelationship, Boolean> _function = (ManyToManyRelationship it_1) -> {
      Application _application = it_1.getSource().getApplication();
      return Boolean.valueOf(Objects.equal(_application, refApp));
    };
    return IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), ManyToManyRelationship.class), _function);
  }
  
  private boolean isEditable(final JoinRelationship it, final Boolean useTarget) {
    int _editStageCode = this._controllerExtensions.getEditStageCode(it, Boolean.valueOf((!(useTarget).booleanValue())));
    return (_editStageCode > 0);
  }
  
  public CharSequence saveNonEditablePresets(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      boolean _isEditable = this.isEditable(it_1, Boolean.valueOf(false));
      return Boolean.valueOf((!_isEditable));
    };
    final Iterable<JoinRelationship> owningAssociationsNonEditable = IterableExtensions.<JoinRelationship>filter(this.getOwningAssociations(it, app), _function);
    _builder.newLineIfNotEmpty();
    final Function1<ManyToManyRelationship, Boolean> _function_1 = (ManyToManyRelationship it_1) -> {
      boolean _isEditable = this.isEditable(it_1, Boolean.valueOf(true));
      return Boolean.valueOf((!_isEditable));
    };
    final Iterable<ManyToManyRelationship> ownedMMAssociationsNonEditable = IterableExtensions.<ManyToManyRelationship>filter(this.getOwnedMMAssociations(it, app), _function_1);
    _builder.newLineIfNotEmpty();
    {
      if (((!IterableExtensions.isEmpty(owningAssociationsNonEditable)) || (!IterableExtensions.isEmpty(ownedMMAssociationsNonEditable)))) {
        _builder.newLine();
        _builder.append("if ($args[\'commandName\'] == \'create\') {");
        _builder.newLine();
        {
          boolean _isEmpty = IterableExtensions.isEmpty(owningAssociationsNonEditable);
          boolean _not = (!_isEmpty);
          if (_not) {
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
          boolean _isEmpty_1 = IterableExtensions.isEmpty(ownedMMAssociationsNonEditable);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
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
        _builder.append("$this->entityFactory->getObjectManager()->flush();");
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
    final String aliasInverse = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf((!(useTarget).booleanValue())));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression = null;
    if ((useTarget).booleanValue()) {
      _xifexpression = it.getTarget();
    } else {
      _xifexpression = it.getSource();
    }
    final String otherObjectType = this._formattingExtensions.formatForCode(_xifexpression.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("if (!empty($this->relationPresets[\'");
    _builder.append(alias);
    _builder.append("\'])) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$relObj = $this->entityFactory->getRepository(\'");
    _builder.append(otherObjectType, "    ");
    _builder.append("\')->selectById($this->relationPresets[\'");
    _builder.append(alias, "    ");
    _builder.append("\']);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (null !== $relObj) {");
    _builder.newLine();
    {
      if (((!(useTarget).booleanValue()) && (it instanceof ManyToManyRelationship))) {
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
          boolean _isManySide_1 = this._modelJoinExtensions.isManySide(it, (!(useTarget).booleanValue()));
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
