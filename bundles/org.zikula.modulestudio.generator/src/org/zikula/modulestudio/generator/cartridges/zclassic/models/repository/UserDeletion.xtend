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
         «IF !application.targets('3.0')»
         *
         * @param int $userId
         * @param int $newUserId
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         «ENDIF»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateCreator(
            «IF application.targets('3.0')»int «ENDIF»$userId,
            «IF application.targets('3.0')»int «ENDIF»$newUserId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        )«IF application.targets('3.0')»: void«ENDIF» {
            «IF application.targets('3.0')»
                if (0 === $userId || 0 === $newUserId) {
                    throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
                }
            «ELSE»
                if (
                    0 === $userId || !is_numeric($userId)
                    || 0 === $newUserId || !is_numeric($newUserId)
                ) {
                    throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
                }
            «ENDIF»

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->mainEntityClass, 'tbl')
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
                'userid' => $userId
            ];
            $logger->debug('{app}: User {user} updated {entities} created by user id {userid}.', $logArgs);
        }
    '''

    def private updateLastEditor(Entity it) '''
        /**
         * Updates the last editor of all objects updated by a certain user.
         «IF !application.targets('3.0')»
         *
         * @param int $userId
         * @param int $newUserId
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         «ENDIF»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateLastEditor(
            «IF application.targets('3.0')»int «ENDIF»$userId,
            «IF application.targets('3.0')»int «ENDIF»$newUserId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        )«IF application.targets('3.0')»: void«ENDIF» {
            «IF application.targets('3.0')»
                if (0 === $userId || 0 === $newUserId) {
                    throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
                }
            «ELSE»
                if (
                    0 === $userId || !is_numeric($userId)
                    || 0 === $newUserId || !is_numeric($newUserId)
                ) {
                    throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
                }
            «ENDIF»

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->mainEntityClass, 'tbl')
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
                'userid' => $userId
            ];
            $logger->debug('{app}: User {user} updated {entities} edited by user id {userid}.', $logArgs);
        }
    '''

    def private deleteByCreator(Entity it) '''
        /**
         * Deletes all objects created by a certain user.
         «IF !application.targets('3.0')»
         *
         * @param int $userId
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         «ENDIF»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByCreator(
            «IF application.targets('3.0')»int «ENDIF»$userId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        )«IF application.targets('3.0')»: void«ENDIF» {
            if (0 === $userId«IF !application.targets('3.0')» || !is_numeric($userId)«ENDIF») {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->mainEntityClass, 'tbl')
               ->where('tbl.createdBy = :creator')
               ->setParameter('creator', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUserApi->get('uname'),
                'entities' => '«nameMultiple.formatForDisplay»',
                'userid' => $userId
            ];
            $logger->debug('{app}: User {user} deleted {entities} created by user id {userid}.', $logArgs);
        }
    '''

    def private deleteByLastEditor(Entity it) '''
        /**
         * Deletes all objects updated by a certain user.
         «IF !application.targets('3.0')»
         *
         * @param int $userId
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         «ENDIF»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByLastEditor(
            «IF application.targets('3.0')»int «ENDIF»$userId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        )«IF application.targets('3.0')»: void«ENDIF» {
            if (0 === $userId«IF !application.targets('3.0')» || !is_numeric($userId)«ENDIF») {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->mainEntityClass, 'tbl')
               ->where('tbl.updatedBy = :editor')
               ->setParameter('editor', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUserApi->get('uname'),
                'entities' => '«nameMultiple.formatForDisplay»',
                'userid' => $userId
            ];
            $logger->debug('{app}: User {user} deleted {entities} edited by user id {userid}.', $logArgs);
        }
    '''

    def private updateUserField(Entity it) '''
        /**
         * Updates a user field value of all objects affected by a certain user.
         «IF !application.targets('3.0')»
         *
         * @param string $fieldName The name of the user field
         * @param int $userId The userid to be replaced
         * @param int $newUserId The new userid as replacement
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         «ENDIF»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function updateUserField(
            «IF application.targets('3.0')»string «ENDIF»$userFieldName,
            «IF application.targets('3.0')»int «ENDIF»$userId,
            «IF application.targets('3.0')»int «ENDIF»$newUserId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        )«IF application.targets('3.0')»: void«ENDIF» {
            if (empty($userFieldName) || !in_array($userFieldName, [«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], true)) {
                throw new InvalidArgumentException($translator->__('Invalid user field name received.'));
            }
            «IF application.targets('3.0')»
                if (0 === $userId || 0 === $newUserId) {
                    throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
                }
            «ELSE»
                if (
                    0 === $userId || !is_numeric($userId)
                    || 0 === $newUserId || !is_numeric($newUserId)
                ) {
                    throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
                }
            «ENDIF»

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->mainEntityClass, 'tbl')
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
                'newuserid' => $newUserId
            ];
            $logger->debug('{app}: User {user} updated {entities} setting {field} from {userid} to {newuserid}.', $logArgs);
        }
    '''

    def private deleteByUserField(Entity it) '''
        /**
         * Deletes all objects updated by a certain user.
         «IF !application.targets('3.0')»
         *
         * @param string $fieldName The name of the user field
         * @param int $userId The userid to be removed
         * @param TranslatorInterface $translator
         * @param LoggerInterface $logger
         * @param CurrentUserApiInterface $currentUserApi
         *
         * @return void
         «ENDIF»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function deleteByUserField(
            «IF application.targets('3.0')»string «ENDIF»$userFieldName,
            «IF application.targets('3.0')»int «ENDIF»$userId,
            TranslatorInterface $translator,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        )«IF application.targets('3.0')»: void«ENDIF» {
            if (empty($userFieldName) || !in_array($userFieldName, [«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], true)) {
                throw new InvalidArgumentException($translator->__('Invalid user field name received.'));
            }
            if (0 === $userId«IF !application.targets('3.0')» || !is_numeric($userId)«ENDIF») {
                throw new InvalidArgumentException($translator->__('Invalid user identifier received.'));
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->mainEntityClass, 'tbl')
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
                'userid' => $userId
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