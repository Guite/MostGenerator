package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.Variable;
import de.guite.modulestudio.metamodel.Variables;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Config {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Config/");
    final String templateExtension = ".html.twig";
    String fileName = ("config" + templateExtension);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      InputOutput.<String>println("Generating config template");
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = ("config.generated" + templateExtension);
      }
      fsa.generateFile((templatePath + fileName), this.configView(it));
    }
  }
  
  private CharSequence configView(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: module configuration page #}");
    _builder.newLine();
    _builder.append("{% extends \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("::adminBase.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title __(\'Settings\') %}");
    _builder.newLine();
    _builder.append("{% block admin_page_icon \'wrench\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    String _lowerCase = this._utils.appName(it).toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("-config\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% form_theme form with [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'@");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "            ");
    _builder.append("/Form/bootstrap_3.html.twig\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("] %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ form_start(form) }}");
    _builder.newLine();
    {
      if (((this._utils.hasMultipleConfigSections(it) || this._modelExtensions.hasImageFields(it)) || (this._utils.targets(it, "1.5")).booleanValue())) {
        _builder.append("        ");
        _builder.append("<div class=\"zikula-bootstrap-tab-container\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<ul class=\"nav nav-tabs\">");
        _builder.newLine();
        {
          List<Variables> _sortedVariableContainers = this._utils.getSortedVariableContainers(it);
          for(final Variables varContainer : _sortedVariableContainers) {
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("{% set tabTitle = __(\'");
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(varContainer.getName());
            _builder.append(_formatForDisplayCapital, "            ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<li role=\"presentation\"");
            {
              if ((Objects.equal(varContainer, IterableExtensions.<Variables>head(this._utils.getSortedVariableContainers(it))) || this.isImageArea(varContainer))) {
                _builder.append(" class=\"");
                {
                  Variables _head = IterableExtensions.<Variables>head(this._utils.getSortedVariableContainers(it));
                  boolean _equals = Objects.equal(varContainer, _head);
                  if (_equals) {
                    _builder.append("active");
                  }
                }
                {
                  boolean _isImageArea = this.isImageArea(varContainer);
                  if (_isImageArea) {
                    _builder.append(" dropdown");
                  }
                }
                _builder.append("\"");
              }
            }
            _builder.append(">");
            _builder.newLineIfNotEmpty();
            {
              boolean _isImageArea_1 = this.isImageArea(varContainer);
              if (_isImageArea_1) {
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("<a id=\"imagesTabDrop\" class=\"dropdown-toggle\" href=\"#\" data-toggle=\"dropdown\" aria-controls=\"imagesTabDropSections\" aria-expanded=\"false\" title=\"{{ tabTitle|e(\'html_attr\') }}\">{{ tabTitle }}<span class=\"caret\"></span></a>");
                _builder.newLine();
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("<ul id=\"imagesTabDropSections\" class=\"dropdown-menu\" aria-labelledby=\"imagesTabDrop\">");
                _builder.newLine();
                {
                  final Function1<Entity, Boolean> _function = (Entity it_1) -> {
                    return Boolean.valueOf(this._modelExtensions.hasImageFieldsEntity(it_1));
                  };
                  Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
                  for(final Entity entity : _filter) {
                    {
                      Iterable<UploadField> _imageFieldsEntity = this._modelExtensions.getImageFieldsEntity(entity);
                      for(final UploadField imageUploadField : _imageFieldsEntity) {
                        _builder.append("        ");
                        _builder.append("    ");
                        _builder.append("    ");
                        _builder.append("<li>");
                        _builder.newLine();
                        _builder.append("        ");
                        _builder.append("    ");
                        _builder.append("    ");
                        _builder.append("    ");
                        _builder.append("<a id=\"images");
                        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
                        _builder.append(_formatForCodeCapital, "                    ");
                        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(imageUploadField.getName());
                        _builder.append(_formatForCodeCapital_1, "                    ");
                        _builder.append("Tab\" href=\"#tabImages");
                        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(entity.getName());
                        _builder.append(_formatForCodeCapital_2, "                    ");
                        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(imageUploadField.getName());
                        _builder.append(_formatForCodeCapital_3, "                    ");
                        _builder.append("\" role=\"tab\" data-toggle=\"tab\" aria-controls=\"tabImages");
                        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(entity.getName());
                        _builder.append(_formatForCodeCapital_4, "                    ");
                        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(imageUploadField.getName());
                        _builder.append(_formatForCodeCapital_5, "                    ");
                        _builder.append("\">{{ __(\'");
                        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(entity.getNameMultiple());
                        _builder.append(_formatForDisplayCapital_1, "                    ");
                        _builder.append(" ");
                        String _formatForDisplay = this._formattingExtensions.formatForDisplay(imageUploadField.getName());
                        _builder.append(_formatForDisplay, "                    ");
                        _builder.append("\') }}</a>");
                        _builder.newLineIfNotEmpty();
                        _builder.append("        ");
                        _builder.append("    ");
                        _builder.append("    ");
                        _builder.append("</li>");
                        _builder.newLine();
                      }
                    }
                  }
                }
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("</ul>");
                _builder.newLine();
              } else {
                _builder.append("        ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("<a id=\"vars");
                int _sortOrder = varContainer.getSortOrder();
                _builder.append(_sortOrder, "                ");
                _builder.append("Tab\" href=\"#tab");
                int _sortOrder_1 = varContainer.getSortOrder();
                _builder.append(_sortOrder_1, "                ");
                _builder.append("\" title=\"{{ tabTitle|e(\'html_attr\') }}\" role=\"tab\" data-toggle=\"tab\">{{ tabTitle }}</a>");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("</li>");
            _builder.newLine();
          }
        }
        {
          Boolean _targets = this._utils.targets(it, "1.5");
          if ((_targets).booleanValue()) {
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("{% set tabTitle = __(\'Workflows\') %}");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<a id=\"workflowsTab\" href=\"#tabWorkflows\" title=\"{{ tabTitle|e(\'html_attr\') }}\" role=\"tab\" data-toggle=\"tab\">{{ tabTitle }}</a>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("</li>");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("</ul>");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{{ form_errors(form) }}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<div class=\"tab-content\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        CharSequence _configSections = this.configSections(it);
        _builder.append(_configSections, "                ");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("{{ form_errors(form) }}");
        _builder.newLine();
        _builder.append("        ");
        CharSequence _configSections_1 = this.configSections(it);
        _builder.append(_configSections_1, "        ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"col-sm-offset-3 col-sm-9\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{{ form_widget(form.save) }}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{{ form_widget(form.cancel) }}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ form_end(form) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.append("{% block footer %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ parent() }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "    ");
        _builder.append(":js/");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.append(".Config.js\')) }}");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endblock %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence configSections(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      List<Variables> _sortedVariableContainers = this._utils.getSortedVariableContainers(it);
      for(final Variables varContainer : _sortedVariableContainers) {
        Variables _head = IterableExtensions.<Variables>head(this._utils.getSortedVariableContainers(it));
        boolean _equals = Objects.equal(varContainer, _head);
        CharSequence _configSection = this.configSection(varContainer, it, Boolean.valueOf(_equals));
        _builder.append(_configSection);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabWorkflows\" aria-labelledby=\"workflowsTab\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set tabTitle = __(\'Workflows\') %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<fieldset>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<legend>{{ tabTitle }}</legend>");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<p class=\"alert alert-info\">{{ __(\'Here you can inspect and amend the existing workflows.\') }}</p>");
        _builder.newLine();
        _builder.newLine();
        {
          Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
          for(final Entity entity : _allEntities) {
            _builder.append("        ");
            _builder.append("<h4>{{ __(\'");
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(entity.getNameMultiple());
            _builder.append(_formatForDisplayCapital, "        ");
            _builder.append("\') }}</h4>");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("<p><a href=\"{{ path(\'zikula_workflow_editor_index\', { \'workflow\': \'");
            String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
            _builder.append(_formatForDB, "        ");
            _builder.append("_");
            String _textualName = this._workflowExtensions.textualName(entity.getWorkflow());
            _builder.append(_textualName, "        ");
            _builder.append("\' }) }}\" title=\"{{ __(\'Edit workflow for ");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
            _builder.append(_formatForDisplay, "        ");
            _builder.append("\') }}\" target=\"_blank\"><i class=\"fa fa-cubes\"></i> {{ __(\'Edit ");
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
            _builder.append(_formatForDisplay_1, "        ");
            _builder.append(" workflow\') }}</a>");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("</fieldset>");
        _builder.newLine();
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence configSection(final Variables it, final Application app, final Boolean isPrimaryVarContainer) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((this._utils.hasMultipleConfigSections(app) || this._modelExtensions.hasImageFields(app)) || (this._utils.targets(app, "1.5")).booleanValue())) {
        {
          boolean _isImageArea = this.isImageArea(it);
          if (_isImageArea) {
            CharSequence _configSectionBodyImages = this.configSectionBodyImages(it, app, isPrimaryVarContainer);
            _builder.append(_configSectionBodyImages);
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade");
            {
              if ((isPrimaryVarContainer).booleanValue()) {
                _builder.append(" in active");
              }
            }
            _builder.append("\" id=\"tab");
            int _sortOrder = it.getSortOrder();
            _builder.append(_sortOrder);
            _builder.append("\" aria-labelledby=\"vars");
            int _sortOrder_1 = it.getSortOrder();
            _builder.append(_sortOrder_1);
            _builder.append("Tab\">");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("{% set tabTitle = __(\'");
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
            _builder.append(_formatForDisplayCapital, "    ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            CharSequence _configSectionBody = this.configSectionBody(it, app, isPrimaryVarContainer);
            _builder.append(_configSectionBody, "    ");
            _builder.newLineIfNotEmpty();
            _builder.append("</div>");
            _builder.newLine();
          }
        }
      } else {
        _builder.append("{% set tabTitle = __(\'");
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital_1);
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        CharSequence _configSectionBody_1 = this.configSectionBody(it, app, isPrimaryVarContainer);
        _builder.append(_configSectionBody_1);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence configSectionBodyImages(final Variables it, final Application app, final Boolean isPrimaryVarContainer) {
    StringConcatenation _builder = new StringConcatenation();
    {
      final Function1<Entity, Boolean> _function = (Entity it_1) -> {
        return Boolean.valueOf(this._modelExtensions.hasImageFieldsEntity(it_1));
      };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(app), _function);
      for(final Entity entity : _filter) {
        {
          Iterable<UploadField> _imageFieldsEntity = this._modelExtensions.getImageFieldsEntity(entity);
          for(final UploadField imageUploadField : _imageFieldsEntity) {
            _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade");
            {
              if ((((isPrimaryVarContainer).booleanValue() && Objects.equal(entity, IterableExtensions.<Entity>head(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(app), ((Function1<Entity, Boolean>) (Entity it_1) -> {
                return Boolean.valueOf(this._modelExtensions.hasImageFieldsEntity(it_1));
              }))))) && Objects.equal(imageUploadField, IterableExtensions.<UploadField>head(this._modelExtensions.getImageFieldsEntity(entity))))) {
                _builder.append(" in active");
              }
            }
            _builder.append("\" id=\"tabImages");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
            _builder.append(_formatForCodeCapital);
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(imageUploadField.getName());
            _builder.append(_formatForCodeCapital_1);
            _builder.append("\" aria-labelledby=\"images");
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(entity.getName());
            _builder.append(_formatForCodeCapital_2);
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(imageUploadField.getName());
            _builder.append(_formatForCodeCapital_3);
            _builder.append("Tab\">");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("{% set tabTitle = __(\'Image settings for ");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
            _builder.append(_formatForDisplay, "    ");
            _builder.append(" ");
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(imageUploadField.getName());
            _builder.append(_formatForDisplay_1, "    ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("<fieldset>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("<legend>{{ tabTitle }}</legend>");
            _builder.newLine();
            _builder.append("        ");
            String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(entity.getName());
            String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(imageUploadField.getName());
            final String fieldSuffix = (_formatForCodeCapital_4 + _formatForCodeCapital_5);
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("        ");
            {
              final Function1<Variable, Boolean> _function_1 = (Variable it_1) -> {
                return Boolean.valueOf((((it_1.getName().endsWith(fieldSuffix) || it_1.getName().endsWith((fieldSuffix + "View"))) || it_1.getName().endsWith((fieldSuffix + "Display"))) || it_1.getName().endsWith((fieldSuffix + "Edit"))));
              };
              Iterable<Variable> _filter_1 = IterableExtensions.<Variable>filter(it.getVars(), _function_1);
              for(final Variable modvar : _filter_1) {
                CharSequence _formRow = this.formRow(modvar);
                _builder.append(_formRow, "        ");
              }
            }
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("</fieldset>");
            _builder.newLine();
            _builder.append("</div>");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence configSectionBody(final Variables it, final Application app, final Boolean isPrimaryVarContainer) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{{ tabTitle }}</legend>");
    _builder.newLine();
    _builder.newLine();
    {
      if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
        {
          boolean _isEmpty = this._formattingExtensions.containedTwigVariables(it.getDocumentation()).isEmpty();
          boolean _not = (!_isEmpty);
          if (_not) {
            _builder.append("    ");
            _builder.append("{{ __f(\'");
            String _replaceTwigVariablesForTranslation = this._formattingExtensions.replaceTwigVariablesForTranslation(it.getDocumentation().replace("\'", "\\\'"));
            _builder.append(_replaceTwigVariablesForTranslation, "    ");
            _builder.append("\', { ");
            final Function1<String, String> _function = (String v) -> {
              return (((("\'%" + v) + "%\': ") + v) + "|default");
            };
            String _join = IterableExtensions.join(ListExtensions.<String, String>map(this._formattingExtensions.containedTwigVariables(it.getDocumentation()), _function), ", ");
            _builder.append(_join, "    ");
            _builder.append(" }) }}");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("<p class=\"alert alert-info\">{{ __(\'");
            String _replace = it.getDocumentation().replace("\'", "\\\'");
            _builder.append(_replace, "    ");
            _builder.append("\')|nl2br }}</p>");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        if (((!this._utils.hasMultipleConfigSections(app)) || (isPrimaryVarContainer).booleanValue())) {
          _builder.append("    ");
          _builder.append("<p class=\"alert alert-info\">{{ __(\'Here you can manage all basic settings for this application.\') }}</p>");
          _builder.newLine();
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    {
      EList<Variable> _vars = it.getVars();
      for(final Variable modvar : _vars) {
        CharSequence _formRow = this.formRow(modvar);
        _builder.append(_formRow, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("</fieldset>");
    _builder.newLine();
    return _builder;
  }
  
  private boolean isImageArea(final Variables it) {
    return (Objects.equal(it.getName(), "Images") && (!IterableExtensions.isEmpty(IterableExtensions.<Variable>filter(it.getVars(), ((Function1<Variable, Boolean>) (Variable it_1) -> {
      return Boolean.valueOf(this._formattingExtensions.formatForCode(it_1.getName()).startsWith("shrinkWidth"));
    })))));
  }
  
  private CharSequence formRow(final Variable it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _startsWith = this._formattingExtensions.formatForCode(it.getName()).startsWith("shrinkWidth");
      if (_startsWith) {
        _builder.append("<div id=\"shrinkDetails");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._formattingExtensions.formatForCode(it.getName()).replace("shrinkWidth", ""));
        _builder.append(_formatForCodeCapital);
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{{ form_row(form.");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(") }}");
    _builder.newLineIfNotEmpty();
    {
      boolean _startsWith_1 = this._formattingExtensions.formatForCode(it.getName()).startsWith("shrinkHeight");
      if (_startsWith_1) {
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
}
