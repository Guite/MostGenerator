package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ArchiveHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Archive helper class for automatic archiving')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/ArchiveHelper.php',
            fh.phpFileContent(it, categoryHelperBaseClass), fh.phpFileContent(it, categoryHelperImpl)
        )
    }

    def private categoryHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use PageUtil;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\PermissionsModule\Api\PermissionApi;

        /**
         * Archive helper base class.
         */
        abstract class AbstractArchiveHelper
        {
            /**
             * @var ContainerBuilder
             */
            protected $container;

            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var SessionInterface
             */
            protected $session;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * @var PermissionApi
             */
            private $permissionApi;

            /**
             * @var WorkflowHelper
             */
            private $workflowHelper;
            «IF hasHookSubscribers»

                /**
                 * @var HookHelper
                 */
                private $hookHelper;
            «ENDIF»

            /**
             * ArchiveHelper constructor.
             *
             * @param ContainerBuilder    $container      ContainerBuilder service instance
             * @param TranslatorInterface $translator     Translator service instance
             * @param SessionInterface    $session        Session service instance
             * @param LoggerInterface     $logger         Logger service instance
             * @param PermissionApi       $permissionApi  PermissionApi service instance
             * @param WorkflowHelper      $workflowHelper WorkflowHelper service instance
             «IF hasHookSubscribers»
             * @param HookHelper          $hookHelper     HookHelper service instance
             «ENDIF»
             */
            public function __construct(
                ContainerBuilder $container,
                TranslatorInterface $translator,
                SessionInterface $session,
                LoggerInterface $logger,
                PermissionApi $permissionApi,
                WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
                HookHelper $hookHelper«ENDIF»)
            {
                $this->container = $container;
                $this->translator = $translator;
                $this->session = $session;
                $this->logger = $logger;
                $this->permissionApi = $permissionApi;
                $this->workflowHelper = $workflowHelper;
                «IF hasHookSubscribers»
                    $this->hookHelper = $hookHelper;
                «ENDIF»
            }

            «archiveHelperBaseImpl»
        }
    '''

    def private archiveHelperBaseImpl(Application it) '''
        /**
         * Moves obsolete data into the archive.
         */
        public function archiveObjects()
        {
            «/*$currentType = FormUtil::getPassedValue('type', 'user', 'GETPOST', FILTER_SANITIZE_STRING);
            $currentFunc = FormUtil::getPassedValue('func', 'index', 'GETPOST', FILTER_SANITIZE_STRING);
            if ($currentType == 'admin' || $currentFunc == 'edit' || $currentFunc == 'install') {
                return;
            }

            */»$randProbability = mt_rand(1, 1000);

            if ($randProbability < 750) {
                return;
            }

            if (!$this->container->has('«appService».entity_factory')) {
                return;
            }

            PageUtil::registerVar('«appName»AutomaticArchiving', false, true);
            $entityFactory = $this->container->get('«appService».entity_factory');
            «FOR entity : getArchivingEntities»

                // perform update for «entity.nameMultiple.formatForDisplay» becoming archived
                $logArgs = ['app' => '«appName»', 'entity' => '«entity.name.formatForCode»'];
                $this->logger->notice('{app}: Automatic archiving for the {entity} entity started.', $logArgs);
                $repository = $entityFactory->getRepository('«entity.name.formatForCode»');
                $repository->archiveObjects($this->permissionApi, $this->session, $this->translator, $this->workflowHelper«IF !entity.skipHookSubscribers», $this->hookHelper«ENDIF»);
                $this->logger->notice('{app}: Automatic archiving for the {entity} entity completed.', $logArgs);
            «ENDFOR»

            PageUtil::setVar('«appName»AutomaticArchiving', false);
        }
    '''

    def private categoryHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractArchiveHelper;

        /**
         * Archive helper implementation class.
         */
        class ArchiveHelper extends AbstractArchiveHelper
        {
            // feel free to extend the archive helper here
        }
    '''
}
