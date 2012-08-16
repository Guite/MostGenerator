package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Action
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler.Config
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler.Redirect
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler.UploadProcessing

class FormHandler {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()
    Redirect redirectHelper = new Redirect()
    Relations relationHelper = new Relations()

    /**
     * Entry point for Form handler classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        for (action : getEditActions) action.generate(it, fsa)
        new Config().generate(it, fsa)
    }

    def private generate(Action it, Application app, IFileSystemAccess fsa) {
    	controller.generate(app, 'edit', fsa)
        for (entity : app.getAllEntities) entity.generate(app, controller, 'edit', fsa)
    }

    def formCreate(Action it, String appName, Controller controller, String actionName) '''
        // Create new Form reference
        $view = FormUtil::newForm('«appName.formatForCode»', $this);

        «val controllerPraefix = formatForCode(appName + '_Form_Handler_' + prepClassPart(controller.name) + prepClassPart(actionName))»

        // Execute form using supplied template and page event handler
        return $view->execute('«controllerPraefix».tpl', new «controllerPraefix»());
    '''

    /**
     * Entry point for generic Form handler base classes.
     */
    def private generate(Controller it, Application app, String actionName, IFileSystemAccess fsa) {
    	println('Generating "' + name + '" form handler base class')
        fsa.generateFile(app.appName.appSourcePath + baseClassFormHandler(actionName).asFile, formHandlerCommonBaseFile(app, actionName))
        fsa.generateFile(app.appName.appSourcePath + implClassFormHandler(actionName).asFile, formHandlerCommonFile(app, actionName))
    }

    def private formHandlerCommonBaseFile(Controller it, Application app, String actionName) '''
    	«fh.phpFileHeader(app)»
    	«formHandlerCommonBaseImpl(app, actionName)»
    '''

    def private formHandlerCommonFile(Controller it, Application app, String actionName) '''
    	«fh.phpFileHeader(app)»
    	«formHandlerCommonImpl(app, actionName)»
    '''

    /**
     * Entry point for Form handler classes per entity.
     */
    def private generate(Entity it, Application app, Controller controller, String actionName, IFileSystemAccess fsa) {
    	println('Generating "' + controller.formattedName + '" form handler classes for "' + name + '_' + actionName + '"')
        fsa.generateFile(app.appName.appSourcePath + baseClassFormHandler(controller, name, actionName).asFile, formHandlerBaseFile(app, controller, actionName))
        fsa.generateFile(app.appName.appSourcePath + implClassFormHandler(controller, name, actionName).asFile, formHandlerFile(app, controller, actionName))
    }

    def private formHandlerBaseFile(Entity it, Application app, Controller controller, String actionName) '''
    	«fh.phpFileHeader(app)»
    	«formHandlerBaseImpl(app, controller, actionName)»
    '''

    def private formHandlerFile(Entity it, Application app, Controller controller, String actionName) '''
    	«fh.phpFileHeader(app)»
    	«formHandlerImpl(app, controller, actionName)»
    '''


