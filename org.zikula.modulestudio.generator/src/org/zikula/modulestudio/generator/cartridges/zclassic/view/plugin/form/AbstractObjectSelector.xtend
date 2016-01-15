package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AbstractObjectSelector {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    // 1.3.x only
    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/AbstractObjectSelector.php',
            fh.phpFileContent(it, selectorBaseImpl), fh.phpFileContent(it, selectorImpl)
        )
    }

    def private selectorBaseImpl(Application it) '''
        use Doctrine\Common\Collections\Collection;
        use Doctrine\ORM\QueryBuilder;

        /**
         * Abstract object selector plugin base class.
         */
        abstract class «appName»_Form_Plugin_Base_AbstractObjectSelector extends Zikula_Form_Plugin_DropdownList
        {
            «memberVars»

            /**
             * Get filename of this file.
             * The information is used to re-establish the plugins on postback.
             *
             * @return string
             */
            public function getFilename()
            {
                return __FILE__;
            }

            «createPlugin»

            «load»

            «renderAttributes»

            «loadItems»

            «validate»

            «setSelectedValue»

            «relationPreProcess»

            «relationPostProcess»

            «buildWhereClause»

            «helperMethods»
        }
    '''

    def private memberVars(Application it) '''
        /**
         * Name of the owning module.
         *
         * @var string
         */
        public $name = '«appName»';

        /**
         * The treated object type.
         *
         * @var string
         */
        public $objectType = '';

        /**
         * Reverse alias for inverse method calls.
         *
         * @var string
         */
        public $aliasReverse = '';

        /**
         * List of identifier field names.
         *
         * @var array
         */
        public $idFields = array();

        /**
         * Where clause.
         *
         * @var string
         */
        public $where = '';

        /**
         * OrderBy clause.
         *
         * @var string
         */
        public $orderBy = '';

        /**
         * The amount of objects to select.
         * A value of 0 causes the inclusion of all existing objects.
         *
         * @var integer
         */
        public $resultsPerPage = 0;

        /**
         * The current page offset.
         *
         * @var integer
         */
        public $currentPage = 1;

        /**
         * Whether to display an empty value to select nothing.
         *
         * @var boolean
         */
        public $showEmptyValue = false;

        /**
         * List of preselected items.
         *
         * @var boolean
         */
        public $preselectedItems = array();

        /**
         * List of selected items.
         *
         * @var boolean
         */
        public $selectedItems = array();
    '''

    def private createPlugin(Application it) '''
        /**
         * Create event handler.
         *
         * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
         * @param array            &$params Parameters passed from the Smarty plugin function.
         *
         * @see    Zikula_Form_AbstractPlugin
         * @return void
         */
        public function create(Zikula_Form_View $view, &$params)
        {
            if (!isset($params['objectType']) || empty($params['objectType'])) {
                $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»RelationSelectorList', 'objectType')));
            }
            $this->objectType = $params['objectType'];
            unset($params['objectType']);

            if (!isset($params['aliasReverse']) || empty($params['aliasReverse'])) {
                $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('relationtesterRelationSelectorList', 'aliasReverse')));
            }
            $this->aliasReverse = $params['aliasReverse'];
            unset($params['aliasReverse']);

            if (isset($params['where'])) {
                $this->where = $params['where'];
                unset($params['where']);
            }

            if (isset($params['orderBy'])) {
                $this->orderBy = $params['orderBy'];
                unset($params['orderBy']);
            } elseif (isset($params['orderby'])) {
                $this->orderBy = $params['orderby'];
                unset($params['orderby']);
            }

            if (isset($params['num'])) {
                $this->resultsPerPage = intval($params['num']);
                unset($params['num']);
            }

            if (isset($params['pos'])) {
                $this->currentPage = intval($params['pos']);
                unset($params['pos']);
            }

            if (isset($params['showEmptyValue'])) {
                $this->showEmptyValue = (bool) $params['showEmptyValue'];
                unset($params['showEmptyValue']);
            }

            parent::create($view, $params);

            $this->idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $this->objectType));
            $this->cssClass .= ' ' . $this->getStyleClass() . ' ' . strtolower($this->objectType);
        }

        /**
         * Entry point for customised css class.
         */
        protected function getStyleClass()
        {
            return 'z-form-itemlist';
        }
    '''

    def private load(Application it) '''
        /**
         * Load event handler.
         *
         * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
         * @param array            &$params Parameters passed from the Smarty plugin function.
         *
         * @return void
         */
        public function load(Zikula_Form_View $view, &$params)
        {
            if (!$this->mandatory) {
                $this->addItem('', '');
            }
            if ($this->showEmptyValue != false) {
                $this->addItem('- - -', 0);
            }
            
            $fetchItemsDuringLoad = isset($params['fetchItemsDuringLoad']) ? $params['fetchItemsDuringLoad'] : true;
        
            if ($fetchItemsDuringLoad) {
                $items = $this->loadItems($params);

                foreach ($items as $item) {
                    if (!$this->isIncluded($item)) {
                        continue;
                    }

                    $itemLabel = $this->createItemLabel($item);
                    $itemId = $this->createItemIdentifier($item);
                    $this->addItem($itemLabel, $itemId);
                }
            }

            parent::load($view, $params);
        }
    '''

    def private renderAttributes(Application it) '''
        /**
         * Render attributes.
         *
         * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
         *
         * @return string
         */
        public function renderAttributes(Zikula_Form_View $view)
        {
            unset($this->attributes['linkingItem']);
            $attributes = parent::renderAttributes($view);

            return $attributes;
        }
    '''

    def private loadItems(Application it) '''
        /**
         * Performs the actual data selection.
         *
         * @param array &$params Parameters passed from the Smarty plugin function.
         *
         * @return array List of selected objects.
         */
        protected function loadItems(&$params)
        {
            $selectionArgs = array(
                'ot' => $this->objectType,
                'where' => $this->where,
                'orderBy' => $this->orderBy,
                'useJoins' => false
            );

            if ($this->resultsPerPage < 1) {
                // no pagination
                $entities = ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);

                return $entities;
            }

            // pagination
            $selectionArgs['currentPage'] = $this->currentPage;
            $selectionArgs['resultsPerPage'] = $this->resultsPerPage;

            list($entities, $objectCount) = ModUtil::apiFunc($this->name, 'selection', 'getEntitiesPaginated', $selectionArgs);

            return $entities;
        }
    '''

    def private validate(Application it) '''
        /**
         * Validates the input.
         *
         * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
         *
         * @return void
         */
        public function validate(Zikula_Form_View $view)
        {
            $this->clearValidation($view);
        }
    '''

    def private setSelectedValue(Application it) '''
        /**
         * Set the selected value.
         *
         * @param mixed $value Selected value.
         *
         * @return void
         */
        public function setSelectedValue($value)
        {
            $newValue = null;

            if ($this->selectionMode == 'single') {
                if ($value instanceof Zikula_EntityAccess && method_exists($value, 'createCompositeIdentifier')) {
                    $newValue = $value->createCompositeIdentifier();
                } elseif (is_array($value)) {
                    $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $value['_objectType']));
                    $newValue = $value[$idFields[0]];
                } else {
                    $newValue[] = $value;
                }
            } else {
                $newValue = array();
                if (is_array($value) || $value instanceof Collection) {
                    foreach ($value as $entity) {
                        if ($entity instanceof Zikula_EntityAccess && method_exists($entity, 'createCompositeIdentifier')) {
                            $newValue[] = $entity->createCompositeIdentifier();
                        } elseif (is_array($entity)) {
                            $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $entity['_objectType']));
                            $newValue[] = $entity[$idFields[0]];
                        } else {
                            $newValue[] = $entity;
                        }
                    }
                }
            }

            return parent::setSelectedValue($newValue);
        }
    '''

    def private relationPreProcess(Application it) '''
        /**
         * Pre-process relationship identifiers.
         *
         * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
         * @param array            &$params Parameters passed from the Smarty plugin function.
         *
         * @return void
         */
        protected function preprocessIdentifiers(Zikula_Form_View $view, &$params)
        {
            $entityData = isset($params['linkingItem']) ? $params['linkingItem'] : $view->get_template_vars('linkingItem');

            $alias = $this->id;
            $itemIds = array();
            $many = $this->selectionMode == 'multiple';

            if (isset($entityData[$alias])) {
                $relatedItems = $entityData[$alias];
                if (is_array($relatedItems) || is_object($relatedItems)) {
                    if ($many) {
                        foreach ($relatedItems as $relatedItem) {
                            $itemIds[] = $this->createItemIdentifier($relatedItem);
                        }
                    } else {
                        $itemIds[] = $this->createItemIdentifier($relatedItems);
                    }
                }
                $this->preselectedItems = $relatedItems;
            }

            if (count($itemIds) > 0) {
                if ($this->selectionMode != 'multiple') {
                    $entityData[$alias] = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $alias, 'id' => $itemIds[0]));
                } else {
                    $entityData[$alias] = ModUtil::apiFunc($this->name, 'selection', 'getEntities', array('ot' => $alias, 'idList' => $itemIds));
                }
            }

            $view->assign('linkingItem', $entityData);
        }
    '''

    def private relationPostProcess(Application it) '''
        /**
         * Post-process submitted data.
         *
         * @param Zikula_Form_View $view   Reference to Zikula_Form_View object.
         * @param string           $source The data source used (GET or POST).
         *
         * @return void
         */
        protected function processRequestData(Zikula_Form_View $view, $source)
        {
            $alias = $this->id;
            $many = ($this->selectionMode == 'multiple');

            $entityClass = $this->name . '_Entity_' . ucfirst($this->objectType);
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);

            $inputValue = FormUtil::getPassedValue($this->inputName, $this->getSelectedValue(), $source);
            if (empty($inputValue)) {
                return $many ? array() : null;
            }

            if (!is_array($inputValue)) {
                $inputValue = explode(',', $inputValue);
            }

            if (!is_array($inputValue) || !count($inputValue)) {
                return $many ? array() : null;
            }

            // fix for #446
            if (count($inputValue) == 1 && empty($inputValue[0])) {
                return $many ? array() : null;
            }

            $this->selectedItems = $this->fetchRelatedItems($view, $inputValue);
        }

        /**
         * Reassign related items to the edited entity.
         *
         * @param Zikula_Form_View $view       Reference to Zikula_Form_View object.
         * @param array|string     $inputValue The input data fetched in processRequestData().
         *
         * @return void
         */
        protected function fetchRelatedItems($view, $inputValue)
        {
            $entityClass = '«appName»_Entity_' . ucfirst($this->objectType);
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);

            $qb = $repository->genericBaseQuery('', '', false);
            $qb = $this->buildWhereClause($inputValue, $qb);
            //$qb = $repository->addCommonViewFilters($qb);

            $query = $repository->getQueryFromBuilder($qb);

            $relatedItems = $query->getResult();

            return $relatedItems;
        }

        /**
         * Reassign related items to the edited entity.
         *
         * @param Zikula_EntityAccess $entity     Reference to the updated entity.
         * @param array               $entityData Entity related form data.
         *
         * @return array form data after processing.
         */
        public function assignRelatedItemsToEntity($entity, $entityData)
        {
            $alias = $this->id;
            $many = ($this->selectionMode == 'multiple');

            $entity[$alias] = $this->preselectedItems;

            // remove all existing references
            if ($many) {
                $removeMethod = 'remove' . ucfirst($alias);
                foreach ($entity[$alias] as $relatedItem) {
                    $entity->$removeMethod($relatedItem);
                }
            } elseif (!$this->mandatory) {
                $entity[$alias] = null;
            }

            if (in_array($alias, array_keys($entityData))) {
                unset($entityData[$alias]);
            }

            // create new references
            $getter = 'get' . ucfirst($alias);
            $assignMethod = ($many ? 'add' : 'set') . ucfirst($alias);
            foreach ($this->selectedItems as $relatedItem) {
                if ($many && $entity->$getter()->contains($relatedItem)) {
                    continue;
                }
                if (!$many) {
                    // check if we are assigning the parent (1-side) of a bidirectional 1:n relationship
                    $inverseAddMethod = 'add' . ucfirst($this->aliasReverse);
                    if (method_exists($relatedItem, $inverseAddMethod)) {
                        // call the inverse method which calls the method in $entity
                        $relatedItem->$inverseAddMethod($entity);
                        continue;
                    }
                }
                $entity->$assignMethod($relatedItem);
            }

            return $entityData;
        }

        /**
         * Persists related items.
         */
        public function persistRelatedItems()
        {
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
        
            foreach ($this->selectedItems as $relatedItem) {
                $entityManager->persist($relatedItem);
            }
        }
    '''

    def private buildWhereClause(Application it) '''
        protected function buildWhereClause($inputValue, QueryBuilder $qb)
        {
            if (!$this->mandatory) {
                // remove empty option if it has been selected
                foreach ($inputValue as $k => $v) {
                    if (!$v) {
                        unset($inputValue[$k]);
                    }
                }
            }
            // readd filter value for returning nothing if no real item has been selected
            if (count($inputValue) == 0) {
                $inputValue[] = 0;
            }

            if (count($this->idFields) > 1) {
                $idsPerField = $this->decodeCompositeIdentifier($inputValue);
                foreach ($this->idFields as $idField) {
                    $qb->andWhere('tbl.' . $idField . ' IN (:' . $idField . 'Ids)')
                       ->setParameter($idField . 'Ids', $idsPerField[$idField]);
                }
            } else {
                $many = ($this->selectionMode == 'multiple');
                $idField = reset($this->idFields);
                if ($many) {
                    $qb->andWhere('tbl.' . $idField . ' IN (:' . $idField . 'Ids)')
                       ->setParameter($idField . 'Ids', $inputValue);
                } else {
                    $qb->andWhere('tbl.' . $idField . ' = :' . $idField)
                       ->setParameter($idField, $inputValue);
                }
            }
            if (!empty($this->where)) {
                $qb->andWhere($this->where);
            }

            return $qb;
        }
    '''

    def private helperMethods(Application it) '''
        /**
         * Determines whether a certain list item should be included or not.
         * Allows to exclude undesired items after the selection has happened.
         *
         * @param Doctrine\ORM\Entity $item The treated entity.
         *
         * @return boolean Whether this entity should be included into the list.
         */
        protected function isIncluded($item)
        {
            return true;
        }

        /**
         * Calculates the label for a certain list item.
         *
         * @param Doctrine\ORM\Entity $item The treated entity.
         *
         * @return string The created label string.
         */
        protected function createItemLabel($item)
        {
            return $item->getTitleFromDisplayPattern();
        }

        /**
         * Calculates the identifier for a certain list item.
         *
         * @param Doctrine\ORM\Entity $item The treated entity.
         *
         * @return string The created identifier string.
         */
        protected function createItemIdentifier($item)
        {
            return $item->createCompositeIdentifier();
        }

        /**
         * Decode a list of concatenated identifier strings (for composite keys).
         * This method is used for reading selected relationships.
         *
         * @param Array $itemIds List of concatenated identifiers.
         *
         * @return Array with list of single identifiers.
         */
        protected function decodeCompositeIdentifier($itemIds)
        {
            $idValues = array();
            foreach ($this->idFields as $idField) {
                $idValues[$idField] = array();
            }
            foreach ($itemIds as $itemId) {
                $itemIdParts = explode('_', $itemId);
                $i = 0;
                foreach ($this->idFields as $idField) {
                    $idValues[$idField][] = $itemIdParts[$i];
                    $i++;
                }
            }

            return $idValues;
        }
    '''

    def private selectorImpl(Application it) '''
        /**
         * Abstract object selector plugin implementation class.
         */
        abstract class «appName»_Form_Plugin_AbstractObjectSelector extends «appName»_Form_Plugin_Base_AbstractObjectSelector
        {
            // feel free to add your customisation here
        }
    '''
}
