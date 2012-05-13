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
        val apiPath = appName.getAppSourceLibPath + 'Api/'
        fsa.generateFile(apiPath + 'Base/Selection.php', selectionBaseFile)
        fsa.generateFile(apiPath + 'Selection.php', selectionFile)
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
		/**
		 * Selection api base class.
		 */
		class «appName»_«fillingApi»Base_Selection extends Zikula_AbstractApi
		{
		    «selectionBaseImpl»
		}
    '''

    def private selectionBaseImpl(Application it) '''
        /**
         * Gets the list of identifier fields for a given object type.
         *
         * @param string $args['ot'] The object type to be treated (optional)
         *
         * @return array List of identifier field names.
         */
        public function getIdFields($args)
        {
            $objectType = $this->determineObjectType($args, 'getIdFields');
            $entityClass = '«appName»_Entity_' . ucfirst($objectType);
            $objectTemp = new $entityClass(); 
            $idFields = $objectTemp->get_idFields();
            return $idFields;
        }

        /**
         * Selects a single entity.
         *
         * @param string  $args['ot']       The object type to retrieve (optional)
         * @param mixed   $args['id']       The id (or array of ids) to use to retrieve the object (default=null).
         «IF hasSluggable»
          * @param string  $args['slug']     Slug to use as selection criteria instead of id (optional) (default=null).
         «ENDIF»
         * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true).
         *
         * @return mixed Desired entity object or null.
         */
        public function getEntity($args)
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

            «IF hasSluggable»
                $entity = null;
                if ($slug != null) {
                    $entity = $repository->selectBySlug($slug, $useJoins);
                } else {
                    $entity = $repository->selectById($idValues, $useJoins);
                }
            «ELSE»
                $entity = $repository->selectById($idValues, $useJoins);
            «ENDIF»

            return $entity;
        }

        /**
         * Selects a single entity by different criteria, using only the
         * primary string/text field«IF hasSluggable», the slug «ENDIF»and the identifier.
         * There are no joins used.
         *
         * @param string  $args['ot']       The object type to retrieve (optional)
         * @param mixed   $args['id']       The id (or array of ids) to use to retrieve the object (default=null).
         «IF hasSluggable»
          * @param string  $args['slug']     Slug to use as selection criteria instead of id (optional) (default=null).
         «ENDIF»
         *
         * @return mixed Desired entity object or null.
         */
        public function getEntitySimple($args)
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

            «IF hasSluggable»
                $entity = null;
                if ($slug != null) {
                    $entity = $repository->selectBySlugSimple($slug);
                } else {
                    $entity = $repository->selectByIdSimple($idValues);
                }
            «ELSE»
                $entity = $repository->selectByIdSimple($idValues);
            «ENDIF»

            return $entity;
        }

        /**
         * Selects a simple list of entities by different criteria, using only the
         * primary string/text field«IF hasSluggable», the slug «ENDIF»and the identifier.
         * There are no joins used.
         *
         * @param string  $args['ot']      The object type to retrieve (optional)
         * @param string  $args['where']   The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $args['orderBy'] The order-by clause to use when retrieving the collection (optional) (default='').
         *
         * @return Array with retrieved collection.
         */
        public function getEntitiesSimple($args)
        {
            $objectType = $this->determineObjectType($args, 'getEntitiesSimple');
            $repository = $this->getRepository($objectType);

            $where = isset($args['where']) ? $args['where'] : '';
            $orderBy = isset($args['orderBy']) ? $args['orderBy'] : '';

            return $repository->selectWhereSimple($where, $orderBy);
        }

        /**
         * Selects a list of entities by different criteria.
         *
         * @param string  $args['ot']       The object type to retrieve (optional)
         * @param string  $args['where']    The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $args['orderBy']  The order-by clause to use when retrieving the collection (optional) (default='').
         * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true).
         *
         * @return Array with retrieved collection.
         */
        public function getEntities($args)
        {
            $objectType = $this->determineObjectType($args, 'getEntities');
            $repository = $this->getRepository($objectType);

            $where = isset($args['where']) ? $args['where'] : '';
            $orderBy = isset($args['orderBy']) ? $args['orderBy'] : '';
            $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;

            return $repository->selectWhere($where, $orderBy, $useJoins);
        }

        /**
         * Selects a list of entities by different criteria.
         *
         * @param string  $args['ot']             The object type to retrieve (optional)
         * @param string  $args['where']          The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $args['orderBy']        The order-by clause to use when retrieving the collection (optional) (default='').
         * @param integer $args['currentPage']    Where to start selection
         * @param integer $args['resultsPerPage'] Amount of items to select
         * @param boolean $args['useJoins']       Whether to include joining related objects (optional) (default=true).
         *
         * @return Array with retrieved collection and amount of total records affected by this query.
         */
        public function getEntitiesPaginated($args)
        {
            $objectType = $this->determineObjectType($args, 'getEntitiesPaginated');
            $repository = $this->getRepository($objectType);

            $where = isset($args['where']) ? $args['where'] : '';
            $orderBy = isset($args['orderBy']) ? $args['orderBy'] : '';
            $currentPage = isset($args['currentPage']) ? $args['currentPage'] : 1;
            $resultsPerPage = isset($args['resultsPerPage']) ? $args['resultsPerPage'] : 25;
            $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;

            if ($orderBy == 'RAND()') {
                // random ordering is disabled for now, see https://github.com/Guite/MostGenerator/issues/143
                $orderBy = $repository->getDefaultSortingField();
            }

            return $repository->selectWherePaginated($where, $orderBy, $currentPage, $resultsPerPage, $useJoins);
        }

        /**
         * Determines object type using controller util methods.
         *
         * @param string $args['ot'] The object type to retrieve (optional)
         * @param string $methodName Name of calling method
         */
        protected function determineObjectType($args, $methodName = '')
        {
            $objectType = isset($args['ot']) ? $args['ot'] : '';
            $utilArgs = array('api' => 'selection', 'action' => $methodName);
            if (!in_array($objectType, «appName»_Util_Controller::getObjectTypes('api', $utilArgs))) {
                $objectType = «appName»_Util_Controller::getDefaultObjectType('api', $utilArgs);
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
            return $this->entityManager->getRepository('«appName»_Entity_' . ucfirst($objectType));
        }
        «IF hasTrees»

            /**
             * Selects tree of given object type.
             *
             * @param string  $args['ot']       The object type to retrieve (optional)
             * @param integer $args['rootId']   Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree.
             * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true).
             *
             * @return array|ArrayCollection retrieved data array or tree node objects.
             */
            public function getTree($args)
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
             * @param string  $args['ot']       The object type to retrieve (optional)
             * @param boolean $args['useJoins'] Whether to include joining related objects (optional) (default=true).
             *
             * @return array|ArrayCollection retrieved data array or tree node objects.
             */
            public function getAllTrees($args)
            {
                $objectType = $this->determineObjectType($args, 'getTree');
                $repository = $this->getRepository($objectType);

                $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;

                return $repository->selectAllTrees($useJoins);
            }
        «ENDIF»
    '''

    def private selectionImpl(Application it) '''
        /**
         * Selection api implementation class.
         */
        class «appName»_«fillingApi»Selection extends «appName»_«fillingApi»Base_Selection
        {
            // feel free to extend the selection api here
        }
    '''
}
