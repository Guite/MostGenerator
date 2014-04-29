package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Action
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.Config
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.Redirect
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.RelationPresets
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.UploadProcessing
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class FormHandler {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils
    @Inject extension WorkflowExtensions = new WorkflowExtensions

    FileHelper fh = new FileHelper
    Redirect redirectHelper = new Redirect
    RelationPresets relationPresetsHelper = new RelationPresets

    Application app

    /**
     * Entry point for Form handler classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        app = it
        if (hasEditActions()) {
            generateCommon('edit', fsa)
            for (entity : getAllEntities) {
                if (entity.hasActions('edit')) {
                    entity.generate('edit', fsa)
                }
            }
        }
        new Config().generate(it, fsa)
    }

    def formCreate(Action it, String appName, String actionName) '''
        // Create new Form reference
        $view = FormUtil::newForm('«appName.formatForCode»', $this);

        «IF controller.container.application.targets('1.3.5')»
            $handlerClass = '«appName»_Form_Handler_«controller.name.formatForCodeCapital»_«actionName.formatForCodeCapital»';
        «ELSE»
            $handlerClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Form\\Handler\\«controller.name.formatForCodeCapital»\\«actionName.formatForCodeCapital»Handler';
        «ENDIF»

        // Execute form using supplied template and page event handler
        return $view->execute('«controller.formattedName.toFirstUpper»/«actionName.formatForCode.toFirstLower».tpl', new $handlerClass());
    '''

    /**
     * Entry point for generic Form handler base classes.
     */
    def private generateCommon(Application it, String actionName, IFileSystemAccess fsa) {
        println('Generating "' + name + '" form handler base class')
        val formHandlerFolder = getAppSourceLibPath + 'Form/Handler/Common/'
        generateClassPair(fsa, formHandlerFolder + actionName.formatForCodeCapital + (if (targets('1.3.5')) '' else 'Handler') + '.php',
            fh.phpFileContent(it, formHandlerCommonBaseImpl(actionName)), fh.phpFileContent(app, formHandlerCommonImpl(actionName))
        )
    }

    /**
     * Entry point for Form handler classes per entity.
     */
    def private generate(Entity it, String actionName, IFileSystemAccess fsa) {
        println('Generating form handler classes for "' + name + '_' + actionName + '"')
        val formHandlerFolder = app.getAppSourceLibPath + 'Form/Handler/' + name.formatForCodeCapital + '/'
        app.generateClassPair(fsa, formHandlerFolder + actionName.formatForCodeCapital + (if (app.targets('1.3.5')) '' else 'Handler') + '.php',
            fh.phpFileContent(app, formHandlerBaseImpl(actionName)), fh.phpFileContent(app, formHandlerImpl(actionName))
        )
    }

    def private formHandlerCommonBaseImpl(Application it, String actionName) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Form\Handler\Common\Base;

            use «appNamespace»\Form\Plugin\AbstractObjectSelector;

            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
            use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

            use ModUtil;
            use SecurityUtil;
            use System;
            use UserUtil;
            use Zikula_Form_AbstractHandler;
            use Zikula_Form_View;
            use ZLanguage;
            use Zikula\Core\Hook\ProcessHook;
            use Zikula\Core\Hook\ValidationHook;
            use Zikula\Core\Hook\ValidationProviders;
            use Zikula\Core\ModUrl;

        «ENDIF»
        /**
         * This handler class handles the page events of editing forms.
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
        «IF targets('1.3.5')»
        class «appName»_Form_Handler_Common_Base_«actionName.formatForCodeCapital» extends Zikula_Form_AbstractHandler
        «ELSE»
        class «actionName.formatForCodeCapital»Handler extends Zikula_Form_AbstractHandler
        «ENDIF»
        {
            /**
             * Name of treated object type.
             *
             * @var string
             */
            protected $objectType;

            /**
             * Name of treated object type starting with upper case.
             *
             * @var string
             */
            protected $objectTypeCapital;

            /**
             * Lower case version.
             *
             * @var string
             */
            protected $objectTypeLower;

            /**
             * Permission component based on object type.
             *
             * @var string
             */
            protected $permissionComponent;

            /**
             * Reference to treated entity instance.
             *
             * @var Zikula_EntityAccess
             */
            protected $entityRef = false;

            /**
             * List of identifier names.
             *
             * @var array
             */
            protected $idFields = array();

            /**
             * List of identifiers of treated entity.
             *
             * @var array
             */
            protected $idValues = array();
            «relationPresetsHelper.memberFields(it)»

            /**
             * One of "create" or "edit".
             *
             * @var string
             */
            protected $mode;

            /**
             * Code defining the redirect goal after command handling.
             *
             * @var string
             */
            protected $returnTo = null;

            /**
             * Whether a create action is going to be repeated or not.
             *
             * @var boolean
             */
            protected $repeatCreateAction = false;

            /**
             * Url of current form with all parameters for multiple creations.
             *
             * @var string
             */
            protected $repeatReturnUrl = null;

            /**
             * Whether this form is being used inline within a window.
             *
             * @var boolean
             */
            protected $inlineUsage = false;

            /**
             * Full prefix for related items.
             *
             * @var string
             */
            protected $idPrefix = '';

            /**
             * Whether an existing item is used as template for a new one.
             *
             * @var boolean
             */
            protected $hasTemplateId = false;

            /**
             * Whether the PageLock extension is used for this entity type or not.
             *
             * @var boolean
             */
            protected $hasPageLockSupport = false;
            «IF hasAttributableEntities»

                /**
                 * Whether the entity has attributes or not.
                 *
                 * @var boolean
                 */
                protected $hasAttributes = false;
            «ENDIF»
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
            «IF hasSluggable»

                /**
                 * Whether the entity has an editable slug or not.
                 *
                 * @var boolean
                 */
                protected $hasSlugUpdatableField = false;
            «ENDIF»
            «IF hasTranslatable»

                /**
                 * Whether the entity has translatable fields or not.
                 *
                 * @var boolean
                 */
                protected $hasTranslatableFields = false;
            «ENDIF»
            «IF hasUploads»

                /**
                 * Array with upload field names and mandatory flags.
                 *
                 * @var array
                 */
                protected $uploadFields = array();
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

            «initialize(actionName)»

            /**
             * Post-initialise hook.
             *
             * @return void
             */
            public function postInitialize()
            {
                «IF targets('1.3.5')»
                    $entityClass = $this->name . '_Entity_' . ucwords($this->objectType);
                «ELSE»
                    $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucwords($this->objectType) . 'Entity';
                «ENDIF»
                $repository = $this->entityManager->getRepository($entityClass);
                $utilArgs = array('controller' => FormUtil::getPassedValue('type', 'user', 'GETPOST'),
                                  'action' => '«actionName.formatForCode.toFirstLower»',
                                  'mode' => $this->mode);
                $this->view->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
            }

            «redirectHelper.getRedirectCodes(it, actionName)»

            «handleCommand(actionName)»

            «fetchInputData(actionName)»

            «applyAction(actionName)»

            «new UploadProcessing().generate(it)»
        }
    '''

    def private initialize(Application it, String actionName) '''
        /**
         * Initialize form handler.
         *
         * This method takes care of all necessary initialisation of our data and form states.
         *
         * @param Zikula_Form_View $view The form view instance.
         *
         * @return boolean False in case of initialization errors, otherwise true.
         «IF !targets('1.3.5')»
         *
         * @throws NotFoundHttpException Thrown if item to be edited isn't found
         * @throws RuntimeException      Thrown if the workflow actions can not be determined
         «ENDIF»
         */
        public function initialize(Zikula_Form_View $view)
        {
            $this->inlineUsage = ((UserUtil::getTheme() == 'Printer') ? true : false);
            $this->idPrefix = $this->request->query->filter('idp', '', «IF !targets('1.3.5')»false, «ENDIF»FILTER_SANITIZE_STRING);

            // initialise redirect goal
            $this->returnTo = $this->request->query->filter('returnTo', null, «IF !targets('1.3.5')»false, «ENDIF»FILTER_SANITIZE_STRING);
            // store current uri for repeated creations
            $this->repeatReturnUrl = System::getCurrentURI();

            $this->permissionComponent = $this->name . ':' . $this->objectTypeCapital . ':';

            «IF targets('1.3.5')»
                $entityClass = $this->name . '_Entity_' . ucfirst($this->objectType);
            «ELSE»
                $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucwords($this->objectType) . 'Entity';
            «ENDIF»
            $this->idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $this->objectType));

            // retrieve identifier of the object we wish to view
            «IF app.targets('1.3.5')»
                $controllerHelper = new «app.appName»_Util_Controller($this->view->getServiceManager());
            «ELSE»
                $controllerHelper = $this->view->getServiceManager()->get('«app.appName.formatForDB».controller_helper');
            «ENDIF»

            $this->idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $this->objectType, $this->idFields);
            $hasIdentifier = $controllerHelper->isValidIdentifier($this->idValues);

            $entity = null;
            $this->mode = ($hasIdentifier) ? 'edit' : 'create';

            if ($this->mode == 'edit') {
                if (!SecurityUtil::checkPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_EDIT)) {
                    «IF targets('1.3.5')»
                        return LogUtil::registerPermissionError();
                    «ELSE»
                        throw new AccessDeniedException();
                    «ENDIF»
                }

                $entity = $this->initEntityForEdit();
                if (!is_object($entity)) {
                    «IF targets('1.3.5')»return LogUtil::registerError«ELSE»throw new NotFoundHttpException«ENDIF»($this->__('No such item.'));
                }

                if ($this->hasPageLockSupport === true && ModUtil::available('PageLock')) {
                    // try to guarantee that only one person at a time can be editing this entity
                    ModUtil::apiFunc('PageLock', 'user', 'pageLock',
                                             array('lockName' => $this->name . $this->objectTypeCapital . $this->createCompositeIdentifier(),
                                                   'returnUrl' => $this->getRedirectUrl(null)));
                }
            } else {
                if (!SecurityUtil::checkPermission($this->permissionComponent, '::', ACCESS_EDIT)) {
                    «IF targets('1.3.5')»
                        return LogUtil::registerPermissionError();
                    «ELSE»
                        throw new AccessDeniedException();
                    «ENDIF»
                }

                $entity = $this->initEntityForCreation();
            }

            $this->view->assign('mode', $this->mode)
                       ->assign('inlineUsage', $this->inlineUsage);

            // save entity reference for later reuse
            $this->entityRef = $entity;

            «initializeExtensions»

            «IF targets('1.3.5')»
                $workflowHelper = new «appName»_Util_Workflow($this->view->getServiceManager());
            «ELSE»
                $workflowHelper = $this->view->getServiceManager()->get('«appName.formatForDB».workflow_helper');
            «ENDIF»
            $actions = $workflowHelper->getActionsForObject($entity);
            if ($actions === false || !is_array($actions)) {
                «IF targets('1.3.5')»
                    return LogUtil::registerError($this->__('Error! Could not determine workflow actions.'));
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! Could not determine workflow actions.'));
                    $logger = $this->view->getServiceManager()->get('logger');
                    $logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed to determine available workflow actions.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => $this->objectType, 'id' => $entity->createCompositeIdentifier()));
                    return false;
                «ENDIF»
            }
            // assign list of allowed actions to the view for further processing
            $this->view->assign('actions', $actions);

            // everything okay, no initialization errors occured
            return true;
        }

        «createCompositeIdentifier»

        «initEntityForEdit»

        «initEntityForCreation»
        «initTranslationsForEdit»
        «initAttributesForEdit»
        «initCategoriesForEdit»
        «initMetaDataForEdit»
    '''

    def private initializeExtensions(Application it) '''
        «IF hasAttributableEntities»

            if ($this->hasAttributes === true) {
                $this->initAttributesForEdit();
            }
        «ENDIF»
        «IF hasCategorisableEntities»

            if ($this->hasCategories === true) {
                $this->initCategoriesForEdit();
            }
        «ENDIF»
        «IF hasMetaDataEntities»

            if ($this->hasMetaData === true) {
                $this->initMetaDataForEdit();
            }
        «ENDIF»
        «IF hasTranslatable»

            if ($this->hasTranslatableFields === true) {
                $this->initTranslationsForEdit();
            }
        «ENDIF»
    '''

    def private createCompositeIdentifier(Application it) '''
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
    '''

    def private initEntityForEdit(Application it) '''
        /**
         * Initialise existing entity for editing.
         *
         * @return Zikula_EntityAccess desired entity instance or null
         «IF !targets('1.3.5')»
         *
         * @throws NotFoundHttpException Thrown if item to be edited isn't found
         «ENDIF»
         */
        protected function initEntityForEdit()
        {
            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $this->objectType, 'id' => $this->idValues));
            if ($entity == null) {
                «IF targets('1.3.5')»return LogUtil::registerError«ELSE»throw new NotFoundHttpException«ENDIF»($this->__('No such item.'));
            }

            $entity->initWorkflow();

            return $entity;
        }
    '''

    def private initEntityForCreation(Application it) '''
        /**
         * Initialise new entity for creation.
         *
         * @return Zikula_EntityAccess desired entity instance or null
         «IF !targets('1.3.5')»
         *
         * @throws NotFoundHttpException Thrown if item to be cloned isn't found
         «ENDIF»
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
                    «IF targets('1.3.5')»return LogUtil::registerError«ELSE»throw new NotFoundHttpException«ENDIF»($this->__('No such item.'));
                }
                $entity = clone $entityT;
            } else {
                «IF targets('1.3.5')»
                    $entityClass = $this->name . '_Entity_' . ucfirst($this->objectType);
                «ELSE»
                    $entityClass = '«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucwords($this->objectType) . 'Entity';
                «ENDIF»
                $entity = new $entityClass();
            }

            return $entity;
        }
    '''

    def private initTranslationsForEdit(Application it) '''
        «IF hasTranslatable»

            /**
             * Initialise translations.
             */
            protected function initTranslationsForEdit()
            {
                $entity = $this->entityRef;

                // retrieve translated fields
                «IF targets('1.3.5')»
                    $translatableHelper = new «appName»_Util_Translatable($this->view->getServiceManager());
                «ELSE»
                    $translatableHelper = $this->serviceManager->get('«app.appName.formatForDB».translatable_helper');
                «ENDIF»
                $translations = $translatableHelper->prepareEntityForEdit($this->objectType, $entity);

                // assign translations
                foreach ($translations as $locale => $translationData) {
                    $this->view->assign($this->objectTypeLower . $locale, $translationData);
                }

                // assign list of installed languages for translatable extension
                $this->view->assign('supportedLocales', ZLanguage::getInstalledLanguages());
            }
        «ENDIF»
    '''

    def private initAttributesForEdit(Application it) '''
        «IF hasAttributableEntities»

            /**
             * Initialise attributes.
             */
            protected function initAttributesForEdit()
            {
                $entity = $this->entityRef;

                $entityData = array();«/*$entity->toArray(); not required probably*/»

                // overwrite attributes array entry with a form compatible format
                $attributes = array();
                foreach ($this->getAttributeFieldNames() as $fieldName) {
                    $attributes[$fieldName] = $entity->getAttributes()->get($fieldName) ? $entity->getAttributes()->get($fieldName)->getValue() : '';
                }
                $entityData['attributes'] = $attributes;

                $this->view->assign($entityData);
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
    '''

    def private initCategoriesForEdit(Application it) '''
        «IF hasCategorisableEntities»

            /**
             * Initialise categories.
             */
            protected function initCategoriesForEdit()
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

    def private initMetaDataForEdit(Application it) '''
        «IF hasMetaDataEntities»

            /**
             * Initialise meta data.
             */
            protected function initMetaDataForEdit()
            {
                $entity = $this->entityRef;

                $metaData = $entity->getMetadata() != null ? $entity->getMetadata()->toArray() : array();
                $this->view->assign('meta', $metaData);
            }
        «ENDIF»
    '''

    def private handleCommand(Application it, String actionName) '''
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
            $action = $args['commandName'];
            $isRegularAction = !in_array($action, array('delete', 'cancel'));

            if ($isRegularAction) {
                // do forms validation including checking all validators on the page to validate their input
                if (!$this->view->isValid()) {
                    return false;
                }
            }

            if ($action != 'cancel') {
                $otherFormData = $this->fetchInputData($view, $args);
            	if ($otherFormData === false) {
                	return false;
            	}
        	}

            // get treated entity reference from persisted member var
            $entity = $this->entityRef;

            $hookAreaPrefix = $entity->getHookAreaPrefix();
            if ($action != 'cancel') {
                $hookType = $action == 'delete' ? 'validate_delete' : 'validate_edit';

                // Let any hooks perform additional validation actions
                «IF targets('1.3.5')»
                    $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
                    $validators = $this->notifyHooks($hook)->getValidators();
                «ELSE»
                    $hook = new ValidationHook(new ValidationProviders());
                    $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
                «ENDIF»
                if ($validators->hasErrors()) {
                    return false;
                }
            }
            «IF hasTranslatable»

                if ($isRegularAction && $this->hasTranslatableFields === true) {
                    $this->processTranslationsForUpdate($entity, $otherFormData);
                }
            «ENDIF»

            if ($action != 'cancel') {
                $success = $this->applyAction($args);
                if (!$success) {
                    // the workflow operation failed
                    return false;
                }

                // Let any hooks know that we have created, updated or deleted an item
                $hookType = $action == 'delete' ? 'process_delete' : 'process_edit';
                $url = null;
                if ($action != 'delete') {
                    $urlArgs = $entity->createUrlArgs();
                    $url = new «IF targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, «IF targets('1.3.5')»FormUtil::getPassedValue('type', 'user', 'GETPOST')«ELSE»$this->objectType«ENDIF», 'display', ZLanguage::getLanguageCode(), $urlArgs);
                }
                «IF targets('1.3.5')»
                    $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier(), $url);
                    $this->notifyHooks($hook);
                «ELSE»
                    $hook = new ProcessHook($entity->createCompositeIdentifier(), $url);
                    $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                «ENDIF»

                // An item was created, updated or deleted, so we clear all cached pages for this item.
                $cacheArgs = array('ot' => $this->objectType, 'item' => $entity);
                ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);

                // clear view cache to reflect our changes
                $this->view->clear_cache();
            }

            if ($this->hasPageLockSupport === true && $this->mode == 'edit' && ModUtil::available('PageLock')) {
                ModUtil::apiFunc('PageLock', 'user', 'releaseLock',
                                 array('lockName' => $this->name . $this->objectTypeCapital . $this->createCompositeIdentifier()));
            }

            return $this->view->redirect($this->getRedirectUrl($args));
        }
        «IF hasAttributableEntities»

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
        «IF hasMetaDataEntities»

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
                    «IF targets('1.3.5')»
                        $metaDataEntityClass = $this->name . '_Entity_' . ucfirst($this->objectType) . 'MetaData';
                    «ELSE»
                        $metaDataEntityClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucfirst($this->objectType) . 'MetaDataEntity';
                    «ENDIF»
                    $metaData = new $metaDataEntityClass($entity);
                }

                $metaData->merge($formData['meta']);
                «/*
                $metaData->setKeywords('a,b,c');
                */»
                $entity->setMetadata($metaData);
                unset($formData['meta']);
            }
        «ENDIF»
        «IF hasTranslatable»

            /**
             * Prepare update of translations.
             *
             * @param Zikula_EntityAccess $entity   currently treated entity instance.
             * @param Array               $formData additional form data outside the entity scope.
             */
            protected function processTranslationsForUpdate($entity, $formData)
            {
                «IF targets('1.3.5')»
                    $entityTransClass = $this->name . '_Entity_' . ucwords($this->objectType) . 'Translation';
                «ELSE»
                    $entityTransClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucwords($this->objectType) . 'TranslationEntity';
                «ENDIF»
                $transRepository = $this->entityManager->getRepository($entityTransClass);

                // persist translated fields
                «IF targets('1.3.5')»
                    $translatableHelper = new «appName»_Util_Translatable($this->view->getServiceManager());
                «ELSE»
                    $translatableHelper = $this->serviceManager->get('«app.appName.formatForDB».translatable_helper');
                «ENDIF»
                $translations = $translatableHelper->processEntityAfterEdit($this->objectType, $formData);

                foreach ($translations as $translation) {
                    foreach ($translation['fields'] as $fieldName => $value) {
                        $transRepository->translate($entity, $fieldName, $translation['locale'], $value);
                    }
                }

                // save updated entity
                $this->entityRef = $entity;
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
         «IF !targets('1.3.5')»
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         «ENDIF»
         */
        protected function addDefaultMessage($args, $success = false)
        {
            $message = $this->getDefaultMessage($args, $success);
            if (!empty($message)) {
                «IF targets('1.3.5')»
                    if ($success === true) {
                        LogUtil::registerStatus($message);
                    } else {
                        LogUtil::registerError($message);
                    }
                «ELSE»
                    $flashType = ($success === true) ? 'status' : 'error';
                    $this->request->getSession()->getFlashBag()->add($flashType, $message);
                    $logger = $this->view->getServiceManager()->get('logger');
                    if ($success === true) {
                        $logger->notice('{app}: User {user} updated the {entity} with id {id}.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => $this->objectType, 'id' => $this->entityRef->createCompositeIdentifier()));
                    } else {
                        $logger->error('{app}: User {user} tried to update the {entity} with id {id}, but failed.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => $this->objectType, 'id' => $this->entityRef->createCompositeIdentifier()));
                    }
                «ENDIF»
            }
        }
    '''

    def private fetchInputData(Application it, String actionName) '''
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

            «IF hasUserFields || hasUploads || hasListFields || (hasSluggable && !getAllEntities.filter[slugUpdatable].empty)»

                if ($args['commandName'] != 'cancel') {
                    «IF hasUserFields»
                        if (count($this->userFields) > 0) {
                            foreach ($this->userFields as $userField => $isMandatory) {
                                $entityData[$userField] = (int) $this->request->request->filter($userField, 0, «IF !targets('1.3.5')»false, «ENDIF»FILTER_VALIDATE_INT);
                                unset($entityData[$userField . 'Selector']);
                            }
                        }

                    «ENDIF»
                    «IF hasUploads»
                        if (count($this->uploadFields) > 0) {
                            $entityData = $this->handleUploads($entityData, $entity);
                            if ($entityData == false) {
                                return false;
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
                    «IF !targets('1.3.5') && hasSluggable»

                        if ($this->hasSlugUpdatableField === true && isset($entityData['slug'])) {
                            «IF app.targets('1.3.5')»
                                $controllerHelper = new «app.appName»_Util_Controller($this->view->getServiceManager());
                            «ELSE»
                                $controllerHelper = $this->view->getServiceManager()->get('«app.appName.formatForDB».controller_helper');
                            «ENDIF»
                            $entityData['slug'] = $controllerHelper->formatPermalink($entityData['slug']);
                        }
                    «ENDIF»
                «IF hasUploads»
                } else {
                    // remove fields for form options to prevent them being merged into the entity object
                    if (count($this->uploadFields) > 0) {
                        foreach ($this->uploadFields as $uploadField => $isMandatory) {
                            if (isset($entityData[$uploadField . 'DeleteFile'])) {
                                unset($entityData[$uploadField . 'DeleteFile']);
                            }
                        }
                    }
                «ENDIF»
                }
            «ENDIF»

            if (isset($entityData['repeatCreation'])) {
                if ($this->mode == 'create') {
                    $this->repeatCreateAction = $entityData['repeatCreation'];
                }
                unset($entityData['repeatCreation']);
            }
            «IF hasAttributableEntities»

                if ($this->hasAttributes === true) {
                    $this->processAttributesForUpdate($entity, $formData);
                }
            «ENDIF»
            «IF hasMetaDataEntities»

                if ($this->hasMetaData === true) {
                    $this->processMetaDataForUpdate($entity, $formData);
                }
            «ENDIF»

            // search for relationship plugins to update the corresponding data
            $entityData = $this->writeRelationDataToEntity($view, $entity, $entityData);

            // assign fetched data
            $entity->merge($entityData);

            // we must persist related items now (after the merge) to avoid validation errors
            // if cascades cause the main entity becoming persisted automatically, too
            $this->persistRelationData($view);

            // save updated entity
            $this->entityRef = $entity;

            // return remaining form data
            return $formData;
        }

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
                if ($plugin instanceof «IF targets('1.3.5')»«appName»_Form_Plugin_AbstractObjectSelector«ELSE»AbstractObjectSelector«ENDIF» && method_exists($plugin, 'assignRelatedItemsToEntity')) {
                    $entityData = $plugin->assignRelatedItemsToEntity($entity, $entityData);
                }
                $entityData = $this->writeRelationDataToEntity_rec($entity, $entityData, $plugin->plugins);
            }

            return $entityData;
        }

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
                if ($plugin instanceof «IF targets('1.3.5')»«appName»_Form_Plugin_AbstractObjectSelector«ELSE»AbstractObjectSelector«ENDIF» && method_exists($plugin, 'persistRelatedItems')) {
                    $plugin->persistRelatedItems();
                }
                $this->persistRelationData_rec($plugin->plugins);
            }
        }
    '''

    def private applyAction(Application it, String actionName) '''
        /**
         * This method executes a certain workflow action.
         *
         * @param Array $args Arguments from handleCommand method.
         *
         * @return bool Whether everything worked well or not.
         */
        public function applyAction(array $args = array())
        {
            // stub for subclasses
            return false;
        }
    '''


    def private formHandlerCommonImpl(Application it, String actionName) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Form\Handler\Common;

            use «appNamespace»\Form\Handler\Common\Base\«actionName.formatForCodeCapital»Handler as Base«actionName.formatForCodeCapital»Handler;

        «ENDIF»
        /**
         * This handler class handles the page events of editing forms.
         * It collects common functionality required by different object types.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Handler_Common_«actionName.formatForCodeCapital» extends «appName»_Form_Handler_Common_Base_«actionName.formatForCodeCapital»
        «ELSE»
        class «actionName.formatForCodeCapital»Handler extends Base«actionName.formatForCodeCapital»Handler
        «ENDIF»
        {
            // feel free to extend the base handler class here
        }
    '''




    def private formHandlerBaseImpl(Entity it, String actionName) '''
        «val app = container.application»
        «formHandlerBaseImports(actionName)»

        /**
         * This handler class handles the page events of editing forms.
         * It aims on the «name.formatForDisplay» object type.
         *
         * More documentation is provided in the parent class.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Form_Handler_«name.formatForCodeCapital»_Base_«actionName.formatForCodeCapital» extends «app.appName»_Form_Handler_Common_«actionName.formatForCodeCapital»
        «ELSE»
        class «actionName.formatForCodeCapital»Handler extends Base«actionName.formatForCodeCapital»Handler
        «ENDIF»
        {
            «formHandlerBasePreInitialize»

            «initialize(actionName)»

            «formHandlerBasePostInitialize»
            «IF ownerPermission && standardFields»

                «formHandlerBaseInitEntityForEdit»
            «ENDIF»

            «redirectHelper.getRedirectCodes(it, app, actionName)»

            «redirectHelper.getDefaultReturnUrl(it, app, actionName)»

            «handleCommand(it, actionName)»

            «applyAction(it, actionName)»

            «redirectHelper.getRedirectUrl(it, app, actionName)»
        }
    '''

    def private formHandlerBaseImports(Entity it, String actionName) '''
        «val app = container.application»
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Form\Handler\«name.formatForCodeCapital»\Base;

            use «app.appNamespace»\Form\Handler\Common\«actionName.formatForCodeCapital»Handler as Base«actionName.formatForCodeCapital»Handler;

        «ENDIF»
        «IF hasOptimisticLock || hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
            «IF hasOptimisticLock»
                use Doctrine\ORM\OptimisticLockException;
            «ENDIF»
        «ENDIF»
        «IF !app.targets('1.3.5')»

            use Symfony\Component\Security\Core\Exception\AccessDeniedException;

            use FormUtil;
            use ModUtil;
            use SecurityUtil;
            use System;
            use UserUtil;
            use Zikula_Form_View;
        «ENDIF»
    '''

    def private formHandlerBasePreInitialize(Entity it) '''
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
            «IF app.hasSluggable»
                $this->hasSlugUpdatableField = «(!app.targets('1.3.5') && hasSluggableFields && slugUpdatable).displayBool»;
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
    '''

    def private formHandlerBasePostInitialize(Entity it) '''
        /**
         * Post-initialise hook.
         *
         * @return void
         */
        public function postInitialize()
        {
            parent::postInitialize();
        }
    '''

    def private formHandlerBaseInitEntityForEdit(Entity it) '''
        /**
         * Initialise existing entity for editing.
         *
         * @return Zikula_EntityAccess desired entity instance or null
         */
        protected function initEntityForEdit()
        {
            $entity = parent::initEntityForEdit();

            // only allow editing for the owner or people with higher permissions
            if (isset($entity['createdUserId']) && $entity['createdUserId'] != UserUtil::getVar('uid')) {
                if (!SecurityUtil::checkPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_ADD)) {
                    «IF app.targets('1.3.5')»
                        return LogUtil::registerPermissionError();
                    «ELSE»
                        throw new AccessDeniedException();
                    «ENDIF»
                }
            }

            return $entity;
        }
    '''

    def private formHandlerImpl(Entity it, String actionName) '''
        «val app = container.application»
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Form\Handler\«name.formatForCodeCapital»;

            use «app.appNamespace»\Form\Handler\«name.formatForCodeCapital»\Base\«actionName.formatForCodeCapital»Handler as Base«actionName.formatForCodeCapital»Handler;

        «ENDIF»
        /**
         * This handler class handles the page events of the Form called by the «formatForCode(app.appName + '_' + name + '_' + actionName)»() function.
         * It aims on the «name.formatForDisplay» object type.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Form_Handler_«name.formatForCodeCapital»_«actionName.formatForCodeCapital» extends «app.appName»_Form_Handler_«name.formatForCodeCapital»_Base_«actionName.formatForCodeCapital»
        «ELSE»
        class «actionName.formatForCodeCapital»Handler extends Base«actionName.formatForCodeCapital»Handler
        «ENDIF»
        {
            // feel free to extend the base handler class here
        }
    '''


    def private initialize(Entity it, String actionName) '''
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

            if ($this->mode == 'create') {
                «IF app.targets('1.3.5')»
                    $modelHelper = new «app.appName»_Util_Model($this->view->getServiceManager());
                «ELSE»
                    $modelHelper = $this->view->getServiceManager()->get('«app.appName.formatForDB».model_helper');
                «ENDIF»
                if (!$modelHelper->canBeCreated($this->objectType)) {
                    «IF app.targets('1.3.5')»
                        LogUtil::registerError($this->__('Sorry, but you can not create the «name.formatForDisplay» yet as other items are required which must be created before!'));
                    «ELSE»
                        $logger = $this->view->getServiceManager()->get('logger');
                        $logger->notice('{app}: User {user} tried to create a new {entity}, but failed as it other items are required which must be created before.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => $this->objectType));
                    «ENDIF»

                    return $this->view->redirect($this->getRedirectUrl(null));
                }
            }

            $entity = $this->entityRef;
            «IF hasOptimisticLock»

                if ($this->mode == 'edit') {
                    «IF app.targets('1.3.5')»
                        SessionUtil::setVar($this->name . 'EntityVersion', $entity->get«getVersionField.name.formatForCodeCapital»());
                    «ELSE»
                        $this->request->getSession()->set($this->name . 'EntityVersion', $entity->get«getVersionField.name.formatForCodeCapital»());
                    «ENDIF»
                }
            «ENDIF»
            «relationPresetsHelper.initPresets(it)»

            // save entity reference for later reuse
            $this->entityRef = $entity;

            $entityData = $entity->toArray();
            «IF app.hasListFields»

                if (count($this->listFields) > 0) {
                    «IF app.targets('1.3.5')»
                        $helper = new «app.appName»_Util_ListEntries($this->view->getServiceManager());
                    «ELSE»
                        $helper = $this->view->getServiceManager()->get('«app.appName.formatForDB».listentries_helper');
                    «ENDIF»

                    foreach ($this->listFields as $listField => $isMultiple) {
                        $entityData[$listField . 'Items'] = $helper->getEntries($this->objectType, $listField);
                        if ($isMultiple) {
                            $entityData[$listField] = $helper->extractMultiList($entityData[$listField]);
                        }
                    }
                }
            «ENDIF»
            «val timeFields = getDerivedFields.filter(TimeField)»
            «IF !timeFields.empty»

                «FOR timeField : timeFields»
                    $entityData['«timeField.name.formatForCode»'] = $entity['«timeField.name.formatForCode»']->format('H:i:s');
                «ENDFOR»
            «ENDIF»

            // assign data to template as array (makes translatable support easier)
            $this->view->assign($this->objectTypeLower, $entityData);

            if ($this->mode == 'edit') {
                // assign formatted title
                $this->view->assign('formattedEntityTitle', $entity->getTitleFromDisplayPattern());
            }

            // everything okay, no initialization errors occured
            return true;
        }
    '''

    def private handleCommand(Entity it, String actionName) '''
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
         * @param Array   $args    Arguments from handleCommand method.
         * @param Boolean $success Becomes true if this is a success, false for default error.
         *
         * @return String desired status or error message.
         */
        protected function getDefaultMessage($args, $success = false)
        {
            if ($success !== true) {
                return parent::getDefaultMessage($args, $success);
            }

            $message = '';
            switch ($args['commandName']) {
                «IF app.hasWorkflowState('deferred')»
                 case 'defer':
                «ENDIF»
                case 'submit':
                            if ($this->mode == 'create') {
                                $message = $this->__('Done! «name.formatForDisplayCapital» created.');
                            } else {
                                $message = $this->__('Done! «name.formatForDisplayCapital» updated.');
                            }
                            break;
                case 'delete':
                            $message = $this->__('Done! «name.formatForDisplayCapital» deleted.');
                            break;
                default:
                            $message = $this->__('Done! «name.formatForDisplayCapital» updated.');
                            break;
            }

            return $message;
        }
    '''

    def private applyAction(Entity it, String actionName) '''
        /**
         * This method executes a certain workflow action.
         *
         * @param Array $args Arguments from handleCommand method.
         *
         * @return bool Whether everything worked well or not.
         «IF !app.targets('1.3.5')»
         *
         * @throws RuntimeException Thrown if concurrent editing is recognised or another error occurs
         «ENDIF»
         */
        public function applyAction(array $args = array())
        {
            // get treated entity reference from persisted member var
            $entity = $this->entityRef;

            $action = $args['commandName'];
            «IF hasOptimisticLock || hasPessimisticWriteLock»

                $applyLock = ($this->mode != 'create' && $action != 'delete');
                «IF hasOptimisticLock»
                    «IF app.targets('1.3.5')»
                        $expectedVersion = SessionUtil::getVar($this->name . 'EntityVersion', 1);
                    «ELSE»
                        $expectedVersion = $this->request->getSession()->get($this->name . 'EntityVersion', 1);
                    «ENDIF»
                «ENDIF»
            «ENDIF»

            try {
                «IF hasOptimisticLock || hasPessimisticWriteLock»
                    if ($applyLock) {
                        // assert version
                        «IF hasOptimisticLock»
                            $this->entityManager->lock($entity, LockMode::OPTIMISTIC, $expectedVersion);
                        «ELSEIF hasPessimisticWriteLock»
                            $this->entityManager->lock($entity, LockMode::«lockType.lockTypeAsConstant»);
                        «ENDIF»
                    }

                «ENDIF»
                // execute the workflow action
                «IF app.targets('1.3.5')»
                    $workflowHelper = new «app.appName»_Util_Workflow($this->view->getServiceManager());
                «ELSE»
                    $workflowHelper = $this->view->getServiceManager()->get('«app.appName.formatForDB».workflow_helper');
                «ENDIF»
                $success = $workflowHelper->executeAction($entity, $action);
            «IF hasOptimisticLock»
                } catch(OptimisticLockException $e) {
                    «IF app.targets('1.3.5')»
                        LogUtil::registerError($this->__('Sorry, but someone else has already changed this record. Please apply the changes again!'));
                    «ELSE»
                        $this->request->getSession()->getFlashBag()->add('error', $this->__('Sorry, but someone else has already changed this record. Please apply the changes again!'));
                        $logger = $this->view->getServiceManager()->get('logger');
                        $logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed as someone else has already changed it.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()));
                    «ENDIF»
            «ENDIF»
            } catch(\Exception $e) {
                «IF app.targets('1.3.5')»
                    LogUtil::registerError($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('error', $this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
                    $logger = $this->view->getServiceManager()->get('logger');
                    $logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed. Error details: {errorMessage}.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier(), 'errorMessage' => $e->getMessage()));
                «ENDIF»
            }

            $this->addDefaultMessage($args, $success);

            if ($success && $this->mode == 'create') {
                // store new identifier
                foreach ($this->idFields as $idField) {
                    $this->idValues[$idField] = $entity[$idField];
                }
            }

            «relationPresetsHelper.saveNonEditablePresets(it, app)»

            return $success;
        }
    '''
}
