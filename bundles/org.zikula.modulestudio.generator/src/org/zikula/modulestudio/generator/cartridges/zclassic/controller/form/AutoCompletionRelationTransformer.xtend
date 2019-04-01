package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

class AutoCompletionRelationTransformer {

    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/DataTransformer/AutoCompletionRelationTransformer.php', transformerBaseImpl, transformerImpl)
    }

    def private transformerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer\Base;

        use Doctrine\Common\Collections\ArrayCollection;
        use Doctrine\Common\Collections\Selectable;
        use Doctrine\ORM\QueryBuilder;
        use Symfony\Component\Form\DataTransformerInterface;
        use Symfony\Component\Form\Exception\TransformationFailedException;
        use Zikula\Core\Doctrine\EntityAccess;
        use «appNamespace»\Entity\Factory\EntityFactory;

        /**
         * Auto completion relation transformer base class.
         *
         * This data transformer identifiers chosen by an auto completion functionality.
         */
        abstract class AbstractAutoCompletionRelationTransformer implements DataTransformerInterface
        {
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var string
             */
            protected $objectType;

            /**
             * @var bool
             */
            protected $isMultiple = false;

            public function __construct(
                EntityFactory $entityFactory,
                «IF targets('3.0')»string «ENDIF»$objectType,
                «IF targets('3.0')»bool «ENDIF»$isMultiple
            ) {
                $this->entityFactory = $entityFactory;
                $this->objectType = $objectType;
                $this->isMultiple = $isMultiple;
            }

            /**
             * Transforms a single object or a list of objects to a string with identifiers.
             *
             * @param EntityAccess|Selectable $entities
             *
             * @return string
             */
            public function transform($entities)
            {
                $result = '';

                if ($this->isMultiple && !count($entities) || !$this->isMultiple && null === $entities) {
                    return $result;
                }

                if (!(is_array($entities) || $entities instanceof Selectable)) {
                    $entities = [$entities];
                }

                foreach ($entities as $entity) {
                    if ('' !== $result) {
                        $result .= ',';
                    }
                    $result .= $entity->getKey();
                }

                return $result;
            }

            /**
             * Transforms a string (identifier list) to an object or object collection.
             *
             * @param string $value Identifier(s)
             *
             * @return EntityAccess|ArrayCollection Resulting object or object collection
             *
             * @throws TransformationFailedException if entity is not found
             */
            public function reverseTransform($value)
            {
                if (!$value) {
                    return $this->isMultiple ? new ArrayCollection() : null;
                }

                if (!is_array($value)) {
                    $value = explode(',', $value);
                }

                if (!count($value)) {
                    return $this->isMultiple ? new ArrayCollection() : null;
                }

                // fix for #446
                if (1 === count($value) && empty($value[0])) {
                    return $this->isMultiple ? new ArrayCollection() : null;
                }

                $repository = $this->entityFactory->getRepository($this->objectType);

                $qb = $repository->genericBaseQuery('', '', false);
                $qb = $this->buildWhereClause($value, $qb);

                $query = $repository->getQueryFromBuilder($qb);

                $entities = $query->getResult();
                if (!count($entities)) {
                    // causes a validation error
                    // this message is not shown to the user
                    // see the invalid_message option
                    throw new TransformationFailedException(sprintf('Failed to find entities ("%1$s") for identifier ("%2$s")!', [$this->objectType, $value]));
                }

                return $this->isMultiple ? $entities : $entities[0];
            }

            «buildWhereClause»
        }
    '''

    def private buildWhereClause(Application it) '''
        /**
         * Builds the where clause for selecting matches for the current search.
         «IF !targets('3.0')»
         *
         * @param array $inputValues The identifier list
         * @param QueryBuilder $qb The query builder to be enriched
         *
         * @return Querybuilder The enriched query builder
         «ENDIF»
         */
        protected function buildWhereClause(array $inputValues = [], QueryBuilder $qb)«IF targets('3.0')»: QueryBuilder«ENDIF»
        {
            // remove empty option if it has been selected
            foreach ($inputValues as $k => $v) {
                if (!$v) {
                    unset($inputValues[$k]);
                }
            }

            // readd filter value for returning nothing if no real item has been selected
            if (0 === count($inputValues)) {
                $inputValues[] = 0;
            }

            $idField = $this->entityFactory->getIdField($this->objectType);
            if ($this->isMultiple) {
                $qb->andWhere('tbl.' . $idField . ' IN (:' . $idField . 'Ids)')
                   ->setParameter($idField . 'Ids', $inputValues);
            } else {
                $qb->andWhere('tbl.' . $idField . ' = :' . $idField)
                   ->setParameter($idField, $inputValues[0]);
            }

            return $qb;
        }
    '''

    def private transformerImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer;

        use «appNamespace»\Form\DataTransformer\Base\AbstractAutoCompletionRelationTransformer;

        /**
         * Auto completion relation transformer implementation class.
         *
         * This data transformer identifiers chosen by an auto completion functionality.
         */
        class AutoCompletionRelationTransformer extends AbstractAutoCompletionRelationTransformer
        {
            // feel free to add your customisation here
        }
    '''
}
