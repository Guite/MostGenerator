package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Kml {
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
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
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
  
  public void generate(final Entity it, final String appName, final Controller controller, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " kml view templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    boolean _hasActions = this._controllerExtensions.hasActions(controller, "view");
    if (_hasActions) {
      String _name_1 = it.getName();
      String _templateFileWithExtension = this._namingExtensions.templateFileWithExtension(controller, _name_1, "view", "kml");
      CharSequence _kmlView = this.kmlView(it, appName, controller);
      fsa.generateFile(_templateFileWithExtension, _kmlView);
    }
    boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "display");
    if (_hasActions_1) {
      String _name_2 = it.getName();
      String _templateFileWithExtension_1 = this._namingExtensions.templateFileWithExtension(controller, _name_2, "display", "kml");
      CharSequence _kmlDisplay = this.kmlDisplay(it, appName, controller);
      fsa.generateFile(_templateFileWithExtension_1, _kmlDisplay);
    }
  }
  
  private CharSequence kmlView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" view kml view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("TemplateHeaders contentType=\'application/vnd.google-earth.kml+xml\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    _builder.newLine();
    _builder.append("<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\">");
    _builder.newLine();
    _builder.append("<Document>");
    _builder.newLine();
    _builder.append("{foreach item=\'item\' from=$items}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<Placemark>");
    _builder.newLine();
    _builder.append("        ");
    EList<EntityField> _fields = it.getFields();
    Iterable<StringField> _filter = Iterables.<StringField>filter(_fields, StringField.class);
    EList<EntityField> _fields_1 = it.getFields();
    Iterable<TextField> _filter_1 = Iterables.<TextField>filter(_fields_1, TextField.class);
    final Iterable<AbstractStringField> stringFields = Iterables.<AbstractStringField>concat(_filter, _filter_1);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<name>");
    {
      boolean _isEmpty = IterableExtensions.isEmpty(stringFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("{$item->get");
        AbstractStringField _head = IterableExtensions.<AbstractStringField>head(stringFields);
        String _name = _head.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("()}");
      } else {
        _builder.append("{gt text=\'");
        String _name_1 = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\'}");
      }
    }
    _builder.append("</name>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<Point>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<coordinates>{$item->getLongitude()}, {$item->getLatitude()}, 0</coordinates>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</Point>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</Placemark>");
    _builder.newLine();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("</Document>");
    _builder.newLine();
    _builder.append("</kml>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence kmlDisplay(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" display kml view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("TemplateHeaders contentType=\'application/vnd.google-earth.kml+xml\'}");
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
    EList<EntityField> _fields = it.getFields();
    Iterable<StringField> _filter = Iterables.<StringField>filter(_fields, StringField.class);
    EList<EntityField> _fields_1 = it.getFields();
    Iterable<TextField> _filter_1 = Iterables.<TextField>filter(_fields_1, TextField.class);
    final Iterable<AbstractStringField> stringFields = Iterables.<AbstractStringField>concat(_filter, _filter_1);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<name>");
    {
      boolean _isEmpty = IterableExtensions.isEmpty(stringFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("{$");
        _builder.append(objName, "        ");
        _builder.append("->get");
        AbstractStringField _head = IterableExtensions.<AbstractStringField>head(stringFields);
        String _name_1 = _head.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("()}");
      } else {
        _builder.append("{gt text=\'");
        String _name_2 = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_2);
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\'}");
      }
    }
    _builder.append("</name>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<Point>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<coordinates>{$");
    _builder.append(objName, "            ");
    _builder.append("->getLongitude()}, {$");
    _builder.append(objName, "            ");
    _builder.append("->getLatitude()}, 0</coordinates>");
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
