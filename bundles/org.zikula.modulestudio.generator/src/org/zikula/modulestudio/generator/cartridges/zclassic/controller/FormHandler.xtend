package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.MappedSuperClass
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.Locking
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.Redirect
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.RelationPresets
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.ArrayFieldTransformer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.AutoCompletionRelationTransformer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.ListFieldTransformer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.TranslationListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.UploadFileTransformer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.ConfigType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.EditEntityType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.ArrayType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.AutoCompletionRelationType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.ColourType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.EntityTreeType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.GeoType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.MultiListType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.TranslationType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.UploadType
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
            for (entity : entities.filter[it instanceof MappedSuperClass || (it as Entity).hasEditAction]) {
                new EditEntityType().generate(entity, fsa)
            }
            if (!entities.filter[e|!e.fields.filter(ArrayField).empty].empty) {
                new ArrayType().generate(it, fsa)
                new ArrayFieldTransformer().generate(it, fsa)
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
            if (hasMultiListFields) {
                new MultiListType().generate(it, fsa)
                new ListFieldTransformer().generate(it, fsa)
            }
            if (hasAutoCompletionRelation) {
                new AutoCompletionRelationType().generate(it, fsa)
                new AutoCompletionRelationTransformer().generate(it, fsa)
            }
            if (hasTranslatable) {
                new TranslationType().generate(it, fsa)
                new TranslationListener().generate(it, fsa)
            }
        }
        // additional form types
        new ConfigType().generate(it, fsa)
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
        use Symfony\Component\Routing\RouterInterface;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
        «IF hasHookSubscribers»
            use Zikula\Bundle\HookBundle\Category\FormAwareCategory;
            use Zikula\Bundle\HookBundle\Category\UiHooksCategory;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\Doctrine\EntityAccess;
        «IF hasHookSubscribers»
            use Zikula\Core\RouteUrl;
        «ENDIF»
        «IF hasTranslatable || needsApproval»
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        «IF needsApproval»
            use Zikula\GroupsModule\Constant as GroupsConstant;
            use Zikula\GroupsModule\Entity\Repository\GroupApplicationRepository;
        «ENDIF»
        use Zikula\PageLockModule\Api\ApiInterface\LockingApiInterface;
        use Zikula\PermissionsModule\Api\ApiInterface\PermissionApiInterface;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        «IF needsApproval»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        use «appNamespace»\Entity\Factory\EntityFactory;
        «IF needsFeatureActivationHelper»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        «IF hasHookSubscribers»
            use «appNamespace»\Helper\HookHelper;
        «ENDIF»
        use «appNamespace»\Helper\ModelHelper;
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
             * Name of primary identifier field.
             *
             * @var string
             */
            protected $idField = null;

            /**
             * Identifier«IF getAllEntities.exists[hasSluggableFields && slugUnique]» or slug«ENDIF» of treated entity.
             *
             * @var integer«IF getAllEntities.exists[hasSluggableFields && slugUnique]»|string«ENDIF»
             */
            protected $idValue = 0;
            «IF getAllEntities.exists[hasSluggableFields && slugUnique]»

                /**
                 * List of object types with unique slugs.
                 */
                protected $entitiesWithUniqueSlugs = ['«getAllEntities.filter[hasSluggableFields && slugUnique].map[name.formatForCode].join('\', \'')»'];
            «ENDIF»

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
            «IF !getJoinRelations.empty»
                «relationPresetsHelper.memberFields(it)»
            «ENDIF»
            «IF !getJoinRelations.empty || needsAutoCompletion»

                /**
                 * Full prefix for related items.
                 *
                 * @var string
                 */
                protected $idPrefix = '';
            «ENDIF»

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
             * @var ZikulaHttpKernelInterface
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
             * @var PermissionApiInterface
             */
            protected $permissionApi;

            «IF hasTranslatable || needsApproval»
                /**
                 * @var VariableApiInterface
                 */
                protected $variableApi;

            «ENDIF»
            /**
             * @var CurrentUserApiInterface
             */
            protected $currentUserApi;

            «IF needsApproval»
                /**
                 * @var GroupApplicationRepository
                 */
                protected $groupApplicationRepository;

            «ENDIF»
            /**
             * @var EntityFactory
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
             * @var LockingApiInterface
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
             * @param ZikulaHttpKernelInterface $kernel           Kernel service instance
             * @param TranslatorInterface       $translator       Translator service instance
             * @param FormFactoryInterface      $formFactory      FormFactory service instance
             * @param RequestStack              $requestStack     RequestStack service instance
             * @param RouterInterface           $router           Router service instance
             * @param LoggerInterface           $logger           Logger service instance
             * @param PermissionApiInterface    $permissionApi    PermissionApi service instance
             «IF hasTranslatable || needsApproval»
             * @param VariableApiInterface      $variableApi      VariableApi service instance
             «ENDIF»
             * @param CurrentUserApiInterface   $currentUserApi   CurrentUserApi service instance
             «IF needsApproval»
             * @param GroupApplicationRepository $groupApplicationRepository GroupApplicationRepository service instance.
             «ENDIF»
             * @param EntityFactory             $entityFactory    EntityFactory service instance
             * @param ControllerHelper          $controllerHelper ControllerHelper service instance
             * @param ModelHelper               $modelHelper      ModelHelper service instance
             * @param WorkflowHelper            $workflowHelper   WorkflowHelper service instance
             «IF hasHookSubscribers»
             * @param HookHelper                $hookHelper       HookHelper service instance
             «ENDIF»
             «IF hasTranslatable»
             * @param TranslatableHelper        $translatableHelper TranslatableHelper service instance
             «ENDIF»
             «IF needsFeatureActivationHelper»
             * @param FeatureActivationHelper   $featureActivationHelper FeatureActivationHelper service instance
             «ENDIF»
             */
            public function __construct(
                ZikulaHttpKernelInterface $kernel,
                TranslatorInterface $translator,
                FormFactoryInterface $formFactory,
                RequestStack $requestStack,
                RouterInterface $router,
                LoggerInterface $logger,
                PermissionApiInterface $permissionApi,
                «IF hasTranslatable || needsApproval»
                    VariableApiInterface $variableApi,
                «ENDIF»
                CurrentUserApiInterface $currentUserApi,
                «IF needsApproval»
                    GroupApplicationRepository $groupApplicationRepository,
                «ENDIF»
                EntityFactory $entityFactory,
                ControllerHelper $controllerHelper,
                ModelHelper $modelHelper,
                WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
                HookHelper $hookHelper«ENDIF»«IF hasTranslatable»,
                TranslatableHelper $translatableHelper«ENDIF»«IF needsFeatureActivationHelper»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
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
             * @param LockingApiInterface $lockingApi
             */
            public function setLockingApi(LockingApiInterface $lockingApi)
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
            «IF !getJoinRelations.empty || app.needsAutoCompletion»

                $this->idPrefix = $this->request->query->get('idp', '');
            «ENDIF»

            // initialise redirect goal
            $this->returnTo = $this->request->query->get('returnTo', null);
            // default to referer
            $refererSessionVar = '«appName.formatForDB»' . $this->objectTypeCapital . 'Referer';
            if (null === $this->returnTo && $this->request->headers->has('referer')) {
                $currentReferer = $this->request->headers->get('referer');
                if ($currentReferer != $this->request->getUri()) {
                    $this->returnTo = $currentReferer;
                    $this->request->getSession()->set($refererSessionVar, $this->returnTo);
                }
            }
            if (null === $this->returnTo && $this->request->getSession()->has($refererSessionVar)) {
                $this->returnTo = $this->request->getSession()->get($refererSessionVar);
            }
            // store current uri for repeated creations
            $this->repeatReturnUrl = $this->request->getSchemeAndHttpHost() . $this->request->getBasePath() . $this->request->getPathInfo();

            $this->permissionComponent = '«appName»:' . $this->objectTypeCapital . ':';

            «IF getAllEntities.exists[hasSluggableFields && slugUnique]»
                $this->idField = in_array($this->objectType, $this->entitiesWithUniqueSlugs) ? 'slug' : $this->entityFactory->getIdField($this->objectType);
            «ELSE»
                $this->idField = $this->entityFactory->getIdField($this->objectType);
            «ENDIF»

            // retrieve identifier of the object we wish to edit
            $routeParams = $this->request->get('_route_params', []);
            «IF getAllEntities.exists[hasSluggableFields && slugUnique]»
                if ($this->idField == 'slug') {
                    if (array_key_exists($this->idField, $routeParams)) {
                        $this->idValue = !empty($routeParams[$this->idField]) ? $routeParams[$this->idField] : '';
                    }
                    if (empty($this->idValue)) {
                        $this->idValue = $this->request->query->get($this->idField, '');
                    }
                }
            «ENDIF»
            if (empty($this->idValue)) {
                «IF getAllEntities.exists[hasSluggableFields && slugUnique]»
                    if ($this->idField == 'slug') {
                        $this->idField = 'id';
                    }

                «ENDIF»
                if (array_key_exists($this->idField, $routeParams)) {
                    $this->idValue = (int) !empty($routeParams[$this->idField]) ? $routeParams[$this->idField] : 0;
                }
                if (0 === $this->idValue) {
                    $this->idValue = $this->request->query->getInt($this->idField, 0);
                }
                if (0 === $this->idValue && $this->idField != 'id') {
                    $this->idValue = $this->request->query->getInt('id', 0);
                }
            }

            $entity = null;
            $this->templateParameters['mode'] = !empty($this->idValue) ? 'edit' : 'create';

            if ($this->templateParameters['mode'] == 'edit') {
                if (!$this->permissionApi->hasPermission($this->permissionComponent, $this->idValue . '::', ACCESS_EDIT)) {
                    throw new AccessDeniedException();
                }

                $entity = $this->initEntityForEditing();
                if (null !== $entity) {
                    «locking.addPageLock(it)»
                }
            } else {
                $permissionLevel = «IF needsApproval»in_array($this->objectType, ['«getAllEntities.filter[workflow != EntityWorkflowType.NONE].map[name.formatForCode].join('\', \'')»']) ? ACCESS_COMMENT : ACCESS_EDIT«ELSE»ACCESS_EDIT«ENDIF»;
                if (!$this->permissionApi->hasPermission($this->permissionComponent, '::', $permissionLevel)) {
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
            «IF !getJoinRelations.empty»
                «relationPresetsHelper.callBaseMethod(it)»
            «ENDIF»

            $actions = $this->workflowHelper->getActionsForObject($entity);
            if (false === $actions || !is_array($actions)) {
                $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! Could not determine workflow actions.'));
                $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $this->objectType, 'id' => $entity->getKey()];
                $this->logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed to determine available workflow actions.', $logArgs);
                throw new \RuntimeException($this->__('Error! Could not determine workflow actions.'));
            }

            $this->templateParameters['actions'] = $actions;

            $this->form = $this->createForm();
            if (!is_object($this->form)) {
                return false;
            }
            «IF hasHookSubscribers»

                if ($entity->supportsHookSubscribers()) {
                    // Call form aware display hooks
                    $formHook = $this->hookHelper->callFormDisplayHooks($this->form, $entity, FormAwareCategory::TYPE_EDIT);
                    $this->templateParameters['formHookTemplates'] = $formHook->getTemplates();
                }
            «ENDIF»

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
        «IF !getJoinRelations.empty»

            «relationPresetsHelper.baseMethod(it)»
        «ENDIF»
        
        «fh.getterMethod(it, 'templateParameters', 'array', true)»

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
                $this->initTranslationsForEditing();
            }
        «ENDIF»
    '''

    def private initEntityForEditing(Application it) '''
        /**
         * Initialise existing entity for editing.
         *
         * @return EntityAccess|null Desired entity instance or null
         */
        protected function initEntityForEditing()
        {
            «IF getAllEntities.exists[hasSluggableFields && slugUnique]»
                if (in_array($this->objectType, $this->entitiesWithUniqueSlugs)) {
                    return $this->entityFactory->getRepository($this->objectType)->selectBySlug($this->idValue);
                }

            «ENDIF»
            return $this->entityFactory->getRepository($this->objectType)->selectById($this->idValue);
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
            $templateId = $this->request->query->getInt('astemplate', '');
            $entity = null;

            if (!empty($templateId)) {
                // reuse existing entity
                $entityT = $this->entityFactory->getRepository($this->objectType)->selectById($templateId);
                if (null === $entityT) {
                    return null;
                }
                $entity = clone $entityT;
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
                $translationsEnabled = $this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType);
                $this->templateParameters['translationsEnabled'] = $translationsEnabled;

                $supportedLanguages = $this->translatableHelper->getSupportedLanguages($this->objectType);
                // assign list of installed languages for translatable extension
                $this->templateParameters['supportedLanguages'] = $supportedLanguages;

                if (!$translationsEnabled) {
                    return;
                }

                if ($this->variableApi->getSystemVar('multilingual') != 1) {
                    $this->templateParameters['translationsEnabled'] = false;

                    return;
                }
                if (count($supportedLanguages) < 2) {
                    $this->templateParameters['translationsEnabled'] = false;

                    return;
                }

                $mandatoryFieldsPerLocale = $this->translatableHelper->getMandatoryFields($this->objectType);
                $localesWithMandatoryFields = [];
                foreach ($mandatoryFieldsPerLocale as $locale => $fields) {
                    if (count($fields) > 0) {
                        $localesWithMandatoryFields[] = $locale;
                    }
                }
                if (!in_array($this->translatableHelper->getCurrentLanguage(), $localesWithMandatoryFields)) {
                    $localesWithMandatoryFields[] = $this->translatableHelper->getCurrentLanguage();
                }
                $this->templateParameters['localesWithMandatoryFields'] = $localesWithMandatoryFields;

                // retrieve and assign translated fields
                $translations = $this->translatableHelper->prepareEntityForEditing($this->entityRef);
                foreach ($translations as $language => $translationData) {
                    $this->templateParameters[$this->objectTypeLower . $language] = $translationData;
                }
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

                $this->templateParameters['attributes'] = $attributes;
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
        public function handleCommand(array $args = [])
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
                $this->fetchInputData(«IF hasSluggable && !getAllEntities.filter[slugUpdatable].empty»$args«ENDIF»);
            }
            «IF hasHookSubscribers»

                // get treated entity reference from persisted member var
                $entity = $this->entityRef;

                if ($entity->supportsHookSubscribers() && $action != 'cancel') {
                    // Let any ui hooks perform additional validation actions
                    $hookType = $action == 'delete' ? UiHooksCategory::TYPE_VALIDATE_DELETE : UiHooksCategory::TYPE_VALIDATE_EDIT;
                    $validationErrors = $this->hookHelper->callValidationHooks($entity, $hookType);
                    if (count($validationErrors) > 0) {
                        $flashBag = $this->request->getSession()->getFlashBag();
                        foreach ($validationErrors as $message) {
                            $flashBag->add('error', $message);
                        }

                        return false;
                    }
                }
            «ENDIF»

            if ($isRegularAction || $action == 'delete') {
                $success = $this->applyAction($args);
                if (!$success) {
                    // the workflow operation failed
                    return false;
                }
                «IF hasTranslatable»

                    if ($isRegularAction && true === $this->hasTranslatableFields) {
                        if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType)) {
                            $this->processTranslationsForUpdate();
                        }
                    }
                «ENDIF»
                «IF hasHookSubscribers»

                    if ($entity->supportsHookSubscribers()) {
                        $routeUrl = null;
                        if ($action != 'delete') {
                            $urlArgs = $entity->createUrlArgs();
                            $urlArgs['_locale'] = $this->request->getLocale();
                            $routeUrl = new RouteUrl('«appName.formatForDB»_' . $this->objectTypeLower . '_display', $urlArgs);
                        }

                        // Call form aware processing hooks
                        $hookType = $action == 'delete' ? FormAwareCategory::TYPE_PROCESS_DELETE : FormAwareCategory::TYPE_PROCESS_EDIT;
                        $this->hookHelper->callFormProcessHooks($this->form, $entity, $hookType, $routeUrl);

                        // Let any ui hooks know that we have created, updated or deleted an item
                        $hookType = $action == 'delete' ? UiHooksCategory::TYPE_PROCESS_DELETE : UiHooksCategory::TYPE_PROCESS_EDIT;
                        $this->hookHelper->callProcessHooks($entity, $hookType, $routeUrl);
                    }
                «ENDIF»
            }

            «locking.releasePageLock(it)»

            return new RedirectResponse($this->getRedirectUrl($args), 302);
        }
        «IF hasAttributableEntities»

            /**
             * Prepare update of attributes.
             */
            protected function processAttributesForUpdate()
            {
                $entity = $this->entityRef;
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
                if (!$this->templateParameters['translationsEnabled']) {
                    return;
                }

                // persist translated fields
                $this->translatableHelper->processEntityAfterEditing($this->entityRef, $this->form, $this->entityFactory->getObjectManager());
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
        protected function getDefaultMessage(array $args = [], $success = false)
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
        protected function addDefaultMessage(array $args = [], $success = false)
        {
            $message = $this->getDefaultMessage($args, $success);
            if (empty($message)) {
                return;
            }

            $flashType = true === $success ? 'status' : 'error';
            $this->request->getSession()->getFlashBag()->add($flashType, $message);
            $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $this->objectType, 'id' => $this->entityRef->getKey()];
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
         «IF hasSluggable && !getAllEntities.filter[slugUpdatable].empty»
         *
         * @param array $args Additional arguments
         «ENDIF»
         */
        public function fetchInputData(«IF hasSluggable && !getAllEntities.filter[slugUpdatable].empty»array $args = []«ENDIF»)
        {
            // fetch posted data input values as an associative array
            $formData = $this->form->getData();
            «IF hasSluggable && !getAllEntities.filter[slugUpdatable].empty»

                if ($args['commandName'] != 'cancel') {
                    if (true === $this->hasSlugUpdatableField && isset($entityData['slug'])) {
                        $entityData['slug'] = iconv('UTF-8', 'ASCII//TRANSLIT', $entityData['slug']);
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
                        $this->processAttributesForUpdate();
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
            $currentUserId = $this->currentUserApi->isLoggedIn() ? $this->currentUserApi->get('uid') : UsersConstant::USER_ID_ANONYMOUS;
            $roles['is_creator'] = $this->templateParameters['mode'] == 'create'
                || (method_exists($this->entityRef, 'getCreatedBy') && $this->entityRef->getCreatedBy()->getUid() == $currentUserId);

            $groupApplicationArgs = [
                'user' => $currentUserId,
                'group' => $this->variableApi->get('«appName»', 'moderationGroupFor' . $this->objectTypeCapital, GroupsConstant::GROUP_ID_ADMIN)
            ];
            $roles['is_moderator'] = count($this->groupApplicationRepository->findBy($groupApplicationArgs)) > 0;

            if (true === $enterprise) {
                $groupApplicationArgs = [
                    'user' => $currentUserId,
                    'group' => $this->variableApi->get('«appName»', 'superModerationGroupFor' . $this->objectTypeCapital, GroupsConstant::GROUP_ID_ADMIN)
                ];
                $roles['is_super_moderator'] = count($this->groupApplicationRepository->findBy($groupApplicationArgs)) > 0;
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
        use «app.appNamespace»\Form\Type\«name.formatForCodeCapital»Type;

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
            if (!$isOwner && !$this->permissionApi->hasPermission($this->permissionComponent, $this->idValue . '::', ACCESS_ADD)) {
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
         * This handler class handles the page events of editing forms.
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
            if ($result instanceof RedirectResponse) {
                return $result;
            }

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

            // assign data to template as array (for additions like standard fields)
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
                    'has_moderate_permission' => $this->permissionApi->hasPermission($this->permissionComponent, $this->idValue . '::', ACCESS_MODERATE),
                «ENDIF»
                «IF !incoming.empty || !outgoing.empty»
                    'filter_by_ownership' => !$this->permissionApi->hasPermission($this->permissionComponent, $this->idValue . '::', ACCESS_ADD)«IF app.needsAutoCompletion»,«ENDIF»
                «ENDIF»
                «IF app.needsAutoCompletion»
                    'inline_usage' => $this->templateParameters['inlineUsage']
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
            «IF hasTranslatableFields»

                $options['translations'] = [];
                foreach ($this->templateParameters['supportedLanguages'] as $language) {
                    $options['translations'][$language] = isset($this->templateParameters[$this->objectTypeLower . $language]) ? $this->templateParameters[$this->objectTypeLower . $language] : [];
                }
            «ENDIF»

            return $this->formFactory->create(«name.formatForCodeCapital»Type::class, $this->entityRef, $options);
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
        public function handleCommand(array $args = [])
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
        protected function getDefaultMessage(array $args = [], $success = false)
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
            } catch (\Exception $exception) {
                $flashBag->add('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . ' ' . $exception->getMessage());
                $logArgs = ['app' => '«app.appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->getKey(), 'errorMessage' => $exception->getMessage()];
                $this->logger->error('{app}: User {user} tried to edit the {entity} with id {id}, but failed. Error details: {errorMessage}.', $logArgs);
            }

            $this->addDefaultMessage($args, $success);

            if ($success && $this->templateParameters['mode'] == 'create') {
                // store new identifier
                $this->idValue = $entity->getKey();
            }
            «IF !incoming.empty || !outgoing.empty»
                «relationPresetsHelper.saveNonEditablePresets(it, app)»
            «ENDIF»

            return $success;
        }
    '''
}
