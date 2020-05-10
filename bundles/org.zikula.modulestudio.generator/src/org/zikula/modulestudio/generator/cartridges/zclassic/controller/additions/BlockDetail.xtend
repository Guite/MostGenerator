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
        public function getType()«IF targets('3.0')»: string«ENDIF»
        {
            return $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('«name.formatForDisplayCapital» detail'«IF !targets('3.0')», '«appName.formatForDB»'«ENDIF»);
        }

        «display»

        «getDisplayArguments»

        «modify»

        /**
         * Returns default settings for this block.
         «IF !targets('3.0')»
         *
         * @return array The default settings
         «ENDIF»
         */
        protected function getDefaults()«IF targets('3.0')»: array«ENDIF»
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
             */
            public function setControllerHelper(ControllerHelper $controllerHelper): void
            {
                $this->controllerHelper = $controllerHelper;
            }

            /**
             * @required
             */
            public function setFragmentHandler(FragmentHandler $fragmentHandler): void
            {
                $this->fragmentHandler = $fragmentHandler;
            }
        «ENDIF»
    '''

    def private display(Application it) '''
        public function display(array $properties = [])«IF targets('3.0')»: string«ENDIF»
        {
            // only show block content if the user has the required permissions
            if (!$this->hasPermission('«appName»:ItemBlock:', $properties['title'] . '::', ACCESS_OVERVIEW)) {
                return '';
            }

            // set default values for all params which are not properly set
            $defaults = $this->getDefaults();
            $properties = array_merge($defaults, $properties);

            if (null === $properties['id'] || empty($properties['id'])) {
                return '';
            }

            «IF targets('3.0')»
                «IF !isSystemModule»
                    $contextArgs = ['name' => 'detail'];
                «ENDIF»
                $allowedObjectTypes = $this->controllerHelper->getObjectTypes('block'«IF !isSystemModule», $contextArgs«ENDIF»);
                if (
                    !isset($properties['objectType'])
                    || !in_array($properties['objectType'], $allowedObjectTypes, true)
                ) {
                    $properties['objectType'] = $this->controllerHelper->getDefaultObjectType('block'«IF !isSystemModule», $contextArgs«ENDIF»);
                }
            «ELSE»
                $controllerHelper = $this->get('«appService».controller_helper');
                «IF !isSystemModule»
                    $contextArgs = ['name' => 'detail'];
                «ENDIF»
                if (
                    !isset($properties['objectType'])
                    || !in_array($properties['objectType'], $controllerHelper->getObjectTypes('block'«IF !isSystemModule», $contextArgs«ENDIF»), true)
                ) {
                    $properties['objectType'] = $controllerHelper->getDefaultObjectType('block'«IF !isSystemModule», $contextArgs«ENDIF»);
                }
            «ENDIF»

            $controllerReference = new ControllerReference(
                «IF targets('3.0')»
                    '«appNamespace»\Controller\ExternalController::displayAction',
                «ELSE»
                    '«appName»:External:display',
                «ENDIF»
                $this->getDisplayArguments($properties),
                ['template' => $properties['customTemplate']]
            );

            return $this->«IF targets('3.0')»fragmentHandler«ELSE»get('fragment.handler')«ENDIF»->render($controllerReference);
        }
    '''

    def private getDisplayArguments(Application it) '''
        /**
         * Returns common arguments for displaying the selected object using the external controller.
         «IF !targets('3.0')»
         *
         * @param array $properties The block properties
         *
         * @return array Display arguments
         «ENDIF»
         */
        protected function getDisplayArguments(array $properties = [])«IF targets('3.0')»: array«ENDIF»
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
        public function getFormClassName()«IF targets('3.0')»: string«ENDIF»
        {
            return ItemBlockType::class;
        }

        public function getFormOptions()«IF targets('3.0')»: array«ENDIF»
        {
            $objectType = '«leadingEntity.name.formatForCode»';

            $request = $this->«IF targets('3.0')»requestStack«ELSE»get('request_stack')«ENDIF»->getCurrentRequest();
            if (null !== $request && $request->attributes->has('blockEntity')) {
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

        public function getFormTemplate()«IF targets('3.0')»: string«ENDIF»
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
