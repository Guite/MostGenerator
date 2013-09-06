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
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
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
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Xml {
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
    String _plus_1 = (_plus + " xml view templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    boolean _hasActions = this._controllerExtensions.hasActions(controller, "view");
    if (_hasActions) {
      String _name_1 = it.getName();
      String _templateFileWithExtension = this._namingExtensions.templateFileWithExtension(controller, _name_1, "view", "xml");
      CharSequence _xmlView = this.xmlView(it, appName, controller);
      fsa.generateFile(_templateFileWithExtension, _xmlView);
    }
    boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "display");
    if (_hasActions_1) {
      String _name_2 = it.getName();
      String _templateFileWithExtension_1 = this._namingExtensions.templateFileWithExtension(controller, _name_2, "display", "xml");
      CharSequence _xmlDisplay = this.xmlDisplay(it, appName, controller);
      fsa.generateFile(_templateFileWithExtension_1, _xmlDisplay);
    }
    String _name_3 = it.getName();
    String _templateFileWithExtension_2 = this._namingExtensions.templateFileWithExtension(controller, _name_3, "include", "xml");
    CharSequence _xmlInclude = this.xmlInclude(it, appName, controller);
    fsa.generateFile(_templateFileWithExtension_2, _xmlInclude);
  }
  
  private CharSequence xmlView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" view xml view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("TemplateHeaders contentType=\'text/xml\'}<?xml version=\"1.0\" encoding=\"{charset}\" ?>");
    _builder.newLineIfNotEmpty();
    _builder.append("<");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForCode = this._formattingExtensions.formatForCode(_nameMultiple_1);
    _builder.append(_formatForCode, "");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("{foreach item=\'item\' from=$items}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{include file=\'");
    String _formattedName_1 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_1, "    ");
    _builder.append("/");
    _builder.append(objName, "    ");
    _builder.append("/include.xml\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<no");
    String _name_1 = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append(" />");
    _builder.newLineIfNotEmpty();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("</");
    String _nameMultiple_2 = it.getNameMultiple();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_nameMultiple_2);
    _builder.append(_formatForCode_1, "");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence xmlDisplay(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" display xml view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("TemplateHeaders contentType=\'text/xml\'}<?xml version=\"1.0\" encoding=\"{charset}\" ?>");
    _builder.newLineIfNotEmpty();
    _builder.append("{getbaseurl assign=\'baseurl\'}");
    _builder.newLine();
    _builder.append("{include file=\'");
    String _formattedName_1 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_1, "");
    _builder.append("/");
    _builder.append(objName, "");
    _builder.append("/include.xml\' item=$");
    _builder.append(objName, "");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence xmlInclude(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" xml inclusion template in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("<");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      for(final DerivedField pkField : _primaryKeyFields) {
        _builder.append(" ");
        String _name_1 = pkField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode, "");
        _builder.append("=\"{$item.");
        String _name_2 = pkField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "");
        _builder.append("}\"");
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append(" createdon=\"{$item.createdDate|dateformat}\" updatedon=\"{$item.updatedDate|dateformat}\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          boolean _isPrimaryKey = e.isPrimaryKey();
          return Boolean.valueOf(_isPrimaryKey);
        }
      };
      Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_derivedFields, _function);
      for(final DerivedField field : _filter) {
        CharSequence _displayEntry = this.displayEntry(field, controller);
        _builder.append(_displayEntry, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<DerivedField> _derivedFields_1 = this._modelExtensions.getDerivedFields(it);
      final Function1<DerivedField,Boolean> _function_1 = new Function1<DerivedField,Boolean>() {
        public Boolean apply(final DerivedField e) {
          boolean _and = false;
          boolean _isPrimaryKey = e.isPrimaryKey();
          boolean _not = (!_isPrimaryKey);
          if (!_not) {
            _and = false;
          } else {
            String _name = e.getName();
            boolean _notEquals = (!Objects.equal(_name, "workflowState"));
            _and = (_not && _notEquals);
          }
          return Boolean.valueOf(_and);
        }
      };
      Iterable<DerivedField> _filter_1 = IterableExtensions.<DerivedField>filter(_derivedFields_1, _function_1);
      for(final DerivedField field_1 : _filter_1) {
        CharSequence _displayEntry_1 = this.displayEntry(field_1, controller);
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
            _builder.append(">{$item.");
            _builder.append(geoFieldName, "    ");
            _builder.append("|");
            String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
            _builder.append(_formatForDB_1, "    ");
            _builder.append("FormatGeoData}</");
            _builder.append(geoFieldName, "    ");
            _builder.append(">");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      if (_isSoftDeleteable) {
        _builder.append("    ");
        _builder.append("<deletedAt>{$item.deletedAt|dateformat:\'datebrief\'}</deletedAt>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("<workflowState>{$item.workflowState|");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_2, "    ");
    _builder.append("ObjectState:false|lower}</workflowState>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _incoming = it.getIncoming();
      Iterable<OneToManyRelationship> _filter_2 = Iterables.<OneToManyRelationship>filter(_incoming, OneToManyRelationship.class);
      final Function1<OneToManyRelationship,Boolean> _function_2 = new Function1<OneToManyRelationship,Boolean>() {
        public Boolean apply(final OneToManyRelationship e) {
          boolean _isBidirectional = e.isBidirectional();
          return Boolean.valueOf(_isBidirectional);
        }
      };
      Iterable<OneToManyRelationship> _filter_3 = IterableExtensions.<OneToManyRelationship>filter(_filter_2, _function_2);
      for(final OneToManyRelationship relation : _filter_3) {
        CharSequence _displayRelatedEntry = this.displayRelatedEntry(relation, controller, Boolean.valueOf(false));
        _builder.append(_displayRelatedEntry, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _outgoing = it.getOutgoing();
      Iterable<OneToOneRelationship> _filter_4 = Iterables.<OneToOneRelationship>filter(_outgoing, OneToOneRelationship.class);
      for(final OneToOneRelationship relation_1 : _filter_4) {
        CharSequence _displayRelatedEntry_1 = this.displayRelatedEntry(relation_1, controller, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntry_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _incoming_1 = it.getIncoming();
      Iterable<ManyToManyRelationship> _filter_5 = Iterables.<ManyToManyRelationship>filter(_incoming_1, ManyToManyRelationship.class);
      final Function1<ManyToManyRelationship,Boolean> _function_3 = new Function1<ManyToManyRelationship,Boolean>() {
        public Boolean apply(final ManyToManyRelationship e) {
          boolean _isBidirectional = e.isBidirectional();
          return Boolean.valueOf(_isBidirectional);
        }
      };
      Iterable<ManyToManyRelationship> _filter_6 = IterableExtensions.<ManyToManyRelationship>filter(_filter_5, _function_3);
      for(final ManyToManyRelationship relation_2 : _filter_6) {
        CharSequence _displayRelatedEntries = this.displayRelatedEntries(relation_2, controller, Boolean.valueOf(false));
        _builder.append(_displayRelatedEntries, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _outgoing_1 = it.getOutgoing();
      Iterable<OneToManyRelationship> _filter_7 = Iterables.<OneToManyRelationship>filter(_outgoing_1, OneToManyRelationship.class);
      for(final OneToManyRelationship relation_3 : _filter_7) {
        CharSequence _displayRelatedEntries_1 = this.displayRelatedEntries(relation_3, controller, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntries_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Relationship> _outgoing_2 = it.getOutgoing();
      Iterable<ManyToManyRelationship> _filter_8 = Iterables.<ManyToManyRelationship>filter(_outgoing_2, ManyToManyRelationship.class);
      for(final ManyToManyRelationship relation_4 : _filter_8) {
        CharSequence _displayRelatedEntries_2 = this.displayRelatedEntries(relation_4, controller, Boolean.valueOf(true));
        _builder.append(_displayRelatedEntries_2, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("</");
    String _name_3 = it.getName();
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_name_3);
    _builder.append(_formatForDB_3, "");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _displayEntry(final DerivedField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append(">");
    CharSequence _displayField = this.fieldHelper.displayField(it, "item", "viewxml");
    _builder.append(_displayField, "");
    _builder.append("</");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _displayEntry(final BooleanField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append(">{if !$item.");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append("}0{else}1{/if}</");
    String _name_2 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayEntryCdata(final DerivedField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("><![CDATA[");
    CharSequence _displayField = this.fieldHelper.displayField(it, "item", "viewxml");
    _builder.append(_displayField, "");
    _builder.append("]]></");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _displayEntry(final StringField it, final Controller controller) {
    CharSequence _displayEntryCdata = this.displayEntryCdata(it, controller);
    return _displayEntryCdata;
  }
  
  private CharSequence _displayEntry(final TextField it, final Controller controller) {
    CharSequence _displayEntryCdata = this.displayEntryCdata(it, controller);
    return _displayEntryCdata;
  }
  
  private CharSequence _displayEntry(final UploadField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    CharSequence _displayField = this.fieldHelper.displayField(it, "item", "viewxml");
    _builder.append(_displayField, "");
    _builder.append("</");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayRelatedEntry(final JoinRelationship it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
    _builder.newLineIfNotEmpty();
    Entity _xifexpression = null;
    if ((useTarget).booleanValue()) {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    } else {
      Entity _source = it.getSource();
      _xifexpression = _source;
    }
    final Entity linkEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    final String relObjName = ("item." + relationAliasName);
    _builder.newLineIfNotEmpty();
    final DerivedField leadingField = this._modelExtensions.getLeadingField(linkEntity);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("<");
        String _firstLower = StringExtensions.toFirstLower(relationAliasName);
        _builder.append(_firstLower, "");
        _builder.append(">{if isset($");
        _builder.append(relObjName, "");
        _builder.append(") && $");
        _builder.append(relObjName, "");
        _builder.append(" ne null}{$");
        _builder.append(relObjName, "");
        _builder.append(".");
        String _name = leadingField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("|default:\'\'}{/if}</");
        String _firstLower_1 = StringExtensions.toFirstLower(relationAliasName);
        _builder.append(_firstLower_1, "");
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        String _name_1 = linkEntity.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence displayRelatedEntries(final JoinRelationship it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
    _builder.newLineIfNotEmpty();
    Entity _xifexpression = null;
    if ((useTarget).booleanValue()) {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    } else {
      Entity _source = it.getSource();
      _xifexpression = _source;
    }
    final Entity linkEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    final String relObjName = ("item." + relationAliasName);
    _builder.newLineIfNotEmpty();
    final DerivedField leadingField = this._modelExtensions.getLeadingField(linkEntity);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("<");
        String _firstLower = StringExtensions.toFirstLower(relationAliasName);
        _builder.append(_firstLower, "");
        _builder.append(">");
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
        _builder.append("<");
        String _name = linkEntity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append(">{$relatedItem.");
        String _name_1 = leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("|default:\'\'}</");
        String _name_2 = linkEntity.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "    ");
        _builder.append(">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("</");
        String _firstLower_1 = StringExtensions.toFirstLower(relationAliasName);
        _builder.append(_firstLower_1, "");
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        String _nameMultiple = linkEntity.getNameMultiple();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
        _builder.append(_formatForDisplay, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence displayEntry(final DerivedField it, final Controller controller) {
    if (it instanceof StringField) {
      return _displayEntry((StringField)it, controller);
    } else if (it instanceof TextField) {
      return _displayEntry((TextField)it, controller);
    } else if (it instanceof UploadField) {
      return _displayEntry((UploadField)it, controller);
    } else if (it instanceof BooleanField) {
      return _displayEntry((BooleanField)it, controller);
    } else if (it != null) {
      return _displayEntry(it, controller);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, controller).toString());
    }
  }
}
