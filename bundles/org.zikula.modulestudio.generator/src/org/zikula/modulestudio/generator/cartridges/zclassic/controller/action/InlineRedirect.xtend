package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class InlineRedirect {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''

        «handleInlineRedirectDocBlock(isBase)»
        «handleInlineRedirectSignature»: Response {
            «IF isBase»
                «handleInlineRedirectBaseImpl»
            «ELSE»
                return parent::handleInlineRedirect«IF !application.targets('3.1')»Action«ENDIF»(
                    $entityFactory,
                    $entityDisplayHelper,
                    $idPrefix,
                    $commandName,
                    $id
                );
            «ENDIF»
        }
    '''

    def private handleInlineRedirectDocBlock(Entity it, Boolean isBase) '''
        «IF isBase»
            /**
             * This method cares for a redirect within an inline frame.
             */
        «ELSE»
            #[Route('/«name.formatForCode»/handleInlineRedirect/{idPrefix}/{commandName}/{id}',
                requirements: ['id' => '\d+'],
                defaults: ['commandName' => '', 'id' => 0],
                methods: ['GET']
            )]
        «ENDIF»
    '''

    def private handleInlineRedirectSignature(Entity it) '''
        public function handleInlineRedirect«IF !application.targets('3.1')»Action«ENDIF»(
            EntityFactory $entityFactory,
            EntityDisplayHelper $entityDisplayHelper,
            string $idPrefix,
            string $commandName,
            int $id = 0
        )'''

    def private handleInlineRedirectBaseImpl(Entity it) '''
        if (empty($idPrefix)) {
            return false;
        }

        $formattedTitle = '';
        $searchTerm = '';
        «IF hasStringFieldsEntity»
            if (!empty($id)) {
                $repository = $entityFactory->getRepository('«name.formatForCode»');
                «IF hasSluggableFields && slugUnique»
                    $«name.formatForCode» = null;
                    if (!is_numeric($id)) {
                        $«name.formatForCode» = $repository->selectBySlug($id);
                    }
                    if (null === $«name.formatForCode» && is_numeric($id)) {
                        $«name.formatForCode» = $repository->selectById($id);
                    }
                «ELSE»
                    $«name.formatForCode» = $repository->selectById($id);
                «ENDIF»
                if (null !== $«name.formatForCode») {
                    $formattedTitle = $entityDisplayHelper->getFormattedTitle($«name.formatForCode»);
                    $searchTerm = $«name.formatForCode»->get«getStringFieldsEntity.head.name.formatForCodeCapital»();
                }
            }
        «ENDIF»

        $templateParameters = [
            'itemId' => $id,
            'formattedTitle' => $formattedTitle,
            'searchTerm' => $searchTerm,
            'idPrefix' => $idPrefix,
            'commandName' => $commandName,
        ];

        return new PlainResponse(
            $this->renderView('@«application.appName»/«name.formatForCode.toFirstUpper»/inlineRedirectHandler.html.twig', $templateParameters)
        );
    '''
}
