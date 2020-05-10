package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyPermissionInheritanceType
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class PermissionHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for custom permission control'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/PermissionHelper.php', permissionHelperBaseClass, permissionHelperImpl)
    }

    def private permissionHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF hasViewActions»
            use Doctrine\Common\Collections\ArrayCollection;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF targets('3.0')»
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
        «ELSE»
            use Zikula\Core\Doctrine\EntityAccess;
        «ENDIF»
        «IF hasLoggable»
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        use Zikula\GroupsModule\Entity\GroupEntity;
        use Zikula\PermissionsModule\Api\ApiInterface\PermissionApiInterface;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
        use Zikula\UsersModule\Entity\UserEntity;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\CategoryHelper;
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

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
        «IF hasCategorisableEntities»

            /**
             * @var FeatureActivationHelper
             */
            protected $featureActivationHelper;

            /**
             * @var CategoryHelper
             */
            protected $categoryHelper;
        «ENDIF»

        public function __construct(
            RequestStack $requestStack,
            PermissionApiInterface $permissionApi,
            «IF hasLoggable»
                VariableApiInterface $variableApi,
            «ENDIF»
            CurrentUserApiInterface $currentUserApi,
            UserRepositoryInterface $userRepository«IF hasCategorisableEntities»,
            FeatureActivationHelper $featureActivationHelper,
            CategoryHelper $categoryHelper«ENDIF»
        ) {
            $this->requestStack = $requestStack;
            $this->permissionApi = $permissionApi;
            «IF hasLoggable»
                $this->variableApi = $variableApi;
            «ENDIF»
            $this->currentUserApi = $currentUserApi;
            $this->userRepository = $userRepository;
            «IF hasCategorisableEntities»
                $this->featureActivationHelper = $featureActivationHelper;
                $this->categoryHelper = $categoryHelper;
            «ENDIF»
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

                return $this->mayEdit($entity, $userId)
                    && $this->variableApi->get('«appName»', 'show' . ucfirst($objectType) . 'History', true)
                ;
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

            «IF hasCategorisableEntities»
                // check category permissions
                if (in_array($objectType, ['«getCategorisableEntities.map[name.formatForCode].join('\', \'')»'], true)) {
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                        if (!$this->categoryHelper->hasPermission($entity)) {
                            return false;
                        }
                    }
                }

            «ENDIF»
            «IF hasEntitiesInheritingPermissions»
                // check inherited permissions
                «FOR entity : getEntitiesInheritingPermissions»
                    if ('«entity.name.formatForCode»' === $objectType) {
                        «FOR relation : entity.getBidirectionalIncomingPermissionInheriters»
                            «entity.inheritedPermissionCheck(relation)»
                        «ENDFOR»
                    }
                «ENDFOR»

            «ENDIF»
            return $this->permissionApi->hasPermission(
                '«appName»:' . ucfirst($objectType) . ':',
                $instance,
                $permissionLevel,
                $userId
            );
        }
        «IF hasViewActions»

            /**
             * Filters a given collection of entities based on different permission checks.
             *
             «IF !targets('3.0')»
             «IF !isSystemModule»
             * @param string $objectType
             «ENDIF»
             * @param array|ArrayCollection $entities The given list of entities
             * @param int $userId
             *
             * @return array The filtered list of entities
             «ENDIF»
             */
            public function filterCollection(«IF !isSystemModule»$objectType, «ENDIF»$entities, «IF targets('3.0')»int «ENDIF»$permissionLevel, «IF targets('3.0')»int «ENDIF»$userId = null)«IF targets('3.0')»: array«ENDIF»
            {
                $filteredEntities = [];
                foreach ($entities as $entity) {
                    if (!$this->hasEntityPermission($entity, $permissionLevel, $userId)) {
                        continue;
                    }
                    $filteredEntities[] = $entity;
                }

                return $filteredEntities;
            }
        «ENDIF»
    '''

    def private hasEntitiesInheritingPermissions(Application it) {
        !getEntitiesInheritingPermissions.empty
    }

    def private getEntitiesInheritingPermissions(Application it) {
        getAllEntities.filter[!getBidirectionalIncomingPermissionInheriters.empty]
    }

    def dispatch private inheritedPermissionCheck(Entity it, JoinRelationship relation) '''
        if (null !== $entity->get«relation.getRelationAliasName(false).formatForCodeCapital»()) {
            $parent = $entity->get«relation.getRelationAliasName(false).formatForCodeCapital»();
            if (!$this->hasEntityPermission($parent, $permissionLevel, $userId)) {
                return false;
            }
        }
    '''

    def dispatch private inheritedPermissionCheck(Entity it, ManyToManyRelationship relation) '''
        «IF relation.inheritPermissions == ManyToManyPermissionInheritanceType.AFFIRMATIVE»
            $parentAccess = false;
        «ENDIF»
        foreach ($entity->get«relation.getRelationAliasName(false).formatForCodeCapital»() as $parent) {
            «IF relation.inheritPermissions == ManyToManyPermissionInheritanceType.AFFIRMATIVE»
                if ($this->hasEntityPermission($parent, $permissionLevel, $userId)) {
                    $parentAccess = true;
                    break;
                }
            «ELSEIF ManyToManyPermissionInheritanceType.UNANIMOUS == relation.inheritPermissions»
                if (!$this->hasEntityPermission($parent, $permissionLevel, $userId)) {
                    return false;
                }
            «ENDIF»
        }
        «IF ManyToManyPermissionInheritanceType.AFFIRMATIVE == relation.inheritPermissions»
            if (true !== $parentAccess) {
                return false;
            }
        «ENDIF»
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
            return $this->permissionApi->hasPermission(
                '«appName»:' . ucfirst($objectType) . ':',
                '::',
                $permissionLevel,
                $userId
            );
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
            return $this->permissionApi->hasPermission(
                '«appName»::',
                '::',
                $permissionLevel,
                $userId
            );
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
