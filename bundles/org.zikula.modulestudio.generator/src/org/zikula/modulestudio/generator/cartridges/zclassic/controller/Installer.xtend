package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ModVars
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Installer {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for application installer.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair(name.formatForCodeCapital + 'ModuleInstaller.php', installerBaseClass, installerImpl)
    }

    def private installerBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        «IF targets('3.0')»
            use Doctrine\Persistence\ManagerRegistry;
        «ENDIF»
        use Exception;
        «IF targets('3.0')»
            use Psr\Log\LoggerInterface;
            «IF hasUploads»
                use Symfony\Component\Filesystem\Filesystem;
            «ENDIF»
            use Symfony\Component\HttpFoundation\RequestStack;
            use Symfony\Contracts\Translation\TranslatorInterface;
            use Zikula\Bundle\CoreBundle\Doctrine\Helper\SchemaHelper;
        «ENDIF»
        «IF !targets('3.0')»
            use Zikula\Core\AbstractExtensionInstaller;
        «ENDIF»
        «IF hasCategorisableEntities»
            «IF targets('3.0')»
                use Zikula\CategoriesModule\Api\CategoryPermissionApi;
            «ENDIF»
            use Zikula\CategoriesModule\Entity\CategoryRegistryEntity;
            «IF targets('3.0')»
                use Zikula\CategoriesModule\Entity\RepositoryInterface\CategoryRegistryRepositoryInterface;
                use Zikula\CategoriesModule\Entity\RepositoryInterface\CategoryRepositoryInterface;
            «ENDIF»
        «ENDIF»
        «IF targets('3.0')»
            use Zikula\ExtensionsModule\AbstractExtension;
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
            use Zikula\ExtensionsModule\Installer\AbstractExtensionInstaller;
            «IF hasUploads || hasCategorisableEntities»
                use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
            «ENDIF»
        «ENDIF»
        «funcListEntityClasses('import')»

        /**
         * Installer base class.
         */
        abstract class Abstract«name.formatForCodeCapital»ModuleInstaller extends AbstractExtensionInstaller
        {
            «memberVars»

            «installerBaseImpl»
        }
    '''

    def private memberVars(Application it) '''
        /**
         * @var string[]
         */
        protected $entities = [
            «funcListEntityClasses('usage')»
        ];
        «IF targets('3.0')»

            /**
             * @var LoggerInterface
             */
            protected $logger;
            «IF hasUploads || hasCategorisableEntities»

                /**
                 * @var CurrentUserApiInterface
                 */
                protected $currentUserApi;
            «ENDIF»
            «IF hasCategorisableEntities»

                /**
                 * @var CategoryRepositoryInterface
                 */
                protected $categoryRepository;

                /**
                 * @var CategoryRegistryRepositoryInterface
                 */
                protected $categoryRegistryRepository;

                /**
                 * @var CategoryPermissionApi
                 */
                protected $categoryPermissionApi;
            «ENDIF»
            «IF hasUploads»

                /**
                 * @var Filesystem
                 */
                protected $filesystem;

                /**
                 * @var string
                 */
                protected $dataDirectory;
            «ENDIF»
        «ENDIF»
    '''

    def private installerBaseImpl(Application it) '''
        «IF targets('3.0')»
            public function __construct(
                AbstractExtension $extension,
                ManagerRegistry $managerRegistry,
                SchemaHelper $schemaTool,
                RequestStack $requestStack,
                TranslatorInterface $translator,
                VariableApiInterface $variableApi,
                LoggerInterface $logger«IF hasUploads || hasCategorisableEntities»,
                CurrentUserApiInterface $currentUserApi«ENDIF»«IF hasCategorisableEntities»,
                CategoryRepositoryInterface $categoryRepository,
                CategoryRegistryRepositoryInterface $categoryRegistryRepository,
                CategoryPermissionApi $categoryPermissionApi«ENDIF»«IF hasUploads»,
                Filesystem $filesystem,
                string $dataDirectory
                «ENDIF»
            ) {
                parent::__construct($extension, $managerRegistry, $schemaTool, $requestStack, $translator, $variableApi);
                $this->logger = $logger;
                «IF hasUploads || hasCategorisableEntities»
                    $this->currentUserApi = $currentUserApi;
                «ENDIF»
                «IF hasCategorisableEntities»
                    $this->categoryRepository = $categoryRepository;
                    $this->categoryRegistryRepository = $categoryRegistryRepository;
                    $this->categoryPermissionApi = $categoryPermissionApi;
                «ENDIF»
                «IF hasUploads»
                    $this->filesystem = $filesystem;
                    $this->dataDirectory = $dataDirectory;
                «ENDIF»
            }

        «ENDIF»
        «funcInit»

        «funcUpdate»

        «funcDelete»
    '''

    def private funcInit(Application it) '''
        public function install()«IF targets('3.0')»: bool«ENDIF»
        {
            «IF !targets('3.0')»
                $logger = $this->container->get('logger');

            «ENDIF»
            «IF hasUploads || hasCategorisableEntities»
                «IF targets('3.0')»
                    $userName = $this->currentUserApi->get('uname');
                «ELSE»
                    $userName = $this->container->get('zikula_users_module.current_user')->get('uname');
                «ENDIF»

            «ENDIF»
            «processUploadFolders»
            // create all tables from according entity definitions
            try {
                $this->schemaTool->create($this->entities);
            } catch (Exception $exception) {
                $this->addFlash('error', $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Doctrine Exception') . ': ' . $exception->getMessage());
                $«IF targets('3.0')»this->«ENDIF»logger->error(
                    '{app}: Could not create the database tables during installation. Error details: {errorMessage}.',
                    ['app' => '«appName»', 'errorMessage' => $exception->getMessage()]
                );

                throw $exception;
            }
            «IF !variables.empty»

                // set up all our vars with initial values
                «new ModVars().init(it)»
            «ENDIF»
            «IF hasCategorisableEntities»

                // add default entry for category registry (property named Main)
                «IF targets('3.0')»
                    $categoryHelper = new \«appNamespace»\Helper\CategoryHelper(
                        $this->getTranslator(),
                        $this->requestStack,
                        $this->logger,
                        $this->currentUserApi,
                        $this->categoryRegistryRepository,
                        $this->categoryPermissionApi
                    );
                    $categoryGlobal = $this->categoryRepository->findOneBy(['name' => 'Global']);
                «ELSE»
                    $categoryHelper = new \«appNamespace»\Helper\CategoryHelper(
                        $this->container->get('translator.default'),
                        $this->container->get('request_stack'),
                        $logger,
                        $this->container->get('zikula_users_module.current_user'),
                        $this->container->get('zikula_categories_module.category_registry_repository'),
                        $this->container->get('zikula_categories_module.api.category_permission')
                    );
                    $categoryGlobal = $this->container->get('zikula_categories_module.category_repository')->findOneBy(['name' => 'Global']);
                «ENDIF»
                if ($categoryGlobal) {
                    $categoryRegistryIdsPerEntity = [];
                    «FOR entity : getCategorisableEntities»

                        $registry = new CategoryRegistryEntity();
                        $registry->setModname('«appName»');
                        $registry->setEntityname('«entity.name.formatForCodeCapital»Entity');
                        $registry->setProperty($categoryHelper->getPrimaryProperty('«entity.name.formatForCodeCapital»'));
                        $registry->setCategory($categoryGlobal);

                        try {
                            $this->entityManager->persist($registry);
                            $this->entityManager->flush();
                        } catch (Exception $exception) {
                            $this->addFlash(
                                'warning',
                                $this->«IF targets('3.0')»trans«ELSE»__f«ENDIF»(
                                    'Error! Could not create a category registry for the %entity% entity. If you want to use categorisation, register at least one registry in the Categories administration.',
                                    ['%entity%' => '«entity.name.formatForDisplay»']
                                )
                            );
                            «IF !targets('3.0')»
                                $«IF targets('3.0')»this->«ENDIF»logger->error(
                                    '{app}: User {user} could not create a category registry for {entities} during installation. Error details: {errorMessage}.',
                                    ['app' => '«appName»', 'user' => $userName, 'entities' => '«entity.nameMultiple.formatForDisplay»', 'errorMessage' => $exception->getMessage()]
                                );
                            «ENDIF»
                        }
                        $categoryRegistryIdsPerEntity['«entity.name.formatForCode»'] = $registry->getId();
                    «ENDFOR»
                }
            «ENDIF»

            // initialisation successful
            return true;
        }
    '''

    def private processUploadFolders(Application it) '''
        «IF hasUploads»
            // Check if upload directories exist and if needed create them
            try {
                «IF targets('3.0')»
                    $uploadHelper = new \«appNamespace»\Helper\UploadHelper(
                        $this->getTranslator(),
                        $this->filesystem,
                        $this->requestStack,
                        $this->logger,
                        $this->currentUserApi,
                        $this->getVariableApi(),
                        $this->dataDirectory
                    );
                «ELSE»
                    $container = $this->container;
                    $uploadHelper = new \«appNamespace»\Helper\UploadHelper(
                        $container->get('translator.default'),
                        $container->get('filesystem'),
                        $container->get('request_stack'),
                        $logger,
                        $container->get('zikula_users_module.current_user'),
                        $container->get('zikula_extensions_module.api.variable'),
                        $container->getParameter('datadir')
                    );
                «ENDIF»
                $uploadHelper->checkAndCreateAllUploadFolders();
            } catch (Exception $exception) {
                $this->addFlash('error', $exception->getMessage());
                $«IF targets('3.0')»this->«ENDIF»logger->error(
                    '{app}: User {user} could not create upload folders during installation. Error details: {errorMessage}.',
                    ['app' => '«appName»', 'user' => $userName, 'errorMessage' => $exception->getMessage()]
                );
            }
        «ENDIF»
    '''

    def private funcUpdate(Application it) '''
        public function upgrade(«IF targets('3.0')»string «ENDIF»$oldVersion)«IF targets('3.0')»: bool«ENDIF»
        {
        /*
            «IF !targets('3.0')»
                $logger = $this->container->get('logger');

            «ENDIF»
            // upgrade dependent on old version number
            switch ($oldVersion) {
                case '1.0.0':
                    // do something
                    // ...
                    // update the database schema
                    try {
                        $this->schemaTool->update($this->entities);
                    } catch (Exception $exception) {
                        $this->addFlash('error', $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Doctrine Exception') . ': ' . $exception->getMessage());
                        $«IF targets('3.0')»this->«ENDIF»logger->error(
                            '{app}: Could not update the database tables during the upgrade.'
                                . ' Error details: {errorMessage}.',
                            ['app' => '«appName»', 'errorMessage' => $exception->getMessage()]
                        );

                        throw $exception;
                    }
            }
            «IF !targets('2.0') && hasHookSubscribers»

                // remove obsolete persisted hooks from the database
                //$this->hookApi->uninstallSubscriberHooks($this->bundle->getMetaData());
            «ENDIF»
        */

            // update successful
            return true;
        }
    '''

    def private funcDelete(Application it) '''
        public function uninstall()«IF targets('3.0')»: bool«ENDIF»
        {
            «IF !targets('3.0')»
                $logger = $this->container->get('logger');

            «ENDIF»
            try {
                $this->schemaTool->drop($this->entities);
            } catch (Exception $exception) {
                $this->addFlash('error', $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Doctrine Exception') . ': ' . $exception->getMessage());
                $«IF targets('3.0')»this->«ENDIF»logger->error(
                    '{app}: Could not remove the database tables during uninstallation. Error details: {errorMessage}.',
                    ['app' => '«appName»', 'errorMessage' => $exception->getMessage()]
                );

                throw $exception;
            }
            «IF !variables.empty»

                // remove all module vars
                $this->delVars();
            «ENDIF»
            «IF hasCategorisableEntities»

                // remove category registry entries
                «IF !targets('3.0')»
                    $registryRepository = $this->container->get('zikula_categories_module.category_registry_repository');
                «ENDIF»
                $registries = $«IF targets('3.0')»this->«ENDIF»registryRepository->findBy(['modname' => '«appName»']);
                foreach ($registries as $registry) {
                    $this->entityManager->remove($registry);
                }
                $this->entityManager->flush();
            «ENDIF»
            «IF hasUploads»

                // remind user about upload folders not being deleted
                $uploadPath = $this->«IF targets('3.0')»dataDirectory«ELSE»container->getParameter('datadir')«ENDIF» . '/«appName»/';
                $this->addFlash(
                    'status',
                    $this->«IF targets('3.0')»trans«ELSE»__f«ENDIF»(
                        'The upload directories at "%path%" can be removed manually.',
                        ['%path%' => $uploadPath]«IF targets('3.0') && !isSystemModule»,
                        'config'«ENDIF»
                    )
                );
            «ENDIF»

            // uninstallation successful
            return true;
        }
    '''

    def private funcListEntityClasses(Application it, String context) '''
        «IF 'import' == context»
            «FOR entity : getAllEntities»
                use «entity.entityClassName('', false)»;
                «IF entity.loggable»
                    use «entity.entityClassName('logEntry', false)»;
                «ENDIF»
                «IF entity.tree == EntityTreeType.CLOSURE»
                    use «entity.entityClassName('closure', false)»;
                «ENDIF»
                «IF entity.hasTranslatableFields»
                    use «entity.entityClassName('translation', false)»;
                «ENDIF»
                «IF entity.attributable»
                    use «entity.entityClassName('attribute', false)»;
                «ENDIF»
                «IF entity.categorisable»
                    use «entity.entityClassName('category', false)»;
                «ENDIF»
            «ENDFOR»
            «IF hasUiHooksProviders»
                use «vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Entity\\HookAssignmentEntity'»;
            «ENDIF»
        «ELSEIF 'usage' == context»
            «FOR entity : getAllEntities»
                «entity.entityClassUsage('')»,
                «IF entity.loggable»
                    «entity.entityClassUsage('logEntry')»,
                «ENDIF»
                «IF entity.tree == EntityTreeType.CLOSURE»
                    «entity.entityClassUsage('closure')»,
                «ENDIF»
                «IF entity.hasTranslatableFields»
                    «entity.entityClassUsage('translation')»,
                «ENDIF»
                «IF entity.attributable»
                    «entity.entityClassUsage('attribute')»,
                «ENDIF»
                «IF entity.categorisable»
                    «entity.entityClassUsage('category')»,
                «ENDIF»
            «ENDFOR»
            «IF hasUiHooksProviders»
                HookAssignmentEntity::class
            «ENDIF»
        «ENDIF»
    '''

    def private entityClassUsage(DataObject it, String suffix) '''
        «name.formatForCodeCapital + suffix.formatForCodeCapital + 'Entity::class'»'''

    def private installerImpl(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\Abstract«name.formatForCodeCapital»ModuleInstaller;

        /**
         * Installer implementation class.
         */
        class «name.formatForCodeCapital»ModuleInstaller extends Abstract«name.formatForCodeCapital»ModuleInstaller
        {
            // feel free to extend the installer here
        }
    '''
}
