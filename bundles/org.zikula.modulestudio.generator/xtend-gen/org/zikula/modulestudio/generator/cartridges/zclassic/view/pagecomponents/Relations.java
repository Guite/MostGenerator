package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.UploadField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Relations {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void displayItemList(final Entity it, final Application app, final Boolean many, final IFileSystemAccess fsa) {
    String _xifexpression = null;
    if ((many).booleanValue()) {
      _xifexpression = "Many";
    } else {
      _xifexpression = "One";
    }
    String _plus = ("includeDisplayItemList" + _xifexpression);
    final String templatePath = this._namingExtensions.templateFile(it, _plus);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(app, templatePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      fsa.generateFile(templatePath, this.inclusionTemplate(it, app, many));
    }
  }
  
  private CharSequence inclusionTemplate(final Entity it, final Application app, final Boolean many) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: inclusion template for display of related ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% set hasAdminPermission = hasPermission(\'");
    String _appName = this._utils.appName(app);
    _builder.append(_appName);
    _builder.append(":");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append(":\', \'::\', \'ACCESS_");
    {
      EntityWorkflowType _workflow = it.getWorkflow();
      boolean _equals = Objects.equal(_workflow, EntityWorkflowType.NONE);
      if (_equals) {
        _builder.append("EDIT");
      } else {
        _builder.append("COMMENT");
      }
    }
    _builder.append("\') %}");
    _builder.newLineIfNotEmpty();
    {
      boolean _isOwnerPermission = it.isOwnerPermission();
      if (_isOwnerPermission) {
        _builder.append("{% set hasEditPermission = hasPermission(\'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1);
        _builder.append(":");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append(":\', \'::\', \'ACCESS_");
        {
          EntityWorkflowType _workflow_1 = it.getWorkflow();
          boolean _equals_1 = Objects.equal(_workflow_1, EntityWorkflowType.NONE);
          if (_equals_1) {
            _builder.append("EDIT");
          } else {
            _builder.append("COMMENT");
          }
        }
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("{% if nolink is not defined %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set nolink = false %}");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    {
      if ((many).booleanValue()) {
        _builder.append("{% if items|default and items|length > 0 %}");
        _builder.newLine();
        _builder.append("<ul class=\"list-group ");
        String _lowerCase = this._utils.appName(app).toLowerCase();
        _builder.append(_lowerCase);
        _builder.append("-related-item-list ");
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB);
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
        _builder.append("{% for item in items %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% if hasAdminPermission or item.workflowState == \'approved\'");
        {
          boolean _isOwnerPermission_1 = it.isOwnerPermission();
          if (_isOwnerPermission_1) {
            _builder.append(" or (item.workflowState == \'defered\' and hasEditPermission and currentUser|default and item.createdBy.getUid() == currentUser.uid)");
          }
        }
        _builder.append(" %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<li class=\"list-group-item\">");
        _builder.newLine();
      }
    }
    _builder.append("<h4");
    {
      if ((many).booleanValue()) {
        _builder.append(" class=\"list-group-item-heading\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction_1) {
        _builder.append("{% spaceless %}");
        _builder.newLine();
        _builder.append("{% if not nolink %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<a href=\"{{ path(\'");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB_1, "    ");
        _builder.append("_");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_2, "    ");
        _builder.append("_\' ~ routeArea ~ \'display\'");
        CharSequence _routeParams = this._urlExtensions.routeParams(it, "item", Boolean.valueOf(true));
        _builder.append(_routeParams, "    ");
        _builder.append(") }}\" title=\"{{ item.getTitleFromDisplayPattern()|e(\'html_attr\') }}\">");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("{{ item.getTitleFromDisplayPattern() }}");
    _builder.newLine();
    {
      boolean _hasDisplayAction_2 = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction_2) {
        _builder.append("{% if not nolink %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</a>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<a id=\"");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("Item");
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate("_", "    ");
            }
            _builder.append("{{ item.");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode_1, "    ");
            _builder.append(" }}");
          }
        }
        _builder.append("Display\" href=\"{{ path(\'");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB_3, "    ");
        _builder.append("_");
        String _formatForDB_4 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_4, "    ");
        _builder.append("_\' ~ routeArea ~ \'display\', { ");
        CharSequence _routePkParams = this._urlExtensions.routePkParams(it, "item", Boolean.valueOf(true));
        _builder.append(_routePkParams, "    ");
        CharSequence _appendSlug = this._urlExtensions.appendSlug(it, "item", Boolean.valueOf(true));
        _builder.append(_appendSlug, "    ");
        _builder.append(", \'raw\': 1 }) }}\" title=\"{{ __(\'Open quick view window\') }}\" class=\"");
        String _lowerCase_1 = this._utils.vendorAndName(it.getApplication()).toLowerCase();
        _builder.append(_lowerCase_1, "    ");
        _builder.append("-inline-window hidden\" data-modal-title=\"{{ item.getTitleFromDisplayPattern()|e(\'html_attr\') }}\"><span class=\"fa fa-id-card-o\"></span></a>");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("{% endspaceless %}");
        _builder.newLine();
      }
    }
    _builder.append("</h4>");
    _builder.newLine();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        final String imageFieldName = this._formattingExtensions.formatForCode(IterableExtensions.<UploadField>head(this._modelExtensions.getImageFieldsEntity(it)).getName());
        _builder.newLineIfNotEmpty();
        _builder.append("{% if item.");
        _builder.append(imageFieldName);
        _builder.append(" is not empty and item.");
        _builder.append(imageFieldName);
        _builder.append("Meta.isImage %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<p");
        {
          if ((many).booleanValue()) {
            _builder.append(" class=\"list-group-item-text\"");
          }
        }
        _builder.append(">");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<img src=\"{{ item.");
        _builder.append(imageFieldName, "        ");
        _builder.append(".getPathname()|imagine_filter(\'zkroot\', relationThumbRuntimeOptions) }}\" alt=\"{{ item.getTitleFromDisplayPattern()|e(\'html_attr\') }}\" width=\"{{ relationThumbRuntimeOptions.thumbnail.size[0] }}\" height=\"{{ relationThumbRuntimeOptions.thumbnail.size[1] }}\" class=\"img-rounded\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</p>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    {
      if ((many).booleanValue()) {
        _builder.append("    ");
        _builder.append("</li>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("{% endfor %}");
        _builder.newLine();
        _builder.append("</ul>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public CharSequence displayRelatedItems(final JoinRelationship it, final String appName, final Entity relatedEntity) {
    StringConcatenation _builder = new StringConcatenation();
    boolean _xifexpression = false;
    if ((Objects.equal(it.getTarget(), relatedEntity) && (!Objects.equal(it.getSource(), relatedEntity)))) {
      _xifexpression = true;
    } else {
      _xifexpression = false;
    }
    final boolean incoming = _xifexpression;
    _builder.newLineIfNotEmpty();
    final boolean useTarget = (!incoming);
    _builder.newLineIfNotEmpty();
    final String relationAliasName = StringExtensions.toFirstLower(this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(useTarget))));
    _builder.newLineIfNotEmpty();
    final String relationAliasNameParam = this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf((!useTarget))));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression_1 = null;
    if ((!useTarget)) {
      _xifexpression_1 = it.getSource();
    } else {
      _xifexpression_1 = it.getTarget();
    }
    final Entity otherEntity = ((Entity) _xifexpression_1);
    _builder.newLineIfNotEmpty();
    final boolean many = this._modelJoinExtensions.isManySideDisplay(it, useTarget);
    _builder.newLineIfNotEmpty();
    _builder.append("{% if routeArea == \'admin\' %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<h4>{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(this._modelExtensions.getEntityNameSingularPlural(otherEntity, Boolean.valueOf(many)));
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\') }}</h4>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<h3>{{ __(\'");
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(this._modelExtensions.getEntityNameSingularPlural(otherEntity, Boolean.valueOf(many)));
    _builder.append(_formatForDisplayCapital_1, "    ");
    _builder.append("\') }}</h3>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% if ");
    String _formatForCode = this._formattingExtensions.formatForCode(relatedEntity.getName());
    _builder.append(_formatForCode);
    _builder.append(".");
    _builder.append(relationAliasName);
    _builder.append("|default %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ include(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'@");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "        ");
    _builder.append("/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(otherEntity.getName());
    _builder.append(_formatForCodeCapital, "        ");
    _builder.append("/includeDisplayItemList");
    {
      if (many) {
        _builder.append("Many");
      } else {
        _builder.append("One");
      }
    }
    _builder.append(".html.twig\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{ item");
    {
      if (many) {
        _builder.append("s");
      }
    }
    _builder.append(": ");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(relatedEntity.getName());
    _builder.append(_formatForCode_1, "        ");
    _builder.append(".");
    _builder.append(relationAliasName, "        ");
    _builder.append(" }");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(") }}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasEditAction = this._controllerExtensions.hasEditAction(otherEntity);
      if (_hasEditAction) {
        {
          if ((!many)) {
            _builder.append("{% if ");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(relatedEntity.getName());
            _builder.append(_formatForCode_2);
            _builder.append(".");
            _builder.append(relationAliasName);
            _builder.append(" is not defined or ");
            String _formatForCode_3 = this._formattingExtensions.formatForCode(relatedEntity.getName());
            _builder.append(_formatForCode_3);
            _builder.append(".");
            _builder.append(relationAliasName);
            _builder.append(" is null %}");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("{% set mayManage = hasPermission(\'");
        _builder.append(appName);
        _builder.append(":");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(otherEntity.getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append(":\', \'::\', \'ACCESS_");
        {
          boolean _isOwnerPermission = otherEntity.isOwnerPermission();
          if (_isOwnerPermission) {
            _builder.append("ADD");
          } else {
            EntityWorkflowType _workflow = otherEntity.getWorkflow();
            boolean _equals = Objects.equal(_workflow, EntityWorkflowType.NONE);
            if (_equals) {
              _builder.append("EDIT");
            } else {
              _builder.append("COMMENT");
            }
          }
        }
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("{% if mayManage");
        {
          boolean _isOwnerPermission_1 = otherEntity.isOwnerPermission();
          if (_isOwnerPermission_1) {
            _builder.append(" or (currentUser|default and ");
            String _formatForCode_4 = this._formattingExtensions.formatForCode(relatedEntity.getName());
            _builder.append(_formatForCode_4);
            _builder.append(".createdBy|default and ");
            String _formatForCode_5 = this._formattingExtensions.formatForCode(relatedEntity.getName());
            _builder.append(_formatForCode_5);
            _builder.append(".createdBy.getUid() == currentUser.uid)");
          }
        }
        _builder.append(" %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<p class=\"managelink\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% set createTitle = __(\'Create ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(otherEntity.getName());
        _builder.append(_formatForDisplay, "        ");
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<a href=\"{{ path(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB, "        ");
        _builder.append("_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(otherEntity.getName());
        _builder.append(_formatForDB_1, "        ");
        _builder.append("_\' ~ routeArea ~ \'edit\', { ");
        _builder.append(relationAliasNameParam, "        ");
        _builder.append(": ");
        CharSequence _idFieldsAsParameterTemplate = this._modelExtensions.idFieldsAsParameterTemplate(relatedEntity);
        _builder.append(_idFieldsAsParameterTemplate, "        ");
        _builder.append(" }) }}\" title=\"{{ createTitle|e(\'html_attr\') }}\" class=\"fa fa-plus\">{{ createTitle }}</a>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</p>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
        {
          if ((!many)) {
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
}
