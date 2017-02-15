package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class InlineRedirect {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''
        «handleInlineRedirectDocBlock(isBase)»
        public function handleInlineRedirectAction($idPrefix, $commandName, $id = 0)
        {
            «IF isBase»
                «handleInlineRedirectBaseImpl»
            «ELSE»
                return parent::handleInlineRedirectAction($idPrefix, $commandName, $id);
            «ENDIF»
        }
    '''

    def private handleInlineRedirectDocBlock(Entity it, Boolean isBase) '''
        /**
         * This method cares for a redirect within an inline frame.
         «IF !isBase»
         *
         * @Route("/«name.formatForCode»/handleInlineRedirect/{idPrefix}/{commandName}/{id}",
         *        requirements = {"id" = "\d+"},
         *        defaults = {"commandName" = "", "id" = 0},
         *        methods = {"GET"}
         * )
         «ENDIF»
         *
         * @param string  $idPrefix    Prefix for inline window element identifier
         * @param string  $commandName Name of action to be performed (create or edit)
         * @param integer $id          Identifier of created «name.formatForDisplay» (used for activating auto completion after closing the modal window)
         *
         * @return PlainResponse Output
         */
    '''

    def private handleInlineRedirectBaseImpl(Entity it) '''
        if (empty($idPrefix)) {
            return false;
        }

        $templateParameters = [
            'itemId' => $id,
            'idPrefix' => $idPrefix,
            'commandName' => $commandName
        ];

        return new PlainResponse($this->get('twig')->render('@«application.appName»/«name.formatForCode.toFirstUpper»/inlineRedirectHandler.html.twig', $templateParameters));
    '''
}
