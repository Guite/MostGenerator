package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Selection {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (isLegacy) {
            generateClassPair(fsa, getAppSourceLibPath + 'Api/Selection.php',
                fh.phpFileContent(it, selectionApiBaseClass), fh.phpFileContent(it, selectionApiImpl)
            )
        } else {
            generateClassPair(fsa, getAppSourceLibPath + 'Helper/SelectionHelper.php',
                fh.phpFileContent(it, selectionHelperBaseClass), fh.phpFileContent(it, selectionHelperImpl)
            )
        }
    }

    def private selectionApiBaseClass(Application it) '''
        /**
         * Selection api base class.
         */
        abstract class «appName»_Api_Base_AbstractSelection extends Zikula_AbstractApi
        {
            «selectionBaseImpl»
        }
    '''

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
             * Constructor.
             * Initialises member vars.
             *
             * @param ContainerBuilder    $container        ContainerBuilder service instance
             * @param ObjectManager       $om               The object manager to be used for retrieving entity meta data
             * @param TranslatorInterface $translator       Translator service instance
             * @param ControllerHelper    $controllerHelper ControllerHelper service instance
             */
            public function __construct(ContainerBuilder $container, ObjectManager $om, TranslatorInterface $translator, ControllerHelper $controllerHelper)
            {
                $this->container = $container;
                $this->om = $om;
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
         «IF isLegacy»
         * @param string $args['ot'] The object type to be treated (optional)
         «ELSE»
         * @param string $objectType The object type to be treated (optional)
         «ENDIF»
         *
         * @return array List of identifier field names
         */
        public function getIdFields(«IF isLegacy»array $args = array()«ELSE»$objectType = ''«ENDIF»)
        {
            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getIdFields');
            «IF isLegacy»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);

                $meta = $this->entityManager->getClassMetadata($entityClass);
            «ELSE»
                $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucfirst($objectType) . 'Entity';

                $meta = $this->om->getClassMetadata($entityClass);
            «ENDIF»

            if ($this->hasCompositeKeys($objectType)) {
                $idFields = $meta->getIdentifierFieldNames();
            } else {
                $idFields = «IF isLegacy»array(«ELSE»[«ENDIF»$meta->getSingleIdentifierFieldName()«IF isLegacy»)«ELSE»]«ENDIF»;
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
            «IF isLegacy»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);

            «ENDIF»
            return $«IF !isLegacy»this->«ENDIF»controllerHelper->hasCompositeKeys($objectType);
        }

        /**
         * Selects a single entity.
         *
         «IF isLegacy»
         * @param string  $args['ot']       The object type to be treated (optional)
         * @param mixed   $args['id']       The id (or array of ids) to use to retrieve the object (default=null)
         «IF hasSluggable»
         * @param string  $args['slug']     Slug to use as selection criteria instead of id (optional) (default=null)
         «ENDIF»
         * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true)
         * @param boolean $args['slimMode'] If activated only some basic fields are selected without using any joins (optional) (default=false)
         «ELSE»
         * @param string $objectType The object type to be treated (optional)
         * @param mixed  $id         The id (or array of ids) to use to retrieve the object (default=null)
         «IF hasSluggable»
         * @param string $slug       Slug to use as selection criteria instead of id (optional) (default=null)
         «ENDIF»
         * @param boolean $useJoins  Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode  If activated only some basic fields are selected without using any joins (optional) (default=false)
         «ENDIF»
         *
         * @return mixed Desired entity object or null
         */
        public function getEntity(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $id = ''«IF hasSluggable», $slug = ''«ENDIF», $useJoins = true, $slimMode = false«ENDIF»)
        {
            «IF isLegacy»
                if (!isset($args['id'])«IF hasSluggable» && !isset($args['slug'])«ENDIF») {
                    $dom = ZLanguage::getModuleDomain('«appName»');
                    throw new \InvalidArgumentException(__('Invalid identifier received.', $dom));
                }
            «ELSE»
                if (empty($id)«IF hasSluggable» && empty($slug)«ENDIF») {
                    throw new \InvalidArgumentException($this->translator->__('Invalid identifier received.'));
                }
            «ENDIF»

            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getEntity');
            $repository = $this->getRepository($objectType);

            «IF isLegacy»
                $id = $args['id'];
                «IF hasSluggable»
                    $slug = isset($args['slug']) ? $args['slug'] : null;
                «ENDIF»
            «ENDIF»
            «IF isLegacy»
                $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
                $slimMode = isset($args['slimMode']) ? ((bool) $args['slimMode']) : false;
            «ELSE»
                $useJoins = (bool) $useJoins;
                $slimMode = (bool) $slimMode; 
            «ENDIF»

            «IF hasSluggable»
                $entity = null;
                if (null !== $slug«IF isLegacy» && '' != $slug«ENDIF») {
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
         «IF isLegacy»
         * @param string  $args['ot']       The object type to retrieve (optional)
         * @param string  $args['idList']   A list of ids to select (optional) (default=array())
         * @param string  $args['where']    The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $args['orderBy']  The order-by clause to use when retrieving the collection (optional) (default='')
         * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true)
         * @param boolean $args['slimMode'] If activated only some basic fields are selected without using any joins (optional) (default=false)
         «ELSE»
         * @param string  $objectType The object type to retrieve (optional)
         * @param string  $idList     A list of ids to select (optional) (default=[])
         * @param string  $where      The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $orderBy    The order-by clause to use when retrieving the collection (optional) (default='')
         * @param boolean $useJoins   Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode   If activated only some basic fields are selected without using any joins (optional) (default=false)
         «ENDIF»
         *
         * @return array with retrieved collection
         */
        public function getEntities(«IF isLegacy»array $args = array()«ELSE»$objectType = '', array $idList = [], $where = '', $orderBy = '', $useJoins = true, $slimMode = false«ENDIF»)
        {
            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getEntities');
            $repository = $this->getRepository($objectType);

            «IF isLegacy»
                $idList = isset($args['idList']) && is_array($args['idList']) ? $args['idList'] : «IF isLegacy»array()«ELSE»[]«ENDIF»;
                $where = isset($args['where']) ? $args['where'] : '';
                $orderBy = isset($args['orderBy']) ? $args['orderBy'] : '';
                $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
                $slimMode = isset($args['slimMode']) ? ((bool) $args['slimMode']) : false;
            «ELSE»
                $useJoins = (bool) $useJoins;
                $slimMode = (bool) $slimMode; 
            «ENDIF»

            if (!empty($idList)) {
               return $repository->selectByIdList($idList, $useJoins, $slimMode);
            }

            return $repository->selectWhere($where, $orderBy, $useJoins, $slimMode);
        }

        /**
         * Selects a list of entities by different criteria.
         *
         «IF isLegacy»
         * @param string  $args['ot']             The object type to retrieve (optional)
         * @param string  $args['where']          The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $args['orderBy']        The order-by clause to use when retrieving the collection (optional) (default='')
         * @param integer $args['currentPage']    Where to start selection
         * @param integer $args['resultsPerPage'] Amount of items to select
         * @param boolean $args['useJoins']       Whether to include joining related objects (optional) (default=true)
         * @param boolean $args['slimMode']       If activated only some basic fields are selected without using any joins (optional) (default=false)
         «ELSE»
         * @param string  $objectType     The object type to retrieve (optional)
         * @param string  $where          The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='')
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode       If activated only some basic fields are selected without using any joins (optional) (default=false)
         «ENDIF»
         *
         * @return array with retrieved collection and amount of total records affected by this query
         */
        public function getEntitiesPaginated(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $where = '', $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true, $slimMode = false«ENDIF»)
        {
            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getEntitiesPaginated');
            $repository = $this->getRepository($objectType);

            «IF isLegacy»
                $where = isset($args['where']) ? $args['where'] : '';
                $orderBy = isset($args['orderBy']) ? $args['orderBy'] : '';
                $currentPage = isset($args['currentPage']) ? $args['currentPage'] : 1;
                $resultsPerPage = isset($args['resultsPerPage']) ? $args['resultsPerPage'] : 25;
                $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
                $slimMode = isset($args['slimMode']) ? ((bool) $args['slimMode']) : false;
            «ELSE»
                $useJoins = (bool) $useJoins;
                $slimMode = (bool) $slimMode; 
            «ENDIF»

            return $repository->selectWherePaginated($where, $orderBy, $currentPage, $resultsPerPage, $useJoins, $slimMode);
        }

        /**
         * Determines object type using controller util methods.
         *
         «IF isLegacy»
         * @param string $args['ot'] The object type to be treated (optional)
         «ELSE»
         * @param string $objectType The object type to be treated (optional)
         «ENDIF»
         * @param string $methodName Name of calling method
         *
         * @return string the object type
         */
        protected function determineObjectType(«IF isLegacy»array $args = array()«ELSE»$objectType = ''«ENDIF», $methodName = '')
        {
            «IF isLegacy»
                $objectType = isset($args['ot']) ? $args['ot'] : '';
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);

            «ENDIF»
            $utilArgs = «IF isLegacy»array(«ELSE»[«ENDIF»'api' => 'selection', 'action' => $methodName«IF isLegacy»)«ELSE»]«ENDIF»;
            if (!in_array($objectType, $«IF !isLegacy»this->«ENDIF»controllerHelper->getObjectTypes('api', $utilArgs))) {
                $objectType = $«IF !isLegacy»this->«ENDIF»controllerHelper->getDefaultObjectType('api', $utilArgs);
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
                «IF isLegacy»
                    $dom = ZLanguage::getModuleDomain('«appName»');
                    throw new \InvalidArgumentException(__('Invalid object type received.', $dom));
                «ELSE»
                    throw new \InvalidArgumentException($this->translator->__('Invalid object type received.'));
                «ENDIF»
            }

            «IF isLegacy»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
                $repository = $this->entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $this->container->get('«appService».' . $objectType . '_factory')->getRepository();
            «ENDIF»

            return $repository;
        }
        «IF hasTrees»

            /**
             * Selects tree of given object type.
             *
             «IF isLegacy»
             * @param string  $args['ot']       The object type to retrieve (optional)
             * @param integer $args['rootId']   Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree
             * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true)
             «ELSE»
             * @param string  $objectType The object type to retrieve (optional)
             * @param integer $rootId     Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree
             * @param boolean $useJoins   Whether to include joining related objects (optional) (default=true)
             «ENDIF»
             *
             * @return array|ArrayCollection retrieved data array or tree node objects
             */
            public function getTree(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $rootId = 0, $useJoins = true«ENDIF»)
            {
                «IF isLegacy»
                    if (!isset($args['rootId'])) {
                        $dom = ZLanguage::getModuleDomain('«appName»');
                        throw new \InvalidArgumentException(__('Invalid root identifier received.', $dom));
                    }
                    $rootId = $args['rootId'];

                «ENDIF»
                $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getTree');
                $repository = $this->getRepository($objectType);

                «IF isLegacy»
                    $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
                «ELSE»
                    $useJoins = (bool) $useJoins;
                «ENDIF»

                return $repository->selectTree($rootId, $useJoins);
            }

            /**
             * Gets all trees at once.
             *
             «IF isLegacy»
             * @param string  $args['ot']       The object type to retrieve (optional)
             * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true)
             «ELSE»
             * @param string  $objectType The object type to retrieve (optional)
             * @param boolean $useJoins   Whether to include joining related objects (optional) (default=true)
             «ENDIF»
             *
             * @return array|ArrayCollection retrieved data array or tree node objects
             */
            public function getAllTrees(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $useJoins = true«ENDIF»)
            {
                $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getTree');
                $repository = $this->getRepository($objectType);

                «IF isLegacy»
                    $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
                «ELSE»
                    $useJoins = (bool) $useJoins;
                «ENDIF»

                return $repository->selectAllTrees($useJoins);
            }
        «ENDIF»
    '''

    def private selectionApiImpl(Application it) '''
        /**
         * Selection api implementation class.
         */
        class «appName»_Api_Selection extends «appName»_Api_Base_AbstractSelection
        {
            // feel free to extend the selection api here
        }
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

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}
