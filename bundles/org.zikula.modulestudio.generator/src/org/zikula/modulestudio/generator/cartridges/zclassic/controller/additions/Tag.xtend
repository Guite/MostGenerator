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
        «IF !targets('1.3.x')»
            namespace «appNamespace»\TaggedObjectMeta\Base;

            use DateUtil;
            use ServiceUtil;
            use UserUtil;
            use Zikula\TagModule\AbstractTaggedObjectMeta;
            use Zikula\Core\UrlInterface;

        «ENDIF»
        /**
         * This class provides object meta data for the Tag module.
         */
        «IF targets('1.3.x')»
        abstract class «appName»_TaggedObjectMeta_Base_Abstract«appName» extends Tag_AbstractTaggedObjectMeta
        «ELSE»
        abstract class Abstract«appName» extends AbstractTaggedObjectMeta
        «ENDIF»
        {
            «tagBaseImpl»
        }
    '''

    def private tagBaseImpl(Application it) '''
        /**
         * Constructor.
         *
         * @param integer             $objectId  Identifier of treated object
         * @param integer             $areaId    Name of hook area
         * @param string              $module    Name of the owning module
         * @param string              $urlString **deprecated**
         * @param «IF targets('1.3.x')»Zikula_ModUrl«ELSE»UrlInterface«ENDIF» $urlObject Object carrying url arguments
         */
        function __construct($objectId, $areaId, $module, $urlString = null, «IF targets('1.3.x')»Zikula_ModUrl«ELSE»UrlInterface«ENDIF» $urlObject = null)
        {
            // call base constructor to store arguments in member vars
            parent::__construct($objectId, $areaId, $module, $urlString, $urlObject);

            // derive object type from url object
            $urlArgs = $urlObject->getArgs();
            $objectType = isset($urlArgs['ot']) ? $urlArgs['ot'] : '«getLeadingEntity.name.formatForCode»';

            $serviceManager = ServiceUtil::getManager();

            «IF !targets('1.3.x')»
                $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');
            «ENDIF»
            $component = $module . ':' . ucfirst($objectType) . ':';
            $perm = «IF targets('1.3.x')»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission($component, $objectId . '::', ACCESS_READ);
            if (!$perm) {
                return;
            }

            «IF targets('1.3.x')»
                $entityClass = $module . '_Entity_' . ucfirst($objectType);
            «ENDIF»
            «IF targets('1.3.x')»
                $entityManager = $serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('«entityManagerService»');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $serviceManager->get('«appService».' . $objectType . '_factory')->getRepository();
            «ENDIF»
            $useJoins = false;

            /** TODO support composite identifiers properly at this point */
            $entity = $repository->selectById($objectId, $useJoins);
            if ($entity === false || (!is_array($entity) && !is_object($entity))) {
                return;
            }

            $this->setObjectTitle($entity->getTitleFromDisplayPattern());

            $dateFieldName = $repository->getStartDateFieldName();
            if ($dateFieldName != '') {
                $this->setObjectDate($entity[$dateFieldName]);
            } else {
                $this->setObjectDate('');
            }

            if (method_exists($entity, 'getCreatedUserId')) {
                $this->setObjectAuthor(UserUtil::getVar('uname', $entity['createdUserId']));
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
«/*            $this->date = $date; */»
            $this->date = DateUtil::formatDatetime($date, 'datetimebrief');
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
        «IF !targets('1.3.x')»
            namespace «appNamespace»\TaggedObjectMeta;

            use «appNamespace»\TaggedObjectMeta\Base\Abstract«appName»;

        «ENDIF»
        /**
         * This class provides object meta data for the Tag module.
         */
        «IF targets('1.3.x')»
        class «appName»_TaggedObjectMeta_«appName» extends «appName»_TaggedObjectMeta_Base_Abstract«appName»
        «ELSE»
        class «appName» extends Abstract«appName»
        «ENDIF»
        {
            // feel free to extend the tag support here
        }
    '''
}