    def private formHandlerCommonBaseImpl(Controller it, Application app, String actionName) '''
        /**
         * This handler class handles the page events of the Form called by the «formatForCode(app.appName + '_' + formattedName + '_' + actionName)»() function.
         * It collects common functionality required by different object types.
         *
         * Member variables in a form handler object are persisted across different page requests. This means
         * a member variable $this->X can be set on one request and on the next request it will still contain
         * the same value.
         *
         * A form handler will be notified of various events happening during it's life-cycle.
         * When a specific event occurs then the corresponding event handler (class method) will be executed. Handlers
         * are named exactly like their events - this is how the framework knows which methods to call.
         *
         * The list of events is:
         *
         * - <b>initialize</b>: this event fires before any of the events for the plugins and can be used to setup
         *   the form handler. The event handler typically takes care of reading URL variables, access control
         *   and reading of data from the database.
         *
         * - <b>handleCommand</b>: this event is fired by various plugins on the page. Typically it is done by the
         *   Zikula_Form_Plugin_Button plugin to signal that the user activated a button.
         */
        class «baseClassFormHandler(it, actionName)» extends Zikula_Form_AbstractHandler
        {
            /**
             * Persistent member vars
             */

            /**
             * @var string Name of treated object type.
             */
            protected $objectType;

            /**
             * @var string Name of treated object type starting with upper case.
             */
            protected $objectTypeCapital;

            /**
             * @var string Lower case version.
             */
            protected $objectTypeLower;

            /**
             * @var string Lower case name of multiple items (needed for hook areas).
             */
            protected $objectTypeLowerMultiple;

            /**
             * @var string Permission component based on object type.
             */
            protected $permissionComponent;

            /**
             * @var Zikula_EntityAccess Reference to treated entity instance.
             */
            protected $entityRef = false;

            /**
             * @var array List of identifier names.
             */
            protected $idFields = array();

            /**
             * @var array List of identifiers of treated entity.
             */
            protected $idValues = array();

            /**
             * @var mixed List of identifiers for incoming relationships.
             */
            protected $incomingIds = array();

            /**
             * @var string One of "create" or "edit".
             */
            protected $mode;

            /**
             * @var string Code defining the redirect goal after command handling.
             */
            protected $returnTo = null;

            /**
             * @var boolean Whether a create action is going to be repeated or not.
             */
            protected $repeatCreateAction = false;

            /**
             * @var string Url of current form with all parameters for multiple creations.
             */
            protected $repeatReturnUrl = null;

            /**
             * @var string Whether this form is being used inline within a window.
             */
            protected $inlineUsage = false;

            /**
             * @var string Full prefix for related items.
             */
            protected $idPrefix = '';

            /**
             * @var boolean Whether an existing item is used as template for a new one
             */
            protected $hasTemplateId = false;

            /**
             * @var boolean Whether the PageLock extension is used for this entity type or not.
             */
            protected $hasPageLockSupport = false;
            «IF app.hasAttributableEntities»

                /**
                 * @var boolean Whether the entity has attributes or not.
                 */
                protected $hasAttributes = false;
            «ENDIF»
            «IF app.hasCategorisableEntities»

                /**
                 * @var boolean Whether the entity is categorisable or not.
                 */
                protected $hasCategories = false;
            «ENDIF»
            «IF app.hasMetaDataEntities»

                /**
                 * @var boolean Whether the entity has meta data or not.
                 */
                protected $hasMetaData = false;
            «ENDIF»
            «IF app.hasTranslatable»

                /**
                 * @var boolean Whether the entity has translatable fields or not.
                 */
                protected $hasTranslatableFields = false;
            «ENDIF»
            «IF app.hasUploads»

                /**
                 * @var array Array with upload fields names and mandatory flags.
                 */
                protected $uploadFields = array();
            «ENDIF»
            «IF app.hasUserFields»

                /**
                 * @var array Array with user fields names and mandatory flags.
                 */
                protected $userFields = array();
            «ENDIF»
            «IF app.hasListFields»

                /**
                 * @var array Array with list fields names and multiple flags.
                 */
                protected $listFields = array();
            «ENDIF»



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

            «initialize(app, actionName)»

            /**
             * Method stub for own additions in subclasses.
             *
             * @depreciated to be removed in favour of postInitialize().
             */
            protected function initializeAdditions()
            {
            }

            /**
             * Post-initialise hook.
             *
             * @return void
             */
            public function postInitialize()
            {
                $entityClass = $this->name . '_Entity_' . ucfirst($this->objectType);
                $repository = $this->entityManager->getRepository($entityClass);
                $utilArgs = array('controller' => '«formattedName»', 'action' => '«actionName.formatForCode.toFirstLower»', 'mode' => $this->mode);
                $this->view->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
            }

            «relationHelper.retrieveRelatedObjects(it, app)»

            «redirectHelper.getRedirectCodes(it, app, actionName)»

            «handleCommand(app, actionName)»

            «fetchInputData(app, actionName)»

            «performUpdate(app, actionName)»

            «relationHelper.reassignRelatedObjects(it)»

            «new UploadProcessing().generate(it)»
        }
    '''

