package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Layout {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private IFileSystemAccess fsa;
  
  public Layout(final IFileSystemAccess fsa) {
    this.fsa = fsa;
  }
  
  public void baseTemplates(final Application it) {
    final String templatePath = this._namingExtensions.getViewPath(it);
    final String templateExtension = ".html.twig";
    String fileName = ("base" + templateExtension);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = ("base.generated" + templateExtension);
      }
      this.fsa.generateFile((templatePath + fileName), this.baseTemplate(it));
    }
    fileName = ("adminBase" + templateExtension);
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not_1 = (!_shouldBeSkipped_1);
    if (_not_1) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked_1) {
        fileName = ("adminBase.generated" + templateExtension);
      }
      this.fsa.generateFile((templatePath + fileName), this.adminBaseTemplate(it));
    }
    fileName = ("Form/bootstrap_3" + templateExtension);
    boolean _shouldBeSkipped_2 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not_2 = (!_shouldBeSkipped_2);
    if (_not_2) {
      boolean _shouldBeMarked_2 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked_2) {
        fileName = ("Form/bootstrap_3.generated" + templateExtension);
      }
      this.fsa.generateFile((templatePath + fileName), this.formBaseTemplate(it));
    }
  }
  
  public CharSequence baseTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: general base layout #}");
    _builder.newLine();
    _builder.append("{% block header %}");
    _builder.newLine();
    {
      if (((!it.getRelations().isEmpty()) && ((this._controllerExtensions.hasViewActions(it) || this._controllerExtensions.hasDisplayActions(it)) || this._controllerExtensions.hasEditActions(it)))) {
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'stylesheet\', asset(\'jquery-ui/themes/base/jquery-ui.min.css\')) }}");
        _builder.newLine();
      }
    }
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', asset(\'magnific-popup/jquery.magnific-popup.min.js\')) }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'stylesheet\', asset(\'magnific-popup/magnific-popup.css\')) }}");
        _builder.newLine();
      }
    }
    {
      if (((!it.getRelations().isEmpty()) && ((this._controllerExtensions.hasViewActions(it) || this._controllerExtensions.hasDisplayActions(it)) || this._controllerExtensions.hasEditActions(it)))) {
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'stylesheet\', asset(\'bootstrap-jqueryui/bootstrap-jqueryui.min.css\')) }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', asset(\'bootstrap-jqueryui/bootstrap-jqueryui.min.js\')) }}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(":js/");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append(".js\')) }}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "    ");
        _builder.append(":js/");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.append(".Geo.js\')) }}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        {
          if ((this._modelBehaviourExtensions.hasGeographical(it) && this._controllerExtensions.hasEditActions(it))) {
            _builder.append("    ");
            _builder.append("{% if \'edit\' in app.request.get(\'_route\') %}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{{ polyfill([\'geolocation\']) }}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      } else {
        {
          if ((this._controllerExtensions.hasEditActions(it) || this._utils.needsConfig(it))) {
            _builder.append("    ");
            _builder.append("{% if ");
            {
              boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
              if (_hasEditActions) {
                _builder.append("\'edit\' in app.request.get(\'_route\')");
                {
                  boolean _needsConfig = this._utils.needsConfig(it);
                  if (_needsConfig) {
                    _builder.append(" or ");
                  }
                }
              }
            }
            {
              boolean _needsConfig_1 = this._utils.needsConfig(it);
              if (_needsConfig_1) {
                _builder.append("\'config\' in app.request.get(\'_route\')");
              }
            }
            _builder.append(" %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{{ polyfill([");
            {
              boolean _hasGeographical_1 = this._modelBehaviourExtensions.hasGeographical(it);
              if (_hasGeographical_1) {
                _builder.append("\'geolocation\', ");
              }
            }
            _builder.append("\'forms\', \'forms-ext\']) }}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% block appTitle %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ moduleHeader(\'user\', \'");
    _builder.append("\', \'");
    _builder.append("\', false, true");
    _builder.append(", false, true");
    _builder.append(") }}");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% block titleArea %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<h2>{% block title %}{% endblock %}</h2>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{{ pageSetVar(\'title\', block(\'pageTitle\')|default(block(\'title\'))) }}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((this._generatorSettingsExtensions.generateModerationPanel(it) && this._workflowExtensions.needsApproval(it))) {
        _builder.append("{{ include(\'@");
        String _appName_4 = this._utils.appName(it);
        _builder.append(_appName_4);
        _builder.append("/Helper/includeModerationPanel.html.twig\') }}");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("{{ showflashes() }}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% block content %}{% endblock %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% block footer %}");
    _builder.newLine();
    {
      boolean _generatePoweredByBacklinksIntoFooterTemplates = this._generatorSettingsExtensions.generatePoweredByBacklinksIntoFooterTemplates(it);
      if (_generatePoweredByBacklinksIntoFooterTemplates) {
        _builder.append("    ");
        CharSequence _msWeblink = new FileHelper().msWeblink(it);
        _builder.append(_msWeblink, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence adminBaseTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: admin area base layout #}");
    _builder.newLine();
    _builder.append("{% extends \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("::base.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block header %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if not app.request.query.getBoolean(\'raw\', false) %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ adminHeader() }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ parent() }}");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block appTitle %}{# empty on purpose #}{% endblock %}");
    _builder.newLine();
    _builder.append("{% block titleArea %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<h3><span class=\"fa fa-{% block admin_page_icon %}{% endblock %}\"></span>{% block title %}{% endblock %}</h3>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block footer %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if not app.request.query.getBoolean(\'raw\', false) %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ adminFooter() }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ parent() }}");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence formBaseTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: apply some general form extensions #}");
    _builder.newLine();
    _builder.append("{% extends \'ZikulaFormExtensionBundle:Form:bootstrap_3_zikula_admin_layout.html.twig\' %}");
    _builder.newLine();
    {
      final Function1<Entity, Boolean> _function = (Entity e) -> {
        boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<DateField>filter(e.getFields(), DateField.class));
        return Boolean.valueOf((!_isEmpty));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append("{%- block date_widget -%}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{- parent() -}}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{%- if not required -%}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<span class=\"help-block\"><a id=\"{{ id }}ResetVal\" href=\"javascript:void(0);\" class=\"hidden\">{{ __(\'Reset to empty value\') }}</a></span>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{%- endif -%}");
        _builder.newLine();
        _builder.append("{%- endblock -%}");
        _builder.newLine();
      }
    }
    {
      final Function1<Entity, Boolean> _function_1 = (Entity e) -> {
        boolean _isEmpty_1 = IterableExtensions.isEmpty(Iterables.<DatetimeField>filter(e.getFields(), DatetimeField.class));
        return Boolean.valueOf((!_isEmpty_1));
      };
      boolean _isEmpty_1 = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function_1));
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.newLine();
        _builder.append("{%- block datetime_widget -%}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{- parent() -}}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{%- if not required -%}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<span class=\"help-block\"><a id=\"reset{{ id }}ResetVal\" href=\"javascript:void(0);\" class=\"hidden\">{{ __(\'Reset to empty value\') }}</a></span>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{%- endif -%}");
        _builder.newLine();
        _builder.append("{%- endblock -%}");
        _builder.newLine();
      }
    }
    {
      boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields) {
        _builder.newLine();
        _builder.append("{%- block ");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB);
        _builder.append("_field_colour_widget -%}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{%- set type = type|default(\'color\') -%}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ block(\'form_widget_simple\') }}");
        _builder.newLine();
        _builder.append("{%- endblock -%}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.newLine();
        _builder.append("{%- block ");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_1);
        _builder.append("_field_translation_row -%}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{{ block(\'form_widget_compound\') }}");
        _builder.newLine();
        _builder.append("{%- endblock -%}");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.newLine();
        _builder.append("{% block ");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_2);
        _builder.append("_field_upload_label %}{% endblock %}");
        _builder.newLineIfNotEmpty();
        _builder.append("{% block ");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_3);
        _builder.append("_field_upload_row %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% spaceless %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ form_row(attribute(form, field_name)) }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"col-sm-9 col-sm-offset-3\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% if not required %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<span class=\"help-block\"><a id=\"{{ id }}_{{ field_name }}ResetVal\" href=\"javascript:void(0);\" class=\"hidden\">{{ __(\'Reset to empty value\') }}</a></span>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<span class=\"help-block\">{{ __(\'Allowed file extensions\') }}: <span id=\"{{ id }}_{{ field_name }}FileExtensions\">{{ allowed_extensions|default(\'\') }}</span></span>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% if allowed_size|default %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<span class=\"help-block\">{{ __(\'Allowed file size\') }}: {{ allowed_size }}</span>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% if file_path|default %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<span class=\"help-block\">");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{{ __(\'Current file\') }}:");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("<a href=\"{{ file_url }}\" title=\"{{ __(\'Open file\') }}\"{% if file_meta.isImage %} class=\"image-link\"{% endif %}>");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{% if file_meta.isImage %}");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("<img src=\"{{ file_path|imagine_filter(\'zkroot\', thumb_runtime_options) }}\" alt=\"{{ formatted_entity_title|e(\'html_attr\') }}\" width=\"{{ thumb_runtime_options.thumbnail.size[0] }}\" height=\"{{ thumb_runtime_options.thumbnail.size[1] }}\" class=\"img-thumbnail\" />");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{% else %}");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("{{ __(\'Download\') }} ({{ file_meta.size|");
        String _formatForDB_4 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_4, "                    ");
        _builder.append("_fileSize(file_path, false, false) }})");
        _builder.newLineIfNotEmpty();
        _builder.append("                ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("</a>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("</span>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% if not required %}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{{ form_row(attribute(form, field_name ~ \'DeleteFile\')) }}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% endspaceless %}");
        _builder.newLine();
        _builder.append("{% endblock %}");
        _builder.newLine();
      }
    }
    {
      boolean _needsUserAutoCompletion = this._modelBehaviourExtensions.needsUserAutoCompletion(it);
      if (_needsUserAutoCompletion) {
        _builder.newLine();
        _builder.append("{% block ");
        String _formatForDB_5 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_5);
        _builder.append("_field_user_widget %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<div id=\"{{ id }}LiveSearch\" class=\"");
        String _lowerCase = this._utils.appName(it).toLowerCase();
        _builder.append(_lowerCase, "    ");
        _builder.append("-livesearch-user ");
        String _lowerCase_1 = this._utils.appName(it).toLowerCase();
        _builder.append(_lowerCase_1, "    ");
        _builder.append("-autocomplete-user hidden\">");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<i class=\"fa fa-search\" title=\"{{ __(\'Search user\') }}\"></i>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<noscript><p>{{ __(\'This function requires JavaScript activated!\') }}</p></noscript>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<input type=\"hidden\" {{ block(\'widget_attributes\') }} value=\"{{ value }}\" />");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<input type=\"text\" id=\"{{ id }}Selector\" name=\"{{ id }}Selector\" autocomplete=\"off\" value=\"{{ user_name|e(\'html_attr\') }}\" title=\"{{ __(\'Enter a part of the user name to search\') }}\" class=\"user-selector typeahead\" />");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<i class=\"fa fa-refresh fa-spin hidden\" id=\"{{ id }}Indicator\"></i>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<span id=\"{{ id }}NoResultsHint\" class=\"hidden\">{{ __(\'No results found!\') }}</span>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% if value and not inline_usage %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<span class=\"help-block avatar\">");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{{ ");
        String _formatForDB_6 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_6, "            ");
        _builder.append("_userAvatar(uid=value, rating=\'g\') }}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("</span>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% if hasPermission(\'ZikulaUsersModule::\', \'::\', \'ACCESS_ADMIN\') %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<span class=\"help-block\"><a href=\"{{ path(\'zikulausersmodule_useradministration_modify\', { \'user\': value }) }}\" title=\"{{ __(\'Switch to users administration\') }}\">{{ __(\'Manage user\') }}</a></span>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("{% endblock %}");
        _builder.newLine();
      }
    }
    {
      boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(it);
      if (_needsAutoCompletion) {
        _builder.newLine();
        _builder.append("{% block ");
        String _formatForDB_7 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB_7);
        _builder.append("_field_autocompletionrelation_widget %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% set entityNameTranslated = \'\' %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set withImage = false %}");
        _builder.newLine();
        {
          EList<DataObject> _entities = it.getEntities();
          for(final DataObject entity : _entities) {
            _builder.append("    ");
            _builder.append("{% ");
            {
              DataObject _head = IterableExtensions.<DataObject>head(it.getEntities());
              boolean _notEquals = (!Objects.equal(entity, _head));
              if (_notEquals) {
                _builder.append("else");
              }
            }
            _builder.append("if object_type == \'");
            String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode, "    ");
            _builder.append("\' %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{% set entityNameTranslated = __(\'");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getName());
            _builder.append(_formatForDisplay, "        ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            {
              boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(entity);
              if (_hasImageFieldsEntity) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("{% set withImage = true %}");
                _builder.newLine();
              }
            }
          }
        }
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set idPrefix = unique_name_for_js %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set addLinkText = multiple ? __f(\'Add %name%\', { \'%name%\': entityNameTranslated }) : __f(\'Select %name%\', { \'%name%\': entityNameTranslated }) %}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"");
        String _lowerCase_2 = this._utils.appName(it).toLowerCase();
        _builder.append(_lowerCase_2, "    ");
        _builder.append("-relation-rightside\">");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<a id=\"{{ idPrefix }}AddLink\" href=\"javascript:void(0);\" class=\"hidden\">{{ addLinkText }}</a>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<div id=\"{{ idPrefix }}AddFields\" class=\"");
        String _lowerCase_3 = this._utils.appName(it).toLowerCase();
        _builder.append(_lowerCase_3, "        ");
        _builder.append("-autocomplete{{ withImage ? \'-with-image\' : \'\' }}\">");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("<label for=\"{{ idPrefix }}Selector\">{{ __f(\'Find %name%\', { \'%name%\': entityNameTranslated }) }}</label>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<br />");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<i class=\"fa fa-search\" title=\"{{ __f(\'Search %name%\', { \'%name%\': entityNameTranslated })|e(\'html_attr\') }}\"></i>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<input type=\"hidden\" {{ block(\'widget_attributes\') }} value=\"{{ value }}\" />");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<input type=\"hidden\" name=\"{{ idPrefix }}Scope\" id=\"{{ idPrefix }}Scope\" value=\"{{ multiple ? \'1\' : \'0\' }}\" />");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<input type=\"text\" id=\"{{ idPrefix }}Selector\" name=\"{{ idPrefix }}Selector\" autocomplete=\"off\" />");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<i class=\"fa fa-refresh fa-spin hidden\" id=\"{{ idPrefix }}Indicator\"></i>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<span id=\"{{ idPrefix }}NoResultsHint\" class=\"hidden\">{{ __(\'No results found!\') }}</span>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<input type=\"button\" id=\"{{ idPrefix }}SelectorDoCancel\" name=\"{{ idPrefix }}SelectorDoCancel\" value=\"{{ __(\'Cancel\') }}\" class=\"btn btn-default ");
        String _lowerCase_4 = this._utils.appName(it).toLowerCase();
        _builder.append(_lowerCase_4, "            ");
        _builder.append("-inline-button\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("{% if create_url != \'\' %}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("<a id=\"{{ idPrefix }}SelectorDoNew\" href=\"{{ create_url }}\" title=\"{{ __f(\'Create new %name%\', { \'%name%\': entityNameTranslated }) }}\" class=\"btn btn-default rkbulletinnewsmodule-inline-button\">{{ __(\'Create\') }}</a>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<noscript><p>{{ __(\'This function requires JavaScript activated!\') }}</p></noscript>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("{% endblock %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public void rawPageFile(final Application it) {
    final String templateExtension = ".html.twig";
    String fileName = ("raw" + templateExtension);
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _plus = (_viewPath + fileName);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _viewPath_1 = this._namingExtensions.getViewPath(it);
      String _plus_1 = (_viewPath_1 + fileName);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, _plus_1);
      if (_shouldBeMarked) {
        fileName = ("raw.generated" + templateExtension);
      }
      String _viewPath_2 = this._namingExtensions.getViewPath(it);
      String _plus_2 = (_viewPath_2 + fileName);
      this.fsa.generateFile(_plus_2, this.rawPageImpl(it));
    }
  }
  
  public CharSequence rawPageImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: Display pages without the theme #}");
    _builder.newLine();
    _builder.append("<!DOCTYPE html>");
    _builder.newLine();
    _builder.append("<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"{{ app.request.locale }}\" lang=\"{{ app.request.locale }}\">");
    _builder.newLine();
    _builder.append("<head>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<title>{{ block(\'pageTitle\')|default(block(\'title\')) }}</title>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"{{ asset(\'bootstrap/css/bootstrap.min.css\') }}\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"{{ asset(\'bootstrap/css/bootstrap-theme.min.css\') }}\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"{{ app.request.basePath }}/style/core.css\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"{{ zasset(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(":css/style.css\') }}\" />");
    _builder.newLineIfNotEmpty();
    {
      boolean _generateExternalControllerAndFinder = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
      if (_generateExternalControllerAndFinder) {
        _builder.append("    ");
        _builder.append("{% if useFinder|default == true %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        CharSequence _rawCssAssets = this.rawCssAssets(it, Boolean.valueOf(true));
        _builder.append(_rawCssAssets, "        ");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
          if (_hasImageFields) {
            _builder.append("    ");
            _builder.append("{% else %}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            CharSequence _rawCssAssets_1 = this.rawCssAssets(it, Boolean.valueOf(false));
            _builder.append(_rawCssAssets_1, "        ");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        {
          boolean _hasImageFields_1 = this._modelExtensions.hasImageFields(it);
          if (_hasImageFields_1) {
            _builder.append("    ");
            CharSequence _rawCssAssets_2 = this.rawCssAssets(it, Boolean.valueOf(false));
            _builder.append(_rawCssAssets_2, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (typeof(Zikula) == \'undefined\') {var Zikula = {};}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("Zikula.Config = {\'entrypoint\': \'{{ getModVar(\'ZConfig\', \'entrypoint\', \'index.php\') }}\', \'baseURL\': \'{{ app.request.getSchemeAndHttpHost() ~ \'/\' }}\', \'baseURI\': \'{{ app.request.getBasePath() }}\'};");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{{ asset(\'jquery/jquery.min.js\') }}\"></script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{{ asset(\'bootstrap/js/bootstrap.min.js\') }}\"></script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{{ asset(\'bundles/fosjsrouting/js/router.js\') }}\"></script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{{ asset(\'js/fos_js_routes.js\') }}\"></script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{{ asset(\'bundles/bazingajstranslation/js/translator.min.js\') }}\"></script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<script type=\"text/javascript\" src=\"{{ asset(\'bundles/core/js/Zikula.Translator.js\') }}\"></script>");
    _builder.newLine();
    {
      boolean _generateExternalControllerAndFinder_1 = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
      if (_generateExternalControllerAndFinder_1) {
        _builder.append("    ");
        _builder.append("{% if useFinder|default == true %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        CharSequence _rawJsAssets = this.rawJsAssets(it, Boolean.valueOf(true));
        _builder.append(_rawJsAssets, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% else %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        CharSequence _rawJsAssets_1 = this.rawJsAssets(it, Boolean.valueOf(false));
        _builder.append(_rawJsAssets_1, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        CharSequence _rawJsAssets_2 = this.rawJsAssets(it, Boolean.valueOf(false));
        _builder.append(_rawJsAssets_2, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</head>");
    _builder.newLine();
    _builder.append("<body>");
    _builder.newLine();
    {
      boolean _generateExternalControllerAndFinder_2 = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
      if (_generateExternalControllerAndFinder_2) {
        _builder.append("    ");
        _builder.append("{% if useFinder|default != true %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<h2>{{ block(\'title\') }}</h2>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("<h2>{{ block(\'title\') }}</h2>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("{% block content %}{% endblock %}");
    _builder.newLine();
    {
      boolean _generateExternalControllerAndFinder_3 = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
      if (_generateExternalControllerAndFinder_3) {
        _builder.append("    ");
        _builder.append("{% if useFinder|default != true %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        CharSequence _rawJsInit = this.rawJsInit(it);
        _builder.append(_rawJsInit, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        CharSequence _rawJsInit_1 = this.rawJsInit(it);
        _builder.append(_rawJsInit_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</body>");
    _builder.newLine();
    _builder.append("</html>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence rawCssAssets(final Application it, final Boolean forFinder) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((forFinder).booleanValue()) {
        _builder.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"{{ zasset(\'@");
        String _appName = this._utils.appName(it);
        _builder.append(_appName);
        _builder.append(":css/finder.css\') }}\" />");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"{{ asset(\'magnific-popup/magnific-popup.css\') }}\" />");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence rawJsAssets(final Application it, final Boolean forFinder) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((forFinder).booleanValue()) {
        _builder.append("<script type=\"text/javascript\" src=\"{{ zasset(\'@");
        String _appName = this._utils.appName(it);
        _builder.append(_appName);
        _builder.append(":js/");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1);
        _builder.append(".Finder.js\') }}\"></script>");
        _builder.newLineIfNotEmpty();
      } else {
        {
          boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
          if (_hasImageFields) {
            _builder.append("<script type=\"text/javascript\" src=\"{{ asset(\'magnific-popup/jquery.magnific-popup.min.js\') }}\"></script>");
            _builder.newLine();
          }
        }
        _builder.append("<script type=\"text/javascript\" src=\"{{ zasset(\'@");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2);
        _builder.append(":js/");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3);
        _builder.append(".js\') }}\"></script>");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
          if (_hasGeographical) {
            _builder.append("<script type=\"text/javascript\" src=\"{{ zasset(\'@");
            String _appName_4 = this._utils.appName(it);
            _builder.append(_appName_4);
            _builder.append(":js/");
            String _appName_5 = this._utils.appName(it);
            _builder.append(_appName_5);
            _builder.append(".Geo.js\') }}\"></script>");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if ((this._controllerExtensions.hasEditActions(it) || this._utils.needsConfig(it))) {
            {
              boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
              if (_hasEditActions) {
                _builder.append("{% if \'edit\' in app.request.get(\'_route\') %}");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
                String _appName_6 = this._utils.appName(it);
                _builder.append(_appName_6, "    ");
                _builder.append(":js/");
                String _appName_7 = this._utils.appName(it);
                _builder.append(_appName_7, "    ");
                _builder.append(".Validation.js\'), 98) }}");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
                String _appName_8 = this._utils.appName(it);
                _builder.append(_appName_8, "    ");
                _builder.append(":js/");
                String _appName_9 = this._utils.appName(it);
                _builder.append(_appName_9, "    ");
                _builder.append(".EditFunctions.js\'), 99) }}");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("{{ pageAddAsset(\'javascript\', asset(\'typeahead/typeahead.bundle.min.js\')) }}");
                _builder.newLine();
                _builder.append("{% endif %}");
                _builder.newLine();
              }
            }
            _builder.append("{% if ");
            {
              boolean _hasEditActions_1 = this._controllerExtensions.hasEditActions(it);
              if (_hasEditActions_1) {
                _builder.append("\'edit\' in app.request.get(\'_route\')");
                {
                  boolean _needsConfig = this._utils.needsConfig(it);
                  if (_needsConfig) {
                    _builder.append(" or ");
                  }
                }
              }
            }
            {
              boolean _needsConfig_1 = this._utils.needsConfig(it);
              if (_needsConfig_1) {
                _builder.append("\'config\' in app.request.get(\'_route\')");
              }
            }
            _builder.append(" %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("{{ polyfill([");
            {
              boolean _hasGeographical_1 = this._modelBehaviourExtensions.hasGeographical(it);
              if (_hasGeographical_1) {
                _builder.append("\'geolocation\', ");
              }
            }
            _builder.append("\'forms\', \'forms-ext\']) }}");
            _builder.newLineIfNotEmpty();
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence rawJsInit(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("( function($) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(document).ready(function() {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$(\'.dropdown-toggle\').addClass(\'hidden\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("})(jQuery);");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
  
  public void pdfHeaderFile(final Application it) {
    final String templateExtension = ".html.twig";
    String fileName = ("includePdfHeader" + templateExtension);
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _plus = (_viewPath + fileName);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _viewPath_1 = this._namingExtensions.getViewPath(it);
      String _plus_1 = (_viewPath_1 + fileName);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, _plus_1);
      if (_shouldBeMarked) {
        fileName = ("includePdfHeader.generated" + templateExtension);
      }
      String _viewPath_2 = this._namingExtensions.getViewPath(it);
      String _plus_2 = (_viewPath_2 + fileName);
      this.fsa.generateFile(_plus_2, this.pdfHeaderImpl(it));
    }
  }
  
  private CharSequence pdfHeaderImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<!DOCTYPE html>");
    _builder.newLine();
    _builder.append("<html xml:lang=\"{{ app.request.locale }}\" lang=\"{{ app.request.locale }}\" dir=\"auto\">");
    _builder.newLine();
    _builder.append("<head>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<title>{{ pageGetVar(\'title\') }}</title>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<style>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("@page {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("margin: 0 2cm 1cm 1cm;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("img {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("border-width: 0;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("vertical-align: middle;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</style>");
    _builder.newLine();
    _builder.append("</head>");
    _builder.newLine();
    _builder.append("<body>");
    _builder.newLine();
    return _builder;
  }
}
