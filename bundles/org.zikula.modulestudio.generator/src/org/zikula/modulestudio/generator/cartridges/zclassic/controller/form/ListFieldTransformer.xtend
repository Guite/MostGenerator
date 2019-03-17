package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

class ListFieldTransformer {

    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/DataTransformer/ListFieldTransformer.php', transformerBaseImpl, transformerImpl)
    }

    def private transformerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer\Base;

        use Symfony\Component\Form\DataTransformerInterface;
        use «appNamespace»\Helper\ListEntriesHelper;

        /**
         * List field transformer base class.
         *
         * This data transformer treats multi-valued list fields.
         */
        abstract class AbstractListFieldTransformer implements DataTransformerInterface
        {
            /**
             * @var ListEntriesHelper
             */
            protected $listHelper;

            /**
             * ListFieldTransformer constructor.
             *
             * @param ListEntriesHelper $listHelper
             */
            public function __construct(ListEntriesHelper $listHelper)
            {
                $this->listHelper = $listHelper;
            }

            /**
             * Transforms the object values to the normalised value.
             *
             * @param string|null $values The object values
             *
             * @return array Normalised value
             */
            public function transform($values)
            {
                if (null === $values || '' === $values) {
                    return [];
                }

                if (is_array($values)) {
                    return $values;
                }

                return $this->listHelper->extractMultiList($values);
            }

            /**
             * Transforms an array with values back to the string.
             *
             * @param array $values The values
             *
             * @return string Resulting string
             */
            public function reverseTransform($values)
            {
                if (!$values) {
                    return '';
                }

                return '###' . implode('###', $values) . '###';
            }
        }
    '''

    def private transformerImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer;

        use «appNamespace»\Form\DataTransformer\Base\AbstractListFieldTransformer;

        /**
         * List field transformer implementation class.
         *
         * This data transformer treats multi-valued list fields.
         */
        class ListFieldTransformer extends AbstractListFieldTransformer
        {
            // feel free to add your customisation here
        }
    '''
}
