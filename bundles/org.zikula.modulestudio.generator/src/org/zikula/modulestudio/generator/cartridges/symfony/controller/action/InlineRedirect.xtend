package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class InlineRedirect extends AbstractAction {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    override name(Application it) {
        'HandleInlineRedirect'
    }

    override requiredFor(Entity it) {
        hasEditAction && application.needsInlineEditing
    }

    override protected imports(Application it) {
        #[
            'Doctrine\\Persistence\\ManagerRegistry',
            'Symfony\\Bundle\\FrameworkBundle\\Controller\\ControllerHelper',
            'Symfony\\Component\\HttpFoundation\\Request',
            'Symfony\\Component\\HttpFoundation\\Response',
            'Zikula\\CoreBundle\\Response\\PlainResponse',
            appNamespace + '\\Helper\\EntityDisplayHelper'
        ]
    }

    override protected constructorArguments(Application it) {
        #[
            'ControllerHelper $controllerHelper',
            'ManagerRegistry $managerRegistry',
            'EntityDisplayHelper $entityDisplayHelper'
        ]
    }

    override protected invocationArguments(Application it, Boolean call) {
        val result = <String>newArrayList
        result.add('Request $request')
        if (call) {
            result.add('string $objectType')
        }
        result
    }

    override protected docBlock(Application it) '''
        /**
         * This method cares for a redirect within an inline frame.
         */
    '''

    override protected returnType(Application it) { 'Response' }

    override protected controllerPreprocessing(Entity it) '''
        $objectType = '«name.formatForCode»';

    '''

    override protected routeMethods(Entity it) '''['GET']'''

    override protected implBody(Application it) '''
        $commandName = $request->request->get('commandName');
        $id = $request->request->get('id');
        if (empty($id)) {
            return false;
        }

        $titleFieldName = $this->entityDisplayHelper->getTitleFieldName($objectType);
        «entityMatchBlock(entities.filter[hasEditAction])»

        $formattedTitle = '';
        $searchTerm = '';
        if ('' !== $titleFieldName && !empty($id)) {
            $repository = $this->managerRegistry->getRepository($entityFqcn);
            «IF hasSluggable»
                $entity = null;
                if (in_array($objectType, ['«entities.filter[hasSluggableFields].map[name.formatForCode].join('\', \'')»'], true)) {
                    $entity = $repository->selectBySlug($id);
                }
                if (null === $entity) {
                    $entity = $repository->selectById($id);
                }
            «ELSE»
                $entity = $repository->selectById($id);
            «ENDIF»
            if (null !== $entity) {
                $formattedTitle = $this->entityDisplayHelper->getFormattedTitle($entity);
                $titleGetter = 'get' . ucfirst($titleFieldName);
                $searchTerm = $entity->$titleGetter();
            }
        }

        $templateParameters = [
            'itemId' => $id,
            'formattedTitle' => $formattedTitle,
            'searchTerm' => $searchTerm,
            'idPrefix' => $idPrefix,
            'commandName' => $commandName,
        ];

        return new PlainResponse(
            $this->controllerHelper->renderView('@«vendorAndName»/' . ucfirst($objectType) . '/inlineRedirectHandler.html.twig', $templateParameters)
        );
    '''
}
