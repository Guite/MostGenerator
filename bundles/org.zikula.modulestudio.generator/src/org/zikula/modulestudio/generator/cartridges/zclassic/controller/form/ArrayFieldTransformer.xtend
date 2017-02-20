package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ArrayFieldTransformer {

    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/DataTransformer/ArrayFieldTransformer.php',
            fh.phpFileContent(it, transformerBaseImpl), fh.phpFileContent(it, transformerImpl)
        )
    }

    def private transformerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer\Base;

        use Symfony\Component\Form\DataTransformerInterface;
        use Symfony\Component\Form\FormBuilderInterface;

        /**
         * Array field transformer base class.
         */
        abstract class AbstractArrayFieldTransformer implements DataTransformerInterface
        {
            /**
             * Transforms the object array to the normalised value.
             *
             * @param array|null $values
             *
             * @return string
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
             Transforms a textual value back to the array.
             *
             * @param string $value
             *
             * @return array
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
             *
             * @param array array The given input array.
             *
             * @return array The cleaned array.
             */
            protected function removeEmptyEntries($array)
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
