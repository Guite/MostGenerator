package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AutoCompletionRelationTransformer {
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/DataTransformer/AutoCompletionRelationTransformer.php',
            fh.phpFileContent(it, transformerBaseImpl), fh.phpFileContent(it, transformerImpl)
        )
    }

    def private transformerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer\Base;

        use Doctrine\Common\Collections\ArrayCollection;
        use Doctrine\Common\Persistence\ObjectManager;
        use Doctrine\ORM\QueryBuilder;
        use Symfony\Component\Form\DataTransformerInterface;
        use Symfony\Component\Form\Exception\TransformationFailedException;
        use Zikula\Core\Doctrine\EntityAccess;

        /**
         * Auto completion relation transformer base class.
         *
         * This data transformer identifiers chosen by an auto completion functionality.
         */
        class AutoCompletionRelationTransformer implements DataTransformerInterface
        {
            /**
             * @var ObjectManager The object manager to be used for determining the repository.
             */
            protected $objectManager;

            /**
             * @var String
             */
            protected $objectType;

            /**
             * @var Boolean
             */
            protected $isMultiple = false;

            /**
             * AutoCompletionRelationTransformer constructor.
             *
             * @param ObjectManager $objectManager Doctrine object manager.
             * @param String        $objectType    The type of entities being processed.
             * @param Boolean       $isMultiple    Whether a single object or a collection of object is processed.
             */
            public function __construct(ObjectManager $objectManager, $objectType, $isMultiple)
            {
                $this->objectManager = $objectManager;
                $this->objectType = $objectType;
                $this->isMultiple = $isMultiple;
            }

            /**
             * Transforms a single object or a list of objects to a string with identifiers.
             *
             * @param EntityAccess|ArrayCollection $entities
             *
             * @return string
             */
            public function transform($entities)
            {
                $result = '';

                if ($this->isMultiple && !count($entities) || !$this->isMultiple && null == $entities) {
                    return $result;
                }

                if (!is_array($entities)) {
                    $entities = [$entities];
                }

                foreach ($entities as $entity) {
                    if ($result != '') {
                        $result .= ',';
                    }
                    $result .= $entity->createCompositeIdentifier();
                }

                return $result;
            }

            /**
             * Transforms a string (identifier list) to an object or object collection.
             *
             * @param string $value
             *
             * @return EntityAccess|ArrayCollection
             *
             * @throws TransformationFailedException if object (issue) is not found.
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
                if (count($value) == 1 && empty($value[0])) {
                    return $this->isMultiple ? new ArrayCollection() : null;
                }

                $repository = $this->objectManager->getRepository('«appName»:' . ucfirst($this->objectType) . 'Entity');

                $qb = $repository->genericBaseQuery('', '', false);
                $qb = $this->buildWhereClause($value, $qb);
                //$qb = $repository->addCommonViewFilters($qb);

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
        protected function buildWhereClause($inputValue, QueryBuilder $qb)
        {
            if (!$this->mandatory) {
                // remove empty option if it has been selected
                foreach ($inputValue as $k => $v) {
                    if (!$v) {
                        unset($inputValue[$k]);
                    }
                }
            }
            // readd filter value for returning nothing if no real item has been selected
            if (count($inputValue) == 0) {
                $inputValue[] = 0;
            }

            if (count($this->idFields) > 1) {
                $idsPerField = $this->decodeCompositeIdentifier($inputValue);
                foreach ($this->idFields as $idField) {
                    $qb->andWhere('tbl.' . $idField . ' IN (:' . $idField . 'Ids)')
                       ->setParameter($idField . 'Ids', $idsPerField[$idField]);
                }
            } else {
                $many = ($this->selectionMode == 'multiple');
                $idField = reset($this->idFields);
                if ($many) {
                    $qb->andWhere('tbl.' . $idField . ' IN (:' . $idField . 'Ids)')
                       ->setParameter($idField . 'Ids', $inputValue);
                } else {
                    $qb->andWhere('tbl.' . $idField . ' = :' . $idField)
                       ->setParameter($idField, $inputValue);
                }
            }
            if (!empty($this->where)) {
                $qb->andWhere($this->where);
            }

            return $qb;
        }
    '''

    def private transformerImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer;

        use «appNamespace»\Form\DataTransformer\Base\AutoCompletionRelationTransformer as BaseTransformer;

        /**
         * Auto completion relation transformer implementation class.
         *
         * This data transformer identifiers chosen by an auto completion functionality.
         */
        class AutoCompletionRelationTransformer extends BaseTransformer
        {
            // feel free to add your customisation here
        }
    '''
}