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
        if (true === $this->hasPageLockSupport && ModUtil::available('«IF isLegacy»PageLock«ELSE»ZikulaPageLockModule«ENDIF»')) {
            // try to guarantee that only one person at a time can be editing this entity
            ModUtil::apiFunc('«IF isLegacy»PageLock«ELSE»ZikulaPageLockModule«ENDIF»', 'user', 'pageLock', «IF isLegacy»array(«ELSE»[«ENDIF»
                                 'lockName' => «IF isLegacy»$this->name«ELSE»'«appName»'«ENDIF» . $this->objectTypeCapital . $this->createCompositeIdentifier(),
                                 'returnUrl' => $this->getRedirectUrl(null)
            «IF isLegacy»)«ELSE»]«ENDIF»);
        }
    '''

    def releasePageLock(Application it) '''
        if (true === $this->hasPageLockSupport && «IF isLegacy»$this->mode«ELSE»$this->templateParameters['mode']«ENDIF» == 'edit' && ModUtil::available('«IF isLegacy»PageLock«ELSE»ZikulaPageLockModule«ENDIF»')) {
            ModUtil::apiFunc('«IF isLegacy»PageLock«ELSE»ZikulaPageLockModule«ENDIF»', 'user', 'releaseLock', «IF isLegacy»array(«ELSE»[«ENDIF»
                                 'lockName' => «IF isLegacy»$this->name«ELSE»'«appName»'«ENDIF» . $this->objectTypeCapital . $this->createCompositeIdentifier()
            «IF isLegacy»)«ELSE»]«ENDIF»);
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

            «IF application.isLegacy»
                if ($this->mode == 'edit') {
                    SessionUtil::setVar($this->name . 'EntityVersion', $entity->get«getVersionField.name.formatForCodeCapital»());
                }
            «ELSE»
                if ($this->templateParameters['mode'] == 'edit') {
                    $this->request->getSession()->set('«application.appName»EntityVersion', $entity->get«getVersionField.name.formatForCodeCapital»());
                }
            «ENDIF»
        «ENDIF»
    '''
 
    def getVersion(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticWriteLock»

            $applyLock = $this->«IF application.isLegacy»mode«ELSE»templateParameters['mode']«ENDIF» != 'create' && $action != 'delete';
            «IF hasOptimisticLock»
                «IF application.isLegacy»
                    $expectedVersion = SessionUtil::getVar($this->name . 'EntityVersion', 1);
                «ELSE»
                    $expectedVersion = $this->request->getSession()->get('«application.appName»EntityVersion', 1);
                «ENDIF»
            «ENDIF»
        «ENDIF»
    '''

    def applyLock(Entity it) '''
        «IF hasOptimisticLock || hasPessimisticWriteLock»
            if ($applyLock) {
                // assert version
                «IF hasOptimisticLock»
                    $this->entityManager->lock($entity, LockMode::OPTIMISTIC, $expectedVersion);
                «ELSEIF hasPessimisticWriteLock»
                    $this->entityManager->lock($entity, LockMode::«lockType.lockTypeAsConstant»);
                «ENDIF»
            }

        «ENDIF»
    '''

    def catchException(Entity it) '''
        «IF hasOptimisticLock»
            } catch(OptimisticLockException $e) {
                «IF application.isLegacy»
                    LogUtil::registerError($this->__('Sorry, but someone else has already changed this record. Please apply the changes again!'));
                «ELSE»
                    $flashBag->add(\Zikula_Session::MESSAGE_ERROR, $this->__('Sorry, but someone else has already changed this record. Please apply the changes again!'));
                    $logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed as someone else has already changed it.', ['app' => '«application.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()]);
                «ENDIF»
        «ENDIF»
    '''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}