package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractStringField;
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
public class Kml {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating kml view templates for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String templateFilePath = "";
    boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
    if (_hasViewAction) {
      templateFilePath = this._namingExtensions.templateFileWithExtension(it, "view", "kml");
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
      boolean _not = (!_shouldBeSkipped);
      if (_not) {
        fsa.generateFile(templateFilePath, this.kmlView(it, appName));
      }
    }
    boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
    if (_hasDisplayAction) {
      templateFilePath = this._namingExtensions.templateFileWithExtension(it, "display", "kml");
      boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
      boolean _not_1 = (!_shouldBeSkipped_1);
      if (_not_1) {
        fsa.generateFile(templateFilePath, this.kmlDisplay(it, appName));
      }
    }
  }
  
  private CharSequence kmlView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" view kml view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    _builder.newLine();
    _builder.append("<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\">");
    _builder.newLine();
    _builder.append("<Document>");
    _builder.newLine();
    _builder.append("{% for ");
    _builder.append(objName);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<Placemark>");
    _builder.newLine();
    _builder.append("        ");
    Iterable<StringField> _filter = Iterables.<StringField>filter(it.getFields(), StringField.class);
    Iterable<TextField> _filter_1 = Iterables.<TextField>filter(it.getFields(), TextField.class);
    final Iterable<AbstractStringField> stringFields = Iterables.<AbstractStringField>concat(_filter, _filter_1);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<name>");
    {
      boolean _isEmpty = IterableExtensions.isEmpty(stringFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("{{ ");
        _builder.append(objName, "        ");
        _builder.append(".get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(IterableExtensions.<AbstractStringField>head(stringFields).getName());
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("() }}");
      } else {
        _builder.append("{{ __(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\') }}");
      }
    }
    _builder.append("</name>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    final Iterable<TextField> textFields = Iterables.<TextField>filter(it.getFields(), TextField.class);
    _builder.newLineIfNotEmpty();
    {
      if (((!IterableExtensions.isEmpty(textFields)) && (!Objects.equal(IterableExtensions.<TextField>head(textFields), IterableExtensions.<AbstractStringField>head(stringFields))))) {
        _builder.append("        ");
        _builder.append("<description><![CDATA[{{ ");
        _builder.append(objName, "        ");
        _builder.append(".get");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(IterableExtensions.<TextField>head(textFields).getName());
        _builder.append(_formatForCodeCapital_1, "        ");
        _builder.append("() }}");
        {
          boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
          if (_hasDisplayAction) {
            _builder.append("<br /><a href=\"{{ url(\'");
            String _lowerCase = appName.toLowerCase();
            _builder.append(_lowerCase, "        ");
            _builder.append("_");
            String _lowerCase_1 = this._formattingExtensions.formatForCode(it.getName()).toLowerCase();
            _builder.append(_lowerCase_1, "        ");
            _builder.append("_display\'");
            CharSequence _routeParams = this._urlExtensions.routeParams(it, this._formattingExtensions.formatForCode(it.getName()), Boolean.valueOf(true));
            _builder.append(_routeParams, "        ");
            _builder.append(") }}\">{{ __(\'Details\') }}</a>");
          }
        }
        _builder.append("]]></description>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("<Point>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<coordinates>{{ ");
    _builder.append(objName, "            ");
    _builder.append(".getLongitude() }}, {{ ");
    _builder.append(objName, "            ");
    _builder.append(".getLatitude() }}, 0</coordinates>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</Point>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</Placemark>");
    _builder.newLine();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("</Document>");
    _builder.newLine();
    _builder.append("</kml>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence kmlDisplay(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" display kml view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    _builder.newLine();
    _builder.append("<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\">");
    _builder.newLine();
    _builder.append("<Document>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<Placemark>");
    _builder.newLine();
    _builder.append("        ");
    Iterable<StringField> _filter = Iterables.<StringField>filter(it.getFields(), StringField.class);
    Iterable<TextField> _filter_1 = Iterables.<TextField>filter(it.getFields(), TextField.class);
    final Iterable<AbstractStringField> stringFields = Iterables.<AbstractStringField>concat(_filter, _filter_1);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<name>");
    {
      boolean _isEmpty = IterableExtensions.isEmpty(stringFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("{{ ");
        _builder.append(objName, "        ");
        _builder.append(".get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(IterableExtensions.<AbstractStringField>head(stringFields).getName());
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("() }}");
      } else {
        _builder.append("{{ __(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\') }}");
      }
    }
    _builder.append("</name>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    final Iterable<TextField> textFields = Iterables.<TextField>filter(it.getFields(), TextField.class);
    _builder.newLineIfNotEmpty();
    {
      if (((!IterableExtensions.isEmpty(textFields)) && (!Objects.equal(IterableExtensions.<TextField>head(textFields), IterableExtensions.<AbstractStringField>head(stringFields))))) {
        _builder.append("        ");
        _builder.append("<description><![CDATA[{{ ");
        _builder.append(objName, "        ");
        _builder.append(".get");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(IterableExtensions.<TextField>head(textFields).getName());
        _builder.append(_formatForCodeCapital_1, "        ");
        _builder.append("() }}");
        {
          boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
          if (_hasDisplayAction) {
            _builder.append("<br /><a href=\"{{ url(\'");
            String _lowerCase = appName.toLowerCase();
            _builder.append(_lowerCase, "        ");
            _builder.append("_");
            String _lowerCase_1 = this._formattingExtensions.formatForCode(it.getName()).toLowerCase();
            _builder.append(_lowerCase_1, "        ");
            _builder.append("_display\'");
            CharSequence _routeParams = this._urlExtensions.routeParams(it, this._formattingExtensions.formatForCode(it.getName()), Boolean.valueOf(true));
            _builder.append(_routeParams, "        ");
            _builder.append(") }}\">{{ __(\'Details\') }}</a>");
          }
        }
        _builder.append("]]></description>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("<Point>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<coordinates>{{ ");
    _builder.append(objName, "            ");
    _builder.append(".getLongitude() }}, {{ ");
    _builder.append(objName, "            ");
    _builder.append(".getLatitude() }}, 0</coordinates>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</Point>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</Placemark>");
    _builder.newLine();
    _builder.append("</Document>");
    _builder.newLine();
    _builder.append("</kml>");
    _builder.newLine();
    return _builder;
  }
}
