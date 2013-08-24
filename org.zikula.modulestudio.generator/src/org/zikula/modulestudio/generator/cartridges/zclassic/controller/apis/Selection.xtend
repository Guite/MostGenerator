package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Selection {
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating selection api')
        val apiPath = getAppSourceLibPath + 'Api/'
        val apiClassSuffix = if (!targets('1.3.5')) 'Api' else ''
        val apiFileName = 'Selection' + apiClassSuffix + '.php'
        fsa.generateFile(apiPath + 'Base/' + apiFileName, selectionBaseFile)
        fsa.generateFile(apiPath + apiFileName, selectionFile)
    }

    def private selectionBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «selectionBaseClass»
    '''

    def private selectionFile(Application it) '''
        «fh.phpFileHeader(it)»
        «selectionImpl»
    '''

    def private selectionBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Api\Base;

            use «appNamespace»\Util\ControllerUtil;

            use LogUtil;
            use ModUtil;
            use Zikula_AbstractApi;

        «ENDIF»
        /**
         * Selection api base class.
         */
        class «IF targets('1.3.5')»«appName»_Api_Base_Selection«ELSE»SelectionApi«ENDIF» extends Zikula_AbstractApi
        {
            «selectionBaseImpl»
        }
    '''

    def private selectionBaseImpl(Application it) '''
        /**
         * Gets the list of identifier fields for a given object type.
         *
         * @param string $args['ot'] The object type to be treated (optional).
         *
         * @return array List of identifier field names.
         */
        public function getIdFields(array $args = array())
        {
            $objectType = $this->determineObjectType($args, 'getIdFields');
            «IF targets('1.3.5')»
            $entityClass = '«appName»_Entity_' . ucfirst($objectType);
            «ELSE»
            $entityClass = '\\«appName»\\Entity\\' . ucfirst($objectType) . 'Entity';
            «ENDIF»
            $objectTemp = new $entityClass(); 
            $idFields = $objectTemp->get_idFields();

            return $idFields;
        }

        /**
         * Selects a single entity.
         *
         * @param string  $args['ot']       The object type to retrieve (optional).
         * @param mixed   $args['id']       The id (or array of ids) to use to retrieve the object (default=null).
         «IF hasSluggable»
          * @param string  $args['slug']     Slug to use as selection criteria instead of id (optional) (default=null).
         «ENDIF»
         * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true).
         * @param boolean $args['slimMode'] If activated only some basic fields are selected without using any joins (optional) (default=false).
         *
         * @return mixed Desired entity object or null.
         */
        public function getEntity(array $args = array())
        {
            if (!isset($args['id'])«IF hasSluggable» && !isset($args['slug'])«ENDIF») {
                return LogUtil::registerArgsError();
            }
            $objectType = $this->determineObjectType($args, 'getEntity');
            $repository = $this->getRepository($objectType);

            $idValues = $args['id'];
            «IF hasSluggable»
                $slug = isset($args['slug']) ? $args['slug'] : null;
            «ENDIF»
            $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
            $slimMode = isset($args['slimMode']) ? ((bool) $args['slimMode']) : false;

            «IF hasSluggable»
                $entity = null;
                if ($slug != null) {
                    $entity = $repository->selectBySlug($slug, $useJoins, $slimMode);
                } else {
                    $entity = $repository->selectById($idValues, $useJoins, $slimMode);
                }
            «ELSE»
                $entity = $repository->selectById($idValues, $useJoins, $slimMode);
            «ENDIF»

            return $entity;
        }

        /**
         * Selects a list of entities by different criteria.
         *
         * @param string  $args['ot']       The object type to retrieve (optional).
         * @param string  $args['where']    The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $args['orderBy']  The order-by clause to use when retrieving the collection (optional) (default='').
         * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true).
         * @param boolean $args['slimMode'] If activated only some basic fields are selected without using any joins (optional) (default=false).
         *
         * @return Array with retrieved collection.
         */
        public function getEntities(array $args = array())
        {
            $objectType = $this->determineObjectType($args, 'getEntities');
            $repository = $this->getRepository($objectType);

            $where = isset($args['where']) ? $args['where'] : '';
            $orderBy = isset($args['orderBy']) ? $args['orderBy'] : '';
            $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
            $slimMode = isset($args['slimMode']) ? ((bool) $args['slimMode']) : false;

            return $repository->selectWhere($where, $orderBy, $useJoins, $slimMode);
        }

        /**
         * Selects a list of entities by different criteria.
         *
         * @param string  $args['ot']             The object type to retrieve (optional).
         * @param string  $args['where']          The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $args['orderBy']        The order-by clause to use when retrieving the collection (optional) (default='').
         * @param integer $args['currentPage']    Where to start selection.
         * @param integer $args['resultsPerPage'] Amount of items to select.
         * @param boolean $args['useJoins']       Whether to include joining related objects (optional) (default=true).
         * @param boolean $args['slimMode']       If activated only some basic fields are selected without using any joins (optional) (default=false).
         *
         * @return Array with retrieved collection and amount of total records affected by this query.
         */
        public function getEntitiesPaginated(array $args = array())
        {
            $objectType = $this->determineObjectType($args, 'getEntitiesPaginated');
            $repository = $this->getRepository($objectType);

            $where = isset($args['where']) ? $args['where'] : '';
            $orderBy = isset($args['orderBy']) ? $args['orderBy'] : '';
            $currentPage = isset($args['currentPage']) ? $args['currentPage'] : 1;
            $resultsPerPage = isset($args['resultsPerPage']) ? $args['resultsPerPage'] : 25;
            $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
            $slimMode = isset($args['slimMode']) ? ((bool) $args['slimMode']) : false;

            return $repository->selectWherePaginated($where, $orderBy, $currentPage, $resultsPerPage, $useJoins, $slimMode);
        }

        /**
         * Determines object type using controller util methods.
         *
         * @param string $args['ot'] The object type to retrieve (optional).
         * @param string $methodName Name of calling method.
         *
         * @return string the object type.
         */
        protected function determineObjectType(array $args = array(), $methodName = '')
        {
            $objectType = isset($args['ot']) ? $args['ot'] : '';
            $controllerHelper = new «IF targets('1.3.5')»«appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
            $utilArgs = array('api' => 'selection', 'action' => $methodName);
            if (!in_array($objectType, $controllerHelper->getObjectTypes('api', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('api', $utilArgs);
            }

            return $objectType;
        }

        /**
         * Returns repository instance for a certain object type.
         *
         * @param string $objectType The desired object type.
         *
         * @return mixed Repository class instance or null.
         */
        protected function getRepository($objectType = '')
        {
            if (empty($objectType)) {
                return LogUtil::registerArgsError();
            }

            «IF targets('1.3.5')»
                $entityClass = '«appName»_Entity_' . ucwords($objectType);
            «ELSE»
                $entityClass = '\\«appName»\\Entity\\' . ucwords($objectType) . 'Entity';
            «ENDIF»

            return $this->entityManager->getRepository($entityClass);
        }
        «IF hasTrees»

            /**
             * Selects tree of given object type.
             *
             * @param string  $args['ot']       The object type to retrieve (optional).
             * @param integer $args['rootId']   Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree.
             * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true).
             *
             * @return array|ArrayCollection retrieved data array or tree node objects.
             */
            public function getTree(array $args = array())
            {
                if (!isset($args['rootId'])) {
                    return LogUtil::registerArgsError();
                }
                $rootId = $args['rootId'];

                $objectType = $this->determineObjectType($args, 'getTree');
                $repository = $this->getRepository($objectType);

                $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;

                return $repository->selectTree($rootId, $useJoins);
            }

            /**
             * Gets all trees at once.
             *
             * @param string  $args['ot']       The object type to retrieve (optional).
             * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true).
             *
             * @return array|ArrayCollection retrieved data array or tree node objects.
             */
            public function getAllTrees(array $args = array())
            {
                $objectType = $this->determineObjectType($args, 'getTree');
                $repository = $this->getRepository($objectType);

                $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;

                return $repository->selectAllTrees($useJoins);
            }
        «ENDIF»
    '''

    def private selectionImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Api;

        «ENDIF»
        /**
         * Selection api implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Api_Selection extends «appName»_Api_Base_Selection
        «ELSE»
        class SelectionApi extends Base\SelectionApi
        «ENDIF»
        {
            // feel free to extend the selection api here
        }
    '''
}
