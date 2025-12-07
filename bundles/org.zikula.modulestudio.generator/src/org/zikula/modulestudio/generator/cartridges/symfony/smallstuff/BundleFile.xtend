package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions
import org.zikula.modulestudio.generator.application.config.AppConfig

class BundleFile {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    AppConfig config
    Boolean needsInitializer = false

    def generate(Application it, IMostFileSystemAccess fsa, AppConfig config) {
        this.config = config
        needsInitializer = if (hasUploads) true else false
        fsa.generateClassPair(appName + '.php', bundleBaseClass, bundleImpl)
    }

    def private bundleBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        «moduleBaseImpl»
    '''

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Component\\HttpKernel\\Bundle\\AbstractBundle',
            'Zikula\\CoreBundle\\Bundle\\MetaData\\BundleMetaDataInterface',
            'Zikula\\CoreBundle\\Bundle\\MetaData\\MetaDataAwareBundleInterface',
            appNamespace + '\\Bundle\\MetaData\\' + appName + 'MetaData'
        ])
        if (needsInitializer) {
            imports.addAll(#[
                'Zikula\\CoreBundle\\Bundle\\Initializer\\BundleInitializerInterface',
                'Zikula\\CoreBundle\\Bundle\\Initializer\\InitializableBundleInterface',
                appNamespace + '\\Bundle\\Initializer\\' + appName + 'Initializer'
            ])
        }

        imports.addAll(#[
            'Symfony\\Component\\Config\\Definition\\Configurator\\DefinitionConfigurator',
            'Symfony\\Component\\DependencyInjection\\ContainerBuilder',
            'Symfony\\Component\\DependencyInjection\\Loader\\Configurator\\ContainerConfigurator'
        ])
        if (hasUploads) {
            imports.add('Vich\\UploaderBundle\\Naming\\SmartUniqueNamer')
        }
        if (!config.relevant) {
            return imports
        }
        imports.add(appNamespace + '\\Helper\\CollectionFilterHelper')
        if (hasGeographical) {
            imports.add(appNamespace + '\\Entity\\Initializer\\EntityInitializer')
        }
        if (hasLoggable) {
            imports.add(appNamespace + '\\EventListener\\EntityLifecycleListener')
        }
        if (hasTranslatable || needsApproval || hasStandardFieldEntities) {
            for (entity : entities.filter[hasEditAction]) {
                imports.add(appNamespace + '\\Form\\Handler\\' + entity.name.formatForCodeCapital + '\\EditHandler as Edit' + entity.name.formatForCodeCapital + 'Handler')
            }
        }
        if (hasIndexActions) {
            imports.add(appNamespace + '\\Helper\\ControllerHelper')
        }
        if (hasAutomaticExpiryHandling || hasLoggable) {
            imports.add(appNamespace + '\\Helper\\ExpiryHelper')
        }
        if (needsApproval) {
            imports.add(appNamespace + '\\Helper\\NotificationHelper')
        }
        if (hasLoggable) {
            imports.add(appNamespace + '\\Helper\\PermissionHelper')
        }
        if (hasUploads) {
            imports.add(appNamespace + '\\Helper\\UploadHelper')
        }
        if (hasGeographical) {
            imports.add(appNamespace + '\\Helper\\ViewHelper')
        }
        imports.add(appNamespace + '\\Menu\\ExtensionMenu')
        if (hasIndexActions) {
            imports.add(appNamespace + '\\Menu\\MenuBuilder')
        }
        imports
    }

    def private moduleBaseImpl(Application it) '''
        «collectBaseImports.print»

        /**
         * Bundle base class.
         */
        abstract class Abstract«appName» extends AbstractBundle implements «IF needsInitializer»InitializableBundleInterface, «ENDIF»MetaDataAwareBundleInterface
        {
            «/* not needed atm
            «IF hasUploads»
                private ?ContainerBuilder $mainBuilder = null;

            «ENDIF*/»
            public function getMetaData(): BundleMetaDataInterface
            {
                return $this->container->get(«appName»MetaData::class);
            }
            «IF needsInitializer»

                public function getInitializer(): BundleInitializerInterface
                {
                    return $this->container->get(«appName»Initializer::class);
                }
            «ENDIF»
            «IF config.relevant»

                «configure»
            «ENDIF»

            «loadExtension»
            «IF hasUploads»

                «prependExtension»
            «ENDIF»
        }
    '''

    def private configure(Application it) '''
        public function configure(DefinitionConfigurator $definition): void
        {
            $definition->import('../config/definition.php');
        }
    '''

    def private loadExtension(Application it) '''
        public function loadExtension(array $config, ContainerConfigurator $container, ContainerBuilder $builder): void
        {
            $container->import('../config/services.yaml');
            «IF config.relevant»

                «configureServices»
            «ENDIF»
            «/* not needed atm
            «IF hasUploads»

                «configureUploadMappingsWithOwnConfig»
            «ENDIF*/»
        }
    '''

    def private configureServices(Application it) '''
        // configure services
        $services = $container->services();

