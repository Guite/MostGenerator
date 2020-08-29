package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.TelType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.TranslationType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.UploadType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.trait.ModerationFormFieldsTrait
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.trait.WorkflowFormFieldsTrait
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

    FileHelper fh
    Redirect redirectHelper = new Redirect
    RelationPresets relationPresetsHelper = new RelationPresets
    Locking locking = new Locking

    Application app

    /**
     * Entry point for Form handler classes.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        app = it
        fh = new FileHelper(app)

        // common form types (shared by entities and variables)
        if (!entities.filter[e|!e.fields.filter(ArrayField).empty].empty || !getAllVariables.filter(ArrayField).empty) {
            new ArrayType().generate(it, fsa)
            new ArrayFieldTransformer().generate(it, fsa)
        }
        if (hasColourFields && !targets('2.0')) {
            new ColourType().generate(it, fsa)
        }
        if (hasTelephoneFields && !targets('2.0')) {
            new TelType().generate(it, fsa)
        }
        if (hasUploads) {
            new UploadType().generate(it, fsa)
            new UploadFileTransformer().generate(it, fsa)
        }
        if (hasMultiListFields || !getAllVariables.filter(ListField).filter[multiple].empty) {
            new MultiListType().generate(it, fsa)
            new ListFieldTransformer().generate(it, fsa)
        }

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
            if (hasStandardFieldEntities) {
                new ModerationFormFieldsTrait().generate(it, fsa)
            }
            if (needsApproval) {
                new WorkflowFormFieldsTrait().generate(it, fsa)
            }
            if (hasGeographical) {
                new GeoType().generate(it, fsa)
            }
            if (hasTrees) {
                new EntityTreeType().generate(it, fsa)
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
    def private generateCommon(Application it, String actionName, IMostFileSystemAccess fsa) {
        ('Generating "' + name + '" form handler base class').printIfNotTesting(fsa)
        val formHandlerFolder = 'Form/Handler/Common/'
        fsa.generateClassPair(formHandlerFolder + actionName.formatForCodeCapital + 'Handler.php',
            formHandlerCommonBaseImpl(actionName), formHandlerCommonImpl(actionName)
        )
    }

    /**
     * Entry point for Form handler classes per entity.
     */
    def private generate(Entity it, String actionName, IMostFileSystemAccess fsa) {
        ('Generating form handler classes for "' + name + '_' + actionName + '"').printIfNotTesting(fsa)
        val formHandlerFolder = 'Form/Handler/' + name.formatForCodeCapital + '/'
        fsa.generateClassPair(formHandlerFolder + actionName.formatForCodeCapital + 'Handler.php',
            formHandlerBaseImpl(actionName), formHandlerImpl(actionName)
        )
    }

    def private formHandlerCommonBaseImpl(Application it, String actionName) '''
        namespace «appNamespace»\Form\Handler\Common\Base;

        use Psr\Log\LoggerInterface;
        use RuntimeException;
        use Symfony\Component\Form\Form;
        use Symfony\Component\Form\FormFactoryInterface;
        «IF targets('3.0')»
            use Symfony\Component\Form\FormInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RedirectResponse;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF !getAllEntities.filter[hasDisplayAction && hasEditAction && hasSluggableFields].empty»
            use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
        «ENDIF»
        use Symfony\Component\Routing\RouterInterface;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
        «ENDIF»
        use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
        «IF targets('3.0')»
            «IF hasHookSubscribers»
                use Zikula\Bundle\CoreBundle\RouteUrl;
            «ENDIF»
            use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        «ENDIF»
        «IF hasHookSubscribers»
            use Zikula\Bundle\HookBundle\Category\FormAwareCategory;
            use Zikula\Bundle\HookBundle\Category\UiHooksCategory;
        «ENDIF»
        «IF !targets('3.0')»
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Common\Translator\TranslatorTrait;
            use Zikula\Core\Doctrine\EntityAccess;
            «IF hasHookSubscribers»
                use Zikula\Core\RouteUrl;
            «ENDIF»
        «ENDIF»
        «IF hasTranslatable || needsApproval || hasStandardFieldEntities»
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        «IF needsApproval»
            use Zikula\GroupsModule\Constant as GroupsConstant;
            use Zikula\GroupsModule\Entity\Repository\GroupApplicationRepository;
        «ENDIF»
        use Zikula\PageLockModule\Api\ApiInterface\LockingApiInterface;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        «IF needsApproval»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        «IF hasNonNullableUserFields»
            use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
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
        use «appNamespace»\Helper\PermissionHelper;
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
             * Reference to treated entity instance.
             *
             * @var EntityAccess
             */
            protected $entityRef;

            /**
             * Name of primary identifier field.
             *
             * @var string
             */
            protected $idField;

            /**
             * Identifier of treated entity.
             *
             * @var int
             */
            protected $idValue = 0;

            /**
             * Code defining the redirect goal after command handling.
             *
             * @var string
             */
            protected $returnTo;

            /**
             * Whether a create action is going to be repeated or not.
             *
             * @var bool
             */
            protected $repeatCreateAction = false;

            /**
             * Url of current form with all parameters for multiple creations.
             *
             * @var string
             */
            protected $repeatReturnUrl;
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
                 * @var bool
                 */
                protected $hasAttributes = false;
            «ENDIF»
            «IF hasTranslatable»

                /**
                 * Whether the entity has translatable fields or not.
                 *
                 * @var bool
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
             * @var RequestStack
             */
            protected $requestStack;

            /**
             * @var RouterInterface
             */
            protected $router;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            «IF hasTranslatable || needsApproval || hasStandardFieldEntities»
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
            «IF hasNonNullableUserFields»
                /**
                 * @var UserRepositoryInterface
                 */
                protected $userRepository;

            «ENDIF»
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * @var ModelHelper
             */
            protected $modelHelper;

            /**
             * @var PermissionHelper
             */
            protected $permissionHelper;

            /**
             * @var WorkflowHelper
             */
            protected $workflowHelper;
            «IF hasHookSubscribers»

                /**
                 * @var HookHelper
                 */
                protected $hookHelper;
            «ENDIF»
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
            protected $lockingApi;

            /**
             * The handled form type.
             *
             * @var Form
             */
            protected $form;

            /**
             * Template parameters.
             *
             * @var array
             */
            protected $templateParameters = [];

            public function __construct(
                ZikulaHttpKernelInterface $kernel,
                TranslatorInterface $translator,
                FormFactoryInterface $formFactory,
                RequestStack $requestStack,
                RouterInterface $router,
                LoggerInterface $logger,
                «IF hasTranslatable || needsApproval || hasStandardFieldEntities»
                    VariableApiInterface $variableApi,
                «ENDIF»
                CurrentUserApiInterface $currentUserApi,
                «IF needsApproval»
                    GroupApplicationRepository $groupApplicationRepository,
                «ENDIF»
                «IF hasNonNullableUserFields»
                    UserRepositoryInterface $userRepository,
                «ENDIF»
                EntityFactory $entityFactory,
                ControllerHelper $controllerHelper,
                ModelHelper $modelHelper,
                PermissionHelper $permissionHelper,
                WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
                HookHelper $hookHelper«ENDIF»«IF hasTranslatable»,
                TranslatableHelper $translatableHelper«ENDIF»«IF needsFeatureActivationHelper»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
                $this->kernel = $kernel;
                $this->setTranslator($translator);
                $this->formFactory = $formFactory;
                $this->requestStack = $requestStack;
                $this->router = $router;
                $this->logger = $logger;
                «IF hasTranslatable || needsApproval || hasStandardFieldEntities»
                    $this->variableApi = $variableApi;
                «ENDIF»
                $this->currentUserApi = $currentUserApi;
                «IF needsApproval»
                    $this->groupApplicationRepository = $groupApplicationRepository;
                «ENDIF»
                «IF hasNonNullableUserFields»
                    $this->userRepository = $userRepository;
                «ENDIF»
                $this->entityFactory = $entityFactory;
                $this->controllerHelper = $controllerHelper;
                $this->modelHelper = $modelHelper;
                $this->permissionHelper = $permissionHelper;
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
            «IF !targets('3.0')»

                «setTranslatorMethod»
            «ENDIF»

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
             «IF !targets('3.0')»
             *
             * @param LockingApiInterface $lockingApi
             «ENDIF»
             */
            public function setLockingApi(LockingApiInterface $lockingApi)«IF targets('3.0')»: void«ENDIF»
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
         «IF !targets('3.0')»
         *
         * @param array $templateParameters List of preassigned template variables
         «ENDIF»
         *
         * @return bool|RedirectResponse Redirect or false on errors
         *
         * @throws AccessDeniedException Thrown if user has not the required permissions
         * @throws RuntimeException Thrown if the workflow actions can not be determined
         */
        public function processForm(array $templateParameters = [])
        {
            $request = $this->requestStack->getCurrentRequest();
            $this->templateParameters = $templateParameters;
            «IF !getJoinRelations.empty»
                $this->templateParameters['inlineUsage'] = $request->query->getBoolean('raw');
            «ENDIF»
            «IF !getJoinRelations.empty || app.needsAutoCompletion»
                $this->idPrefix = $request->query->get('idp', '');
            «ENDIF»
            $session = $request->hasSession() ? $request->getSession() : null;

            // initialise redirect goal
            $this->returnTo = $request->query->get('returnTo');
            if (null !== $session) {
                // default to referer
                $refererSessionVar = '«appName.formatForDB»' . $this->objectTypeCapital . 'Referer';
                if (null === $this->returnTo && $request->headers->has('referer')) {
                    $currentReferer = $request->headers->get('referer');
                    if ($currentReferer !== urldecode($request->getUri())) {
                        $this->returnTo = $currentReferer;
                        $session->set($refererSessionVar, $this->returnTo);
                    }
                }
                if (null === $this->returnTo && $session->has($refererSessionVar)) {
                    $this->returnTo = $session->get($refererSessionVar);
                }
            }
            // store current uri for repeated creations
            $this->repeatReturnUrl = $request->getUri();

            $this->idField = $this->entityFactory->getIdField($this->objectType);

            // retrieve identifier of the object we wish to edit
            $routeParams = $request->get('_route_params', []);
            if (array_key_exists($this->idField, $routeParams)) {
                $this->idValue = (int) !empty($routeParams[$this->idField]) ? $routeParams[$this->idField] : 0;
            }
            if (0 === $this->idValue) {
                $this->idValue = $request->query->getInt($this->idField);
            }
            if (0 === $this->idValue && 'id' !== $this->idField) {
                $this->idValue = $request->query->getInt('id');
            }

            $entity = null;
            $this->templateParameters['mode'] = !empty($this->idValue) ? 'edit' : 'create';

            if ('edit' === $this->templateParameters['mode']) {
                $entity = $this->initEntityForEditing();
                if (null !== $entity) {
                    «locking.addPageLock(it)»
                    if (!$this->permissionHelper->mayEdit($entity)) {
                        throw new AccessDeniedException();
                    }
                    «IF !getAllEntities.filter[hasDisplayAction && hasEditAction && hasSluggableFields].empty»
                        if (null !== $session && in_array($this->objectType, ['«getAllEntities.filter[hasDisplayAction && hasEditAction && hasSluggableFields].map[name.formatForCode].join('\', \'')»'], true)) {
                            // map display return urls to redirect codes because slugs may change
                            $routePrefix = '«app.appName.formatForDB»_' . $this->objectTypeLower . '_';
                            $userDisplayUrl = $this->router->generate(
                                $routePrefix . 'display',
                                $entity->createUrlArgs(),
                                UrlGeneratorInterface::ABSOLUTE_URL
                            );
                            $adminDisplayUrl = $this->router->generate(
                                $routePrefix . 'admindisplay',
                                $entity->createUrlArgs(),
                                UrlGeneratorInterface::ABSOLUTE_URL
                            );
                            if ($this->returnTo === $userDisplayUrl) {
                                $this->returnTo = 'userDisplay';
                            } elseif ($this->returnTo === $adminDisplayUrl) {
                                $this->returnTo = 'adminDisplay';
                            }
                            $session->set($refererSessionVar, $this->returnTo);
                        }
                    «ENDIF»
                }
            } else {
                «IF needsApproval»
                    $objectTypesNeedingApproval = ['«getAllEntities.filter[workflow != EntityWorkflowType.NONE].map[name.formatForCode].join('\', \'')»'];
                    $permissionLevel = in_array($this->objectType, $objectTypesNeedingApproval, true) ? ACCESS_COMMENT : ACCESS_EDIT;
                «ELSE»
                    $permissionLevel = ACCESS_EDIT;
                «ENDIF»
                if (!$this->permissionHelper->hasComponentPermission($this->objectType, $permissionLevel)) {
                    throw new AccessDeniedException();
                }

                $entity = $this->initEntityForCreation();

                // set default values from request parameters
                foreach ($request->query->all() as $key => $value) {
                    if (5 > mb_strlen($key) || 0 !== mb_strpos($key, 'set_')) {
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
                if (null !== $session) {
                    $session->getFlashBag()->add('error', «IF !targets('3.0')»$this->__(«ENDIF»'No such item found.'«IF !targets('3.0')»)«ENDIF»);
                }

                return new RedirectResponse($this->getRedirectUrl(['commandName' => 'cancel']), 302);
            }

            «IF !getAllEntities.filter[hasEditAction && hasSluggableFields && slugUnique && needsSlugHandler].empty»
                if (null !== $entity->getSlug() && in_array($this->objectType, ['«getAllEntities.filter[hasEditAction && hasSluggableFields && slugUnique && needsSlugHandler].map[name.formatForCode].join('\', \'')»'], true)) {
                    $slugParts = explode('/', $entity->getSlug());
                    $entity->setSlug(end($slugParts));
                }
            «ENDIF»
            // save entity reference for later reuse
            $this->entityRef = $entity;
            «initialiseExtensions»
            «IF !getJoinRelations.empty»

                «relationPresetsHelper.callBaseMethod(it)»
            «ENDIF»

            $actions = $this->workflowHelper->getActionsForObject($entity);
            if (false === $actions || !is_array($actions)) {
                if (null !== $session) {
                    $session->getFlashBag()->add(
                        'error',
                        «IF !targets('3.0')»$this->__(«ENDIF»'Error! Could not determine workflow actions.'«IF !targets('3.0')»)«ENDIF»
                    );
                }
                $logArgs = [
                    'app' => '«appName»',
                    'user' => $this->currentUserApi->get('uname'),
                    'entity' => $this->objectType,
                    'id' => $entity->getKey(),
                ];
                $this->logger->error(
                    '{app}: User {user} tried to edit the {entity} with id {id},'
                        . ' but failed to determine available workflow actions.',
                    $logArgs
                );
                throw new RuntimeException($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Could not determine workflow actions.'));
            }

            $this->templateParameters['actions'] = $actions;

            $this->form = $this->createForm();
            if (!is_object($this->form)) {
                return false;
            }
            «IF hasHookSubscribers»

                if (method_exists($entity, 'supportsHookSubscribers') && $entity->supportsHookSubscribers()) {
                    // call form aware display hooks
                    $formHook = $this->hookHelper->callFormDisplayHooks($this->form, $entity, FormAwareCategory::TYPE_EDIT);
                    $this->templateParameters['formHookTemplates'] = $formHook->getTemplates();
                }
            «ENDIF»

            // handle form request and check validity constraints of edited entity
            $this->form->handleRequest($request);
            if ($this->form->isSubmitted()) {
                if ($this->form->has('cancel') && $this->form->get('cancel')->isClicked()) {
                    «locking.releasePageLock(it)»

                    return new RedirectResponse($this->getRedirectUrl(['commandName' => 'cancel']), 302);
                }
                if ($this->form->isValid()) {
                    $result = $this->handleCommand();
                    if (false === $result) {
                        $this->templateParameters['form'] = $this->form->createView();
                    }

                    return $result;
                }
            }

            $this->templateParameters['form'] = $this->form->createView();

            // everything okay, no initialisation errors occured
            return true;
        }

        /**
         * Creates the form type.
         */
        protected function createForm()«IF targets('3.0')»: ?FormInterface«ENDIF»
        {
            // to be customised in sub classes
            return null;
        }

        /**
         * Returns the form options.
         «IF !targets('3.0')»
         *
         * @return array
         «ENDIF»
         */
        protected function getFormOptions()«IF targets('3.0')»: array«ENDIF»
        {
            // to be customised in sub classes
            return [];
        }
        «IF !getJoinRelations.empty»
            «relationPresetsHelper.baseMethod(it)»
        «ENDIF»
        «fh.getterMethod(it, 'templateParameters', 'array', true, false, targets('3.0'))»

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
         «IF !targets('3.0')»
         *
         * @return EntityAccess|null Desired entity instance or null
         «ENDIF»
         */
        protected function initEntityForEditing()«IF targets('3.0')»: ?EntityAccess«ENDIF»
        {
            return $this->entityFactory->getRepository($this->objectType)->selectById($this->idValue);
        }
    '''

    def private initEntityForCreation(Application it) '''
        /**
         * Initialise new entity for creation.
         «IF !targets('3.0')»
         *
         * @return EntityAccess|null Desired entity instance or null
         «ENDIF»
         */
        protected function initEntityForCreation()«IF targets('3.0')»: ?EntityAccess«ENDIF»
        {
            $request = $this->requestStack->getCurrentRequest();
            $templateId = $request->query->getInt('astemplate');
            $entity = null;

            if (0 < $templateId) {
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
                «IF hasTrees»
                    if (in_array($this->objectType, ['«getTreeEntities.map[name.formatForCode].join('\', \'')»'], true)) {
                        $parentId = $request->query->getInt('parent');
                        if (0 < $parentId) {
                            $parentEntity = $this->entityFactory->getRepository($this->objectType)->selectById($parentId);
                            if (null !== $parentEntity) {
                                $entity->setParent($parentEntity);
                            }
                        }
                    }
                «ENDIF»
            }

            return $entity;
        }
    '''

    def private initTranslationsForEditing(Application it) '''
        «IF hasTranslatable»

            /**
             * Initialise translations.
             */
            protected function initTranslationsForEditing()«IF targets('3.0')»: void«ENDIF»
            {
                $translationsEnabled = $this->featureActivationHelper->isEnabled(
                    FeatureActivationHelper::TRANSLATIONS,
                    $this->objectType
                );
                $this->templateParameters['translationsEnabled'] = $translationsEnabled;

                $supportedLanguages = $this->translatableHelper->getSupportedLanguages($this->objectType);
                // assign list of installed languages for translatable extension
                $this->templateParameters['supportedLanguages'] = $supportedLanguages;

                if (!$translationsEnabled) {
                    return;
                }

                if (!$this->variableApi->getSystemVar('multilingual')) {
                    $this->templateParameters['translationsEnabled'] = false;

                    return;
                }
                if (2 > count($supportedLanguages)) {
                    $this->templateParameters['translationsEnabled'] = false;

                    return;
                }

                $mandatoryFieldsPerLocale = $this->translatableHelper->getMandatoryFields($this->objectType);
                $localesWithMandatoryFields = [];
                foreach ($mandatoryFieldsPerLocale as $locale => $fields) {
                    if (0 < count($fields)) {
                        $localesWithMandatoryFields[] = $locale;
                    }
                }
                if (!in_array($this->translatableHelper->getCurrentLanguage(), $localesWithMandatoryFields, true)) {
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
            protected function initAttributesForEditing()«IF targets('3.0')»: void«ENDIF»
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
             * @return string[] List of attribute names
             */
            protected function getAttributeFieldNames()«IF targets('3.0')»: array«ENDIF»
            {
                return [
                    'field1', 'field2', 'field3',
                ];
            }
        «ENDIF»
    '''

    def private dispatch handleCommand(Application it) '''
        /**
         * Command event handler.
         * This event handler is called when a command is issued by the user.
         «IF !targets('3.0')»
         *
         * @param array $args List of arguments
         «ENDIF»
         *
         * @return bool|RedirectResponse Redirect or false on errors
         */
        public function handleCommand(array $args = [])
        {
            // build $args for BC (e.g. used by redirect handling)
            foreach ($this->templateParameters['actions'] as $action) {
                if ($this->form->get($action['id'])->isClicked()) {
                    $args['commandName'] = $action['id'];
                }
            }
            if (
                'create' === $this->templateParameters['mode']
                && $this->form->has('submitrepeat')
                && $this->form->get('submitrepeat')->isClicked()
            ) {
                $args['commandName'] = 'submit';
                $this->repeatCreateAction = true;
            }
            «IF hasTranslatable || hasHookSubscribers»

                $action = $args['commandName'];
                «IF hasTranslatable»
                    $isRegularAction = 'delete' !== $action;
                «ENDIF»
            «ENDIF»

            $this->fetchInputData();
            «IF !getTranslatableEntities.filter[loggable].empty»

                if ($isRegularAction && true === $this->hasTranslatableFields) {
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType)) {
                        if (in_array($this->objectType, ['«getTranslatableEntities.filter[loggable].map[name.formatForCode].join('\', \'')»'], true)) {
                            // collect translated fields for revisioning
                            $translationData = [];

                            // main language
                            $language = $this->translatableHelper->getCurrentLanguage();
                            $translationData[$language] = [];
                            $translatableFields = $this->translatableHelper->getTranslatableFields($this->objectType);
                            foreach ($translatableFields as $fieldName) {
                                $fieldData = isset($this->form[$fieldName]) ? $this->form[$fieldName]->getData() : '';
                                $translationData[$language][$fieldName] = $fieldData;
                            }

                            // other languages
                            $supportedLanguages = $this->translatableHelper->getSupportedLanguages($this->objectType);
                            foreach ($supportedLanguages as $language) {
                                $translationInput = $this->translatableHelper->readTranslationInput($this->form, $language);
                                if (!count($translationInput)) {
                                    continue;
                                }
                                $translationData[$language] = $translationInput;
                            }

                            $this->entityRef->setTranslationData($translationData);
                        }
                    }
                }
            «ENDIF»
            «IF hasHookSubscribers»

                // get treated entity reference from persisted member var
                $entity = $this->entityRef;

                if (method_exists($entity, 'supportsHookSubscribers') && $entity->supportsHookSubscribers()) {
                    // let any ui hooks perform additional validation actions
                    $hookType = 'delete' === $action
                        ? UiHooksCategory::TYPE_VALIDATE_DELETE
                        : UiHooksCategory::TYPE_VALIDATE_EDIT
                    ;
                    $validationErrors = $this->hookHelper->callValidationHooks($entity, $hookType);
                    if (0 < count($validationErrors)) {
                        $request = $this->requestStack->getCurrentRequest();
                        if ($request->hasSession() && ($session = $request->getSession())) {
                            foreach ($validationErrors as $message) {
                                $session->getFlashBag()->add('error', $message);
                            }
                        }

                        return false;
                    }
                }
            «ENDIF»

            $success = $this->applyAction($args);
            if (!$success) {
                // the workflow operation failed
                return false;
            }
            «IF hasTranslatable»

                if (
                    true === $isRegularAction
                    && true === $this->hasTranslatableFields
                    && $this->featureActivationHelper->isEnabled(
                        FeatureActivationHelper::TRANSLATIONS,
                        $this->objectType
                    )
                ) {
                    $this->processTranslationsForUpdate();
                }
            «ENDIF»
            «IF hasHookSubscribers»

                if (method_exists($entity, 'supportsHookSubscribers') && $entity->supportsHookSubscribers()) {
                    $entitiesWithDisplayAction = ['«getAllEntities.filter[hasDisplayAction].map[name.formatForCode].join('\', \'')»'];
                    $hasDisplayAction = in_array($this->objectType, $entitiesWithDisplayAction, true);

                    $routeUrl = null;
                    if ($hasDisplayAction && 'delete' !== $action) {
                        $urlArgs = $entity->createUrlArgs();
                        $urlArgs['_locale'] = $this->requestStack->getCurrentRequest()->getLocale();
                        $routeUrl = new RouteUrl('«appName.formatForDB»_' . $this->objectTypeLower . '_display', $urlArgs);
                    }

                    // call form aware processing hooks
                    $hookType = 'delete' === $action
                        ? FormAwareCategory::TYPE_PROCESS_DELETE
                        : FormAwareCategory::TYPE_PROCESS_EDIT
                    ;
                    $this->hookHelper->callFormProcessHooks($this->form, $entity, $hookType, $routeUrl);

                    // let any ui hooks know that we have created, updated or deleted an item
                    $hookType = 'delete' === $action
                        ? UiHooksCategory::TYPE_PROCESS_DELETE
                        : UiHooksCategory::TYPE_PROCESS_EDIT
                    ;
                    $this->hookHelper->callProcessHooks($entity, $hookType, $routeUrl);
                }
            «ENDIF»

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
                }«/*
                $entity->setAttribute('url', 'http://www.example.com');
                $entity->setAttribute('url', null); // remove
                */»
            }
        «ENDIF»
        «IF hasTranslatable»

            /**
             * Prepare update of translations.
             */
            protected function processTranslationsForUpdate()«IF targets('3.0')»: void«ENDIF»
            {
                if (!$this->templateParameters['translationsEnabled']) {
                    return;
                }

                // persist translated fields
                $this->translatableHelper->processEntityAfterEditing($this->entityRef, $this->form);
            }
        «ENDIF»

        /**
         * Get success or error message for default operations.
         «IF !targets('3.0')»
         *
         * @param array $args List of arguments from handleCommand method
         * @param bool $success Becomes true if this is a success, false for default error
         *
         * @return string desired status or error message
         «ENDIF»
         */
        protected function getDefaultMessage(array $args = [], «IF targets('3.0')»bool «ENDIF»$success = false)«IF targets('3.0')»: string«ENDIF»
        {
            $message = '';
            switch ($args['commandName']) {
                case 'create':
                    if (true === $success) {
                        $message = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Done! Item created.');
                    } else {
                        $message = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Creation attempt failed.');
                    }
                    break;
                case 'update':
                    if (true === $success) {
                        $message = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Done! Item updated.');
                    } else {
                        $message = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Update attempt failed.');
                    }
                    break;
                case 'delete':
                    if (true === $success) {
                        $message = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Done! Item deleted.');
                    } else {
                        $message = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Deletion attempt failed.');
                    }
                    break;
            }

            return $message;
        }

        /**
         * Add success or error message to session.
         «IF !targets('3.0')»
         *
         * @param array $args List of arguments from handleCommand method
         * @param bool $success Becomes true if this is a success, false for default error
         «ENDIF»
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         */
        protected function addDefaultMessage(array $args = [], «IF targets('3.0')»bool «ENDIF»$success = false)«IF targets('3.0')»: void«ENDIF»
        {
            $message = $this->getDefaultMessage($args, $success);
            if (empty($message)) {
                return;
            }

            $flashType = true === $success ? 'status' : 'error';
            $request = $this->requestStack->getCurrentRequest();
            if ($request->hasSession() && ($session = $request->getSession())) {
                $session->getFlashBag()->add($flashType, $message);
            }
            $logArgs = [
                'app' => '«appName»',
                'user' => $this->currentUserApi->get('uname'),
                'entity' => $this->objectType,
                'id' => $this->entityRef->getKey(),
            ];
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
         * @return mixed
         */
        public function fetchInputData()
        {
            // fetch posted data input values as an associative array
            $formData = $this->form->getData();
            «IF hasStandardFieldEntities»

                if (method_exists($this->entityRef, 'getCreatedBy')) {
                    if (
                        isset($this->form['moderationSpecificCreator'])
                        && null !== $this->form['moderationSpecificCreator']->getData()
                    ) {
                        $this->entityRef->setCreatedBy($this->form['moderationSpecificCreator']->getData());
                    }
                    if (
                        isset($this->form['moderationSpecificCreationDate'])
                        && null !== $this->form['moderationSpecificCreationDate']->getData()
                        && '' !== $this->form['moderationSpecificCreationDate']->getData()
                    ) {
                        $this->entityRef->setCreatedDate($this->form['moderationSpecificCreationDate']->getData());
                    }
                }
            «ENDIF»
            «IF needsApproval»

                if (
                    isset($this->form['additionalNotificationRemarks'])
                    && '' !== $this->form['additionalNotificationRemarks']->getData()
                ) {
                    $request = $this->requestStack->getCurrentRequest();
                    if ($request->hasSession() && ($session = $request->getSession())) {
                        $session->set(
                            '«appName»AdditionalNotificationRemarks',
                            $this->form['additionalNotificationRemarks']->getData()
                        );
                    }
                }
            «ENDIF»
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
         * Executes a certain workflow action.
         «IF !targets('3.0')»
         *
         * @param array $args List of arguments from handleCommand method
         *
         * @return bool Whether everything worked well or not
         «ENDIF»
         */
        public function applyAction(array $args = [])«IF targets('3.0')»: bool«ENDIF»
        {
            // stub for subclasses
            return false;
        }
    '''

    def private prepareWorkflowAdditions(Application it) '''
        /**
         * Prepares properties related to advanced workflows.
         «IF !targets('3.0')»
         *
         * @param bool $enterprise Whether the enterprise workflow is used instead of the standard workflow
         *
         * @return array List of additional form options
         «ENDIF»
         */
        protected function prepareWorkflowAdditions(«IF targets('3.0')»bool «ENDIF»$enterprise = false)«IF targets('3.0')»: array«ENDIF»
        {
            $roles = [];
            $currentUserId = $this->currentUserApi->isLoggedIn()
                ? $this->currentUserApi->get('uid')
                : UsersConstant::USER_ID_ANONYMOUS
            ;
            $roles['is_creator'] = 'create' === $this->templateParameters['mode']
                || (
                    method_exists($this->entityRef, 'getCreatedBy')
                    && $this->entityRef->getCreatedBy()->getUid() === $currentUserId
                )
            ;

            $groupApplicationArgs = [
                'user' => $currentUserId,
                'group' => $this->variableApi->get(
                    '«appName»',
                    'moderationGroupFor' . $this->objectTypeCapital,
                    GroupsConstant::GROUP_ID_ADMIN
                ),
            ];
            $roles['is_moderator'] = 0 < count($this->groupApplicationRepository->findBy($groupApplicationArgs));

            if (true === $enterprise) {
                $groupApplicationArgs = [
                    'user' => $currentUserId,
                    'group' => $this->variableApi->get(
                        '«appName»',
                        'superModerationGroupFor' . $this->objectTypeCapital,
                        GroupsConstant::GROUP_ID_ADMIN
                    ),
                ];
                $roles['is_super_moderator'] = 0 < count($this->groupApplicationRepository->findBy($groupApplicationArgs));
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
        use Exception;
        use RuntimeException;
        «IF app.targets('3.0')»
            use Symfony\Component\Form\FormInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RedirectResponse;
        «IF ownerPermission»
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
            «IF app.targets('3.0')»
                use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            «ENDIF»
        «ENDIF»
        «IF ownerPermission || !fields.filter(UserField).filter[!nullable].empty»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        use «entityClassName('', false)»;
        «IF attributable»
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
        «IF app.hasTranslatable»
            $this->hasTranslatableFields = «hasTranslatableFields.displayBool»;
        «ENDIF»
    '''

    def private formHandlerBaseInitEntityForEditing(Entity it) '''
        protected function initEntityForEditing()«IF app.targets('3.0')»: ?EntityAccess«ENDIF»
        {
            $entity = parent::initEntityForEditing();
            if (null === $entity) {
                return $entity;
            }
            «IF ownerPermission»

                // only allow editing for the owner or people with higher permissions
                $currentUserId = $this->currentUserApi->isLoggedIn()
                    ? $this->currentUserApi->get('uid')
                    : UsersConstant::USER_ID_ANONYMOUS
                ;
                $isOwner = null !== $entity
                    && null !== $entity->getCreatedBy()
                    && $currentUserId === $entity->getCreatedBy()->getUid()
                ;
                if (!$isOwner && !$this->permissionHelper->hasEntityPermission($entity, ACCESS_ADD)) {
                    throw new AccessDeniedException();
                }
            «ENDIF»

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
        public function processForm(array $templateParameters = [])
        {
            «memberVarAssignments»

            $result = parent::processForm($templateParameters);
            if ($result instanceof RedirectResponse) {
                return $result;
            }

            if ('create' === $this->templateParameters['mode'] && !$this->modelHelper->canBeCreated($this->objectType)) {
                $request = $this->requestStack->getCurrentRequest();
                if ($request->hasSession() && ($session = $request->getSession())) {
                    $session->getFlashBag()->add(
                        'error',
                        «IF app.targets('3.0') && app.isSystemModule»
                            'Sorry, but you can not create the «name.formatForDisplay» yet as other items are required which must be created before!'
                        «ELSE»
                            $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»(
                                'Sorry, but you can not create the «name.formatForDisplay» yet as other items are required which must be created before!'«IF app.targets('3.0') && !app.isSystemModule»,
                                [],
                                '«name.formatForCode»'«ENDIF»
                            )
                        «ENDIF»
                    );
                }
                $logArgs = [
                    'app' => '«app.appName»',
                    'user' => $this->currentUserApi->get('uname'),
                    'entity' => $this->objectType,
                ];
                $this->logger->notice(
                    '{app}: User {user} tried to create a new {entity}, but failed'
                        . ' as other items are required which must be created before.',
                    $logArgs
                );

                return new RedirectResponse($this->getRedirectUrl(['commandName' => '']), 302);
            }
            «locking.setVersion(it)»
            «IF !app.targets('3.0')»

                $entityData = $this->entityRef->toArray();
            «ENDIF»

            // assign data to template«IF !app.targets('3.0')» as array«ENDIF» (for additions like standard fields)
            $this->templateParameters[$this->objectTypeLower] = «IF app.targets('3.0')»$this->entityRef«ELSE»$entityData«ENDIF»;
            «IF !skipHookSubscribers»
                $this->templateParameters['supportsHookSubscribers'] = $this->entityRef->supportsHookSubscribers();
            «ENDIF»

            return $result;
        }
        «IF !incoming.empty || !outgoing.empty»
            «relationPresetsHelper.childMethod(it)»
        «ENDIF»

        protected function createForm()«IF app.targets('3.0')»: ?FormInterface«ENDIF»
        {
            return $this->formFactory->create(«name.formatForCodeCapital»Type::class, $this->entityRef, $this->getFormOptions());
        }

        protected function getFormOptions()«IF app.targets('3.0')»: array«ENDIF»
        {
            $options = [
                «IF hasUploadFieldsEntity»
                    'entity' => $this->entityRef,
                «ENDIF»
                'mode' => $this->templateParameters['mode'],
                'actions' => $this->templateParameters['actions'],
                «IF standardFields»
                    'has_moderate_permission' => $this->permissionHelper->hasEntityPermission($this->entityRef, ACCESS_ADMIN),
                    'allow_moderation_specific_creator' => (bool) $this->variableApi->get(
                        '«app.appName»',
                        'allowModerationSpecificCreatorFor' . $this->objectTypeCapital,
                        false
                    ),
                    'allow_moderation_specific_creation_date' => (bool) $this->variableApi->get(
                        '«app.appName»',
                        'allowModerationSpecificCreationDateFor' . $this->objectTypeCapital,
                        false
                    ),
                «ENDIF»
                «IF !incoming.empty || !outgoing.empty»
                    'filter_by_ownership' => !$this->permissionHelper->hasEntityPermission($this->entityRef, ACCESS_ADD),
                «ENDIF»
                «IF !incoming.empty || !outgoing.empty»
                    'inline_usage' => $this->templateParameters['inlineUsage'],
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
                    $translationKey = $this->objectTypeLower . $language;
                    «IF app.targets('3.0')»
                        $options['translations'][$language] = $this->templateParameters[$translationKey] ?? [];
                    «ELSE»
                        $options['translations'][$language] = isset($this->templateParameters[$translationKey]) ? $this->templateParameters[$translationKey] : [];
                    «ENDIF»
                }
            «ENDIF»

            return $options;
        }
    '''

    def private dispatch handleCommand(Entity it) '''
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
            if (
                'create' === $this->templateParameters['mode']
                && $this->form->has('submitrepeat')
                && $this->form->get('submitrepeat')->isClicked()
            ) {
                $args['commandName'] = 'submit';
                $this->repeatCreateAction = true;
            }

            return new RedirectResponse($this->getRedirectUrl($args), 302);
        }

        protected function getDefaultMessage(array $args = [], «IF app.targets('3.0')»bool «ENDIF»$success = false)«IF app.targets('3.0')»: string«ENDIF»
        {
            if (false === $success) {
                return parent::getDefaultMessage($args, $success);
            }

            switch ($args['commandName']) {
                «IF app.hasWorkflowState('deferred')»
                    case 'defer':
                «ENDIF»
                case 'submit':
                    if ('create' === $this->templateParameters['mode']) {
                        $message = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Done! «name.formatForDisplayCapital» created.'«IF app.targets('3.0') && !app.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
                    } else {
                        $message = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Done! «name.formatForDisplayCapital» updated.'«IF app.targets('3.0') && !app.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
                    }
                    «IF EntityWorkflowType.NONE !== workflow»
                        if ('waiting' === $this->entityRef->getWorkflowState()) {
                            $message .= ' ' . $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('It is now waiting for approval by our moderators.');
                        }
                    «ENDIF»
                    break;
                case 'delete':
                    $message = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Done! «name.formatForDisplayCapital» deleted.'«IF app.targets('3.0') && !app.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
                    break;
                default:
                    $message = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Done! «name.formatForDisplayCapital» updated.'«IF app.targets('3.0') && !app.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
                    break;
            }

            return $message;
        }
    '''

    def private dispatch applyAction(Entity it) '''
        /**
         * @throws RuntimeException Thrown if concurrent editing is recognised or another error occurs
         */
        public function applyAction(array $args = [])«IF app.targets('3.0')»: bool«ENDIF»
        {
            // get treated entity reference from persisted member var
            /** @var «name.formatForCodeCapital»Entity $entity */
            $entity = $this->entityRef;

            $action = $args['commandName'];
            «IF loggable»
                if ('delete' === $action) {
                    $entity->set_actionDescriptionForLogEntry('_HISTORY_«name.formatForCode.toUpperCase»_DELETED');
                } elseif ('create' === $this->templateParameters['mode']) {
                    $entity->set_actionDescriptionForLogEntry('_HISTORY_«name.formatForCode.toUpperCase»_CREATED');
                } else {
                    $templateId = $this->requestStack->getCurrentRequest()->query->getInt('astemplate');
                    if ($templateId > 0) {
                        $entityT = $this->entityFactory->getRepository($this->objectType)->selectById($templateId, false, true);
                        if (null !== $entityT) {
                            $entity->set_actionDescriptionForLogEntry('_HISTORY_«name.formatForCode.toUpperCase»_CLONED|%«name.formatForCode»%=' . $entityT->getKey());
                        }
                    }
                    if (!$entity->get_actionDescriptionForLogEntry()) {
                        $entity->set_actionDescriptionForLogEntry('_HISTORY_«name.formatForCode.toUpperCase»_UPDATED');
                    }
                }
            «ENDIF»
            «IF !fields.filter(UserField).filter[!nullable].empty»
                if ('delete' !== $action) {
                    «FOR field : fields.filter(UserField).filter[!nullable]»
                        if (!$entity->get«field.name.formatForCodeCapital»()) {
                            $entity->set«field.name.formatForCodeCapital»($this->userRepository->find(UsersConstant::USER_ID_ANONYMOUS));
                        }
                    «ENDFOR»
                }
            «ENDIF»
            «locking.getVersion(it)»

            $success = false;
            try {
                «locking.applyLock(it)»
                // execute the workflow action
                $success = $this->workflowHelper->executeAction($entity, $action);
            «locking.catchException(it)»
            } catch (Exception $exception) {
                $request = $this->requestStack->getCurrentRequest();
                if ($request->hasSession() && ($session = $request->getSession())) {
                    $session->getFlashBag()->add(
                        'error',
                        $this->«IF app.targets('3.0')»trans«ELSE»__f«ENDIF»(
                            'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                            ['%action%' => $action]
                        ) . ' ' . $exception->getMessage()
                    );
                }
                $logArgs = [
                    'app' => '«app.appName»',
                    'user' => $this->currentUserApi->get('uname'),
                    'entity' => '«name.formatForDisplay»',
                    'id' => $entity->getKey(),
                    'errorMessage' => $exception->getMessage(),
                ];
                $this->logger->error(
                    '{app}: User {user} tried to edit the {entity} with id {id},'
                        . ' but failed. Error details: {errorMessage}.',
                    $logArgs
                );
            }

            $this->addDefaultMessage($args, $success);

            if ($success && 'create' === $this->templateParameters['mode']) {
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
