package org.zikula.modulestudio.generator.cartridges.zclassic.models.event

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LifecycleListener {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app
    EventAction eventAction = new EventAction('$entity')

    def generate(Application it, IMostFileSystemAccess fsa) {
        app = it
        fsa.generateClassPair('Listener/EntityLifecycleListener.php', lifecycleListenerBaseImpl, lifecycleListenerImpl)
    }

    def private lifecycleListenerBaseImpl(Application it) '''
        namespace «appNamespace»\Listener\Base;

        use Doctrine\Common\EventSubscriber;
        use Doctrine\ORM\Event\OnFlushEventArgs;
        use Doctrine\ORM\Event\PostFlushEventArgs;
        use Doctrine\ORM\Event\PreFlushEventArgs;
        use Doctrine\ORM\Event\PreUpdateEventArgs;
        use Doctrine\ORM\Events;
        use Doctrine\Persistence\Event\LifecycleEventArgs;
        «IF hasLoggable»
            use Gedmo\Loggable\Entity\MappedSuperclass\AbstractLogEntry;
        «ENDIF»
        use Psr\Log\LoggerInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Symfony\Component\DependencyInjection\ContainerInterface;
        use Symfony\Contracts\EventDispatcher\EventDispatcherInterface;
        use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
        «IF !getUploadEntities.empty»
            use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
        «ENDIF»
        «IF hasLoggable»
            use Zikula\ExtensionsModule\Api\VariableApi;
        «ENDIF»
        use Zikula\UsersModule\Api\CurrentUserApi;
        «IF hasLoggable»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        «IF hasLoggable»
            use «appNamespace»\Entity\Factory\EntityFactory;
        «ENDIF»
        «IF !getUploadEntities.empty»
            use «appNamespace»\Helper\UploadHelper;
        «ENDIF»
        «IF hasLoggable»
            use «appNamespace»\Listener\LoggableListener;
        «ENDIF»

        /**
         * Event subscriber base class for entity lifecycle events.
         */
        abstract class AbstractEntityLifecycleListener implements EventSubscriber, ContainerAwareInterface
        {
            use ContainerAwareTrait;

            «IF !getUploadEntities.empty»
                /**
                 * @var ZikulaHttpKernelInterface
                 */
                protected $kernel;

            «ENDIF»
            /**
             * @var EventDispatcherInterface
             */
            protected $eventDispatcher;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            public function __construct(
                «IF !getUploadEntities.empty»
                    ZikulaHttpKernelInterface $kernel,
                «ENDIF»
                ContainerInterface $container,
                EventDispatcherInterface $eventDispatcher,
                LoggerInterface $logger
            ) {
                «IF !getUploadEntities.empty»
                    $this->kernel = $kernel;
                «ENDIF»
                $this->setContainer($container);
                $this->eventDispatcher = $eventDispatcher;
                $this->logger = $logger;
            }

            /**
             * Returns list of events to subscribe.
             *
             * @return string[] List of events
             */
            public function getSubscribedEvents(): array
            {
                return [
                    Events::preFlush,
                    Events::onFlush,
                    Events::postFlush,
                    Events::preRemove,
                    Events::postRemove,
                    Events::prePersist,
                    Events::postPersist,
                    Events::preUpdate,
                    Events::postUpdate,
                    Events::postLoad,
                ];
            }

            /**
             * The preFlush event is called at EntityManager#flush() before anything else.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#preflush
             */
            public function preFlush(PreFlushEventArgs $args): void
            {
                «IF hasLoggable»
                    $this->activateCustomLoggableListener();
                «ENDIF»
            }

            /**
             * The onFlush event is called inside EntityManager#flush() after the changes to all the
             * managed entities and their associations have been computed.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#onflush
             */
            public function onFlush(OnFlushEventArgs $args): void
            {
            }

            /**
             * The postFlush event is called at the end of EntityManager#flush().
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#postflush
             */
            public function postFlush(PostFlushEventArgs $args): void
            {
            }

            /**
             * The preRemove event occurs for a given entity before the respective EntityManager
             * remove operation for that entity is executed. It is not called for a DQL DELETE statement.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#preremove
             */
            public function preRemove(LifecycleEventArgs $args): void
            {
                /** @var EntityAccess $entity */
                $entity = $args->getObject();
                if (
                    !$this->isEntityManagedByThisBundle($entity)
                    || !method_exists($entity, 'get_objectType')
                ) {
                    return;
                }
                «eventAction.preRemove(app)»
            }

            /**
             * The postRemove event occurs for an entity after the entity has been deleted. It will be
             * invoked after the database delete operations. It is not called for a DQL DELETE statement.
             *
             * Note that the postRemove event or any events triggered after an entity removal can receive
             * an uninitializable proxy in case you have configured an entity to cascade remove relations.
             * In this case, you should load yourself the proxy in the associated pre event.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#postupdate-postremove-postpersist
             */
            public function postRemove(LifecycleEventArgs $args): void
            {
                /** @var EntityAccess $entity */
                $entity = $args->getObject();
                if (
                    !$this->isEntityManagedByThisBundle($entity)
                    || !method_exists($entity, 'get_objectType')
                ) {
                    return;
                }
                «eventAction.postRemove(app)»
            }

            /**
             * The prePersist event occurs for a given entity before the respective EntityManager
             * persist operation for that entity is executed. It should be noted that this event
             * is only triggered on initial persist of an entity (i.e. it does not trigger on future updates).
             *
             * Doctrine will not recognize changes made to relations in a prePersist event.
             * This includes modifications to collections such as additions, removals or replacement.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#prepersist
             */
            public function prePersist(LifecycleEventArgs $args): void
            {
                /** @var EntityAccess $entity */
                $entity = $args->getObject();
                if (
                    !$this->isEntityManagedByThisBundle($entity)
                    || «IF hasLoggable»(!method_exists($entity, 'get_objectType') && !$entity instanceof AbstractLogEntry)«ELSE»!method_exists($entity, 'get_objectType')«ENDIF»
                ) {
                    return;
                }
                «eventAction.prePersist(app)»
            }

            /**
             * The postPersist event occurs for an entity after the entity has been made persistent.
             * It will be invoked after the database insert operations. Generated primary key values
             * are available in the postPersist event.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#postupdate-postremove-postpersist
             */
            public function postPersist(LifecycleEventArgs $args): void
            {
                /** @var EntityAccess $entity */
                $entity = $args->getObject();
                if (
                    !$this->isEntityManagedByThisBundle($entity)
                    || !method_exists($entity, 'get_objectType')
                ) {
                    return;
                }
                «eventAction.postPersist(app)»
            }

            /**
             * The preUpdate event occurs before the database update operations to entity data.
             * It is not called for a DQL UPDATE statement nor when the computed changeset is empty.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#preupdate
             */
            public function preUpdate(PreUpdateEventArgs $args): void
            {
                /** @var EntityAccess $entity */
                $entity = $args->getObject();
                if (
                    !$this->isEntityManagedByThisBundle($entity)
                    || !method_exists($entity, 'get_objectType')
                ) {
                    return;
                }
                «eventAction.preUpdate(app)»
            }

            /**
             * The postUpdate event occurs after the database update operations to entity data.
             * It is not called for a DQL UPDATE statement.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#postupdate-postremove-postpersist
             */
            public function postUpdate(LifecycleEventArgs $args): void
            {
                /** @var EntityAccess $entity */
                $entity = $args->getObject();
                if (
                    !$this->isEntityManagedByThisBundle($entity)
                    || !method_exists($entity, 'get_objectType')
                ) {
                    return;
                }
                «eventAction.postUpdate(app)»
            }

            /**
             * The postLoad event occurs for an entity after the entity has been loaded into the current
             * EntityManager from the database or after the refresh operation has been applied to it.
             *
             * Note that, when using Doctrine\ORM\AbstractQuery#iterate(), postLoad events will be executed
             * immediately after objects are being hydrated, and therefore associations are not guaranteed
             * to be initialized. It is not safe to combine usage of Doctrine\ORM\AbstractQuery#iterate()
             * and postLoad event handlers.
             *
             * @see https://www.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#postload
             */
            public function postLoad(LifecycleEventArgs $args): void
            {
                /** @var EntityAccess $entity */
                $entity = $args->getObject();
                if (
                    !$this->isEntityManagedByThisBundle($entity)
                    || !method_exists($entity, 'get_objectType')
                ) {
                    return;
                }
                «eventAction.postLoad(app)»
            }

            /**
             * Checks whether this listener is responsible for the given entity or not.
             */
            protected function isEntityManagedByThisBundle(object $entity): bool
            {
                $entityClassParts = explode('\\', get_class($entity));

                if ('DoctrineProxy' === $entityClassParts[0] && '__CG__' === $entityClassParts[1]) {
                    array_shift($entityClassParts);
                    array_shift($entityClassParts);
                }

                return '«vendor.formatForCodeCapital»' === $entityClassParts[0]
                    && '«name.formatForCodeCapital»Module' === $entityClassParts[1]
                ;
            }

            /**
             * Returns a filter event instance for the given entity.
             */
            protected function createFilterEvent(EntityAccess $entity, string $classSuffix = '')
            {
                $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\' . ucfirst($entity->get_objectType()) . $classSuffix . 'Event';

                return new $filterEventClass($entity);
            }
            «IF !getUploadEntities.empty»

                /**
                 * Returns list of upload fields for the given object type.
                 *
                 * @return string[] List of upload field names
                 */
                protected function getUploadFields(string $objectType = ''): array
                {
                    $uploadFields = [];
                    switch ($objectType) {
                        «FOR entity : getUploadEntities»
                            case '«entity.name.formatForCode»':
                                $uploadFields = ['«entity.getUploadFieldsEntity.map[name.formatForCode].join('\', \'')»'];
                                break;
                        «ENDFOR»
                    }

                    return $uploadFields;
                }
            «ENDIF»
            «IF hasLoggable»

                /**
                 * Purges the version history as configured.
                 */
                protected function purgeHistory(string $objectType = ''): void
                {
                    if (!in_array($objectType, ['«getLoggableEntities.map[name.formatForCode].join('\', \'')»'])) {
                        return;
                    }

                    $entityManager = $this->container->get(EntityFactory::class)->getEntityManager();
                    $variableApi = $this->container->get(VariableApi::class);
                    $objectTypeCapitalised = ucfirst($objectType);

                    $revisionHandling = $variableApi->get(
                        '«appName»',
                        'revisionHandlingFor' . $objectTypeCapitalised,
                        'unlimited'
                    );
                    $limitParameter = '';
                    if ('limitedByAmount' === $revisionHandling) {
                        $limitParameter = $variableApi->get(
                            '«appName»',
                            'maximumAmountOf' . $objectTypeCapitalised . 'Revisions',
                            25
                        );
                    } elseif ('limitedByDate' === $revisionHandling) {
                        $limitParameter = $variableApi->get(
                            '«appName»',
                            'periodFor' . $objectTypeCapitalised . 'Revisions',
                            'P1Y0M0DT0H0M0S'
                        );
                    }

                    $logEntriesRepository = $entityManager->getRepository(
                        '«appName»:' . $objectTypeCapitalised . 'LogEntryEntity'
                    );
                    $logEntriesRepository->purgeHistory($revisionHandling, $limitParameter);
                }

                /**
                 * Enables the custom loggable listener.
                 */
                protected function activateCustomLoggableListener(): void
                {
                    $entityManager = $this->container->get(EntityFactory::class)->getEntityManager();
                    $eventManager = $entityManager->getEventManager();
                    $customLoggableListener = $this->container->get(LoggableListener::class);

                    «IF hasTranslatable»
                        $hasLoggableActivated = false;
                    «ENDIF»
                    foreach ($eventManager->getListeners() as $event => $listeners) {
                        foreach ($listeners as $hash => $listener) {
                            if (is_object($listener) && 'Gedmo\Loggable\LoggableListener' === get_class($listener)) {
                                $eventManager->removeEventSubscriber($listener);
                                «IF hasTranslatable»
                                    $hasLoggableActivated = true;
                                «ENDIF»
                                break 2;
                            }
                        }
                    }
                    «IF hasTranslatable»

                        if (!$hasLoggableActivated) {
                            // translations are persisted, so we temporarily disable loggable listener
                            // to avoid creating unrequired log entries for the main entity
                            return;
                        }
                    «ENDIF»

                    $variableApi = $this->container->get(VariableApi::class);
                    $currentUserApi = $this->container->get(CurrentUserApi::class);
                    $userName = $currentUserApi->isLoggedIn()
                        ? $currentUserApi->get('uname')
                        : $variableApi->get(UsersConstant::MODNAME, UsersConstant::MODVAR_ANONYMOUS_DISPLAY_NAME, 'Guest')
                    ;

                    $customLoggableListener->setUsername($userName);

                    $eventManager->addEventSubscriber($customLoggableListener);
                }
            «ENDIF»
        }
    '''

    def private lifecycleListenerImpl(Application it) '''
        namespace «appNamespace»\Listener;

        use «appNamespace»\Listener\Base\AbstractEntityLifecycleListener;

        /**
         * Event subscriber implementation class for entity lifecycle events.
         */
        class EntityLifecycleListener extends AbstractEntityLifecycleListener
        {
            // feel free to enhance this listener by custom actions
        }
    '''
}
