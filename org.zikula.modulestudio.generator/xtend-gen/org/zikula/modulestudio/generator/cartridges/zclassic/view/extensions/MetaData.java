package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class MetaData {
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
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public void generate(final Application it, final Controller controller, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _formattedName = this._controllerExtensions.formattedName(controller);
      _xifexpression = _formattedName;
    } else {
      String _formattedName_1 = this._controllerExtensions.formattedName(controller);
      String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
      _xifexpression = _firstUpper;
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    boolean _or = false;
    boolean _hasActions = this._controllerExtensions.hasActions(controller, "view");
    if (_hasActions) {
      _or = true;
    } else {
      boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "display");
      _or = (_hasActions || _hasActions_1);
    }
    if (_or) {
      String _plus_1 = (templatePath + "include_metadata_display.tpl");
      CharSequence _metaDataViewImpl = this.metaDataViewImpl(it, controller);
      fsa.generateFile(_plus_1, _metaDataViewImpl);
    }
    boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "edit");
    if (_hasActions_2) {
      String _plus_2 = (templatePath + "include_metadata_edit.tpl");
      CharSequence _metaDataEditImpl = this.metaDataEditImpl(it, controller);
      fsa.generateFile(_plus_2, _metaDataEditImpl);
    }
  }
  
  private CharSequence metaDataViewImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: reusable display of meta data fields *}");
    _builder.newLine();
    _builder.append("{if isset($obj.metadata)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"metadata z-panel-header z-panel-indicator ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("z");
      } else {
        _builder.append("cursor");
      }
    }
    _builder.append("-pointer\">{gt text=\'Metadata\'}</h3>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<div class=\"metadata z-panel-content\" style=\"display: none\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"metadata\">{gt text=\'Metadata\'}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dl class=\"propertylist\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.title ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Title\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.title|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.author ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Author\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.author|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.subject ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Subject\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.subject|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.keywords ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Keywords\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.keywords|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.description ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Description\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.description|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.publisher ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Publisher\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.publisher|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.contributor ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Contributor\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.contributor|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.startdate ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Start date\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.startdate|dateformat}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.enddate ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'End date\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.enddate|dateformat}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.type ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Type\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.type|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.format ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Format\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.format|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.uri ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Uri\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.uri|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.source ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Source\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.source|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.language ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Language\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.language|getlanguagename|safehtml}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.relation ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Relation\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.relation|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.coverage ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Coverage\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.coverage|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.comment ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Comment\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.comment|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $obj.metadata.extra ne \'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'Extra\'}</dt>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dd>{$obj.metadata.extra|default:\'-\'|safetext}</dd>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</dl>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence metaDataEditImpl(final Application it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: reusable editing of meta data fields *}");
    _builder.newLine();
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<h3 class=\"metadata z-panel-header z-panel-indicator ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("z");
      } else {
        _builder.append("cursor");
      }
    }
    _builder.append("-pointer\">{gt text=\'Metadata\'}</h3>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<fieldset class=\"metadata z-panel-content\" style=\"display: none\">");
    _builder.newLine();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset class=\"metadata\">");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{gt text=\'Metadata\'}</legend>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataTitle\' __text=\'Title\'");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_2);
      if (_not) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_3);
      if (_not_1) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataTitle\' dataField=\'title\' maxLength=80");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      boolean _not_2 = (!_targets_4);
      if (_not_2) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      boolean _not_3 = (!_targets_5);
      if (_not_3) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      if (_targets_6) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataAuthor\' __text=\'Author\'");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      boolean _not_4 = (!_targets_7);
      if (_not_4) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      boolean _not_5 = (!_targets_8);
      if (_not_5) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataAuthor\' dataField=\'author\' maxLength=80");
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      boolean _not_6 = (!_targets_9);
      if (_not_6) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_10 = this._utils.targets(it, "1.3.5");
      boolean _not_7 = (!_targets_10);
      if (_not_7) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_11 = this._utils.targets(it, "1.3.5");
      if (_targets_11) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataSubject\' __text=\'Subject\'");
    {
      boolean _targets_12 = this._utils.targets(it, "1.3.5");
      boolean _not_8 = (!_targets_12);
      if (_not_8) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_13 = this._utils.targets(it, "1.3.5");
      boolean _not_9 = (!_targets_13);
      if (_not_9) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataSubject\' dataField=\'subject\' maxLength=255");
    {
      boolean _targets_14 = this._utils.targets(it, "1.3.5");
      boolean _not_10 = (!_targets_14);
      if (_not_10) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_15 = this._utils.targets(it, "1.3.5");
      boolean _not_11 = (!_targets_15);
      if (_not_11) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_16 = this._utils.targets(it, "1.3.5");
      if (_targets_16) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataKeywords\' __text=\'Keywords\'");
    {
      boolean _targets_17 = this._utils.targets(it, "1.3.5");
      boolean _not_12 = (!_targets_17);
      if (_not_12) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_18 = this._utils.targets(it, "1.3.5");
      boolean _not_13 = (!_targets_18);
      if (_not_13) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataKeywords\' dataField=\'keywords\' maxLength=128");
    {
      boolean _targets_19 = this._utils.targets(it, "1.3.5");
      boolean _not_14 = (!_targets_19);
      if (_not_14) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_20 = this._utils.targets(it, "1.3.5");
      boolean _not_15 = (!_targets_20);
      if (_not_15) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_21 = this._utils.targets(it, "1.3.5");
      if (_targets_21) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataDescription\' __text=\'Description\'");
    {
      boolean _targets_22 = this._utils.targets(it, "1.3.5");
      boolean _not_16 = (!_targets_22);
      if (_not_16) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_23 = this._utils.targets(it, "1.3.5");
      boolean _not_17 = (!_targets_23);
      if (_not_17) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataDescription\' dataField=\'description\' maxLength=255");
    {
      boolean _targets_24 = this._utils.targets(it, "1.3.5");
      boolean _not_18 = (!_targets_24);
      if (_not_18) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_25 = this._utils.targets(it, "1.3.5");
      boolean _not_19 = (!_targets_25);
      if (_not_19) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_26 = this._utils.targets(it, "1.3.5");
      if (_targets_26) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataPublisher\' __text=\'Publisher\'");
    {
      boolean _targets_27 = this._utils.targets(it, "1.3.5");
      boolean _not_20 = (!_targets_27);
      if (_not_20) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_28 = this._utils.targets(it, "1.3.5");
      boolean _not_21 = (!_targets_28);
      if (_not_21) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataPublisher\' dataField=\'publisher\' maxLength=128");
    {
      boolean _targets_29 = this._utils.targets(it, "1.3.5");
      boolean _not_22 = (!_targets_29);
      if (_not_22) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_30 = this._utils.targets(it, "1.3.5");
      boolean _not_23 = (!_targets_30);
      if (_not_23) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_31 = this._utils.targets(it, "1.3.5");
      if (_targets_31) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataContributor\' __text=\'Contributor\'");
    {
      boolean _targets_32 = this._utils.targets(it, "1.3.5");
      boolean _not_24 = (!_targets_32);
      if (_not_24) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_33 = this._utils.targets(it, "1.3.5");
      boolean _not_25 = (!_targets_33);
      if (_not_25) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataContributor\' dataField=\'contributor\' maxLength=80");
    {
      boolean _targets_34 = this._utils.targets(it, "1.3.5");
      boolean _not_26 = (!_targets_34);
      if (_not_26) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_35 = this._utils.targets(it, "1.3.5");
      boolean _not_27 = (!_targets_35);
      if (_not_27) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_36 = this._utils.targets(it, "1.3.5");
      if (_targets_36) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataStartdate\' __text=\'Start date\'");
    {
      boolean _targets_37 = this._utils.targets(it, "1.3.5");
      boolean _not_28 = (!_targets_37);
      if (_not_28) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_38 = this._utils.targets(it, "1.3.5");
      boolean _not_29 = (!_targets_38);
      if (_not_29) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("{if $mode ne \'create\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{formdateinput group=\'meta\' id=\'metadataStartdate\' dataField=\'startdate\' mandatory=false includeTime=true");
    {
      boolean _targets_39 = this._utils.targets(it, "1.3.5");
      boolean _not_30 = (!_targets_39);
      if (_not_30) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{formdateinput group=\'meta\' id=\'metadataStartdate\' dataField=\'startdate\' mandatory=false includeTime=true defaultValue=\'now\'");
    {
      boolean _targets_40 = this._utils.targets(it, "1.3.5");
      boolean _not_31 = (!_targets_40);
      if (_not_31) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    {
      boolean _targets_41 = this._utils.targets(it, "1.3.5");
      boolean _not_32 = (!_targets_41);
      if (_not_32) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_42 = this._utils.targets(it, "1.3.5");
      if (_targets_42) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataEnddate\' __text=\'End date\'");
    {
      boolean _targets_43 = this._utils.targets(it, "1.3.5");
      boolean _not_33 = (!_targets_43);
      if (_not_33) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_44 = this._utils.targets(it, "1.3.5");
      boolean _not_34 = (!_targets_44);
      if (_not_34) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("{if $mode ne \'create\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{formdateinput group=\'meta\' id=\'metadataEnddate\' dataField=\'enddate\' mandatory=false includeTime=true");
    {
      boolean _targets_45 = this._utils.targets(it, "1.3.5");
      boolean _not_35 = (!_targets_45);
      if (_not_35) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{formdateinput group=\'meta\' id=\'metadataEnddate\' dataField=\'enddate\' mandatory=false includeTime=true defaultValue=\'now\'");
    {
      boolean _targets_46 = this._utils.targets(it, "1.3.5");
      boolean _not_36 = (!_targets_46);
      if (_not_36) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    {
      boolean _targets_47 = this._utils.targets(it, "1.3.5");
      boolean _not_37 = (!_targets_47);
      if (_not_37) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_48 = this._utils.targets(it, "1.3.5");
      if (_targets_48) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataType\' __text=\'Type\'");
    {
      boolean _targets_49 = this._utils.targets(it, "1.3.5");
      boolean _not_38 = (!_targets_49);
      if (_not_38) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_50 = this._utils.targets(it, "1.3.5");
      boolean _not_39 = (!_targets_50);
      if (_not_39) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataType\' dataField=\'type\' maxLength=128");
    {
      boolean _targets_51 = this._utils.targets(it, "1.3.5");
      boolean _not_40 = (!_targets_51);
      if (_not_40) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_52 = this._utils.targets(it, "1.3.5");
      boolean _not_41 = (!_targets_52);
      if (_not_41) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_53 = this._utils.targets(it, "1.3.5");
      if (_targets_53) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataFormat\' __text=\'Format\'");
    {
      boolean _targets_54 = this._utils.targets(it, "1.3.5");
      boolean _not_42 = (!_targets_54);
      if (_not_42) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_55 = this._utils.targets(it, "1.3.5");
      boolean _not_43 = (!_targets_55);
      if (_not_43) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataFormat\' dataField=\'format\' maxLength=128");
    {
      boolean _targets_56 = this._utils.targets(it, "1.3.5");
      boolean _not_44 = (!_targets_56);
      if (_not_44) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_57 = this._utils.targets(it, "1.3.5");
      boolean _not_45 = (!_targets_57);
      if (_not_45) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_58 = this._utils.targets(it, "1.3.5");
      if (_targets_58) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataUri\' __text=\'Uri\'");
    {
      boolean _targets_59 = this._utils.targets(it, "1.3.5");
      boolean _not_46 = (!_targets_59);
      if (_not_46) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_60 = this._utils.targets(it, "1.3.5");
      boolean _not_47 = (!_targets_60);
      if (_not_47) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataUri\' dataField=\'uri\' maxLength=255");
    {
      boolean _targets_61 = this._utils.targets(it, "1.3.5");
      boolean _not_48 = (!_targets_61);
      if (_not_48) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_62 = this._utils.targets(it, "1.3.5");
      boolean _not_49 = (!_targets_62);
      if (_not_49) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_63 = this._utils.targets(it, "1.3.5");
      if (_targets_63) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataSource\' __text=\'Source\'");
    {
      boolean _targets_64 = this._utils.targets(it, "1.3.5");
      boolean _not_50 = (!_targets_64);
      if (_not_50) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_65 = this._utils.targets(it, "1.3.5");
      boolean _not_51 = (!_targets_65);
      if (_not_51) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataSource\' dataField=\'source\' maxLength=128");
    {
      boolean _targets_66 = this._utils.targets(it, "1.3.5");
      boolean _not_52 = (!_targets_66);
      if (_not_52) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_67 = this._utils.targets(it, "1.3.5");
      boolean _not_53 = (!_targets_67);
      if (_not_53) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_68 = this._utils.targets(it, "1.3.5");
      if (_targets_68) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataLanguage\' __text=\'Language\'");
    {
      boolean _targets_69 = this._utils.targets(it, "1.3.5");
      boolean _not_54 = (!_targets_69);
      if (_not_54) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_70 = this._utils.targets(it, "1.3.5");
      boolean _not_55 = (!_targets_70);
      if (_not_55) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formlanguageselector group=\'meta\' id=\'metadataLanguage\' mandatory=false __title=\'Choose a language\' dataField=\'language\'");
    {
      boolean _targets_71 = this._utils.targets(it, "1.3.5");
      boolean _not_56 = (!_targets_71);
      if (_not_56) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_72 = this._utils.targets(it, "1.3.5");
      boolean _not_57 = (!_targets_72);
      if (_not_57) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_73 = this._utils.targets(it, "1.3.5");
      if (_targets_73) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataRelation\' __text=\'Relation\'");
    {
      boolean _targets_74 = this._utils.targets(it, "1.3.5");
      boolean _not_58 = (!_targets_74);
      if (_not_58) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_75 = this._utils.targets(it, "1.3.5");
      boolean _not_59 = (!_targets_75);
      if (_not_59) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataRelation\' dataField=\'relation\' maxLength=255");
    {
      boolean _targets_76 = this._utils.targets(it, "1.3.5");
      boolean _not_60 = (!_targets_76);
      if (_not_60) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_77 = this._utils.targets(it, "1.3.5");
      boolean _not_61 = (!_targets_77);
      if (_not_61) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_78 = this._utils.targets(it, "1.3.5");
      if (_targets_78) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataCoverage\' __text=\'Coverage\'");
    {
      boolean _targets_79 = this._utils.targets(it, "1.3.5");
      boolean _not_62 = (!_targets_79);
      if (_not_62) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_80 = this._utils.targets(it, "1.3.5");
      boolean _not_63 = (!_targets_80);
      if (_not_63) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataCoverage\' dataField=\'coverage\' maxLength=64");
    {
      boolean _targets_81 = this._utils.targets(it, "1.3.5");
      boolean _not_64 = (!_targets_81);
      if (_not_64) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_82 = this._utils.targets(it, "1.3.5");
      boolean _not_65 = (!_targets_82);
      if (_not_65) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_83 = this._utils.targets(it, "1.3.5");
      if (_targets_83) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataComment\' __text=\'Comment\'");
    {
      boolean _targets_84 = this._utils.targets(it, "1.3.5");
      boolean _not_66 = (!_targets_84);
      if (_not_66) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_85 = this._utils.targets(it, "1.3.5");
      boolean _not_67 = (!_targets_85);
      if (_not_67) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataComment\' dataField=\'comment\' maxLength=255");
    {
      boolean _targets_86 = this._utils.targets(it, "1.3.5");
      boolean _not_68 = (!_targets_86);
      if (_not_68) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_87 = this._utils.targets(it, "1.3.5");
      boolean _not_69 = (!_targets_87);
      if (_not_69) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_88 = this._utils.targets(it, "1.3.5");
      if (_targets_88) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'metadataExtra\' __text=\'Extra\'");
    {
      boolean _targets_89 = this._utils.targets(it, "1.3.5");
      boolean _not_70 = (!_targets_89);
      if (_not_70) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_90 = this._utils.targets(it, "1.3.5");
      boolean _not_71 = (!_targets_90);
      if (_not_71) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{formtextinput group=\'meta\' id=\'metadataExtra\' dataField=\'extra\' maxLength=255");
    {
      boolean _targets_91 = this._utils.targets(it, "1.3.5");
      boolean _not_72 = (!_targets_91);
      if (_not_72) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_92 = this._utils.targets(it, "1.3.5");
      boolean _not_73 = (!_targets_92);
      if (_not_73) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</fieldset>");
    _builder.newLine();
    return _builder;
  }
}
