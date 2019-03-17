package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserDeletion {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
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
         * @param integer $userId
         * @param integer $newUserId
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateCreator($userId, $newUserId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApiInterface $currentUserApi)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->mainEntityClass, 'tbl')
               ->set('tbl.createdBy', $newUserId)
               ->where('tbl.createdBy = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = ['app' => '«application.appName»', 'user' => $currentUserApi->get('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId];
            $logger->debug('{app}: User {user} updated {entities} created by user id {userid}.', $logArgs);
        }
    '''

    def private updateLastEditor(Entity it) '''
        /**
         * Updates the last editor of all objects updated by a certain user.
         *
         * @param integer $userId
         * @param integer $newUserId
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateLastEditor($userId, $newUserId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApiInterface $currentUserApi)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->mainEntityClass, 'tbl')
               ->set('tbl.updatedBy', $newUserId)
               ->where('tbl.updatedBy = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = ['app' => '«application.appName»', 'user' => $currentUserApi->get('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId];
            $logger->debug('{app}: User {user} updated {entities} edited by user id {userid}.', $logArgs);
        }
    '''

    def private deleteByCreator(Entity it) '''
        /**
         * Deletes all objects created by a certain user.
         *
         * @param integer $userId
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByCreator($userId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApiInterface $currentUserApi)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->mainEntityClass, 'tbl')
               ->where('tbl.createdBy = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = ['app' => '«application.appName»', 'user' => $currentUserApi->get('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId];
            $logger->debug('{app}: User {user} deleted {entities} created by user id {userid}.', $logArgs);
        }
    '''

    def private deleteByLastEditor(Entity it) '''
        /**
         * Deletes all objects updated by a certain user.
         *
         * @param integer $userId
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByLastEditor($userId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApiInterface $currentUserApi)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->mainEntityClass, 'tbl')
               ->where('tbl.updatedBy = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = ['app' => '«application.appName»', 'user' => $currentUserApi->get('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'userid' => $userId];
            $logger->debug('{app}: User {user} deleted {entities} edited by user id {userid}.', $logArgs);
        }
    '''

    def private updateUserField(Entity it) '''
        /**
         * Updates a user field value of all objects affected by a certain user.
         *
         * @param string $fieldName The name of the user field
         * @param integer $userId The userid to be replaced
         * @param integer $newUserId The new userid as replacement
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateUserField($userFieldName, $userId, $newUserId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApiInterface $currentUserApi)
        {
            // check field parameter
            if (empty($userFieldName) || !in_array($userFieldName, [«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»])) {
                throw new InvalidArgumentException($translator->__('Invalid user field name received.'));
            }
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->mainEntityClass, 'tbl')
               ->set('tbl.' . $userFieldName, $newUserId)
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = ['app' => '«application.appName»', 'user' => $currentUserApi->get('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'field' => $userFieldName, 'userid' => $userId, 'newuserid' => $newUserId];
            $logger->debug('{app}: User {user} updated {entities} setting {field} from {userid} to {newuserid}.', $logArgs);
        }
    '''

    def private deleteByUserField(Entity it) '''
        /**
         * Deletes all objects updated by a certain user.
         *
         * @param string $fieldName The name of the user field
         * @param integer $userId The userid to be removed
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByUserField($userFieldName, $userId, TranslatorInterface $translator, LoggerInterface $logger, CurrentUserApiInterface $currentUserApi)
        {
            // check field parameter
            if (empty($userFieldName) || !in_array($userFieldName, [«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»])) {
                throw new InvalidArgumentException($translator->__('Invalid user field name received.'));
            }
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->mainEntityClass, 'tbl')
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = ['app' => '«application.appName»', 'user' => $currentUserApi->get('uname'), 'entities' => '«nameMultiple.formatForDisplay»', 'field' => $userFieldName, 'userid' => $userId];
            $logger->debug('{app}: User {user} deleted {entities} with {field} having set to user id {userid}.', $logArgs);
        }
    '''

    def private initQueryAdditions(Entity it) '''
         «IF hasPessimisticWriteLock»
            $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
        «ENDIF»
    '''
}