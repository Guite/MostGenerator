package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlockModerationView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class BlockModeration {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        val needsModerationBlock = generateModerationBlock && needsApproval
        if (!needsModerationBlock) {
            return
        }
        'Generating block for moderation'.printIfNotTesting(fsa)
        fsa.generateClassPair('Block/ModerationBlock.php', moderationBlockBaseClass, moderationBlockImpl)
        new BlockModerationView().generate(it, fsa)
    }

    def private moderationBlockBaseClass(Application it) '''
        namespace «appNamespace»\Block\Base;

        use Zikula\BlocksModule\AbstractBlockHandler;
        «IF targets('3.0')»
            use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        «ENDIF»

        /**
         * Moderation block base class.
         */
        abstract class AbstractModerationBlock extends AbstractBlockHandler
        {
            «moderationBlockBaseImpl»
        }
    '''

    def private moderationBlockBaseImpl(Application it) '''
        «IF targets('3.0')»
            /**
             * @var CurrentUserApiInterface
             */
            protected $currentUserApi;

        «ENDIF»
        /**
         * @inheritDoc
         */
        public function getType()
        {
            return $this->__('«name.formatForDisplayCapital» moderation', '«appName.formatForDB»');
        }

        «display»

        «getDisplayTemplate»
        «IF targets('3.0')»

            /**
             * @required
             * @param CurrentUserApiInterface $currentUserApi
             */
            public function setCurrentUserApi(CurrentUserApiInterface $currentUserApi)
            {
                $this->currentUserApi = $currentUserApi;
            }
        «ENDIF»
    '''

    def private display(Application it) '''
        /**
         * @inheritDoc
         */
        public function display(array $properties = [])
        {
            // only show block content if the user has the required permissions
            if (!$this->hasPermission('«appName»:ModerationBlock:', "$properties[title]::", ACCESS_OVERVIEW)) {
                return '';
            }

            «IF targets('3.0')»
                if (!$this->currentUserApi->isLoggedIn()) {
                    return '';
                }
            «ELSE»
                $currentUserApi = $this->get('zikula_users_module.current_user');
                if (!$currentUserApi->isLoggedIn()) {
                    return '';
                }
            «ENDIF»

            $template = $this->getDisplayTemplate();

            $workflowHelper = $this->get('«appService».workflow_helper');
            $amounts = $workflowHelper->collectAmountOfModerationItems();

            // set a block title
            if (empty($properties['title'])) {
                $properties['title'] = $this->__('Moderation', '«appName.formatForDB»');
            }

            return $this->renderView($template, [«/*'properties' => $properties, */»'moderationObjects' => $amounts]);
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         *
         * @return string the template path
         */
        protected function getDisplayTemplate()
        {
            return '@«appName»/Block/moderation.html.twig';
        }
    '''

    def private moderationBlockImpl(Application it) '''
        namespace «appNamespace»\Block;

        use «appNamespace»\Block\Base\AbstractModerationBlock;

        /**
         * Moderation block implementation class.
         */
        class ModerationBlock extends AbstractModerationBlock
        {
            // feel free to extend the moderation block here
        }
    '''
}
