package org.zikula.modulestudio.generator.cartridges.symfony.controller.subscriber

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class FileUploadSubscriber {

    extension ModelExtensions = new ModelExtensions

    def generate(Application it) '''
        public function __construct(
            protected readonly UploadHelper $uploadHelper
        ) {
        }

        public static function getSubscribedEvents(): array
        {
            return [
                UploadEvents::PRE_UPLOAD => 'onPreUpload',
                UploadEvents::POST_UPLOAD => 'onPostUpload',
                UploadEvents::PRE_INJECT => 'onPreInject',
                UploadEvents::POST_INJECT => 'onPostInject',
                UploadEvents::PRE_REMOVE => 'onPreRemove',
                UploadEvents::POST_REMOVE => 'onPostRemove',
                UploadEvents::UPLOAD_ERROR => 'onUploadError',
                UploadEvents::REMOVE_ERROR => 'onRemoveError',
            ];
        }

        /**
         * Subscriber for the `vich_uploader.pre_upload` event.
         *
         * Occurs before a file upload is handled.
         */
        public function onPreUpload(UploadEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getObject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
            «IF hasUploads»

                $mapping = $event->getMapping();
                $file = $mapping->getFile($entity);

                if (!$file instanceof UploadedFile || !$file->isReadable()) {
                    return;
                }

                $fieldName = $mapping->getFilePropertyName();

                // apply custom processing
                $tempFilePath = $this->uploadHelper->polishUploadedFile($file, $entity->get_objectType(), $fieldName);

                // set new File instance so Vich will persist this one
                $mapping->setFile($entity, new EmbeddedFile($tempFilePath));
            «ENDIF»
        }

        /**
         * Subscriber for the `vich_uploader.post_upload` event.
         *
         * Occurs right after a file upload is handled.
         */
        public function onPostUpload(UploadEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getObject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `vich_uploader.pre_inject` event.
         *
         * Occurs before a file is injected into an entity.
         */
        public function onPreInject(UploadEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getObject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `vich_uploader.post_inject` event.
         *
         * Occurs after a file is injected into an entity.
         */
        public function onPostInject(UploadEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getObject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `vich_uploader.pre_remove` event.
         *
         * Occurs before a file is removed.
         */
        public function onPreRemove(UploadEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getObject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `vich_uploader.post_remove` event.
         *
         * Occurs after a file is removed.
         */
        public function onPostRemove(UploadEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getObject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `vich_uploader.upload_error` event.
         *
         * Occurs if writing to storage fails.
         */
        public function onUploadError(UploadErrorEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getObject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `vich_uploader.remove_error` event.
         *
         * Occurs if removing the file from storage fails.
         */
        public function onRemoveError(UploadErrorEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getObject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        «isEntityManagedByThisBundle»
    '''

    def private isEntityManagedByThisBundle(Application it) '''
        /**
         * Checks whether this subscriber is responsible for the given entity or not.
         */
        protected function isEntityManagedByThisBundle(object $entity): bool
        {
            return $entity instanceof EntityInterface;
        }
    '''
}
