package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

class ArrayFieldTransformer {

    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/DataTransformer/ArrayFieldTransformer.php', transformerBaseImpl, transformerImpl)
    }

    def private transformerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer\Base;

        use Symfony\Component\Form\DataTransformerInterface;

        /**
         * Array field transformer base class.
         */
        abstract class AbstractArrayFieldTransformer implements DataTransformerInterface
        {
            /**
             * Transforms the object array to the normalised value.
             */
            public function transform($values)
            {
                if (null === $values) {
                    return '';
                }
        
                if (!is_array($values)) {
                    return $values;
                }
        
                if (!count($values)) {
                    return '';
                }
        
                $value = $this->removeEmptyEntries($values);
        
                return implode("\n", $value);
            }

            /**
             * Transforms a textual value back to the array.
             */
            public function reverseTransform($value)
            {
                if (!$value) {
                    return [];
                }
        
                $items = explode("\n", $value);
        
                return $this->removeEmptyEntries($items);
            }

            /**
             * Iterates over the given array and removes all empty entries.
             */
            protected function removeEmptyEntries(array $array = []): array
            {
                $items = $array;
        
                foreach ($items as $k => $v) {
                    if (!empty($v)) {
                        continue;
                    }
                    unset($items[$k]);
                }
        
                return $items;
            }
        }
    '''

    def private transformerImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer;

        use «appNamespace»\Form\DataTransformer\Base\AbstractArrayFieldTransformer;

        /**
         * Array field transformer implementation class.
         */
        class ArrayFieldTransformer extends AbstractArrayFieldTransformer
        {
            // feel free to add your customisation here
        }
    '''
}
