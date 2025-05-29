package org.zikula.modulestudio.generator.cartridges.symfony.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class PermissionHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for custom permission control'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/PermissionHelper.php', permissionHelperBaseClass, permissionHelperImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Bundle\\SecurityBundle\\Security',
            'Symfony\\Component\\HttpFoundation\\RequestStack',
            'Zikula\\GroupsBundle\\Entity\\Group',
            'Zikula\\UsersBundle\\Entity\\User',
            appNamespace + '\\Entity\\EntityInterface'
        ])
        if (hasIndexActions) {
            imports.add('ArrayIterator')
            imports.add('Doctrine\\Common\\Collections\\Collection')
        }
        imports
    }

    def private permissionHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «collectBaseImports.print»

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
            protected readonly RequestStack $requestStack,
            protected readonly Security $security«IF hasLoggable»,
            protected readonly array $loggableConfig«ENDIF»
        ) {
        }

        «accessMethods»

        «helperMethods»
    '''

    def private accessMethods(Application it) '''
        /**
         * Checks if the given entity instance may be read.
         */
        public function mayRead(EntityInterface $entity, ?int $userId = null): bool
        {
            return $this->hasEntityPermission($entity, /*ACCESS_READ, */$userId);
        }

        /**
         * Checks if the given entity instance may be edited.
         */
        public function mayEdit(EntityInterface $entity, ?int $userId = null): bool
        {
            return $this->hasEntityPermission($entity, /*ACCESS_EDIT, */$userId);
        }
        «IF hasLoggable»

            /**
             * Checks if the given entity instance may be deleted.
             */
            public function mayAccessHistory(EntityInterface $entity, ?int $userId = null): bool
            {
                $objectType = $entity->get_objectType();

                return $this->mayEdit($entity, $userId) && $this->mayUseHistory($objectType, $userId);
            }
        «ENDIF»

        /**
         * Checks if the given entity instance may be deleted.
         */
        public function mayDelete(EntityInterface $entity, ?int $userId = null): bool
        {
            return $this->hasEntityPermission($entity, /*ACCESS_DELETE, */$userId);
        }

        /**
         * Checks if a certain permission level is granted for the given entity instance.
         */
        public function hasEntityPermission(EntityInterface $entity, /*int $permissionLevel, */?int $userId = null): bool
        {
            $objectType = $entity->get_objectType();
            $instance = $entity->getKey() . '::';
            «/* TODO add custom security voters

            return $this->permissionApi->hasPermission(
                '«appName»:' . ucfirst($objectType) . ':',
                $instance,
                $permissionLevel,
                $userId
            );
            */»
            return $this->security->isGranted('ROLE_ADMIN');
        }
        «IF hasIndexActions»

            /**
             * Filters a given collection of entities based on different permission checks.
             */
            public function filterCollection(string $objectType, array|Collection|ArrayIterator $entities, /*int $permissionLevel, */?int $userId = null): array
            {
                $filteredEntities = [];
                foreach ($entities as $entity) {
                    if (!$this->hasEntityPermission($entity, /*$permissionLevel, */$userId)) {
                        continue;
                    }
                    $filteredEntities[] = $entity;
                }

                return $filteredEntities;
            }
        «ENDIF»
    '''

    def private helperMethods(Application it) '''
        /**
         * Checks if a certain permission level is granted for the given object type.
         */
        public function hasComponentPermission(string $objectType, /*int $permissionLevel, */?int $userId = null): bool
        {
            «/* TODO add custom security voters
            return $this->permissionApi->hasPermission(
                '«appName»:' . ucfirst($objectType) . ':',
                '::',
                $permissionLevel,
                $userId
            );
            */»
            return $this->security->isGranted('ROLE_ADMIN');
        }
        «IF hasIndexActions»

            /**
             * Checks if the quick navigation form for the given object type may be used or not.
             */
            public function mayUseQuickNav(string $objectType, ?int $userId = null): bool
            {
                return $this->hasComponentPermission($objectType, /*ACCESS_READ, */$userId);
            }
        «ENDIF»
        «IF hasLoggable»

            /**
             * Checks if the history for a given object type may be used or not.
             */
            public function mayUseHistory(string $objectType, ?int $userId = null): bool
            {
                $configNames = [
                    «FOR entity : loggableEntities»
                        '«entity.name.formatForCode»' => '«entity.name.formatForSnakeCase»',
                    «ENDFOR»
                ];

                return $this->loggableConfig['show_' . $configNames[$objectType] . '_history'];
            }
        «ENDIF»

        /**
         * Checks if a certain permission level is granted for the application in general.
         */
        public function hasPermission(/*int $permissionLevel, */?int $userId = null): bool
        {
            «/* TODO add custom security voters
            return $this->permissionApi->hasPermission(
                '«appName»::',
                '::',
                $permissionLevel,
                $userId
            );
            */»
            return $this->security->isGranted('ROLE_ADMIN');
        }

        /**
         * Returns the list of user group ids of the current user.
         *
         * @return int[] List of group ids
         */
        public function getUserGroupIds(): array
        {
            $currentUser = $this->security->getUser();
            if (null === $currentUser) {
                return [];
            }

            $groupIds = [];
            $groups = $currentUser->getGroups();
            /** @var Group $group */
            foreach ($groups as $group) {
                $groupIds[] = $group->getId();
            }

            return $groupIds;
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
