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

        use Doctrine\Persistence\ManagerRegistry;
        use Exception;
        use Psr\Log\LoggerInterface;
        «IF hasUploads»
            use Symfony\Component\Filesystem\Filesystem;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\Bundle\CoreBundle\Doctrine\Helper\SchemaHelper;
        «IF hasUploads»
            use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
        «ENDIF»
        «IF hasCategorisableEntities»
            use Zikula\CategoriesModule\Api\CategoryPermissionApi;
            use Zikula\CategoriesModule\Entity\CategoryRegistryEntity;
            use Zikula\CategoriesModule\Entity\RepositoryInterface\CategoryRegistryRepositoryInterface;
            use Zikula\CategoriesModule\Entity\RepositoryInterface\CategoryRepositoryInterface;
        «ENDIF»
        use Zikula\ExtensionsModule\AbstractExtension;
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        use Zikula\ExtensionsModule\Installer\AbstractExtensionInstaller;
        «IF hasUploads || hasCategorisableEntities»
            use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
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
        protected array $entities = [
            «funcListEntityClasses('usage')»
        ];
    '''

    def private installerBaseImpl(Application it) '''
        public function __construct(
            AbstractExtension $extension,
            ManagerRegistry $managerRegistry,
            SchemaHelper $schemaTool,
            RequestStack $requestStack,
            TranslatorInterface $translator,
            VariableApiInterface $variableApi,
            protected LoggerInterface $logger«IF hasUploads»,
            protected ZikulaHttpKernelInterface $kernel«ENDIF»«IF hasUploads || hasCategorisableEntities»,
            protected CurrentUserApiInterface $currentUserApi«ENDIF»«IF hasCategorisableEntities»,
            protected CategoryRepositoryInterface $categoryRepository,
            protected CategoryRegistryRepositoryInterface $categoryRegistryRepository,
            protected CategoryPermissionApi $categoryPermissionApi«ENDIF»«IF hasUploads»,
            protected Filesystem $filesystem,
            protected string $dataDirectory«ENDIF»
        ) {
            parent::__construct($extension, $managerRegistry, $schemaTool, $requestStack, $translator, $variableApi);
        }

        «funcInit»

        «funcUpdate»

        «funcDelete»
    '''

    def private funcInit(Application it) '''
        public function install(): bool
        {
            «IF hasUploads || hasCategorisableEntities»
                $userName = $this->currentUserApi->get('uname');

            «ENDIF»
            «processUploadFolders»
            // create all tables from according entity definitions
            try {
                $this->schemaTool->create($this->entities);
            } catch (Exception $exception) {
                $this->addFlash('error', $this->trans('Doctrine Exception') . ': ' . $exception->getMessage());
                $this->logger->error(
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
                $categoryHelper = new \«appNamespace»\Helper\CategoryHelper(
                    $this->getTranslator(),
                    $this->requestStack,
                    $this->logger,
                    $this->currentUserApi,
                    $this->categoryRegistryRepository,
                    $this->categoryPermissionApi
                );
                $categoryGlobal = $this->categoryRepository->findOneBy(['name' => 'Global']);
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
                                $this->trans(
                                    'Error! Could not create a category registry for the %entity% entity. If you want to use categorisation, register at least one registry in the Categories administration.',
                                    ['%entity%' => '«entity.name.formatForDisplay»']
                                ) . ' ' . $exception->getMessage()
                            );
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
                $uploadHelper = new \«appNamespace»\Helper\UploadHelper(
                    $this->kernel,
                    $this->getTranslator(),
                    $this->filesystem,
                    $this->requestStack,
                    $this->logger,
                    $this->currentUserApi,
                    $this->getVariableApi(),
                    $this->dataDirectory
                );
                $uploadHelper->checkAndCreateAllUploadFolders();
            } catch (Exception $exception) {
                $this->addFlash('error', $exception->getMessage());
                $this->logger->error(
                    '{app}: User {user} could not create upload folders during installation. Error details: {errorMessage}.',
                    ['app' => '«appName»', 'user' => $userName, 'errorMessage' => $exception->getMessage()]
                );
            }
        «ENDIF»
    '''

    def private funcUpdate(Application it) '''
        public function upgrade(string $oldVersion): bool
        {
            /*
                // upgrade dependent on old version number
                switch ($oldVersion) {
                    case '1.0.0':
                        // do something
                        // ...
                        // update the database schema
                        try {
                            $this->schemaTool->update($this->entities);
                        } catch (Exception $exception) {
                            $this->addFlash('error', $this->trans('Doctrine Exception') . ': ' . $exception->getMessage());
                            $this->logger->error(
                                '{app}: Could not update the database tables during the upgrade.'
                                    . ' Error details: {errorMessage}.',
                                ['app' => '«appName»', 'errorMessage' => $exception->getMessage()]
                            );

                            throw $exception;
                        }
                }
            */

            // update successful
            return true;
        }
    '''

    def private funcDelete(Application it) '''
        public function uninstall(): bool
        {
            try {
                $this->schemaTool->drop($this->entities);
            } catch (Exception $exception) {
                $this->addFlash('error', $this->trans('Doctrine Exception') . ': ' . $exception->getMessage());
                $this->logger->error(
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
                $registries = $this->categoryRegistryRepository->findBy(['modname' => '«appName»']);
                foreach ($registries as $registry) {
                    $this->entityManager->remove($registry);
                }
                $this->entityManager->flush();
            «ENDIF»
            «IF hasUploads»

                // remind user about upload folders not being deleted
                $uploadPath = $this->dataDirectory . '/«appName»/';
                $this->addFlash(
                    'status',
                    $this->trans(
                        'The upload directories at "%path%" can be removed manually.',
                        ['%path%' => $uploadPath]«IF !isSystemModule»,
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
                «IF entity.categorisable»
                    use «entity.entityClassName('category', false)»;
                «ENDIF»
            «ENDFOR»
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
                «IF entity.categorisable»
                    «entity.entityClassUsage('category')»,
                «ENDIF»
            «ENDFOR»
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
