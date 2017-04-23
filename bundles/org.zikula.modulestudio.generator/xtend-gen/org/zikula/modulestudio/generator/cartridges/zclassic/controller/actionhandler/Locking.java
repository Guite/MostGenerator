package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Locking {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence memberVars() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Whether the PageLock extension is used for this entity type or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var boolean");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $hasPageLockSupport = false;");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence addPageLock(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (true === $this->hasPageLockSupport && $this->kernel->isBundle(\'ZikulaPageLockModule\') && null !== $this->lockingApi) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// try to guarantee that only one person at a time can be editing this entity");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$lockName = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\' . $this->objectTypeCapital . $this->createCompositeIdentifier();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->lockingApi->addLock($lockName, $this->getRedirectUrl(null));");
    _builder.newLine();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("    ");
        _builder.append("// reload entity as the addLock call above has triggered the preUpdate event");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->entityFactory->getObjectManager()->refresh($entity);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence releasePageLock(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (true === $this->hasPageLockSupport && $this->templateParameters[\'mode\'] == \'edit\' && $this->kernel->isBundle(\'ZikulaPageLockModule\') && null !== $this->lockingApi) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$lockName = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\' . $this->objectTypeCapital . $this->createCompositeIdentifier();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->lockingApi->releaseLock($lockName);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence imports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((this._modelExtensions.hasOptimisticLock(it) || this._modelExtensions.hasPessimisticReadLock(it)) || this._modelExtensions.hasPessimisticWriteLock(it))) {
        _builder.append("use Doctrine\\DBAL\\LockMode;");
        _builder.newLine();
        {
          boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
          if (_hasOptimisticLock) {
            _builder.append("use Doctrine\\ORM\\OptimisticLockException;");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
  
  public CharSequence memberVarAssignments(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$this->hasPageLockSupport = ");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(this._modelExtensions.hasPageLockSupport(it)));
    _builder.append(_displayBool);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence setVersion(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
      if (_hasOptimisticLock) {
        _builder.newLine();
        _builder.append("if ($this->templateParameters[\'mode\'] == \'edit\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->request->getSession()->set(\'");
        String _appName = this._utils.appName(it.getApplication());
        _builder.append(_appName, "    ");
        _builder.append("EntityVersion\', $this->entityRef->get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._modelExtensions.getVersionField(it).getName());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("());");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public CharSequence getVersion(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((this._modelExtensions.hasOptimisticLock(it) || this._modelExtensions.hasPessimisticWriteLock(it))) {
        _builder.newLine();
        _builder.append("$applyLock = $this->templateParameters[\'mode\'] != \'create\' && $action != \'delete\';");
        _builder.newLine();
        {
          boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
          if (_hasOptimisticLock) {
            _builder.append("$expectedVersion = $this->request->getSession()->get(\'");
            String _appName = this._utils.appName(it.getApplication());
            _builder.append(_appName);
            _builder.append("EntityVersion\', 1);");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  public CharSequence applyLock(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((this._modelExtensions.hasOptimisticLock(it) || this._modelExtensions.hasPessimisticWriteLock(it))) {
        _builder.append("if ($applyLock) {");
        _builder.newLine();
        {
          boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
          if (_hasOptimisticLock) {
            _builder.append("    ");
            _builder.append("// assert version");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$this->entityFactory->getObjectManager()->lock($entity, LockMode::");
            String _lockTypeAsConstant = this._modelExtensions.lockTypeAsConstant(it.getLockType());
            _builder.append(_lockTypeAsConstant, "    ");
            _builder.append(", $expectedVersion);");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
            if (_hasPessimisticWriteLock) {
              _builder.append("    ");
              _builder.append("$this->entityFactory->getObjectManager()->lock($entity, LockMode::");
              String _lockTypeAsConstant_1 = this._modelExtensions.lockTypeAsConstant(it.getLockType());
              _builder.append(_lockTypeAsConstant_1, "    ");
              _builder.append(");");
              _builder.newLineIfNotEmpty();
            }
          }
        }
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public CharSequence catchException(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
      if (_hasOptimisticLock) {
        _builder.append("} catch(OptimisticLockException $e) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$flashBag->add(\'error\', $this->__(\'Sorry, but someone else has already changed this record. Please apply the changes again!\'));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$logArgs = [\'app\' => \'");
        String _appName = this._utils.appName(it.getApplication());
        _builder.append(_appName, "    ");
        _builder.append("\', \'user\' => $this->currentUserApi->get(\'uname\'), \'entity\' => \'");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\', \'id\' => $entity->createCompositeIdentifier()];");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$this->logger->error(\'{app}: User {user} tried to edit the {entity} with id {id}, but failed as someone else has already changed it.\', $logArgs);");
        _builder.newLine();
      }
    }
    return _builder;
  }
}
