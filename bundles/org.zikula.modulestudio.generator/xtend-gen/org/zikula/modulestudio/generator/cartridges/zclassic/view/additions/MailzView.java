package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class MailzView {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Mailz/");
    final String templateExtension = ".twig";
    String entityTemplate = "";
    Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      {
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        String _plus = ((templatePath + "itemlist_") + _formatForCode);
        String _plus_1 = (_plus + ".text");
        String _plus_2 = (_plus_1 + templateExtension);
        entityTemplate = _plus_2;
        boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, entityTemplate);
        boolean _not = (!_shouldBeSkipped);
        if (_not) {
          boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, entityTemplate);
          if (_shouldBeMarked) {
            String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
            String _plus_3 = ((templatePath + "itemlist_") + _formatForCode_1);
            String _plus_4 = (_plus_3 + ".generated.text");
            String _plus_5 = (_plus_4 + templateExtension);
            entityTemplate = _plus_5;
          }
          fsa.generateFile(entityTemplate, this.textTemplate(entity, it));
        }
        String _formatForCode_2 = this._formattingExtensions.formatForCode(entity.getName());
        String _plus_6 = ((templatePath + "itemlist_") + _formatForCode_2);
        String _plus_7 = (_plus_6 + ".html");
        String _plus_8 = (_plus_7 + templateExtension);
        entityTemplate = _plus_8;
        boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, entityTemplate);
        boolean _not_1 = (!_shouldBeSkipped_1);
        if (_not_1) {
          boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, entityTemplate);
          if (_shouldBeMarked_1) {
            String _formatForCode_3 = this._formattingExtensions.formatForCode(entity.getName());
            String _plus_9 = ((templatePath + "itemlist_") + _formatForCode_3);
            String _plus_10 = (_plus_9 + ".generated.html");
            String _plus_11 = (_plus_10 + templateExtension);
            entityTemplate = _plus_11;
          }
          fsa.generateFile(entityTemplate, this.htmlTemplate(entity, it));
        }
      }
    }
  }
  
  private CharSequence textTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" in text mailings #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% for ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    CharSequence _mailzEntryText = this.mailzEntryText(it, this._utils.appName(app));
    _builder.append(_mailzEntryText);
    _builder.newLineIfNotEmpty();
    _builder.append("-----");
    _builder.newLine();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("{{ __(\'No ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_1);
    _builder.append(" found.\') }}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endfor %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence htmlTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" in html mailings #}");
    _builder.newLineIfNotEmpty();
    {
      boolean _generateListContentType = this._generatorSettingsExtensions.generateListContentType(app);
      if (_generateListContentType) {
        _builder.append("{#");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("{% for ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<li>");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _mailzEntryHtml = this.mailzEntryHtml(it, app);
    _builder.append(_mailzEntryHtml, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</li>");
    _builder.newLine();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<li>{{ __(\'No ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append(" found.\') }}</li>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("</ul>");
    _builder.newLine();
    {
      boolean _generateListContentType_1 = this._generatorSettingsExtensions.generateListContentType(app);
      if (_generateListContentType_1) {
        _builder.append("#}");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("{{ include(\'@");
        String _appName = this._utils.appName(app);
        _builder.append(_appName);
        _builder.append("/ContentType/itemlist_");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1);
        _builder.append("_display_description.html.twig\') }}");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence mailzEntryText(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(".getTitleFromDisplayPattern() }}");
    _builder.newLineIfNotEmpty();
    CharSequence _mailzEntryHtmlLinkUrl = this.mailzEntryHtmlLinkUrl(it, it.getApplication());
    _builder.append(_mailzEntryHtmlLinkUrl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence mailzEntryHtml(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<a href=\"");
    CharSequence _mailzEntryHtmlLinkUrl = this.mailzEntryHtmlLinkUrl(it, app);
    _builder.append(_mailzEntryHtmlLinkUrl);
    _builder.append("\">{{ ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(".getTitleFromDisplayPattern() }}</a>");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence mailzEntryHtmlLinkUrl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("{{ url(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB);
        _builder.append("_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_1);
        _builder.append("_display\'");
        CharSequence _routeParams = this._urlExtensions.routeParams(it, this._formattingExtensions.formatForCode(it.getName()), Boolean.valueOf(true));
        _builder.append(_routeParams);
        _builder.append(") }}");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
        if (_hasViewAction) {
          _builder.append("{{ url(\'");
          String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(app));
          _builder.append(_formatForDB_2);
          _builder.append("_");
          String _formatForDB_3 = this._formattingExtensions.formatForDB(it.getName());
          _builder.append(_formatForDB_3);
          _builder.append("_view\') }}");
          _builder.newLineIfNotEmpty();
        } else {
          boolean _hasIndexAction = this._controllerExtensions.hasIndexAction(it);
          if (_hasIndexAction) {
            _builder.append("{{ url(\'");
            String _formatForDB_4 = this._formattingExtensions.formatForDB(this._utils.appName(app));
            _builder.append(_formatForDB_4);
            _builder.append("_");
            String _formatForDB_5 = this._formattingExtensions.formatForDB(it.getName());
            _builder.append(_formatForDB_5);
            _builder.append("_index\') }}");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("{{ app.request.getSchemeAndHttpHost() ~ app.request.getBasePath() }}");
            _builder.newLine();
            _builder.append("        ");
          }
        }
      }
    }
    return _builder;
  }
}
