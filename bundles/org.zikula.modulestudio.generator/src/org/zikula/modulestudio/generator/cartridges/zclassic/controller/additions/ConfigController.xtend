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
        use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
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
        public function config(
            Request $request,
            PermissionHelper $permissionHelper,
            AppSettings $appSettings,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi
        ): Response {
            «IF isBase»
                «configBaseImpl»
            «ELSE»
                return parent::config($request, $permissionHelper, $appSettings, $logger, $currentUserApi);
            «ENDIF»
        }
    '''

    def private configDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * This method takes care of the application configuration.
             *
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             */
        «ELSE»
            /**
             * @Theme("admin")
             */
            #[Route('', name: '«appName.formatForDB»_config_config', methods: ['GET', 'POST'])]
        «ENDIF»
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

                $this->addFlash('status', $this->trans('Done! Configuration updated.', [], 'config'));
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
        return $this->render('@«vendorAndName»/Config/config.html.twig', $templateParameters);
    '''

    def private configControllerImpl(Application it) '''
        namespace «appNamespace»\Controller;

        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Routing\Annotation\Route;
        use Zikula\ThemeBundle\Engine\Annotation\Theme;
        use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
        use «appNamespace»\AppSettings;
        use «appNamespace»\Controller\Base\AbstractConfigController;
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Config controller implementation class.
         */
        #[Route('/«name.formatForDB»/config')]
        class ConfigController extends AbstractConfigController
        {
            «configAction(false)»

            // feel free to add your own config controller methods here
        }
    '''
}
