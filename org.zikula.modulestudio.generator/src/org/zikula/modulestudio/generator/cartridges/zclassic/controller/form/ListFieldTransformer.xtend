package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ListFieldTransformer {
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/DataTransformer/ListFieldTransformer.php',
            fh.phpFileContent(it, transformerBaseImpl), fh.phpFileContent(it, transformerImpl)
        )
    }

    def private transformerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer\Base;

        use Symfony\Component\Form\DataTransformerInterface;
        use «appNamespace»\Helper\ListEntriesHelper;

        /**
         * List fields transformer base class.
         *
         * This data transformer treats mult-valued list fields.
         */
        class ListFieldTransformer implements DataTransformerInterface
        {
            /**
             * @var ListEntriesHelper
             */
            protected $listHelper;

            /**
             * ListFieldTransformer constructor.
             *
             * @param ListEntriesHelper $listHelper ListEntriesHelper service instance
             */
            public function __construct(ListEntriesHelper $listHelper)
            {
                $this->listHelper = $listHelper;
            }

            /**
             * Transforms the object values to the normalised value.
             *
             * @param string|null $values
             *
             * @return array
             */
            public function transform($values)
            {
                if (null === $values || '' === $values) {
                    return [];
                }

                return $this->listHelper->extractMultiList($values);
            }

            /**
             * Transforms an array with values back to the string.
             *
             * @param array $values
             *
             * @return string
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

        use «appNamespace»\Form\DataTransformer\Base\ListFieldTransformer as BaseTransformer;

        /**
         * List fields transformer implementation class.
         *
         * This data transformer treats mult-valued list fields.
         */
        class ListFieldTransformer extends BaseTransformer
        {
            // feel free to add your customisation here
        }
    '''
}
