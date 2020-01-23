package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigController {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating config controller class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Controller/ConfigController.php', configControllerBaseClass, configControllerImpl)
    }

    def private configControllerBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        «IF targets('3.0')»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «IF targets('3.0')»
            use Zikula\Bundle\CoreBundle\Controller\AbstractController;
        «ELSE»
            use Zikula\Core\Controller\AbstractController;
        «ENDIF»
        «IF targets('3.0')»
            use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
            use «appNamespace»\AppSettings;
        «ENDIF»
        use «appNamespace»\Form\Type\ConfigType;
        «IF targets('3.0')»
            use «appNamespace»\Helper\PermissionHelper;
        «ENDIF»

        /**
         * Config controller base class.
         */
        abstract class AbstractConfigController extends AbstractController
        {
            «configAction(true)»
        }
    '''

    def private configAction(Application it, Boolean isBase) '''
        «configDocBlock(isBase)»
        «IF targets('3.0')»
            public function configAction(
                Request $request,
                PermissionHelper $permissionHelper,
                AppSettings $appSettings,
                LoggerInterface $logger,
                CurrentUserApiInterface $currentUserApi
            ): Response {
                «IF isBase»
                    «configBaseImpl»
                «ELSE»
                    return parent::configAction($request, $permissionHelper, $appSettings, $logger, $currentUserApi);
                «ENDIF»
            }
        «ELSE»
            public function configAction(Request $request)
            {
                «IF isBase»
                    «configBaseImpl»
                «ELSE»
                    return parent::configAction($request);
                «ENDIF»
            }
        «ENDIF»
    '''

    def private configDocBlock(Application it, Boolean isBase) '''
        /**
         «IF isBase»
         * This method takes care of the application configuration.
         *
         «IF !targets('3.0')»
         * @param Request $request
         *
         * @return Response Output
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @Route("/config",
         *        methods = {"GET", "POST"}
         * )
         * @Theme("admin")
         «ENDIF»
         */
    '''

    def private configBaseImpl(Application it) '''
        if (!«IF targets('3.0')»$permissionHelper«ELSE»$this->get('«appService».permission_helper')«ENDIF»->hasPermission(ACCESS_ADMIN)) {
            throw new AccessDeniedException();
        }

        $form = $this->createForm(ConfigType::class, «IF targets('3.0')»$appSettings«ELSE»$this->get('«appService».app_settings')«ENDIF»);
        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            if ($form->get('save')->isClicked()) {
                $appSettings = $form->getData();
                $appSettings->save();

                $this->addFlash('status', $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Done! Configuration updated.'«IF targets('3.0') && !isSystemModule», [], 'config'«ENDIF»));
                «IF targets('3.0')»
                    $userName = $currentUserApi->get('uname');
                    $logger->notice(
                        '{app}: User {user} updated the configuration.',
                        ['app' => 'ZikulaContentModule', 'user' => $userName]
                    );
                «ELSE»
                    $userName = $this->get('zikula_users_module.current_user')->get('uname');
                    $this->get('logger')->notice(
                        '{app}: User {user} updated the configuration.',
                        ['app' => '«appName»', 'user' => $userName]
                    );
                «ENDIF»
            } elseif ($form->get('cancel')->isClicked()) {
                $this->addFlash('status', «IF !targets('3.0')»$this->__(«ENDIF»'Operation cancelled.'«IF !targets('3.0')»)«ENDIF»);
            }

            // redirect to config page again (to show with GET request)
            return $this->redirectToRoute('«appName.formatForDB»_config_config');
        }

        $templateParameters = [
            'form' => $form->createView()
        ];

        // render the config form
        return $this->render('@«appName»/Config/config.html.twig', $templateParameters);
    '''

    def private configControllerImpl(Application it) '''
        namespace «appNamespace»\Controller;

        «IF targets('3.0')»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Routing\Annotation\Route;
        use Zikula\ThemeModule\Engine\Annotation\Theme;
        «IF targets('3.0')»
            use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
            use «appNamespace»\AppSettings;
        «ENDIF»
        use «appNamespace»\Controller\Base\AbstractConfigController;
        «IF targets('3.0')»
            use «appNamespace»\Helper\PermissionHelper;
        «ENDIF»

        /**
         * Config controller implementation class.
         *
         * @Route("/config")
         */
        class ConfigController extends AbstractConfigController
        {
            «configAction(false)»

            // feel free to add your own config controller methods here
        }
    '''
}
