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

        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\Core\Controller\AbstractController;
        use «appNamespace»\Form\Type\ConfigType;

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
        public function configAction(Request $request)
        {
            «IF isBase»
                «configBaseImpl»
            «ELSE»
                return parent::configAction($request);
            «ENDIF»
        }
    '''

    def private configDocBlock(Application it, Boolean isBase) '''
        /**
         «IF isBase»
         * This method takes care of the application configuration.
         *
         * @param Request $request Current request instance
         *
         * @return Response Output
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @inheritDoc
         * @Route("/config",
         *        methods = {"GET", "POST"}
         * )
         * @Theme("admin")
         «ENDIF»
         */
    '''

    def private configBaseImpl(Application it) '''
        if (!$this->get('«appService».permission_helper')->hasPermission(ACCESS_ADMIN)) {
            throw new AccessDeniedException();
        }

        $form = $this->createForm(ConfigType::class, $this->get('«appService».app_settings'));

        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            if ($form->get('save')->isClicked()) {
                $appSettings = $form->getData();
                $appSettings->save();

                $this->addFlash('status', $this->__('Done! Module configuration updated.'));
                $userName = $this->get('zikula_users_module.current_user')->get('uname');
                $this->get('logger')->notice('{app}: User {user} updated the configuration.', ['app' => '«appName»', 'user' => $userName]);
            } elseif ($form->get('cancel')->isClicked()) {
                $this->addFlash('status', $this->__('Operation cancelled.'));
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

        use «appNamespace»\Controller\Base\AbstractConfigController;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Routing\Annotation\Route;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\ThemeModule\Engine\Annotation\Theme;

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
