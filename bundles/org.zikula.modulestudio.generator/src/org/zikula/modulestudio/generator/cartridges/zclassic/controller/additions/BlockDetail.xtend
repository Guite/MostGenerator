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
        use Symfony\Component\HttpKernel\Fragment\FragmentHandler;
        use Zikula\BlocksModule\AbstractBlockHandler;
        use «appNamespace»\Block\Form\Type\ItemBlockType;
        use «appNamespace»\Helper\ControllerHelper;

        /**
         * Generic item detail block base class.
         */
        abstract class AbstractItemBlock extends AbstractBlockHandler
        {
            «detailBlockBaseImpl»
        }
    '''

    def private detailBlockBaseImpl(Application it) '''
        protected ControllerHelper $controllerHelper;

        protected FragmentHandler $fragmentHandler;

        public function getType(): string
        {
            return $this->trans('«name.formatForDisplayCapital» detail');
        }

        «display»

        «getDisplayArguments»

        «modify»

        public function getPropertyDefaults(): array
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'id' => null,
                'template' => 'item_display.html.twig',
                'customTemplate' => null,
            ];
        }

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
    '''

    def private display(Application it) '''
        public function display(array $properties = []): string
        {
            // only show block content if the user has the required permissions
            if (!$this->hasPermission('«appName»:ItemBlock:', $properties['title'] . '::', ACCESS_OVERVIEW)) {
                return '';
            }

            if (null === $properties['id'] || empty($properties['id'])) {
                return '';
            }

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

            $controllerReference = new ControllerReference(
                '«appNamespace»\Controller\ExternalController::display«IF !targets('3.1')»Action«ENDIF»',
                $this->getDisplayArguments($properties),
                [
                    'template' => $properties['customTemplate']
                ]
            );

            return $this->fragmentHandler->render($controllerReference);
        }
    '''

    def private getDisplayArguments(Application it) '''
        /**
         * Returns common arguments for displaying the selected object using the external controller.
         */
        protected function getDisplayArguments(array $properties = []): array
        {
            return [
                'objectType' => $properties['objectType'],
                'id' => $properties['id'],
                'source' => 'block',
                'displayMode' => 'embed',
            ];
        }
    '''

    def private modify(Application it) '''
        public function getFormClassName(): string
        {
            return ItemBlockType::class;
        }

        public function getFormOptions(): array
        {
            $objectType = '«leadingEntity.name.formatForCode»';
            «/* TODO remove the following block */»
            $request = $this->requestStack->getCurrentRequest();
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
                'object_type' => $objectType,
            ];
        }

        public function getFormTemplate(): string
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
