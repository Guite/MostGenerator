package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ObjectField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Loggable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

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
         * Selects all log entries for deletions to determine deleted «name.formatForDisplay».
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
               ->andWhere('log.action = :action')
               ->andWhere($qb->expr()->notIn('log.objectId', $qbExisting->getDQL()))
               ->orderBy('log.version', 'DESC');

            $qb->setParameter('objectClass', $objectClass)
               ->setParameter('action', 'remove');

            $query = $qb->getQuery();

            if (null !== $limit) {
                $query->setMaxResults($limit);
            }

            return $query->getResult();
        }
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»*
         «' '»* @ORM\Entity(repositoryClass="«repositoryClass(extensionClassType)»")
         «' '»* @ORM\Table(name="«fullEntityTableName»_log_entry",
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
