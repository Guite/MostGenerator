package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MultiListType {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app

    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasMultiListFields) {
            return
        }
        app = it
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/MultiListType.php',
            fh.phpFileContent(it, multiListTypeBaseImpl), fh.phpFileContent(it, multiListTypeImpl)
        )
    }

    def private multiListTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        «IF targets('1.5')»
            use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        use «appNamespace»\Form\DataTransformer\ListFieldTransformer;
        use «app.appNamespace»\Helper\ListEntriesHelper;

        /**
         * Multi list field type base class.
         */
        abstract class AbstractMultiListType extends AbstractType
        {
            /**
             * @var ListEntriesHelper
             */
            protected $listHelper;

            /**
             * MultiListType constructor.
             *
             * @param ListEntriesHelper $listHelper ListEntriesHelper service instance
             */
            public function __construct(ListEntriesHelper $listHelper)
            {
                $this->listHelper = $listHelper;
            }

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new ListFieldTransformer($this->listHelper);
                $builder->addModelTransformer($transformer);
            }

            /**
             * @inheritDoc
             */
            public function getParent()
            {
                return «IF targets('1.5')»ChoiceType::class«ELSE»'Symfony\Component\Form\Extension\Core\Type\ChoiceType'«ENDIF»;
            }

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_multilist';
            }
        }
    '''

    def private multiListTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractMultiListType;

        /**
         * Multi list field type implementation class.
         */
        class MultiListType extends AbstractMultiListType
        {
            // feel free to extend the base form type class here
        }
    '''
}