    def private initialize(Controller it, Application app, String actionName) '''
        /**
         * Initialize form handler.
         *
         * This method takes care of all necessary initialisation of our data and form states.
         *
         * @param Zikula_Form_View $view The form view instance.
         *
         * @return boolean False in case of initialization errors, otherwise true.
         */
        public function initialize(Zikula_Form_View $view)
        {
            $this->inlineUsage = ((UserUtil::getTheme() == 'Printer') ? true : false);
            $this->idPrefix = $this->request->query->filter('idp', '', FILTER_SANITIZE_STRING);

            // initialise redirect goal
            $this->returnTo = $this->request->query->filter('returnTo', null, FILTER_SANITIZE_STRING);
            // store current uri for repeated creations
            $this->repeatReturnUrl = System::getCurrentURI();

            $this->permissionComponent = $this->name . ':' . $this->objectTypeCapital . ':';

            $entityClass = $this->name . '_Entity_' . ucfirst($this->objectType);
            $objectTemp = new $entityClass();
            $this->idFields = $objectTemp->get_idFields();

            // retrieve identifier of the object we wish to view
            $controllerHelper = new «app.appName»_Util_Controller($this->view->getServiceManager());
            $this->idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $this->objectType, $this->idFields);
            $hasIdentifier = $controllerHelper->isValidIdentifier($this->idValues);

            $entity = null;
            $this->mode = ($hasIdentifier) ? 'edit' : 'create';

            if ($this->mode == 'edit') {
                if (!SecurityUtil::checkPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_EDIT)) {
                    // set an error message and return false
                    return LogUtil::registerPermissionError();
                }

                $entity = $this->initEntityForEdit();

                if ($this->hasPageLockSupport === true && ModUtil::available('PageLock')) {
                    // try to guarantee that only one person at a time can be editing this entity
                    ModUtil::apiFunc('PageLock', 'user', 'pageLock',
                                             array('lockName' => $this->name . $this->objectTypeCapital . $this->createCompositeIdentifier(),
                                                   'returnUrl' => $this->getRedirectUrl(null)));
                }
            }
            else {
                if (!SecurityUtil::checkPermission($this->permissionComponent, '::', ACCESS_ADD)) {
                    return LogUtil::registerPermissionError();
                }

                $entity = $this->initEntityForCreation();
            }

            $this->view->assign('mode', $this->mode)
                       ->assign('inlineUsage', $this->inlineUsage);
            «IF app.hasAttributableEntities»

                if ($this->hasAttributes === true) {
                    $this->initAttributesForEdit($entity);
                }
            «ENDIF»
            «IF app.hasCategorisableEntities»

                if ($this->hasCategories === true) {
                    $this->initCategoriesForEdit($entity);
                }
            «ENDIF»
            «IF app.hasMetaDataEntities»

                if ($this->hasMetaData === true) {
                    $this->initMetaDataForEdit($entity);
                }
            «ENDIF»
            «IF app.hasTranslatable»

                if ($this->hasTranslatableFields === true) {
                    $this->initTranslationsForEdit($entity);
                }
            «ENDIF»

            // save entity reference for later reuse
            $this->entityRef = $entity;

            // everything okay, no initialization errors occured
            return true;
        }

        /**
         * Create concatenated identifier string (for composite keys).
         *
         * @return String concatenated identifiers. 
         */
        protected function createCompositeIdentifier()
        {
            $itemId = '';
            foreach ($this->idFields as $idField) {
                if (!empty($itemId)) {
                    $itemId .= '_';
                }
                $itemId .= $this->idValues[$idField];
            }

            return $itemId;
        }

        /**
         * Decode a list of concatenated identifier strings (for composite keys).
         * This method is used for reading selected relationships.
         *
         * @param Array $itemIds List of concatenated identifiers.
         * @param Array $idFields List of identifier names.
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

        /**
         * Enrich a given args array for easy creation of display urls with composite keys.
         *
         * @param Array $args List of arguments to be extended.
         * @return Array enriched arguments list. 
         */
        protected function addIdentifiersToUrlArgs($args = array())
        {
            foreach ($this->idFields as $idField) {
                $args[$idField] = $this->idValues[$idField];
            }

            return $args;
        }

        /**
         * Initialise existing entity for editing.
         *
         * @return Zikula_EntityAccess desired entity instance or null 
         */
        protected function initEntityForEdit()
        {
            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $this->objectType, 'id' => $this->idValues));
            if ($entity == null) {
                return LogUtil::registerError($this->__('No such item.'));
            }
            return $entity;
        }

        /**
         * Initialise new entity for creation.
         *
         * @return Zikula_EntityAccess desired entity instance or null 
         */
        protected function initEntityForCreation()
        {
            $this->hasTemplateId = false;
            $templateId = $this->request->query->get('astemplate', '');
            if (!empty($templateId)) {
                $templateIdValueParts = explode('_', $templateId);
                $this->hasTemplateId = (count($templateIdValueParts) == count($this->idFields));
            }

            if ($this->hasTemplateId === true) {
                $templateIdValues = array();
                $i = 0;
                foreach ($this->idFields as $idField) {
                    $templateIdValues[$idField] = $templateIdValueParts[$i];
                    $i++;
                }
                // reuse existing entity
                $entityT = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $this->objectType, 'id' => $templateIdValues));
                if ($entityT == null) {
                    return LogUtil::registerError($this->__('No such item.'));
                }
                $entity = clone $entityT;
            } else {
                $entityClass = $this->name . '_Entity_' . ucfirst($this->objectType);
                $entity = new $entityClass();
            }

            return $entity;
        }
        «IF app.hasTranslatable»

            /**
             * Initialise translations.
             *
             * @param Zikula_EntityAccess $entity treated entity instance.
             */
            protected function initTranslationsForEdit($entity)
            {
                // retrieve translated fields
                $translatableHelper = new «app.appName»_Util_Translatable($this->view->getServiceManager());
                $translations = $translatableHelper->prepareEntityForEdit($this->objectType, $entity);

                // assign translations
                foreach ($translations as $locale => $translationData) {
                    $this->view->assign($this->objectTypeLower . $locale, $translationData);
                }

                // assign list of installed languages for translatable extension
                $this->view->assign('supportedLocales', ZLanguage::getInstalledLanguages());
            }
        «ENDIF»
        «IF app.hasAttributableEntities»

            /**
             * Initialise attributes.
             *
             * @param Zikula_EntityAccess $entity treated entity instance.
             */
            protected function initAttributesForEdit($entity)
            {
                $objectData = array();«/*$entity->toArray(); not required probably*/»

                // overwrite attributes array entry with a form compatible format
                $attributes = array();
                foreach ($this->getAttributeFieldNames() as $fieldName) {
                    $attributes[$fieldName] = $entity->getAttributes()->get($fieldName) ? $entity->getAttributes()->get($fieldName)->getValue() : '';
                }
                $objectData['attributes'] = $attributes;

                $this->view->assign($objectData);
            }

            /**
             * Return list of attribute field names.
             *
             * @return array list of attribute names.
             */
            protected function getAttributeFieldNames()
            {
                return array('field1', 'field2', 'field3');
            }
        «ENDIF»
        «IF app.hasCategorisableEntities»

            /**
             * Initialise categories.
             *
             * @param Zikula_EntityAccess $entity treated entity instance.
             */
            protected function initCategoriesForEdit($entity)
            {
                // assign the actual object for categories listener
                $this->view->assign($this->objectTypeLower . 'Obj', $entity);

                // load and assign registered categories
                $categories = CategoryRegistryUtil::getRegisteredModuleCategories($this->name, $this->objectTypeCapital, $this->idFields[0]);
                $this->view->assign('registries', $categories);
            }
        «ENDIF»
        «IF app.hasMetaDataEntities»

            /**
             * Initialise meta data.
             *
             * @param Zikula_EntityAccess $entity treated entity instance.
             */
            protected function initMetaDataForEdit($entity)
            {
                $metaData = $entity->getMetadata() != null? $entity->getMetadata()->toArray() : array();
                $this->view->assign('meta', $metaData);
            }
        «ENDIF»
    '''

