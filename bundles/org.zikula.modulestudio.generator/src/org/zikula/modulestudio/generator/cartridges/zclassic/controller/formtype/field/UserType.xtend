package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserType {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/UserType.php',
            fh.phpFileContent(it, userTypeBaseImpl), fh.phpFileContent(it, userTypeImpl)
        )
    }

    def private userTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormEvent;
        use Symfony\Component\Form\FormEvents;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\OptionsResolver\OptionsResolver;

        /**
         * User field type base class.
         */
        abstract class AbstractUserType extends AbstractType
        {
            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder->addEventListener(FormEvents::PRE_SUBMIT, function(FormEvent $event) {
                    $formData = $event->getData();

                    if (!$formData) {
                        return;
                    }

                    $formData = intval($formData);
                    $event->setData($formData);
                });
            }

            /**
             * {@inheritdoc}
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                $view->vars['inlineUsage'] = $options['inlineUsage'];
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver
                    ->setDefaults([
                        'inlineUsage' => false
                    ])
                    ->setAllowedTypes([
                        'inlineUsage' => 'bool'
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getParent()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\TextType';
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_user';
            }
        }
    '''

    def private userTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractUserType;

        /**
         * User field type implementation class.
         */
        class UserType extends AbstractUserType
        {
            // feel free to add your customisation here
        }
    '''
}
