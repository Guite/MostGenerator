package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Joins {
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
  
  public CharSequence generate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper method to add join selections.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String Enhancement for select clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addJoinsToSelection()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selection = \'");
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _source = e.getSource();
            Models _container = _source.getContainer();
            Application _application = _container.getApplication();
            boolean _equals = Objects.equal(_application, app);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_bidirectionalIncomingJoinRelations, _function);
      for(final JoinRelationship relation : _filter) {
        CharSequence _addJoin = this.addJoin(relation, Boolean.valueOf(false), "select");
        _builder.append(_addJoin, "    ");
      }
    }
    {
      Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_1 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _target = e.getTarget();
            Models _container = _target.getContainer();
            Application _application = _container.getApplication();
            boolean _equals = Objects.equal(_application, app);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(_outgoingJoinRelations, _function_1);
      for(final JoinRelationship relation_1 : _filter_1) {
        CharSequence _addJoin_1 = this.addJoin(relation_1, Boolean.valueOf(true), "select");
        _builder.append(_addJoin_1, "    ");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations_1 = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_2 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _source = e.getSource();
            Models _container = _source.getContainer();
            Application _application = _container.getApplication();
            boolean _notEquals = (!Objects.equal(_application, app));
            return Boolean.valueOf(_notEquals);
          }
        };
      Iterable<JoinRelationship> _filter_2 = IterableExtensions.<JoinRelationship>filter(_bidirectionalIncomingJoinRelations_1, _function_2);
      for(final JoinRelationship relation_2 : _filter_2) {
        _builder.append("    ");
        _builder.append("if (ModUtil::available(\'");
        Entity _source = relation_2.getSource();
        Models _container = _source.getContainer();
        Application _application = _container.getApplication();
        String _name = _application.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$selection .= \'");
        CharSequence _addJoin_2 = this.addJoin(relation_2, Boolean.valueOf(false), "select");
        _builder.append(_addJoin_2, "        ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      Iterable<JoinRelationship> _outgoingJoinRelations_1 = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_3 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _target = e.getTarget();
            Models _container = _target.getContainer();
            Application _application = _container.getApplication();
            boolean _notEquals = (!Objects.equal(_application, app));
            return Boolean.valueOf(_notEquals);
          }
        };
      Iterable<JoinRelationship> _filter_3 = IterableExtensions.<JoinRelationship>filter(_outgoingJoinRelations_1, _function_3);
      for(final JoinRelationship relation_3 : _filter_3) {
        _builder.append("    ");
        _builder.append("if (ModUtil::available(\'");
        Entity _target = relation_3.getTarget();
        Models _container_1 = _target.getContainer();
        Application _application_1 = _container_1.getApplication();
        String _name_1 = _application_1.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$selection .= \'");
        CharSequence _addJoin_3 = this.addJoin(relation_3, Boolean.valueOf(true), "select");
        _builder.append(_addJoin_3, "        ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$selection = \', tblCategories\';");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $selection;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper method to add joins to from clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine\\ORM\\QueryBuilder $qb query builder instance used to create the query.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String Enhancement for from clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addJoinsToFrom(QueryBuilder $qb)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations_2 = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_4 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _source = e.getSource();
            Models _container = _source.getContainer();
            Application _application = _container.getApplication();
            boolean _equals = Objects.equal(_application, app);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter_4 = IterableExtensions.<JoinRelationship>filter(_bidirectionalIncomingJoinRelations_2, _function_4);
      for(final JoinRelationship relation_4 : _filter_4) {
        CharSequence _addJoin_4 = this.addJoin(relation_4, Boolean.valueOf(false), "from");
        _builder.append(_addJoin_4, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      Iterable<JoinRelationship> _outgoingJoinRelations_2 = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_5 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _target = e.getTarget();
            Models _container = _target.getContainer();
            Application _application = _container.getApplication();
            boolean _equals = Objects.equal(_application, app);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter_5 = IterableExtensions.<JoinRelationship>filter(_outgoingJoinRelations_2, _function_5);
      for(final JoinRelationship relation_5 : _filter_5) {
        CharSequence _addJoin_5 = this.addJoin(relation_5, Boolean.valueOf(true), "from");
        _builder.append(_addJoin_5, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations_3 = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_6 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _source = e.getSource();
            Models _container = _source.getContainer();
            Application _application = _container.getApplication();
            boolean _notEquals = (!Objects.equal(_application, app));
            return Boolean.valueOf(_notEquals);
          }
        };
      Iterable<JoinRelationship> _filter_6 = IterableExtensions.<JoinRelationship>filter(_bidirectionalIncomingJoinRelations_3, _function_6);
      for(final JoinRelationship relation_6 : _filter_6) {
        _builder.append("    ");
        _builder.append("if (ModUtil::available(\'");
        Entity _source_1 = relation_6.getSource();
        Models _container_2 = _source_1.getContainer();
        Application _application_2 = _container_2.getApplication();
        String _name_2 = _application_2.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_2, "    ");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        CharSequence _addJoin_6 = this.addJoin(relation_6, Boolean.valueOf(false), "from");
        _builder.append(_addJoin_6, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      Iterable<JoinRelationship> _outgoingJoinRelations_3 = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_7 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _target = e.getTarget();
            Models _container = _target.getContainer();
            Application _application = _container.getApplication();
            boolean _notEquals = (!Objects.equal(_application, app));
            return Boolean.valueOf(_notEquals);
          }
        };
      Iterable<JoinRelationship> _filter_7 = IterableExtensions.<JoinRelationship>filter(_outgoingJoinRelations_3, _function_7);
      for(final JoinRelationship relation_7 : _filter_7) {
        _builder.append("    ");
        _builder.append("if (ModUtil::available(\'");
        Entity _target_1 = relation_7.getTarget();
        Models _container_3 = _target_1.getContainer();
        Application _application_3 = _container_3.getApplication();
        String _name_3 = _application_3.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_3, "    ");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        CharSequence _addJoin_7 = this.addJoin(relation_7, Boolean.valueOf(true), "from");
        _builder.append(_addJoin_7, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _isCategorisable_1 = it.isCategorisable();
      if (_isCategorisable_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$qb->leftJoin(\'tbl.categories\', \'tblCategories\');");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $qb;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addJoin(final JoinRelationship it, final Boolean incoming, final String target) {
    CharSequence _xblockexpression = null;
    {
      String _relationAliasName = this._namingExtensions.getRelationAliasName(it, incoming);
      final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
      CharSequence _xifexpression = null;
      boolean _equals = Objects.equal(target, "select");
      if (_equals) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append(", tbl");
        _builder.append(relationAliasName, "");
        _xifexpression = _builder;
      } else {
        CharSequence _xifexpression_1 = null;
        boolean _equals_1 = Objects.equal(target, "from");
        if (_equals_1) {
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append("$qb->leftJoin(\'tbl.");
          String _firstLower = StringExtensions.toFirstLower(relationAliasName);
          _builder_1.append(_firstLower, "");
          _builder_1.append("\', \'tbl");
          _builder_1.append(relationAliasName, "");
          _builder_1.append("\');");
          _builder_1.newLineIfNotEmpty();
          _xifexpression_1 = _builder_1;
        }
        _xifexpression = _xifexpression_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
}