    def private handleCommand(Controller it, Application app, String actionName) '''
        /**
         * Command event handler.
         *
         * This event handler is called when a command is issued by the user. Commands are typically something
         * that originates from a {@link Zikula_Form_Plugin_Button} plugin. The passed args contains different properties
         * depending on the command source, but you should at least find a <var>$args['commandName']</var>
         * value indicating the name of the command. The command name is normally specified by the plugin
         * that initiated the command.
         *
         * @param Zikula_Form_View $view The form view instance.
         * @param array            $args Additional arguments.
         *
         * @see Zikula_Form_Plugin_Button
         * @see Zikula_Form_Plugin_ImageButton
         *
         * @return mixed Redirect or false on errors.
         */
        public function handleCommand(Zikula_Form_View $view, &$args)
        {
            if ($args['commandName'] == 'delete') {
                if (!SecurityUtil::checkPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_DELETE)) {
                    return LogUtil::registerPermissionError();
                }
            }

            if (!in_array($args['commandName'], array('delete', 'cancel'))) {
                // do forms validation including checking all validators on the page to validate their input
                if (!$this->view->isValid()) {
                    return false;
                }
            }

            $otherFormData = $this->fetchInputData($view, $args);
            if ($otherFormData === false) {
                 return false;
            }

            $hookAreaPrefix = '«app.name.formatForDB».ui_hooks.' . $this->objectTypeLowerMultiple;

            // get treated entity reference from persisted member var
            $entity = $this->entityRef;

            if (in_array($args['commandName'], array('create', 'update'))) {
                // event handling if user clicks on create or update

                // Let any hooks perform additional validation actions
                $hook = new Zikula_ValidationHook($hookAreaPrefix . '.validate_edit', new Zikula_Hook_ValidationProviders());
                $validators = $this->notifyHooks($hook)->getValidators();
                if ($validators->hasErrors()) {
                    return false;
                }
                «IF app.hasTranslatable»

                    if ($this->hasTranslatableFields === true) {
                        $this->processTranslationsForUpdate($entity, $otherFormData);
                    }
                «ENDIF»

                $this->performUpdate($args);

                $success = true;
                if ($args['commandName'] == 'create') {
                    // store new identifier
                    foreach ($this->idFields as $idField) {
                        $this->idValues[$idField] = $entity[$idField];
                        // check if the insert has worked, might become obsolete due to exception usage
                        if (!$this->idValues[$idField]) {
                            $success = false;
                            break;
                        }
                    }
                } else if ($args['commandName'] == 'update') {
                }
                $this->addDefaultMessage($args, $success);

                // Let any hooks know that we have created or updated an item
                $urlArgs = array('ot' => $this->objectType);
                $urlArgs = $this->addIdentifiersToUrlArgs($urlArgs);
                if (isset($this->entityRef['slug'])) {
                    $urlArgs['slug'] = $this->entityRef['slug'];
                }
                $url = new Zikula_ModUrl($this->name, '«formattedName»', 'display', ZLanguage::getLanguageCode(), $urlArgs);
                $hook = new Zikula_ProcessHook($hookAreaPrefix . '.process_edit', $this->createCompositeIdentifier(), $url);
                $this->notifyHooks($hook);

                // An item was created or updated, so we clear all cached pages of item lists and this item.
                $cacheArgs = array('ot' => $this->objectType, 'item' => $entity);
                ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);
            } else if ($args['commandName'] == 'delete') {
                // event handling if user clicks on delete

                // Let any hooks perform additional validation actions
                $hook = new Zikula_ValidationHook($hookAreaPrefix . '.validate_delete', new Zikula_Hook_ValidationProviders());
                $validators = $this->notifyHooks($hook)->getValidators();
                if ($validators->hasErrors()) {
                    return false;
                }

                // delete entity
                $this->entityManager->remove($entity);
                $this->entityManager->flush();

                $this->addDefaultMessage($args, true);

                // Let any hooks know that we have deleted an item
                $hook = new Zikula_ProcessHook($hookAreaPrefix . '.process_delete', $this->createCompositeIdentifier());
                $this->notifyHooks($hook);

                // An item was deleted, so we clear all cached pages this item.
                $cacheArgs = array('ot' => $this->objectType, 'item' => $entity);
                ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);
            } else if ($args['commandName'] == 'cancel') {
                // event handling if user clicks on cancel
            }

            if ($args['commandName'] != 'cancel') {
                // clear view cache to reflect our changes
                $this->view->clear_cache();
            }

            if ($this->hasPageLockSupport === true && $this->mode == 'edit') {
                ModUtil::apiFunc('PageLock', 'user', 'releaseLock',
                                 array('lockName' => $this->name . $this->objectTypeCapital . $this->createCompositeIdentifier()));
            }

            return $this->view->redirect($this->getRedirectUrl($args));
        }
        «IF app.hasAttributableEntities»

            /**
             * Prepare update of attributes.
             *
             * @param Zikula_EntityAccess $entity   currently treated entity instance.
             * @param Array               $formData form data to be merged.
             */
            protected function processAttributesForUpdate($entity, $formData)
            {
                if (!isset($formData['attributes'])) {
                    return;
                }

                foreach($formData['attributes'] as $name => $value) {
                    $entity->setAttribute($name, $value);
                }
                «/*
                $entity->setAttribute('url', 'http://www.example.com');
                $entity->setAttribute('url', null); // remove
                */»
                unset($formData['attributes']);
            }
        «ENDIF»
        «IF app.hasCategorisableEntities»

            /**
             * Prepare update of categories.
             *
             * @param Zikula_EntityAccess $entity     currently treated entity instance.
             * @param Array               $entityData form data to be merged.
             */
            protected function processCategoriesForUpdate($entity, $entityData)
            {
            }
        «ENDIF»
        «IF app.hasMetaDataEntities»

            /**
             * Prepare update of meta data.
             *
             * @param Zikula_EntityAccess $entity     currently treated entity instance.
             * @param Array               $entityData form data to be merged.
             */
            protected function processMetaDataForUpdate($entity, $entityData)
            {
                $metaData = $entity->getMetadata();
                if (is_null($metaData)) {
                   $metaDataEntityClass = '«app.appName»_Entity_' . ucfirst($this->objectType) . 'MetaData';
                    $metaData = new $metaDataEntityClass($entity);
                }

                $metaData->merge($entityData['meta']);
                «/*
                $metaData->setKeywords('a,b,c');
                */»
                $entity->setMetadata($metaData);
                unset($entityData['meta']);
            }
        «ENDIF»
        «IF app.hasTranslatable»

            /**
             * Prepare update of translations.
             *
             * @param Zikula_EntityAccess $entity   currently treated entity instance.
             * @param Array               $formData additional form data outside the entity scope.
             */
            protected function processTranslationsForUpdate($entity, $formData)
            {
                $entityTransClass = $this->name . '_Entity_' . ucfirst($this->objectType) . 'Translation';
                $transRepository = $this->entityManager->getRepository($entityTransClass);

                $translatableHelper = new «container.application.appName»_Util_Translatable($this->view->getServiceManager());
                $translations = $translatableHelper->processEntityAfterEdit($this->objectType, $formData);

                foreach ($translations as $translation) {
                    foreach ($translation['fields'] as $fieldName => $value) {
                        $transRepository->translate($entity, $fieldName, $translation['locale'], $value);
                    }
                }
            }
        «ENDIF»

        /**
         * Get success or error message for default operations.
         *
         * @param Array   $args    arguments from handleCommand method.
         * @param Boolean $success true if this is a success, false for default error.
         * @return String desired status or error message.
         */
        protected function getDefaultMessage($args, $success = false)
        {
            $message = '';
            switch ($args['commandName']) {
                case 'create':
                        if ($success === true) {
                            $message = $this->__('Done! Item created.');
                        } else {
                            $message = $this->__('Error! Creation attempt failed.');
                        }
                        break;
                case 'update':
                        if ($success === true) {
                            $message = $this->__('Done! Item updated.');
                        } else {
                            $message = $this->__('Error! Update attempt failed.');
                        }
                        break;
                case 'delete':
                        if ($success === true) {
                            $message = $this->__('Done! Item deleted.');
                        } else {
                            $message = $this->__('Error! Deletion attempt failed.');
                        }
                        break;
            }
            return $message;
        }

        /**
         * Add success or error message to session.
         *
         * @param Array   $args    arguments from handleCommand method.
         * @param Boolean $success true if this is a success, false for default error.
         */
        protected function addDefaultMessage($args, $success = false)
        {
            $message = $this->getDefaultMessage($args, $success);
            if (!empty($message)) {
                if ($success === true) {
                    LogUtil::registerStatus($message);
                } else {
                    LogUtil::registerError($message);
                }
            }
        }
    '''

