package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.AuthMethodType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AuthenticationMethod {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (authenticationMethod == AuthMethodType.NONE) {
            return
        }
        fsa.generateClassPair('AuthenticationMethod/' + name.formatForCodeCapital + 'AuthenticationMethod.php',
            authMethodBaseClass, authMethodImpl
        )
    }

    def private authMethodBaseClass(Application it) '''
        namespace «appNamespace»\AuthenticationMethod\Base;

        «IF authenticationMethod == AuthMethodType.REMOTE»
            use Symfony\Component\HttpFoundation\RequestStack;
            use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
            use Symfony\Component\Routing\RouterInterface;
        «ENDIF»
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
        «ENDIF»
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        use Zikula\UsersModule\AuthenticationMethodInterface\«IF authenticationMethod == AuthMethodType.LOCAL»Non«ENDIF»ReEntrantAuthenticationMethodInterface;
        use Zikula\ZAuthModule\Api\ApiInterface\PasswordApiInterface;
        «IF authenticationMethod == AuthMethodType.LOCAL»
            use Zikula\ZAuthModule\Form\Type\RegistrationType;
            use Zikula\ZAuthModule\Form\Type\UnameLoginType;
        «ENDIF»
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
             * @var RequestStack
             */
            protected $requestStack;
            «IF authenticationMethod == AuthMethodType.REMOTE»

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
            protected $variableApi;

            /**
             * @var PasswordApiInterface
             */
            protected $passwordApi;

            public function __construct(
                TranslatorInterface $translator,
                RequestStack $requestStack,
                «IF authenticationMethod == AuthMethodType.REMOTE»
                    RouterInterface $router,
                «ENDIF»
                EntityFactory $entityFactory,
                VariableApiInterface $variableApi,
                PasswordApiInterface $passwordApi)
            {
                $this->translator = $translator;
                $this->requestStack = $requestStack;
                «IF authenticationMethod == AuthMethodType.REMOTE»
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
        public function getAlias()«IF targets('3.0')»: string«ENDIF»
        {
            return '«name.formatForDB»_authentication';
        }

        public function getDisplayName()«IF targets('3.0')»: string«ENDIF»
        {
            return $this->translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('«name.formatForDisplayCapital»');
        }

        public function getDescription()«IF targets('3.0')»: string«ENDIF»
        {
            return $this->translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Allow a user to authenticate and login using the «name.formatForDisplay» module.');
        }

        public function authenticate(array $data = [])«IF targets('3.0')»: ?int«ENDIF»
        {
            $request = $this->requestStack->getCurrentRequest();
            if ($request->hasSession() && ($session = $request->getSession())) {
                $session->getFlashBag()->add('error', «IF !targets('3.0')»$this->translator->__(«ENDIF»'Login for «name.formatForDisplay» authentication method is not implemented yet.'«IF !targets('3.0')»)«ENDIF»);
            }

            return null;
        }

        public function register(array $data = [])«IF targets('3.0')»: bool«ENDIF»
        {
            $request = $this->requestStack->getCurrentRequest();
            if ($request->hasSession() && ($session = $request->getSession())) {
                $session->getFlashBag()->add('error', «IF !targets('3.0')»$this->translator->__(«ENDIF»'Registration for «name.formatForDisplay» authentication method is not implemented yet.'«IF !targets('3.0')»)«ENDIF»);
            }

            return false;
        }
    '''

    def private authMethodBaseImplRemote(Application it) '''
        public function getId()«IF targets('3.0')»: string«ENDIF»
        {
            return null;
        }

        public function getEmail()«IF targets('3.0')»: string«ENDIF»
        {
            return null;
        }

        public function getUname()«IF targets('3.0')»: string«ENDIF»
        {
            return null;
        }
    '''

    def private authMethodBaseImplLocal(Application it) '''
        public function getLoginFormClassName()«IF targets('3.0')»: string«ENDIF»
        {
            return UnameLoginType::class;
        }

        public function getLoginTemplateName«IF targets('3.0')»(string $type = 'page', string $position = 'left'): string«ELSE»($type = 'page', $position = 'left')«ENDIF»
        {
            if ('block' === $type) {
                if ('topnav' === $position) {
                    return 'ZikulaZAuthModule:Authentication:UnameLoginBlock.topnav.html.twig';
                }

                return 'ZikulaZAuthModule:Authentication:UnameLoginBlock.html.twig';
            }

            return 'ZikulaZAuthModule:Authentication:UnameLogin.html.twig';
        }

        public function getRegistrationFormClassName()«IF targets('3.0')»: string«ENDIF»
        {
            return RegistrationType;
        }

        public function getRegistrationTemplateName()«IF targets('3.0')»: string«ENDIF»
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
        public function authenticate(array $data = [])«IF targets('3.0')»: ?int«ENDIF»
        {
            // @todo replace by your own authentication logic
            return parent::authenticate($data);
        }

        public function register(array $data = [])«IF targets('3.0')»: bool«ENDIF»
        {
            // @todo replace by your own registration logic
            return parent::register($data);
        }
    '''

    def private authMethodImplRemote(Application it) '''
        public function getId()«IF targets('3.0')»: string«ENDIF»
        {
            // @todo replace by your own logic
            return parent::getId();
        }

        public function getEmail()«IF targets('3.0')»: string«ENDIF»
        {
            // @todo replace by your own logic
            return parent::getEmail();
        }

        public function getUname()«IF targets('3.0')»: string«ENDIF»
        {
            // @todo replace by your own logic
            return parent::getUname();
        }
    '''

    def private authMethodImplLocal(Application it) '''
        public function getLoginFormClassName()«IF targets('3.0')»: string«ENDIF»
        {
            // @todo replace by your own form type
            return parent::getLoginFormClassName();
        }

        public function getLoginTemplateName«IF targets('3.0')»(string $type = 'page', string $position = 'left'): string«ELSE»($type = 'page', $position = 'left')«ENDIF»
        {
            // @todo replace by your own template
            return parent::getLoginTemplateName($type, $position);
        }

        public function getRegistrationFormClassName()«IF targets('3.0')»: string«ENDIF»
        {
            // @todo replace by your own form type
            return parent::getRegistrationFormClassName();
        }

        public function getRegistrationTemplateName()«IF targets('3.0')»: string«ENDIF»
        {
            // @todo replace by your own template
            return parent::getRegistrationTemplateName();
        }
    '''
}
