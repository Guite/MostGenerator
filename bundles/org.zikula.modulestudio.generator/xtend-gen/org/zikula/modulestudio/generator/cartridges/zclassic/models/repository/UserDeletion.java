package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository;

import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.UserField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class UserDeletion {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        CharSequence _userDeletionStandardFields = this.userDeletionStandardFields(it);
        _builder.append(_userDeletionStandardFields);
        _builder.newLineIfNotEmpty();
        {
          boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
          if (_hasUserFieldsEntity) {
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _hasUserFieldsEntity_1 = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity_1) {
        CharSequence _userDeletionUserFields = this.userDeletionUserFields(it);
        _builder.append(_userDeletionUserFields);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence userDeletionStandardFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateCreator = this.updateCreator(it);
    _builder.append(_updateCreator);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _updateLastEditor = this.updateLastEditor(it);
    _builder.append(_updateLastEditor);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _deleteByCreator = this.deleteByCreator(it);
    _builder.append(_deleteByCreator);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _deleteByLastEditor = this.deleteByLastEditor(it);
    _builder.append(_deleteByLastEditor);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence userDeletionUserFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateUserField = this.updateUserField(it);
    _builder.append(_updateUserField);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _deleteByUserField = this.deleteByUserField(it);
    _builder.append(_deleteByUserField);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence updateCreator(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Updates the creator of all objects created by a certain user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $userId         The userid of the creator to be replaced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $newUserId      The new userid of the creator as replacement");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param LoggerInterface     $logger         Logger service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param CurrentUserApi");
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("     ");
      }
    }
    _builder.append(" $currentUserApi CurrentUserApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function updateCreator($userId, $newUserId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApi");
    {
      Boolean _targets_1 = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $currentUserApi)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check id parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($userId == 0 || !is_numeric($userId)");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("|| $newUserId == 0 || !is_numeric($newUserId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException($translator->__(\'Invalid user identifier received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->update(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "    ");
    _builder.append("\', \'tbl\')");
    _builder.newLineIfNotEmpty();
    _builder.append("       ");
    _builder.append("->set(\'tbl.createdBy\', $newUserId)");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->where(\'tbl.createdBy = :creator\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'creator\', $userId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    {
      boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
      if (_hasPessimisticWriteLock) {
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
        _builder.append(_lockTypeAsConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("\', \'user\' => $currentUserApi->get(\'uname\'), \'entities\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', \'userid\' => $userId];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logger->debug(\'{app}: User {user} updated {entities} created by user id {userid}.\', $logArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence updateLastEditor(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Updates the last editor of all objects updated by a certain user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $userId         The userid of the last editor to be replaced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $newUserId      The new userid of the last editor as replacement");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param LoggerInterface     $logger         Logger service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param CurrentUserApi");
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("     ");
      }
    }
    _builder.append(" $currentUserApi CurrentUserApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function updateLastEditor($userId, $newUserId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApi");
    {
      Boolean _targets_1 = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $currentUserApi)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check id parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($userId == 0 || !is_numeric($userId)");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("|| $newUserId == 0 || !is_numeric($newUserId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException($translator->__(\'Invalid user identifier received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->update(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "    ");
    _builder.append("\', \'tbl\')");
    _builder.newLineIfNotEmpty();
    _builder.append("       ");
    _builder.append("->set(\'tbl.updatedBy\', $newUserId)");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->where(\'tbl.updatedBy = :editor\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'editor\', $userId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    {
      boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
      if (_hasPessimisticWriteLock) {
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
        _builder.append(_lockTypeAsConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("\', \'user\' => $currentUserApi->get(\'uname\'), \'entities\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', \'userid\' => $userId];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logger->debug(\'{app}: User {user} updated {entities} edited by user id {userid}.\', $logArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence deleteByCreator(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Deletes all objects created by a certain user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $userId         The userid of the creator to be removed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param LoggerInterface     $logger         Logger service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param CurrentUserApi");
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("     ");
      }
    }
    _builder.append(" $currentUserApi CurrentUserApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function deleteByCreator($userId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApi");
    {
      Boolean _targets_1 = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $currentUserApi)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check id parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($userId == 0 || !is_numeric($userId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException($translator->__(\'Invalid user identifier received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->delete(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "    ");
    _builder.append("\', \'tbl\')");
    _builder.newLineIfNotEmpty();
    _builder.append("       ");
    _builder.append("->where(\'tbl.createdBy = :creator\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'creator\', $userId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _initDeleteQueryAdditions = this.initDeleteQueryAdditions(it);
    _builder.append(_initDeleteQueryAdditions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("\', \'user\' => $currentUserApi->get(\'uname\'), \'entities\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', \'userid\' => $userId];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logger->debug(\'{app}: User {user} deleted {entities} created by user id {userid}.\', $logArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence deleteByLastEditor(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Deletes all objects updated by a certain user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $userId         The userid of the last editor to be removed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param LoggerInterface     $logger         Logger service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param CurrentUserApi");
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("     ");
      }
    }
    _builder.append(" $currentUserApi CurrentUserApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function deleteByLastEditor($userId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApi");
    {
      Boolean _targets_1 = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $currentUserApi)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check id parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($userId == 0 || !is_numeric($userId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException($translator->__(\'Invalid user identifier received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->delete(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "    ");
    _builder.append("\', \'tbl\')");
    _builder.newLineIfNotEmpty();
    _builder.append("       ");
    _builder.append("->where(\'tbl.updatedBy = :editor\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'editor\', $userId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _initDeleteQueryAdditions = this.initDeleteQueryAdditions(it);
    _builder.append(_initDeleteQueryAdditions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("\', \'user\' => $currentUserApi->get(\'uname\'), \'entities\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', \'userid\' => $userId];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logger->debug(\'{app}: User {user} deleted {entities} edited by user id {userid}.\', $logArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence updateUserField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Updates a user field value of all objects affected by a certain user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string              $fieldName      The name of the user field");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $userId         The userid to be replaced");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $newUserId      The new userid as replacement");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param LoggerInterface     $logger         Logger service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param CurrentUserApi");
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("     ");
      }
    }
    _builder.append(" $currentUserApi CurrentUserApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function updateUserField($userFieldName, $userId, $newUserId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApi");
    {
      Boolean _targets_1 = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $currentUserApi)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check field parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($userFieldName) || !in_array($userFieldName, [");
    {
      Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
      boolean _hasElements = false;
      for(final UserField field : _userFieldsEntity) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "    ");
        }
        _builder.append("\'");
        String _formatForCode = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\'");
      }
    }
    _builder.append("])) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException($translator->__(\'Invalid user field name received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check id parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($userId == 0 || !is_numeric($userId)");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("|| $newUserId == 0 || !is_numeric($newUserId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException($translator->__(\'Invalid user identifier received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->update(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "    ");
    _builder.append("\', \'tbl\')");
    _builder.newLineIfNotEmpty();
    _builder.append("       ");
    _builder.append("->set(\'tbl.\' . $userFieldName, $newUserId)");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->where(\'tbl.\' . $userFieldName . \' = :user\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'user\', $userId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    {
      boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
      if (_hasPessimisticWriteLock) {
        _builder.append("    ");
        _builder.append("$query->setLockMode(LockMode::");
        String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
        _builder.append(_lockTypeAsConstant, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("\', \'user\' => $currentUserApi->get(\'uname\'), \'entities\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', \'field\' => $userFieldName, \'userid\' => $userId, \'newuserid\' => $newUserId];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logger->debug(\'{app}: User {user} updated {entities} setting {field} from {userid} to {newuserid}.\', $logArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence deleteByUserField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Deletes all objects updated by a certain user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string              $fieldName      The name of the user field");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer             $userId         The userid to be removed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param TranslatorInterface $translator     Translator service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param LoggerInterface     $logger         Logger service instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param CurrentUserApi");
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("     ");
      }
    }
    _builder.append(" $currentUserApi CurrentUserApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws InvalidArgumentException Thrown if invalid parameters are received");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function deleteByUserField($userFieldName, $userId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApi");
    {
      Boolean _targets_1 = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $currentUserApi)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check field parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($userFieldName) || !in_array($userFieldName, [");
    {
      Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
      boolean _hasElements = false;
      for(final UserField field : _userFieldsEntity) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "    ");
        }
        _builder.append("\'");
        String _formatForCode = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\'");
      }
    }
    _builder.append("])) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException($translator->__(\'Invalid user field name received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check id parameter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($userId == 0 || !is_numeric($userId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new InvalidArgumentException($translator->__(\'Invalid user identifier received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->getEntityManager()->createQueryBuilder();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb->delete(\'");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, "    ");
    _builder.append("\', \'tbl\')");
    _builder.newLineIfNotEmpty();
    _builder.append("       ");
    _builder.append("->where(\'tbl.\' . $userFieldName . \' = :user\')");
    _builder.newLine();
    _builder.append("       ");
    _builder.append("->setParameter(\'user\', $userId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $qb->getQuery();");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _initDeleteQueryAdditions = this.initDeleteQueryAdditions(it);
    _builder.append(_initDeleteQueryAdditions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query->execute();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("\', \'user\' => $currentUserApi->get(\'uname\'), \'entities\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\', \'field\' => $userFieldName, \'userid\' => $userId];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logger->debug(\'{app}: User {user} deleted {entities} with {field} having set to user id {userid}.\', $logArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initDeleteQueryAdditions(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
      if (_hasPessimisticWriteLock) {
        _builder.newLine();
        _builder.append("$query->setLockMode(LockMode::");
        String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
        _builder.append(_lockTypeAsConstant);
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
}