    def private fetchInputData(Controller it, Application app, String actionName) '''
        /**
         * Input data processing called by handleCommand method.
         *
         * @param Zikula_Form_View $view The form view instance.
         * @param array            $args Additional arguments.
         *
         * @return array form data after processing.
         */
        public function fetchInputData(Zikula_Form_View $view, &$args)
        {
            // fetch posted data input values as an associative array
            $formData = $this->view->getValues();
            // we want the array with our field values
            $entityData = $formData[$this->objectTypeLower];
            unset($formData[$this->objectTypeLower]);

            // get treated entity reference from persisted member var
            $entity = $this->entityRef;

            «IF app.hasUserFields || app.hasUploads || app.hasListFields || (app.hasSluggable && !app.getAllEntities.filter(e|e.slugUpdatable).isEmpty)»

                if (in_array($args['commandName'], array('create', 'update', 'delete'))) {
                    «IF app.hasUserFields»
                        if (count($this->userFields) > 0) {
                            foreach ($this->userFields as $userField => $isMandatory) {
                                $entityData[$userField] = (int) $this->request->request->filter($userField, 0, FILTER_VALIDATE_INT);
                                unset($entityData[$userField . 'Selector']);
                            }
                        }

                    «ENDIF»
                    «IF app.hasUploads»
                        if (count($this->uploadFields) > 0) {
                            $entityData = $this->handleUploads($entityData, $entity);
                            if ($entityData == false) {
                                return false;
                            }
                        }

                    «ENDIF»
                    «IF app.hasListFields»
                        if (count($this->listFields) > 0) {
                            foreach ($this->listFields as $listField => $multiple) {
                                if (!$multiple) {
                                    continue;
                                }
                                if (is_array($entityData[$listField])) { 
                                    $values = $entityData[$listField];
                                    $entityData[$listField] = '';
                                    if (count($values) > 0) {
                                        if (count($values) > 1) {
                                            $entityData[$listField] = '###' . implode('###', $values) . '###';
                                        } else {
                                            $entityData[$listField] = '###' . $values . '###';
                                        }
                                    }
                                }
                            }
                        }
                    «ENDIF»

                    «/*no slug input element yet, see https://github.com/l3pp4rd/DoctrineExtensions/issues/140
                    «IF hasSluggableFields && slugUpdatable»
                        $controllerHelper = new «container.application.appName»_Util_Controller($this->view->getServiceManager());
                        $entityData['slug'] = $controllerHelper->formatPermalink($entityData['slug']);
                    «ENDIF»
                */»
                }
            «ENDIF»

            if (isset($entityData['repeatcreation'])) {
                if ($args['commandName'] == 'create') {
                    $this->repeatCreateAction = $entityData['repeatcreation'];
                }
                unset($entityData['repeatcreation']);
            }
            «IF app.hasAttributableEntities»

                if ($this->hasAttributes === true) {
                    $this->processAttributesForUpdate($entity, $formData);
                }
            «ENDIF»
            «IF app.hasMetaDataEntities»

                if ($this->hasMetaData === true) {
                    $this->processMetaDataForUpdate($entity, $entityData);
                }
            «ENDIF»

            // assign fetched data
            $entity->merge($entityData);

            // save updated entity
            $this->entityRef = $entity;

            // return remaining form data
            return $formData;
        }
    '''

