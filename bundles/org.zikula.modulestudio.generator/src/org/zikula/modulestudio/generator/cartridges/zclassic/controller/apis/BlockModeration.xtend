package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlockModerationView
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockModeration {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating block for moderation')
        generateClassPair(fsa, getAppSourceLibPath + 'Block/ModerationBlock.php',
            fh.phpFileContent(it, moderationBlockBaseClass), fh.phpFileContent(it, moderationBlockImpl)
        )
        new BlockModerationView().generate(it, fsa)
    }

    def private moderationBlockBaseClass(Application it) '''
        namespace «appNamespace»\Block\Base;

        use Zikula\BlocksModule\AbstractBlockHandler;

        /**
         * Moderation block base class.
         */
        abstract class AbstractModerationBlock extends AbstractBlockHandler
        {
            «moderationBlockBaseImpl»
        }
    '''

    def private moderationBlockBaseImpl(Application it) '''
        «display»

        «getDisplayTemplate»
    '''

    def private display(Application it) '''
        /**
         * Display the block content.
         *
         * @param array $properties The block properties array
         *
         * @return array|string
         */
        public function display(array $properties)
        {
            // only show block content if the user has the required permissions
            if (!$this->hasPermission('«appName»:ModerationBlock:', "$properties[title]::", ACCESS_OVERVIEW)) {
                return false;
            }

            $currentUserApi = $this->get('zikula_users_module.current_user');
            if (!$currentUserApi->isLoggedIn()) {
                return false;
            }

            $template = $this->getDisplayTemplate();

            $workflowHelper = $this->get('«appService».workflow_helper');
            $amounts = $workflowHelper->collectAmountOfModerationItems();

            // set a block title
            if (empty($properties['title'])) {
                $properties['title'] = $this->__('Moderation');
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
