package org.zikula.modulestudio.generator.cartridges.symfony.models.event

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EventAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    String entityVar

    new(String entityVar) {
        this.entityVar = entityVar
    }

    def postLoad(Application it) '''
        «IF !getUploadEntities.empty»

            // prepare helper fields for uploaded files
            $uploadFields = $this->getUploadFields(«entityVar»->get_objectType());
            if (0 < count($uploadFields)) {
                $request = $this->requestStack->getCurrentRequest();
                $baseUrl = $request->getSchemeAndHttpHost() . $request->getBasePath();

                $uploadBaseDirectory = $this->uploadHelper->getFileBaseFolder(«entityVar»->get_objectType());
                if ('/public' !== mb_substr($uploadBaseDirectory, -7)) {
                    «entityVar»->set_uploadBasePathRelative(mb_substr($uploadBaseDirectory, 7));
                } else {
                    «entityVar»->set_uploadBasePathRelative($uploadBaseDirectory);
                }
                «entityVar»->set_uploadBasePathAbsolute($this->projectDir . '/' . $uploadBaseDirectory);
                «entityVar»->set_uploadBaseUrl($baseUrl);

                // determine meta data if it does not exist
                foreach ($uploadFields as $fieldName) {
                    $getter = 'get' . ucfirst($fieldName);
                    $fileName = «entityVar»->$getter();
                    if (empty($fileName)) {
                        continue;
                    }

                    $getter = 'get' . ucfirst($fieldName) . 'Meta';
                    $metaData = «entityVar»->$getter();
                    if (is_array($metaData) && count($metaData)) {
                        continue;
                    }

                    $basePath = $this->uploadHelper->getFileBaseFolder(«entityVar»->get_objectType(), $fieldName);
                    $filePath = $this->projectDir . '/' . $basePath . $fileName;
                    if (!file_exists($filePath)) {
                        continue;
                    }

                    $setter = 'set' . ucfirst($fieldName) . 'Meta';
                    «entityVar»->$setter($this->uploadHelper->readMetaDataForFile($fileName, $filePath));
                }
            }
        «ENDIF»
    '''

    def prePersist(Application it) '''
        «IF hasLoggable»

            if («entityVar» instanceof AbstractLogEntry) {
                // check if a supported object has been undeleted
                if ('create' !== «entityVar»->getAction()) {
                    return;
                }

                // select main entity
                if (null === «entityVar»->getObjectId()) {
                    return;
                }

                $entityManager = $this->entityFactory->getEntityManager();
                $repository = $entityManager->getRepository(«entityVar»->getObjectClass());
                $object = $repository->find(«entityVar»->getObjectId());
                if (null === $object || !method_exists($object, 'get_objectType')) {
                    return;
                }

                // set correct version after undeletion
                $logVersion = «entityVar»->getVersion();
                «FOR entity : getLoggableEntities»
                    if ('«entity.name.formatForCode»' === $object->get_objectType() && method_exists($object, 'get«entity.getVersionField.name.formatForCodeCapital»')) {
                        if ($logVersion < $object->get«entity.getVersionField.name.formatForCodeCapital»()) {
                            «entityVar»->setVersion($object->get«entity.getVersionField.name.formatForCodeCapital»());
                        }
                    }
                «ENDFOR»

                return;
            }
        «ENDIF»
    '''

    def postPersist(Application it) '''

        $logArgs = [
            'app' => '«appName»',
            'user' => $this->security->getUser()?->getUserIdentifier(),
            'entity' => «entityVar»->get_objectType(),
            'id' => «entityVar»->getKey(),
        ];
        $this->logger->debug('{app}: User {user} created the {entity} with id {id}.', $logArgs);
        «IF hasLoggable»

            $this->purgeHistory(«entityVar»->get_objectType());
        «ENDIF»
    '''

    def preRemove(Application it) '''
    '''

    def postRemove(Application it) '''

        $objectType = «entityVar»->get_objectType();
        «IF !getUploadEntities.empty»

            $uploadFields = $this->getUploadFields($objectType);
            if (0 < count($uploadFields)) {
                foreach ($uploadFields as $fieldName) {
                    $getter = 'get' . ucfirst($fieldName);
                    $uploadFile = «entityVar»->$getter();
                    if (empty($uploadFile)) {
                        continue;
                    }

                    // remove upload file
                    $this->uploadHelper->deleteUploadFile(«entityVar», $fieldName);
                }
            }
        «ENDIF»
        «IF hasLoggable»

            $this->purgeHistory($objectType);
        «ENDIF»

        $logArgs = [
            'app' => '«appName»',
            'user' => $this->security->getUser()?->getUserIdentifier(),
            'entity' => $objectType,
            'id' => «entityVar»->getKey(),
        ];
        $this->logger->debug('{app}: User {user} removed the {entity} with id {id}.', $logArgs);
    '''

    def preUpdate(Application it) '''
    '''

    def postUpdate(Application it) '''

        $logArgs = [
            'app' => '«appName»',
            'user' => $this->security->getUser()?->getUserIdentifier(),
            'entity' => «entityVar»->get_objectType(),
            'id' => «entityVar»->getKey(),
        ];
        $this->logger->debug('{app}: User {user} updated the {entity} with id {id}.', $logArgs);
        «IF hasLoggable»

            $this->purgeHistory(«entityVar»->get_objectType());
        «ENDIF»
    '''
}
