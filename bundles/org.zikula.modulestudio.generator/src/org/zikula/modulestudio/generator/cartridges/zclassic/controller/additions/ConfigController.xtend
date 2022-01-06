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

        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\Bundle\CoreBundle\Controller\AbstractController;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use «appNamespace»\AppSettings;
        use «appNamespace»\Form\Type\ConfigType;
        use «appNamespace»\Helper\PermissionHelper;

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
        public function config«IF !targets('3.1')»Action«ENDIF»(
            Request $request,
            PermissionHelper $permissionHelper,
            AppSettings $appSettings,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        ): Response {
            «IF isBase»
                «configBaseImpl»
            «ELSE»
                return parent::config«IF !targets('3.1')»Action«ENDIF»($request, $permissionHelper, $appSettings, $logger, $currentUserApi);
            «ENDIF»
        }
    '''

    def private configDocBlock(Application it, Boolean isBase) '''
        /**
         «IF isBase»
         * This method takes care of the application configuration.
         *
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
        if (!$permissionHelper->hasPermission(ACCESS_ADMIN)) {
            throw new AccessDeniedException();
        }

        $form = $this->createForm(ConfigType::class, $appSettings);
        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            if ($form->get('save')->isClicked()) {
                $appSettings = $form->getData();
                $appSettings->save();

                $this->addFlash('status', «IF isSystemModule»'Done! Configuration updated.'«ELSE»$this->trans('Done! Configuration updated.', [], 'config')«ENDIF»);
                $userName = $currentUserApi->get('uname');
                $logger->notice(
                    '{app}: User {user} updated the configuration.',
                    ['app' => '«appName»', 'user' => $userName]
                );
            } elseif ($form->get('cancel')->isClicked()) {
                $this->addFlash('status', 'Operation cancelled.');
            }

            // redirect to config page again (to show with GET request)
            return $this->redirectToRoute('«appName.formatForDB»_config_config');
        }

        $templateParameters = [
            'form' => $form->createView(),
        ];

        // render the config form
        return $this->render('@«appName»/Config/config.html.twig', $templateParameters);
    '''

    def private configControllerImpl(Application it) '''
        namespace «appNamespace»\Controller;

        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Routing\Annotation\Route;
        use Zikula\ThemeModule\Engine\Annotation\Theme;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use «appNamespace»\AppSettings;
        use «appNamespace»\Controller\Base\AbstractConfigController;
        use «appNamespace»\Helper\PermissionHelper;

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
