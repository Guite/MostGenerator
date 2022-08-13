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

    def imports(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
            «IF hasOptimisticLock»
                use Doctrine\ORM\OptimisticLockException;
            «ENDIF»
        «ENDIF»
    '''

    def setVersion(Entity it) '''
        «IF hasOptimisticLock»

            if ('edit' === $this->templateParameters['mode']) {
                $request = $this->requestStack->getCurrentRequest();
                if ($request->hasSession() && ($session = $request->getSession())) {
                    $session->set(
                        '«application.appName»EntityVersion',
                        $this->entityRef->get«getVersionField.name.formatForCodeCapital»()
                    );
                }
            }
        «ENDIF»
    '''
 
    def getVersion(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticWriteLock»

            $applyLock = 'create' !== $this->templateParameters['mode'] && 'delete' !== $action;
            «IF hasOptimisticLock»
                $request = $this->requestStack->getCurrentRequest();
                if ($request->hasSession() && ($session = $request->getSession())) {
                    $expectedVersion = $session->get('«application.appName»EntityVersion', 1);
                } else {
                    $expectedVersion = 1;
                }
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
                $request = $this->requestStack->getCurrentRequest();
                if ($request->hasSession() && ($session = $request->getSession())) {
                    $session->getFlashBag()->add(
                        'error',
                        'Sorry, but someone else has already changed this record. Please apply the changes again!'
                    );
                }
                $logArgs = [
                    'app' => '«application.appName»',
                    'user' => $this->currentUserApi->get('uname'),
                    'entity' => '«name.formatForDisplay»',
                    'id' => $entity->getKey(),
                ];
                $this->logger->error(
                    '{app}: User {user} tried to edit the {entity} with id {id},'
                        . ' but failed as someone else has already changed it. ' . $exception->getMessage(),
                    $logArgs
                );
        «ENDIF»
    '''
}