        «IF hasGeographical»
            $services->get(EntityInitializer::class)
                ->arg('$defaultLatitude', (float) $config['geo']['default_latitude'])
                ->arg('$defaultLongitude', (float) $config['geo']['default_longitude']);
        «ENDIF»
        «IF hasLoggable»
            $services->get(EntityLifecycleListener::class)
                ->arg('$loggableConfig', $config['versioning']);
        «ENDIF»
        «IF hasTranslatable || needsApproval || hasStandardFieldEntities»
            «FOR entity : entities.filter[hasEditAction]»
                $services->get(Edit«entity.name.formatForCodeCapital»Handler::class)
                    ->arg('$moderationConfig', $config['moderation']);
            «ENDFOR»
        «ENDIF»
        $services->get(CollectionFilterHelper::class)
            ->arg('$listViewConfig', $config['list_views']);
        «IF hasIndexActions»
            $services->get(ControllerHelper::class)
                ->arg('$listViewConfig', $config['list_views']);
        «ENDIF»
        «IF hasAutomaticExpiryHandling || hasLoggable»
            $services->get(ExpiryHelper::class)
                ->arg('$loggableConfig', $config['versioning']);
        «ENDIF»
        «IF hasLoggable»
            $services->get(PermissionHelper::class)
                ->arg('$loggableConfig', $config['versioning']);
        «ENDIF»
        «IF needsApproval»
            $services->get(NotificationHelper::class)
                ->arg('$moderationConfig', $config['moderation']);
        «ENDIF»
        «IF hasUploads»
            $services->get(UploadHelper::class)
                ->arg('$imageConfig', $config['images']);
        «ENDIF»
        «IF hasGeographical»
            $services->get(ViewHelper::class)
                ->arg('$geoConfig', $config['geo']);
        «ENDIF»
        $services->get(ExtensionMenu::class)
            ->arg('$listViewConfig', $config['list_views']);
        «IF hasIndexActions»
            $services->get(MenuBuilder::class)
                ->arg('$listViewConfig', $config['list_views']);
        «ENDIF»
    '''

    def private prependExtension(Application it) '''
        public function prependExtension(ContainerConfigurator $container, ContainerBuilder $builder): void
        {
            «IF hasUploads»
                «configureDefaultUploadMappings»
            «ENDIF»
        }
    '''

    def private configureDefaultUploadMappings(Application it) '''
        «/* not needed atm
        // inject defaults before own app config
        // save *main* builder to reuse it in loadExtension()
        // @see https://github.com/symfony/symfony/discussions/57951
        $this->mainBuilder = $builder;
        */»// hard defaults (app can override later)
        $uploadBase = '%kernel.project_dir%/public';
        $uploadPath = '/uploads/«appName»/';

        $builder->prependExtensionConfig('vich_uploader', [
            'mappings' => [
                «FOR field : getAllUploadFields»
                    «vichUploaderMapping(field)»
                «ENDFOR»
            ],
        ]);
    '''

    /*def private configureUploadMappingsWithOwnConfig(Application it) '''
        // ⚠️ IMPORTANT to modify VichUploader config this late,
        // we need to use $this->mainBuilder from prependExtension()
        if ($this->mainBuilder instanceof ContainerBuilder) {
            // for example: add something depending on own bundle config
            $uploadBase = $config['upload_base'] ?? '%kernel.project_dir%/public';
            $uploadPath = '/uploads/«appName»/';
            $namer = 'Vich\\UploaderBundle\\Naming\\SmartUniqueNamer';
            $this->mainBuilder->prependExtensionConfig('vich_uploader', [
                'mappings' => [
                    «FOR field : getAllUploadFields»
                        «vichUploaderMapping(field)»
                    «ENDFOR»
                ],
            ]);
        }
    '''*/

    // https://github.com/dustin10/VichUploaderBundle/blob/master/docs/index.md
    def private vichUploaderMapping(Application app, UploadField it) '''
        '«mappingName»' => [
            'uri_prefix' => $uploadPath . '«mappingPath»',
            'upload_destination' => $uploadBase . $uploadPath . '«mappingPath»',
            'namer' => SmartUniqueNamer::class,
        ],
    '''

    def private bundleImpl(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\Abstract«appName»;

        /**
         * Bundle implementation class.
         */
        class «appName» extends Abstract«appName»
        {
            // custom enhancements can go here
        }
    '''
}
