package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.ContentTypeDetailType
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeDetailView

class ContentTypeDetail {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateDetailContentType || !hasDisplayActions) {
            return
        }
        'Generating content type for single objects'.printIfNotTesting(fsa)
        if (targets('2.0')) {
            fsa.generateClassPair('ContentType/ItemType.php', contentTypeBaseClass, contentTypeImpl)
            new ContentTypeDetailType().generate(it, fsa)
        } else {
            fsa.generateClassPair('ContentType/Item.php', contentTypeLegacyBaseClass, contentTypeLegacyImpl)
        }
        new ContentTypeDetailView().generate(it, fsa)
    }

    def private contentTypeBaseClass(Application it) '''
        namespace «appNamespace»\ContentType\Base;

        use Symfony\Component\HttpKernel\Controller\ControllerReference;
        use Symfony\Component\HttpKernel\Fragment\FragmentHandler;
        use Zikula\Common\Content\AbstractContentType;
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

    def private contentTypeLegacyBaseClass(Application it) '''
        namespace «appNamespace»\ContentType\Base;

        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Symfony\Component\HttpKernel\Controller\ControllerReference;

        /**
         * Generic single item display content type base class.
         */
        abstract class AbstractItem extends \Content_AbstractContentType implements ContainerAwareInterface
        {
            use ContainerAwareTrait;

            «contentTypeBaseLegacyImpl»
        }
    '''

    def private contentTypeBaseImpl(Application it) '''
        /**
         * @var ControllerHelper
         */
        protected $controllerHelper;

        /**
         * @var FragmentHandler
         */
        protected $fragmentHandler;

        /**
         * @inheritDoc
         */
        public function getIcon()
        {
            return 'circle-o';
        }

        /**
         * @inheritDoc
         */
        public function getTitle()
        {
            return $this->__('«name.formatForDisplayCapital» detail', '«appName.formatForDB»');
        }

        /**
         * @inheritDoc
         */
        public function getDescription()
        {
            return $this->__('Display or link a single «name.formatForDisplay» object.', '«appName.formatForDB»');
        }

        /**
         * @inheritDoc
         */
        public function getDefaultData()
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'id' => null,
                'displayMode' => 'embed',
                'customTemplate' => null
            ];
        }

        /**
         * @inheritDoc
         */
        public function getData()
        {
            $data = parent::getData();

            $contextArgs = ['name' => 'detail'];
            if (!isset($data['objectType']) || !in_array($data['objectType'], $this->controllerHelper->getObjectTypes('contentType', $contextArgs))) {
                $data['objectType'] = $this->controllerHelper->getDefaultObjectType('contentType', $contextArgs);
                $this->data = $data;
            }

            return $data;
        }

        /**
         * @inheritDoc
         */
        public function displayView()
        {
            if (null === $this->data['id'] || empty($this->data['id']) || empty($this->data['displayMode'])) {
                return '';
            }

            $controllerReference = new ControllerReference('«appName»:External:display', $this->getDisplayArguments(), ['template' => $this->data['customTemplate']]);

            return $this->fragmentHandler->render($controllerReference, 'inline', []);
        }

        /**
         * @inheritDoc
         */
        public function displayEditing()
        {
            if (null === $this->data['id'] || empty($this->data['id']) || empty($this->data['displayMode'])) {
                return $this->__('No item selected.', '«appName.formatForDB»');
            }

            return parent::displayEditing();
        }

        /**
         * Returns common arguments for displaying the selected object using the external controller.
         *
         * @return array Display arguments
         */
        protected function getDisplayArguments()
        {
            return [
                'objectType' => $this->data['objectType'],
                'id' => $this->data['id'],
                'source' => 'contentType',
                'displayMode' => $this->data['displayMode']
            ];
        }

        /**
         * @inheritDoc
         */
        public function getEditFormClass()
        {
            return FormType::class;
        }

        /**
         * @inheritDoc
         */
        public function getEditFormOptions($context)
        {
            $options = parent::getEditFormOptions($context);
            $data = $this->getData();
            $options['object_type'] = $data['objectType'];

            return $options;
        }

        /**
         * @param ControllerHelper $controllerHelper
         */
        public function setControllerHelper(ControllerHelper $controllerHelper)
        {
            $this->controllerHelper = $controllerHelper;
        }

        /**
         * @param FragmentHandler $fragmentHandler
         */
        public function setFragmentHandler(FragmentHandler $fragmentHandler)
        {
            $this->fragmentHandler = $fragmentHandler;
        }
    '''

    def private contentTypeBaseLegacyImpl(Application it) '''
        /**
         * @var string
         */
        protected $objectType;

        /**
         * @var integer
         */
        protected $id;

        /**
         * @var string
         */
        protected $displayMode;

        /**
         * @var string
         */
        protected $customTemplate;

        /**
         * Item constructor.
         */
        public function __construct()
        {
            $this->setContainer(\ServiceUtil::getManager());
        }

        /**
         * Returns the module providing this content type.
         *
         * @return string The module name
         */
        public function getModule()
        {
            return '«appName»';
        }

        /**
         * Returns the name of this content type.
         *
         * @return string The content type name
         */
        public function getName()
        {
            return 'Item';
        }

        /**
         * Returns the title of this content type.
         *
         * @return string The content type title
         */
        public function getTitle()
        {
            return $this->container->get('translator.default')->__('«appName» detail view', '«appName.formatForDB»');
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description
         */
        public function getDescription()
        {
            return $this->container->get('translator.default')->__('Display or link a single «appName» object.', '«appName.formatForDB»');
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters
         */
        public function loadData(&$data)
        {
            $controllerHelper = $this->container->get('«appService».controller_helper');

            $contextArgs = ['name' => 'detail'];
            if (!isset($data['objectType']) || !in_array($data['objectType'], $controllerHelper->getObjectTypes('contentType', $contextArgs))) {
                $data['objectType'] = $controllerHelper->getDefaultObjectType('contentType', $contextArgs);
            }

            $this->objectType = $data['objectType'];

            $this->id = isset($data['id']) ? $data['id'] : null;
            $this->displayMode = isset($data['displayMode']) ? $data['displayMode'] : 'embed';
            $this->customTemplate = isset($data['customTemplate']) ? $data['customTemplate'] : null;
        }

        /**
         * Displays the data.
         *
         * @return string The returned output
         */
        public function display()
        {
            if (null === $this->id || empty($this->id) || empty($this->displayMode)) {
                return '';
            }

            $controllerReference = new ControllerReference('«appName»:External:display', $this->getDisplayArguments(), ['template' => $this->customTemplate]);

            return $this->container->get('fragment.handler')->render($controllerReference, 'inline', []);
        }

        /**
         * Displays the data for editing.
         */
        public function displayEditing()
        {
            if (null === $this->id || empty($this->id) || empty($this->displayMode)) {
                return $this->container->get('translator.default')->__('No item selected.', '«appName.formatForDB»');
            }

            return $this->display();
        }

        /**
         * Returns common arguments for displaying the selected object using the external controller.
         *
         * @return array Display arguments
         */
        protected function getDisplayArguments()
        {
            return [
                'objectType' => $this->objectType,
                'id' => $this->id,
                'source' => 'contentType',
                'displayMode' => $this->displayMode
            ];
        }

        /**
         * Returns the default data.
         *
         * @return array Default data and parameters
         */
        public function getDefaultData()
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'id' => null,
                'displayMode' => 'embed',
                'customTemplate' => null
            ];
        }

        /**
         * Executes additional actions for the editing mode.
         */
        public function startEditing()
        {
            // ensure that the view does not look for templates in the Content module (#218)
            $this->view->toplevelmodule = '«appName»';

            // ensure our custom plugins are loaded
            array_push($this->view->plugins_dir, '«relativeAppRootPath»/«getViewPath»plugins');

            // required as parameter for the item selector plugin
            $this->view->assign('objectType', $this->objectType);
        }

        /**
         * Returns the edit template path.
         *
         * @return string
         */
        public function getEditTemplate()
        {
            $absoluteTemplatePath = str_replace('ContentType/Base/AbstractItem.php', 'Resources/views/ContentType/item_edit.tpl', __FILE__);

            return 'file:' . $absoluteTemplatePath;
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

    def private contentTypeLegacyImpl(Application it) '''
        namespace «appNamespace»\ContentType;

        use «appNamespace»\ContentType\Base\AbstractItem;

        /**
         * Generic single item display content type implementation class.
         */
        class Item extends AbstractItem
        {
            // feel free to extend the content type here
        }
    '''
}
