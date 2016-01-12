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
        namespace «appNamespace»\Form\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Translation\TranslatorInterface;
        use «app.appNamespace»\Helper\ListEntriesHelper;

        /**
         * Multi list field type base class.
         */
        class MultiListType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * @var ListEntriesHelper
             */
            private $listHelper;

            /**
             * AppSettingsType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
             * @param ListEntriesHelper   $listHelper ListEntriesHelper service instance.
             */
            public function __construct(TranslatorInterface $translator, ListEntriesHelper $listHelper)
            {
                $this->translator = $translator;
                $this->listHelper = $listHelper;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new ListFieldTransformer($this->listHelper);
                $builder->addModelTransformer($transformer);
            }

            /**
             * {@inheritdoc}
             */
            public function getParent()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\ChoiceType';
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_multilist';
            }
        }
    '''

    def private multiListTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Field;

        use «appNamespace»\Form\Base\AppSettingsType as BaseAppSettingsType;

        /**
         * Multi list field type implementation class.
         */
        class MultiListType extends BaseMultiListType
        {
            // feel free to extend the base form type class here
        }
    '''
}
