package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SelectionHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for entity selections')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/SelectionHelper.php',
            fh.phpFileContent(it, selectionHelperBaseClass), fh.phpFileContent(it, selectionHelperImpl)
        )
    }

    def private selectionHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\Common\Persistence\ObjectManager;
        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Zikula\Common\Translator\TranslatorInterface;
        use «appNamespace»\Helper\ControllerHelper;

        /**
         * Selection helper base class.
         */
        abstract class AbstractSelectionHelper
        {
            /**
             * @var ContainerBuilder
             */
            protected $container;

            /**
             * @var ObjectManager The object manager to be used for determining the repository
             */
            protected $objectManager;

            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * SelectionHelper constructor.
             *
             * @param ContainerBuilder    $container        ContainerBuilder service instance
             * @param ObjectManager       $objectManager    The object manager to be used for retrieving entity meta data
             * @param TranslatorInterface $translator       Translator service instance
             * @param ControllerHelper    $controllerHelper ControllerHelper service instance
             */
            public function __construct(ContainerBuilder $container, ObjectManager $objectManager, TranslatorInterface $translator, ControllerHelper $controllerHelper)
            {
                $this->container = $container;
                $this->objectManager = $objectManager;
                $this->translator = $translator;
                $this->controllerHelper = $controllerHelper;
            }

            «selectionBaseImpl»
        }
    '''

    def private selectionBaseImpl(Application it) '''
        /**
         * Gets the list of identifier fields for a given object type.
         *
         * @param string $objectType The object type to be treated (optional)
         *
         * @return array List of identifier field names
         */
        public function getIdFields($objectType = '')
        {
            $objectType = $this->determineObjectType($objectType, 'getIdFields');
            $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucfirst($objectType) . 'Entity';

            $meta = $this->objectManager->getClassMetadata($entityClass);

            if ($this->hasCompositeKeys($objectType)) {
                $idFields = $meta->getIdentifierFieldNames();
            } else {
                $idFields = [$meta->getSingleIdentifierFieldName()];
            }

            return $idFields;
        }

        /**
         * Checks whether a certain entity type uses composite keys or not.
         *
         * @param string $objectType The object type to retrieve
         *
         * @return boolean Whether composite keys are used or not
         */
        protected function hasCompositeKeys($objectType)
        {
            return $this->controllerHelper->hasCompositeKeys($objectType);
        }

        /**
         * Selects a single entity.
         *
         * @param string $objectType The object type to be treated (optional)
         * @param mixed  $id         The id (or array of ids) to use to retrieve the object (default=null)
         «IF hasSluggable»
         * @param string $slug       Slug to use as selection criteria instead of id (optional) (default=null)
         «ENDIF»
         * @param boolean $useJoins  Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode  If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return mixed Desired entity object or null
         */
        public function getEntity($objectType = '', $id = ''«IF hasSluggable», $slug = ''«ENDIF», $useJoins = true, $slimMode = false)
        {
            if (empty($id)«IF hasSluggable» && empty($slug)«ENDIF») {
                throw new \InvalidArgumentException($this->translator->__('Invalid identifier received.'));
            }

            $objectType = $this->determineObjectType($objectType, 'getEntity');
            $repository = $this->getRepository($objectType);

            $useJoins = (bool) $useJoins;
            $slimMode = (bool) $slimMode; 

            «IF hasSluggable»
                $entity = null;
                if (null !== $slug) {
                    $entity = $repository->selectBySlug($slug, $useJoins, $slimMode);
                } else {
                    $entity = $repository->selectById($id, $useJoins, $slimMode);
                }
            «ELSE»
                $entity = $repository->selectById($id, $useJoins, $slimMode);
            «ENDIF»

            return $entity;
        }

        /**
         * Selects a list of entities by different criteria.
         *
         * @param string  $objectType The object type to retrieve (optional)
         * @param string  $idList     A list of ids to select (optional) (default=[])
         * @param string  $where      The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $orderBy    The order-by clause to use when retrieving the collection (optional) (default='')
         * @param boolean $useJoins   Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode   If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return array with retrieved collection
         */
        public function getEntities($objectType = '', array $idList = [], $where = '', $orderBy = '', $useJoins = true, $slimMode = false)
        {
            $objectType = $this->determineObjectType($objectType, 'getEntities');
            $repository = $this->getRepository($objectType);

            $useJoins = (bool) $useJoins;
            $slimMode = (bool) $slimMode; 

            if (!empty($idList)) {
               return $repository->selectByIdList($idList, $useJoins, $slimMode);
            }

            return $repository->selectWhere($where, $orderBy, $useJoins, $slimMode);
        }

        /**
         * Selects a list of entities by different criteria.
         *
         * @param string  $objectType     The object type to retrieve (optional)
         * @param string  $where          The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='')
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode       If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return array with retrieved collection and amount of total records affected by this query
         */
        public function getEntitiesPaginated($objectType = '', $where = '', $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true, $slimMode = false)
        {
            $objectType = $this->determineObjectType($objectType, 'getEntitiesPaginated');
            $repository = $this->getRepository($objectType);

            $useJoins = (bool) $useJoins;
            $slimMode = (bool) $slimMode; 

            return $repository->selectWherePaginated($where, $orderBy, $currentPage, $resultsPerPage, $useJoins, $slimMode);
        }

        /**
         * Determines object type using controller util methods.
         *
         * @param string $objectType The object type to be treated (optional)
         * @param string $methodName Name of calling method
         *
         * @return string the object type
         */
        protected function determineObjectType($objectType = '', $methodName = '')
        {
            $contextArgs = ['helper' => 'selection', 'action' => $methodName];
            if (!in_array($objectType, $this->controllerHelper->getObjectTypes('helper', $contextArgs))) {
                $objectType = $this->controllerHelper->getDefaultObjectType('helper', $contextArgs);
            }

            return $objectType;
        }

        /**
         * Returns repository instance for a certain object type.
         *
         * @param string $objectType The desired object type
         *
         * @return mixed Repository class instance or null
         */
        protected function getRepository($objectType = '')
        {
            if (empty($objectType)) {
                throw new \InvalidArgumentException($this->translator->__('Invalid object type received.'));
            }

            return $this->container->get('«appService».' . $objectType . '_factory')->getRepository();
        }
        «IF hasTrees»

            /**
             * Selects tree of given object type.
             *
             * @param string  $objectType The object type to retrieve (optional)
             * @param integer $rootId     Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree
             * @param boolean $useJoins   Whether to include joining related objects (optional) (default=true)
             *
             * @return array|ArrayCollection retrieved data array or tree node objects
             */
            public function getTree($objectType = '', $rootId = 0, $useJoins = true)
            {
                $objectType = $this->determineObjectType($objectType, 'getTree');
                $repository = $this->getRepository($objectType);

                $useJoins = (bool) $useJoins;

                return $repository->selectTree($rootId, $useJoins);
            }

            /**
             * Gets all trees at once.
             *
             * @param string  $objectType The object type to retrieve (optional)
             * @param boolean $useJoins   Whether to include joining related objects (optional) (default=true)
             *
             * @return array|ArrayCollection retrieved data array or tree node objects
             */
            public function getAllTrees($objectType = '', $useJoins = true)
            {
                $objectType = $this->determineObjectType($objectType, 'getTree');
                $repository = $this->getRepository($objectType);

                $useJoins = (bool) $useJoins;

                return $repository->selectAllTrees($useJoins);
            }
        «ENDIF»
    '''

    def private selectionHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractSelectionHelper;

        /**
         * Selection helper implementation class.
         */
        class SelectionHelper extends AbstractSelectionHelper
        {
            // feel free to extend the selection helper here
        }
    '''
}
