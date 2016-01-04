package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlockModerationView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockModeration {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating block for moderation')
        generateClassPair(fsa, getAppSourceLibPath + 'Block/Moderation' + (if (targets('1.3.x')) '' else 'Block') + '.php',
            fh.phpFileContent(it, moderationBlockBaseClass), fh.phpFileContent(it, moderationBlockImpl)
        )
        new BlockModerationView().generate(it, fsa)
    }

    def private moderationBlockBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Block\Base;

            use UserUtil;
            use Zikula\Core\AbstractBlockHandler;

        «ENDIF»
        /**
         * Moderation block base class.
         */
        class «IF targets('1.3.x')»«appName»_Block_Base_Moderation extends Zikula_Controller_AbstractBlock«ELSE»ModerationBlock extends AbstractBlockHandler«ENDIF»
        {
            «moderationBlockBaseImpl»
        }
    '''

    def private moderationBlockBaseImpl(Application it) '''
        «IF targets('1.3.x')»
            «init»

            «info»

        «ENDIF»
        «display»

        «getDisplayTemplate»
    '''

    // 1.3.x only
    def private init(Application it) '''
        /**
         * Initialise the block.
         */
        public function init()
        {
            //SecurityUtil::registerPermissionSchema('«appName»:ModerationBlock:', 'Block title::');
        }
    '''

    // 1.3.x only
    def private info(Application it) '''
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

            return array(
                'module'          => '«appName»',
                'text_type'       => $this->__('Moderation'),
                'text_type_long'  => $this->__('Show a list of pending tasks to moderators.'),
                'allow_multiple'  => true,
                'form_content'    => false,
                'form_refresh'    => false,
                'show_preview'    => false,
                'admin_tableless' => true,
                'requirement'     => $requirementMessage
            );
        }
    '''

    def private display(Application it) '''
        /**
         * Display the block content.
         *
        «IF targets('1.3.x')»
            «' '»* @param array $blockinfo the blockinfo structure.
            «' '»*
            «' '»* @return string output of the rendered block
        «ELSE»
            «' '»* @param array $properties The block properties array.

            «' '»* @return array|string
        «ENDIF»
         */
        public function display(«IF targets('1.3.x')»$blockinfo«ELSE»array $properties«ENDIF»)
        {
            // only show block content if the user has the required permissions
            «IF targets('1.3.x')»
                if (!SecurityUtil::checkPermission('«appName»:ModerationBlock:', "$blockinfo[title]::", ACCESS_OVERVIEW)) {
                    return false;
                }
            «ELSE»
                if (!$this->hasPermission('«appName»:ModerationBlock:', "$properties[title]::", ACCESS_OVERVIEW)) {
                    return false;
                }
            «ENDIF»

            if (!UserUtil::isLoggedIn()) {
                return false;
            }
            «IF targets('1.3.x')»

                // check if the module is available at all
                if (!ModUtil::available('«appName»')) {
                    return false;
                }

                ModUtil::initOOModule('«appName»');

                $this->view->setCaching(Zikula_View::CACHE_DISABLED);
                $template = $this->getDisplayTemplate();

                $workflowHelper = new «appName»_Util_Workflow($this->serviceManager);
            «ELSE»
                $template = $this->getDisplayTemplate();

                $workflowHelper = $this->get('«appName.formatForDB».workflow_helper');
            «ENDIF»
            $amounts = $workflowHelper->collectAmountOfModerationItems();

            «IF targets('1.3.x')»
                // assign block vars and fetched data
                $this->view->assign('moderationObjects', $amounts);

                // set a block title
                if (empty($blockinfo['title'])) {
                    $blockinfo['title'] = $this->__('Moderation');
                }

                $blockinfo['content'] = $this->view->fetch($template);

                // return the block to the theme
                return BlockUtil::themeBlock($blockinfo);
            «ELSE»
                return $this->renderView($template, [«/*'properties' => $properties, */»'moderationObjects' => $amounts]);
            «ENDIF»
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         *
         * @return string the template path.
         */
        protected function getDisplayTemplate()
        {
            «IF targets('1.3.x')»
                $template = 'block/moderation.tpl';
            «ELSE»
                $template = '«appName»:Block:moderation.html.twig';
            «ENDIF»

            return $template;
        }
    '''

    def private moderationBlockImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Block;

            use «appNamespace»\Block\Base\ModerationBlock as BaseModerationBlock;

        «ENDIF»
        /**
         * Moderation block implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Block_Moderation extends «appName»_Block_Base_Moderation
        «ELSE»
        class ModerationBlock extends BaseModerationBlock
        «ENDIF»
        {
            // feel free to extend the moderation block here
        }
    '''
}
