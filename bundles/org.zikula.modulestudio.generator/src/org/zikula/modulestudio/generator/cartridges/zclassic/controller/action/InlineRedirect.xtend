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
        «handleInlineRedirectSignature»«IF application.targets('3.0')»: Response«ENDIF» {
            «IF isBase»
                «handleInlineRedirectBaseImpl»
            «ELSE»
                «IF application.targets('3.0')»
                    return parent::handleInlineRedirect«IF !application.targets('3.x-dev')»Action«ENDIF»(
                        $entityFactory,
                        $entityDisplayHelper,
                        $idPrefix,
                        $commandName,
                        $id
                    );
                «ELSE»
                    return parent::handleInlineRedirectAction($idPrefix, $commandName, $id);
                «ENDIF»
            «ENDIF»
        }
    '''

    def private handleInlineRedirectDocBlock(Entity it, Boolean isBase) '''
        /**
         «IF isBase»
         * This method cares for a redirect within an inline frame.
         «IF !application.targets('3.0')»
         *
         * @param string $idPrefix Prefix for inline window element identifier
         * @param string $commandName Name of action to be performed (create or edit)
         * @param int $id Identifier of created «name.formatForDisplay» (used for activating auto completion after closing the modal window)
         *
         * @return Response
         «ENDIF»
         «ELSE»
         * @Route("/«name.formatForCode»/handleInlineRedirect/{idPrefix}/{commandName}/{id}",
         *        requirements = {"id" = "\d+"},
         *        defaults = {"commandName" = "", "id" = 0},
         *        methods = {"GET"}
         * )
         «ENDIF»
         */
    '''

    def private handleInlineRedirectSignature(Entity it) '''
        public function handleInlineRedirect«IF !application.targets('3.x-dev')»Action«ENDIF»(
            «IF application.targets('3.0')»
                EntityFactory $entityFactory,
                EntityDisplayHelper $entityDisplayHelper,
                string $idPrefix,
                string $commandName,
                int $id = 0
            «ELSE»
                $idPrefix,
                $commandName,
                $id = 0
            «ENDIF»
        )'''

    def private handleInlineRedirectBaseImpl(Entity it) '''
        if (empty($idPrefix)) {
            return false;
        }

        $formattedTitle = '';
        $searchTerm = '';
        «IF hasStringFieldsEntity»
            if (!empty($id)) {
                $repository = «IF application.targets('3.0')»$entityFactory«ELSE»$this->get('«application.appService».entity_factory')«ENDIF»->getRepository('«name.formatForCode»');
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
                    $formattedTitle = «IF application.targets('3.0')»$entityDisplayHelper«ELSE»$this->get('«application.appService».entity_display_helper')«ENDIF»->getFormattedTitle($«name.formatForCode»);
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
            $this->«IF application.targets('3.0')»renderView«ELSE»get('twig')->render«ENDIF»('@«application.appName»/«name.formatForCode.toFirstUpper»/inlineRedirectHandler.html.twig', $templateParameters)
        );
    '''
}
