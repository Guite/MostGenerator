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
        use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
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
        public function __construct(
            protected RequestStack $requestStack,
            protected PermissionApiInterface $permissionApi,
            «IF hasLoggable»
                protected VariableApiInterface $variableApi,
            «ENDIF»
            protected CurrentUserApiInterface $currentUserApi,
            protected UserRepositoryInterface $userRepository«IF hasCategorisableEntities»,
            protected FeatureActivationHelper $featureActivationHelper,
            protected CategoryHelper $categoryHelper«ENDIF»
        ) {
        }

        «accessMethods»

        «helperMethods»
    '''

    def private accessMethods(Application it) '''
        /**
         * Checks if the given entity instance may be read.
         */
        public function mayRead(EntityAccess $entity, ?int $userId = null): bool
        {
            return $this->hasEntityPermission($entity, ACCESS_READ, $userId);
        }

        /**
         * Checks if the given entity instance may be edited.
         */
        public function mayEdit(EntityAccess $entity, ?int $userId = null): bool
        {
            return $this->hasEntityPermission($entity, ACCESS_EDIT, $userId);
        }
        «IF hasLoggable»

            /**
             * Checks if the given entity instance may be deleted.
             */
            public function mayAccessHistory(EntityAccess $entity, ?int $userId = null): bool
            {
                $objectType = $entity->get_objectType();

                return $this->mayEdit($entity, $userId) && $this->mayUseHistory($objectType, $userId);
            }
        «ENDIF»

        /**
         * Checks if the given entity instance may be deleted.
         */
        public function mayDelete(EntityAccess $entity, ?int $userId = null): bool
        {
            return $this->hasEntityPermission($entity, ACCESS_DELETE, $userId);
        }

        /**
         * Checks if a certain permission level is granted for the given entity instance.
         */
        public function hasEntityPermission(EntityAccess $entity, int $permissionLevel, ?int $userId = null): bool
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
             * @param array|ArrayCollection $entities The given list of entities
             */
            public function filterCollection(«IF !isSystemModule»$objectType, «ENDIF»$entities, int $permissionLevel, ?int $userId = null): array
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
         */
        public function hasComponentPermission(string $objectType, int $permissionLevel, ?int $userId = null): bool
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
             */
            public function mayUseQuickNav(string $objectType, ?int $userId = null): bool
            {
                return $this->hasComponentPermission($objectType, ACCESS_READ, $userId);
            }
        «ENDIF»
        «IF hasLoggable»

            /**
             * Checks if the history for a given object type may be used or not.
             */
            public function mayUseHistory(string $objectType, ?int $userId = null): bool
            {
                return $this->variableApi->get('«appName»', 'show' . ucfirst($objectType) . 'History', true);
            }
        «ENDIF»

        /**
         * Checks if a certain permission level is granted for the application in general.
         */
        public function hasPermission(int $permissionLevel, ?int $userId = null): bool
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
        public function getUserGroupIds(): array
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
         */
        public function getUserId(): int
        {
            return (int) $this->currentUserApi->get('uid');
        }

        /**
         * Returns the the current user's entity.
         */
        public function getUser(): UserEntity
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
