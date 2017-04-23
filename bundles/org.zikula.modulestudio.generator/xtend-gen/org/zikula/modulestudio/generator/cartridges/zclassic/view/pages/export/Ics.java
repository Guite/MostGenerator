package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UrlField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Ics {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating ics view templates for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    final String templateFilePath = this._namingExtensions.templateFileWithExtension(it, "display", "ics");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      fsa.generateFile(templateFilePath, this.icsDisplay(it, appName));
    }
  }
  
  private CharSequence icsDisplay(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" display ics view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("BEGIN:VCALENDAR");
    _builder.newLine();
    _builder.append("VERSION:2.0");
    _builder.newLine();
    _builder.append("PRODID:{{ app.request.getSchemeAndHttpHost() }}");
    _builder.newLine();
    _builder.append("METHOD:PUBLISH");
    _builder.newLine();
    _builder.append("BEGIN:VEVENT");
    _builder.newLine();
    _builder.append("DTSTART:{{ ");
    _builder.append(objName);
    _builder.append("|date(\'Ymd\\THi00\\Z\') }}");
    _builder.newLineIfNotEmpty();
    _builder.append("DTEND:{{ ");
    _builder.append(objName);
    _builder.append("|date(\'Ymd\\THi00\\Z\') }}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    _builder.append(objName);
    _builder.append(".zipcode != \'\' and ");
    _builder.append(objName);
    _builder.append(".city is not empty %}{% set location = ");
    _builder.append(objName);
    _builder.append(".zipcode ~ \' \' ~ ");
    _builder.append(objName);
    _builder.append(".city %}LOCATION{{ location|");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB);
    _builder.append("_icalText }}{% endif %}");
    _builder.newLineIfNotEmpty();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        _builder.append("{% if ");
        _builder.append(objName);
        _builder.append(".latitude and ");
        _builder.append(objName);
        _builder.append(".longitude %}GEO:{{ ");
        _builder.append(objName);
        _builder.append(".longitude }};{{ ");
        _builder.append(objName);
        _builder.append(".latitude }}");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("TRANSP:OPAQUE");
    _builder.newLine();
    _builder.append("SEQUENCE:0");
    _builder.newLine();
    _builder.append("UID:{{ \'ICAL\' ~ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getStartDateField(it).getName());
    _builder.append(_formatForCode);
    _builder.append(" ~ random(5000) ~ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(this._modelExtensions.getEndDateField(it).getName());
    _builder.append(_formatForCode_1);
    _builder.append(" }}");
    _builder.newLineIfNotEmpty();
    _builder.append("DTSTAMP:{{ \'now\'|date(\'Ymd\\THi00\\Z\') }}");
    _builder.newLine();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("ORGANIZER;CN=\"{{ ");
        _builder.append(objName);
        _builder.append(".createdBy.getUname() }}\":MAILTO:{{ ");
        _builder.append(objName);
        _builder.append(".createdBy.getEmail() }}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("CATEGORIES:{% for propName, catMapping in ");
        _builder.append(objName);
        _builder.append(".categories %}{% if not loop.first %},{% endif %}{{ catMapping.category.display_name[lang]|upper %}{% endfor %}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("SUMMARY{{ ");
    _builder.append(objName);
    _builder.append(".getTitleFromDisplayPattern()|");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_1);
    _builder.append("_icalText }}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasTextFieldsEntity = this._modelExtensions.hasTextFieldsEntity(it);
      if (_hasTextFieldsEntity) {
        final TextField field = IterableExtensions.<TextField>head(this._modelExtensions.getTextFieldsEntity(it));
        _builder.newLineIfNotEmpty();
        _builder.append("{% if ");
        _builder.append(objName);
        _builder.append(".");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode_2);
        _builder.append(" is not empty %}DESCRIPTION{{ ");
        _builder.append(objName);
        _builder.append(".");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode_3);
        _builder.append("|");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_2);
        _builder.append("_icalText }}{% endif %}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("PRIORITY:5");
    _builder.newLine();
    {
      boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity) {
        {
          Iterable<UploadField> _uploadFieldsEntity = this._modelExtensions.getUploadFieldsEntity(it);
          for(final UploadField field_1 : _uploadFieldsEntity) {
            _builder.append("{% if ");
            _builder.append(objName);
            _builder.append(".");
            String _formatForCode_4 = this._formattingExtensions.formatForCode(field_1.getName());
            _builder.append(_formatForCode_4);
            _builder.append(" %}ATTACH;VALUE=URL:{{ ");
            _builder.append(objName);
            _builder.append(".");
            String _formatForCode_5 = this._formattingExtensions.formatForCode(field_1.getName());
            _builder.append(_formatForCode_5);
            _builder.append("Url }}");
            _builder.newLineIfNotEmpty();
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<UrlField>filter(it.getFields(), UrlField.class));
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          Iterable<UrlField> _filter = Iterables.<UrlField>filter(it.getFields(), UrlField.class);
          for(final UrlField field_2 : _filter) {
            _builder.append("{% if ");
            _builder.append(objName);
            _builder.append(".");
            String _formatForCode_6 = this._formattingExtensions.formatForCode(field_2.getName());
            _builder.append(_formatForCode_6);
            _builder.append(" %}ATTACH;VALUE=URL:{{ ");
            _builder.append(objName);
            _builder.append(".");
            String _formatForCode_7 = this._formattingExtensions.formatForCode(field_2.getName());
            _builder.append(_formatForCode_7);
            _builder.append(" }}");
            _builder.newLineIfNotEmpty();
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("CLASS:PUBLIC");
    _builder.newLine();
    _builder.append("STATUS:CONFIRMED");
    _builder.newLine();
    _builder.append("END:VEVENT");
    _builder.newLine();
    _builder.append("END:VCALENDAR");
    _builder.newLine();
    return _builder;
  }
}
