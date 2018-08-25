package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ObjectField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Loggable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
         * @Gedmo\Loggable(logEntryClass="\«entityClassName('logEntry', false)»")
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
        «IF entity instanceof Entity && (entity as Entity).loggable && !(it instanceof ObjectField)» * @Gedmo\Versioned
        «ENDIF»
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
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
        use Gedmo\Loggable\Entity\MappedSuperclass\«extensionBaseClass»;
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
     * Returns the extension repository base class implementation.
     */
    override extensionRepositoryClassBaseImplementation(Entity it) '''
        /**
         * Selects all log entries for removals to determine deleted «nameMultiple.formatForDisplay».
         *
         * @param integer $limit The maximum amount of items to fetch
         *
         * @return ArrayCollection Collection containing retrieved items
         */
        public function selectDeleted($limit = null)
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
               ->orderBy('log.version', 'DESC')
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
         * @param string $limitParameter   Optional parameter for limitation (maximum revision amount«IF application.targets('2.0')» or date interval«ENDIF»)
         */
        public function purgeHistory($revisionHandling = 'unlimited', $limitParameter = '')
        {
            if ('unlimited' == $revisionHandling || !in_array($revisionHandling, ['limitedByAmount', 'limitedByDate'])) {
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
            if ('limitedByAmount' == $revisionHandling) {
                $limitParameter = intval($limitParameter);
                if (!$limitParameter) {
                    $limitParameter = 25;
                }
                $limitParameter++; // one more for the initial creation entry

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
            }«IF application.targets('2.0')» elseif ('limitedByDate' == $revisionHandling) {
                if (!$limitParameter) {
                    $limitParameter = 'P1Y0M0DT0H0M0S';
                }
                $thresholdDate = new \DateTime(date('Ymd'));
                $thresholdDate->sub(new \DateInterval($limitParameter));

                $qb->andWhere('log.loggedAt <= :thresholdDate')
                   ->setParameter('thresholdDate', $thresholdDate)
                ;
            }«ENDIF»

            // we do not need to filter specific actions, but may remove/conflate log entries with all actions
            // this does not affect detection of deleted «nameMultiple.formatForDisplay»
            // because in those cases the remove log entry is always the newest one (otherwise an undeletion has been done)

            $query = $qb->getQuery();
            $result = $query->getResult();
            if (!count($result)) {
                return;
            }

            $entityManager = $this->getEntityManager();
            $keepPerObject = 'limitedByAmount' == $revisionHandling ? $limitParameter : -1;
            $thresholdForObject = 0;
            $counterPerObject = 0;

            // loop through the log entries
            $dataForObject = [];
            $lastObjectId = 0;
            $lastLogEntry = null;
            foreach ($result as $logEntry) {
                // step 2 - conflate data arrays
                $objectId = $logEntry->getObjectId();
                if ($lastObjectId != $objectId) {
                    if ($lastObjectId > 0) {
                        // write conflated data into last obsolete version (which will be kept)
                        $lastLogEntry->setData($dataForObject);
                        // this becomes a creation entry now
                        $lastLogEntry->setAction(LoggableListener::ACTION_CREATE);
                        // we keep the old loggedAt value though
                    } else {
                        // very first loop execution, nothing special to do here
                    }
                    $counterPerObject = 1;
                    $thresholdForObject = $keepPerObject > 0 && isset($logAmountMap[$objectId]) ? ($logAmountMap[$objectId] - $keepPerObject) : 1;
                } else {
                    // we have a another log entry for the same object
                    if ($keepPerObject < 0 || $counterPerObject < $thresholdForObject) {
                        if (null !== $logEntry->getData()) {
                            $dataForObject = array_merge($dataForObject, $logEntry->getData());
                        }
                        // thus we may remove the last one
                        $entityManager->remove($lastLogEntry);
                    }
                }

                $lastObjectId = $objectId;
                if ($keepPerObject < 0 || $counterPerObject < $thresholdForObject) {
                	$lastLogEntry = $logEntry;
                }
                $counterPerObject++;
            }

            // do not forget to save values for the last objectId
            if (null !== $lastLogEntry && count($dataForObject)) {
                $lastLogEntry->setData($dataForObject);
                $lastLogEntry->setAction(LoggableListener::ACTION_CREATE);
            }

            // step 3 - push changes into database
            $entityManager->flush();
        }
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»*
         «' '»* @ORM\Entity(repositoryClass="«repositoryClass(extensionClassType)»")
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
