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
            use «appNamespace»\Helper\WorkflowHelper;
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

            /**
             * @var WorkflowHelper
             */
            protected $workflowHelper;

        «ENDIF»
        public function getType()«IF targets('3.0')»: string«ENDIF»
        {
            return $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('«name.formatForDisplayCapital» moderation'«IF !targets('3.0')», '«appName.formatForDB»'«ENDIF»);
        }

        «display»

        «getDisplayTemplate»
        «IF targets('3.0')»

            /**
             * @required
             */
            public function setCurrentUserApi(CurrentUserApiInterface $currentUserApi): void
            {
                $this->currentUserApi = $currentUserApi;
            }

            /**
             * @required
             */
            public function setWorkflowHelper(WorkflowHelper $workflowHelper): void
            {
                $this->workflowHelper = $workflowHelper;
            }
        «ENDIF»
    '''

    def private display(Application it) '''
        public function display(array $properties = [])«IF targets('3.0')»: string«ENDIF»
        {
            // only show block content if the user has the required permissions
            if (!$this->hasPermission('«appName»:ModerationBlock:', $properties['title'] . '::', ACCESS_OVERVIEW)) {
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

            «IF targets('3.0')»
                $amounts = $this->workflowHelper->collectAmountOfModerationItems();
            «ELSE»
                $workflowHelper = $this->get('«appService».workflow_helper');
                $amounts = $workflowHelper->collectAmountOfModerationItems();
            «ENDIF»

            // set a block title
            if (empty($properties['title'])) {
                $properties['title'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Moderation'«IF !targets('3.0')», '«appName.formatForDB»'«ENDIF»);
            }

            return $this->renderView($template, [«/*'properties' => $properties, */»'moderationObjects' => $amounts]);
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
        «IF !targets('3.0')»
         *
         * @return string the template path
        «ENDIF»
         */
        protected function getDisplayTemplate()«IF targets('3.0')»: string«ENDIF»
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
