package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.ContentTypeDetailType
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeDetailView
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeDetail {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateDetailContentType || !hasDisplayActions) {
            return
        }
        'Generating content type for single objects'.printIfNotTesting(fsa)
        fsa.generateClassPair('ContentType/ItemType.php', contentTypeBaseClass, contentTypeImpl)
        new ContentTypeDetailType().generate(it, fsa)
        new ContentTypeDetailView().generate(it, fsa)
    }

    def private contentTypeBaseClass(Application it) '''
        namespace «appNamespace»\ContentType\Base;

        use Symfony\Component\HttpKernel\Controller\ControllerReference;
        use Symfony\Component\HttpKernel\Fragment\FragmentHandler;
        use Zikula\ExtensionsModule\ModuleInterface\Content\AbstractContentType;
        use «appNamespace»\ContentType\Form\Type\ItemType as FormType;
        use «appNamespace»\Helper\ControllerHelper;

        /**
         * Generic single item display content type base class.
         */
        abstract class AbstractItemType extends AbstractContentType
        {
            «contentTypeBaseImpl»
        }
    '''

    def private contentTypeBaseImpl(Application it) '''
        protected ControllerHelper $controllerHelper;

        protected FragmentHandler $fragmentHandler;

        public function getIcon(): string
        {
            return 'circle-o';
        }

        public function getTitle(): string
        {
            return $this->translator->trans('«name.formatForDisplayCapital» detail');
        }

        public function getDescription(): string
        {
            return $this->translator->trans('Display or link a single «name.formatForDisplay» object.');
        }

        public function getDefaultData(): array
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'id' => null,
                'displayMode' => 'embed',
                'customTemplate' => null,
            ];
        }

        public function getData(): array
        {
            $data = parent::getData();

            «IF !isSystemModule»
                $contextArgs = ['name' => 'detail'];
            «ENDIF»
            $allowedObjectTypes = $this->controllerHelper->getObjectTypes('contentType'«IF !isSystemModule», $contextArgs«ENDIF»);
            if (
                !isset($data['objectType'])
                || !in_array($data['objectType'], $allowedObjectTypes, true)
            ) {
                $data['objectType'] = $this->controllerHelper->getDefaultObjectType('contentType'«IF !isSystemModule», $contextArgs«ENDIF»);
                $this->data = $data;
            }

            return $data;
        }

        public function displayView(): string
        {
            if (null === $this->data['id'] || empty($this->data['id']) || empty($this->data['displayMode'])) {
                return '';
            }

            $controllerReference = new ControllerReference(
                '«appNamespace»\Controller\ExternalController::display«IF !targets('3.1')»Action«ENDIF»',
                $this->getDisplayArguments(),
                [
                    'template' => $this->data['customTemplate']
                ]
            );

            return $this->fragmentHandler->render($controllerReference, 'inline', []);
        }

        public function displayEditing(): string
        {
            if (null === $this->data['id'] || empty($this->data['id']) || empty($this->data['displayMode'])) {
                return $this->translator->trans('No item selected.');
            }

            return parent::displayEditing();
        }

        /**
         * Returns common arguments for displaying the selected object using the external controller.
         */
        protected function getDisplayArguments(): array
        {
            return [
                'objectType' => $this->data['objectType'],
                'id' => $this->data['id'],
                'source' => 'contentType',
                'displayMode' => $this->data['displayMode'],
            ];
        }

        public function getEditFormClass(): string
        {
            return FormType::class;
        }

        public function getEditFormOptions($context): array
        {
            $options = parent::getEditFormOptions($context);
            $data = $this->getData();
            $options['object_type'] = $data['objectType'];

            return $options;
        }

        #[Required]
        public function setControllerHelper(ControllerHelper $controllerHelper): void
        {
            $this->controllerHelper = $controllerHelper;
        }

        #[Required]
        public function setFragmentHandler(FragmentHandler $fragmentHandler): void
        {
            $this->fragmentHandler = $fragmentHandler;
        }
    '''

    def private contentTypeImpl(Application it) '''
        namespace «appNamespace»\ContentType;

        use «appNamespace»\ContentType\Base\AbstractItemType;

        /**
         * Generic single item display content type implementation class.
         */
        class ItemType extends AbstractItemType
        {
            // feel free to extend the content type here
        }
    '''
}
