package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Locking {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def memberVars() '''
        /**
         * Whether the PageLock extension is used for this entity type or not.
         *
         * @var boolean
         */
        protected $hasPageLockSupport = false;
    '''

    def addPageLock(Application it) '''
        if (
            true === $this->hasPageLockSupport
            && null !== $this->lockingApi
            && $this->kernel->isBundle('ZikulaPageLockModule')
        ) {
            // try to guarantee that only one person at a time can be editing this entity
            $lockName = '«appName»' . $this->objectTypeCapital . $entity->getKey();
            $this->lockingApi->addLock($lockName, $this->getRedirectUrl(['commandName' => '']));
        }
    '''

    def releasePageLock(Application it) '''
        if (
            true === $this->hasPageLockSupport
            && null !== $this->lockingApi
            && 'edit' === $this->templateParameters['mode']
            && $this->kernel->isBundle('ZikulaPageLockModule')
        ) {
            $lockName = '«appName»' . $this->objectTypeCapital . $this->entityRef->getKey();
            $this->lockingApi->releaseLock($lockName);
        }
    '''

    def imports(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
            «IF hasOptimisticLock»
                use Doctrine\ORM\OptimisticLockException;
            «ENDIF»
        «ENDIF»
    '''

    def memberVarAssignments(Entity it) '''
        $this->hasPageLockSupport = «hasPageLockSupport.displayBool»;
    '''

    def setVersion(Entity it) '''
        «IF hasOptimisticLock»

            if ('edit' === $this->templateParameters['mode']) {
                $this->requestStack->getCurrentRequest()->getSession()->set(
                    '«application.appName»EntityVersion',
                    $this->entityRef->get«getVersionField.name.formatForCodeCapital»()
                );
            }
        «ENDIF»
    '''
 
    def getVersion(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticWriteLock»

            $applyLock = 'create' !== $this->templateParameters['mode'] && 'delete' !== $action;
            «IF hasOptimisticLock»
                $expectedVersion = $this->requestStack->getCurrentRequest()->getSession()->get(
                    '«application.appName»EntityVersion',
                    1
                );
            «ENDIF»
        «ENDIF»
    '''

    def applyLock(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticWriteLock»
            if ($applyLock) {
                «IF hasOptimisticLock»
                    // assert version
                    $this->entityFactory->getEntityManager()->lock($entity, LockMode::«lockType.lockTypeAsConstant», $expectedVersion);
                «ELSEIF hasPessimisticWriteLock»
                    $this->entityFactory->getEntityManager()->lock($entity, LockMode::«lockType.lockTypeAsConstant»);
                «ENDIF»
            }

        «ENDIF»
    '''

    def catchException(Entity it) '''
        «IF hasOptimisticLock»
            } catch (OptimisticLockException $exception) {
                $flashBag->add(
                    'error',
                    $this->__('Sorry, but someone else has already changed this record. Please apply the changes again!')
                );
                $logArgs = [
                    'app' => '«application.appName»',
                    'user' => $this->currentUserApi->get('uname'),
                    'entity' => '«name.formatForDisplay»',
                    'id' => $entity->getKey()
                ];
                $this->logger->error(
                    '{app}: User {user} tried to edit the {entity} with id {id},'
                        . ' but failed as someone else has already changed it.',
                    $logArgs
                );
        «ENDIF»
    '''
}
