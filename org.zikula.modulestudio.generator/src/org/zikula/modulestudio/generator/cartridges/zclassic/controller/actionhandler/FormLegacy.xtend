package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

// 1.3.x only
class FormLegacy {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def handlerDescription() '''
        «' '»*
        «' '»* Member variables in a form handler object are persisted across different page requests. This means
        «' '»* a member variable $this->X can be set on one request and on the next request it will still contain
        «' '»* the same value.
        «' '»*
        «' '»* A form handler will be notified of various events happening during it's life-cycle.
        «' '»* When a specific event occurs then the corresponding event handler (class method) will be executed. Handlers
        «' '»* are named exactly like their events - this is how the framework knows which methods to call.
        «' '»*
        «' '»* The list of events is:
        «' '»*
        «' '»* - <b>initialize</b>: this event fires before any of the events for the plugins and can be used to setup
        «' '»*   the form handler. The event handler typically takes care of reading URL variables, access control
        «' '»*   and reading of data from the database.
        «' '»*
        «' '»* - <b>handleCommand</b>: this event is fired by various plugins on the page. Typically it is done by the
        «' '»*   Zikula_Form_Plugin_Button plugin to signal that the user activated a button.
    '''

    def memberVars(Application it) '''
        «IF hasCategorisableEntities»

            /**
             * Whether the entity is categorisable or not.
             *
             * @var boolean
             */
            protected $hasCategories = false;
        «ENDIF»
        «IF hasMetaDataEntities»

            /**
             * Whether the entity has meta data or not.
             *
             * @var boolean
             */
            protected $hasMetaData = false;
        «ENDIF»
         «IF hasUserFields»

             /**
              * Array with user field names and mandatory flags.
              *
              * @var array
              */
             protected $userFields = array();
         «ENDIF»
         «IF hasListFields»

             /**
              * Array with list field names and multiple flags.
              *
              * @var array
              */
             protected $listFields = array();
         «ENDIF»
    '''

    def stubs() '''
        /**
         * Post construction hook.
         *
         * @return mixed
         */
        public function setup()
        {
        }

        /**
         * Pre-initialise hook.
         *
         * @return void
         */
        public function preInitialize()
        {
        }
    '''

    def initExtensions(Application it) '''
        «IF hasCategorisableEntities»

            if ($this->hasCategories === true) {
                $this->initCategoriesForEditing();
            }
        «ENDIF»
        «IF hasMetaDataEntities»

            if ($this->hasMetaData === true) {
                $this->initMetaDataForEditing();
            }
        «ENDIF»
    '''

    def initCategoriesForEditing(Application it) '''
        «IF hasCategorisableEntities»

            /**
             * Initialise categories.
             */
            protected function initCategoriesForEditing()
            {
                $entity = $this->entityRef;

                // assign the actual object for categories listener
                $this->view->assign($this->objectTypeLower . 'Obj', $entity);

                // load and assign registered categories
                $registries = ModUtil::apiFunc($this->name, 'category', 'getAllPropertiesWithMainCat', array('ot' => $this->objectType, 'arraykey' => $this->idFields[0]));

                // check if multiple selection is allowed for this object type
                $multiSelectionPerRegistry = array();
                foreach ($registries as $registryId => $registryCid) {
                    $multiSelectionPerRegistry[$registryId] = ModUtil::apiFunc($this->name, 'category', 'hasMultipleSelection', array('ot' => $this->objectType, 'registry' => $registryId));
                }
                $this->view->assign('registries', $registries)
                           ->assign('multiSelectionPerRegistry', $multiSelectionPerRegistry);
            }
        «ENDIF»
    '''

    def initMetaDataForEditing(Application it) '''
        «IF hasMetaDataEntities»

            /**
             * Initialise meta data.
             */
            protected function initMetaDataForEditing()
            {
                $entity = $this->entityRef;

                $metaData = null !== $entity->getMetadata() ? $entity->getMetadata()->toArray() : array();
                $this->view->assign('meta', $metaData);
            }
        «ENDIF»
    '''

    def processSpecialFields(Application it) '''
        «IF hasUserFields»
            if (count($this->userFields) > 0) {
                foreach ($this->userFields as $userField => $isMandatory) {
                    $entityData[$userField] = (int) $this->request->request->filter($userField, 0, FILTER_VALIDATE_INT);
                    unset($entityData[$userField . 'Selector']);
                }
            }

        «ENDIF»
        «IF hasListFields»
            if (count($this->listFields) > 0) {
                foreach ($this->listFields as $listField => $multiple) {
                    if (!$multiple) {
                        continue;
                    }
                    if (is_array($entityData[$listField])) { 
                        $values = $entityData[$listField];
                        $entityData[$listField] = '';
                        if (count($values) > 0) {
                            $entityData[$listField] = '###' . implode('###', $values) . '###';
                        }
                    }
                }
            }

        «ENDIF»
    '''

