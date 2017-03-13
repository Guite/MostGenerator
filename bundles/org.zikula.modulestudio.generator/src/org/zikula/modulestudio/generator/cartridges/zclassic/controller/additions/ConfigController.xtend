package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigController {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Config controller class')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Controller/ConfigController.php',
            fh.phpFileContent(it, configControllerBaseClass), fh.phpFileContent(it, configControllerImpl)
        )
    }

    def private configControllerBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\Core\Controller\AbstractController;
        «IF targets('1.4-dev')»
            use «appNamespace»\Form\AppSettingsType;
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
         * This method takes care of the application configuration.
         «IF !isBase»
         *
         * @Route("/config",
         *        methods = {"GET", "POST"}
         * )
         * @Theme("admin")
         «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return string Output
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         */
    '''

    def private configBaseImpl(Application it) '''
        if (!$this->hasPermission($this->name . '::', '::', ACCESS_ADMIN)) {
            throw new AccessDeniedException();
        }

        $form = $this->createForm(«IF targets('1.4-dev')»AppSettingsType::class«ELSE»'«appNamespace»\Form\AppSettingsType'«ENDIF»);

        if ($form->handleRequest($request)->isValid()) {
            if ($form->get('save')->isClicked()) {
                «IF hasUserGroupSelectors»
                    $formData = $form->getData();
                    foreach (['«getUserGroupSelectors.map[name.formatForCode].join('\', \'')»'] as $groupFieldName) {
                        $formData[$groupFieldName] = is_object($formData[$groupFieldName]) ? $formData[$groupFieldName]->getGid() : $formData[$groupFieldName];
                    }
                    $this->setVars($formData);
                «ELSE»
                    $this->setVars($form->getData());
                «ENDIF»

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
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
        use Symfony\Component\HttpFoundation\Request;
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
