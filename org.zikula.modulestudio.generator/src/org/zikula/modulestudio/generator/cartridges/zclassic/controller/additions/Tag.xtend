package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Tag {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val tagPath = getAppSourceLibPath + 'TaggedObjectMeta/'
        fsa.generateFile(tagPath + 'Base/' + appName + '.php', tagBaseFile)
        fsa.generateFile(tagPath + appName + '.php', tagFile)
        //new TagView().generate(it, fsa)
    }

    def private tagBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «tagBaseClass»
    '''

    def private tagFile(Application it) '''
        «fh.phpFileHeader(it)»
        «tagImpl»
    '''

    def private tagBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\TaggedObjectMeta\Base;

            use DateUtil;
            use SecurityUtil;
            use ServiceUtil;
            use UserUtil;
            use Zikula\Core\ModUrl;

        «ENDIF»
        /**
         * This class provides object meta data for the Tag module.
         */
        «IF targets('1.3.5')»
        class «appName»_TaggedObjectMeta_Base_«appName» extends Tag_AbstractTaggedObjectMeta
        «ELSE»
        class «appName» extends \Tag\AbstractTaggedObjectMeta
        «ENDIF»
        {
            «tagBaseImpl»
        }
    '''

    def private tagBaseImpl(Application it) '''
        /**
         * Constructor.
         *
         * @param integer             $objectId  Identifier of treated object.
         * @param integer             $areaId    Name of hook area.
         * @param string              $module    Name of the owning module.
         * @param string              $urlString **deprecated**
         * @param «IF targets('1.3.5')»Zikula_«ENDIF»ModUrl $urlObject Object carrying url arguments.
         */
        function __construct($objectId, $areaId, $module, $urlString = null, «IF targets('1.3.5')»Zikula_«ENDIF»ModUrl $urlObject = null)
        {
            // call base constructor to store arguments in member vars
            parent::__construct($objectId, $areaId, $module, $urlString, $urlObject);

            // derive object type from url object
            $urlArgs = $urlObject->getArgs();
            $objectType = isset($urlArgs['ot']) ? $urlArgs['ot'] : '«getLeadingEntity.name.formatForCode»';

            $component = $module . ':' . ucwords($objectType) . ':';
            $perm = SecurityUtil::checkPermission($component, $objectId . '::', ACCESS_READ);
            if (!$perm) {
                return;
            }

            «IF targets('1.3.5')»
                $entityClass = $module . '_Entity_' . ucwords($objectType);
            «ELSE»
                $entityClass = '\\' . $module . '\\Entity\\' . ucwords($objectType) . 'Entity';
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);
            $useJoins = false;

            /** TODO support composite identifiers properly at this point */
            $entity = $repository->selectById($objectId, $useJoins);
            if ($entity === false || (!is_array($entity) && !is_object($entity))) {
                return;
            }

            $this->setObjectTitle($entity[$repository->getTitleFieldName()]);

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
        «IF !targets('1.3.5')»
            namespace «appNamespace»\TaggedObjectMeta;

            use Base\«appName» as Base«appName»;

        «ENDIF»
        /**
         * This class provides object meta data for the Tag module.
         */
        «IF targets('1.3.5')»
        class «appName»_TaggedObjectMeta_«appName» extends «appName»_TaggedObjectMeta_Base_«appName»
        «ELSE»
        class «appName» extends Base«appName»
        «ENDIF»
        {
            // feel free to extend the tag support here
        }
    '''
}