    def private performUpdate(Controller it, Application app, String actionName) '''
        /**
         * Executing insert and update statements
         *
         * @param Array   $args    arguments from handleCommand method.
         */
        public function performUpdate($args)
        {
            // stub for subclasses
        }
    '''


    def private formHandlerCommonImpl(Controller it, Application app, String actionName) '''
        /**
         * This handler class handles the page events of the Form called by the «formatForCode(app.appName + '_' + formattedName + '_' + actionName)»() function.
         * It collects common functionality required by different object types.
         */
        class «implClassFormHandler(it, actionName)» extends «baseClassFormHandler(it, actionName)»
        {
            // feel free to extend the base handler class here
        }
    '''




    def private formHandlerBaseImpl(Entity it, Application app, Controller controller, String actionName) '''
        «IF hasOptimisticLock || hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
            «IF hasOptimisticLock»
                use Doctrine\ORM\OptimisticLockException;
            «ENDIF»

        «ENDIF»
        /**
         * This handler class handles the page events of the Form called by the «formatForCode(app.appName + '_' + controller.formattedName + '_' + actionName)»() function.
         * It aims on the «name.formatForDisplay» object type.
         *
         * More documentation is provided in the parent class.
         */
        class «baseClassFormHandler(controller, name, actionName)» extends «implClassFormHandler(controller, actionName)»
        {
            /**
             * Persistent member vars
             */

            /**
             * Pre-initialise hook.
             *
             * @return void
             */
            public function preInitialize()
            {
                parent::preInitialize();

                $this->objectType = '«name.formatForCode»';
                $this->objectTypeCapital = '«name.formatForCodeCapital»';
                $this->objectTypeLower = '«name.formatForDB»';
                $this->objectTypeLowerMultiple = '«nameMultiple.formatForDB»';

                $this->hasPageLockSupport = «hasPageLockSupport.displayBool»;
                «IF app.hasAttributableEntities»
                    $this->hasAttributes = «attributable.displayBool»;
                «ENDIF»
                «IF app.hasCategorisableEntities»
                    $this->hasCategories = «categorisable.displayBool»;
                «ENDIF»
                «IF app.hasMetaDataEntities»
                    $this->hasMetaData = «metaData.displayBool»;
                «ENDIF»
                «IF app.hasTranslatable»
                    $this->hasTranslatableFields = «hasTranslatableFields.displayBool»;
                «ENDIF»
                «IF hasUploadFieldsEntity»
                    // array with upload fields and mandatory flags
                    $this->uploadFields = array(«FOR uploadField : getUploadFieldsEntity SEPARATOR ', '»'«uploadField.name.formatForCode»' => «uploadField.mandatory.displayBool»«ENDFOR»);
                «ENDIF»
                «IF hasUserFieldsEntity»
                    // array with user fields and mandatory flags
                    $this->userFields = array(«FOR userField : getUserFieldsEntity SEPARATOR ', '»'«userField.name.formatForCode»' => «userField.mandatory.displayBool»«ENDFOR»);
                «ENDIF»
                «IF hasListFieldsEntity»
                    // array with list fields and multiple flags
                    $this->listFields = array(«FOR listField : getListFieldsEntity SEPARATOR ', '»'«listField.name.formatForCode»' => «listField.multiple.displayBool»«ENDFOR»);
                «ENDIF»
            }

            «initialize(app, controller, actionName)»

            /**
             * Post-initialise hook.
             *
             * @return void
             */
            public function postInitialize()
            {
                parent::postInitialize();
            }

            «redirectHelper.getRedirectCodes(it, app, controller, actionName)»

            «redirectHelper.getDefaultReturnUrl(it, app, controller, actionName)»

            «handleCommand(it, app, controller, actionName)»

            «fetchInputData(it, app, controller, actionName)»

            «performUpdate(it, app, controller, actionName)»

            «redirectHelper.getRedirectUrl(it, app, controller, actionName)»

            «relationHelper.reassignRelatedObjects(it)»

            «relationHelper.updateRelationLinks(it)»
        }
    '''


