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
        use «appNamespace»\Entity\Factory\EntityFactory;

        /**
         * Auto completion relation transformer base class.
         *
         * This data transformer identifiers chosen by an auto completion functionality.
         */
        abstract class AbstractAutoCompletionRelationTransformer implements DataTransformerInterface
        {
            public function __construct(
                protected EntityFactory $entityFactory,
                protected string $objectType,
                protected bool $isMultiple
            ) {
            }

            /**
             * Transforms a single object or a list of objects to a string with identifiers.
             */
            public function transform($entities)
            {
                $result = '';
                if (null === $entities) {
                    return $result;
                }

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
                $this->applyFilter($qb, $value);

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

            «applyFilter»
        }
    '''

    def private applyFilter(Application it) '''
        /**
         * Adds the filter for selecting matches for the current search to the given query builder.
         */
        protected function applyFilter(QueryBuilder $qb, array $inputValues = []): void
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
