package org.zikula.modulestudio.generator.cartridges.symfony.models.event

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions

class SluggableEventAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    def generate(Application it) '''
        «maybeResetSlug»
    '''

    def private maybeResetSlug(Application it) '''
        /**
         * Resets slug of given entity to let Gedmo regenerate it if needed.
         */
        protected function maybeResetSlug(EntityInterface $entity): void
        {
            $objectType = $entity->get_objectType();
            if (!in_array($objectType, ['«getSluggableEntities.map[name.formatForCode].join('\', \'')»'])) {
                return;
            }

            $slug = $entity->getSlug();

            // set slug to null if it is an empty slug so Gedmo generates a fresh one
            if (null === $slug || '' === $slug) {
                $entity->setSlug(null);

                return;
            }

            // slug exists but maybe is not unique?
            $idField = $this->entityManager->getClassMetadata($entity::class)->getSingleIdentifierFieldName();
            $repository = $this->entityManager->getRepository($entity::class);

            $qb = $repository->createQueryBuilder('e');
            $count = $qb->select('count(e.' . $idField . ')')
                ->where('e.slug = :slug')
                ->andWhere('e.' . $idField . ' != :' . $idField . '')
                ->setParameter('slug', $slug)
                ->setParameter($idField, $entity->getKey() ?? 0)
                ->getQuery()
                ->getSingleScalarResult();
            
            if (0 < $count) {
                // slug is not unique -> reset to force regeneration
                $entity->setSlug(null);
            }
        }
    '''
}
