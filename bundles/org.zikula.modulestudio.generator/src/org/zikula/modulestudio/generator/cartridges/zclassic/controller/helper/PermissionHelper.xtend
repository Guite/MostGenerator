package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class PermissionHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for custom permission control'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/PermissionHelper.php', permissionHelperBaseClass, permissionHelperImpl)
    }

    def private permissionHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\Core\Doctrine\EntityAccess;
        «IF hasLoggable»
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        use Zikula\GroupsModule\Entity\GroupEntity;
        use Zikula\PermissionsModule\Api\ApiInterface\PermissionApiInterface;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
        use Zikula\UsersModule\Entity\UserEntity;

        /**
         * Permission helper base class.
         */
        abstract class AbstractPermissionHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var PermissionApiInterface
         */
        protected $permissionApi;
        «IF hasLoggable»

            /**
             * @var VariableApiInterface
             */
            protected $variableApi;
        «ENDIF»

        /**
         * @var CurrentUserApiInterface
         */
        protected $currentUserApi;

        /**
         * @var UserRepositoryInterface
         */
        protected $userRepository;

        public function __construct(
            RequestStack $requestStack,
            PermissionApiInterface $permissionApi,
            «IF hasLoggable»
                VariableApiInterface $variableApi,
            «ENDIF»
            CurrentUserApiInterface $currentUserApi,
            UserRepositoryInterface $userRepository
        ) {
            $this->requestStack = $requestStack;
            $this->permissionApi = $permissionApi;
            «IF hasLoggable»
                $this->variableApi = $variableApi;
            «ENDIF»
            $this->currentUserApi = $currentUserApi;
            $this->userRepository = $userRepository;
        }

        «accessMethods»

        «helperMethods»
    '''

    def private accessMethods(Application it) '''
        /**
         * Checks if the given entity instance may be read.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity
         * @param int $userId
         *
         * @return bool
         «ENDIF»
         */
        public function mayRead(EntityAccess $entity, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: bool«ENDIF»
        {
            return $this->hasEntityPermission($entity, ACCESS_READ, $userId);
        }

        /**
         * Checks if the given entity instance may be edited.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity
         * @param int $userId
         *
         * @return bool
         «ENDIF»
         */
        public function mayEdit(EntityAccess $entity, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: bool«ENDIF»
        {
            return $this->hasEntityPermission($entity, ACCESS_EDIT, $userId);
        }
        «IF hasLoggable»

            /**
             * Checks if the given entity instance may be deleted.
             «IF !targets('3.0')»
             *
             * @param EntityAccess $entity
             * @param int $userId
             *
             * @return bool
             «ENDIF»
             */
            public function mayAccessHistory(EntityAccess $entity, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: bool«ENDIF»
            {
                $objectType = $entity->get_objectType();

                return $this->mayEdit($entity, $userId) && $this->variableApi->get('«appName»', 'show' . ucfirst($objectType) . 'History', true);
            }
        «ENDIF»

        /**
         * Checks if the given entity instance may be deleted.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity
         * @param int $userId
         *
         * @return bool
         «ENDIF»
         */
        public function mayDelete(EntityAccess $entity, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: bool«ENDIF»
        {
            return $this->hasEntityPermission($entity, ACCESS_DELETE, $userId);
        }

        /**
         * Checks if a certain permission level is granted for the given entity instance.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity
         * @param int $permissionLevel
         * @param int $userId
         *
         * @return bool
         «ENDIF»
         */
        public function hasEntityPermission(EntityAccess $entity, «IF targets('3.0')»int «ENDIF»$permissionLevel, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: bool«ENDIF»
        {
            $objectType = $entity->get_objectType();
            $instance = $entity->getKey() . '::';

            return $this->permissionApi->hasPermission('«appName»:' . ucfirst($objectType) . ':', $instance, $permissionLevel, $userId);
        }
    '''

    def private helperMethods(Application it) '''
        /**
         * Checks if a certain permission level is granted for the given object type.
         «IF !targets('3.0')»
         *
         * @param string $objectType
         * @param int $permissionLevel
         * @param int $userId
         *
         * @return bool
         «ENDIF»
         */
        public function hasComponentPermission(«IF targets('3.0')»string «ENDIF»$objectType, «IF targets('3.0')»int «ENDIF»$permissionLevel, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: bool«ENDIF»
        {
            return $this->permissionApi->hasPermission('«appName»:' . ucfirst($objectType) . ':', '::', $permissionLevel, $userId);
        }
        «IF hasViewActions»

            /**
             * Checks if the quick navigation form for the given object type may be used or not.
             «IF !targets('3.0')»
             *
             * @param string $objectType
             * @param int $userId
             *
             * @return bool
             «ENDIF»
             */
            public function mayUseQuickNav(«IF targets('3.0')»string «ENDIF»$objectType, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: bool«ENDIF»
            {
                return $this->hasComponentPermission($objectType, ACCESS_READ, $userId);
            }
        «ENDIF»

        /**
         * Checks if a certain permission level is granted for the application in general.
         «IF !targets('3.0')»
         *
         * @param int $permissionLevel
         * @param int $userId
         *
         * @return bool
         «ENDIF»
         */
        public function hasPermission(«IF targets('3.0')»int «ENDIF»$permissionLevel, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: bool«ENDIF»
        {
            return $this->permissionApi->hasPermission('«appName»::', '::', $permissionLevel, $userId);
        }

        /**
         * Returns the list of user group ids of the current user.
         *
         * @return int[] List of group ids
         */
        public function getUserGroupIds()«IF targets('3.0')»: array«ENDIF»
        {
            $isLoggedIn = $this->currentUserApi->isLoggedIn();
            if (!$isLoggedIn) {
                return [];
            }

            $groupIds = [];
            $groups = $this->currentUserApi->get('groups');
            /** @var GroupEntity $group */
            foreach ($groups as $group) {
                $groupIds[] = $group->getGid();
            }

            return $groupIds;
        }

        /**
         * Returns the the current user's id.
         «IF !targets('3.0')»
         *
         * @return int
         «ENDIF»
         */
        public function getUserId()«IF targets('3.0')»: int«ENDIF»
        {
            return (int)$this->currentUserApi->get('uid');
        }

        /**
         * Returns the the current user's entity.
         «IF !targets('3.0')»
         *
         * @return UserEntity
         «ENDIF»
         */
        public function getUser()«IF targets('3.0')»: UserEntity«ENDIF»
        {
            return $this->userRepository->find($this->getUserId());
        }
    '''

    def private permissionHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractPermissionHelper;

        /**
         * Permission helper implementation class.
         */
        class PermissionHelper extends AbstractPermissionHelper
        {
            // feel free to extend the permission helper here
        }
    '''
}
