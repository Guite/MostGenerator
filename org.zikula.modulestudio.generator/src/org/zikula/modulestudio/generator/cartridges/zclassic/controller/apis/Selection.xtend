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
        println('Generating selection api')
        generateClassPair(fsa, getAppSourceLibPath + 'Api/Selection' + (if (targets('1.3.x')) '' else 'Api') + '.php',
            fh.phpFileContent(it, selectionBaseClass), fh.phpFileContent(it, selectionImpl)
        )
    }

    def private selectionBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api\Base;

            use ModUtil;
            use Zikula\Core\Api\AbstractApi;

        «ENDIF»
        /**
         * Selection api base class.
         */
        class «IF targets('1.3.x')»«appName»_Api_Base_Selection extends Zikula_AbstractApi«ELSE»SelectionApi extends AbstractApi«ENDIF»
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
            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
            «ELSE»
                $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucfirst($objectType) . 'Entity';
            «ENDIF»

            $em = $this->get('doctrine.entitymanager');

            $meta = $em->getClassMetadata($entityClass);
            if ($this->hasCompositeKeys($objectType)) {
                $idFields = $meta->getIdentifierFieldNames();
            } else {
                $idFields = array($meta->getSingleIdentifierFieldName());
            }

            return $idFields;
        }

        /**
         * Checks whether a certain entity type uses composite keys or not.
         *
         * @param string $objectType The object type to retrieve.
         *
         * @return boolean Whether composite keys are used or not.
         */
        protected function hasCompositeKeys($objectType)
        {
            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«appName.formatForDB».controller_helper');
            «ENDIF»

            return $controllerHelper->hasCompositeKeys($objectType);
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
                throw new \InvalidArgumentException(__('Invalid identifier received.'));
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
         * @param string  $args['idList']   A list of ids to select (optional) (default=array()).
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

            $idList = isset($args['idList']) && is_array($args['idList']) ? $args['idList'] : array();
            $where = isset($args['where']) ? $args['where'] : '';
            $orderBy = isset($args['orderBy']) ? $args['orderBy'] : '';
            $useJoins = isset($args['useJoins']) ? ((bool) $args['useJoins']) : true;
            $slimMode = isset($args['slimMode']) ? ((bool) $args['slimMode']) : false;

            if (!empty($idList)) {
               return $repository->selectByIdList($idList, $useJoins, $slimMode);
            }

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
            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«appName.formatForDB».controller_helper');
            «ENDIF»
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
                throw new \InvalidArgumentException(__('Invalid object type received.'));
            }

            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
                $repository = $this->entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $this->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();
            «ENDIF»

            return $repository;
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
                    throw new \InvalidArgumentException(__('Invalid root identifier received.'));
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
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api;

            use «appNamespace»\Api\Base\SelectionApi as BaseSelectionApi;

        «ENDIF»
        /**
         * Selection api implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Api_Selection extends «appName»_Api_Base_Selection
        «ELSE»
        class SelectionApi extends BaseSelectionApi
        «ENDIF»
        {
            // feel free to extend the selection api here
        }
    '''
}
