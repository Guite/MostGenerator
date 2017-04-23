package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import de.guite.modulestudio.metamodel.OneToOneRelationship;
import java.util.ArrayList;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Csv {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  private SimpleFields fieldHelper = new SimpleFields();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    final String templateFilePath = this._namingExtensions.templateFileWithExtension(it, "view", "csv");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
      String _plus = ("Generating csv view templates for entity \"" + _formatForDisplay);
      String _plus_1 = (_plus + "\"");
      InputOutput.<String>println(_plus_1);
      fsa.generateFile(templateFilePath, this.csvView(it, appName));
    }
  }
  
  private CharSequence csvView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" view csv view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% spaceless %}");
    {
      final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
        String _name = it_1.getName();
        return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
      };
      Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(this._modelExtensions.getDisplayFields(it), _function);
      boolean _hasElements = false;
      for(final DerivedField field : _filter) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(";", "");
        }
        CharSequence _headerLine = this.headerLine(field);
        _builder.append(_headerLine);
      }
    }
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList("latitude", "longitude");
          for(final String geoFieldName : _newArrayList) {
            _builder.append(";\"{{ __(\'");
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(geoFieldName);
            _builder.append(_formatForDisplayCapital);
            _builder.append("\') }}\"");
          }
        }
      }
    }
    _builder.append(";\"{{ __(\'Workflow state\') }}\"");
    _builder.newLineIfNotEmpty();
    {
      final Function1<OneToManyRelationship, Boolean> _function_1 = (OneToManyRelationship it_1) -> {
        return Boolean.valueOf(it_1.isBidirectional());
      };
      Iterable<OneToManyRelationship> _filter_1 = IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function_1);
      for(final OneToManyRelationship relation : _filter_1) {
        CharSequence _headerLineRelation = this.headerLineRelation(relation, Boolean.valueOf(false));
        _builder.append(_headerLineRelation);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<OneToOneRelationship> _filter_2 = Iterables.<OneToOneRelationship>filter(it.getOutgoing(), OneToOneRelationship.class);
      for(final OneToOneRelationship relation_1 : _filter_2) {
        CharSequence _headerLineRelation_1 = this.headerLineRelation(relation_1, Boolean.valueOf(true));
        _builder.append(_headerLineRelation_1);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      final Function1<ManyToManyRelationship, Boolean> _function_2 = (ManyToManyRelationship it_1) -> {
        return Boolean.valueOf(it_1.isBidirectional());
      };
      Iterable<ManyToManyRelationship> _filter_3 = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(it.getIncoming(), ManyToManyRelationship.class), _function_2);
      for(final ManyToManyRelationship relation_2 : _filter_3) {
        CharSequence _headerLineRelation_2 = this.headerLineRelation(relation_2, Boolean.valueOf(false));
        _builder.append(_headerLineRelation_2);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<OneToManyRelationship> _filter_4 = Iterables.<OneToManyRelationship>filter(it.getOutgoing(), OneToManyRelationship.class);
      for(final OneToManyRelationship relation_3 : _filter_4) {
        CharSequence _headerLineRelation_3 = this.headerLineRelation(relation_3, Boolean.valueOf(true));
        _builder.append(_headerLineRelation_3);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<ManyToManyRelationship> _filter_5 = Iterables.<ManyToManyRelationship>filter(it.getOutgoing(), ManyToManyRelationship.class);
      for(final ManyToManyRelationship relation_4 : _filter_5) {
        CharSequence _headerLineRelation_4 = this.headerLineRelation(relation_4, Boolean.valueOf(true));
        _builder.append(_headerLineRelation_4);
      }
    }
    _builder.append("{% endspaceless %}");
    _builder.newLineIfNotEmpty();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{% for ");
    _builder.append(objName);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% spaceless %}");
    _builder.newLine();
    _builder.append("    ");
    {
      final Function1<DerivedField, Boolean> _function_3 = (DerivedField e) -> {
        String _name = e.getName();
        return Boolean.valueOf((!Objects.equal(_name, "workflowState")));
      };
      Iterable<DerivedField> _filter_6 = IterableExtensions.<DerivedField>filter(this._modelExtensions.getDisplayFields(it), _function_3);
      boolean _hasElements_1 = false;
      for(final DerivedField field_1 : _filter_6) {
        if (!_hasElements_1) {
          _hasElements_1 = true;
        } else {
          _builder.appendImmediate(";", "    ");
        }
        CharSequence _displayEntry = this.displayEntry(field_1);
        _builder.append(_displayEntry, "    ");
      }
    }
    {
      boolean _isGeographical_1 = it.isGeographical();
      if (_isGeographical_1) {
        {
          ArrayList<String> _newArrayList_1 = CollectionLiterals.<String>newArrayList("latitude", "longitude");
          for(final String geoFieldName_1 : _newArrayList_1) {
            _builder.append(";\"{{ ");
            String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode, "    ");
            _builder.append(".");
            _builder.append(geoFieldName_1, "    ");
            _builder.append("|");
            String _formatForDB = this._formattingExtensions.formatForDB(appName);
            _builder.append(_formatForDB, "    ");
            _builder.append("_geoData }}\"");
          }
        }
      }
    }
    _builder.append(";\"{{ ");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, "    ");
    _builder.append(".workflowState|");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_1, "    ");
    _builder.append("_objectState(false)|lower }}\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      final Function1<OneToManyRelationship, Boolean> _function_4 = (OneToManyRelationship it_1) -> {
        return Boolean.valueOf(it_1.isBidirectional());
      };
      Iterable<OneToManyRelationship> _filter_7 = IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function_4);
      for(final OneToManyRelationship relation_5 : _filter_7) {
        CharSequence _displayRelatedEntry = this.displayRelatedEntry(relation_5, Boolean.valueOf(false));
        _builder.append(_displayRelatedEntry, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<OneToOneRelationship> _filter_8 = Iterables.<OneToOneRelationship>filter(it.getOutgoing(), OneToOneRelationship.class);
      for(final OneToOneRelationship relation_6 : _filter_8) {
        CharSequence _displayRelatedEntry_1 = this.displayRelatedEntry(relation_6, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntry_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      final Function1<ManyToManyRelationship, Boolean> _function_5 = (ManyToManyRelationship it_1) -> {
        return Boolean.valueOf(it_1.isBidirectional());
      };
      Iterable<ManyToManyRelationship> _filter_9 = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(it.getIncoming(), ManyToManyRelationship.class), _function_5);
      for(final ManyToManyRelationship relation_7 : _filter_9) {
        CharSequence _displayRelatedEntries = this.displayRelatedEntries(relation_7, Boolean.valueOf(false));
        _builder.append(_displayRelatedEntries, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<OneToManyRelationship> _filter_10 = Iterables.<OneToManyRelationship>filter(it.getOutgoing(), OneToManyRelationship.class);
      for(final OneToManyRelationship relation_8 : _filter_10) {
        CharSequence _displayRelatedEntries_1 = this.displayRelatedEntries(relation_8, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntries_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<ManyToManyRelationship> _filter_11 = Iterables.<ManyToManyRelationship>filter(it.getOutgoing(), ManyToManyRelationship.class);
      for(final ManyToManyRelationship relation_9 : _filter_11) {
        CharSequence _displayRelatedEntries_2 = this.displayRelatedEntries(relation_9, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntries_2, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{% endspaceless %}");
    _builder.newLine();
    _builder.append("{% endfor %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence headerLine(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital);
    _builder.append("\') }}\"");
    return _builder;
  }
  
  private CharSequence headerLineRelation(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(";\"{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(this._namingExtensions.getRelationAliasName(it, useTarget));
    _builder.append(_formatForDisplayCapital);
    _builder.append("\') }}\"");
    return _builder;
  }
  
  private CharSequence _displayEntry(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"");
    CharSequence _displayField = this.fieldHelper.displayField(it, this._formattingExtensions.formatForCode(it.getEntity().getName()), "viewcsv");
    _builder.append(_displayField);
    _builder.append("\"");
    return _builder;
  }
  
  private CharSequence _displayEntry(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\"{% if not ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getEntity().getName());
    _builder.append(_formatForCode);
    _builder.append(".");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append(" %}0{% else %}1{% endif %}\"");
    return _builder;
  }
  
  private CharSequence displayRelatedEntry(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String relationAliasName = this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, useTarget));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression = null;
    if ((!(useTarget).booleanValue())) {
      _xifexpression = it.getTarget();
    } else {
      _xifexpression = it.getSource();
    }
    final DataObject mainEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    String _formatForCode = this._formattingExtensions.formatForCode(mainEntity.getName());
    String _plus = (_formatForCode + ".");
    final String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    _builder.append(";\"{% if ");
    _builder.append(relObjName);
    _builder.append("|default %}{{ ");
    _builder.append(relObjName);
    _builder.append(".getTitleFromDisplayPattern() }}{% endif %}\"");
    return _builder;
  }
  
  private CharSequence displayRelatedEntries(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String relationAliasName = this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, useTarget));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression = null;
    if ((!(useTarget).booleanValue())) {
      _xifexpression = it.getTarget();
    } else {
      _xifexpression = it.getSource();
    }
    final DataObject mainEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    String _formatForCode = this._formattingExtensions.formatForCode(mainEntity.getName());
    String _plus = (_formatForCode + ".");
    final String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    _builder.append(";\"");
    _builder.newLine();
    _builder.append("{% if ");
    _builder.append(relObjName);
    _builder.append("|default %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% for relatedItem in ");
    _builder.append(relObjName, "    ");
    _builder.append(" %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ relatedItem.getTitleFromDisplayPattern() }}{% if not loop.last %}, {% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("\"");
    return _builder;
  }
  
  private CharSequence displayEntry(final DerivedField it) {
    if (it instanceof BooleanField) {
      return _displayEntry((BooleanField)it);
    } else if (it != null) {
      return _displayEntry(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
