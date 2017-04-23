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
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.UploadField;
import java.util.ArrayList;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Xml {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private SimpleFields fieldHelper = new SimpleFields();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating xml view templates for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String templateFilePath = "";
    boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
    if (_hasViewAction) {
      templateFilePath = this._namingExtensions.templateFileWithExtension(it, "view", "xml");
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
      boolean _not = (!_shouldBeSkipped);
      if (_not) {
        fsa.generateFile(templateFilePath, this.xmlView(it, appName));
      }
    }
    boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
    if (_hasDisplayAction) {
      templateFilePath = this._namingExtensions.templateFileWithExtension(it, "display", "xml");
      boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
      boolean _not_1 = (!_shouldBeSkipped_1);
      if (_not_1) {
        fsa.generateFile(templateFilePath, this.xmlDisplay(it, appName));
      }
    }
    templateFilePath = this._namingExtensions.templateFileWithExtension(it, "include", "xml");
    boolean _shouldBeSkipped_2 = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not_2 = (!_shouldBeSkipped_2);
    if (_not_2) {
      fsa.generateFile(templateFilePath, this.xmlInclude(it, appName));
    }
  }
  
  private CharSequence xmlView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" view xml view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("<?xml version=\"1.0\" encoding=\"{{ pageGetVar(\'meta.charset\') }}\" ?>");
    _builder.newLine();
    _builder.append("<");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getNameMultiple());
    _builder.append(_formatForCode);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("{% for ");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ include(\'@");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("/include.xml.twig\') }}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<no");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "    ");
    _builder.append(" />");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("</");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getNameMultiple());
    _builder.append(_formatForCode_2);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence xmlDisplay(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" display xml view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("<?xml version=\"1.0\" encoding=\"{{ pageGetVar(\'meta.charset\') }}\" ?>");
    _builder.newLine();
    _builder.append("{{ include(\'@");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append("/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("/include.xml.twig\') }}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence xmlInclude(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" xml inclusion template #}");
    _builder.newLineIfNotEmpty();
    _builder.append("<");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      for(final DerivedField pkField : _primaryKeyFields) {
        _builder.append(" ");
        String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode);
        _builder.append("=\"{{ ");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1);
        _builder.append(".");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode_2);
        _builder.append(" }}\"");
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append(" createdon=\"{{ ");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_3);
        _builder.append(".createdDate|localizeddate(\'medium\', \'short\') }}\" updatedon=\"{{ ");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_4);
        _builder.append(".updatedDate|localizeddate(\'medium\', \'short\') }}\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
        return Boolean.valueOf(it_1.isPrimaryKey());
      };
      Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(this._modelExtensions.getDerivedFields(it), _function);
      for(final DerivedField field : _filter) {
        CharSequence _displayEntry = this.displayEntry(field);
        _builder.append(_displayEntry, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_1) -> {
        return Boolean.valueOf(((!it_1.isPrimaryKey()) && (!Objects.equal(it_1.getName(), "workflowState"))));
      };
      Iterable<DerivedField> _filter_1 = IterableExtensions.<DerivedField>filter(this._modelExtensions.getDerivedFields(it), _function_1);
      for(final DerivedField field_1 : _filter_1) {
        CharSequence _displayEntry_1 = this.displayEntry(field_1);
        _builder.append(_displayEntry_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList("latitude", "longitude");
          for(final String geoFieldName : _newArrayList) {
            _builder.append("    ");
            _builder.append("<");
            _builder.append(geoFieldName, "    ");
            _builder.append(">{{ ");
            String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_5, "    ");
            _builder.append(".");
            _builder.append(geoFieldName, "    ");
            _builder.append("|");
            String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
            _builder.append(_formatForDB_1, "    ");
            _builder.append("_geoData }}</");
            _builder.append(geoFieldName, "    ");
            _builder.append(">");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("<workflowState>{{ ");
    String _formatForCode_6 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_6, "    ");
    _builder.append(".workflowState|");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_2, "    ");
    _builder.append("_objectState(false)|lower }}</workflowState>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      final Function1<OneToManyRelationship, Boolean> _function_2 = (OneToManyRelationship it_1) -> {
        return Boolean.valueOf(it_1.isBidirectional());
      };
      Iterable<OneToManyRelationship> _filter_2 = IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function_2);
      for(final OneToManyRelationship relation : _filter_2) {
        CharSequence _displayRelatedEntry = this.displayRelatedEntry(relation, Boolean.valueOf(false));
        _builder.append(_displayRelatedEntry, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<OneToOneRelationship> _filter_3 = Iterables.<OneToOneRelationship>filter(it.getOutgoing(), OneToOneRelationship.class);
      for(final OneToOneRelationship relation_1 : _filter_3) {
        CharSequence _displayRelatedEntry_1 = this.displayRelatedEntry(relation_1, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntry_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      final Function1<ManyToManyRelationship, Boolean> _function_3 = (ManyToManyRelationship it_1) -> {
        return Boolean.valueOf(it_1.isBidirectional());
      };
      Iterable<ManyToManyRelationship> _filter_4 = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(it.getIncoming(), ManyToManyRelationship.class), _function_3);
      for(final ManyToManyRelationship relation_2 : _filter_4) {
        CharSequence _displayRelatedEntries = this.displayRelatedEntries(relation_2, Boolean.valueOf(false));
        _builder.append(_displayRelatedEntries, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<OneToManyRelationship> _filter_5 = Iterables.<OneToManyRelationship>filter(it.getOutgoing(), OneToManyRelationship.class);
      for(final OneToManyRelationship relation_3 : _filter_5) {
        CharSequence _displayRelatedEntries_1 = this.displayRelatedEntries(relation_3, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntries_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<ManyToManyRelationship> _filter_6 = Iterables.<ManyToManyRelationship>filter(it.getOutgoing(), ManyToManyRelationship.class);
      for(final ManyToManyRelationship relation_4 : _filter_6) {
        CharSequence _displayRelatedEntries_2 = this.displayRelatedEntries(relation_4, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntries_2, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("</");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_3);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _displayEntry(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(">");
    CharSequence _displayField = this.fieldHelper.displayField(it, this._formattingExtensions.formatForCode(it.getEntity().getName()), "viewxml");
    _builder.append(_displayField);
    _builder.append("</");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _displayEntry(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(">{% if not ");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getEntity().getName());
    _builder.append(_formatForCode_1);
    _builder.append(".");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2);
    _builder.append(" %}0{% else %}1{% endif %}</");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayEntryCdata(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("><![CDATA[");
    CharSequence _displayField = this.fieldHelper.displayField(it, this._formattingExtensions.formatForCode(it.getEntity().getName()), "viewxml");
    _builder.append(_displayField);
    _builder.append("]]></");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _displayEntry(final StringField it) {
    return this.displayEntryCdata(it);
  }
  
  private CharSequence _displayEntry(final TextField it) {
    return this.displayEntryCdata(it);
  }
  
  private CharSequence _displayEntry(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    CharSequence _displayField = this.fieldHelper.displayField(it, this._formattingExtensions.formatForCode(it.getEntity().getName()), "viewxml");
    _builder.append(_displayField);
    _builder.append("</");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayRelatedEntry(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String relationAliasName = this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, useTarget));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression = null;
    if ((useTarget).booleanValue()) {
      _xifexpression = it.getSource();
    } else {
      _xifexpression = it.getTarget();
    }
    String _formatForCode = this._formattingExtensions.formatForCode(_xifexpression.getName());
    String _plus = (_formatForCode + ".");
    final String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    _builder.append("<");
    String _firstLower = StringExtensions.toFirstLower(relationAliasName);
    _builder.append(_firstLower);
    _builder.append(">{% if ");
    _builder.append(relObjName);
    _builder.append("|default %}{{ ");
    _builder.append(relObjName);
    _builder.append(".getTitleFromDisplayPattern() }}{% endif %}</");
    String _firstLower_1 = StringExtensions.toFirstLower(relationAliasName);
    _builder.append(_firstLower_1);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayRelatedEntries(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String relationAliasName = this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, useTarget));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression = null;
    if ((useTarget).booleanValue()) {
      _xifexpression = it.getSource();
    } else {
      _xifexpression = it.getTarget();
    }
    String _formatForCode = this._formattingExtensions.formatForCode(_xifexpression.getName());
    String _plus = (_formatForCode + ".");
    final String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      _xifexpression_1 = it.getTarget();
    } else {
      _xifexpression_1 = it.getSource();
    }
    final DataObject linkEntity = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    _builder.append("<");
    String _firstLower = StringExtensions.toFirstLower(relationAliasName);
    _builder.append(_firstLower);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
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
    _builder.append("<");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(linkEntity.getName());
    _builder.append(_formatForCode_1, "    ");
    _builder.append(">{{ relatedItem.getTitleFromDisplayPattern() }}</");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(linkEntity.getName());
    _builder.append(_formatForCode_2, "    ");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("</");
    String _firstLower_1 = StringExtensions.toFirstLower(relationAliasName);
    _builder.append(_firstLower_1);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayEntry(final DerivedField it) {
    if (it instanceof StringField) {
      return _displayEntry((StringField)it);
    } else if (it instanceof TextField) {
      return _displayEntry((TextField)it);
    } else if (it instanceof UploadField) {
      return _displayEntry((UploadField)it);
    } else if (it instanceof BooleanField) {
      return _displayEntry((BooleanField)it);
    } else if (it != null) {
      return _displayEntry(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
