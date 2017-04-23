package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed;

import com.google.common.collect.Iterables;
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
public class Rss {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    final String templateFilePath = this._namingExtensions.templateFileWithExtension(it, "view", "rss");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
      String _plus = ("Generating rss view templates for entity \"" + _formatForDisplay);
      String _plus_1 = (_plus + "\"");
      InputOutput.<String>println(_plus_1);
      fsa.generateFile(templateFilePath, this.rssView(it, appName));
    }
  }
  
  private CharSequence rssView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" rss feed #}");
    _builder.newLineIfNotEmpty();
    _builder.append("<?xml version=\"1.0\" encoding=\"{% set charset = pageGetVar(\'meta.charset\') %}{% if charset == \'ISO-8859-15\' %}ISO-8859-1{% else %}{{ charset }}{% endif %}\" ?>");
    _builder.newLine();
    _builder.append("<rss version=\"2.0\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("xmlns:dc=\"http://purl.org/dc/elements/1.1/\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("xmlns:sy=\"http://purl.org/rss/1.0/modules/syndication/\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("xmlns:admin=\"http://webns.net/mvcb/\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("xmlns:content=\"http://purl.org/rss/1.0/modules/content/\"");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("xmlns:atom=\"http://www.w3.org/2005/Atom\">");
    _builder.newLine();
    _builder.append("{#<rss version=\"0.92\">#}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<channel>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<title>{{ __(\'Latest ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_1, "        ");
    _builder.append("\') }}</title>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<link>{{ app.request.getSchemeAndHttpHost() ~ app.request.getBasePath()|e }}</link>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<atom:link href=\"{{ app.request.getSchemeAndHttpHost() ~ app.request.getPathInfo() }}\" rel=\"self\" type=\"application/rss+xml\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<description>{{ __(\'A direct feed showing the list of ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_2, "        ");
    _builder.append("\') }} - {{ getModVar(\'ZConfig\', \'slogan\') }}</description>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<language>{{ app.request.locale }}</language>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{# commented out as imagepath is not defined and we can\'t know whether this logo exists or not");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<image>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<title>{{ getModVar(\'ZConfig\', \'sitename\') }}</title>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<url>{{ app.request.getSchemeAndHttpHost() ~ app.request.getBasePath()|e }}{{ imagepath }}/logo.jpg</url>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<link>{{ app.request.getSchemeAndHttpHost() ~ app.request.getBasePath()|e }}</link>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</image>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("#}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<docs>http://blogs.law.harvard.edu/tech/rss</docs>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<copyright>Copyright (c) {{ \'now\'|date(\'Y\') }}, {{ app.request.getSchemeAndHttpHost()|e }}</copyright>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<webMaster>{{ pageGetVar(\'adminmail)|e }}</webMaster>");
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
    _builder.append("    ");
    _builder.append("</channel>");
    _builder.newLine();
    _builder.append("</rss>");
    _builder.newLine();
    _builder.append("{% block entry %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<item>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ block(\'entry_content\') }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</item>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block entry_content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<title><![CDATA[{% if ");
    _builder.append(objName, "    ");
    _builder.append(".updatedDate|default %}{{ ");
    _builder.append(objName, "    ");
    _builder.append(".updatedDate|localizeddate(\'medium\', \'short\') }} - {% endif %}{{ ");
    _builder.append(objName, "    ");
    _builder.append(".getTitleFromDisplayPattern()");
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("|notifyFilters(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB, "    ");
        _builder.append(".filterhook.");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getNameMultiple());
        _builder.append(_formatForDB_1, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(" }}]]></title>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<link>{{ url(\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_2, "    ");
    _builder.append("_");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_3, "    ");
    _builder.append("_\' ~ routeArea ~ \'");
    CharSequence _defaultAction = this._controllerExtensions.defaultAction(it);
    _builder.append(_defaultAction, "    ");
    _builder.append("\'");
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        CharSequence _routeParams = this._urlExtensions.routeParams(it, objName, Boolean.valueOf(true));
        _builder.append(_routeParams, "    ");
      }
    }
    _builder.append(") }}</link>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<guid>{{ url(\'");
    String _formatForDB_4 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_4, "    ");
    _builder.append("_");
    String _formatForDB_5 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_5, "    ");
    _builder.append("_\' ~ routeArea ~ \'");
    CharSequence _defaultAction_1 = this._controllerExtensions.defaultAction(it);
    _builder.append(_defaultAction_1, "    ");
    _builder.append("\'");
    {
      boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction_1) {
        CharSequence _routeParams_1 = this._urlExtensions.routeParams(it, objName, Boolean.valueOf(true));
        _builder.append(_routeParams_1, "    ");
      }
    }
    _builder.append(") }}</guid>");
    _builder.newLineIfNotEmpty();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
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
        _builder.append("<author>{{ ");
        _builder.append(objName, "        ");
        _builder.append(".createdBy.getEmail() }} ({{ creatorAttributes.get(\'realname\')|default(creatorAttributes.get(\'name\'))|default(");
        _builder.append(objName, "        ");
        _builder.append(".createdBy.getUname()) }})</author>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("    ");
        _builder.append("<category><![CDATA[{{ __(\'Categories\') }}: {% for propName, catMapping in ");
        _builder.append(objName, "    ");
        _builder.append(".categories %}{{ catMapping.category.display_name[lang] }}{% if not loop.last %}, {% endif %}{% endfor %}]]></category>");
        _builder.newLineIfNotEmpty();
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
    _builder.append("<description>");
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
        _builder.append("|replace({ \'<br>\': \'<br />\' }) }}");
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
    _builder.append("    ");
    _builder.append("]]>");
    _builder.newLine();
    _builder.append("</description>");
    _builder.newLine();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("{% if ");
        _builder.append(objName);
        _builder.append(".createdDate|default %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<pubDate>{{ ");
        _builder.append(objName, "    ");
        _builder.append(".createdDate|date(\'a, d b Y T +0100\') }}</pubDate>");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
}
