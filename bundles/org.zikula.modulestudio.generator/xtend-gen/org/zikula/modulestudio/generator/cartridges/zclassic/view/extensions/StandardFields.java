package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class StandardFields {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Helper/");
    final String templateExtension = ".html.twig";
    String fileName = "";
    if ((this._controllerExtensions.hasViewActions(it) || this._controllerExtensions.hasDisplayActions(it))) {
      fileName = ("includeStandardFieldsDisplay" + templateExtension);
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
      boolean _not = (!_shouldBeSkipped);
      if (_not) {
        boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
        if (_shouldBeMarked) {
          fileName = ("includeStandardFieldsDisplay.generated" + templateExtension);
        }
        fsa.generateFile((templatePath + fileName), this.standardFieldsViewImpl(it));
      }
    }
    boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
    if (_hasEditActions) {
      fileName = ("includeStandardFieldsEdit" + templateExtension);
      boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
      boolean _not_1 = (!_shouldBeSkipped_1);
      if (_not_1) {
        boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
        if (_shouldBeMarked_1) {
          fileName = ("includeStandardFieldsEdit.generated" + templateExtension);
        }
        fsa.generateFile((templatePath + fileName), this.standardFieldsEditImpl(it));
      }
    }
  }
  
  private CharSequence standardFieldsViewImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: reusable display of standard fields #}");
    _builder.newLine();
    _builder.append("{% if (obj.createdBy|default and obj.createdBy.getUid() > 0) or (obj.updatedBy|default and obj.updatedBy.getUid() > 0) %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabStandardFields\" aria-labelledby=\"standardFieldsTab\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h3>{{ __(\'Creation and update\') }}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3 class=\"standard-fields\">{{ __(\'Creation and update\') }}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _viewBody = this.viewBody(it);
    _builder.append(_viewBody, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence viewBody(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<dl class=\"propertylist\">");
    _builder.newLine();
    _builder.append("{% if obj.createdBy|default and obj.createdBy.getUid() > 0 %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dt>{{ __(\'Creation\') }}</dt>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set profileLink = obj.createdBy.getUid()|profileLinkByUserId() %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dd class=\"avatar\">{{ ");
    String _lowerCase = this._utils.appName(it).toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("_userAvatar(uid=obj.createdBy.getUid(), rating=\'g\') }}</dd>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dd>{{ __f(\'Created by %user on %date\', {\'%user\': profileLink, \'%date\': obj.createdDate|localizeddate(\'medium\', \'short\')})|raw }}{% if currentUser.loggedIn %}{% set sendMessageUrl = obj.createdBy.getUid()|messageSendLink(urlOnly=true) %}{% if sendMessageUrl != \'#\' %}<a href=\"{{ sendMessageUrl }}\" title=\"{{ __f(\'Send private message to %userName%\', { \'%userName%\': obj.createdBy.getUname() }) }}\"><i class=\"fa fa-envelope-o\"></i></a>{% endif %}{% endif %}</dd>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% if obj.updatedBy|default and obj.updatedBy.getUid() > 0 %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dt>{{ __(\'Last update\') }}</dt>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set profileLink = obj.updatedBy.getUid()|profileLinkByUserId() %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dd class=\"avatar\">{{ ");
    String _lowerCase_1 = this._utils.appName(it).toLowerCase();
    _builder.append(_lowerCase_1, "    ");
    _builder.append("_userAvatar(uid=obj.updatedBy.getUid(), rating=\'g\') }}</dd>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dd>{{ __f(\'Updated by %user on %date\', {\'%user\': profileLink, \'%date\': obj.updatedDate|localizeddate(\'medium\', \'short\')})|raw }}{% if currentUser.loggedIn %}{% set sendMessageUrl = obj.updatedBy.getUid()|messageSendLink(urlOnly=true) %}{% if sendMessageUrl != \'#\' %}<a href=\"{{ sendMessageUrl }}\" title=\"{{ __f(\'Send private message to %userName%\', { \'%userName%\': obj.updatedBy.getUname() }) }}\"><i class=\"fa fa-envelope-o\"></i></a>{% endif %}{% endif %}</dd>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("</dl>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence standardFieldsEditImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: reusable editing of standard fields #}");
    _builder.newLine();
    _builder.append("{% if (obj.createdBy|default and obj.createdBy.getUid() > 0) or (obj.updatedBy|default and obj.updatedBy.getUid() > 0) %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabStandardFields\" aria-labelledby=\"standardFieldsTab\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h3>{{ __(\'Creation and update\') }}</h3>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset class=\"standardfields\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<legend>{{ __(\'Creation and update\') }}</legend>");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _editBody = this.editBody(it);
    _builder.append(_editBody, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editBody(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("{% if obj.createdBy|default and obj.createdBy.getUid() > 0 %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<li>{{ __f(\'Created by %user\', {\'%user\': obj.createdBy.getUname()}) }}</li>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<li>{{ __f(\'Created on %date\', {\'%date\': obj.createdDate|localizeddate(\'medium\', \'short\')}) }}</li>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% if obj.updatedBy|default and obj.updatedBy.getUid() > 0 %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<li>{{ __f(\'Updated by %user\', {\'%user\': obj.updatedBy.getUname()}) }}</li>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<li>{{ __f(\'Updated on %date\', {\'%date\': obj.updatedDate|localizeddate(\'medium\', \'short\')}) }}</li>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("</ul>");
    _builder.newLine();
    return _builder;
  }
}