    def processExtensions(Application it) '''
        «IF hasMetaDataEntities»
            if ($this->hasMetaData === true) {
                $this->processMetaDataForUpdate($entity, $formData);
            }

        «ENDIF»
        // search for relationship plugins to update the corresponding data
        $entityData = $this->writeRelationDataToEntity($view, $entity, $entityData);
    '''

    def writeRelationDataToEntity(Application it) '''
        /**
         * Updates the entity with new relationship data.
         *
         * @param Zikula_Form_View    $view       The form view instance.
         * @param Zikula_EntityAccess $entity     Reference to the updated entity.
         * @param array               $entityData Entity related form data.
         *
         * @return array form data after processing.
         */
        protected function writeRelationDataToEntity(Zikula_Form_View $view, $entity, $entityData)
        {
            $entityData = $this->writeRelationDataToEntity_rec($entity, $entityData, $view->plugins);

            return $entityData;
        }

        /**
         * Searches for relationship plugins to write their updated values
         * back to the given entity.
         *
         * @param Zikula_EntityAccess $entity     Reference to the updated entity.
         * @param array               $entityData Entity related form data.
         * @param array               $plugins    List of form plugin which are searched.
         *
         * @return array form data after processing.
         */
        protected function writeRelationDataToEntity_rec($entity, $entityData, $plugins)
        {
            foreach ($plugins as $plugin) {
                if ($plugin instanceof «appName»_Form_Plugin_AbstractObjectSelector && method_exists($plugin, 'assignRelatedItemsToEntity')) {
                    $entityData = $plugin->assignRelatedItemsToEntity($entity, $entityData);
                }
                $entityData = $this->writeRelationDataToEntity_rec($entity, $entityData, $plugin->plugins);
            }

            return $entityData;
        }
    '''

    def persistRelationData(Application it) '''
        /**
         * Persists any related items.
         *
         * @param Zikula_Form_View $view The form view instance.
         */
        protected function persistRelationData(Zikula_Form_View $view)
        {
            $this->persistRelationData_rec($view->plugins);
        }

        /**
         * Searches for relationship plugins to persist their related items.
         */
        protected function persistRelationData_rec($plugins)
        {
            foreach ($plugins as $plugin) {
                if ($plugin instanceof «appName»_Form_Plugin_AbstractObjectSelector && method_exists($plugin, 'persistRelatedItems')) {
                    $plugin->persistRelatedItems();
                }
                $this->persistRelationData_rec($plugin->plugins);
            }
        }
    '''

    def processMetaDataForUpdate(Application it) '''
        /**
         * Prepare update of meta data.
         *
         * @param Zikula_EntityAccess $entity   currently treated entity instance.
         * @param Array               $formData form data to be merged.
         */
        protected function processMetaDataForUpdate($entity, $formData)
        {
            $metaData = $entity->getMetadata();
            if (is_null($metaData)) {
                $metaDataEntityClass = $this->name . '_Entity_' . ucfirst($this->objectType) . 'MetaData';
                $metaData = new $metaDataEntityClass($entity);
            }

            if (isset($formData['meta']) && is_array($formData['meta'])) {
                // convert form date values into DateTime objects
                $formData['meta']['startdate'] = new \DateTime($formData['meta']['startdate']);
                $formData['meta']['enddate'] = new \DateTime($formData['meta']['enddate']);

                // now set meta data values
                $metaData->merge($formData['meta']);
            }
            $entity->setMetadata($metaData);
            unset($formData['meta']);
        }
    '''

    def setMemberVars(Entity it) '''
        «IF application.hasCategorisableEntities»
            $this->hasCategories = «categorisable.displayBool»;
        «ENDIF»
        «IF application.hasMetaDataEntities»
            $this->hasMetaData = «metaData.displayBool»;
        «ENDIF»
        «IF hasUserFieldsEntity»
            // array with user fields and mandatory flags
            $this->userFields = array(«FOR userField : getUserFieldsEntity SEPARATOR ', '»'«userField.name.formatForCode»' => «userField.mandatory.displayBool»«ENDFOR»);
        «ENDIF»
        «IF hasListFieldsEntity»
            // array with list fields and multiple flags
            $this->listFields = array(«FOR listField : getListFieldsEntity SEPARATOR ', '»'«listField.name.formatForCode»' => «listField.multiple.displayBool»«ENDFOR»);
        «ENDIF»
    '''
}
