package org.zikula.modulestudio.generator.cartridges.zclassic.controller.di

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions
import de.guite.modulestudio.metamodel.UserField

class DependencyInjection {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        val extensionFileName = vendor.formatForCodeCapital + name.formatForCodeCapital + 'Extension.php'
        fsa.generateClassPair('DependencyInjection/' + extensionFileName, extensionBaseImpl, extensionImpl)
    }

    def private extensionBaseImpl(Application it) '''
        namespace «appNamespace»\DependencyInjection\Base;

        use Symfony\Component\Config\FileLocator;
        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Symfony\Component\DependencyInjection\Loader\YamlFileLoader;
        use Symfony\Component\HttpKernel\DependencyInjection\Extension;
        use «appNamespace»\DependencyInjection\Configuration;
        «IF needsConfig»
            «IF hasGeographical»
                use «appNamespace»\Entity\Factory\EntityInitializer;
            «ENDIF»
            «IF hasLoggable»
                use «appNamespace»\EventListener\EntityLifecycleListener;
            «ENDIF»
            use «appNamespace»\EventListener\UserListener;
            «IF hasTranslatable || needsApproval || hasStandardFieldEntities»
                «FOR entity : getAllEntities.filter[hasEditAction]»
                    use «appNamespace»\Form\Handler\«entity.name.formatForCodeCapital»\EditHandler as Edit«entity.name.formatForCodeCapital»Handler;
                «ENDFOR»
            «ENDIF»
            use «appNamespace»\Helper\CollectionFilterHelper;
            «IF hasIndexActions»
                use «appNamespace»\Helper\ControllerHelper;
            «ENDIF»
            «IF hasAutomaticExpiryHandling || hasLoggable»
                use «appNamespace»\Helper\ExpiryHelper;
            «ENDIF»
            «IF hasUploads»
                use «appNamespace»\Helper\ImageHelper;
            «ENDIF»
            «IF needsApproval»
                use «appNamespace»\Helper\NotificationHelper;
            «ENDIF»
            «IF hasLoggable»
                use «appNamespace»\Helper\PermissionHelper;
            «ENDIF»
            «IF hasUploads»
                use «appNamespace»\Helper\UploadHelper;
            «ENDIF»
            «IF hasGeographical»
                use «appNamespace»\Helper\ViewHelper;
            «ENDIF»
            «IF generateAccountApi»
                use «appNamespace»\Menu\ExtensionMenu;
            «ENDIF»
            «IF hasIndexActions»
                use «appNamespace»\Menu\MenuBuilder;
            «ENDIF»
        «ENDIF»

        /**
         * DependencyInjection extension base class.
         */
        abstract class Abstract«vendor.formatForCodeCapital»«name.formatForCodeCapital»Extension extends Extension
        {
            public function load(array $configs, ContainerBuilder $container)
            {
                $loader = new YamlFileLoader($container, new FileLocator(__DIR__ . '/../../Resources/config'));
                $loader->load('services.yaml');
                «IF needsConfig»

                    $configuration = new Configuration();
                    $config = $this->processConfiguration($configuration, $configs);

                    «IF hasGeographical»
                        $container->getDefinition(EntityInitializer::class)
                            ->setArgument('$defaultLatitude', $config['geo']['default_latitude'])
                            ->setArgument('$defaultLongitude', $config['geo']['default_longitude']);
                    «ENDIF»
                    «IF hasLoggable»
                        $container->getDefinition(EntityLifecycleListener::class)
                            ->setArgument('$loggableConfig', $config['versioning']);
                    «ENDIF»
                    «IF hasUserVariables»
                        $container->getDefinition(UserListener::class)
                            «FOR userVar : getAllVariables.filter(UserField)»
                                ->setArgument('$«userVar.name.formatForCode»', $config['«userVar.varContainer.name.formatForSnakeCase»']['«userVar.name.formatForSnakeCase»'])
                            «ENDFOR»
                        ;
                    «ENDIF»
                    «IF hasTranslatable || needsApproval || hasStandardFieldEntities»
                        «FOR entity : getAllEntities.filter[hasEditAction]»
                            $container->getDefinition(Edit«entity.name.formatForCodeCapital»Handler::class)
                                ->setArgument('$moderationConfig', $config['moderation']);
                        «ENDFOR»
                    «ENDIF»
                    $container->getDefinition(CollectionFilterHelper::class)
                        ->setArgument('$listViewConfig', $config['list_views']);
                    «IF hasIndexActions»
                        $container->getDefinition(ControllerHelper::class)
                            ->setArgument('$listViewConfig', $config['list_views']);
                    «ENDIF»
                    «IF hasAutomaticExpiryHandling || hasLoggable»
                        $container->getDefinition(ExpiryHelper::class)
                            ->setArgument('$loggableConfig', $config['versioning']);
                    «ENDIF»
                    «IF hasUploads»
                        $container->getDefinition(ImageHelper::class)
                            ->setArgument('$imageConfig', $config['images']);
                    «ENDIF»
                    «IF hasLoggable»
                        $container->getDefinition(PermissionHelper::class)
                            ->setArgument('$loggableConfig', $config['versioning']);
                    «ENDIF»
                    «IF needsApproval»
                        $container->getDefinition(NotificationHelper::class)
                            ->setArgument('$moderationConfig', $config['moderation']);
                    «ENDIF»
                    «IF hasUploads»
                        $container->getDefinition(UploadHelper::class)
                            ->setArgument('$imageConfig', $config['images']);
                    «ENDIF»
                    «IF hasGeographical»
                        $container->getDefinition(ViewHelper::class)
                            ->setArgument('$geoConfig', $config['geo']);
                    «ENDIF»
                    «IF generateAccountApi»
                        $container->getDefinition(ExtensionMenu::class)
                            ->setArgument('$listViewConfig', $config['list_views']);
                    «ENDIF»
                    «IF hasIndexActions»
                        $container->getDefinition(MenuBuilder::class)
                            ->setArgument('$listViewConfig', $config['list_views']);
                    «ENDIF»
                «ENDIF»
            }
        }
    '''

    def private extensionImpl(Application it) '''
        namespace «appNamespace»\DependencyInjection;

        use «appNamespace»\DependencyInjection\Base\Abstract«vendor.formatForCodeCapital»«name.formatForCodeCapital»Extension;

        /**
         * DependencyInjection extension implementation class.
         */
        class «vendor.formatForCodeCapital»«name.formatForCodeCapital»Extension extends Abstract«vendor.formatForCodeCapital»«name.formatForCodeCapital»Extension
        {
            // custom enhancements can go here
        }
    '''
}
