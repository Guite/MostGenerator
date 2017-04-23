package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.AccountDeletionHandler;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.UserField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.CommonExample;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class User {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private CommonExample commonExample = new CommonExample();
  
  public CharSequence generate(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((isBase).booleanValue() && (this._modelBehaviourExtensions.hasStandardFieldEntities(it) || this._modelExtensions.hasUserFields(it)))) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var TranslatorInterface");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $translator;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var ");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital, " ");
        _builder.append("Factory");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $entityFactory;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var CurrentUserApi");
        {
          Boolean _targets = this._utils.targets(it, "1.5");
          if ((_targets).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $currentUserApi;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var LoggerInterface");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $logger;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* UserListener constructor.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param TranslatorInterface $translator     Translator service instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param ");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1, " ");
        _builder.append("Factory $entityFactory ");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_2, " ");
        _builder.append("Factory service instance");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @param CurrentUserApi");
        {
          Boolean _targets_1 = this._utils.targets(it, "1.5");
          if ((_targets_1).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("     ");
          }
        }
        _builder.append(" $currentUserApi CurrentUserApi service instance");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @param LoggerInterface     $logger         Logger service instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return void");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function __construct(");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("TranslatorInterface $translator,");
        _builder.newLine();
        _builder.append("    ");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_3, "    ");
        _builder.append("Factory $entityFactory,");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("CurrentUserApi");
        {
          Boolean _targets_2 = this._utils.targets(it, "1.5");
          if ((_targets_2).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append(" $currentUserApi,");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("LoggerInterface $logger");
        _builder.newLine();
        _builder.append(") {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->translator = $translator;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->entityFactory = $entityFactory;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->currentUserApi = $currentUserApi;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->logger = $logger;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Makes our handlers known to the event system.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public static function getSubscribedEvents()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("return [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("UserEvents::CREATE_ACCOUNT => [\'create\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("UserEvents::UPDATE_ACCOUNT => [\'update\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("UserEvents::DELETE_ACCOUNT => [\'delete\', 5]");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return parent::getSubscribedEvents();");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
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
        _builder.append("* @param GenericEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function create(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::create($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
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
        _builder.append("* @param GenericEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function update(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::update($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_1 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `user.account.delete` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after the deletion of a user account. Subject is $userId.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param GenericEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function delete(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::delete($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_2 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_2, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        {
          if ((this._modelBehaviourExtensions.hasStandardFieldEntities(it) || this._modelExtensions.hasUserFields(it))) {
            _builder.append("    ");
            _builder.append("$userId = $event->getSubject();");
            _builder.newLine();
            _builder.newLine();
            _builder.append("    ");
            {
              Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
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
      if ((it.isStandardFields() || this._modelExtensions.hasUserFieldsEntity(it))) {
        _builder.newLine();
        _builder.append("$repo = $this->entityFactory->getRepository(\'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        {
          boolean _isStandardFields = it.isStandardFields();
          if (_isStandardFields) {
            {
              AccountDeletionHandler _onAccountDeletionCreator = it.getOnAccountDeletionCreator();
              boolean _notEquals = (!Objects.equal(_onAccountDeletionCreator, AccountDeletionHandler.DELETE));
              if (_notEquals) {
                _builder.append("// set creator to ");
                String _adhAsConstant = this._modelBehaviourExtensions.adhAsConstant(it.getOnAccountDeletionCreator());
                _builder.append(_adhAsConstant);
                _builder.append(" (");
                Object _adhUid = this._modelBehaviourExtensions.adhUid(it.getApplication(), it.getOnAccountDeletionCreator());
                _builder.append(_adhUid);
                _builder.append(") for all ");
                String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
                _builder.append(_formatForDisplay);
                _builder.append(" created by this user");
                _builder.newLineIfNotEmpty();
                _builder.append("$repo->updateCreator($userId, ");
                Object _adhUid_1 = this._modelBehaviourExtensions.adhUid(it.getApplication(), it.getOnAccountDeletionCreator());
                _builder.append(_adhUid_1);
                _builder.append(", $this->translator, $this->logger, $this->currentUserApi);");
                _builder.newLineIfNotEmpty();
              } else {
                _builder.append("// delete all ");
                String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
                _builder.append(_formatForDisplay_1);
                _builder.append(" created by this user");
                _builder.newLineIfNotEmpty();
                _builder.append("$repo->deleteByCreator($userId, $this->translator, $this->logger, $this->currentUserApi);");
                _builder.newLine();
              }
            }
            _builder.newLine();
            {
              AccountDeletionHandler _onAccountDeletionLastEditor = it.getOnAccountDeletionLastEditor();
              boolean _notEquals_1 = (!Objects.equal(_onAccountDeletionLastEditor, AccountDeletionHandler.DELETE));
              if (_notEquals_1) {
                _builder.append("// set last editor to ");
                String _adhAsConstant_1 = this._modelBehaviourExtensions.adhAsConstant(it.getOnAccountDeletionLastEditor());
                _builder.append(_adhAsConstant_1);
                _builder.append(" (");
                Object _adhUid_2 = this._modelBehaviourExtensions.adhUid(it.getApplication(), it.getOnAccountDeletionLastEditor());
                _builder.append(_adhUid_2);
                _builder.append(") for all ");
                String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
                _builder.append(_formatForDisplay_2);
                _builder.append(" updated by this user");
                _builder.newLineIfNotEmpty();
                _builder.append("$repo->updateLastEditor($userId, ");
                Object _adhUid_3 = this._modelBehaviourExtensions.adhUid(it.getApplication(), it.getOnAccountDeletionLastEditor());
                _builder.append(_adhUid_3);
                _builder.append(", $this->translator, $this->logger, $this->currentUserApi);");
                _builder.newLineIfNotEmpty();
              } else {
                _builder.append("// delete all ");
                String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
                _builder.append(_formatForDisplay_3);
                _builder.append(" recently updated by this user");
                _builder.newLineIfNotEmpty();
                _builder.append("$repo->deleteByLastEditor($userId, $this->translator, $this->logger, $this->currentUserApi);");
                _builder.newLine();
              }
            }
          }
        }
        {
          boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
          if (_hasUserFieldsEntity) {
            {
              Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
              for(final UserField userField : _userFieldsEntity) {
                CharSequence _onAccountDeletionHandler = this.onAccountDeletionHandler(userField);
                _builder.append(_onAccountDeletionHandler);
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        _builder.newLine();
        _builder.append("$logArgs = [\'app\' => \'");
        String _appName = this._utils.appName(it.getApplication());
        _builder.append(_appName);
        _builder.append("\', \'user\' => $this->currentUserApi->get(\'uname\'), \'entities\' => \'");
        String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay_4);
        _builder.append("\'];");
        _builder.newLineIfNotEmpty();
        _builder.append("$this->logger->notice(\'{app}: User {user} has been deleted, so we deleted/updated corresponding {entities}, too.\', $logArgs);");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence onAccountDeletionHandler(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      DataObject _entity = it.getEntity();
      if ((_entity instanceof Entity)) {
        {
          AccountDeletionHandler _onAccountDeletion = it.getOnAccountDeletion();
          boolean _notEquals = (!Objects.equal(_onAccountDeletion, AccountDeletionHandler.DELETE));
          if (_notEquals) {
            _builder.append("// set last editor to ");
            String _adhAsConstant = this._modelBehaviourExtensions.adhAsConstant(it.getOnAccountDeletion());
            _builder.append(_adhAsConstant);
            _builder.append(" (");
            Object _adhUid = this._modelBehaviourExtensions.adhUid(it.getEntity().getApplication(), it.getOnAccountDeletion());
            _builder.append(_adhUid);
            _builder.append(") for all ");
            DataObject _entity_1 = it.getEntity();
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(((Entity) _entity_1).getNameMultiple());
            _builder.append(_formatForDisplay);
            _builder.append(" affected by this user");
            _builder.newLineIfNotEmpty();
            _builder.append("$repo->updateUserField(\'");
            String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode);
            _builder.append("\', $userId, ");
            Object _adhUid_1 = this._modelBehaviourExtensions.adhUid(it.getEntity().getApplication(), it.getOnAccountDeletion());
            _builder.append(_adhUid_1);
            _builder.append(", $this->translator, $this->logger, $this->currentUserApi);");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("// delete all ");
            DataObject _entity_2 = it.getEntity();
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(((Entity) _entity_2).getNameMultiple());
            _builder.append(_formatForDisplay_1);
            _builder.append(" affected by this user");
            _builder.newLineIfNotEmpty();
            _builder.append("$repo->deleteByUserField(\'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_1);
            _builder.append("\', $userId, $this->translator, $this->logger, $this->currentUserApi);");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
}
