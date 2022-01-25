package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserDeletion {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generateInterface(Entity it) '''
        «IF standardFields»

            /**
             * Updates the creator of all objects created by a certain user.
             *
             * @throws InvalidArgumentException Thrown if invalid parameters are received
             */
            public function updateCreator(
                int $userId,
                int $newUserId,
                TranslatorInterface $translator,
                LoggerInterface $logger,
                CurrentUserApiInterface $currentUserApi
            ): void;

            /**
             * Updates the last editor of all objects updated by a certain user.
             *
             * @throws InvalidArgumentException Thrown if invalid parameters are received
             */
            public function updateLastEditor(
                int $userId,
                int $newUserId,
                TranslatorInterface $translator,
                LoggerInterface $logger,
                CurrentUserApiInterface $currentUserApi
            ): void;

            /**
             * Deletes all objects created by a certain user.
             *
             * @throws InvalidArgumentException Thrown if invalid parameters are received
             */
            public function deleteByCreator(
                int $userId,
                TranslatorInterface $translator,
                LoggerInterface $logger,
                CurrentUserApiInterface $currentUserApi
            ): void;

            /**
             * Deletes all objects updated by a certain user.
             *
             * @throws InvalidArgumentException Thrown if invalid parameters are received
             */
            public function deleteByLastEditor(
                int $userId,
                TranslatorInterface $translator,
                LoggerInterface $logger,
                CurrentUserApiInterface $currentUserApi
            ): void;
        «ENDIF»
        «IF hasUserFieldsEntity»

            /**
             * Updates a user field value of all objects affected by a certain user.
             *
             * @throws InvalidArgumentException Thrown if invalid parameters are received
             */
            public function updateUserField(
                string $userFieldName,
                int $userId,
                int $newUserId,
                TranslatorInterface $translator,
                LoggerInterface $logger,
                CurrentUserApiInterface $currentUserApi
            ): void;

            /**
             * Deletes all objects referencing a certain user in a specific field.
             *
             * @throws InvalidArgumentException Thrown if invalid parameters are received
             */
            public function deleteByUserField(
                string $userFieldName,
                int $userId,
                TranslatorInterface $translator,
                LoggerInterface $logger,
                CurrentUserApiInterface $currentUserApi
            ): void;
        «ENDIF»
    '''

    def generate(Entity it) '''
        «IF standardFields»
            «userDeletionStandardFields»
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
        public function updateCreator(
            int $userId,
            int $newUserId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        ): void {
            if (0 === $userId || 0 === $newUserId) {
                throw new InvalidArgumentException($translator->trans('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->_entityName, 'tbl')
               ->set('tbl.createdBy', $newUserId)
               ->where('tbl.createdBy = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUserApi->get('uname'),
                'entities' => '«nameMultiple.formatForDisplay»',
                'userid' => $userId,
            ];
            $logger->debug('{app}: User {user} updated {entities} created by user id {userid}.', $logArgs);
        }
    '''

    def private updateLastEditor(Entity it) '''
        public function updateLastEditor(
            int $userId,
            int $newUserId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        ): void {
            if (0 === $userId || 0 === $newUserId) {
                throw new InvalidArgumentException($translator->trans('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->_entityName, 'tbl')
               ->set('tbl.updatedBy', $newUserId)
               ->where('tbl.updatedBy = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUserApi->get('uname'),
                'entities' => '«nameMultiple.formatForDisplay»',
                'userid' => $userId,
            ];
            $logger->debug('{app}: User {user} updated {entities} edited by user id {userid}.', $logArgs);
        }
    '''

    def private deleteByCreator(Entity it) '''
        public function deleteByCreator(
            int $userId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        ): void {
            if (0 === $userId) {
                throw new InvalidArgumentException($translator->trans('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->_entityName, 'tbl')
               ->where('tbl.createdBy = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUserApi->get('uname'),
                'entities' => '«nameMultiple.formatForDisplay»',
                'userid' => $userId,
            ];
            $logger->debug('{app}: User {user} deleted {entities} created by user id {userid}.', $logArgs);
        }
    '''

    def private deleteByLastEditor(Entity it) '''
        public function deleteByLastEditor(
            int $userId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        ): void {
            if (0 === $userId) {
                throw new InvalidArgumentException($translator->trans('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->_entityName, 'tbl')
               ->where('tbl.updatedBy = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUserApi->get('uname'),
                'entities' => '«nameMultiple.formatForDisplay»',
                'userid' => $userId,
            ];
            $logger->debug('{app}: User {user} deleted {entities} edited by user id {userid}.', $logArgs);
        }
    '''

    def private updateUserField(Entity it) '''
        public function updateUserField(
            string $userFieldName,
            int $userId,
            int $newUserId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        ): void {
            if (empty($userFieldName) || !in_array($userFieldName, [«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], true)) {
                throw new InvalidArgumentException($translator->trans('Invalid user field name received.'));
            }
            if (0 === $userId || 0 === $newUserId) {
                throw new InvalidArgumentException($translator->trans('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->_entityName, 'tbl')
               ->set('tbl.' . $userFieldName, $newUserId)
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUserApi->get('uname'),
                'entities' => '«nameMultiple.formatForDisplay»',
                'field' => $userFieldName,
                'userid' => $userId,
                'newuserid' => $newUserId,
            ];
            $logger->debug('{app}: User {user} updated {entities} setting {field} from {userid} to {newuserid}.', $logArgs);
        }
    '''

    def private deleteByUserField(Entity it) '''
        public function deleteByUserField(
            string $userFieldName,
            int $userId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        ): void {
            if (empty($userFieldName) || !in_array($userFieldName, [«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], true)) {
                throw new InvalidArgumentException($translator->trans('Invalid user field name received.'));
            }
            if (0 === $userId) {
                throw new InvalidArgumentException($translator->trans('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->_entityName, 'tbl')
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUserApi->get('uname'),
                'entities' => '«nameMultiple.formatForDisplay»',
                'field' => $userFieldName,
                'userid' => $userId,
            ];
            $logger->debug('{app}: User {user} deleted {entities} with {field} having set to user id {userid}.', $logArgs);
        }
    '''

    def private initQueryAdditions(Entity it) '''
         «IF hasPessimisticWriteLock»
            $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
        «ENDIF»
    '''
}