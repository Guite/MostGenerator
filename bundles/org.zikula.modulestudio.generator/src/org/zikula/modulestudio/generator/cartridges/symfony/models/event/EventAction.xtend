package org.zikula.modulestudio.generator.cartridges.symfony.models.event

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EventAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    String entityVar

    new(String entityVar) {
        this.entityVar = entityVar
    }

    def postLoad(Application it) '''
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

                $repository = $this->entityManager->getRepository(«entityVar»->getObjectClass());
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

    def preRemove(Application it) '''
    '''

    def postRemove(Application it) '''

        $objectType = «entityVar»->get_objectType();
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
}
