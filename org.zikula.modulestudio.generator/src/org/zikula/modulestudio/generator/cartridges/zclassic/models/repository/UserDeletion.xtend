package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserDeletion {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it) '''
        «IF standardFields»
            «userDeletionStandardFields»
            «IF hasUserFieldsEntity»

            «ENDIF»
        «ENDIF»
        «IF hasUserFieldsEntity»
            «userDeletionUserFields»
        «ENDIF»
    '''

    def private userDeletionStandardFields(Entity it) '''
        «updateCreator»

        «updateLastEditor»

        «deleteByCreator»

        «deleteByLastEditor»
    '''

    def private userDeletionUserFields(Entity it) '''
        «updateUserField»

        «deleteByUserField»
    '''

    def private updateCreator(Entity it) '''
        /**
         * Updates the creator of all objects created by a certain user.
         *
         * @param integer $userId    The userid of the creator to be replaced.
         * @param integer $newUserId The new userid of the creator as replacement.
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateCreator($userId, $newUserId)
        {
            «IF application.targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain($this->name);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
            «ENDIF»

            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                «IF application.targets('1.3.x')»
                    throw new \InvalidArgumentException(__('Invalid user identifier received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException($serviceManager->get('translator')->__('Invalid user identifier received.'));
                «ENDIF»
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«entityClassName('', false)»', 'tbl')
               ->set('tbl.createdUserId', $newUserId)
               ->where('tbl.createdUserId = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»
            $query->execute();
            «IF !application.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->debug('{app}: User {user} updated {entities} created by user id {userid}.', ['app' => '«application.appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId]);
            «ENDIF»
        }
    '''

    def private updateLastEditor(Entity it) '''
        /**
         * Updates the last editor of all objects updated by a certain user.
         *
         * @param integer $userId    The userid of the last editor to be replaced.
         * @param integer $newUserId The new userid of the last editor as replacement.
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateLastEditor($userId, $newUserId)
        {
            «IF application.targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain($this->name);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
            «ENDIF»

            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                «IF application.targets('1.3.x')»
                    throw new \InvalidArgumentException(__('Invalid user identifier received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException($serviceManager->get('translator')->__('Invalid user identifier received.'));
                «ENDIF»
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«entityClassName('', false)»', 'tbl')
               ->set('tbl.updatedUserId', $newUserId)
               ->where('tbl.updatedUserId = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»
            $query->execute();
            «IF !application.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->debug('{app}: User {user} updated {entities} edited by user id {userid}.', ['app' => '«application.appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId]);
            «ENDIF»
        }
    '''

    def private deleteByCreator(Entity it) '''
        /**
         * Deletes all objects created by a certain user.
         *
         * @param integer $userId The userid of the creator to be removed.
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByCreator($userId)
        {
            «IF application.targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain($this->name);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
            «ENDIF»

            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                «IF application.targets('1.3.x')»
                    throw new \InvalidArgumentException(__('Invalid user identifier received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException($serviceManager->get('translator')->__('Invalid user identifier received.'));
                «ENDIF»
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«entityClassName('', false)»', 'tbl')
               ->where('tbl.createdUserId = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «initDeleteQueryAdditions»

            $query->execute();
            «IF !application.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->debug('{app}: User {user} deleted {entities} created by user id {userid}.', ['app' => '«application.appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId]);
            «ENDIF»
        }
    '''

    def private deleteByLastEditor(Entity it) '''
        /**
         * Deletes all objects updated by a certain user.
         *
         * @param integer $userId The userid of the last editor to be removed.
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByLastEditor($userId)
        {
            «IF application.targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain($this->name);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
            «ENDIF»

            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                «IF application.targets('1.3.x')»
                    throw new \InvalidArgumentException(__('Invalid user identifier received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException($serviceManager->get('translator')->__('Invalid user identifier received.'));
                «ENDIF»
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«entityClassName('', false)»', 'tbl')
               ->where('tbl.updatedUserId = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «initDeleteQueryAdditions»

            $query->execute();
            «IF !application.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->debug('{app}: User {user} deleted {entities} edited by user id {userid}.', ['app' => '«application.appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId]);
            «ENDIF»
        }
    '''

    def private updateUserField(Entity it) '''
         /**
         * Updates a user field value of all objects affected by a certain user.
         *
         * @param string  $fieldName The name of the user field.
         * @param integer $userId    The userid to be replaced.
         * @param integer $newUserId The new userid as replacement.
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateUserField($userFieldName, $userId, $newUserId)
        {
            «IF application.targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain($this->name);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
            «ENDIF»

            // check field parameter
            if (empty($userFieldName) || !in_array($userFieldName, «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»«IF application.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                «IF application.targets('1.3.x')»
                    throw new \InvalidArgumentException(__('Invalid user field name received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException($serviceManager->get('translator')->__('Invalid user field name received.'));
                «ENDIF»
            }
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                «IF application.targets('1.3.x')»
                    throw new \InvalidArgumentException(__('Invalid user identifier received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException($serviceManager->get('translator')->__('Invalid user identifier received.'));
                «ENDIF»
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«entityClassName('', false)»', 'tbl')
               ->set('tbl.' . $userFieldName, $newUserId)
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»
            $query->execute();
            «IF !application.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->debug('{app}: User {user} updated {entities} setting {field} from {userid} to {newuserid}.', ['app' => '«application.appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'field' => $userFieldName, 'userid' => $userId, 'newuserid' => $newUserId]);
            «ENDIF»
        }
    '''

    def private deleteByUserField(Entity it) '''
        /**
         * Deletes all objects updated by a certain user.
         *
         * @param string  $fieldName The name of the user field.
         * @param integer $userId    The userid to be removed.
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByUserField($userFieldName, $userId)
        {
            «IF application.targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain($this->name);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
            «ENDIF»

            // check field parameter
            if (empty($userFieldName) || !in_array($userFieldName, «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»«IF application.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                «IF application.targets('1.3.x')»
                    throw new \InvalidArgumentException(__('Invalid user field name received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException($serviceManager->get('translator')->__('Invalid user field name received.'));
                «ENDIF»
            }
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                «IF application.targets('1.3.x')»
                    throw new \InvalidArgumentException(__('Invalid user identifier received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException($serviceManager->get('translator')->__('Invalid user identifier received.'));
                «ENDIF»
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«entityClassName('', false)»', 'tbl')
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «initDeleteQueryAdditions»

            $query->execute();
            «IF !application.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->debug('{app}: User {user} deleted {entities} edited by user id {userid}.', ['app' => '«application.appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId]);
            «ENDIF»
        }
    '''

    def private initDeleteQueryAdditions(Entity it) '''
        «IF softDeleteable»

            // set the softdeletable query hint
            $query->setHint(
                Query::HINT_CUSTOM_OUTPUT_WALKER,
                'Gedmo\\SoftDeleteable\\Query\\TreeWalker\\SoftDeleteableWalker'
            );
        «ENDIF»
        «IF hasPessimisticWriteLock»

            $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
        «ENDIF»
    '''
}