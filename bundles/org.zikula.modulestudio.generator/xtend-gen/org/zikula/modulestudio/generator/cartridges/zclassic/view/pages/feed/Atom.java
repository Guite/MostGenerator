package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;

@SuppressWarnings("all")
public class Atom {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  private Application app;
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    this.app = it.getApplication();
    final String templateFilePath = this._namingExtensions.templateFileWithExtension(it, "view", "atom");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(this.app, templateFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
      String _plus = ("Generating atom view templates for entity \"" + _formatForDisplay);
      String _plus_1 = (_plus + "\"");
      InputOutput.<String>println(_plus_1);
      fsa.generateFile(templateFilePath, this.atomView(it, appName));
    }
  }
  
  private CharSequence atomView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" atom feed #}");
    _builder.newLineIfNotEmpty();
    _builder.append("<?xml version=\"1.0\" encoding=\"{% set charset = pageGetVar(\'meta.charset\') %}{% if charset == \'ISO-8859-15\' %}ISO-8859-1{% else %}{{ charset }}{% endif %}\" ?>");
    _builder.newLine();
    _builder.append("<feed xmlns=\"http://www.w3.org/2005/Atom\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<title type=\"text\">{{ __(\'Latest ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\') }}</title>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<subtitle type=\"text\">{{ __(\'A direct feed showing the list of ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_2, "    ");
    _builder.append("\') }} - {{ getModVar(\'ZConfig\', \'slogan\') }}</subtitle>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<author>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<name>{{ getModVar(\'ZConfig\', \'sitename\') }}</name>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</author>");
    _builder.newLine();
    _builder.append("{% set amountOfItems = items|length %}");
    _builder.newLine();
    _builder.append("{% if amountOfItems > 0 %}");
    _builder.newLine();
    _builder.append("{% set uniqueID %}tag:{{ app.request.getSchemeAndHttpHost()|replace({ \'http://\': \'\', \'/\': \'\' }) }},{{ ");
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("items.first.createdDate");
      } else {
        _builder.append("\'now\'");
      }
    }
    _builder.append("|date(\'Y-m-d\') }}:{{ path(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB);
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1);
    _builder.append("_\' ~ routeArea ~ \'");
    CharSequence _defaultAction = this._controllerExtensions.defaultAction(it);
    _builder.append(_defaultAction);
    _builder.append("\'");
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        CharSequence _routeParams = this._urlExtensions.routeParams(it, "items.first", Boolean.valueOf(true));
        _builder.append(_routeParams);
      }
    }
    _builder.append(") }}{% endset %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<id>{{ uniqueID }}</id>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<updated>{{ ");
    {
      boolean _isStandardFields_1 = it.isStandardFields();
      if (_isStandardFields_1) {
        _builder.append("items[0].updatedDate");
      } else {
        _builder.append("\'now\'");
      }
    }
    _builder.append("|date(\'Y-m-dTH:M:SZ\') }}</updated>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<link rel=\"alternate\" type=\"text/html\" hreflang=\"{{ app.request.locale }}\" href=\"{{ url(\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_2, "    ");
    _builder.append("_");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_3, "    ");
    _builder.append("_\' ~ routeArea ~ \'");
    {
      boolean _hasIndexAction = this._controllerExtensions.hasIndexAction(it);
      if (_hasIndexAction) {
        _builder.append("index");
      } else {
        boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
        if (_hasViewAction) {
          _builder.append("view");
        } else {
          CharSequence _defaultAction_1 = this._controllerExtensions.defaultAction(it);
          _builder.append(_defaultAction_1, "    ");
        }
      }
    }
    _builder.append("\') }}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<link rel=\"self\" type=\"application/atom+xml\" href=\"{{ app.request.getSchemeAndHttpHost() ~ app.request.getBasePath() }}\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<rights>Copyright (c) {{ \'now\'|date(\'Y\') }}, {{ app.request.getSchemeAndHttpHost()|e }}</rights>");
    _builder.newLine();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{% for ");
    _builder.append(objName);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ block(\'entry\') }}");
    _builder.newLine();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("</feed>");
    _builder.newLine();
    _builder.append("{% block entry %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<entry>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ block(\'entry_content\') }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</entry>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block entry_content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<title type=\"html\">{{ ");
    _builder.append(objName, "    ");
    _builder.append(".getTitleFromDisplayPattern()");
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("|notifyFilters(\'");
        String _formatForDB_4 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_4, "    ");
        _builder.append(".filterhook.");
        String _formatForDB_5 = this._formattingExtensions.formatForDB(it.getNameMultiple());
        _builder.append(_formatForDB_5, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(" }}</title>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<link rel=\"alternate\" type=\"text/html\" href=\"{{ url(\'");
    String _formatForDB_6 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_6, "    ");
    _builder.append("_");
    String _formatForDB_7 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_7, "    ");
    _builder.append("_\' ~ routeArea ~ \'");
    CharSequence _defaultAction_2 = this._controllerExtensions.defaultAction(it);
    _builder.append(_defaultAction_2, "    ");
    _builder.append("\'");
    {
      boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction_1) {
        CharSequence _routeParams_1 = this._urlExtensions.routeParams(it, objName, Boolean.valueOf(true));
        _builder.append(_routeParams_1, "    ");
      }
    }
    _builder.append(") }}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% set uniqueID %}tag:{{ app.request.getSchemeAndHttpHost()|replace({ \'http://\': \'\', \'/\': \'\' }) }},{{ ");
    {
      boolean _isStandardFields_2 = it.isStandardFields();
      if (_isStandardFields_2) {
        _builder.append(objName, "    ");
        _builder.append(".createdDate");
      } else {
        _builder.append("\'now\'");
      }
    }
    _builder.append("|date(\'Y-m-d\') }}:{{ path(\'");
    String _formatForDB_8 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_8, "    ");
    _builder.append("_");
    String _formatForDB_9 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_9, "    ");
    _builder.append("_\' ~ routeArea ~ \'");
    CharSequence _defaultAction_3 = this._controllerExtensions.defaultAction(it);
    _builder.append(_defaultAction_3, "    ");
    _builder.append("\'");
    {
      boolean _hasDisplayAction_2 = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction_2) {
        CharSequence _routeParams_2 = this._urlExtensions.routeParams(it, objName, Boolean.valueOf(true));
        _builder.append(_routeParams_2, "    ");
      }
    }
    _builder.append(") }}{% endset %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<id>{{ uniqueID }}</id>");
    _builder.newLine();
    {
      boolean _isStandardFields_3 = it.isStandardFields();
      if (_isStandardFields_3) {
        _builder.append("    ");
        _builder.append("{% if ");
        _builder.append(objName, "    ");
        _builder.append(".updatedDate|default %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<updated>{{ ");
        _builder.append(objName, "        ");
        _builder.append(".updatedDate|date(\'Y-m-dTH:M:SZ\') }}</updated>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% if ");
        _builder.append(objName, "    ");
        _builder.append(".createdDate|default %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<published>{{ ");
        _builder.append(objName, "        ");
        _builder.append(".createdDate|date(\'Y-m-dTH:M:SZ\') }}</published>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% if ");
        _builder.append(objName, "    ");
        _builder.append(".createdBy|default and ");
        _builder.append(objName, "    ");
        _builder.append(".createdBy.getUid() > 0 %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("{% set creatorAttributes = ");
        _builder.append(objName, "        ");
        _builder.append(".createdBy.getAttributes() %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<author>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("<name>{{ creatorAttributes.get(\'realname\')|default(creatorAttributes.get(\'name\'))|default(");
        _builder.append(objName, "           ");
        _builder.append(".createdBy.getUname()) }}</name>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("<uri>{{ creatorAttributes.get(\'_UYOURHOMEPAGE\')|default(\'-\') }}</uri>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("<email>{{ ");
        _builder.append(objName, "           ");
        _builder.append(".createdBy.getEmail() }}</email>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("</author>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _description = this.description(it, objName);
    _builder.append(_description, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence description(final Entity it, final String objName) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<TextField> textFields = Iterables.<TextField>filter(it.getFields(), TextField.class);
    _builder.newLineIfNotEmpty();
    final Iterable<StringField> stringFields = Iterables.<StringField>filter(it.getFields(), StringField.class);
    _builder.newLineIfNotEmpty();
    _builder.append("<summary type=\"html\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<![CDATA[");
    _builder.newLine();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(textFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("    ");
        _builder.append("{{ ");
        _builder.append(objName, "    ");
        _builder.append(".");
        String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<TextField>head(textFields).getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("|truncate(150, true, \'&hellip;\')|default(\'-\') }}");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isEmpty_1 = IterableExtensions.isEmpty(stringFields);
        boolean _not_1 = (!_isEmpty_1);
        if (_not_1) {
          _builder.append("    ");
          _builder.append("{{ ");
          _builder.append(objName, "    ");
          _builder.append(".");
          String _formatForCode_1 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(stringFields).getName());
          _builder.append(_formatForCode_1, "    ");
          _builder.append("|truncate(150, true, \'&hellip;\')|default(\'-\') }}");
          _builder.newLineIfNotEmpty();
        } else {
          _builder.append("    ");
          _builder.append("{{ ");
          _builder.append(objName, "    ");
          _builder.append(".getTitleFromDisplayPattern()|truncate(150, true, \'&hellip;\')|default(\'-\') }}");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    _builder.append("    ");
    _builder.append("]]>");
    _builder.newLine();
    _builder.append("</summary>");
    _builder.newLine();
    _builder.append("<content type=\"html\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<![CDATA[");
    _builder.newLine();
    {
      int _size = IterableExtensions.size(textFields);
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        _builder.append("    ");
        _builder.append("{{ ");
        _builder.append(objName, "    ");
        _builder.append(".");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(IterableExtensions.<TextField>head(IterableExtensions.<TextField>tail(textFields)).getName());
        _builder.append(_formatForCode_2, "    ");
        _builder.append("|replace({ \'<br>\': \'<br />\' }) }}");
        _builder.newLineIfNotEmpty();
      } else {
        if (((!IterableExtensions.isEmpty(textFields)) && (!IterableExtensions.isEmpty(stringFields)))) {
          _builder.append("    ");
          _builder.append("{{ ");
          _builder.append(objName, "    ");
          _builder.append(".");
          String _formatForCode_3 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(stringFields).getName());
          _builder.append(_formatForCode_3, "    ");
          _builder.append("|replace({ \'<br>\': \'<br />\' }) }}");
          _builder.newLineIfNotEmpty();
        } else {
          int _size_1 = IterableExtensions.size(stringFields);
          boolean _greaterThan_1 = (_size_1 > 1);
          if (_greaterThan_1) {
            _builder.append("    ");
            _builder.append("{{ ");
            _builder.append(objName, "    ");
            _builder.append(".");
            String _formatForCode_4 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(IterableExtensions.<StringField>tail(stringFields)).getName());
            _builder.append(_formatForCode_4, "    ");
            _builder.append("|replace({ \'<br>\': \'<br />\' }) }}");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("{{ ");
            _builder.append(objName, "    ");
            _builder.append(".getTitleFromDisplayPattern()|replace({ \'<br>\': \'<br />\' }) }}");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("]]>");
    _builder.newLine();
    _builder.append("</content>");
    _builder.newLine();
    return _builder;
  }
}
