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
        «IF targets('1.5')»
            use Symfony\Component\Form\Extension\Core\Type\TextType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\PropertyAccess\PropertyAccess;
        use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
        use Zikula\UsersModule\Entity\UserEntity;
        use «appNamespace»\Form\DataTransformer\UserFieldTransformer;

        /**
         * User field type base class.
         */
        abstract class AbstractUserType extends AbstractType
        {
            /**
             * @var UserRepositoryInterface
             */
            protected $userRepository;

            /**
             * UserType constructor.
             *
             * @param UserRepositoryInterface $userRepository UserRepository service instance
             */
            public function __construct(UserRepositoryInterface $userRepository)
            {
                $this->userRepository = $userRepository;
            }

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new UserFieldTransformer($this->userRepository);
                $builder->addModelTransformer($transformer);
            }

            /**
             * @inheritDoc
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                $view->vars['inline_usage'] = $options['inline_usage'];

                $fieldName = $form->getConfig()->getName();
                $parentData = $form->getParent()->getData();
                $accessor = PropertyAccess::createPropertyAccessor();
                $fieldNameGetter = 'get' . ucfirst($fieldName);
                $user = null !== $parentData && method_exists($parentData, $fieldNameGetter) ? $accessor->getValue($parentData, $fieldNameGetter) : null;

                $view->vars['user_name'] = null !== $user && is_object($user) ? $user->getUname() : '';
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver
                    ->setDefaults([
                        'inline_usage' => false
                    ])
                    ->setAllowedTypes([
                        'inline_usage' => 'bool'
                    ])
                ;
            }

            /**
             * @inheritDoc
             */
            public function getParent()
            {
                return «IF targets('1.5')»TextType::class«ELSE»'Symfony\Component\Form\Extension\Core\Type\TextType'«ENDIF»;
            }

            /**
             * @inheritDoc
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
