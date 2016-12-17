package org.zikula.modulestudio.generator.cartridges.zclassic.models.event

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

// 1.4.x only
class LifecycleListener {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app
    FileHelper fh = new FileHelper
    EventAction eventAction = new EventAction('$entity')

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            return
        }
        app = it
        generateClassPair(fsa, getAppSourceLibPath + 'Listener/EntityLifecycleListener.php',
            fh.phpFileContent(it, lifecycleListenerBaseImpl), fh.phpFileContent(it, lifecycleListenerImpl)
        )
    }

    def private lifecycleListenerBaseImpl(Application it) '''
        namespace «appNamespace»\Listener\Base;

        use Doctrine\Common\EventSubscriber;
        use Doctrine\Common\Persistence\Event\LifecycleEventArgs;
        use Doctrine\ORM\Event\PreUpdateEventArgs;
        use Doctrine\ORM\Events;
        use ServiceUtil;
        «IF hasUploads»
            use Symfony\Component\HttpFoundation\File\File;
        «ENDIF»
        use Zikula\Core\Doctrine\EntityAccess;
        use «appNamespace»\«name.formatForCodeCapital»Events;
        «FOR entity : entities»
            use «appNamespace»\Event\Filter«entity.name.formatForCodeCapital»Event;
        «ENDFOR»

        /**
         * Event subscriber base class for entity lifecycle events.
         */
        abstract class AbstractEntityLifecycleListener implements EventSubscriber
        {
            /**
             * Returns list of events to subscribe.
             *
             * @return array list of events
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
                if (!$this->isEntityManagedByThisBundle($entity)) {
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
                if (!$this->isEntityManagedByThisBundle($entity)) {
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
                if (!$this->isEntityManagedByThisBundle($entity)) {
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
                if (!$this->isEntityManagedByThisBundle($entity)) {
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
             * @param LifecycleEventArgs $args Event arguments
             */
            public function preUpdate(PreUpdateEventArgs $args)
            {
                $entity = $args->getObject();
                if (!$this->isEntityManagedByThisBundle($entity)) {
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
                if (!$this->isEntityManagedByThisBundle($entity)) {
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
                if (!$this->isEntityManagedByThisBundle($entity)) {
                    return;
                }
                «IF hasUploads»

                    // prepare helper fields for uploaded files
                    $objectType = $entity->get_objectType();
                    $controllerHelper = ServiceUtil::get('«appService».controller_helper');
                    $request = ServiceUtil::get('request_stack')->getCurrentRequest();
                    $baseUrl = $request->getSchemeAndHttpHost() . $request->getBasePath();

                    $uploadFields = [];
                    «FOR entity : getUploadEntities»
                        if ($objectType == '«entity.name.formatForCode»') {
                            $uploadFields = ['«entity.getUploadFieldsEntity.map[f|f.name.formatForCode].join("', '")»'];
                        }
                    «ENDFOR»

                    if (count($uploadFields) > 0) {
                        foreach ($uploadFields as $fieldName) {
                            if (empty($entity[$fieldName])) {
                                continue;
                            }
                            $basePath = $controllerHelper->getFileBaseFolder($objectType, $fieldName);
                            $fullPath = $basePath . $entity[$fieldName];
                            if (file_exists($fullPath)) {
                                $entity[$fieldName] = new File($fullPath);
                                $entity[$fieldName . 'Url'] = $baseUrl . '/' . $fullPath;

                                // just some backwards compatibility stuff«/*TODO remove on demand handling of upload meta data */»
                                /*if (!isset($entity[$fieldName . 'Meta']) || !is_array($entity[$fieldName . 'Meta']) || !count($entity[$fieldName . 'Meta'])) {
                                    // assign new meta data
                                    $entity[$fieldName . 'Meta'] = $uploadManager->readMetaDataForFile($entity[$fieldName], $fullPath);
                                }*/
                            } else {
                                $entity[$fieldName] = null;
                                $entity[$fieldName . 'Url'] = '';
                                $entity[$fieldName . 'Meta'] = [];
                            }
                        }
                    }
                «ENDIF»

                «eventAction.postLoad(app, null)»
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
                if (!($entity instanceof EntityAccess)) {
                    return false;
                }

                $entityClassParts = explode('\\', get_class($entity));

                return ($entityClassParts[0] == '«vendor.formatForCodeCapital»' && $entityClassParts[1] == '«name.formatForCodeCapital»Module');
            }
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
        }
    '''
}
