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
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use «appNamespace»\Helper\WorkflowHelper;

        /**
         * Moderation block base class.
         */
        abstract class AbstractModerationBlock extends AbstractBlockHandler
        {
            «moderationBlockBaseImpl»
        }
    '''

    def private moderationBlockBaseImpl(Application it) '''
        protected CurrentUserApiInterface $currentUserApi;

        protected WorkflowHelper $workflowHelper;

        public function getType(): string
        {
            return $this->trans('«name.formatForDisplayCapital» moderation');
        }

        «display»

        «getDisplayTemplate»

        #[Required]
        public function setCurrentUserApi(CurrentUserApiInterface $currentUserApi): void
        {
            $this->currentUserApi = $currentUserApi;
        }

        #[Required]
        public function setWorkflowHelper(WorkflowHelper $workflowHelper): void
        {
            $this->workflowHelper = $workflowHelper;
        }
    '''

    def private display(Application it) '''
        public function display(array $properties = []): string
        {
            // only show block content if the user has the required permissions
            if (!$this->hasPermission('«appName»:ModerationBlock:', $properties['title'] . '::', ACCESS_OVERVIEW)) {
                return '';
            }

            if (!$this->currentUserApi->isLoggedIn()) {
                return '';
            }

            $template = $this->getDisplayTemplate();

            $amounts = $this->workflowHelper->collectAmountOfModerationItems();

            // set a block title
            if (empty($properties['title'])) {
                $properties['title'] = $this->trans('Moderation');
            }

            return $this->renderView($template, [«/*'properties' => $properties, */»'moderationObjects' => $amounts]);
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         */
        protected function getDisplayTemplate(): string
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
