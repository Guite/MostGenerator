package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class SearchView {
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
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "search";
    } else {
      _xifexpression = "Search";
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    String _plus_1 = (templatePath + "options.tpl");
    CharSequence _optionsTemplate = this.optionsTemplate(it);
    fsa.generateFile(_plus_1, _optionsTemplate);
  }
  
  private CharSequence optionsTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display search options *}");
    _builder.newLine();
    _builder.append("<input type=\"hidden\" id=\"active_");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("\" name=\"active[");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append("]\" value=\"1\" checked=\"checked\" />");
    _builder.newLineIfNotEmpty();
    String _appName_2 = this._utils.appName(it);
    final String appLower = this._formattingExtensions.formatForDB(_appName_2);
    _builder.newLineIfNotEmpty();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            boolean _hasAbstractStringFieldsEntity = SearchView.this._modelExtensions.hasAbstractStringFieldsEntity(e);
            return Boolean.valueOf(_hasAbstractStringFieldsEntity);
          }
        };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
      for(final Entity entity : _filter) {
        String _nameMultiple = entity.getNameMultiple();
        final String nameMultiLower = this._formattingExtensions.formatForDB(_nameMultiple);
        _builder.newLineIfNotEmpty();
        _builder.append("<div>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<input type=\"checkbox\" id=\"active_");
        _builder.append(appLower, "    ");
        _builder.append("_");
        _builder.append(nameMultiLower, "    ");
        _builder.append("\" name=\"search_");
        _builder.append(appLower, "    ");
        _builder.append("_types[]\" value=\"");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append("\"{if $active_");
        String _name_1 = entity.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("} checked=\"checked\"{/if} />");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<label for=\"active_");
        _builder.append(appLower, "    ");
        _builder.append("_");
        _builder.append(nameMultiLower, "    ");
        _builder.append("\">{gt text=\'");
        String _nameMultiple_1 = entity.getNameMultiple();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_nameMultiple_1);
        _builder.append(_formatForDisplayCapital, "    ");
        _builder.append("\' domain=\'module_");
        _builder.append(appLower, "    ");
        _builder.append("\'}</label>");
        _builder.newLineIfNotEmpty();
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
}
