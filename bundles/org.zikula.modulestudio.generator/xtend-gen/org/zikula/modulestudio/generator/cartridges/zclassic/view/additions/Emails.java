package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Emails {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      EntityWorkflowType _workflow = it_1.getWorkflow();
      return Boolean.valueOf((!Objects.equal(_workflow, EntityWorkflowType.NONE)));
    };
    final Iterable<Entity> entitiesWithWorkflow = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    boolean _isEmpty = IterableExtensions.isEmpty(entitiesWithWorkflow);
    if (_isEmpty) {
      return;
    }
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Email/");
    final String templateExtension = ".html.twig";
    for (final Entity entity : entitiesWithWorkflow) {
      {
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
        String _plus = ("notify" + _formatForCodeCapital);
        String _plus_1 = (_plus + "Creator");
        String fileName = (_plus_1 + templateExtension);
        boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
        boolean _not = (!_shouldBeSkipped);
        if (_not) {
          boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
          if (_shouldBeMarked) {
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(entity.getName());
            String _plus_2 = ("notify" + _formatForCodeCapital_1);
            String _plus_3 = (_plus_2 + "Creator.generated");
            String _plus_4 = (_plus_3 + templateExtension);
            fileName = _plus_4;
          }
          fsa.generateFile((templatePath + fileName), this.notifyCreatorTemplate(entity));
        }
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(entity.getName());
        String _plus_5 = ("notify" + _formatForCodeCapital_2);
        String _plus_6 = (_plus_5 + "Moderator");
        String _plus_7 = (_plus_6 + templateExtension);
        fileName = _plus_7;
        boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
        boolean _not_1 = (!_shouldBeSkipped_1);
        if (_not_1) {
          boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
          if (_shouldBeMarked_1) {
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(entity.getName());
            String _plus_8 = ("notify" + _formatForCodeCapital_3);
            String _plus_9 = (_plus_8 + "Moderator.generated");
            String _plus_10 = (_plus_9 + templateExtension);
            fileName = _plus_10;
          }
          fsa.generateFile((templatePath + fileName), this.notifyModeratorTemplate(entity));
        }
      }
    }
  }
  
  private CharSequence notifyCreatorTemplate(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<p>{{ __f(\'Hello %recipient%\', { \'%recipient%\': recipient.name }) }},</p>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<p>{{ __f(\'Your ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append(" \"%entity%\" has been changed.\', { \'%entity%\': mailData.name }) }}</p>");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<p>{{ __f(\"It\'s new state is: %state%\", { \'%state%\': mailData.newState }) }}</p>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% if mailData.remarks is not empty %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p>{{ __(\'Additional remarks:\') }}<br />{{ mailData.remarks|nl2br }}</p>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% if mailData.newState != __(\'Deleted\') %}");
    _builder.newLine();
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("    ");
        _builder.append("<p>{{ __(\'Link to your ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append(":\') }} <a href=\"{{ mailData.displayUrl|e(\'html_attr\') }}\" title=\"{{ mailData.name|e(\'html_attr\') }}\">{{ mailData.displayUrl }}</a></p>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasEditAction = this._controllerExtensions.hasEditAction(it);
      if (_hasEditAction) {
        _builder.append("    ");
        _builder.append("<p>{{ __(\'Edit your ");
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_2, "    ");
        _builder.append(":\') }} <a href=\"{{ mailData.editUrl|e(\'html_attr\') }}\" title=\"{{ __(\'Edit\') }}\">{{ mailData.editUrl }}</a></p>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<p>{{ __f(\'This mail has been sent automatically by %siteName%.\', { \'%siteName%\': getModVar(\'ZConfig\', \'sitename\') }) }}</p>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence notifyModeratorTemplate(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<p>{{ __f(\'Hello %recipient%\', { \'%recipient%\': recipient.name }) }},</p>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<p>{{ __f(\'A user changed his ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append(" \"%entity%\".\', { \'%entity%\': mailData.name }) }}</p>");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<p>{{ __f(\"It\'s new state is: %state%\", { \'%state%\': mailData.newState }) }}</p>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% if mailData.remarks is not empty %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p>{{ __(\'Additional remarks:\') }}<br />{{ mailData.remarks|nl2br }}</p>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% if mailData.newState != __(\'Deleted\') %}");
    _builder.newLine();
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("    ");
        _builder.append("<p>{{ __(\'Link to the ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append(":\') }} <a href=\"{{ mailData.displayUrl|e(\'html_attr\') }}\" title=\"{{ mailData.name|e(\'html_attr\') }}\">{{ mailData.displayUrl }}</a></p>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasEditAction = this._controllerExtensions.hasEditAction(it);
      if (_hasEditAction) {
        _builder.append("    ");
        _builder.append("<p>{{ __(\'Edit the ");
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_2, "    ");
        _builder.append(":\') }} <a href=\"{{ mailData.editUrl|e(\'html_attr\') }}\" title=\"{{ __(\'Edit\') }}\">{{ mailData.editUrl }}</a></p>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<p>{{ __f(\'This mail has been sent automatically by %siteName%.\', { \'%siteName%\': getModVar(\'ZConfig\', \'sitename\') }) }}</p>");
    _builder.newLine();
    return _builder;
  }
}
