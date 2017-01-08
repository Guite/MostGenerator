package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Tag {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'TaggedObjectMeta/' + appName + '.php',
            fh.phpFileContent(it, tagBaseClass), fh.phpFileContent(it, tagImpl)
        )
    }

    def private tagBaseClass(Application it) '''
        namespace «appNamespace»\TaggedObjectMeta\Base;

        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Zikula\Core\UrlInterface;
        use Zikula\TagModule\AbstractTaggedObjectMeta;

        /**
         * This class provides object meta data for the Tag module.
         */
        abstract class Abstract«appName» extends AbstractTaggedObjectMeta implements ContainerAwareInterface
        {
            use ContainerAwareTrait;

            «tagBaseImpl»
        }
    '''

    def private tagBaseImpl(Application it) '''
        /**
         * «appName» constructor.
         *
         * @param integer      $objectId  Identifier of treated object
         * @param integer      $areaId    Name of hook area
         * @param string       $module    Name of the owning module
         * @param string       $urlString **deprecated**
         * @param UrlInterface $urlObject Object carrying url arguments
         */
        function __construct($objectId, $areaId, $module, $urlString = null, UrlInterface $urlObject = null)
        {
            // call base constructor to store arguments in member vars
            parent::__construct($objectId, $areaId, $module, $urlString, $urlObject);

            // derive object type from url object
            $urlArgs = $urlObject->getArgs();
            $objectType = isset($urlArgs['ot']) ? $urlArgs['ot'] : '«getLeadingEntity.name.formatForCode»';

            $permissionApi = $this->container->get('zikula_permissions_module.api.permission');
            $component = $module . ':' . ucfirst($objectType) . ':';
            $perm = $permissionApi->hasPermission($component, $objectId . '::', ACCESS_READ);
            if (!$perm) {
                return;
            }

            $repository = $this->container->get('«appService».entity_factory')->getRepository($objectType);
            $useJoins = false;

            «/* TODO support composite identifiers properly at this point */»
            $entity = $repository->selectById($objectId, $useJoins);
            if (null === $entity) {
                return;
            }

            $this->setObjectTitle($entity->getTitleFromDisplayPattern());

            $dateFieldName = $repository->getStartDateFieldName();
            if ($dateFieldName != '') {
                $this->setObjectDate($entity[$dateFieldName]);
            } else {
                $this->setObjectDate('');
            }

            if (method_exists($entity, 'getCreatedBy')) {
                $this->setObjectAuthor($entity->getCreatedBy()->getUname());
            } else {
                $this->setObjectAuthor('');
            }
        }

        /**
         * Sets the object title.
         *
         * @param string $title
         */
        public function setObjectTitle($title)
        {
            $this->title = $title;
        }

        /**
         * Sets the object date.
         *
         * @param string $date
         */
        public function setObjectDate($date)
        {
            $this->date = «/* $date; */»\DateUtil::formatDatetime($date, 'datetimebrief');
        }

        /**
         * Sets the object author.
         *
         * @param string $author
         */
        public function setObjectAuthor($author)
        {
            $this->author = $author;
        }
    '''

    def private tagImpl(Application it) '''
        namespace «appNamespace»\TaggedObjectMeta;

        use «appNamespace»\TaggedObjectMeta\Base\Abstract«appName»;

        /**
         * This class provides object meta data for the Tag module.
         */
        class «appName» extends Abstract«appName»
        {
            // feel free to extend the tag support here
        }
    '''
}
