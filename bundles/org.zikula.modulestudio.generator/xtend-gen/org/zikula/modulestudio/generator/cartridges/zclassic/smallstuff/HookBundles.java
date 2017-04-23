package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class HookBundles {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence setup(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    final String areaPrefix = (_formatForDB + ".");
    _builder.newLineIfNotEmpty();
    final String uiArea = (areaPrefix + "ui_hooks.");
    _builder.newLineIfNotEmpty();
    {
      final Function1<Entity, Boolean> _function = (Entity e) -> {
        boolean _isSkipHookSubscribers = e.isSkipHookSubscribers();
        return Boolean.valueOf((!_isSkipHookSubscribers));
      };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
      for(final Entity entity : _filter) {
        final String areaName = this._formattingExtensions.formatForDB(entity.getNameMultiple());
        _builder.newLineIfNotEmpty();
        _builder.append("$bundle = new SubscriberBundle(\'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName);
        _builder.append("\', \'subscriber.");
        _builder.append(uiArea);
        _builder.append(areaName);
        _builder.append("\', \'ui_hooks\', $this->__(\'");
        _builder.append(areaPrefix);
        _builder.append(" ");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(entity.getNameMultiple());
        _builder.append(_formatForDisplayCapital);
        _builder.append(" Display Hooks\'));");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          if ((this._controllerExtensions.hasViewAction(entity) || this._controllerExtensions.hasDisplayAction(entity))) {
            _builder.append("// Display hook for view/display templates.");
            _builder.newLine();
            _builder.append("$bundle->addEvent(\'display_view\', \'");
            _builder.append(uiArea);
            _builder.append(areaName);
            _builder.append(".display_view\');");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("// Display hook for create/edit forms.");
        _builder.newLine();
        _builder.append("$bundle->addEvent(\'form_edit\', \'");
        _builder.append(uiArea);
        _builder.append(areaName);
        _builder.append(".form_edit\');");
        _builder.newLineIfNotEmpty();
        {
          if ((this._controllerExtensions.hasEditAction(entity) || this._controllerExtensions.hasDeleteAction(entity))) {
            _builder.append("// Display hook for delete dialogues.");
            _builder.newLine();
            _builder.append("$bundle->addEvent(\'form_delete\', \'");
            _builder.append(uiArea);
            _builder.append(areaName);
            _builder.append(".form_delete\');");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("// Validate input from an ui create/edit form.");
        _builder.newLine();
        _builder.append("$bundle->addEvent(\'validate_edit\', \'");
        _builder.append(uiArea);
        _builder.append(areaName);
        _builder.append(".validate_edit\');");
        _builder.newLineIfNotEmpty();
        {
          if ((this._controllerExtensions.hasEditAction(entity) || this._controllerExtensions.hasDeleteAction(entity))) {
            _builder.append("// Validate input from an ui delete form.");
            _builder.newLine();
            _builder.append("$bundle->addEvent(\'validate_delete\', \'");
            _builder.append(uiArea);
            _builder.append(areaName);
            _builder.append(".validate_delete\');");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("// Perform the final update actions for a ui create/edit form.");
        _builder.newLine();
        _builder.append("$bundle->addEvent(\'process_edit\', \'");
        _builder.append(uiArea);
        _builder.append(areaName);
        _builder.append(".process_edit\');");
        _builder.newLineIfNotEmpty();
        {
          if ((this._controllerExtensions.hasEditAction(entity) || this._controllerExtensions.hasDeleteAction(entity))) {
            _builder.append("// Perform the final delete actions for a ui form.");
            _builder.newLine();
            _builder.append("$bundle->addEvent(\'process_delete\', \'");
            _builder.append(uiArea);
            _builder.append(areaName);
            _builder.append(".process_delete\');");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("$this->registerHookSubscriberBundle($bundle);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("$bundle = new SubscriberBundle(\'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1);
        _builder.append("\', \'subscriber.");
        _builder.append(areaPrefix);
        _builder.append("filter_hooks.");
        _builder.append(areaName);
        _builder.append("\', \'filter_hooks\', $this->__(\'");
        _builder.append(areaPrefix);
        _builder.append(" ");
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(entity.getNameMultiple());
        _builder.append(_formatForDisplayCapital_1);
        _builder.append(" Filter Hooks\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("// A filter applied to the given area.");
        _builder.newLine();
        _builder.append("$bundle->addEvent(\'filter\', \'");
        _builder.append(areaPrefix);
        _builder.append("filter_hooks.");
        _builder.append(areaName);
        _builder.append(".filter\');");
        _builder.newLineIfNotEmpty();
        _builder.append("$this->registerHookSubscriberBundle($bundle);");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.newLine();
    return _builder;
  }
}
