package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.AuthMethodType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AuthenticationMethod {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (authenticationMethod == AuthMethodType.NONE) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'AuthenticationMethod/' + name.formatForCodeCapital + 'AuthenticationMethod.php',
            fh.phpFileContent(it, authMethodBaseClass), fh.phpFileContent(it, authMethodImpl)
        )
    }

    def private authMethodBaseClass(Application it) '''
        namespace «appNamespace»\AuthenticationMethod\Base;

        «IF authenticationMethod == AuthMethodType.REMOTE»
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        «IF authenticationMethod == AuthMethodType.REMOTE»
            use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
            use Symfony\Component\Routing\RouterInterface;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        use Zikula\UsersModule\AuthenticationMethodInterface\«IF authenticationMethod == AuthMethodType.LOCAL»Non«ENDIF»ReEntrantAuthenticationMethodInterface;
        use Zikula\ZAuthModule\Api\ApiInterface\PasswordApiInterface;
        use «appNamespace»\Entity\Factory\EntityFactory;

        /**
         * «name.formatForDisplayCapital» authentication method base class.
         */
        abstract class Abstract«name.formatForCodeCapital»AuthenticationMethod implements «IF authenticationMethod == AuthMethodType.LOCAL»Non«ENDIF»ReEntrantAuthenticationMethodInterface
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var SessionInterface
             */
            protected $session;
            «IF authenticationMethod == AuthMethodType.REMOTE»

                /**
                 * @var RequestStack
                 */
                protected $requestStack;

                /**
                 * @var RouterInterface
                 */
                protected $router;
            «ENDIF»

            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var VariableApiInterface
             */
            private $variableApi;

            /**
             * @var PasswordApiInterface
             */
            private $passwordApi;

            /**
             * «name.formatForCodeCapital»AuthenticationMethod constructor.
             *
             «IF authenticationMethod == AuthMethodType.REMOTE»
             * @param TranslatorInterface $translator   Translator service instance
             * @param SessionInterface    $session      Session service instance
             * @param RequestStack        $requestStack RequestStack service instance
             * @param RouterInterface     $router       Router service instance
             «ENDIF»
             * @param TranslatorInterface  $translator    Translator service instance
             * @param SessionInterface     $session       Session service instance
             * @param EntityFactory        $entityFactory EntityFactory service instance
             * @param VariableApiInterface $variableApi   VariableApi service instance
             * @param PasswordApiInterface $passwordApi   PasswordApi service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                SessionInterface $session,
                «IF authenticationMethod == AuthMethodType.REMOTE»
                    RequestStack $requestStack,
                    RouterInterface $router,
                «ENDIF»
                EntityFactory $entityFactory,
                VariableApiInterface $variableApi,
                PasswordApiInterface $passwordApi)
            {
                $this->translator = $translator;
                $this->session = $session;
                «IF authenticationMethod == AuthMethodType.REMOTE»
                    $this->requestStack = $requestStack;
                    $this->router = $router;
                «ENDIF»
                $this->entityFactory = $entityFactory;
                $this->variableApi = $variableApi;
                $this->passwordApi = $passwordApi;
            }

            «authMethodBaseImplCommon»

            «IF authenticationMethod == AuthMethodType.REMOTE»
                «authMethodBaseImplRemote»
            «ELSEIF authenticationMethod == AuthMethodType.LOCAL»
                «authMethodBaseImplLocal»
            «ENDIF»
        }
    '''

    def private authMethodBaseImplCommon(Application it) '''
        /**
         * @inheritDoc
         */
        public function getAlias()
        {
            return '«name.formatForDB»_authentication';
        }

        /**
         * @inheritDoc
         */
        public function getDisplayName()
        {
            return $this->translator->__('«name.formatForDisplayCapital»');
        }

        /**
         * @inheritDoc
         */
        public function getDescription()
        {
            return $this->translator->__('Allow a user to authenticate and login using the «name.formatForDisplay» module.');
        }

        /**
         * @inheritDoc
         */
        public function authenticate(array $data = [])
        {
            $this->session->getFlashBag()->add('error', $this->translator->__('Login for «name.formatForDisplay» authentication method is not implemented yet.'));

            return null;
        }

        /**
         * @inheritDoc
         */
        public function register(array $data = [])
        {
            $this->session->getFlashBag()->add('error', $this->translator->__('Registration for «name.formatForDisplay» authentication method is not implemented yet.'));

            return false;
        }
    '''

    def private authMethodBaseImplRemote(Application it) '''
        /**
         * @inheritDoc
         */
        public function getId()
        {
            return null;
        }

        /**
         * @inheritDoc
         */
        public function getEmail()
        {
            return null;
        }

        /**
         * @inheritDoc
         */
        public function getUname()
        {
            return null;
        }
    '''

    def private authMethodBaseImplLocal(Application it) '''
        /**
         * @inheritDoc
         */
        public function getLoginFormClassName()
        {
            return 'Zikula\ZAuthModule\Form\Type\UnameLoginType';
        }

        /**
         * @inheritDoc
         */
        public function getLoginTemplateName($type = 'page', $position = 'left')
        {
            if ($type == 'block') {
                if ($position == 'topnav') {
                    return 'ZikulaZAuthModule:Authentication:UnameLoginBlock.topnav.html.twig';
                }

                return 'ZikulaZAuthModule:Authentication:UnameLoginBlock.html.twig';
            }

            return 'ZikulaZAuthModule:Authentication:UnameLogin.html.twig';
        }

        /**
         * @inheritDoc
         */
        public function getRegistrationFormClassName()
        {
            return 'Zikula\ZAuthModule\Form\Type\RegistrationType';
        }

        /**
         * @inheritDoc
         */
        public function getRegistrationTemplateName()
        {
            return 'ZikulaZAuthModule:Authentication:register.html.twig';
        }
    '''

    def private authMethodImpl(Application it) '''
        namespace «appNamespace»\AuthenticationMethod;

        use «appNamespace»\AuthenticationMethod\Base\Abstract«name.formatForCodeCapital»AuthenticationMethod;

        /**
         * «name.formatForDisplayCapital» authentication method implementation class.
         */
        class «name.formatForCodeCapital»AuthenticationMethod extends Abstract«name.formatForCodeCapital»AuthenticationMethod
        {
            «authMethodImplCommon»

            «IF authenticationMethod == AuthMethodType.REMOTE»
                «authMethodImplRemote»
            «ELSEIF authenticationMethod == AuthMethodType.LOCAL»
                «authMethodImplLocal»
            «ENDIF»
        }
    '''

    def private authMethodImplCommon(Application it) '''
        /**
         * Authenticate the user from the provided data and return the associated native uid.
         *
         * @param array $data Authentication data
         *
         * @return integer|null
         *
         * @inheritDoc
         */
        public function authenticate(array $data = [])
        {
            // @todo replace by your own authentication logic
            return parent::authenticate($data);
        }

        /**
         * Register a new user from the provided data and map authorization to a Zikula UID.
         * MUST return boolean TRUE on success.
         *
         * @param array $data Authentication data
         *
         * @return boolean
         *
         * @inheritDoc
         */
        public function register(array $data = [])
        {
            // @todo replace by your own registration logic
            return parent::register($data);
        }
    '''

    def private authMethodImplRemote(Application it) '''
        /**
         * Return the ID of the user sent by the provider.
         *
         * @return string
         */
        public function getId()
        {
            // @todo replace by your own logic
            return parent::getId();
        }

        /**
         * After authentication, this method is used to update the user entity.
         *
         * @return string
         */
        public function getEmail()
        {
            // @todo replace by your own logic
            return parent::getEmail();
        }

        /**
         * After authentication, this method is used to update the user entity.
         *
         * @return string
         */
        public function getUname()
        {
            // @todo replace by your own logic
            return parent::getUname();
        }
    '''

    def private authMethodImplLocal(Application it) '''
        /**
         * Provide a FqCN for a Symfony form for login.
         *
         * @return string
         */
        public function getLoginFormClassName()
        {
            // @todo replace by your own form type
            return parent::getLoginFormClassName();
        }

        /**
         * Provide a path to the required template for login.
         *
         * @param string $type
         * @param string $position
         *
         * @return string
         */
        public function getLoginTemplateName($type = 'page', $position = 'left')
        {
            // @todo replace by your own template
            return parent::getLoginTemplateName($type, $position);
        }

        /**
         * Provide a FqCN for a Symfony form for registration.
         *
         * @return string
         */
        public function getRegistrationFormClassName()
        {
            // @todo replace by your own form type
            return parent::getRegistrationFormClassName();
        }

        /**
         * Provide a path to the required template for registration.
         *
         * @return string
         */
        public function getRegistrationTemplateName()
        {
            // @todo replace by your own template
            return parent::getRegistrationTemplateName();
        }
    '''
}
