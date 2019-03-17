package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.BlockDetailType
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlockDetailView
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockDetail {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateDetailBlock || !hasDisplayActions) {
            return
        }
        'Generating block for single objects'.printIfNotTesting(fsa)
        fsa.generateClassPair('Block/ItemBlock.php', detailBlockBaseClass, detailBlockImpl)
        new BlockDetailType().generate(it, fsa)
        new BlockDetailView().generate(it, fsa)
    }

    def private detailBlockBaseClass(Application it) '''
        namespace «appNamespace»\Block\Base;

        use Symfony\Component\HttpKernel\Controller\ControllerReference;
        «IF targets('3.0')»
            use Symfony\Component\HttpKernel\Fragment\FragmentHandler;
        «ENDIF»
        use Zikula\BlocksModule\AbstractBlockHandler;
        use «appNamespace»\Block\Form\Type\ItemBlockType;
        «IF targets('3.0')»
            use «appNamespace»\Helper\ControllerHelper;
        «ENDIF»

        /**
         * Generic item detail block base class.
         */
        abstract class AbstractItemBlock extends AbstractBlockHandler
        {
            «detailBlockBaseImpl»
        }
    '''

    def private detailBlockBaseImpl(Application it) '''
        «IF targets('3.0')»
            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * @var FragmentHandler
             */
            protected $fragmentHandler;

        «ENDIF»
        /**
         * @inheritDoc
         */
        public function getType()
        {
            return $this->__('«name.formatForDisplayCapital» detail', '«appName.formatForDB»');
        }

        «display»

        «getDisplayArguments»

        «modify»

        /**
         * Returns default settings for this block.
         *
         * @return array The default settings
         */
        protected function getDefaults()
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'id' => null,
                'template' => 'item_display.html.twig',
                'customTemplate' => null
            ];
        }
        «IF targets('3.0')»

            /**
             * @required
             * @param ControllerHelper $controllerHelper
             */
            public function setControllerHelper(ControllerHelper $controllerHelper)
            {
                $this->controllerHelper = $controllerHelper;
            }

            /**
             * @required
             * @param FragmentHandler $fragmentHandler
             */
            public function setFragmentHandler(FragmentHandler $fragmentHandler)
            {
                $this->fragmentHandler = $fragmentHandler;
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
            if (!$this->hasPermission('«appName»:ItemBlock:', "$properties[title]::", ACCESS_OVERVIEW)) {
                return '';
            }

            // set default values for all params which are not properly set
            $defaults = $this->getDefaults();
            $properties = array_merge($defaults, $properties);

            if (null === $properties['id'] || empty($properties['id'])) {
                return '';
            }

            «IF targets('3.0')»
                $contextArgs = ['name' => 'detail'];
                if (!isset($properties['objectType']) || !in_array($properties['objectType'], $this->controllerHelper->getObjectTypes('block', $contextArgs))) {
                    $properties['objectType'] = $this->controllerHelper->getDefaultObjectType('block', $contextArgs);
                }
            «ELSE»
                $controllerHelper = $this->get('«appService».controller_helper');
                $contextArgs = ['name' => 'detail'];
                if (!isset($properties['objectType']) || !in_array($properties['objectType'], $controllerHelper->getObjectTypes('block', $contextArgs))) {
                    $properties['objectType'] = $controllerHelper->getDefaultObjectType('block', $contextArgs);
                }
            «ENDIF»

            $controllerReference = new ControllerReference('«appName»:External:display', $this->getDisplayArguments($properties), ['template' => $properties['customTemplate']]);

            return $this->«IF targets('3.0')»fragmentHandler«ELSE»get('fragment.handler')«ENDIF»->render($controllerReference, 'inline', []);
        }
    '''

    def private getDisplayArguments(Application it) '''
        /**
         * Returns common arguments for displaying the selected object using the external controller.
         *
         * @param array $properties The block properties
         *
         * @return array Display arguments
         */
        protected function getDisplayArguments(array $properties = [])
        {
            return [
                'objectType' => $properties['objectType'],
                'id' => $properties['id'],
                'source' => 'block',
                'displayMode' => 'embed'
            ];
        }
    '''

    def private modify(Application it) '''
        /**
         * @inheritDoc
         */
        public function getFormClassName()
        {
            return ItemBlockType::class;
        }

        /**
         * @inheritDoc
         */
        public function getFormOptions()
        {
            $objectType = '«leadingEntity.name.formatForCode»';

            $request = $this->«IF targets('3.0')»requestStack«ELSE»get('request_stack')«ENDIF»->getCurrentRequest();
            if ($request->attributes->has('blockEntity')) {
                $blockEntity = $request->attributes->get('blockEntity');
                if (is_object($blockEntity) && method_exists($blockEntity, 'getProperties')) {
                    $blockProperties = $blockEntity->getProperties();
                    if (isset($blockProperties['objectType'])) {
                        $objectType = $blockProperties['objectType'];
                    } else {
                        // set default options for new block creation
                        $blockEntity->setProperties($this->getDefaults());
                    }
                }
            }

            return [
                'object_type' => $objectType
            ];
        }

        /**
         * @inheritDoc
         */
        public function getFormTemplate()
        {
            return '@«appName»/Block/item_modify.html.twig';
        }
    '''

    def private detailBlockImpl(Application it) '''
        namespace «appNamespace»\Block;

        use «appNamespace»\Block\Base\AbstractItemBlock;

        /**
         * Generic item detail block implementation class.
         */
        class ItemBlock extends AbstractItemBlock
        {
            // feel free to extend the item detail block here
        }
    '''
}
