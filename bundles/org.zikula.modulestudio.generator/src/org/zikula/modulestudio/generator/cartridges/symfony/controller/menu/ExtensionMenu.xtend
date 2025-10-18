package org.zikula.modulestudio.generator.cartridges.symfony.controller.menu

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions
import org.zikula.modulestudio.generator.application.ImportList

class ExtensionMenu {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating extension menu class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Menu/ExtensionMenu.php', extensionMenuBaseImpl, extensionMenuImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Bundle\\SecurityBundle\\Security',
            'EasyCorp\\Bundle\\EasyAdminBundle\\Config\\MenuItem',
            'function Symfony\\Component\\Translation\\t',
            'Zikula\\ThemeBundle\\ExtensionMenu\\ExtensionMenuInterface',
            appNamespace + '\\Helper\\ControllerHelper',
            appNamespace + '\\Helper\\PermissionHelper'
        ])
        for (entity : entities.filter[hasIndexAction]) {
            imports.add(appNamespace + '\\Entity\\' + entity.name.formatForCodeCapital)
        }
        if (needsApproval) {
            imports.add(appNamespace + '\\Helper\\WorkflowHelper')
            imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Form\\Type\\ComparisonType')
        }
        imports
    }

    def private extensionMenuBaseImpl(Application it) '''
        namespace «appNamespace»\Menu\Base;

        «collectBaseImports.print»

        /**
         * This is the extension menu service base class.
         */
        abstract class AbstractExtensionMenu implements ExtensionMenuInterface
        {
            public function __construct(
                protected readonly Security $security,
                protected readonly ControllerHelper $controllerHelper,
                protected readonly PermissionHelper $permissionHelper«IF needsApproval»,
                protected readonly WorkflowHelper $workflowHelper«ENDIF»,
                protected readonly array $listViewConfig
            ) {
            }

            public function get(string $context = ExtensionMenuInterface::CONTEXT_ADMIN): iterable
            {
                $contextArgs = ['api' => 'extensionMenu', 'action' => 'get'];
        
                // $permLevel = ExtensionMenuInterface::CONTEXT_ADMIN === $context ? ACCESS_ADMIN : ACCESS_READ;

                if (ExtensionMenuInterface::CONTEXT_ACCOUNT === $context) {
                    if (null === $this->security->getUser()) {
                        return;
                    }
                    if (!$this->permissionHelper->hasPermission(/*ACCESS_OVERVIEW*/)) {
                        return;
                    }

                    «FOR entity : entities.filter[hasIndexAction && standardFields]»
                        if ($this->listViewConfig['link_own_«entity.nameMultiple.formatForSnakeCase»_on_account_page']) {
                            $objectType = '«entity.name.formatForCode»';
                            if ($this->permissionHelper->hasComponentPermission($objectType/*, ACCESS_READ*/)) {
                                $routeParameters = ['own' => 1];
                                «IF entity.ownerPermission»
                                    $showOnlyOwnEntries = $this->listViewConfig['«entity.name.formatForSnakeCase»_private_mode'];
                                    if (true === $showOnlyOwnEntries) {
                                        $routeParameters = [];
                                    }
                                «ENDIF»
                                yield 'My «entity.nameMultiple.formatForDisplay»' => MenuItem::linktoRoute(t('My «entity.nameMultiple.formatForDisplay»'), 'fas fa-list-alt', '«appName.formatForDB»_' . mb_strtolower($objectType) . '_index', $routeParameters);
                            }
                        }

                    «ENDFOR»
                    if ($this->permissionHelper->hasPermission(/*ACCESS_ADMIN*/)) {
                        yield 'backend' => MenuItem::linktoRoute(t('«name.formatForDisplayCapital» Backend'), 'fas fa-wrench', '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»');
                    }
                }

                $isAdmin = ExtensionMenuInterface::CONTEXT_ADMIN === $context;
                «menuEntries»
            }

            public function getBundleName(): string
            {
                return '«appName»';
            }
        }
    '''

    def menuEntries(Application it) '''
        «menuEntriesBetweenControllers»

        «FOR entity : entities.filter[hasIndexAction]»
            «entity.menuEntryForCrud»
        «ENDFOR»
        «IF needsApproval»

            if ($isAdmin) {
                $moderationEntries = $this->workflowHelper->collectAmountOfModerationItems();
                foreach ($moderationEntries as $entry) {
                    $objectType = $entry['objectType'];
                    if ($this->permissionHelper->hasComponentPermission($objectType/*, $permLevel*/)) {
                        $entityClass = match ($objectType) {
                            «FOR entity : getEntitiesForWorkflow(true)»
                                '«entity.name.formatForCode»' => «entity.name.formatForCodeCapital»::class,
                            «ENDFOR»
                            default => throw new \RuntimeException('Invalid object type.')
                        };
                        yield $objectType . ucfirst($entry['state']) => 
                            MenuItem::linkToCrud($entry['title'], 'fa fa-user-magnifying-class', $entityClass)
                                ->setQueryParameter('filters[workflowState][comparison]', ComparisonType::EQ)
                                ->setQueryParameter('filters[workflowState][value]', $entry['state'])
                                ->setBadge($entry['amount'], 'primary')
                        ;
                    }
                }
            }
        «ENDIF»
    '''

    def private menuEntryForCrud(Entity it) '''
        if ($this->permissionHelper->hasComponentPermission('«name.formatForCode»'/*, $permLevel*/)) {
            yield '«name.formatForCode»' => MenuItem::linktoCrud(t('«nameMultiple.formatForDisplayCapital»'), 'fa fa-square', «name.formatForCodeCapital»::class);
        }
    '''

    def private menuEntriesBetweenControllers(Application it) '''
        if ($isAdmin) {
            if ($this->permissionHelper->hasPermission(/*ACCESS_READ*/)) {
                yield 'frontend' => MenuItem::linktoRoute(t('Frontend'), 'fas fa-home', '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_«getLeadingEntity.getPrimaryAction»');
            }
        } else {
            if ($this->permissionHelper->hasPermission(/*ACCESS_ADMIN*/)) {
                yield 'backend' => MenuItem::linktoRoute(t('Backend'), 'fas fa-wrench', '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»');
            }
        }
    '''

    def private extensionMenuImpl(Application it) '''
        namespace «appNamespace»\Menu;

        use «appNamespace»\Menu\Base\AbstractExtensionMenu;

        /**
         * This is the extension menu service implementation class.
         */
        class ExtensionMenu extends AbstractExtensionMenu
        {
            // feel free to add own extensions here
        }
    '''
}
