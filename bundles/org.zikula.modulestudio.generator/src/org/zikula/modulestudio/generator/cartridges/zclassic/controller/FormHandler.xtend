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
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.UserFieldTransformer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.Config
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.DeleteEntity
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.EditEntity
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.AutoCompletionRelationType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.ColourType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.DateTimeType
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
            for (entity : getAllEntities.filter[hasEditAction]) {
                entity.generate('edit', fsa)
            }
            // form types
            for (entity : entities.filter[e|e instanceof MappedSuperClass || (e as Entity).hasEditAction]) {
                new EditEntity().generate(entity, fsa)
            }
            if (hasColourFields) {
                new ColourType().generate(it, fsa)
            }
            if (needsDatetimeType) {
                new DateTimeType().generate(it, fsa)
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
            if (needsUserAutoCompletion) {
                new UserType().generate(it, fsa)
                new UserFieldTransformer().generate(it, fsa)
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

        use Psr\Log\LoggerInterface;
        use RuntimeException;
        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormFactoryInterface;
        use Symfony\Component\HttpFoundation\RedirectResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF !targets('1.4-dev')»
            use Symfony\Component\HttpKernel\KernelInterface;
        «ENDIF»
        use Symfony\Component\Routing\RouterInterface;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF targets('1.4-dev')»
            use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
        «ENDIF»
        use Zikula\Core\Doctrine\EntityAccess;
        «IF hasHookSubscribers»
            use Zikula\Core\RouteUrl;
        «ENDIF»
        «IF hasTranslatable || needsApproval»
            use Zikula\ExtensionsModule\Api\VariableApi;
        «ENDIF»
        «IF needsApproval»
            use Zikula\GroupsModule\Entity\Repository\GroupApplicationRepository;
        «ENDIF»
        use Zikula\PageLockModule\Api\LockingApi;
        use Zikula\PermissionsModule\Api\PermissionApi;
        use Zikula\UsersModule\Api\CurrentUserApi;
        use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;
        «IF needsFeatureActivationHelper»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        «IF hasHookSubscribers»
            use «appNamespace»\Helper\HookHelper;
        «ENDIF»
        use «appNamespace»\Helper\ModelHelper;
        use «appNamespace»\Helper\SelectionHelper;
        «IF hasTranslatable»
            use «appNamespace»\Helper\TranslatableHelper;
        «ENDIF»
        use «appNamespace»\Helper\WorkflowHelper;

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
             * @var «IF targets('1.4-dev')»ZikulaHttpKernelInterface«ELSE»KernelInterface«ENDIF»
             */
            protected $kernel;

            /**
             * @var FormFactoryInterface
             */
            protected $formFactory;

            /**
             * The current request.
             *
             * @var Request
             */
            protected $request;

            /**
             * The router.
             *
             * @var RouterInterface
             */
            protected $router;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * @var PermissionApi
             */
            protected $permissionApi;

            «IF hasTranslatable || needsApproval»
                /**
                 * @var VariableApi
                 */
                protected $variableApi;

            «ENDIF»
            /**
             * @var CurrentUserApi
             */
            protected $currentUserApi;

            «IF needsApproval»
                /**
                 * @var GroupApplicationRepository
                 */
                protected $groupApplicationRepository;

            «ENDIF»
            /**
             * @var «name.formatForCodeCapital»Factory
             */
            protected $entityFactory;

            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;
            «IF hasHookSubscribers»

                /**
                 * @var HookHelper
                 */
                protected $hookHelper;
            «ENDIF»

            /**
             * @var ModelHelper
             */
            protected $modelHelper;

            /**
             * @var SelectionHelper
             */
            protected $selectionHelper;

            /**
             * @var WorkflowHelper
             */
            protected $workflowHelper;
            «IF hasTranslatable»

                /**
                 * @var TranslatableHelper
                 */
                protected $translatableHelper;
            «ENDIF»
            «IF needsFeatureActivationHelper»

                /**
                 * @var FeatureActivationHelper
                 */
                protected $featureActivationHelper;
            «ENDIF»

            /**
             * Reference to optional locking api.
             *
             * @var LockingApi
             */
            protected $lockingApi = null;

            /**
             * The handled form type.
             *
             * @var AbstractType
             */
            protected $form;

            /**
             * Template parameters.
             *
             * @var array
             */
            protected $templateParameters = [];

            /**
             * «actionName.formatForCodeCapital»Handler constructor.
             *
             «IF targets('1.4-dev')»
             * @param ZikulaHttpKernelInterface $kernel      Kernel service instance
             «ELSE»
             * @param KernelInterface      $kernel           Kernel service instance
             «ENDIF»
             * @param TranslatorInterface  $translator       Translator service instance
             * @param FormFactoryInterface $formFactory      FormFactory service instance
             * @param RequestStack         $requestStack     RequestStack service instance
             * @param RouterInterface      $router           Router service instance
             * @param LoggerInterface      $logger           Logger service instance
             * @param PermissionApi        $permissionApi    PermissionApi service instance
             «IF hasTranslatable || needsApproval»
             * @param VariableApi          $variableApi      VariableApi service instance
             «ENDIF»
             * @param CurrentUserApi       $currentUserApi   CurrentUserApi service instance
             «IF needsApproval»
             * @param GroupApplicationRepository $groupApplicationRepository GroupApplicationRepository service instance.
             «ENDIF»
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
             * @param ControllerHelper     $controllerHelper ControllerHelper service instance
             * @param ModelHelper          $modelHelper      ModelHelper service instance
             * @param SelectionHelper      $selectionHelper  SelectionHelper service instance
             * @param WorkflowHelper       $workflowHelper   WorkflowHelper service instance
             «IF hasHookSubscribers»
             * @param HookHelper           $hookHelper       HookHelper service instance
             «ENDIF»
             «IF hasTranslatable»
             * @param TranslatableHelper   $translatableHelper TranslatableHelper service instance
             «ENDIF»
             «IF needsFeatureActivationHelper»
             * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
             «ENDIF»
             */
            public function __construct(
                «IF targets('1.4-dev')»ZikulaHttpKernelInterface«ELSE»KernelInterface«ENDIF» $kernel,
                TranslatorInterface $translator,
                FormFactoryInterface $formFactory,
                RequestStack $requestStack,
                RouterInterface $router,
                LoggerInterface $logger,
                PermissionApi $permissionApi,
                «IF hasTranslatable || needsApproval»
                    VariableApi $variableApi,
                «ENDIF»
                CurrentUserApi $currentUserApi,
                «IF needsApproval»
                    GroupApplicationRepository $groupApplicationRepository,
                «ENDIF»
                «name.formatForCodeCapital»Factory $entityFactory,
                ControllerHelper $controllerHelper,
                ModelHelper $modelHelper,
                SelectionHelper $selectionHelper,
                WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
                HookHelper $hookHelper«ENDIF»«IF hasTranslatable»,
                TranslatableHelper $translatableHelper«ENDIF»«IF needsFeatureActivationHelper»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»)
            {
                $this->kernel = $kernel;
                $this->setTranslator($translator);
                $this->formFactory = $formFactory;
                $this->request = $requestStack->getCurrentRequest();
                $this->router = $router;
                $this->logger = $logger;
                $this->permissionApi = $permissionApi;
                «IF hasTranslatable || needsApproval»
                    $this->variableApi = $variableApi;
                «ENDIF»
                $this->currentUserApi = $currentUserApi;
                «IF needsApproval»
                    $this->groupApplicationRepository = $groupApplicationRepository;
                «ENDIF»
                $this->entityFactory = $entityFactory;
                $this->controllerHelper = $controllerHelper;
                $this->modelHelper = $modelHelper;
                $this->selectionHelper = $selectionHelper;
                $this->workflowHelper = $workflowHelper;
                «IF hasHookSubscribers»
                    $this->hookHelper = $hookHelper;
                «ENDIF»
                «IF hasTranslatable»
                    $this->translatableHelper = $translatableHelper;
                «ENDIF»
                «IF needsFeatureActivationHelper»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
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

            /**
             * Sets optional locking api reference.
             *
             * @param LockingApi $lockingApi
             */
            public function setLockingApi(LockingApi $lockingApi)
            {
                $this->lockingApi = $lockingApi;
            }
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
         * @throws RuntimeException Thrown if the workflow actions can not be determined
         */
        public function processForm(array $templateParameters)
        {
            $this->templateParameters = $templateParameters;
            «IF app.needsAutoCompletion»
                $this->templateParameters['inlineUsage'] = $this->request->query->getBoolean('raw', false);
            «ENDIF»
            «IF !relations.filter(JoinRelationship).empty»

                $this->idPrefix = $this->request->query->getAlnum('idp', '');
            «ENDIF»

            // initialise redirect goal
            $this->returnTo = $this->request->query->get('returnTo', null);
            if (null === $this->returnTo) {
                // default to referer
                if ($this->request->getSession()->has('«appName.formatForDB»Referer')) {
                    $this->returnTo = $this->request->getSession()->get('«appName.formatForDB»Referer');
                } elseif ($this->request->headers->has('«appName.formatForDB»Referer')) {
                    $this->returnTo = $this->request->headers->get('«appName.formatForDB»Referer');
                    $this->request->getSession()->set('«appName.formatForDB»Referer', $this->returnTo);
                } elseif ($this->request->server->has('HTTP_REFERER')) {
                    $this->returnTo = $this->request->server->get('HTTP_REFERER');
                    $this->request->getSession()->set('«appName.formatForDB»Referer', $this->returnTo);
                }
            }
            // store current uri for repeated creations
            $this->repeatReturnUrl = $this->request->getSchemeAndHttpHost() . $this->request->getBasePath() . $this->request->getPathInfo();

            $this->permissionComponent = '«appName»:' . $this->objectTypeCapital . ':';

            $this->idFields = $this->selectionHelper->getIdFields($this->objectType);

            // retrieve identifier of the object we wish to view
            $this->idValues = $this->controllerHelper->retrieveIdentifier($this->request, [], $this->objectType, $this->idFields);
            $hasIdentifier = $this->controllerHelper->isValidIdentifier($this->idValues);

            $entity = null;
            $this->templateParameters['mode'] = $hasIdentifier ? 'edit' : 'create';

            if ($this->templateParameters['mode'] == 'edit') {
                if (!$this->permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_EDIT)) {
                    throw new AccessDeniedException();
                }

                $entity = $this->initEntityForEditing();
                if (null !== $entity) {
                    «locking.addPageLock(it)»
                }
            } else {
                if (!$this->permissionApi->hasPermission($this->permissionComponent, '::', ACCESS_EDIT)) {
                    throw new AccessDeniedException();
                }

                $entity = $this->initEntityForCreation();

                // set default values from request parameters
                foreach ($this->request->query->all() as $key => $value) {
                    if (strlen($key) < 5 || substr($key, 0, 4) != 'set_') {
                        continue;
                    }
                    $fieldName = str_replace('set_', '', $key);
                    $setterName = 'set' . ucfirst($fieldName);
                    if (!method_exists($entity, $setterName)) {
                        continue;
                    }
                    $entity[$fieldName] = $value;
                }
            }

            if (null === $entity) {
                $this->request->getSession()->getFlashBag()->add('error', $this->__('No such item found.'));

                return new RedirectResponse($this->getRedirectUrl(['commandName' => 'cancel']), 302);
            }

            // save entity reference for later reuse
            $this->entityRef = $entity;

            «initialiseExtensions»
            «IF !relations.filter(JoinRelationship).empty»
                «relationPresetsHelper.callBaseMethod(it)»
            «ENDIF»

            $actions = $this->workflowHelper->getActionsForObject($entity);
            if (false === $actions || !is_array($actions)) {
                $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! Could not determine workflow actions.'));
                $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $this->objectType, 'id' => $entity->createCompositeIdentifier()];
                $this->logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed to determine available workflow actions.', $logArgs);
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
        «IF !relations.filter(JoinRelationship).empty»

            «relationPresetsHelper.baseMethod(it)»
        «ENDIF»
        
        «fh.getterMethod(it, 'templateParameters', 'array', true)»
        «createCompositeIdentifier»

        «initEntityForEditing»

        «initEntityForCreation»
        «initTranslationsForEditing»
        «initAttributesForEditing»
    '''

    def private initialiseExtensions(Application it) '''
        «IF hasAttributableEntities»

            if (true === $this->hasAttributes) {
                if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {
                    $this->initAttributesForEditing();
                }
            }
        «ENDIF»
        «IF hasTranslatable»

            if (true === $this->hasTranslatableFields) {
                if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType)) {
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
         */
        protected function initEntityForEditing()
        {
            $entity = $this->selectionHelper->getEntity($this->objectType, $this->idValues);
            if (null === $entity) {
                return null;
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
                    $entityT = $this->selectionHelper->getEntity($this->objectType, $templateIdValues);
                    if (null === $entityT) {
                        return null;
                    }
                    $entity = clone $entityT;
                }
            }

            if (null === $entity) {
                $createMethod = 'create' . ucfirst($this->objectType);
                $entity = $this->entityFactory->$createMethod();
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
                $translations = $this->translatableHelper->prepareEntityForEditing($this->objectType, $entity);

                // assign translations
                foreach ($translations as $language => $translationData) {
                    $this->templateParameters[$this->objectTypeLower . $language] = $translationData;
                }

                // assign list of installed languages for translatable extension
                $this->templateParameters['supportedLanguages'] = $this->translatableHelper->getSupportedLanguages($this->objectType);
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

                if ($entity->supportsHookSubscribers() && $action != 'cancel') {
                    // Let any hooks perform additional validation actions
                    $hookType = $action == 'delete' ? 'validate_delete' : 'validate_edit';
                    $validationHooksPassed = $this->hookHelper->callValidationHooks($entity, $hookType);
                    if (!$validationHooksPassed) {
                        return false;
                    }
                }
            «ENDIF»
            «IF hasTranslatable»

                if ($isRegularAction && true === $this->hasTranslatableFields) {
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType)) {
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
                            $urlArgs['_locale'] = $this->request->getLocale();
                            $url = new RouteUrl('«appName.formatForDB»_' . $this->objectType . '_display', $urlArgs);
                        }
                        $this->hookHelper->callProcessHooks($entity, $hookType, $url);
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
                $transRepository = $this->entityFactory->getObjectManager()->getRepository($entityTransClass);

                // persist translated fields
                $translations = $this->translatableHelper->processEntityAfterEditing($this->objectType, $entity, $this->form);

                if ($this->variableApi->getSystemVar('multilingual') == 1) {
                    foreach ($translations as $locale => $translationFields) {
                        foreach ($translationFields as $fieldName => $value) {
                            $transRepository->translate($entity, $fieldName, $locale, $value);
                        }
                    }
                }

                $this->entityFactory->getObjectManager()->flush();
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
            $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $this->objectType, 'id' => $this->entityRef->createCompositeIdentifier()];
            if (true === $success) {
                $this->logger->notice('{app}: User {user} updated the {entity} with id {id}.', $logArgs);
            } else {
                $this->logger->error('{app}: User {user} tried to update the {entity} with id {id}, but failed.', $logArgs);
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
                        $entityData['slug'] = $this->controllerHelper->formatPermalink($entityData['slug']);
                    }
                }
            «ENDIF»

            if ($this->templateParameters['mode'] == 'create' && isset($this->form['repeatCreation']) && $this->form['repeatCreation']->getData() == 1) {
                $this->repeatCreateAction = true;
            }
            «IF hasStandardFieldEntities»

                if (method_exists($this->entityRef, 'getCreatedBy')) {
                    if (isset($this->form['moderationSpecificCreator']) && null !== $this->form['moderationSpecificCreator']->getData()) {
                        $this->entityRef->setCreatedBy($this->form['moderationSpecificCreator']->getData());
                    }
                    if (isset($this->form['moderationSpecificCreationDate']) && $this->form['moderationSpecificCreationDate']->getData() != '') {
                        $this->entityRef->setCreatedDate($this->form['moderationSpecificCreationDate']->getData());
                    }
                }
            «ENDIF»

            if (isset($this->form['additionalNotificationRemarks']) && $this->form['additionalNotificationRemarks']->getData() != '') {
                $this->request->getSession()->set('«appName»AdditionalNotificationRemarks', $this->form['additionalNotificationRemarks']->getData());
            }
            «IF hasAttributableEntities»

                if (true === $this->hasAttributes) {
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {
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
         * Prepares properties related to advanced workflows.
         *
         * @param bool $enterprise Whether the enterprise workflow is used instead of the standard workflow
         *
         * @return array List of additional form options
         */
        protected function prepareWorkflowAdditions($enterprise = false)
        {
            $roles = [];
            «/* TODO review this after https://github.com/zikula/core/issues/2800 has been solved */»
            $isLoggedIn = $this->currentUserApi->isLoggedIn();
            $currentUserId = $isLoggedIn ? $this->currentUserApi->get('uid') : 1;
            $roles['isCreator'] = $this->templateParameters['mode'] == 'create'
                || (method_exists($this->entityRef, 'getCreatedBy') && $this->entityRef->getCreatedBy()->getUid() == $currentUserId);

            $groupApplicationArgs = [
                'user' => $currentUserId,
                'group' => $this->variableApi->get('«appName»', 'moderationGroupFor' . $this->objectTypeCapital, 2)
            ];
            $roles['isModerator'] = count($this->groupApplicationRepository->findBy($groupApplicationArgs)) > 0;

            if (true === $enterprise) {
                $groupApplicationArgs = [
                    'user' => $currentUserId,
                    'group' => $this->variableApi->get('«appName»', 'superModerationGroupFor' . $this->objectTypeCapital, 2)
                ];
                $roles['isSuperModerator'] = count($this->groupApplicationRepository->findBy($groupApplicationArgs)) > 0;
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

            «IF ownerPermission»

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
        use RuntimeException;
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
         * @return EntityAccess Desired entity instance or null
         */
        protected function initEntityForEditing()
        {
            $entity = parent::initEntityForEditing();

            // only allow editing for the owner or people with higher permissions
            $currentUserId = $this->currentUserApi->isLoggedIn() ? $this->currentUserApi->get('uid') : 1;
            $isOwner = null !== $entity->getCreatedBy() && $currentUserId == $entity->getCreatedBy()->getUid();
            if (!$isOwner && !$this->permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_ADD)) {
                throw new AccessDeniedException();
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
                if (!$this->modelHelper->canBeCreated($this->objectType)) {
                    $this->request->getSession()->getFlashBag()->add('error', $this->__('Sorry, but you can not create the «name.formatForDisplay» yet as other items are required which must be created before!'));
                    $logArgs = ['app' => '«app.appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $this->objectType];
                    $this->logger->notice('{app}: User {user} tried to create a new {entity}, but failed as it other items are required which must be created before.', $logArgs);

                    return new RedirectResponse($this->getRedirectUrl(['commandName' => '']), 302);
                }
            }
            «locking.setVersion(it)»

            $entityData = $this->entityRef->toArray();

            // assign data to template as array (makes translatable support easier)
            $this->templateParameters[$this->objectTypeLower] = $entityData;

            return $result;
        }
        «IF !incoming.empty || !outgoing.empty»
            «relationPresetsHelper.childMethod(it)»
        «ENDIF»

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
                «IF standardFields»
                    'hasModeratePermission' => $this->permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_MODERATE),
                «ENDIF»
                «IF !incoming.empty || !outgoing.empty»
                    'filterByOwnership' => !$this->permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . '::', ACCESS_ADD)«IF app.needsAutoCompletion»,
                    'inlineUsage' => $this->templateParameters['inlineUsage']«ENDIF»
                «ENDIF»
            ];
            «IF attributable»
                if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {
                    $options['attributes'] = $this->templateParameters['attributes'];
                }
            «ENDIF»
            «IF workflow != EntityWorkflowType.NONE»

                $workflowRoles = $this->prepareWorkflowAdditions(«(workflow == EntityWorkflowType.ENTERPRISE).displayBool»);
                $options = array_merge($options, $workflowRoles);
            «ENDIF»

            return $this->formFactory->create('«app.appNamespace»\Form\Type\«name.formatForCodeCapital»Type', $this->entityRef, $options);
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
            try {
                «locking.applyLock(it)»
                // execute the workflow action
                $success = $this->workflowHelper->executeAction($entity, $action);
            «locking.catchException(it)»
            } catch(\Exception $e) {
                $flashBag->add('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . ' ' . $e->getMessage());
                $logArgs = ['app' => '«app.appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier(), 'errorMessage' => $e->getMessage()];
                $this->logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed. Error details: {errorMessage}.', $logArgs);
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
