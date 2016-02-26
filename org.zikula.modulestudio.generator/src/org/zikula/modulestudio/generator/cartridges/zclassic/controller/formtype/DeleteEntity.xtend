package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DeleteEntity {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for entity deletion form type.
     * 1.4.x only.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasDeleteActions) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/DeleteEntityType.php',
            fh.phpFileContent(it, deleteEntityTypeBaseImpl), fh.phpFileContent(it, deleteEntityTypeImpl)
        )
    }

    def private deleteEntityTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Zikula\Common\Translator\TranslatorInterface;

        /**
         * Entity deletion form type base class.
         */
        class DeleteEntityType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * DeleteEntityType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
             */
            public function __construct(TranslatorInterface $translator)
            {
                $this->translator = $translator;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->add('delete', '«nsSymfonyFormType»SubmitType', [
                        'label' => $this->translator->__('Delete')
                    ])
                    ->add('cancel', '«nsSymfonyFormType»SubmitType', [
                        'label' => $this->translator->__('Cancel')
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_deleteentity';
            }

            /**
             * {@inheritdoc}
             */
            public function getName()
            {
                return $this->getBlockPrefix();
            }
        }
    '''

    def private deleteEntityTypeImpl(Application it) '''
        namespace «appNamespace»\Form;

        use «appNamespace»\Form\Base\DeleteEntityType as BaseDeleteEntityType;

        /**
         * Entity deletion form type implementation class.
         */
        class DeleteEntityType extends BaseDeleteEntityType
        {
            // feel free to extend the base form type class here
        }
    '''
}
