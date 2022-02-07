package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class IncreaseCounter {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it) {
        increaseCounterImpl
    }

    def private increaseCounterImpl(Application it) '''
        /**
         * The «appName.formatForDB»_increaseCounter function increases a counter field of a specific entity.
         * It uses Doctrine DBAL to avoid creating a new loggable version, sending workflow notification or executing other unwanted actions.
         * Example:
         *     {{ «appName.formatForDB»_increaseCounter(«getEntitiesWithCounterFields.head.name.formatForCode», '«getEntitiesWithCounterFields.head.getCounterFields.head.name.formatForCode»') }}.
         */
        public function increaseCounter(EntityInterface $entity, string $fieldName = ''): void
        {
            $entityId = $entity->getId();
            $objectType = $entity->get_objectType();

            // check against session to see if user was already counted
            $request = $this->requestStack->getCurrentRequest();
            $doCount = true;
            if (null !== $request && $request->hasSession() && $session = $request->getSession()) {
                if ($session->has('«appName»Read' . $objectType . $entityId)) {
                    $doCount = false;
                } else {
                    $session->set('«appName»Read' . $objectType . $entityId, 1);
                }
            }
            if (!$doCount) {
                return;
            }

            $getter = 'get' . ucfirst($fieldName);
            $counterValue = $entity->$getter() + 1;

            $this->databaseConnection->update(
                '«vendor.formatForDB + '_' + prefix()»_' . mb_strtolower($objectType),
                [$fieldName => $counterValue],
                ['id' => $entityId]
            );
        }
    '''
}
