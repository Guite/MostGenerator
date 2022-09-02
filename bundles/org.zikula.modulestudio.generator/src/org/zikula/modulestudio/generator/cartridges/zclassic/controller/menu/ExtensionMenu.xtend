package org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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

    def private extensionMenuBaseImpl(Application it) '''
        namespace «appNamespace»\Menu\Base;

        use EasyCorp\Bundle\EasyAdminBundle\Config\MenuItem;
        use function Symfony\Component\Translation\t;
        use Zikula\ThemeBundle\ExtensionMenu\ExtensionMenuInterface;
        «IF generateAccountApi»
            use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        use «appNamespace»\Helper\PermissionHelper;
        «IF needsApproval»
            use «appNamespace»\Helper\WorkflowHelper;
        «ENDIF»

        /**
         * This is the extension menu service base class.
         */
        abstract class AbstractExtensionMenu implements ExtensionMenuInterface
        {
            public function __construct(
                «IF generateAccountApi»
                    protected readonly CurrentUserApiInterface $currentUserApi,
                «ENDIF»
                protected readonly ControllerHelper $controllerHelper,
                protected readonly PermissionHelper $permissionHelper«IF needsApproval»,
                protected readonly WorkflowHelper $workflowHelper«ENDIF»«IF generateAccountApi»,
                protected readonly array $listViewConfig«ENDIF»
            ) {
            }

            public function get(string $context = ExtensionMenuInterface::CONTEXT_ADMIN): iterable
            {
                $contextArgs = ['api' => 'extensionMenu', 'action' => 'get'];
        
                $permLevel = ExtensionMenuInterface::CONTEXT_ADMIN === $context ? ACCESS_ADMIN : ACCESS_READ;

                if (ExtensionMenuInterface::CONTEXT_ACCOUNT === $context) {
                    «IF generateAccountApi»
                        if (!$this->currentUserApi->isLoggedIn()) {
                            return;
                        }
                        if (!$this->permissionHelper->hasPermission(ACCESS_OVERVIEW)) {
                            return;
                        }

                        «FOR entity : getAllEntities.filter[hasIndexAction && standardFields]»
                            if ($this->listViewConfig['link_own_«entity.nameMultiple.formatForSnakeCase»_on_account_page']) {
                                $objectType = '«entity.name.formatForCode»';
                                if ($this->permissionHelper->hasComponentPermission($objectType, ACCESS_READ)) {
                                    $routeParameters = ['own' => 1];
                                    «IF entity.ownerPermission»
                                        $showOnlyOwnEntries = $this->listViewConfig['«entity.name.formatForSnakeCase»_private_mode'];
                                        if (true === $showOnlyOwnEntries) {
                                            $routeParameters = [];
                                        }
                                    «ENDIF»
                                    yield MenuItem::linktoRoute(t('My «entity.nameMultiple.formatForDisplay»'), 'fas fa-list-alt', '«appName.formatForDB»_' . mb_strtolower($objectType) . '_index', $routeParameters);
                                }
                            }

                        «ENDFOR»
                        if ($this->permissionHelper->hasPermission(ACCESS_ADMIN)) {
                            yield MenuItem::linktoRoute(t('«name.formatForDisplayCapital» Backend'), 'fas fa-wrench', '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»');
                        }

                    «ENDIF»
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

        «FOR entity : getAllEntities.filter[hasIndexAction]»
            «entity.menuEntryForCrud»
        «ENDFOR»
        «IF needsApproval»

            if ($isAdmin) {
                $moderationEntries = $this->workflowHelper->collectAmountOfModerationItems()
                foreach ($entry as $moderationEntries) {
                    yield MenuItem::linktoRoute($entry['title'], null, '«appName.formatForDB»_' . mb_strtolower($entry['objectType'] . '_index', ['workflowState' => $entry['state']])
                        ->setBadge($entry['amount'], 'primary');
            }
        «ENDIF»
    '''

    def private menuEntryForCrud(Entity it) '''
        if ($this->permissionHelper->hasComponentPermission('«name.formatForCode»', $permLevel)) {
            yield MenuItem::linktoRoute(t('«nameMultiple.formatForDisplayCapital»'), null, '«application.appName.formatForDB»_«name.formatForDB»_index'«/*IF tree != EntityTreeType.NONE», ['tpl' => 'tree']«ENDIF*/»);
        }
    '''

    def private menuEntriesBetweenControllers(Application it) '''
        if ($isAdmin) {
            if ($this->permissionHelper->hasPermission(ACCESS_READ)) {
                yield MenuItem::linktoRoute(t('Frontend'), 'fas fa-home', '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_«getLeadingEntity.getPrimaryAction»');
            }
        } else {
            if ($this->permissionHelper->hasPermission(ACCESS_ADMIN)) {
                yield MenuItem::linktoRoute(t('Backend'), 'fas fa-wrench', '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»');
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
