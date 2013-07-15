package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class User {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public CharSequence generate(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `user.gettheme` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Called during UserUtil::getTheme() and is used to filter the results.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives arg[\'type\'] with the type of result to be filtered");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* and the $themeName in the $event->data which can be modified.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Must $event->stop");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Propagation");
      }
    }
    _builder.append("() if handler performs filter.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function getTheme(");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not_1 = (!(isBase).booleanValue());
      if (_not_1) {
        _builder.append("    ");
        _builder.append("parent::getTheme($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `user.account.create` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs after a user account is created. All handlers are notified.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* It does not apply to creation of a pending registration.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The full user record created is available as the subject.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The subject of the event is set to the user record that was created.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function create(");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not_2 = (!(isBase).booleanValue());
      if (_not_2) {
        _builder.append("    ");
        _builder.append("parent::create($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `user.account.update` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs after a user is updated. All handlers are notified.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The full updated user record is available as the subject.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The subject of the event is set to the user record, with the updated values.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      if (_targets_5) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function update(");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      if (_targets_6) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not_3 = (!(isBase).booleanValue());
      if (_not_3) {
        _builder.append("    ");
        _builder.append("parent::update($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `user.account.delete` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs after a user is deleted from the system.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* All handlers are notified.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The full user record deleted is available as the subject.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The subject of the event is set to the user record that is being deleted.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      if (_targets_7) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function delete(");
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      if (_targets_8) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not_4 = (!(isBase).booleanValue());
      if (_not_4) {
        _builder.append("    ");
        _builder.append("parent::delete($event);");
        _builder.newLine();
      } else {
        {
          boolean _or = false;
          boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
          if (_hasStandardFieldEntities) {
            _or = true;
          } else {
            boolean _hasUserFields = this._modelExtensions.hasUserFields(it);
            _or = (_hasStandardFieldEntities || _hasUserFields);
          }
          if (_or) {
            _builder.append("    ");
            _builder.append("ModUtil::initOOModule(\'");
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "    ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$userRecord = $event->getSubject();");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$uid = $userRecord[\'uid\'];");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$serviceManager = ServiceUtil::getManager();");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
            _builder.newLine();
            _builder.append("    ");
            {
              EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
              for(final Entity entity : _allEntities) {
                CharSequence _userDelete = this.userDelete(entity);
                _builder.append(_userDelete, "    ");
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence userDelete(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _or = false;
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _or = true;
      } else {
        boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
        _or = (_isStandardFields || _hasUserFieldsEntity);
      }
      if (_or) {
        _builder.newLine();
        _builder.append("$repo = $entityManager->getRepository(\'");
        String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName, "");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        {
          boolean _isStandardFields_1 = it.isStandardFields();
          if (_isStandardFields_1) {
            _builder.append("// delete all ");
            String _nameMultiple = it.getNameMultiple();
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
            _builder.append(_formatForDisplay, "");
            _builder.append(" created by this user");
            _builder.newLineIfNotEmpty();
            _builder.append("$repo->deleteCreator($uid);");
            _builder.newLine();
            _builder.append("// note you could also do: $repo->updateCreator($uid, 2);");
            _builder.newLine();
            _builder.newLine();
            _builder.append("// set last editor to admin (2) for all ");
            String _nameMultiple_1 = it.getNameMultiple();
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple_1);
            _builder.append(_formatForDisplay_1, "");
            _builder.append(" updated by this user");
            _builder.newLineIfNotEmpty();
            _builder.append("$repo->updateLastEditor($uid, 2);");
            _builder.newLine();
            _builder.append("// note you could also do: $repo->deleteLastEditor($uid);");
            _builder.newLine();
          }
        }
        {
          boolean _hasUserFieldsEntity_1 = this._modelExtensions.hasUserFieldsEntity(it);
          if (_hasUserFieldsEntity_1) {
            {
              Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
              for(final UserField userField : _userFieldsEntity) {
                _builder.append("// set ");
                String _name = userField.getName();
                String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name);
                _builder.append(_formatForDisplay_2, "");
                _builder.append(" to guest (1) for all affected ");
                String _nameMultiple_2 = it.getNameMultiple();
                String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_nameMultiple_2);
                _builder.append(_formatForDisplay_3, "");
                _builder.newLineIfNotEmpty();
                _builder.append("$repo->updateUserField(\'");
                String _name_1 = userField.getName();
                String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
                _builder.append(_formatForCode, "");
                _builder.append("\', $uid, 1);");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    return _builder;
  }
}
