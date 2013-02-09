package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AbstractObjectSelector {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val formPluginPath = getAppSourceLibPath + 'Form/Plugin/'
        fsa.generateFile(formPluginPath + 'Base/AbstractObjectSelector.php', selectorBaseFile)
        fsa.generateFile(formPluginPath + 'AbstractObjectSelector.php', selectorFile)
    }

    def private selectorBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «selectorBaseImpl»
    '''

    def private selectorFile(Application it) '''
        «fh.phpFileHeader(it)»
        «selectorImpl»
    '''

    def private selectorBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Form\Plugin\Base;

            use DataUtil;
        «ENDIF»
        use Doctrine\Common\Collections\Collection;
        «IF targets('1.3.5')»

        «ELSE»
            use FormUtil;
            use ModUtil;
            use ServiceUtil;
            use Zikula_EntityAccess;
            use Zikula_Form_Plugin_DropdownList;
            use Zikula_Form_View;

        «ENDIF»
        /**
         * Abstract object selector plugin base class.
         */
        «IF targets('1.3.5')»
        abstract class «appName»_Form_Plugin_Base_AbstractObjectSelector extends Zikula_Form_Plugin_DropdownList
        «ELSE»
        class AbstractObjectSelector extends Zikula_Form_Plugin_DropdownList
        «ENDIF»
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

            «loadItems»

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
         * Name of the field to display.
         *
         * @var string
         */
        public $displayField = '';

        /**
         * Name of optional second field to display.
         *
         * @var string
         */
        public $displayFieldTwo = '';

        /**
         * Whether to display an empty value to select nothing.
         *
         * @var boolean
         */
        public $showEmptyValue = false;

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

            if (isset($params['displayField'])) {
                if (!empty($params['displayField'])) {
                    $this->displayField = $params['displayField'];
                }
                unset($params['displayField']);
            }
            if (empty($this->displayField)) {
                // fallback to the leading field
                «IF targets('1.3.5')»
                    $entityClass = $this->name . '_Entity_' . ucwords($this->objectType);
                «ELSE»
                    $entityClass = '\\' . $this->name . '\\Entity\\' . ucwords($this->objectType) . 'Entity';
                «ENDIF»
                $entityManager = ServiceUtil::getManager()->getService('doctrine.entitymanager');
                $repository = $entityManager->getRepository($entityClass);
                $this->displayField = $repository->getTitleFieldName();
            }

            $this->displayFieldTwo = '';
            if (isset($params['displayField2'])) {
                $this->displayFieldTwo = $params['displayField2'];
                unset($params['displayField2']);
            } elseif (isset($params['displayFieldTwo'])) {
                $this->displayFieldTwo = $params['displayFieldTwo'];
                unset($params['displayFieldTwo']);
            }

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
            if ($this->showEmptyValue != false) {
                $this->addItem('- - -', 0);
            }

            $items = $this->loadItems($params);

            foreach ($items as $item) {
                if (!$this->isIncluded($item)) {
                    continue;
                }

                $itemLabel = $this->createItemLabel($item);
                $itemId = $this->createItemIdentifier($item);
                $this->addItem($itemLabel, $itemId);
            }

            parent::load($view, $params);
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
                'orderBy' => $this->orderBy
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
                }
            } else {
                $newValue = array();
                if (is_array($value) || $value instanceof Collection) {
                    foreach ($value as $entity) {
                        if ($entity instanceof Zikula_EntityAccess && method_exists($entity, 'createCompositeIdentifier')) {
                            $newValue[] = $entity->createCompositeIdentifier();
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
            $entityObj = $view->get_template_vars(strtolower($this->objectType) . 'Obj');
            $alias = $this->id;
            $itemIds = array();
            if (isset($entityData[$alias])) {
                $relatedItems = $entityData[$alias];
                if (is_array($relatedItems) || is_object($relatedItems)) {
                    foreach ($relatedItems as $relatedItem) {
                        $itemIds[] = $this->createItemIdentifier($relatedItem);
                    }
                }
            }
            $entityData[$alias] = $itemIds;
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

            «IF targets('1.3.5')»
                $entityClass = $this->name . '_Entity_' . ucwords($this->objectType);
            «ELSE»
                $entityClass = '\\' . $this->name . '\\Entity\\' . ucwords($this->objectType) . 'Entity';
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);

            $inputValue = $this->getSelectedValue();
            if (empty($inputValue) || !$inputValue) {
                $inputValue = FormUtil::getPassedValue($this->inputName, '', $source);
            }
            if (empty($inputValue)) {
                return $many ? array() : null;
            }

            if (!is_array($inputValue)) {
                $inputValue = explode(',', $inputValue);
            }

            if (!is_array($inputValue) || !count($inputValue)) {
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
            $selectionArgs = array(
                'ot' => $this->objectType,
                'where' => $this->buildWhereClause($inputValue),
                'orderBy' => $this->orderBy
            );
            $relatedItems = ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);

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

            // remove all existing references
            if ($many) {
                $removeMethod = 'remove' . ucwords($alias);
                foreach ($entity[$alias] as $relatedItem) {
                    $entity->$removeMethod($relatedItem);
                }
            } elseif (!$this->mandatory) {
                $entity[$alias] = null;
            }

            if (isset($entityData[$alias])) {
                unset($entityData[$alias]);
            }

            $entityManager = ServiceUtil::getManager()->getService('doctrine.entitymanager');

            // create new references
            $getter = 'get' . ucwords($alias);
            $assignMethod = ($many ? 'add' : 'set') . ucwords($alias);
            foreach ($this->selectedItems as $relatedItem) {
                if ($many && $entity->$getter()->contains($relatedItem)) {
                    continue;
                }
                $entity->$assignMethod($relatedItem);
                $entityManager->persist($relatedItem);
            }

            return $entityData;
        }
    '''

    def private buildWhereClause(Application it) '''
        protected function buildWhereClause($inputValue)
        {
            $where = '';
            if (count($this->idFields) > 1) {
                $idsPerField = $this->decodeCompositeIdentifier($inputValue);
                foreach ($this->idFields as $idField) {
                    if (!empty($where)) {
                        $where .= ' AND ';
                    }
                    $where .= 'tbl.' . $idField . ' IN (' . DataUtil::formatForStore(implode(', ', $idsPerField[$idField])) . ')';
                }
            } else {
                $many = ($this->selectionMode == 'multiple');
                $idField = reset($this->idFields);
                if ($many) {
                    $where .= 'tbl.' . $idField . ' IN (' . DataUtil::formatForStore(implode(', ', $inputValue)) . ')';
                } else {
                    $where .= 'tbl.' . $idField . ' = \'' . DataUtil::formatForStore($inputValue) . '\'';
                }
            }
            if (!empty($this->where)) {
                $where .= ' AND ' . $this->where;
            }

            return $where;
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
            $itemLabel = $item[$this->displayField];
            if (!empty($this->displayFieldTwo) && isset($item[$this->displayFieldTwo])) {
                $itemLabel .= ' (' . $item[$this->displayFieldTwo] . ')';
            }

            return $itemLabel;
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
            // create concatenated list of identifiers (for composite keys)
            $itemId = '';
            foreach ($this->idFields as $idField) {
                $itemId .= ((!empty($itemId)) ? '_' : '') . $item[$idField];
            }

            return $itemId;
        }

        /**
         * Decode a list of concatenated identifier strings (for composite keys).
         * This method is used for reading selected relationships.
         *
         * @param Array $itemIds List of concatenated identifiers.
         * @param Array $idFields List of identifier names.
         *
         * @return Array with list of single identifiers. 
         */
        protected function decodeCompositeIdentifier($itemIds, $idFields)
        {
            $idValues = array();
            foreach ($idFields as $idField) {
                $idValues[$idField] = array();
            }
            foreach ($itemIds as $itemId) {
                $itemIdParts = explode('_', $itemId);
                $i = 0;
                foreach ($idFields as $idField) {
                    $idValues[$idField][] = $itemIdParts[$i];
                    $i++;
                }
            }

            return $idValues;
        }
    '''

    def private selectorImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Form\Plugin;

        «ENDIF»
        /**
         * Abstract object selector plugin implementation class.
         */
        «IF targets('1.3.5')»
        abstract class «appName»_Form_Plugin_AbstractObjectSelector extends «appName»_Form_Plugin_Base_AbstractObjectSelector
        «ELSE»
        class AbstractObjectSelector extends Base\AbstractObjectSelector
        «ENDIF»
        {
            // feel free to add your customisation here
        }
    '''
}