    def private formHandlerImpl(Entity it, Application app, Controller controller, String actionName) '''
        /**
         * This handler class handles the page events of the Form called by the «formatForCode(app.appName + '_' + controller.formattedName + '_' + actionName)»() function.
         * It aims on the «name.formatForDisplay» object type.
         */
        class «implClassFormHandler(controller, name, actionName)» extends «baseClassFormHandler(controller, name, actionName)»
        {
            // feel free to extend the base handler class here
        }
    '''


    def private initialize(Entity it, Application app, Controller controller, String actionName) '''
        /**
         * Initialize form handler.
         *
         * This method takes care of all necessary initialisation of our data and form states.
         *
         * @param Zikula_Form_View $view The form view instance.
         *
         * @return boolean False in case of initialization errors, otherwise true.
         */
        public function initialize(Zikula_Form_View $view)
        {
            parent::initialize($view);

            $entity = $this->entityRef;

            if ($this->mode == 'edit') {
                «IF hasOptimisticLock»
                    SessionUtil::setVar($this->name . 'EntityVersion', $entity->get«getVersionField.name.formatForCodeCapital»());
                «ENDIF»
            } else {
                if ($this->hasTemplateId !== true) {
                    «FOR relation : getBidirectionalIncomingJoinRelations.filter(e|e.source.container.application == app)»«relationHelper.initRelatedObjectDefault(relation, true)»«ENDFOR»
                    «FOR relation : getOutgoingJoinRelations.filter(e|e.target.container.application == app)»«relationHelper.initRelatedObjectDefault(relation, false)»«ENDFOR»
                }
            }

            «relationHelper.incomingInitialisation(it)»

            // save entity reference for later reuse
            $this->entityRef = $entity;

            $entityData = $entity->toArray();
            «IF app.hasListFields»

                if (count($this->listFields) > 0) {
                    $helper = new «app.appName»_Util_ListEntries($this->view->getServiceManager());
                    foreach ($this->listFields as $listField => $isMultiple) {
                        $entityData[$listField . 'Items'] = $helper->getEntries($this->objectType, $listField);
                        if ($isMultiple) {
                            $entityData[$listField] = $helper->extractMultiList($entityData[$listField]);
                        }
                    }
                }
            «ENDIF»

            // assign data to template as array (makes translatable support easier)
            $this->view->assign($this->objectTypeLower, $entityData);

            $this->initializeAdditions();

            // everything okay, no initialization errors occured
            return true;
        }
    '''

