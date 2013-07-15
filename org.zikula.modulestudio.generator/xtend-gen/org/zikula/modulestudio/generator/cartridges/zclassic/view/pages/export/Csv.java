package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import java.util.ArrayList;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Csv {
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
  
  private SimpleFields fieldHelper = new Function0<SimpleFields>() {
    public SimpleFields apply() {
      SimpleFields _simpleFields = new SimpleFields();
      return _simpleFields;
    }
  }.apply();
  
  public void generate(final Entity it, final String appName, final Controller controller, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " csv view templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    String _name_1 = it.getName();
    String _templateFileWithExtension = this._namingExtensions.templateFileWithExtension(controller, _name_1, "view", "csv");
    CharSequence _csvView = this.csvView(it, appName, controller);
    fsa.generateFile(_templateFileWithExtension, _csvView);
  }
  
  private CharSequence csvView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" view csv view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("TemplateHeaders contentType=\'text/comma-separated-values; charset=iso-8859-15\' asAttachment=true filename=\'");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_nameMultiple_1);
    _builder.append(_formatForCodeCapital, "");
    _builder.append(".csv\'}");
    _builder.newLineIfNotEmpty();
    {
      Iterable<DerivedField> _displayFields = this._modelExtensions.getDisplayFields(it);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
          public Boolean apply(final DerivedField e) {
            String _name = e.getName();
            boolean _notEquals = (!Objects.equal(_name, "workflowState"));
            return Boolean.valueOf(_notEquals);
          }
        };
      Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_displayFields, _function);
      boolean _hasElements = false;
      for(final DerivedField field : _filter) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(";", "");
        }
        CharSequence _headerLine = this.headerLine(field);
        _builder.append(_headerLine, "");
      }
    }
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList("latitude", "longitude");
          for(final String geoFieldName : _newArrayList) {
            _builder.append(";\"{gt text=\'");
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(geoFieldName);
            _builder.append(_formatForDisplayCapital, "");
            _builder.append("\'}\"");
          }
        }
      }
    }
    {
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      if (_isSoftDeleteable) {
        _builder.append(";\"{gt text=\'Deleted at\'}\"");
      }
    }
    _builder.append(";\"{gt text=\'Workflow state\'}\"");
    _builder.newLineIfNotEmpty();
    {
      EList<Relationship> _incoming = it.getIncoming();
      Iterable<OneToManyRelationship> _filter_1 = Iterables.<OneToManyRelationship>filter(_incoming, OneToManyRelationship.class);
      final Function1<OneToManyRelationship,Boolean> _function_1 = new Function1<OneToManyRelationship,Boolean>() {
          public Boolean apply(final OneToManyRelationship e) {
            boolean _isBidirectional = e.isBidirectional();
            return Boolean.valueOf(_isBidirectional);
          }
        };
      Iterable<OneToManyRelationship> _filter_2 = IterableExtensions.<OneToManyRelationship>filter(_filter_1, _function_1);
      for(final OneToManyRelationship relation : _filter_2) {
        CharSequence _headerLineRelation = this.headerLineRelation(relation, Boolean.valueOf(false));
        _builder.append(_headerLineRelation, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      EList<Relationship> _outgoing = it.getOutgoing();
      Iterable<OneToOneRelationship> _filter_3 = Iterables.<OneToOneRelationship>filter(_outgoing, OneToOneRelationship.class);
      for(final OneToOneRelationship relation_1 : _filter_3) {
        CharSequence _headerLineRelation_1 = this.headerLineRelation(relation_1, Boolean.valueOf(true));
        _builder.append(_headerLineRelation_1, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      EList<Relationship> _incoming_1 = it.getIncoming();
      Iterable<ManyToManyRelationship> _filter_4 = Iterables.<ManyToManyRelationship>filter(_incoming_1, ManyToManyRelationship.class);
      final Function1<ManyToManyRelationship,Boolean> _function_2 = new Function1<ManyToManyRelationship,Boolean>() {
          public Boolean apply(final ManyToManyRelationship e) {
            boolean _isBidirectional = e.isBidirectional();
            return Boolean.valueOf(_isBidirectional);
          }
        };
      Iterable<ManyToManyRelationship> _filter_5 = IterableExtensions.<ManyToManyRelationship>filter(_filter_4, _function_2);
      for(final ManyToManyRelationship relation_2 : _filter_5) {
        CharSequence _headerLineRelation_2 = this.headerLineRelation(relation_2, Boolean.valueOf(false));
        _builder.append(_headerLineRelation_2, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      EList<Relationship> _outgoing_1 = it.getOutgoing();
      Iterable<OneToManyRelationship> _filter_6 = Iterables.<OneToManyRelationship>filter(_outgoing_1, OneToManyRelationship.class);
      for(final OneToManyRelationship relation_3 : _filter_6) {
        CharSequence _headerLineRelation_3 = this.headerLineRelation(relation_3, Boolean.valueOf(true));
        _builder.append(_headerLineRelation_3, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      EList<Relationship> _outgoing_2 = it.getOutgoing();
      Iterable<ManyToManyRelationship> _filter_7 = Iterables.<ManyToManyRelationship>filter(_outgoing_2, ManyToManyRelationship.class);
      for(final ManyToManyRelationship relation_4 : _filter_7) {
        CharSequence _headerLineRelation_4 = this.headerLineRelation(relation_4, Boolean.valueOf(true));
        _builder.append(_headerLineRelation_4, "");
      }
    }
    _builder.newLineIfNotEmpty();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{foreach item=\'");
    _builder.append(objName, "");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<DerivedField> _displayFields_1 = this._modelExtensions.getDisplayFields(it);
      final Function1<DerivedField,Boolean> _function_3 = new Function1<DerivedField,Boolean>() {
          public Boolean apply(final DerivedField e) {
            String _name = e.getName();
            boolean _notEquals = (!Objects.equal(_name, "workflowState"));
            return Boolean.valueOf(_notEquals);
          }
        };
      Iterable<DerivedField> _filter_8 = IterableExtensions.<DerivedField>filter(_displayFields_1, _function_3);
      boolean _hasElements_1 = false;
      for(final DerivedField field_1 : _filter_8) {
        if (!_hasElements_1) {
          _hasElements_1 = true;
        } else {
          _builder.appendImmediate(";", "    ");
        }
        CharSequence _displayEntry = this.displayEntry(field_1, controller);
        _builder.append(_displayEntry, "    ");
      }
    }
    {
      boolean _isGeographical_1 = it.isGeographical();
      if (_isGeographical_1) {
        {
          ArrayList<String> _newArrayList_1 = CollectionLiterals.<String>newArrayList("latitude", "longitude");
          for(final String geoFieldName_1 : _newArrayList_1) {
            _builder.append(";\"{$");
            String _name_1 = it.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode, "    ");
            _builder.append(".");
            _builder.append(geoFieldName_1, "    ");
            _builder.append("|");
            String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
            _builder.append(_formatForDB_1, "    ");
            _builder.append("FormatGeoData}\"");
          }
        }
      }
    }
    {
      boolean _isSoftDeleteable_1 = it.isSoftDeleteable();
      if (_isSoftDeleteable_1) {
        _builder.append(";\"{$item.deletedAt|dateformat:\'datebrief\'}\"");
      }
    }
    _builder.append(";\"{$item.workflowState|");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_2, "    ");
    _builder.append("ObjectState:false|lower}\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _incoming_2 = it.getIncoming();
      Iterable<OneToManyRelationship> _filter_9 = Iterables.<OneToManyRelationship>filter(_incoming_2, OneToManyRelationship.class);
      final Function1<OneToManyRelationship,Boolean> _function_4 = new Function1<OneToManyRelationship,Boolean>() {
          public Boolean apply(final OneToManyRelationship e) {
            boolean _isBidirectional = e.isBidirectional();
            return Boolean.valueOf(_isBidirectional);
          }
        };
      Iterable<OneToManyRelationship> _filter_10 = IterableExtensions.<OneToManyRelationship>filter(_filter_9, _function_4);
      for(final OneToManyRelationship relation_5 : _filter_10) {
        CharSequence _displayRelatedEntry = this.displayRelatedEntry(relation_5, controller, Boolean.valueOf(false));
        _builder.append(_displayRelatedEntry, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _outgoing_3 = it.getOutgoing();
      Iterable<OneToOneRelationship> _filter_11 = Iterables.<OneToOneRelationship>filter(_outgoing_3, OneToOneRelationship.class);
      for(final OneToOneRelationship relation_6 : _filter_11) {
        CharSequence _displayRelatedEntry_1 = this.displayRelatedEntry(relation_6, controller, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntry_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _incoming_3 = it.getIncoming();
      Iterable<ManyToManyRelationship> _filter_12 = Iterables.<ManyToManyRelationship>filter(_incoming_3, ManyToManyRelationship.class);
      final Function1<ManyToManyRelationship,Boolean> _function_5 = new Function1<ManyToManyRelationship,Boolean>() {
          public Boolean apply(final ManyToManyRelationship e) {
            boolean _isBidirectional = e.isBidirectional();
            return Boolean.valueOf(_isBidirectional);
          }
        };
      Iterable<ManyToManyRelationship> _filter_13 = IterableExtensions.<ManyToManyRelationship>filter(_filter_12, _function_5);
      for(final ManyToManyRelationship relation_7 : _filter_13) {
        CharSequence _displayRelatedEntries = this.displayRelatedEntries(relation_7, controller, Boolean.valueOf(false));
        _builder.append(_displayRelatedEntries, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _outgoing_4 = it.getOutgoing();
      Iterable<OneToManyRelationship> _filter_14 = Iterables.<OneToManyRelationship>filter(_outgoing_4, OneToManyRelationship.class);
      for(final OneToManyRelationship relation_8 : _filter_14) {
        CharSequence _displayRelatedEntries_1 = this.displayRelatedEntries(relation_8, controller, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntries_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _outgoing_5 = it.getOutgoing();
      Iterable<ManyToManyRelationship> _filter_15 = Iterables.<ManyToManyRelationship>filter(_outgoing_5, ManyToManyRelationship.class);
      for(final ManyToManyRelationship relation_9 : _filter_15) {
        CharSequence _displayRelatedEntries_2 = this.displayRelatedEntries(relation_9, controller, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntries_2, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{/foreach}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence headerLine(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"{gt text=\'");
    String _name = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\'}\"");
    return _builder;
  }
  
  private CharSequence headerLineRelation(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(";\"{gt text=\'");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_relationAliasName);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\'}\"");
    return _builder;
  }
  
  private CharSequence _displayEntry(final DerivedField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"");
    Entity _entity = it.getEntity();
    String _name = _entity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    CharSequence _displayField = this.fieldHelper.displayField(it, _formatForCode, "viewcsv");
    _builder.append(_displayField, "");
    _builder.append("\"");
    return _builder;
  }
  
  private CharSequence _displayEntry(final BooleanField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"{if !$");
    Entity _entity = it.getEntity();
    String _name = _entity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append(".");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append("}0{else}1{/if}\"");
    return _builder;
  }
  
  private CharSequence displayRelatedEntry(final JoinRelationship it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
    _builder.newLineIfNotEmpty();
    Entity _xifexpression = null;
    boolean _not = (!(useTarget).booleanValue());
    if (_not) {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    } else {
      Entity _source = it.getSource();
      _xifexpression = _source;
    }
    final Entity mainEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    Entity _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      Entity _target_1 = it.getTarget();
      _xifexpression_1 = _target_1;
    } else {
      Entity _source_1 = it.getSource();
      _xifexpression_1 = _source_1;
    }
    final Entity linkEntity = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    String _name = mainEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _plus = (_formatForCode + ".");
    final String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    final DerivedField leadingField = this._modelExtensions.getLeadingField(linkEntity);
    _builder.newLineIfNotEmpty();
    _builder.append(";\"{if isset($");
    _builder.append(relObjName, "");
    _builder.append(") && $");
    _builder.append(relObjName, "");
    _builder.append(" ne null}");
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("{$");
        _builder.append(relObjName, "");
        _builder.append(".");
        DerivedField _leadingField = this._modelExtensions.getLeadingField(linkEntity);
        String _name_1 = _leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("|default:\'\'}");
      } else {
        String _name_2 = linkEntity.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_2);
        _builder.append(_formatForDisplay, "");
      }
    }
    _builder.append("{/if}\"");
    return _builder;
  }
  
  private CharSequence displayRelatedEntries(final JoinRelationship it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
    _builder.newLineIfNotEmpty();
    Entity _xifexpression = null;
    boolean _not = (!(useTarget).booleanValue());
    if (_not) {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    } else {
      Entity _source = it.getSource();
      _xifexpression = _source;
    }
    final Entity mainEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    Entity _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      Entity _target_1 = it.getTarget();
      _xifexpression_1 = _target_1;
    } else {
      Entity _source_1 = it.getSource();
      _xifexpression_1 = _source_1;
    }
    final Entity linkEntity = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    String _name = mainEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _plus = (_formatForCode + ".");
    final String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    final DerivedField leadingField = this._modelExtensions.getLeadingField(linkEntity);
    _builder.newLineIfNotEmpty();
    _builder.append(";\"");
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.newLineIfNotEmpty();
        _builder.append("{if isset($");
        _builder.append(relObjName, "");
        _builder.append(") && $");
        _builder.append(relObjName, "");
        _builder.append(" ne null}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{foreach name=\'relationLoop\' item=\'relatedItem\' from=$");
        _builder.append(relObjName, "    ");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{$relatedItem.");
        String _name_1 = leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("|default:\'\'}{if !$smarty.foreach.relationLoop.last}, {/if}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      } else {
        String _nameMultiple = linkEntity.getNameMultiple();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
        _builder.append(_formatForDisplay, "");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
      }
    }
    _builder.append("\"");
    return _builder;
  }
  
  private CharSequence displayEntry(final DerivedField it, final Controller controller) {
    if (it instanceof BooleanField) {
      return _displayEntry((BooleanField)it, controller);
    } else if (it != null) {
      return _displayEntry(it, controller);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, controller).toString());
    }
  }
}
