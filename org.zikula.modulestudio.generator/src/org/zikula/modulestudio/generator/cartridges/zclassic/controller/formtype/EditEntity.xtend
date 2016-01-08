package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditEntity {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for entity editing form type.
     * 1.4.x only.
     */
    def generate(Entity it, IFileSystemAccess fsa) {
        if (!hasActions('edit')) {
            return
        }
        app = it.application
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Form/Type/' + name.formatForCodeCapital + 'Type.php',
            fh.phpFileContent(app, editTypeBaseImpl), fh.phpFileContent(app, editTypeImpl)
        )
    }

    def private editTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\Base;

        use Symfony\Component\Form\AbstractType as SymfonyAbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\Translation\TranslatorInterface;
        «IF metaData»
            use Symfony\Component\Validator\Constraints\Valid;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» editing form type base class.
         */
        class «name.formatForCodeCapital»Type extends SymfonyAbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * «name.formatForCodeCapital»Type constructor.
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
                «/* TODO add fields */»

                «/* note: */»
                // all form fields not existing in the mapped object cause an exception
                // hence additional form fields need mapped=false
                // $builder->add('addition', '«nsSymfonyFormType»TextType', ['mapped' => false]);
                // form fields not contained in submitted data are explictly set to null

                «IF metaData»

                    // embedded meta data form
                    $builder->add('metadata', '«app.appNamespace»\Form\EntityMetaDataType', [
                        'constraints' => new Valid()
                    ]);
                «ENDIF»
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»';
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver->setDefaults([
                    // define class for underlying data (required for embedding forms)
                    'data_class' => '«entityClassName('', false)»'
                ]);
            }
        }
    '''

    def private editTypeImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type;

        use «app.appNamespace»\Form\Type\Base\«name.formatForCodeCapital»Type as Base«name.formatForCodeCapital»Type;

        /**
         * «name.formatForDisplayCapital» editing form type implementation class.
         */
        class «name.formatForCodeCapital»Type extends Base«name.formatForCodeCapital»Type
        {
            // feel free to extend the «name.formatForDisplay» editing form type class here
        }
    '''
}
