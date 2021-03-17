package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ObjectField
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.AbstractIntegerField

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
        «IF entity instanceof Entity && (entity as Entity).loggable && !(it instanceof ObjectField) && !translatable»«/* if loggable and translatable are combined we add store this into a translationData array field instead */» * @Gedmo\Versioned
        «ENDIF»
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''
        /**
         * Description of currently executed action to be persisted in next log entry.
         *
         * @var string
         */
        protected $_actionDescriptionForLogEntry = '';

    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «IF application.targets('3.0')»
            «(new FileHelper(application)).getterAndSetterMethods(it, '_actionDescriptionForLogEntry', 'string', false, false, true, '', '')»
        «ELSE»
            «(new FileHelper(application)).getterAndSetterMethods(it, '_actionDescriptionForLogEntry', 'string', false, false, false, '', '')»
        «ENDIF»
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
             * @var int
             *
             * @ORM\Column(name="object_id", type="integer")
             */
            protected $objectId;

        «ENDIF»
        /**
         * Extended description of the executed action which produced this log entry.
         *
         * @var string
         * @ORM\Column(name="action_description", length=255)
         */
        protected $actionDescription = '';
        «IF application.targets('3.0')»
            «(new FileHelper(application)).getterAndSetterMethods(it, 'actionDescription', 'string', false, false, true, '', '')»
        «ELSE»
            «(new FileHelper(application)).getterAndSetterMethods(it, 'actionDescription', 'string', false, false, false, '', '')»
        «ENDIF»
    '''

    /**
     * Returns the extension repository base class implementation.
     */
    override extensionRepositoryClassBaseImplementation(Entity it) '''
        /**
         * Selects all log entries for removals to determine deleted «nameMultiple.formatForDisplay».
         «IF !application.targets('3.0')»
         *
         * @param integer $limit The maximum amount of items to fetch
         *
         * @return array Collection containing retrieved items
         «ENDIF»
         */
        public function selectDeleted«IF application.targets('3.0')»(?int $limit = null): array«ELSE»($limit = null)«ENDIF»
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
         * @param string $limitParameter Optional parameter for limitation (maximum revision amount«IF application.targets('2.0')» or date interval«ENDIF»)
         */
        public function purgeHistory«IF application.targets('3.0')»(string $revisionHandling = 'unlimited', string $limitParameter = ''): void«ELSE»($revisionHandling = 'unlimited', $limitParameter = '')«ENDIF»
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
            }«IF application.targets('2.0')» elseif ('limitedByDate' === $revisionHandling) {
                if (!$limitParameter) {
                    $limitParameter = 'P1Y0M0DT0H0M0S';
                }
                $thresholdDate = new DateTime(date('Ymd'));
                $thresholdDate->sub(new DateInterval($limitParameter));

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
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
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
