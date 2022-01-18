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
        use Symfony\Component\Security\Core\Encoder\EncoderFactoryInterface;
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        use Zikula\UsersModule\AuthenticationMethodInterface\«IF authenticationMethod == AuthMethodType.LOCAL»Non«ENDIF»ReEntrantAuthenticationMethodInterface;
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
            public function __construct(
                protected TranslatorInterface $translator,
                protected RequestStack $requestStack,
                «IF authenticationMethod == AuthMethodType.REMOTE»
                    protected RouterInterface $router,
                «ENDIF»
                protected EntityFactory $entityFactory,
                protected VariableApiInterface $variableApi,
                protected EncoderFactoryInterface $encoderFactory
            ) {
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
        public function getAlias(): string
        {
            return '«name.formatForDB»_authentication';
        }

        public function getDisplayName(): string
        {
            return $this->translator->trans('«name.formatForDisplayCapital»');
        }

        public function getDescription(): string
        {
            return $this->translator->trans('Allow a user to authenticate and login using the «name.formatForDisplay» module.');
        }

        public function authenticate(array $data = []): ?int
        {
            $request = $this->requestStack->getCurrentRequest();
            if ($request->hasSession() && ($session = $request->getSession())) {
                $session->getFlashBag()->add('error', 'Login for «name.formatForDisplay» authentication method is not implemented yet.');
            }

            return null;
        }

        public function register(array $data = []): bool
        {
            $request = $this->requestStack->getCurrentRequest();
            if ($request->hasSession() && ($session = $request->getSession())) {
                $session->getFlashBag()->add('error', 'Registration for «name.formatForDisplay» authentication method is not implemented yet.');
            }

            return false;
        }
    '''

    def private authMethodBaseImplRemote(Application it) '''
        public function getId()
        {
            return null;
        }

        public function getEmail(): string
        {
            return null;
        }

        public function getUname(): string
        {
            return null;
        }
    '''

    def private authMethodBaseImplLocal(Application it) '''
        public function getLoginFormClassName(): string
        {
            return UnameLoginType::class;
        }

        public function getLoginTemplateName(string $type = 'page', string $position = 'left'): string
        {
            if ('block' === $type) {
                if ('topnav' === $position) {
                    return 'ZikulaZAuthModule:Authentication:UnameLoginBlock.topnav.html.twig';
                }

                return 'ZikulaZAuthModule:Authentication:UnameLoginBlock.html.twig';
            }

            return 'ZikulaZAuthModule:Authentication:UnameLogin.html.twig';
        }

        public function getRegistrationFormClassName(): string
        {
            return RegistrationType;
        }

        public function getRegistrationTemplateName(): string
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
        public function authenticate(array $data = []): ?int
        {
            // @todo replace by your own authentication logic
            return parent::authenticate($data);
        }

        public function register(array $data = []): bool
        {
            // @todo replace by your own registration logic
            return parent::register($data);
        }
    '''

    def private authMethodImplRemote(Application it) '''
        public function getId()
        {
            // @todo replace by your own logic
            return parent::getId();
        }

        public function getEmail(): string
        {
            // @todo replace by your own logic
            return parent::getEmail();
        }

        public function getUname(): string
        {
            // @todo replace by your own logic
            return parent::getUname();
        }
    '''

    def private authMethodImplLocal(Application it) '''
        public function getLoginFormClassName(): string
        {
            // @todo replace by your own form type
            return parent::getLoginFormClassName();
        }

        public function getLoginTemplateName(string $type = 'page', string $position = 'left'): string
        {
            // @todo replace by your own template
            return parent::getLoginTemplateName($type, $position);
        }

        public function getRegistrationFormClassName(): string
        {
            // @todo replace by your own form type
            return parent::getRegistrationFormClassName();
        }

        public function getRegistrationTemplateName(): string
        {
            // @todo replace by your own template
            return parent::getRegistrationTemplateName();
        }
    '''
}
