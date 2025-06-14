package org.zikula.modulestudio.generator.cartridges.symfony.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.symfony.controller.actionhandler.Locking
import org.zikula.modulestudio.generator.cartridges.symfony.controller.actionhandler.Redirect
import org.zikula.modulestudio.generator.cartridges.symfony.controller.actionhandler.RelationPresets
import org.zikula.modulestudio.generator.cartridges.symfony.controller.form.AutoCompletionRelationTransformer
import org.zikula.modulestudio.generator.cartridges.symfony.controller.form.TranslationListener
import org.zikula.modulestudio.generator.cartridges.symfony.controller.form.UploadFileTransformer
import org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.EditEntityType
import org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.field.AutoCompletionRelationType
import org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.field.EntityTreeType
import org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.field.GeoType
import org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.field.TranslationType
import org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.field.UploadType
import org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.trait.ModerationFormFieldsTrait
import org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.trait.WorkflowFormFieldsTrait
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
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

        if (hasEditActions()) {
            // form handlers
            generateCommon('edit', fsa)
            for (entity : entities.filter[hasEditAction]) {
                entity.generate('edit', fsa)
            }
            // form types
            for (entity : entities.filter[hasEditAction]) {
                new EditEntityType().generate(entity, fsa)
            }
            if (hasUploads) {
                new UploadType().generate(it, fsa)
                new UploadFileTransformer().generate(it, fsa)
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

    def private collectCommonBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Psr\\Log\\LoggerInterface',
            'RuntimeException',
            'Symfony\\Bundle\\SecurityBundle\\Security',
            'Symfony\\Component\\Form\\Form',
            'Symfony\\Component\\Form\\FormFactoryInterface',
            'Symfony\\Component\\Form\\FormInterface',
            'Symfony\\Component\\HttpFoundation\\RedirectResponse',
            'Symfony\\Component\\HttpFoundation\\RequestStack',
            'Symfony\\Component\\Routing\\RouterInterface',
            'Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException',
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            'Zikula\\CoreBundle\\Translation\\TranslatorTrait',
            appNamespace + '\\Entity\\EntityInterface',
            appNamespace + '\\Entity\\Factory\\EntityFactory',
            appNamespace + '\\Helper\\ControllerHelper',
            appNamespace + '\\Helper\\ModelHelper',
            appNamespace + '\\Helper\\PermissionHelper',
            appNamespace + '\\Helper\\WorkflowHelper'
        ])
        if (!entities.filter[hasDetailAction && hasEditAction && hasSluggableFields].empty) {
            imports.add('Symfony\\Component\\Routing\\Generator\\UrlGeneratorInterface')
        }
        if (hasTranslatable || needsApproval || hasStandardFieldEntities) {
            imports.add('function Symfony\\Component\\String\\s')
        }
        if (hasTranslatable) {
            imports.add('Zikula\\CoreBundle\\Api\\ApiInterface\\LocaleApiInterface')
            imports.add(appNamespace + '\\Helper\\TranslatableHelper')
        }
        if (needsApproval) {
            imports.add('Doctrine\\Common\\Collections\\ArrayCollection')
            imports.add('Zikula\\UsersBundle\\UsersConstant')
        }
        if (hasNonNullableUserFields) {
            imports.add('Nucleos\\UserBundle\\Model\\UserManager')
        }
        if (needsFeatureActivationHelper) {
            imports.add(appNamespace + '\\Helper\\FeatureActivationHelper')
        }
        imports
    }

    def private formHandlerCommonBaseImpl(Application it, String actionName) '''
        namespace «appNamespace»\Form\Handler\Common\Base;

        «collectCommonBaseImports.print»

        /**
         * This handler class handles the page events of editing forms.
         * It collects common functionality required by different object types.
         */
        abstract class Abstract«actionName.formatForCodeCapital»Handler
        {
            use TranslatorTrait;

            /**
             * Name of treated object type.
             */
            protected string $objectType;

            /**
             * Reference to treated entity instance.
             */
            protected EntityInterface $entityRef;

            /**
             * Name of primary identifier field.
             */
            protected string $idField;

            /**
             * Identifier of treated entity.
             */
            protected int $idValue = 0;

            /**
             * Code defining the redirect goal after command handling.
             */
            protected ?string $returnTo = null;

            /**
             * Whether a create action is going to be repeated or not.
             */
            protected bool $repeatCreateAction = false;

            /**
             * Url of current form with all parameters for multiple creations.
             */
            protected string $repeatReturnUrl;
            «IF !relations.empty»
                «relationPresetsHelper.memberFields(it)»
            «ENDIF»
            «IF !relations.empty || needsAutoCompletion»

                /**
                 * Full prefix for related items.
                 */
                protected string $idPrefix = '';
            «ENDIF»
            «IF hasTranslatable»

                /**
                 * Whether the entity has translatable fields or not.
                 */
                protected bool $hasTranslatableFields = false;
            «ENDIF»

            /**
             * The handled form type.
             */
            protected Form $form;

            /**
             * Template parameters.
             */
            protected array $templateParameters = [];

            public function __construct(
                TranslatorInterface $translator,
                protected readonly FormFactoryInterface $formFactory,
                protected readonly RequestStack $requestStack,
                protected readonly RouterInterface $router,
                protected readonly LoggerInterface $logger,
                protected readonly Security $security,
                «IF hasTranslatable»
                    protected readonly LocaleApiInterface $localeApi,
                «ENDIF»
                «IF hasNonNullableUserFields»
                    protected readonly UserManager $userManager,
                «ENDIF»
                protected readonly EntityFactory $entityFactory,
                protected readonly ControllerHelper $controllerHelper,
                protected readonly ModelHelper $modelHelper,
                protected readonly PermissionHelper $permissionHelper,
                protected readonly WorkflowHelper $workflowHelper«IF hasTranslatable»,
                protected readonly TranslatableHelper $translatableHelper«ENDIF»«IF needsFeatureActivationHelper»,
                protected readonly FeatureActivationHelper $featureActivationHelper«ENDIF»«IF hasTranslatable || needsApproval || hasStandardFieldEntities»,
                protected readonly array $moderationConfig
                «ENDIF»
            ) {
                $this->setTranslator($translator);
            }

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
         * @return bool|RedirectResponse Redirect or false on errors
         *
         * @throws AccessDeniedException Thrown if user has not the required permissions
         * @throws RuntimeException Thrown if the workflow actions can not be determined
         */
        public function processForm(array $templateParameters = [])
        {
            $request = $this->requestStack->getCurrentRequest();
            $this->templateParameters = $templateParameters;
            «IF !relations.empty»
                $this->templateParameters['inlineUsage'] = $request->query->getBoolean('raw');
            «ENDIF»
            «IF !relations.empty || app.needsAutoCompletion»
                $this->idPrefix = $request->query->get('idp', '');
            «ENDIF»
            $session = $request->hasSession() ? $request->getSession() : null;

            // initialise redirect goal
            $this->returnTo = $request->query->get('returnTo');
            if (null !== $session) {
                // default to referer
                $refererSessionVar = '«appName.formatForDB»' . ucfirst($this->objectType) . 'Referer';
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
                $this->idValue = (int) (!empty($routeParams[$this->idField]) ? $routeParams[$this->idField] : 0);
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
                    if (!$this->permissionHelper->mayEdit($entity)) {
                        throw new AccessDeniedException();
                    }
                    «IF !entities.filter[hasDetailAction && hasEditAction && hasSluggableFields].empty»
                        if (null !== $session && in_array($this->objectType, ['«entities.filter[hasDetailAction && hasEditAction && hasSluggableFields].map[name.formatForCode].join('\', \'')»'], true)) {
                            // map display return urls to redirect codes because slugs may change
                            $routePrefix = '«app.appName.formatForDB»_' . mb_strtolower($this->objectType) . '_';
                            $userDetailUrl = $this->router->generate(
                                $routePrefix . 'detail',
                                $entity->createUrlArgs(),
                                UrlGeneratorInterface::ABSOLUTE_URL
                            );
                            $adminDetailUrl = $this->router->generate(
                                $routePrefix . 'admindetail',
                                $entity->createUrlArgs(),
                                UrlGeneratorInterface::ABSOLUTE_URL
                            );
                            if ($this->returnTo === $userDetailUrl) {
                                $this->returnTo = 'userDetail';
                            } elseif ($this->returnTo === $adminDetailUrl) {
                                $this->returnTo = 'adminDetail';
                            }
                            $session->set($refererSessionVar, $this->returnTo);
                        }
                    «ENDIF»
                }
            } else {
                «IF needsApproval»
                    $objectTypesNeedingApproval = ['«entities.filter[approval].map[name.formatForCode].join('\', \'')»'];
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
                    $session->getFlashBag()->add('error', 'No such item found.');
                }

                return new RedirectResponse($this->router->generate('home'), 302);
            }

            «IF !entities.filter[hasEditAction && hasSluggableFields && needsSlugHandler].empty»
                if (
                    in_array($this->objectType, ['«entities.filter[hasEditAction && hasSluggableFields && needsSlugHandler].map[name.formatForCode].join('\', \'')»'], true)
                    && method_exists($entity, 'getSlug')
                    && null !== $entity->getSlug()
                ) {
                    $slugParts = explode('/', $entity->getSlug());
                    $entity->setSlug(end($slugParts));
                }
            «ENDIF»
            // save entity reference for later reuse
            $this->entityRef = $entity;
            «initialiseExtensions»
            «IF !relations.empty»
                «relationPresetsHelper.callBaseMethod(it)»
            «ENDIF»

            $actions = $this->workflowHelper->getActionsForObject($entity);
            if (false === $actions || !is_array($actions)) {
                if (null !== $session) {
                    $session->getFlashBag()->add(
                        'error',
                        'Error! Could not determine workflow actions.'
                    );
                }
                $logArgs = [
                    'app' => '«appName»',
                    'user' => $this->security->getUser()?->getUserIdentifier(),
                    'entity' => $this->objectType,
                    'id' => $entity->getKey(),
                ];
                $this->logger->error(
                    '{app}: User {user} tried to edit the {entity} with id {id},'
                        . ' but failed to determine available workflow actions.',
                    $logArgs
                );
                throw new RuntimeException($this->trans('Error! Could not determine workflow actions.'));
            }

            $this->templateParameters['actions'] = $actions;

            $this->form = $this->createForm();
            if (!is_object($this->form)) {
                return false;
            }

            // handle form request and check validity constraints of edited entity
            $this->form->handleRequest($request);
            if ($this->form->isSubmitted()) {
                if ($this->form->has('cancel') && $this->form->get('cancel')->isClicked()) {
                    return new RedirectResponse($this->getRedirectUrl(['commandName' => 'cancel']), 302);
                }
                if ($this->form->isValid()) {
                    $result = $this->handleCommand();
                    if (false === $result) {
                        $this->templateParameters['form'] = $this->form;
                    }

                    return $result;
                }
            }

            $this->templateParameters['form'] = $this->form;

            // everything okay, no initialisation errors occured
            return true;
        }

        /**
         * Creates the form type.
         */
        protected function createForm(): ?FormInterface
        {
            // to be customised in sub classes
            return null;
        }

        /**
         * Returns the form options.
         */
        protected function getFormOptions(): array
        {
            // to be customised in sub classes
            return [];
        }
        «IF !relations.empty»
            «relationPresetsHelper.baseMethod(it)»
        «ENDIF»
        «fh.getterMethod(it, 'templateParameters', 'array', false)»

        «initEntityForEditing»

        «initEntityForCreation»
        «initTranslationsForEditing»
    '''

    def private initialiseExtensions(Application it) '''
        «IF hasTranslatable»

            if (true === $this->hasTranslatableFields) {
                $this->initTranslationsForEditing();
            }
        «ENDIF»
    '''

    def private initEntityForEditing(Application it) '''
        /**
         * Initialise existing entity for editing.
         */
        protected function initEntityForEditing(): ?EntityInterface
        {
            return $this->entityFactory->getRepository($this->objectType)->selectById($this->idValue);
        }
    '''

    def private initEntityForCreation(Application it) '''
        /**
         * Initialise new entity for creation.
         */
        protected function initEntityForCreation(): ?EntityInterface
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
            protected function initTranslationsForEditing(): void
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

                if (!$this->localeApi->multilingual() || 2 > count($supportedLanguages)) {
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
                    $this->templateParameters[mb_strtolower($this->objectType) . $language] = $translationData;
                }
            }
        «ENDIF»
    '''

    def private dispatch handleCommand(Application it) '''
        /**
         * Command event handler.
         * This event handler is called when a command is issued by the user.
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
            «IF hasTranslatable»

                $action = $args['commandName'];
                «IF hasTranslatable»
                    $isRegularAction = 'delete' !== $action;
                «ENDIF»
            «ENDIF»

            if (false === $this->fetchInputData()) {
                return false;
            }
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

            return new RedirectResponse($this->getRedirectUrl($args), 302);
        }
        «IF hasTranslatable»

            /**
             * Prepare update of translations.
             */
            protected function processTranslationsForUpdate(): void
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
         */
        protected function getDefaultMessage(array $args = [], bool $success = false): string
        {
            $message = '';
            switch ($args['commandName']) {
                case 'create':
                    if (true === $success) {
                        $message = $this->trans('Done! Item created.');
                    } else {
                        $message = $this->trans('Error! Creation attempt failed.');
                    }
                    break;
                case 'update':
                    if (true === $success) {
                        $message = $this->trans('Done! Item updated.');
                    } else {
                        $message = $this->trans('Error! Update attempt failed.');
                    }
                    break;
                case 'delete':
                    if (true === $success) {
                        $message = $this->trans('Done! Item deleted.');
                    } else {
                        $message = $this->trans('Error! Deletion attempt failed.');
                    }
                    break;
            }

            return $message;
        }

        /**
         * Add success or error message to session.
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         */
        protected function addDefaultMessage(array $args = [], bool $success = false): void
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
                'user' => $this->security->getUser()?->getUserIdentifier(),
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

            // return remaining form data
            return $formData;
        }
    '''

    def private dispatch applyAction(Application it) '''
        /**
         * Executes a certain workflow action.
         */
        public function applyAction(array $args = []): bool
        {
            // stub for subclasses
            return false;
        }
    '''

    def private prepareWorkflowAdditions(Application it) '''
        /**
         * Prepares properties related to approval handling.
         */
        protected function prepareWorkflowAdditions(): array
        {
            $roles = [];
            $currentUserId = $this->security->getUser()?->getId() ?? UsersConstant::USER_ID_ANONYMOUS;
            $roles['is_creator'] = 'create' === $this->templateParameters['mode']
                || (
                    method_exists($this->entityRef, 'getCreatedBy')
                    && $currentUserId === $this->entityRef->getCreatedBy()?->getId()
                )
            ;

            $configSuffix = s($this->objectType)->snake();
            $userGroups = $this->security->getUser()?->getGroups() ?? new ArrayCollection();
            $moderationGroupId = $this->moderationConfig['moderation_group_for_' . $configSuffix];
            $roles['is_moderator'] = !$userGroups->filter(fn(Group $group) => $moderationGroupId === $group->getId())->isEmpty();

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

    def private collectBaseImports(Entity it, String actionName) {
        val imports = new ImportList
        imports.addAll(#[
            'Exception',
            'RuntimeException',
            'Symfony\\Component\\Form\\FormInterface',
            'Symfony\\Component\\HttpFoundation\\RedirectResponse',
            entityClassName('', false),
            app.appNamespace + '\\Form\\Handler\\Common\\' + actionName.formatForCodeCapital + 'Handler',
            app.appNamespace + '\\Form\\Type\\' + name.formatForCodeCapital + 'Type'
        ])
        imports.addAll(locking.imports(it))
        if (ownerPermission || !fields.filter(UserField).filter[!nullable].empty) {
            imports.add('Zikula\\UsersBundle\\UsersConstant')
            if (ownerPermission) {
                imports.add('Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException')
                imports.add(app.appNamespace + '\\Entity\\EntityInterface')
            }
        }
        imports
    }

    def private formHandlerBaseImports(Entity it, String actionName) '''
        namespace «app.appNamespace»\Form\Handler\«name.formatForCodeCapital»\Base;

        «collectBaseImports(actionName).print»
    '''

    def private memberVarAssignments(Entity it) '''
        $this->objectType = '«name.formatForCode»';
        «IF app.hasTranslatable»
            $this->hasTranslatableFields = «hasTranslatableFields.displayBool»;
        «ENDIF»
    '''

    def private formHandlerBaseInitEntityForEditing(Entity it) '''
        protected function initEntityForEditing(): ?EntityInterface
        {
            $entity = parent::initEntityForEditing();
            if (null === $entity) {
                return $entity;
            }
            «IF ownerPermission»

                // only allow editing for the owner or people with higher permissions
                $currentUserId = $this->security->getUser()?->getId() ?? UsersConstant::USER_ID_ANONYMOUS;
                $isOwner = null !== $entity && $currentUserId === $entity->getCreatedBy()?->getId();
                if (!$isOwner && !$this->permissionHelper->hasEntityPermission($entity/*, ACCESS_ADD*/)) {
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
                        $this->trans(
                            'Sorry, but you can not create the «name.formatForDisplay» yet as other items are required which must be created before!',
                            [],
                            '«name.formatForCode»'
                        )
                    );
                }
                $logArgs = [
                    'app' => '«app.appName»',
                    'user' => $this->security->getUser()?->getUserIdentifier(),
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

            // assign data to template
            $this->templateParameters[$this->objectType] = $this->entityRef;

            return $result;
        }
        «IF !incoming.empty || !outgoing.empty»
            «relationPresetsHelper.childMethod(it)»
        «ENDIF»

        protected function createForm(): ?FormInterface
        {
            return $this->formFactory->create(«name.formatForCodeCapital»Type::class, $this->entityRef, $this->getFormOptions());
        }

        protected function getFormOptions(): array
        {
            «IF standardFields»
                $configSuffix = s($this->objectType)->snake();
            «ENDIF»
            $options = [
                «IF hasUploadFieldsEntity»
                    'entity' => $this->entityRef,
                «ENDIF»
                'mode' => $this->templateParameters['mode'],
                'actions' => $this->templateParameters['actions'],
                «IF standardFields»
                    'has_moderate_permission' => $this->permissionHelper->hasEntityPermission($this->entityRef/*, ACCESS_ADMIN*/),
                    'allow_moderation_specific_creator' => $this->moderationConfig['allow_moderation_specific_creator_for_' . $configSuffix],
                    'allow_moderation_specific_creation_date' => $this->moderationConfig['allow_moderation_specific_creation_date_for_' . $configSuffix],
                «ENDIF»
                «IF !incoming.empty || !outgoing.empty»
                    'filter_by_ownership' => !$this->permissionHelper->hasEntityPermission($this->entityRef/*, ACCESS_ADD*/),
                    'inline_usage' => $this->templateParameters['inlineUsage'],
                «ENDIF»
            ];
            «IF approval»

                $workflowRoles = $this->prepareWorkflowAdditions();
                $options = array_merge($options, $workflowRoles);
            «ENDIF»
            «IF hasTranslatableFields»

                $options['translations'] = [];
                foreach ($this->templateParameters['supportedLanguages'] as $language) {
                    $translationKey = mb_strtolower($this->objectType) . $language;
                    $options['translations'][$language] = $this->templateParameters[$translationKey] ?? [];
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

        protected function getDefaultMessage(array $args = [], bool $success = false): string
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
                        $message = $this->trans('Done! «name.formatForDisplayCapital» created.', [], '«name.formatForCode»');
                    } else {
                        $message = $this->trans('Done! «name.formatForDisplayCapital» updated.', [], '«name.formatForCode»');
                    }
                    «IF approval»
                        if ('waiting' === $this->entityRef->getWorkflowState()) {
                            $message .= ' ' . $this->trans('It is now waiting for approval by our moderators.');
                        }
                    «ENDIF»
                    break;
                case 'delete':
                    $message = $this->trans('Done! «name.formatForDisplayCapital» deleted.', [], '«name.formatForCode»');
                    break;
                default:
                    $message = $this->trans('Done! «name.formatForDisplayCapital» updated.', [], '«name.formatForCode»');
                    break;
            }

            return $message;
        }
    '''

    def private dispatch applyAction(Entity it) '''
        /**
         * @throws RuntimeException Thrown if concurrent editing is recognised or another error occurs
         */
        public function applyAction(array $args = []): bool
        {
            // get treated entity reference from persisted member var
            /** @var «name.formatForCodeCapital» $entity */
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
                            $entity->set«field.name.formatForCodeCapital»($this->userManager->findUserBy(['id' => UsersConstant::USER_ID_ANONYMOUS]));
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
                        $this->trans(
                            'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                            ['%action%' => $action]
                        ) . ' ' . $exception->getMessage()
                    );
                }
                $logArgs = [
                    'app' => '«app.appName»',
                    'user' => $this->security->getUser()?->getUserIdentifier(),
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
