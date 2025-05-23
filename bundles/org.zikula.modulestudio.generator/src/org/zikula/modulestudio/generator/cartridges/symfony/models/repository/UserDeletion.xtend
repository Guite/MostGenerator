package org.zikula.modulestudio.generator.cartridges.symfony.models.repository

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserDeletion {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generateInterface(Entity it) '''
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
                LoggerInterface $logger,
                UserInterface $currentUser
            ): void;

            /**
             * Deletes all objects referencing a certain user in a specific field.
             *
             * @throws InvalidArgumentException Thrown if invalid parameters are received
             */
            public function deleteByUserField(
                string $userFieldName,
                int $userId,
                LoggerInterface $logger,
                UserInterface $currentUser
            ): void;
        «ENDIF»
    '''

    def generate(Entity it) '''
        «IF hasUserFieldsEntity»

            «updateUserField»
    
            «deleteByUserField»
        «ENDIF»
    '''

    def private updateUserField(Entity it) '''
        public function updateUserField(
            string $userFieldName,
            int $userId,
            int $newUserId,
            LoggerInterface $logger,
            UserInterface $currentUser
        ): void {
            if (empty($userFieldName) || !in_array($userFieldName, [«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], true)) {
                throw new InvalidArgumentException('Invalid user field name received.');
            }
            if (0 === $userId || 0 === $newUserId) {
                throw new InvalidArgumentException('Invalid user identifier received.');
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
                'user' => $currentUser,
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
            LoggerInterface $logger,
            UserInterface $currentUser
        ): void {
            if (empty($userFieldName) || !in_array($userFieldName, [«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], true)) {
                throw new InvalidArgumentException('Invalid user field name received.');
            }
            if (0 === $userId) {
                throw new InvalidArgumentException('Invalid user identifier received.');
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
                'user' => $currentUser,
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