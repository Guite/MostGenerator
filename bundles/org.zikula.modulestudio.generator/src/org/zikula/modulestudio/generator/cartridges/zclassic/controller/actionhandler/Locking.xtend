package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Locking {

    extension FormattingExtensions = new FormattingExtensions
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
        if (true === $this->hasPageLockSupport && $this->kernel->isBundle('ZikulaPageLockModule') && null !== $this->lockingApi) {
            // try to guarantee that only one person at a time can be editing this entity
            $lockName = '«appName»' . $this->objectTypeCapital . $this->createCompositeIdentifier();
            $this->lockingApi->addLock($lockName, $this->getRedirectUrl(null));
            «IF hasUploads»
                // reload entity as the addLock call above has triggered the preUpdate event
                $this->entityFactory->getObjectManager()->refresh($entity);
            «ENDIF»
        }
    '''

    def releasePageLock(Application it) '''
        if (true === $this->hasPageLockSupport && $this->templateParameters['mode'] == 'edit' && $this->kernel->isBundle('ZikulaPageLockModule') && null !== $this->lockingApi) {
            $lockName = '«appName»' . $this->objectTypeCapital . $this->createCompositeIdentifier();
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

            if ($this->templateParameters['mode'] == 'edit') {
                $this->request->getSession()->set('«application.appName»EntityVersion', $this->entityRef->get«getVersionField.name.formatForCodeCapital»());
            }
        «ENDIF»
    '''
 
    def getVersion(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticWriteLock»

            $applyLock = $this->templateParameters['mode'] != 'create' && $action != 'delete';
            «IF hasOptimisticLock»
                $expectedVersion = $this->request->getSession()->get('«application.appName»EntityVersion', 1);
            «ENDIF»
        «ENDIF»
    '''

    def applyLock(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticWriteLock»
            if ($applyLock) {
                «IF hasOptimisticLock»
                    // assert version
                    $this->entityManager->lock($entity, LockMode::«lockType.lockTypeAsConstant», $expectedVersion);
                «ELSEIF hasPessimisticWriteLock»
                    $this->entityManager->lock($entity, LockMode::«lockType.lockTypeAsConstant»);
                «ENDIF»
            }

        «ENDIF»
    '''

    def catchException(Entity it) '''
        «IF hasOptimisticLock»
            } catch(OptimisticLockException $e) {
                $flashBag->add('error', $this->__('Sorry, but someone else has already changed this record. Please apply the changes again!'));
                $logArgs = ['app' => '«application.appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()];
                $this->logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed as someone else has already changed it.', $logArgs);
        «ENDIF»
    '''
}
