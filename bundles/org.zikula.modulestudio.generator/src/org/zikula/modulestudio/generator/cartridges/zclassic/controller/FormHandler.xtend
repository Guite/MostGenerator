package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.Locking
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.Redirect
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.RelationPresets
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.AutoCompletionRelationTransformer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.ListFieldTransformer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.UploadFileTransformer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.Config
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.DeleteEntity
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.EditEntity
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.AutoCompletionRelationType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.ColourType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.EntityTreeType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.GeoType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.MultiListType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.UploadType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.UserType
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class FormHandler {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    FileHelper fh = new FileHelper
    Redirect redirectHelper = new Redirect
    RelationPresets relationPresetsHelper = new RelationPresets
    Locking locking = new Locking

    Application app

    /**
     * Entry point for Form handler classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        app = it
        if (hasEditActions()) {
            // form handlers
            generateCommon('edit', fsa)
            for (entity : getAllEntities.filter[e|e.hasActions('edit')]) {
                entity.generate('edit', fsa)
            }
            // form types
            for (entity : entities.filter[e|e instanceof MappedSuperClass || e.hasActions('edit')]) {
                new EditEntity().generate(entity, fsa)
            }
            if (hasColourFields) {
                new ColourType().generate(it, fsa)
            }
            if (hasGeographical) {
                new GeoType().generate(it, fsa)
            }
            if (hasTrees) {
                new EntityTreeType().generate(it, fsa)
            }
            if (hasUploads) {
                new UploadType().generate(it, fsa)
                new UploadFileTransformer().generate(it, fsa)
            }
            if (hasUserFields) {
                new UserType().generate(it, fsa)
            }
            if (hasMultiListFields) {
                new MultiListType().generate(it, fsa)
                new ListFieldTransformer().generate(it, fsa)
            }
            if (needsAutoCompletion) {
                new AutoCompletionRelationType().generate(it, fsa)
                new AutoCompletionRelationTransformer().generate(it, fsa)
            }
        }
        // additional form types
        new DeleteEntity().generate(it, fsa)
        new Config().generate(it, fsa)
    }

    /**
     * Entry point for generic Form handler base classes.
     */
    def private generateCommon(Application it, String actionName, IFileSystemAccess fsa) {
        println('Generating "' + name + '" form handler base class')
        val formHandlerFolder = getAppSourceLibPath + 'Form/Handler/Common/'
        generateClassPair(fsa, formHandlerFolder + actionName.formatForCodeCapital + 'Handler.php',
            fh.phpFileContent(it, formHandlerCommonBaseImpl(actionName)), fh.phpFileContent(app, formHandlerCommonImpl(actionName))
        )
    }

    /**
     * Entry point for Form handler classes per entity.
     */
    def private generate(Entity it, String actionName, IFileSystemAccess fsa) {
        println('Generating form handler classes for "' + name + '_' + actionName + '"')
        val formHandlerFolder = app.getAppSourceLibPath + 'Form/Handler/' + name.formatForCodeCapital + '/'
        app.generateClassPair(fsa, formHandlerFolder + actionName.formatForCodeCapital + 'Handler.php',
            fh.phpFileContent(app, formHandlerBaseImpl(actionName)), fh.phpFileContent(app, formHandlerImpl(actionName))
        )
    }

    def private formHandlerCommonBaseImpl(Application it, String actionName) '''
        namespace «appNamespace»\Form\Handler\Common\Base;

        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\HttpFoundation\RedirectResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
        use Symfony\Component\Routing\RouterInterface;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\Core\RouteUrl;
        use ModUtil;
        use RuntimeException;
        use UserUtil;
        «IF needsFeatureActivationHelper»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * This handler class handles the page events of editing forms.
         * It collects common functionality required by different object types.
         */
        abstract class Abstract«actionName.formatForCodeCapital»Handler
        {
            use TranslatorTrait;

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
             * @var EntityAccess
             */
            protected $entityRef = null;

            /**
             * List of identifier names.
             *
             * @var array
             */
            protected $idFields = [];

            /**
             * List of identifiers of treated entity.
             *
             * @var array
             */
            protected $idValues = [];

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
            «IF !relations.filter(JoinRelationship).empty»
                «relationPresetsHelper.memberFields(it)»

                /**
                 * Full prefix for related items.
                 *
                 * @var string
                 */
                protected $idPrefix = '';
            «ENDIF»

            /**
             * Whether an existing item is used as template for a new one.
             *
             * @var boolean
             */
            protected $hasTemplateId = false;

            «locking.memberVars»
            «IF hasAttributableEntities»

                /**
                 * Whether the entity has attributes or not.
                 *
                 * @var boolean
                 */
                protected $hasAttributes = false;
            «ENDIF»
            «IF hasSluggable && !getAllEntities.filter[slugUpdatable].empty»

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

            /**
             * @var ContainerBuilder
             */
            protected $container;

            /**
             * The current request.
             *
             * @var Request
             */
            protected $request = null;

            /**
             * The router.
             *
             * @var RouterInterface
             */
            protected $router = null;

            /**
             * The handled form type.
             *
             * @var AbstractType
             */
            protected $form = null;

            /**
             * Template parameters.
             *
             * @var array
             */
            protected $templateParameters = [];

            /**
             * «actionName.formatForCodeCapital»Handler constructor.
             *
             * @param ContainerBuilder    $container    ContainerBuilder service instance
             * @param TranslatorInterface $translator   Translator service instance
             * @param RequestStack        $requestStack RequestStack service instance
             * @param RouterInterface     $router       Router service instance
             */
            public function __construct(ContainerBuilder $container, TranslatorInterface $translator, RequestStack $requestStack, RouterInterface $router)
            {
                $this->container = $container;
                $this->setTranslator($translator);
                $this->request = $requestStack->getCurrentRequest();
                $this->router = $router;
            }

            «setTranslatorMethod»

            «processForm»

            «redirectHelper.getRedirectCodes(it)»

            «handleCommand»

            «fetchInputData»

            «applyAction»
            «IF needsApproval»

                «prepareWorkflowAdditions»
            «ENDIF»
        }
    '''

    def private dispatch processForm(Application it) '''
        /**
         * Initialise form handler.
         *
         * This method takes care of all necessary initialisation of our data and form states.
         *
         * @param array $templateParameters List of preassigned template variables
         *
         * @return boolean False in case of initialisation errors, otherwise true
         *
         * @throws NotFoundHttpException Thrown if item to be edited isn't found
         * @throws RuntimeException      Thrown if the workflow actions can not be determined
         */
        public function processForm(array $templateParameters)
        {
            $this->templateParameters = $templateParameters;
            $this->templateParameters['inlineUsage'] = UserUtil::getTheme() == 'ZikulaPrinterTheme' ? true : false;

            «IF !relations.filter(JoinRelationship).empty»
                $this->idPrefix = $this->request->query->getAlnum('idp', '');
            «ENDIF»

            // initialise redirect goal
            $this->returnTo = $this->request->query->get('returnTo', null);
            if (null === $this->returnTo) {
                // default to referer
                if ($this->request->getSession()->has('referer')) {
                    $this->returnTo = $this->request->getSession()->get('referer');
                } elseif ($this->request->headers->has('referer')) {
                    $this->returnTo = $this->request->headers->get('referer');
                    $this->request->getSession()->set('referer', $this->returnTo);
                } elseif ($this->request->server->has('HTTP_REFERER')) {
                    $this->returnTo = $this->request->server->get('HTTP_REFERER');
                    $this->request->getSession()->set('referer', $this->returnTo);
                }
            }
            // store current uri for repeated creations
            $this->repeatReturnUrl = $this->request->getSchemeAndHttpHost() . $this->request->getBasePath() . $this->request->getPathInfo();

            $this->permissionComponent = '«appName»:' . $this->objectTypeCapital . ':';

            $selectionHelper = $this->container->get('«appService».selection_helper');
            $this->idFields = $selectionHelper->getIdFields($this->objectType);

            // retrieve identifier of the object we wish to view
            $controllerHelper = $this->container->get('«appService».controller_helper');

            $this->idValues = $controllerHelper->retrieveIdentifier($this->request, [], $this->objectType, $this->idFields);
            $hasIdentifier = $controllerHelper->isValidIdentifier($this->idValues);

            $entity = null;
            $this->templateParameters['mode'] = $hasIdentifier ? 'edit' : 'create';

            $permissionApi = $this->container->get('zikula_permissions_module.api.permission');

            if ($this->templateParameters['mode'] == 'edit') {
                if (!$permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_EDIT)) {
                    throw new AccessDeniedException();
                }

                $entity = $this->initEntityForEditing();
                if (!is_object($entity)) {
                    return false;
                }

                «locking.addPageLock(it)»
            } else {
                if (!$permissionApi->hasPermission($this->permissionComponent, '::', ACCESS_EDIT)) {
                    throw new AccessDeniedException();
                }

                $entity = $this->initEntityForCreation();
            }

            // save entity reference for later reuse
            $this->entityRef = $entity;

            «initialiseExtensions»

            $workflowHelper = $this->container->get('«appService».workflow_helper');
            $actions = $workflowHelper->getActionsForObject($entity);
            if (false === $actions || !is_array($actions)) {
                $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! Could not determine workflow actions.'));
                $logger = $this->container->get('logger');
                $logArgs = ['app' => '«appName»', 'user' => $this->container->get('zikula_users_module.current_user')->get('uname'), 'entity' => $this->objectType, 'id' => $entity->createCompositeIdentifier()];
                $logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed to determine available workflow actions.', $logArgs);
                throw new \RuntimeException($this->__('Error! Could not determine workflow actions.'));
            }

            $this->templateParameters['actions'] = $actions;

            $this->form = $this->createForm();
            if (!is_object($this->form)) {
                return false;
            }

            // handle form request and check validity constraints of edited entity
            if ($this->form->handleRequest($this->request) && $this->form->isSubmitted()) {
                if ($this->form->isValid()) {
                    $result = $this->handleCommand();
                    if (false === $result) {
                        $this->templateParameters['form'] = $this->form->createView();
                    }

                    return $result;
                }
                if ($this->form->get('cancel')->isClicked()) {
                    return new RedirectResponse($this->getRedirectUrl(['commandName' => 'cancel']), 302);
                }
            }

            $this->templateParameters['form'] = $this->form->createView();

            // everything okay, no initialisation errors occured
            return true;
        }

        /**
         * Creates the form type.
         */
        protected function createForm()
        {
            // to be customised in sub classes
            return null;
        }
        
        «fh.getterMethod(it, 'templateParameters', 'array', true)»
        «createCompositeIdentifier»

        «initEntityForEditing»

        «initEntityForCreation»
        «initTranslationsForEditing»
        «initAttributesForEditing»
    '''

    def private initialiseExtensions(Application it) '''
        «IF hasAttributableEntities || hasTranslatable»
            $featureActivationHelper = $this->container->get('«app.appService».feature_activation_helper');

        «ENDIF»
        «IF hasAttributableEntities»

            if (true === $this->hasAttributes) {
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {
                    $this->initAttributesForEditing();
                }
            }
        «ENDIF»
        «IF hasTranslatable»

            if (true === $this->hasTranslatableFields) {
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType)) {
                    $this->initTranslationsForEditing();
                }
            }
        «ENDIF»
    '''

    def private createCompositeIdentifier(Application it) '''
        /**
         * Create concatenated identifier string (for composite keys).
         *
         * @return String concatenated identifiers
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

    def private initEntityForEditing(Application it) '''
        /**
         * Initialise existing entity for editing.
         *
         * @return EntityAccess|null Desired entity instance or null
         *
         * @throws NotFoundHttpException Thrown if item to be edited isn't found
         */
        protected function initEntityForEditing()
        {
            $selectionHelper = $this->container->get('«appService».selection_helper');
            $entity = $selectionHelper->getEntity($this->objectType, $this->idValues);
            if (null === $entity) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }

            $entity->initWorkflow();

            return $entity;
        }
    '''

    def private initEntityForCreation(Application it) '''
        /**
         * Initialise new entity for creation.
         *
         * @return EntityAccess|null Desired entity instance or null
         *
         * @throws NotFoundHttpException Thrown if item to be cloned isn't found
         */
        protected function initEntityForCreation()
        {
            $this->hasTemplateId = false;
            $templateId = $this->request->query->get('astemplate', '');
            $entity = null;

            if (!empty($templateId)) {
                $templateIdValueParts = explode('_', $templateId);
                $this->hasTemplateId = count($templateIdValueParts) == count($this->idFields);

                if (true === $this->hasTemplateId) {
                    $templateIdValues = [];
                    $i = 0;
                    foreach ($this->idFields as $idField) {
                        $templateIdValues[$idField] = $templateIdValueParts[$i];
                        $i++;
                    }
                    // reuse existing entity
                    $selectionHelper = $this->container->get('«appService».selection_helper');
                    $entityT = $selectionHelper->getEntity($this->objectType, $templateIdValues);
                    if (null === $entityT) {
                        throw new NotFoundHttpException($this->__('No such item.'));
                    }
                    $entity = clone $entityT;
                }
            }

            if (null === $entity) {
                $factory = $this->container->get('«appService».' . $this->objectType . '_factory');
                $createMethod = 'create' . ucfirst($this->objectType);
                $entity = $factory->$createMethod();
            }

            return $entity;
        }
    '''

    def private initTranslationsForEditing(Application it) '''
        «IF hasTranslatable»

            /**
             * Initialise translations.
             */
            protected function initTranslationsForEditing()
            {
                $entity = $this->entityRef;

                // retrieve translated fields
                $translatableHelper = $this->container->get('«app.appService».translatable_helper');
                $translations = $translatableHelper->prepareEntityForEditing($this->objectType, $entity);

                // assign translations
                foreach ($translations as $language => $translationData) {
                    $this->templateParameters[$this->objectTypeLower . $language] = $translationData;
                }

                // assign list of installed languages for translatable extension
                $this->templateParameters['supportedLanguages'] = $translatableHelper->getSupportedLanguages($this->objectType);
            }
        «ENDIF»
    '''

    def private initAttributesForEditing(Application it) '''
        «IF hasAttributableEntities»

            /**
             * Initialise attributes.
             */
            protected function initAttributesForEditing()
            {
                $entity = $this->entityRef;

                $entityData = [];

                // overwrite attributes array entry with a form compatible format
                $attributes = [];
                foreach ($this->getAttributeFieldNames() as $fieldName) {
                    $attributes[$fieldName] = $entity->getAttributes()->get($fieldName) ? $entity->getAttributes()->get($fieldName)->getValue() : '';
                }
                $entityData['attributes'] = $attributes;

                $this->templateParameters['attributes'] = $this->getAttributeFieldNames();
            }

            /**
             * Return list of attribute field names.
             * To be customised in sub classes as needed.
             *
             * @return array list of attribute names
             */
            protected function getAttributeFieldNames()
            {
                return [
                    'field1', 'field2', 'field3'
                ];
            }
        «ENDIF»
    '''

    def private dispatch handleCommand(Application it) '''
        /**
         * Command event handler.
         *
         * @param array $args List of arguments
         *
         * @return mixed Redirect or false on errors
         */
        public function handleCommand($args = [])
        {
            // build $args for BC (e.g. used by redirect handling)
            foreach ($this->templateParameters['actions'] as $action) {
                if ($this->form->get($action['id'])->isClicked()) {
                    $args['commandName'] = $action['id'];
                }
            }
            if ($this->form->get('cancel')->isClicked()) {
                $args['commandName'] = 'cancel';
            }

            $action = $args['commandName'];
            $isRegularAction = !in_array($action, ['delete', 'cancel']);

            if ($isRegularAction || $action == 'delete') {
                $this->fetchInputData($args);
            }

            // get treated entity reference from persisted member var
            $entity = $this->entityRef;
            «IF hasHookSubscribers»

                $hookHelper = null;
                if ($entity->supportsHookSubscribers() && $action != 'cancel') {
                    $hookHelper = $this->container->get('«app.appService».hook_helper');
                    // Let any hooks perform additional validation actions
                    $hookType = $action == 'delete' ? 'validate_delete' : 'validate_edit';
                    $validationHooksPassed = $hookHelper->callValidationHooks($entity, $hookType);
                    if (!$validationHooksPassed) {
                        return false;
                    }
                }
            «ENDIF»
            «IF hasTranslatable»

                if ($isRegularAction && true === $this->hasTranslatableFields) {
                    $featureActivationHelper = $this->container->get('«app.appService».feature_activation_helper');
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType)) {
                        $this->processTranslationsForUpdate();
                    }
                }
            «ENDIF»

            if ($isRegularAction || $action == 'delete') {
                $success = $this->applyAction($args);
                if (!$success) {
                    // the workflow operation failed
                    return false;
                }
                «IF hasHookSubscribers»

                    if ($entity->supportsHookSubscribers()) {
                        // Let any hooks know that we have created, updated or deleted an item
                        $hookType = $action == 'delete' ? 'process_delete' : 'process_edit';
                        $url = null;
                        if ($action != 'delete') {
                            $urlArgs = $entity->createUrlArgs();
                            $urlArgs['_locale'] = $this->container->get('request_stack')->getMasterRequest()->getLocale();
                            $url = new RouteUrl('«appName.formatForDB»_' . $this->objectType . '_display', $urlArgs);
                        }
                        if (null !== $hookHelper) {
                            $hookHelper->callProcessHooks($entity, $hookType, $url);
                        }
                    }
                «ENDIF»
            }

            «locking.releasePageLock(it)»

            return new RedirectResponse($this->getRedirectUrl($args), 302);
        }
        «IF hasAttributableEntities»

            /**
             * Prepare update of attributes.
             *
             * @param EntityAccess $entity Currently treated entity instance
             */
            protected function processAttributesForUpdate($entity)
            {
                foreach ($this->getAttributeFieldNames() as $fieldName) {
                    $value = $this->form['attributes' . $fieldName]->getData();
                    $entity->setAttribute($fieldName, $value);
                }
                «/*
                $entity->setAttribute('url', 'http://www.example.com');
                $entity->setAttribute('url', null); // remove
                */»
            }
        «ENDIF»
        «IF hasTranslatable»

            /**
             * Prepare update of translations.
             */
            protected function processTranslationsForUpdate()
            {
                // get treated entity reference from persisted member var
                $entity = $this->entityRef;

                $entityTransClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucfirst($this->objectType) . 'TranslationEntity';
                $transRepository = $this->entityManager->getRepository($entityTransClass);

                // persist translated fields
                $translatableHelper = $this->container->get('«app.appService».translatable_helper');
                $translations = $translatableHelper->processEntityAfterEditing($this->objectType, $entity, $this->form);

                if ($this->container->get('zikula_extensions_module.api.variable')->getSystemVar('multilingual') == 1) {
                    foreach ($translations as $locale => $translationFields) {
                        foreach ($translationFields as $fieldName => $value) {
                            $transRepository->translate($entity, $fieldName, $locale, $value);
                        }
                    }
                }

                $this->entityManager->flush();
            }
        «ENDIF»

        /**
         * Get success or error message for default operations.
         *
         * @param array   $args    arguments from handleCommand method
         * @param Boolean $success true if this is a success, false for default error
         *
         * @return String desired status or error message
         */
        protected function getDefaultMessage($args, $success = false)
        {
            $message = '';
            switch ($args['commandName']) {
                case 'create':
                    if (true === $success) {
                        $message = $this->__('Done! Item created.');
                    } else {
                        $message = $this->__('Error! Creation attempt failed.');
                    }
                    break;
                case 'update':
                    if (true === $success) {
                        $message = $this->__('Done! Item updated.');
                    } else {
                        $message = $this->__('Error! Update attempt failed.');
                    }
                    break;
                case 'delete':
                    if (true === $success) {
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
         * @param array   $args    arguments from handleCommand method
         * @param Boolean $success true if this is a success, false for default error
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         */
        protected function addDefaultMessage($args, $success = false)
        {
            $message = $this->getDefaultMessage($args, $success);
            if (empty($message)) {
                return;
            }

            $flashType = true === $success ? 'status' : 'error';
            $this->request->getSession()->getFlashBag()->add($flashType, $message);
            $logger = $this->container->get('logger');
            $logArgs = ['app' => '«appName»', 'user' => $this->container->get('zikula_users_module.current_user')->get('uname'), 'entity' => $this->objectType, 'id' => $this->entityRef->createCompositeIdentifier()];
            if (true === $success) {
                $logger->notice('{app}: User {user} updated the {entity} with id {id}.', $logArgs);
            } else {
                $logger->error('{app}: User {user} tried to update the {entity} with id {id}, but failed.', $logArgs);
            }
        }
    '''

    def private fetchInputData(Application it) '''
        /**
         * Input data processing called by handleCommand method.
         *
         * @param array $args Additional arguments
         */
        public function fetchInputData($args)
        {
            // fetch posted data input values as an associative array
            $formData = $this->form->getData();
            «IF hasSluggable && !getAllEntities.filter[slugUpdatable].empty»

                if ($args['commandName'] != 'cancel') {
                    if (true === $this->hasSlugUpdatableField && isset($entityData['slug'])) {
                        $controllerHelper = $this->container->get('«app.appService».controller_helper');
                        $entityData['slug'] = $controllerHelper->formatPermalink($entityData['slug']);
                    }
                }
            «ENDIF»

            if ($this->templateParameters['mode'] == 'create' && isset($this->form['repeatCreation']) && $this->form['repeatCreation']->getData() == 1) {
                $this->repeatCreateAction = true;
            }

            if (isset($this->form['additionalNotificationRemarks']) && $this->form['additionalNotificationRemarks']->getData() != '') {
                $this->request->getSession()->set('«appName»AdditionalNotificationRemarks', $this->form['additionalNotificationRemarks']->getData());
            }
            «IF hasAttributableEntities»

                if (true === $this->hasAttributes) {
                    $featureActivationHelper = $this->container->get('«app.appService».feature_activation_helper');
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {
                        $this->processAttributesForUpdate($entity);
                    }
                }
            «ENDIF»

            // return remaining form data
            return $formData;
        }
    '''

    def private dispatch applyAction(Application it) '''
        /**
         * This method executes a certain workflow action.
         *
         * @param array $args Arguments from handleCommand method
         *
         * @return bool Whether everything worked well or not
         */
        public function applyAction(array $args = [])
        {
            // stub for subclasses
            return false;
        }
    '''

    def private prepareWorkflowAdditions(Application it) '''
        /**
         * Prepares properties related to advanced workflow.
         *
         * @param bool $enterprise Whether the enterprise workflow is used instead of the standard workflow
         *
         * @return array List of additional form options
         */
        protected function prepareWorkflowAdditions($enterprise = false)
        {
            $roles = [];

            «/* TODO recheck this after https://github.com/zikula/core/issues/2800 has been solved */»
            $currentUserApi = $this->container->get('zikula_users_module.current_user');
            $isLoggedIn = $currentUserApi->isLoggedIn();
            $uid = $isLoggedIn ? $currentUserApi->get('uid') : 1;
            $roles['isCreator'] = $this->templateParameters['mode'] == 'create'
                || (method_exists($this->entityRef, 'getCreatedBy') && $this->entityRef->getCreatedBy()->getUid() == $uid);
            $variableApi = $this->container->get('zikula_extensions_module.api.variable');

            $groupArgs = ['uid' => $uid, 'gid' => $variableApi->get('«appName»', 'moderationGroupFor' . $this->objectTypeCapital, 2)];
            $roles['isModerator'] = ModUtil::apiFunc('ZikulaGroupsModule', 'user', 'isgroupmember', $groupArgs);

            if (true === $enterprise) {
                $groupArgs = ['uid' => $uid, 'gid' => $variableApi->get('«appName»', 'superModerationGroupFor' . $this->objectTypeCapital, 2)];
                $roles['isSuperModerator'] = ModUtil::apiFunc('ZikulaGroupsModule', 'user', 'isgroupmember', $groupArgs);
            }

            return $roles;
        }
    '''

    def private formHandlerCommonImpl(Application it, String actionName) '''
        namespace «appNamespace»\Form\Handler\Common;

        use «appNamespace»\Form\Handler\Common\Base\Abstract«actionName.formatForCodeCapital»Handler;

        /**
         * This handler class handles the page events of editing forms.
         * It collects common functionality required by different object types.
         */
        abstract class «actionName.formatForCodeCapital»Handler extends Abstract«actionName.formatForCodeCapital»Handler
        {
            // feel free to extend the base handler class here
        }
    '''




    def private formHandlerBaseImpl(Entity it, String actionName) '''
        «val app = application»
        «formHandlerBaseImports(actionName)»

        /**
         * This handler class handles the page events of editing forms.
         * It aims on the «name.formatForDisplay» object type.
         */
        abstract class Abstract«actionName.formatForCodeCapital»Handler extends «actionName.formatForCodeCapital»Handler
        {
            «processForm»

            «IF ownerPermission && standardFields»

                «formHandlerBaseInitEntityForEditing»
            «ENDIF»

            «redirectHelper.getRedirectCodes(it, app)»

            «redirectHelper.getDefaultReturnUrl(it, app)»

            «handleCommand(it)»

            «applyAction(it)»

            «redirectHelper.getRedirectUrl(it, app)»
        }
    '''

    def private formHandlerBaseImports(Entity it, String actionName) '''
        «val app = application»
        namespace «app.appNamespace»\Form\Handler\«name.formatForCodeCapital»\Base;

        use «app.appNamespace»\Form\Handler\Common\«actionName.formatForCodeCapital»Handler;

        «locking.imports(it)»
        use Symfony\Component\HttpFoundation\RedirectResponse;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use ModUtil;
        use RuntimeException;
        use System;
        use UserUtil;
        «IF app.needsFeatureActivationHelper»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
    '''

    def private memberVarAssignments(Entity it) '''
        $this->objectType = '«name.formatForCode»';
        $this->objectTypeCapital = '«name.formatForCodeCapital»';
        $this->objectTypeLower = '«name.formatForDB»';

        «locking.memberVarAssignments(it)»
        «IF app.hasAttributableEntities»
            $this->hasAttributes = «attributable.displayBool»;
        «ENDIF»
        «IF app.hasSluggable»
            $this->hasSlugUpdatableField = «(hasSluggableFields && slugUpdatable).displayBool»;
        «ENDIF»
        «IF app.hasTranslatable»
            $this->hasTranslatableFields = «hasTranslatableFields.displayBool»;
        «ENDIF»
    '''

    def private formHandlerBaseInitEntityForEditing(Entity it) '''
        /**
         * Initialise existing entity for editing.
         *
         * @return EntityAccess desired entity instance or null
         */
        protected function initEntityForEditing()
        {
            $entity = parent::initEntityForEditing();

            // only allow editing for the owner or people with higher permissions
            $uid = $this->container->get('zikula_users_module.current_user')->get('uid');
            if (!method_exists($entity, 'getCreatedBy') || $entity->getCreatedBy()->getUid() != $uid) {
                $permissionApi = $this->container->get('zikula_permissions_module.api.permission');
                if (!$permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_ADD)) {
                    throw new AccessDeniedException();
                }
            }

            return $entity;
        }
    '''

    def private formHandlerImpl(Entity it, String actionName) '''
        «val app = application»
        namespace «app.appNamespace»\Form\Handler\«name.formatForCodeCapital»;

        use «app.appNamespace»\Form\Handler\«name.formatForCodeCapital»\Base\Abstract«actionName.formatForCodeCapital»Handler;

        /**
         * This handler class handles the page events of the Form called by the «formatForCode(app.appName + '_' + name + '_' + actionName)»() function.
         * It aims on the «name.formatForDisplay» object type.
         */
        class «actionName.formatForCodeCapital»Handler extends Abstract«actionName.formatForCodeCapital»Handler
        {
            // feel free to extend the base handler class here
        }
    '''


    def private dispatch processForm(Entity it) '''
        /**
         * Initialise form handler.
         *
         * This method takes care of all necessary initialisation of our data and form states.
         *
         * @param array $templateParameters List of preassigned template variables
         *
         * @return boolean False in case of initialisation errors, otherwise true
         */
        public function processForm(array $templateParameters)
        {
            «memberVarAssignments»

            $result = parent::processForm($templateParameters);

            if ($this->templateParameters['mode'] == 'create') {
                $modelHelper = $this->container->get('«app.appService».model_helper');
                if (!$modelHelper->canBeCreated($this->objectType)) {
                    $this->request->getSession()->getFlashBag()->add('error', $this->__('Sorry, but you can not create the «name.formatForDisplay» yet as other items are required which must be created before!'));
                    $logger = $this->container->get('logger');
                    $logArgs = ['app' => '«app.appName»', 'user' => $this->container->get('zikula_users_module.current_user')->get('uname'), 'entity' => $this->objectType];
                    $logger->notice('{app}: User {user} tried to create a new {entity}, but failed as it other items are required which must be created before.', $logArgs);

                    return new RedirectResponse($this->getRedirectUrl(['commandName' => '']), 302);
                }
            }

            $entity = $this->entityRef;
            «locking.setVersion(it)»
            «IF !incoming.empty || !outgoing.empty»
                «relationPresetsHelper.initPresets(it)»
            «ENDIF»

            // save entity reference for later reuse
            $this->entityRef = $entity;

            $entityData = $entity->toArray();

            // assign data to template as array (makes translatable support easier)
            $this->templateParameters[$this->objectTypeLower] = $entityData;

            return $result;
        }

        /**
         * Creates the form type.
         */
        protected function createForm()
        {
            $options = [
                «IF hasUploadFieldsEntity»
                    'entity' => $this->entityRef,
                «ENDIF»
                'mode' => $this->templateParameters['mode'],
                'actions' => $this->templateParameters['actions'],
                «IF !incoming.empty || !outgoing.empty»
                    'inlineUsage' => $this->templateParameters['inlineUsage']
                «ENDIF»
            ];
            «IF attributable»
                $featureActivationHelper = $this->container->get('«app.appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {
                    $options['attributes'] = $this->templateParameters['attributes'];
                }
            «ENDIF»
            «IF workflow != EntityWorkflowType.NONE»

                $workflowRoles = $this->prepareWorkflowAdditions(«(workflow == EntityWorkflowType.ENTERPRISE).displayBool»);
                $options = array_merge($options, $workflowRoles);
            «ENDIF»

            return $this->container->get('form.factory')->create('«app.appNamespace»\Form\Type\«name.formatForCodeCapital»Type', $this->entityRef, $options);
        }
    '''

    def private dispatch handleCommand(Entity it) '''
        /**
         * Command event handler.
         *
         * This event handler is called when a command is issued by the user.
         *
         * @param array $args List of arguments
         *
         * @return mixed Redirect or false on errors
         */
        public function handleCommand($args = [])
        {
            $result = parent::handleCommand($args);
            if (false === $result) {
                return $result;
            }

            // build $args for BC (e.g. used by redirect handling)
            foreach ($this->templateParameters['actions'] as $action) {
                if ($this->form->get($action['id'])->isClicked()) {
                    $args['commandName'] = $action['id'];
                }
            }
            if ($this->form->get('cancel')->isClicked()) {
                $args['commandName'] = 'cancel';
            }

            return new RedirectResponse($this->getRedirectUrl($args), 302);
        }

        /**
         * Get success or error message for default operations.
         *
         * @param array   $args    Arguments from handleCommand method
         * @param Boolean $success Becomes true if this is a success, false for default error
         *
         * @return String desired status or error message
         */
        protected function getDefaultMessage($args, $success = false)
        {
            if (false === $success) {
                return parent::getDefaultMessage($args, $success);
            }

            $message = '';
            switch ($args['commandName']) {
                «IF app.hasWorkflowState('deferred')»
                    case 'defer':
                «ENDIF»
                case 'submit':
                    if ($this->templateParameters['mode'] == 'create') {
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

    def private dispatch applyAction(Entity it) '''
        /**
         * This method executes a certain workflow action.
         *
         * @param array $args Arguments from handleCommand method
         *
         * @return bool Whether everything worked well or not
         *
         * @throws RuntimeException Thrown if concurrent editing is recognised or another error occurs
         */
        public function applyAction(array $args = [])
        {
            // get treated entity reference from persisted member var
            $entity = $this->entityRef;

            $action = $args['commandName'];
            «locking.getVersion(it)»

            $success = false;
            $flashBag = $this->request->getSession()->getFlashBag();
            $logger = $this->container->get('logger');
            try {
                «locking.applyLock(it)»
                // execute the workflow action
                $workflowHelper = $this->container->get('«app.appService».workflow_helper');
                $success = $workflowHelper->executeAction($entity, $action);
            «locking.catchException(it)»
            } catch(\Exception $e) {
                $flashBag->add('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . ' ' . $e->getMessage());
                $logArgs = ['app' => '«app.appName»', 'user' => $this->container->get('zikula_users_module.current_user')->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier(), 'errorMessage' => $e->getMessage()];
                $logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed. Error details: {errorMessage}.', $logArgs);
            }

            $this->addDefaultMessage($args, $success);

            if ($success && $this->templateParameters['mode'] == 'create') {
                // store new identifier
                foreach ($this->idFields as $idField) {
                    $this->idValues[$idField] = $entity[$idField];
                }
            }
            «IF !incoming.empty || !outgoing.empty»
                «relationPresetsHelper.saveNonEditablePresets(it, app)»
            «ENDIF»

            return $success;
        }
    '''
}
