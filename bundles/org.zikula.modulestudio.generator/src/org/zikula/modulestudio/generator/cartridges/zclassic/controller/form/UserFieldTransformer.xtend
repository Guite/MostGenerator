package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserFieldTransformer {

    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/DataTransformer/UserFieldTransformer.php',
            fh.phpFileContent(it, transformerBaseImpl), fh.phpFileContent(it, transformerImpl)
        )
    }

    def private transformerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer\Base;

        use Symfony\Component\Form\DataTransformerInterface;
        use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
        use Zikula\UsersModule\Entity\UserEntity;

        /**
         * User field transformer base class.
         *
         * This data transformer treats user fields.
         */
        abstract class AbstractUserFieldTransformer implements DataTransformerInterface
        {
            /**
             * @var UserRepositoryInterface
             */
            protected $userRepository;

            /**
             * UserFieldTransformer constructor.
             *
             * @param UserRepositoryInterface $userRepository UserRepository service instance
             */
            public function __construct(UserRepositoryInterface $userRepository)
            {
                $this->userRepository = $userRepository;
            }

            /**
             * Transforms the object values to the normalised value.
             *
             * @param UserEntity|null $value
             *
             * @return int|null
             */
            public function transform($value)
            {
                if (null === $value || !$value) {
                    return null;
                }

                if ($value instanceof UserEntity) {
                    return $value->getUid();
                }

                return intval($value);
            }

            /**
             * Transforms the form value back to the user entity.
             *
             * @param int $value
             *
             * @return UserEntity|null
             */
            public function reverseTransform($value)
            {
                if (!$value) {
                    return null;
                }

                return $this->userRepository->find($value);
            }
        }
    '''

    def private transformerImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer;

        use «appNamespace»\Form\DataTransformer\Base\AbstractUserFieldTransformer;

        /**
         * User field transformer implementation class.
         *
         * This data transformer treats user fields.
         */
        class UserFieldTransformer extends AbstractUserFieldTransformer
        {
            // feel free to add your customisation here
        }
    '''
}
