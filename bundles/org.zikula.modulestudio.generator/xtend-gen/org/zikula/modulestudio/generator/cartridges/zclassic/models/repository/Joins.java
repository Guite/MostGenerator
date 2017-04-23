package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Joins {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
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
    _builder.append("* @return String Enhancement for select clause");
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
      final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
        Application _application = it_1.getSource().getApplication();
        return Boolean.valueOf(Objects.equal(_application, app));
      };
      Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it), _function);
      for(final JoinRelationship relation : _filter) {
        CharSequence _addJoin = this.addJoin(relation, Boolean.valueOf(false), "select");
        _builder.append(_addJoin, "    ");
      }
    }
    {
      final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship it_1) -> {
        Application _application = it_1.getTarget().getApplication();
        return Boolean.valueOf(Objects.equal(_application, app));
      };
      Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), _function_1);
      for(final JoinRelationship relation_1 : _filter_1) {
        CharSequence _addJoin_1 = this.addJoin(relation_1, Boolean.valueOf(true), "select");
        _builder.append(_addJoin_1, "    ");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasJoinsToOtherApplications = this.hasJoinsToOtherApplications(it, app);
      if (_hasJoinsToOtherApplications) {
        _builder.append("    ");
        _builder.append("$kernel = \\ServiceUtil::get(\'kernel\');");
        _builder.newLine();
        {
          final Function1<JoinRelationship, Boolean> _function_2 = (JoinRelationship it_1) -> {
            Application _application = it_1.getSource().getApplication();
            return Boolean.valueOf((!Objects.equal(_application, app)));
          };
          Iterable<JoinRelationship> _filter_2 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it), _function_2);
          for(final JoinRelationship relation_2 : _filter_2) {
            _builder.append("    ");
            _builder.append("if ($kernel->isBundle(\'");
            String _appName = this._utils.appName(relation_2.getSource().getApplication());
            _builder.append(_appName, "    ");
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
          final Function1<JoinRelationship, Boolean> _function_3 = (JoinRelationship it_1) -> {
            Application _application = it_1.getTarget().getApplication();
            return Boolean.valueOf((!Objects.equal(_application, app)));
          };
          Iterable<JoinRelationship> _filter_3 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), _function_3);
          for(final JoinRelationship relation_3 : _filter_3) {
            _builder.append("    ");
            _builder.append("if ($kernel->isBundle(\'");
            String _appName_1 = this._utils.appName(relation_3.getTarget().getApplication());
            _builder.append(_appName_1, "    ");
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
    _builder.append("* @param QueryBuilder $qb Query builder instance used to create the query");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return QueryBuilder The query builder enriched by additional joins");
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
      final Function1<JoinRelationship, Boolean> _function_4 = (JoinRelationship it_1) -> {
        Application _application = it_1.getSource().getApplication();
        return Boolean.valueOf(Objects.equal(_application, app));
      };
      Iterable<JoinRelationship> _filter_4 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it), _function_4);
      for(final JoinRelationship relation_4 : _filter_4) {
        CharSequence _addJoin_4 = this.addJoin(relation_4, Boolean.valueOf(false), "from");
        _builder.append(_addJoin_4, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      final Function1<JoinRelationship, Boolean> _function_5 = (JoinRelationship it_1) -> {
        Application _application = it_1.getTarget().getApplication();
        return Boolean.valueOf(Objects.equal(_application, app));
      };
      Iterable<JoinRelationship> _filter_5 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), _function_5);
      for(final JoinRelationship relation_5 : _filter_5) {
        CharSequence _addJoin_5 = this.addJoin(relation_5, Boolean.valueOf(true), "from");
        _builder.append(_addJoin_5, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _hasJoinsToOtherApplications_1 = this.hasJoinsToOtherApplications(it, app);
      if (_hasJoinsToOtherApplications_1) {
        _builder.append("    ");
        _builder.append("$kernel = \\ServiceUtil::get(\'kernel\');");
        _builder.newLine();
        {
          final Function1<JoinRelationship, Boolean> _function_6 = (JoinRelationship it_1) -> {
            Application _application = it_1.getSource().getApplication();
            return Boolean.valueOf((!Objects.equal(_application, app)));
          };
          Iterable<JoinRelationship> _filter_6 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it), _function_6);
          for(final JoinRelationship relation_6 : _filter_6) {
            _builder.append("    ");
            _builder.append("if ($kernel->isBundle(\'");
            String _appName_2 = this._utils.appName(relation_6.getSource().getApplication());
            _builder.append(_appName_2, "    ");
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
          final Function1<JoinRelationship, Boolean> _function_7 = (JoinRelationship it_1) -> {
            Application _application = it_1.getTarget().getApplication();
            return Boolean.valueOf((!Objects.equal(_application, app)));
          };
          Iterable<JoinRelationship> _filter_7 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), _function_7);
          for(final JoinRelationship relation_7 : _filter_7) {
            _builder.append("    ");
            _builder.append("if ($kernel->isBundle(\'");
            String _appName_3 = this._utils.appName(relation_7.getTarget().getApplication());
            _builder.append(_appName_3, "    ");
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
  
  private boolean hasJoinsToOtherApplications(final Entity it, final Application app) {
    return ((!IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it), ((Function1<JoinRelationship, Boolean>) (JoinRelationship it_1) -> {
      Application _application = it_1.getSource().getApplication();
      return Boolean.valueOf((!Objects.equal(_application, app)));
    })))) || (!IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), ((Function1<JoinRelationship, Boolean>) (JoinRelationship it_1) -> {
      Application _application = it_1.getTarget().getApplication();
      return Boolean.valueOf((!Objects.equal(_application, app)));
    })))));
  }
  
  private CharSequence addJoin(final JoinRelationship it, final Boolean incoming, final String target) {
    CharSequence _xblockexpression = null;
    {
      final String relationAliasName = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, incoming));
      CharSequence _xifexpression = null;
      boolean _equals = Objects.equal(target, "select");
      if (_equals) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append(", tbl");
        _builder.append(relationAliasName);
        _xifexpression = _builder;
      } else {
        CharSequence _xifexpression_1 = null;
        boolean _equals_1 = Objects.equal(target, "from");
        if (_equals_1) {
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append("$qb->leftJoin(\'tbl.");
          String _firstLower = StringExtensions.toFirstLower(relationAliasName);
          _builder_1.append(_firstLower);
          _builder_1.append("\', \'tbl");
          _builder_1.append(relationAliasName);
          _builder_1.append("\');");
          _builder_1.newLineIfNotEmpty();
          _xifexpression_1 = _builder_1;
        }
        _xifexpression = _xifexpression_1;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
}
