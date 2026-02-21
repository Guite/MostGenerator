package org.zikula.modulestudio.generator.cartridges.symfony.controller.menu

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

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
            appNamespace + '\\Helper\\ControllerHelper'
        ])
        for (entity : entities.filter[hasIndexAction]) {
            imports.add(appNamespace + '\\Controller\\Crud\\' + entity.name.formatForCodeCapital + 'Controller')
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
                «IF needsApproval»
                    protected readonly WorkflowHelper $workflowHelper,
                «ENDIF»
                protected readonly array $listViewConfig,
            ) {
            }

            public function get(string $context = ExtensionMenuInterface::CONTEXT_ADMIN): iterable
            {
                if (ExtensionMenuInterface::CONTEXT_ACCOUNT === $context) {
                    if (null === $this->security->getUser()) {
                        return;
                    }

                    «FOR entity : entities.filter[hasIndexAction && standardFields]»
                        if ($this->listViewConfig['link_own_«entity.nameMultiple.formatForSnakeCase»_on_account_page']) {
                            $own«entity.nameMultiple.formatForCodeCapital»Item = MenuItem::linkTo(«entity.name.formatForCodeCapital»Controller::class, t('My «entity.nameMultiple.formatForDisplay»'), 'fas fa-list-alt')
                            «IF !entity.ownerPermission»
                                ->setQueryParameter('own', '1')
                            «ENDIF»
                                ->setPermission('ROLE_USER');
                            «IF entity.ownerPermission»
                                $showOnlyOwnEntries = $this->listViewConfig['«entity.name.formatForSnakeCase»_private_mode'];
                                if (true !== $showOnlyOwnEntries) {
                                    $own«entity.nameMultiple.formatForCodeCapital»Item->setQueryParameter('own', '1');
                                }
                            «ENDIF»
                            yield 'My «entity.nameMultiple.formatForDisplay»' => $own«entity.nameMultiple.formatForCodeCapital»Item;
                        }

                    «ENDFOR»
                    yield 'backend' => MenuItem::linkToRoute(t('«name.formatForDisplayCapital» Backend'), 'fas fa-wrench', 'admin_«getLeadingEntity.route(getLeadingEntity.getPrimaryAction)»')
                        ->setPermission('ADMIN');
                }

                $isAdmin = ExtensionMenuInterface::CONTEXT_ADMIN === $context;
                $permissionAttribute = $isAdmin ? 'ROLE_ADMIN' : 'ROLE_USER';
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
                    $controllerClass = match ($objectType) {
                        «FOR entity : getEntitiesForWorkflow(true)»
                            '«entity.name.formatForCode»' => «entity.name.formatForCodeCapital»Controller::class,
                        «ENDFOR»
                        default => throw new \RuntimeException('Invalid object type.')
                    };
                    yield $objectType . ucfirst($entry['state']) => 
                        MenuItem::linkTo($controllerClass, $entry['title'], 'fa fa-user-magnifying-class')
                            ->setQueryParameter('filters[workflowState][comparison]', ComparisonType::EQ)
                            ->setQueryParameter('filters[workflowState][value]', $entry['state'])
                            ->setBadge($entry['amount'], 'primary')
                            ->setPermission('ROLE_EDITOR')
                    ;
                }
            }
        «ENDIF»
    '''

    def private menuEntryForCrud(Entity it) '''
        yield '«name.formatForCode»' => MenuItem::linkto(«name.formatForCodeCapital»Controller::class, t('«nameMultiple.formatForDisplayCapital»'), 'fa fa-square')
            ->setPermission($permissionAttribute);
    '''

    def private menuEntriesBetweenControllers(Application it) '''
        if ($isAdmin) {
            yield 'frontend' => MenuItem::linktoRoute(t('Frontend'), 'fas fa-home', 'user_«getLeadingEntity.route(getLeadingEntity.getPrimaryAction)»')
                ->setPermission('ROLE_USER');
        } else {
            yield 'backend' => MenuItem::linktoRoute(t('Backend'), 'fas fa-wrench', 'admin_«getLeadingEntity.route(getLeadingEntity.getPrimaryAction)»')
                ->setPermission('ROLE_ADMIN');
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
