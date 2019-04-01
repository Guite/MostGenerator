package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Tag {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('TaggedObjectMeta/' + appName + '.php', tagBaseClass, tagImpl)
    }

    def private tagBaseClass(Application it) '''
        namespace «appNamespace»\TaggedObjectMeta\Base;

        use DateTimeInterface;
        use IntlDateFormatter;
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
         «IF !targets('3.0')»
         *
         * @param int $objectId Identifier of treated object
         * @param int $areaId Name of hook area
         * @param string $module Name of the owning module
         * @param string $urlString **deprecated**
         * @param UrlInterface $urlObject Object carrying url arguments
         «ENDIF»
         */
        function __construct(
            «IF targets('3.0')»int «ENDIF»$objectId,
            «IF targets('3.0')»int «ENDIF»$areaId,
            «IF targets('3.0')»string «ENDIF»$module,
            «IF targets('3.0')»string «ENDIF»$urlString = null,
            UrlInterface $urlObject = null
        ) {
            // call base constructor to store arguments in member vars
            parent::__construct($objectId, $areaId, $module, $urlString, $urlObject);

            // derive object type from url object
            $urlArgs = $urlObject->getArgs();
            $objectType = isset($urlArgs['ot']) ? $urlArgs['ot'] : '«getLeadingEntity.name.formatForCode»';

            $this->setContainer(\ServiceUtil::getManager());

            $repository = $this->container->get('«appService».entity_factory')->getRepository($objectType);
            $entity = $repository->selectById($objectId, false);
            if (null === $entity) {
                return;
            }

            $permissionHelper = $this->container->get('«appService».permission_helper');
            if (!$permissionHelper->mayRead($entity)) {
                return;
            }

            $entityDisplayHelper = $this->container->get('«appService».entity_display_helper');
            $this->setObjectTitle($entityDisplayHelper->getFormattedTitle($entity));

            $dateFieldName = $entityDisplayHelper->getStartDateFieldName($objectType);
            if ('' !== $dateFieldName) {
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
         */
        public function setObjectTitle(«IF targets('3.0')»string «ENDIF»$title)«IF targets('3.0')»: void«ENDIF»
        {
            $this->title = $title;
        }

        /**
         * Sets the object date.
         *
         * @param DateTimeInterface|string $date
         */
        public function setObjectDate($date)«IF targets('3.0')»: void«ENDIF»
        {
            if ($date instanceof DateTimeInterface) {
                $locale = $this->container->get('request_stack')->getCurrentRequest()->getLocale();
                $formatter = new IntlDateFormatter($locale, IntlDateFormatter::NONE, IntlDateFormatter::NONE);
                $this->date = $formatter->format($date->getTimestamp());
        	} else {
                $this->date = $date;
            }
        }

        /**
         * Sets the object author.
         */
        public function setObjectAuthor(«IF targets('3.0')»string «ENDIF»$author)«IF targets('3.0')»: void«ENDIF»
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
