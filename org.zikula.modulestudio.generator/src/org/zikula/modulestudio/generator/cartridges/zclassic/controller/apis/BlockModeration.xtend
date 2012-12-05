package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlockModerationView
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockModeration {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating block for moderation')
        val blockPath = appName.getAppSourceLibPath + 'Block/'
        fsa.generateFile(blockPath + 'Base/Moderation.php', moderationBlockBaseFile)
        fsa.generateFile(blockPath + 'Moderation.php', moderationBlockFile)
        new BlockModerationView().generate(it, fsa)
    }

    def private moderationBlockBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «moderationBlockBaseClass»
    '''

    def private moderationBlockFile(Application it) '''
        «fh.phpFileHeader(it)»
        «moderationBlockImpl»
    '''

    def private moderationBlockBaseClass(Application it) '''
        /**
         * Moderation block base class.
         */
        class «appName»_Block_Base_Moderation extends Zikula_Controller_AbstractBlock
        {
            «moderationBlockBaseImpl»
        }
    '''

    def private moderationBlockBaseImpl(Application it) '''
        /**
         * Initialise the block.
         */
        public function init()
        {
            SecurityUtil::registerPermissionSchema('«appName»:ModerationBlock:', 'Block title::');
        }

        /**
         * Get information on the block.
         *
         * @return array The block information
         */
        public function info()
        {
            $requirementMessage = '';
            // check if the module is available at all
            if (!ModUtil::available('«appName»')) {
                $requirementMessage .= $this->__('Notice: This block will not be displayed until you activate the «appName» module.');
            }

            return array('module'          => '«appName»',
                         'text_type'       => $this->__('Moderation'),
                         'text_type_long'  => $this->__('Show a list of pending tasks to moderators.'),
                         'allow_multiple'  => true,
                         'form_content'    => false,
                         'form_refresh'    => false,
                         'show_preview'    => false,
                         'admin_tableless' => true,
                         'requirement'     => $requirementMessage);
        }

        /**
         * Display the block.
         *
         * @param array $blockinfo the blockinfo structure
         *
         * @return string output of the rendered block
         */
        public function display($blockinfo)
        {
            // only show block content if the user has the required permissions
            if (!SecurityUtil::checkPermission('«appName»:ModerationBlock:', "$blockinfo[title]::", ACCESS_OVERVIEW)) {
                return false;
            }

            // check if the module is available at all
            if (!ModUtil::available('«appName»')) {
                return false;
            }

            if (!UserUtil::isLoggedIn()) {
                return false;
            }

            ModUtil::initOOModule('«appName»');

            $this->view->setCaching(Zikula_View::CACHE_DISABLED);
            $template = $this->getDisplayTemplate($vars);

            $workflowHelper = new «appName»_Util_Workflow($this->serviceManager);
            $amounts = $workflowHelper->collectAmountOfModerationItems();

            // assign block vars and fetched data
            $this->view->assign('moderationObjects', $amounts);

            // set a block title
            if (empty($blockinfo['title'])) {
                $blockinfo['title'] = $this->__('Moderation');
            }

            $blockinfo['content'] = $this->view->fetch($template);

            // return the block to the theme
            return BlockUtil::themeBlock($blockinfo);
        }

        /**
         * Returns the template used for output.
         *
         * @param array $vars List of block variables.
         *
         * @return string the template path.
         */
        protected function getDisplayTemplate($vars)
        {
            $template = 'block/moderation.tpl';

            return $template;
        }
    '''

    def private moderationBlockImpl(Application it) '''
        /**
         * Moderation block implementation class.
         */
        class «appName»_Block_Moderation extends «appName»_Block_Base_Moderation
        {
            // feel free to extend the moderation block here
        }
    '''
}
