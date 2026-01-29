package org.zikula.modulestudio.generator.cartridges.symfony.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityLockType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
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

    def generateTrait(Application it, IMostFileSystemAccess fsa) {
        if (!hasEntitiesWithUserFields) {
            return
        }
        val filePath = 'src/Repository/UserDeletionTrait.php'
        fsa.generateFile(filePath, traitFile)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'InvalidArgumentException',
            'Psr\\Log\\LoggerInterface',
            'Symfony\\Component\\Security\\Core\\User\\UserInterface'
        ])
        if (!entitiesWithPessimisticWriteLock.empty) {
            imports.add('Doctrine\\DBAL\\LockMode')
            for (entity : entitiesWithPessimisticWriteLock) {
                imports.add(appNamespace + '\\Entity\\' + entity.name.formatForCodeCapital)
            }
        }
        imports
    }

    def private traitFile(Application it) '''
        namespace «appNamespace»\Repository;

        «collectBaseImports.print»

        /**
         * User deletion trait.
         */
        trait UserDeletionTrait
        {
            «traitImpl»
        }
    '''

    def private traitImpl(Application it) '''
        «updateUserField»

        «deleteByUserField»
    '''

    def private updateUserField(Application it) '''
        public function updateUserField(
            string $userFieldName,
            int $userId,
            int $newUserId,
            LoggerInterface $logger,
            UserInterface $currentUser
        ): void {
            if (empty($userFieldName) || !in_array($userFieldName, $this->getUserFieldNames(), true)) {
                throw new InvalidArgumentException('Invalid user field name received.');
            }
            if (0 === $userId || 0 === $newUserId) {
                throw new InvalidArgumentException('Invalid user identifier received.');
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->getEntityName(), 'tbl')
               ->set('tbl.' . $userFieldName, $newUserId)
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«appName»',
                'user' => $currentUser->getUserIdentifier(),
                'entityName' => $this->getEntityName(),
                'field' => $userFieldName,
                'userid' => $userId,
                'newuserid' => $newUserId,
            ];
            $logger->debug('{app}: User {user} updated {entityName} entities setting {field} from {userid} to {newuserid}.', $logArgs);
        }
    '''

    def private deleteByUserField(Application it) '''
        public function deleteByUserField(
            string $userFieldName,
            int $userId,
            LoggerInterface $logger,
            UserInterface $currentUser
        ): void {
            if (empty($userFieldName) || !in_array($userFieldName, $this->getUserFieldNames(), true)) {
                throw new InvalidArgumentException('Invalid user field name received.');
            }
            if (0 === $userId) {
                throw new InvalidArgumentException('Invalid user identifier received.');
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete($this->getEntityName(), 'tbl')
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', $userId);
            $query = $qb->getQuery();
            «initQueryAdditions»
            $query->execute();

            $logArgs = [
                'app' => '«appName»',
                'user' => $currentUser->getUserIdentifier(),
                'entityName' => $this->getEntityName(),
                'field' => $userFieldName,
                'userid' => $userId,
            ];
            $logger->debug('{app}: User {user} deleted {entityName} entities with {field} having set to user id {userid}.', $logArgs);
        }
    '''

    def private initQueryAdditions(Application it) '''
        «IF !entitiesWithPessimisticWriteLock.empty»
            if (in_array($this->getEntityName(), ['«entitiesWithPessimisticWriteLock.map[name.formatForCodeCapital + '::class'].join('\', \'')»'], true)) {
                $query->setLockMode(LockMode::«EntityLockType.PESSIMISTIC_WRITE.lockTypeAsConstant»);
            }
        «ENDIF»
    '''

    def private getEntitiesWithPessimisticWriteLock(Application it) {
        entities.filter[hasPessimisticWriteLock]
    }
}