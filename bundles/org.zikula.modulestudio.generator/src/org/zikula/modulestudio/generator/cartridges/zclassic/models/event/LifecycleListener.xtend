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
        use Doctrine\Common\Persistence\Event\LifecycleEventArgs;
        use Doctrine\ORM\Event\PreUpdateEventArgs;
        use Doctrine\ORM\Events;
        «IF hasLoggable»
            use Gedmo\Loggable\Entity\MappedSuperclass\AbstractLogEntry;
        «ENDIF»
        use Psr\Log\LoggerInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Symfony\Component\DependencyInjection\ContainerInterface;
        use Symfony\Component\EventDispatcher\Event;
        use Symfony\Component\EventDispatcher\EventDispatcherInterface;
        use Zikula\Core\Doctrine\EntityAccess;
        use «appNamespace»\«name.formatForCodeCapital»Events;
        «FOR entity : getAllEntities»
            use «appNamespace»\Event\Filter«entity.name.formatForCodeCapital»Event;
        «ENDFOR»

        /**
         * Event subscriber base class for entity lifecycle events.
         */
        abstract class AbstractEntityLifecycleListener implements EventSubscriber, ContainerAwareInterface
        {
            use ContainerAwareTrait;

            /**
             * @var EventDispatcherInterface
             */
            protected $eventDispatcher;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * EntityLifecycleListener constructor.
             *
             * @param ContainerInterface       $container
             * @param EventDispatcherInterface $eventDispatcher EventDispatcher service instance
             * @param LoggerInterface          $logger          Logger service instance
             */
            public function __construct(
                ContainerInterface $container,
                EventDispatcherInterface $eventDispatcher,
                LoggerInterface $logger
            ) {
                $this->setContainer($container);
                $this->eventDispatcher = $eventDispatcher;
                $this->logger = $logger;
            }

            /**
             * Returns list of events to subscribe.
             *
             * @return string[] List of events
             */
            public function getSubscribedEvents()
            {
                return [
                    Events::preRemove,
                    Events::postRemove,
                    Events::prePersist,
                    Events::postPersist,
                    Events::preUpdate,
                    Events::postUpdate,
                    Events::postLoad
                ];
            }

            /**
             * The preRemove event occurs for a given entity before the respective EntityManager
             * remove operation for that entity is executed. It is not called for a DQL DELETE statement.
             *
             * @param LifecycleEventArgs $args Event arguments
             */
            public function preRemove(LifecycleEventArgs $args)
            {
                $entity = $args->getObject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
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
             * @param LifecycleEventArgs $args Event arguments
             */
            public function postRemove(LifecycleEventArgs $args)
            {
                $entity = $args->getObject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
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
             * @param LifecycleEventArgs $args Event arguments
             */
            public function prePersist(LifecycleEventArgs $args)
            {
                $entity = $args->getObject();
                if (!$this->isEntityManagedByThisBundle($entity) || «IF hasLoggable»(!method_exists($entity, 'get_objectType') && !$entity instanceof AbstractLogEntry)«ELSE»!method_exists($entity, 'get_objectType')«ENDIF») {
                    return;
                }
                «eventAction.prePersist(app)»
            }

            /**
             * The postPersist event occurs for an entity after the entity has been made persistent.
             * It will be invoked after the database insert operations. Generated primary key values
             * are available in the postPersist event.
             *
             * @param LifecycleEventArgs $args Event arguments
             */
            public function postPersist(LifecycleEventArgs $args)
            {
                $entity = $args->getObject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
                «eventAction.postPersist(app)»
            }

            /**
             * The preUpdate event occurs before the database update operations to entity data.
             * It is not called for a DQL UPDATE statement nor when the computed changeset is empty.
             *
             * @see http://docs.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html#preupdate
             *
             * @param PreUpdateEventArgs $args Event arguments
             */
            public function preUpdate(PreUpdateEventArgs $args)
            {
                $entity = $args->getObject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
                «eventAction.preUpdate(app)»
            }

            /**
             * The postUpdate event occurs after the database update operations to entity data.
             * It is not called for a DQL UPDATE statement.
             *
             * @param LifecycleEventArgs $args Event arguments
             */
            public function postUpdate(LifecycleEventArgs $args)
            {
                $entity = $args->getObject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
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
             * @param LifecycleEventArgs $args Event arguments
             */
            public function postLoad(LifecycleEventArgs $args)
            {
                $entity = $args->getObject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
                «eventAction.postLoad(app)»
            }

            /**
             * Checks whether this listener is responsible for the given entity or not.
             *
             * @param EntityAccess $entity The given entity
             *
             * @return boolean True if entity is managed by this listener, false otherwise
             */
            protected function isEntityManagedByThisBundle($entity)
            {
                $entityClassParts = explode('\\', get_class($entity));

                return ($entityClassParts[0] == '«vendor.formatForCodeCapital»' && $entityClassParts[1] == '«name.formatForCodeCapital»Module');
            }

            /**
             * Returns a filter event instance for the given entity.
             *
             * @param EntityAccess $entity The given entity
             *
             * @return Event The created event instance
             */
            protected function createFilterEvent($entity)
            {
                $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst($entity->get_objectType()) . 'Event';
                $event = new $filterEventClass($entity);

                return $event;
            }
            «IF !getUploadEntities.empty»

                /**
                 * Returns list of upload fields for the given object type.
                 *
                 * @param string $objectType The object type
                 *
                 * @return string[] List of upload field names
                 */
                protected function getUploadFields($objectType = '')
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
                 *
                 * @param string $objectType The object type
                 */
                protected function purgeHistory($objectType = '')
                {
                    if (!in_array($objectType, ['«getLoggableEntities.map[name.formatForCode].join('\', \'')»'])) {
                        return;
                    }

                    $entityManager = $this->container->get('«appService».entity_factory')->getObjectManager();
                    $variableApi = $this->container->get('zikula_extensions_module.api.variable');
                    $objectTypeCapitalised = ucfirst($objectType);

                    $revisionHandling = $variableApi->get('«appName»', 'revisionHandlingFor' . $objectTypeCapitalised, 'unlimited');
                    $limitParameter = '';
                    if ('limitedByAmount' == $revisionHandling) {
                        $limitParameter = $variableApi->get('«appName»', 'maximumAmountOf' . $objectTypeCapitalised . 'Revisions', 25);
                    }«IF targets('2.0')» elseif ('limitedByDate' == $revisionHandling) {
                        $limitParameter = $variableApi->get('«appName»', 'periodFor' . $objectTypeCapitalised . 'Revisions', 'P1Y0M0DT0H0M0S');
                    }«ENDIF»

                    $logEntriesRepository = $entityManager->getRepository('«appName»:' . $objectTypeCapitalised . 'LogEntryEntity');
                    $logEntriesRepository->purgeHistory($revisionHandling, $limitParameter);
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
