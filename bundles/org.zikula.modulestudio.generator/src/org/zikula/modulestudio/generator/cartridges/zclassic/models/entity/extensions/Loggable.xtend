package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ObjectField
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class Loggable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
         * @Gedmo\Loggable(logEntryClass=«name.formatForCodeCapital»LogEntryEntity::class)
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
        «IF entity instanceof Entity && (entity as Entity).loggable && !(it instanceof ObjectField) && !translatable»«/* if loggable and translatable are combined we add store this into a translationData array field instead */» * @Gedmo\Versioned
        «ENDIF»
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''
        /**
         * Description of currently executed action to be persisted in next log entry.
         */
        protected string $_actionDescriptionForLogEntry = '';

    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «(new FileHelper(application)).getterAndSetterMethods(it, '_actionDescriptionForLogEntry', 'string', false, '', '')»
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        'logEntry'
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) '''
        use Doctrine\ORM\Mapping as ORM;
        use Gedmo\Loggable\Entity\MappedSuperclass\«extensionBaseClass»;
        use «repositoryClass(extensionClassType)»;
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        'AbstractLogEntry'
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        'Entity extension domain class storing ' + name.formatForDisplay + ' log entries.'
    }

    /**
     * Returns the extension base class implementation.
     */
    override extensionClassBaseImplementation(Entity it) '''
        «IF primaryKey instanceof AbstractIntegerField»
            /**
             * Use integer instead of string for increased performance.
             *
             * @ORM\Column(name="object_id", type="integer")
             */
            protected «/* no type allowed because we override a parent field */»$objectId;

        «ENDIF»
        /**
         * Extended description of the executed action which produced this log entry.
         *
         * @ORM\Column(name="action_description", length=255)
         */
        protected string $actionDescription = '';
        «(new FileHelper(application)).getterAndSetterMethods(it, 'actionDescription', 'string', false, '', '')»
    '''

    /**
     * Returns the extension repository interface base implementation.
     */
    override extensionRepositoryInterfaceBaseImplementation(Entity it) '''
        public function getLogEntries($entity);

        public function getLogEntriesQuery($entity);

        public function revert($entity, $version = 1);

        public function selectDeleted(?int $limit = null): array;

        public function purgeHistory(string $revisionHandling = 'unlimited', string $limitParameter = ''): void;

        public function updateUserName(string $oldUserName, string $newUserName): void;
    '''

    /**
     * Returns the extension repository class base implementation.
     */
    override extensionRepositoryClassBaseImplementation(Entity it) '''
        /**
         * Selects all log entries for removals to determine deleted «nameMultiple.formatForDisplay».
         */
        public function selectDeleted(?int $limit = null): array
        {
            $objectClass = str_replace('LogEntry', '', $this->_entityName);

            // avoid selecting logs for those entries which already had been undeleted
            $qbExisting = $this->getEntityManager()->createQueryBuilder();
            $qbExisting->select('tbl.id')
                ->from($objectClass, 'tbl');

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select('log')
               ->from($this->_entityName, 'log')
               ->andWhere('log.objectClass = :objectClass')
               ->setParameter('objectClass', $objectClass)
               ->andWhere('log.action = :action')
               ->setParameter('action', LoggableListener::ACTION_REMOVE)
               ->andWhere($qb->expr()->notIn('log.objectId', $qbExisting->getDQL()))
               ->orderBy('log.loggedAt', 'DESC')
            ;

            $query = $qb->getQuery();

            if (null !== $limit) {
                $query->setMaxResults($limit);
            }

            return $query->getResult();
        }

        /**
         * Removes (or rather conflates) all obsolete log entries.
         *
         * @param string $revisionHandling The currently configured revision handling mode
         * @param string $limitParameter Optional parameter for limitation (maximum revision amount or date interval)
         */
        public function purgeHistory(string $revisionHandling = 'unlimited', string $limitParameter = ''): void
        {
            if (
                'unlimited' === $revisionHandling
                || !in_array($revisionHandling, ['limitedByAmount', 'limitedByDate'], true)
            ) {
                // nothing to do
                return;
            }

            $objectClass = str_replace('LogEntry', '', $this->_entityName);

            // step 1 - determine obsolete revisions
            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select('log')
               ->from($this->_entityName, 'log')
               ->andWhere('log.objectClass = :objectClass')
               ->setParameter('objectClass', $objectClass)
               ->addOrderBy('log.objectId', 'ASC')
               ->addOrderBy('log.version', 'ASC')
            ;

            $logAmountMap = [];
            if ('limitedByAmount' === $revisionHandling) {
                $limitParameter = (int) $limitParameter;
                if (!$limitParameter) {
                    $limitParameter = 25;
                }
                ++$limitParameter; // one more for the initial creation entry

                $qbMatchingObjects = $this->getEntityManager()->createQueryBuilder();
                $qbMatchingObjects->select('log.objectId, COUNT(log.objectId) amountOfRevisions')
                    ->from($this->_entityName, 'log')
                    ->andWhere('log.objectClass = :objectClass')
                    ->setParameter('objectClass', $objectClass)
                    ->groupBy('log.objectId')
                    ->andHaving('amountOfRevisions > :maxAmount')
                    ->setParameter('maxAmount', $limitParameter)
                ;
                $result = $qbMatchingObjects->getQuery()->getScalarResult();
                $identifiers = array_column($result, 'objectId');
                foreach ($result as $row) {
                    $logAmountMap[$row['objectId']] = $row['amountOfRevisions'];
                }

                $qb->andWhere('log.objectId IN (:identifiers)')
                   ->setParameter('identifiers', $identifiers)
                ;
            } elseif ('limitedByDate' === $revisionHandling) {
                if (!$limitParameter) {
                    $limitParameter = 'P1Y0M0DT0H0M0S';
                }
                $thresholdDate = new DateTime(date('Ymd'));
                $thresholdDate->sub(new DateInterval($limitParameter));

                $qb->andWhere('log.loggedAt <= :thresholdDate')
                   ->setParameter('thresholdDate', $thresholdDate)
                ;
            }

            // we do not need to filter specific actions, but may remove/conflate log entries with all actions
            // this does not affect detection of deleted «nameMultiple.formatForDisplay»
            // because in those cases the remove log entry is always the newest one (otherwise an undeletion has been done)

            $query = $qb->getQuery();
            $result = $query->getResult();
            if (!count($result)) {
                return;
            }

            $entityManager = $this->getEntityManager();
            $keepPerObject = 'limitedByAmount' === $revisionHandling ? $limitParameter : -1;
            $thresholdForObject = 0;
            $counterPerObject = 0;

            // loop through the log entries
            $dataForObject = [];
            $lastObjectId = 0;
            $lastLogEntry = null;
            foreach ($result as $logEntry) {
                // step 2 - conflate data arrays
                $objectId = $logEntry->getObjectId();
                if ($lastObjectId !== $objectId) {
                    if ($lastObjectId > 0) {
                        if (count($dataForObject)) {
                            // write conflated data into last obsolete version (which will be kept)
                            $lastLogEntry->setData($dataForObject);
                        }
                        // this becomes a creation entry now
                        $lastLogEntry->setAction(LoggableListener::ACTION_CREATE);
                        // we keep the old loggedAt value though
                    } else {
                        // very first loop execution, nothing special to do here
                    }
                    $counterPerObject = 1;
                    $thresholdForObject = 0 < $keepPerObject && isset($logAmountMap[$objectId])
                        ? ($logAmountMap[$objectId] - $keepPerObject)
                        : 1
                    ;
                    $dataForObject = $logEntry->getData();
                } else {
                    // we have a another log entry for the same object
                    if (0 > $keepPerObject || $counterPerObject < $thresholdForObject) {
                        if (null !== $logEntry->getData()) {
                            $dataForObject = array_merge($dataForObject, $logEntry->getData());
                        }
                        // thus we may remove the last one
                        $entityManager->remove($lastLogEntry);
                    }
                }

                $lastObjectId = $objectId;
                if (0 > $keepPerObject || $counterPerObject < $thresholdForObject) {
                    $lastLogEntry = $logEntry;
                }
                ++$counterPerObject;
            }

            // do not forget to save values for the last objectId
            if (null !== $lastLogEntry) {
                if (count($dataForObject)) {
                    $lastLogEntry->setData($dataForObject);
                }
                $lastLogEntry->setAction(LoggableListener::ACTION_CREATE);
            }

            // step 3 - push changes into database
            $entityManager->flush();
        }

        /**
         * Updates a changed user name in all affected log entries.
         */
        public function updateUserName(string $oldUserName, string $newUserName): void
        {
            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update($this->_entityName, 'tbl')
               ->set('tbl.username', $newUserName)
               ->where('tbl.username = :oldName')
               ->setParameter('oldName', $oldUserName);
            $query = $qb->getQuery();
            $query->execute();
        }
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»* @ORM\Entity(repositoryClass=«name.formatForCodeCapital»«extensionClassType.formatForCodeCapital»Repository::class)
         «' '»* @ORM\Table(
         «' '»*     name="«fullEntityTableName»_log_entry",
         «' '»*     options={"row_format":"DYNAMIC"},
         «' '»*     indexes={
         «' '»*         @ORM\Index(name="log_class_lookup_idx", columns={"object_class"}),
         «' '»*         @ORM\Index(name="log_date_lookup_idx", columns={"logged_at"}),
         «' '»*         @ORM\Index(name="log_user_lookup_idx", columns={"username"}),
         «' '»*         @ORM\Index(name="log_version_lookup_idx", columns={"object_id", "object_class", "version"}),
         «' '»*         @ORM\Index(name="log_object_id_lookup_idx", columns={"object_id"})
         «' '»*     }
         «' '»* )
    '''
}
