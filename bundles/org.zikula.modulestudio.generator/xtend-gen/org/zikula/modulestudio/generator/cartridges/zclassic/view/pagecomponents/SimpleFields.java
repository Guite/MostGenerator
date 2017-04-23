package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.EmailField;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.TimeField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UrlField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class SimpleFields {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  protected CharSequence _displayField(final EntityField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(" }}");
    return _builder;
  }
  
  protected CharSequence _displayField(final BooleanField it, final String objName, final String page) {
    CharSequence _xifexpression = null;
    if ((it.isAjaxTogglability() && (Objects.equal(page, "view") || Objects.equal(page, "display")))) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("{% set itemid = ");
      _builder.append(objName);
      _builder.append(".createCompositeIdentifier() %}");
      _builder.newLineIfNotEmpty();
      _builder.append("<a id=\"toggle");
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
      _builder.append(_formatForCodeCapital);
      _builder.append("{{ itemid }}\" href=\"javascript:void(0);\" class=\"");
      String _lowerCase = this._utils.vendorAndName(it.getEntity().getApplication()).toLowerCase();
      _builder.append(_lowerCase);
      _builder.append("-ajax-toggle hidden\" data-object-type=\"");
      String _formatForCode = this._formattingExtensions.formatForCode(it.getEntity().getName());
      _builder.append(_formatForCode);
      _builder.append("\" data-field-name=\"");
      String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
      _builder.append(_formatForCode_1);
      _builder.append("\" data-item-id=\"{{ itemid }}\">");
      _builder.newLineIfNotEmpty();
      _builder.append("    ");
      _builder.append("<i class=\"fa fa-check{% if not ");
      _builder.append(objName, "    ");
      _builder.append(".");
      String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
      _builder.append(_formatForCode_2, "    ");
      _builder.append(" %} hidden{% endif %}\" id=\"yes");
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
      _builder.append(_formatForCodeCapital_1, "    ");
      _builder.append("{{ itemid }}\" title=\"{{ __(\'This setting is enabled. Click here to disable it.\') }}\"></i>");
      _builder.newLineIfNotEmpty();
      _builder.append("    ");
      _builder.append("<i class=\"fa fa-times{% if ");
      _builder.append(objName, "    ");
      _builder.append(".");
      String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
      _builder.append(_formatForCode_3, "    ");
      _builder.append(" %} hidden{% endif %}\" id=\"no");
      String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
      _builder.append(_formatForCodeCapital_2, "    ");
      _builder.append("{{ itemid }}\" title=\"{{ __(\'This setting is disabled. Click here to enable it.\') }}\"></i>");
      _builder.newLineIfNotEmpty();
      _builder.append("</a>");
      _builder.newLine();
      _builder.append("<noscript><div id=\"noscript");
      String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
      _builder.append(_formatForCodeCapital_3);
      _builder.append("{{ itemid }}\">");
      _builder.newLineIfNotEmpty();
      _builder.append("    ");
      _builder.append("{% if ");
      _builder.append(objName, "    ");
      _builder.append(".");
      String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
      _builder.append(_formatForCode_4, "    ");
      _builder.append(" %}");
      _builder.newLineIfNotEmpty();
      _builder.append("        ");
      _builder.append("<i class=\"fa fa-check\" title=\"{{ __(\'Yes\') }}\"></i>");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("{% else %}");
      _builder.newLine();
      _builder.append("        ");
      _builder.append("<i class=\"fa fa-times\" title=\"{{ __(\'No\') }}\"></i>");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("{% endif %}");
      _builder.newLine();
      _builder.append("</div></noscript>");
      _builder.newLine();
      _xifexpression = _builder;
    } else {
      StringConcatenation _builder_1 = new StringConcatenation();
      _builder_1.append("{% if ");
      _builder_1.append(objName);
      _builder_1.append(".");
      String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
      _builder_1.append(_formatForCode_5);
      _builder_1.append(" %}");
      _builder_1.newLineIfNotEmpty();
      _builder_1.append("    ");
      _builder_1.append("<i class=\"fa fa-check\" title=\"{{ __(\'Yes\') }}\"></i>");
      _builder_1.newLine();
      _builder_1.append("{% else %}");
      _builder_1.newLine();
      _builder_1.append("    ");
      _builder_1.append("<i class=\"fa fa-times\" title=\"{{ __(\'No\') }}\"></i>");
      _builder_1.newLine();
      _builder_1.append("{% endif %}");
      _builder_1.newLine();
      _xifexpression = _builder_1;
    }
    return _xifexpression;
  }
  
  protected CharSequence _displayField(final IntegerField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(" }}");
    {
      boolean _isPercentage = it.isPercentage();
      if (_isPercentage) {
        _builder.append("%");
      }
    }
    return _builder;
  }
  
  protected CharSequence _displayField(final DecimalField it, final String objName, final String page) {
    CharSequence _xifexpression = null;
    boolean _isPercentage = it.isPercentage();
    if (_isPercentage) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("{{ (");
      _builder.append(objName);
      _builder.append(".");
      String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
      _builder.append(_formatForCode);
      _builder.append(" * 100)|localizednumber }}%");
      _xifexpression = _builder;
    } else {
      StringConcatenation _builder_1 = new StringConcatenation();
      _builder_1.append("{{ ");
      _builder_1.append(objName);
      _builder_1.append(".");
      String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
      _builder_1.append(_formatForCode_1);
      _builder_1.append("|localized");
      {
        boolean _isCurrency = it.isCurrency();
        if (_isCurrency) {
          _builder_1.append("currency(\'EUR\')");
        } else {
          _builder_1.append("number");
        }
      }
      _builder_1.append(" }}");
      _xifexpression = _builder_1;
    }
    return _xifexpression;
  }
  
  protected CharSequence _displayField(final FloatField it, final String objName, final String page) {
    CharSequence _xifexpression = null;
    boolean _isPercentage = it.isPercentage();
    if (_isPercentage) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("{{ (");
      _builder.append(objName);
      _builder.append(".");
      String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
      _builder.append(_formatForCode);
      _builder.append(" * 100)|localizednumber }}%");
      _xifexpression = _builder;
    } else {
      StringConcatenation _builder_1 = new StringConcatenation();
      _builder_1.append("{{ ");
      _builder_1.append(objName);
      _builder_1.append(".");
      String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
      _builder_1.append(_formatForCode_1);
      _builder_1.append("|localized");
      {
        boolean _isCurrency = it.isCurrency();
        if (_isCurrency) {
          _builder_1.append("currency(\'EUR\')");
        } else {
          _builder_1.append("number");
        }
      }
      _builder_1.append(" }}");
      _xifexpression = _builder_1;
    }
    return _xifexpression;
  }
  
  protected CharSequence _displayField(final UserField it, final String objName, final String page) {
    CharSequence _xblockexpression = null;
    {
      String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
      final String realName = ((objName + ".") + _formatForCode);
      CharSequence _xifexpression = null;
      if ((Objects.equal(page, "viewcsv") || Objects.equal(page, "viewxml"))) {
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isMandatory = it.isMandatory();
          boolean _not = (!_isMandatory);
          if (_not) {
            _builder.append("{% if ");
            _builder.append(realName);
            _builder.append("|default and ");
            _builder.append(realName);
            _builder.append(".getUid() > 0 %}");
          }
        }
        _builder.append("{{ ");
        _builder.append(realName);
        _builder.append(".getUname() }}");
        {
          boolean _isMandatory_1 = it.isMandatory();
          boolean _not_1 = (!_isMandatory_1);
          if (_not_1) {
            _builder.append("{% endif %}");
          }
        }
        _xifexpression = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        {
          boolean _isMandatory_2 = it.isMandatory();
          boolean _not_2 = (!_isMandatory_2);
          if (_not_2) {
            _builder_1.append("{% if ");
            _builder_1.append(realName);
            _builder_1.append("|default and ");
            _builder_1.append(realName);
            _builder_1.append(".getUid() > 0 %}");
            _builder_1.newLineIfNotEmpty();
          }
        }
        {
          boolean _equals = Objects.equal(page, "display");
          if (_equals) {
            _builder_1.append("{% if not isQuickView %}");
            _builder_1.newLine();
          }
        }
        _builder_1.append("    ");
        _builder_1.append("{{ ");
        _builder_1.append(realName, "    ");
        _builder_1.append(".getUid()|profileLinkByUserId() }}{% if currentUser.loggedIn %}{% set sendMessageUrl = ");
        _builder_1.append(realName, "    ");
        _builder_1.append(".getUid()|messageSendLink(urlOnly=true) %}{% if sendMessageUrl != \'#\' %}<a href=\"{{ sendMessageUrl }}\" title=\"{{ __f(\'Send private message to %userName%\', { \'%userName%\': ");
        _builder_1.append(realName, "    ");
        _builder_1.append(".getUname() }) }}\"><i class=\"fa fa-envelope-o\"></i></a>{% endif %}{% endif %}");
        _builder_1.newLineIfNotEmpty();
        _builder_1.append("    ");
        _builder_1.append("<span class=\"avatar\">{{ ");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getEntity().getApplication()));
        _builder_1.append(_formatForDB, "    ");
        _builder_1.append("_userAvatar(");
        _builder_1.append(realName, "    ");
        _builder_1.append(".getUid(), rating=\'g\') }}</span>");
        _builder_1.newLineIfNotEmpty();
        {
          boolean _equals_1 = Objects.equal(page, "display");
          if (_equals_1) {
            _builder_1.append("{% else %}");
            _builder_1.newLine();
            _builder_1.append("    ");
            _builder_1.append("{{ ");
            _builder_1.append(realName, "    ");
            _builder_1.append(".getUname() }}");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("{% endif %}");
            _builder_1.newLine();
          }
        }
        {
          boolean _isMandatory_3 = it.isMandatory();
          boolean _not_3 = (!_isMandatory_3);
          if (_not_3) {
            _builder_1.append("{% else %}&nbsp;{% endif %}");
            _builder_1.newLine();
          }
        }
        _xifexpression = _builder_1;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  protected CharSequence _displayField(final StringField it, final String objName, final String page) {
    CharSequence _xifexpression = null;
    boolean _isPassword = it.isPassword();
    boolean _not = (!_isPassword);
    if (_not) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("{{ ");
      _builder.append(objName);
      _builder.append(".");
      String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
      _builder.append(_formatForCode);
      {
        boolean _isCountry = it.isCountry();
        if (_isCountry) {
          _builder.append("|");
          String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getEntity().getApplication()));
          _builder.append(_formatForDB);
          _builder.append("_countryName");
        } else {
          if ((it.isLanguage() || it.isLocale())) {
            _builder.append("|languageName");
          }
        }
      }
      _builder.append(" }}");
      _xifexpression = _builder;
    }
    return _xifexpression;
  }
  
  protected CharSequence _displayField(final TextField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("|safeHtml");
    {
      boolean _equals = Objects.equal(page, "view");
      if (_equals) {
        _builder.append("|truncate(50)");
      }
    }
    _builder.append(" }}");
    return _builder;
  }
  
  protected CharSequence _displayField(final EmailField it, final String objName, final String page) {
    CharSequence _xblockexpression = null;
    {
      String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
      final String realName = ((objName + ".") + _formatForCode);
      CharSequence _xifexpression = null;
      if ((Objects.equal(page, "viewcsv") || Objects.equal(page, "viewxml"))) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("{{ ");
        _builder.append(realName);
        _builder.append(" }}");
        _xifexpression = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        {
          boolean _isMandatory = it.isMandatory();
          boolean _not = (!_isMandatory);
          if (_not) {
            _builder_1.append("{% if ");
            _builder_1.append(realName);
            _builder_1.append(" is not empty %}");
            _builder_1.newLineIfNotEmpty();
          }
        }
        {
          boolean _equals = Objects.equal(page, "display");
          if (_equals) {
            _builder_1.append("{% if not isQuickView %}");
            _builder_1.newLine();
          }
        }
        _builder_1.append("<a href=\"mailto:{{ ");
        _builder_1.append(realName);
        _builder_1.append("|protectMail }}\" title=\"{{ __(\'Send an email\') }}\" class=\"fa fa-envelope\"></a>");
        _builder_1.newLineIfNotEmpty();
        {
          boolean _equals_1 = Objects.equal(page, "display");
          if (_equals_1) {
            _builder_1.append("{% else %}");
            _builder_1.newLine();
            _builder_1.append("    ");
            _builder_1.append("{{ ");
            _builder_1.append(realName, "    ");
            _builder_1.append("|protectMail }}");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("{% endif %}");
            _builder_1.newLine();
          }
        }
        {
          boolean _isMandatory_1 = it.isMandatory();
          boolean _not_1 = (!_isMandatory_1);
          if (_not_1) {
            _builder_1.append("{% else %}&nbsp;{% endif %}");
            _builder_1.newLine();
          }
        }
        _xifexpression = _builder_1;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  protected CharSequence _displayField(final UrlField it, final String objName, final String page) {
    CharSequence _xblockexpression = null;
    {
      String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
      final String realName = ((objName + ".") + _formatForCode);
      CharSequence _xifexpression = null;
      if ((Objects.equal(page, "viewcsv") || Objects.equal(page, "viewxml"))) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("{{ ");
        _builder.append(realName);
        _builder.append(" }}");
        _xifexpression = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        {
          boolean _isMandatory = it.isMandatory();
          boolean _not = (!_isMandatory);
          if (_not) {
            _builder_1.append("{% if ");
            _builder_1.append(realName);
            _builder_1.append(" is not empty %}");
            _builder_1.newLineIfNotEmpty();
          }
        }
        {
          boolean _equals = Objects.equal(page, "display");
          if (_equals) {
            _builder_1.append("{% if not isQuickView %}");
            _builder_1.newLine();
          }
        }
        _builder_1.append("<a href=\"{{ ");
        _builder_1.append(realName);
        _builder_1.append(" }}\" title=\"{{ __(\'Visit this page\') }}\" class=\"fa fa-external-link-square\"></a>");
        _builder_1.newLineIfNotEmpty();
        {
          boolean _equals_1 = Objects.equal(page, "display");
          if (_equals_1) {
            _builder_1.append("{% else %}");
            _builder_1.newLine();
            _builder_1.append("    ");
            _builder_1.append("{{ ");
            _builder_1.append(realName, "    ");
            _builder_1.append(" }}");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("{% endif %}");
            _builder_1.newLine();
          }
        }
        {
          boolean _isMandatory_1 = it.isMandatory();
          boolean _not_1 = (!_isMandatory_1);
          if (_not_1) {
            _builder_1.append("{% else %}&nbsp;{% endif %}");
            _builder_1.newLine();
          }
        }
        _xifexpression = _builder_1;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  protected CharSequence _displayField(final UploadField it, final String objName, final String page) {
    CharSequence _xblockexpression = null;
    {
      final String appNameSmall = this._formattingExtensions.formatForDB(this._utils.appName(it.getEntity().getApplication()));
      String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
      final String realName = ((objName + ".") + _formatForCode);
      CharSequence _xifexpression = null;
      boolean _equals = Objects.equal(page, "viewcsv");
      if (_equals) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("{{ ");
        _builder.append(realName);
        _builder.append(" }}");
        _xifexpression = _builder;
      } else {
        CharSequence _xifexpression_1 = null;
        boolean _equals_1 = Objects.equal(page, "viewxml");
        if (_equals_1) {
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append("{% if ");
          _builder_1.append(realName);
          _builder_1.append(" is not empty and ");
          _builder_1.append(realName);
          _builder_1.append("Meta|default %} extension=\"{{ ");
          _builder_1.append(realName);
          _builder_1.append("Meta.extension }}\" size=\"{{ ");
          _builder_1.append(realName);
          _builder_1.append("Meta.size }}\" isImage=\"{% if ");
          _builder_1.append(realName);
          _builder_1.append("Meta.isImage %}true{% else %}false{% endif %}\"{% if ");
          _builder_1.append(realName);
          _builder_1.append("Meta.isImage %} width=\"{{ ");
          _builder_1.append(realName);
          _builder_1.append("Meta.width }}\" height=\"{{ ");
          _builder_1.append(realName);
          _builder_1.append("Meta.height }}\" format=\"{{ ");
          _builder_1.append(realName);
          _builder_1.append("Meta.format }}\"{% endif %}{% endif %}>{{ ");
          _builder_1.append(realName);
          _builder_1.append(" }}");
          _xifexpression_1 = _builder_1;
        } else {
          StringConcatenation _builder_2 = new StringConcatenation();
          {
            boolean _isMandatory = it.isMandatory();
            boolean _not = (!_isMandatory);
            if (_not) {
              _builder_2.append("{% if ");
              _builder_2.append(realName);
              _builder_2.append(" is not empty and ");
              _builder_2.append(realName);
              _builder_2.append("Meta|default %}");
              _builder_2.newLineIfNotEmpty();
              _builder_2.append("            ");
            } else {
              _builder_2.append("{% if ");
              _builder_2.append(realName);
              _builder_2.append("Meta|default %}");
              _builder_2.newLineIfNotEmpty();
            }
          }
          _builder_2.append("<a href=\"{{ ");
          _builder_2.append(realName);
          _builder_2.append("Url }}\" title=\"{{ ");
          _builder_2.append(objName);
          _builder_2.append(".getTitleFromDisplayPattern()|e(\'html_attr\') }}\"{% if ");
          _builder_2.append(realName);
          _builder_2.append("Meta.isImage %} class=\"image-link\"{% endif %}>");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("{% if ");
          _builder_2.append(realName);
          _builder_2.append("Meta.isImage %}");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("    ");
          _builder_2.append("{% set thumbOptions = attribute(thumbRuntimeOptions, \'");
          String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getEntity().getName());
          _builder_2.append(_formatForCode_1, "    ");
          String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
          _builder_2.append(_formatForCodeCapital, "    ");
          _builder_2.append("\') %}");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("    ");
          _builder_2.append("<img src=\"{{ ");
          _builder_2.append(realName, "    ");
          _builder_2.append(".getPathname()|imagine_filter(\'zkroot\', thumbOptions) }}\" alt=\"{{ ");
          _builder_2.append(objName, "    ");
          _builder_2.append(".getTitleFromDisplayPattern()|e(\'html_attr\') }}\" width=\"{{ thumbOptions.thumbnail.size[0] }}\" height=\"{{ thumbOptions.thumbnail.size[1] }}\" class=\"img-thumbnail\" />");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("{% else %}");
          _builder_2.newLine();
          _builder_2.append("    ");
          _builder_2.append("{{ __(\'Download\') }} ({{ ");
          _builder_2.append(realName, "    ");
          _builder_2.append("Meta.size|");
          _builder_2.append(appNameSmall, "    ");
          _builder_2.append("_fileSize(");
          _builder_2.append(realName, "    ");
          _builder_2.append(".getPathname(), false, false) }})");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("{% endif %}");
          _builder_2.newLine();
          _builder_2.append("</a>");
          _builder_2.newLine();
          {
            boolean _isMandatory_1 = it.isMandatory();
            boolean _not_1 = (!_isMandatory_1);
            if (_not_1) {
              _builder_2.append("{% else %}&nbsp;{% endif %}");
              _builder_2.newLine();
              _builder_2.append("            ");
            } else {
              _builder_2.append("{% endif %}");
              _builder_2.newLineIfNotEmpty();
            }
          }
          _xifexpression_1 = _builder_2;
        }
        _xifexpression = _xifexpression_1;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  protected CharSequence _displayField(final ListField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("|");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getEntity().getApplication()));
    _builder.append(_formatForDB);
    _builder.append("_listEntry(\'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getEntity().getName());
    _builder.append(_formatForCode_1);
    _builder.append("\', \'");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2);
    _builder.append("\') }}");
    return _builder;
  }
  
  protected CharSequence _displayField(final ArrayField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% if ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(" is iterable and ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append("|length > 0 %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% for entry in ");
    _builder.append(objName, "    ");
    _builder.append(".");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, "    ");
    _builder.append(" %}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<li>{{ entry }}</li>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  protected CharSequence _displayField(final DateField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("|localizeddate(\'medium\', \'none\') }}");
    return _builder;
  }
  
  protected CharSequence _displayField(final DatetimeField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("|localizeddate(\'medium\', \'short\') }}");
    return _builder;
  }
  
  protected CharSequence _displayField(final TimeField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    _builder.append(objName);
    _builder.append(".");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("|localizeddate(\'none\', \'short\') }}");
    return _builder;
  }
  
  public CharSequence displayField(final EntityField it, final String objName, final String page) {
    if (it instanceof EmailField) {
      return _displayField((EmailField)it, objName, page);
    } else if (it instanceof IntegerField) {
      return _displayField((IntegerField)it, objName, page);
    } else if (it instanceof ListField) {
      return _displayField((ListField)it, objName, page);
    } else if (it instanceof StringField) {
      return _displayField((StringField)it, objName, page);
    } else if (it instanceof TextField) {
      return _displayField((TextField)it, objName, page);
    } else if (it instanceof UploadField) {
      return _displayField((UploadField)it, objName, page);
    } else if (it instanceof UrlField) {
      return _displayField((UrlField)it, objName, page);
    } else if (it instanceof UserField) {
      return _displayField((UserField)it, objName, page);
    } else if (it instanceof ArrayField) {
      return _displayField((ArrayField)it, objName, page);
    } else if (it instanceof DateField) {
      return _displayField((DateField)it, objName, page);
    } else if (it instanceof DatetimeField) {
      return _displayField((DatetimeField)it, objName, page);
    } else if (it instanceof DecimalField) {
      return _displayField((DecimalField)it, objName, page);
    } else if (it instanceof FloatField) {
      return _displayField((FloatField)it, objName, page);
    } else if (it instanceof TimeField) {
      return _displayField((TimeField)it, objName, page);
    } else if (it instanceof BooleanField) {
      return _displayField((BooleanField)it, objName, page);
    } else if (it != null) {
      return _displayField(it, objName, page);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, objName, page).toString());
    }
  }
}
