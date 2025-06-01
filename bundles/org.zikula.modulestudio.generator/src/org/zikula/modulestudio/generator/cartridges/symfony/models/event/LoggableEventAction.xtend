package org.zikula.modulestudio.generator.cartridges.symfony.models.event

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableEventAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        «purgeHistory»

        «activateCustomLoggableListener»
    '''

    def private purgeHistory(Application it) '''
        /**
         * Purges the version history as configured.
         */
        protected function purgeHistory(string $objectType = ''): void
        {
            if (!in_array($objectType, ['«getLoggableEntities.map[name.formatForCode].join('\', \'')»'])) {
                return;
            }

            $entityManager = $this->entityFactory->getEntityManager();
            $configSuffix = s($objectType)->snake();

            $revisionHandling = $this->loggableConfig['revision_handling_for_' . $configSuffix];
            $limitParameter = '';
            if ('limitedByAmount' === $revisionHandling) {
                $limitParameter = $this->loggableConfig['maximum_amount_of_' . $configSuffix . '_revisions'];
            } elseif ('limitedByDate' === $revisionHandling) {
                $limitParameter = $this->loggableConfig['period_for_' . $configSuffix . '_revisions'];
            }

            $logEntriesRepository = $entityManager->getRepository(
                '«appName»:' . $objectTypeCapitalised . 'LogEntryEntity'
            );
            $logEntriesRepository->purgeHistory($revisionHandling, $limitParameter);
        }
    '''

    def private activateCustomLoggableListener(Application it) '''
        /**
         * Enables the custom loggable listener.
         */
        protected function activateCustomLoggableListener(): void
        {
            $entityManager = $this->entityFactory->getEntityManager();
            $eventManager = $entityManager->getEventManager();
            $customLoggableListener = $this->loggableListener;

            «IF hasTranslatable»
                $hasLoggableActivated = false;
            «ENDIF»
            foreach ($eventManager->getListeners() as $event => $listeners) {
                foreach ($listeners as $hash => $listener) {
                    if (is_object($listener) && 'Gedmo\Loggable\LoggableListener' === $listener::class) {
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

            «/* TODO remove me
            $userName = $this->security->getUser()?->getUserIdentifier() ?? 'Guest';
            $customLoggableListener->setUsername($userName);

            */»
            $eventManager->addEventSubscriber($customLoggableListener);
        }
    '''
}