    def private handleCommand(Entity it, Application app, Controller controller, String actionName) '''
        /**
         * Command event handler.
         *
         * This event handler is called when a command is issued by the user.
         *
         * @param Zikula_Form_View $view The form view instance.
         * @param array            $args Additional arguments.
         *
         * @return mixed Redirect or false on errors.
         */
        public function handleCommand(Zikula_Form_View $view, &$args)
        {
            $result = parent::handleCommand($view, $args);
            if ($result === false) {
                return $result;
            }

            return $this->view->redirect($this->getRedirectUrl($args));
        }

        /**
         * Get success or error message for default operations.
         *
         * @param Array   $args    arguments from handleCommand method.
         * @param Boolean $success true if this is a success, false for default error.
         * @return String desired status or error message.
         */
        protected function getDefaultMessage($args, $success = false)
        {
            if ($success !== true) {
                return parent::getDefaultMessage($args, $success);
            }

            $message = '';
            switch ($args['commandName']) {
                case 'create':
                            $message = $this->__('Done! «name.formatForDisplayCapital» created.');
                            break;
                case 'update':
                            $message = $this->__('Done! «name.formatForDisplayCapital» updated.');
                            break;
                case 'delete':
                            $message = $this->__('Done! «name.formatForDisplayCapital» deleted.');
                            break;
            }
            return $message;
        }
    '''

    def private fetchInputData(Entity it, Application app, Controller controller, String actionName) '''
        /**
         * Input data processing called by handleCommand method.
         *
         * @param Zikula_Form_View $view The form view instance.
         * @param array            $args Additional arguments.
         *
         * @return array form data after processing.
         */
        public function fetchInputData(Zikula_Form_View $view, &$args)
        {
            $otherFormData = parent::fetchInputData($view, $args);

            // get treated entity reference from persisted member var
            $entity = $this->entityRef;

            $entityData = array();

            $this->reassignRelatedObjects();
            «FOR relation : getIncomingJoinRelationsWithoutManyToMany.filter(e|e.source.container.application == app)»«relationHelper.fetchRelationValue(relation, true)»«ENDFOR»

            // assign fetched data
            if (count($entityData) > 0) {
                $entity->merge($entityData);
            }

            // save updated entity
            $this->entityRef = $entity;

            return $otherFormData;
        }
    '''


    def private performUpdate(Entity it, Application app, Controller controller, String actionName) '''
        /**
         * Executing insert and update statements
         *
         * @param Array   $args    arguments from handleCommand method.
         */
        public function performUpdate($args)
        {
            // get treated entity reference from persisted member var
            $entity = $this->entityRef;

            «IF hasOptimisticLock»
                $expectedVersion = SessionUtil::getVar($this->name . 'EntityVersion', 1);
                try {
                    if ($this->mode != 'create') {
                        // assert version
                        $this->entityManager->lock($entity, LockMode::OPTIMISTIC, $expectedVersion);
                    }
            «ENDIF»
            $this->updateRelationLinks($entity);
            //$this->entityManager->transactional(function($entityManager) {
            «IF hasPessimisticWriteLock»
                $this->entityManager->lock($entity, LockMode::«lockType.asConstant»);
            «ENDIF»
                $this->entityManager->persist($entity);
                $this->entityManager->flush();
            //});
            «IF hasOptimisticLock»
                } catch(OptimisticLockException $e) {
                    echo $this->__('Sorry, but someone else has already changed this record. Please apply the changes again!');
                }
            «ENDIF»
            «val uniOwningAssociations = getIncomingJoinRelations.filter(e|!e.bidirectional).filter(e|e.source.container.application == app)»
            «IF !uniOwningAssociations.isEmpty»

                // save incoming relationship from parent entity
                if ($args['commandName'] == 'create') {
                «FOR uniOwningAssociation : uniOwningAssociations»
                    if (!empty($this->incomingIds['«uniOwningAssociation.getRelationAliasName(false)»'])) {
                        $relObj = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => '«uniOwningAssociation.source.name.formatForCode»', 'id' => $this->incomingIds['«uniOwningAssociation.getRelationAliasName(false)»']));
                        if ($relObj != null) {
                            $relObj->add«uniOwningAssociation.getRelationAliasName(true).toFirstUpper»($entity);
                        }
                    }
                «ENDFOR»
                    $this->entityManager->flush();
                }
            «ENDIF»
        }
    '''
}
