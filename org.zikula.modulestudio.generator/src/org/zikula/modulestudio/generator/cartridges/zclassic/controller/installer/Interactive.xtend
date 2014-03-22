package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper

/**
 * Entry point for interactive installer implementation.
 */
class Interactive {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it) '''
        «new ControllerHelper().controllerPostInitialize(it, false, '')»

        «funcInteractiveInit»

        «IF needsConfig»«funcInteractiveInitStep2»

        «ENDIF»
        «funcInteractiveInitStep3»

        «funcInteractiveUpdate»

        «funcInteractiveDelete»
    '''

    def private funcInteractiveInit(Application it) '''
        /**
         * Interactive installation procedure.
         *
         * @return string|boolean Output.
         «IF !targets('1.3.5')»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
        public function install«IF !targets('1.3.5')»Action«ENDIF»()
        {
            «IF targets('1.3.5')»
                $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));
            «ELSE»
                if (!SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN)) {
                    throw new AccessDeniedException();
                }
            «ENDIF»

            // fetch and return the appropriate template
            «IF targets('1.3.5')»
            return $this->view->fetch('init/interactive.tpl');
            «ELSE»
            return $this->response($this->view->fetch('Init/interactive.tpl'));
            «ENDIF»
        }
    '''

    def private funcInteractiveInitStep2(Application it) '''
        /**
         * Interactive installation procedure step 2.
         *
         * @return string|boolean Output.
         «IF !targets('1.3.5')»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
        public function interactiveinitstep2«IF !targets('1.3.5')»Action«ENDIF»()
        {
            «IF targets('1.3.5')»
                $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));
            «ELSE»
                if (!SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN)) {
                    throw new AccessDeniedException();
                }
            «ENDIF»

            $submit = $this->request->request->get('submit', null);
            if (!$submit) {
                // fetch and return the appropriate template
                «IF targets('1.3.5')»
                return $this->view->fetch('init/step2.tpl');
                «ELSE»
                return $this->response($this->view->fetch('Init/step2.tpl'));
                «ENDIF»
            }

            $this->checkCsrfToken();

            «val modVarHelper = new ModVars()»
            «FOR modvar : getAllVariables»
                $formValue = $this->request->request->get('«modvar.name.formatForCode»', «modVarHelper.valForm2SessionDefault(modvar)»);
                «IF targets('1.3.5')»
                    SessionUtil::setVar('«formatForCode(name + '_' + modvar.name)»', $formValue);
                «ELSE»
                    $this->session->set('«formatForCode(name + '_' + modvar.name)»', $formValue);
                «ENDIF»

            «ENDFOR»

            $activate = (bool) $this->request->request->filter('activate', false, «IF !targets('1.3.5')»false, «ENDIF»FILTER_VALIDATE_BOOLEAN);
            $activate = !empty($activate) ? true : false;

            «IF targets('1.3.5')»
                return $this->redirect(ModUtil::url('«appName»', 'init', 'interactiveinitstep3', array('activate' => $activate)));
            «ELSE»
                return new RedirectResponse(System::normalizeUrl(ModUtil::url('«appName»', 'init', 'interactiveinitstep3', array('activate' => $activate))));
            «ENDIF»
        }
    '''

    def private funcInteractiveInitStep3(Application it) '''
        /**
         * Interactive installation procedure step 3
         *
         * @return string|boolean Output.
         «IF !targets('1.3.5')»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
        public function interactiveinitstep3«IF !targets('1.3.5')»Action«ENDIF»()
        {
            «IF targets('1.3.5')»
                $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));
            «ELSE»
                if (!SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN)) {
                    throw new AccessDeniedException();
                }
            «ENDIF»

            $activate = (bool) $this->request->request->filter('activate', false, «IF !targets('1.3.5')»false, «ENDIF»FILTER_VALIDATE_BOOLEAN);

            // assign activation flag
            $this->view->assign('activate', $activate);

            // fetch and return the appropriate template
            «IF targets('1.3.5')»
            return $this->view->fetch('init/step3.tpl');
            «ELSE»
            return $this->response($this->view->fetch('Init/step3.tpl'));
            «ENDIF»
        }
    '''

    def private funcInteractiveUpdate(Application it) '''
        /**
         * Interactive update procedure
         *
         * @return string|boolean Output.
         «IF !targets('1.3.5')»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
        public function upgrade«IF !targets('1.3.5')»Action«ENDIF»()
        {
            «IF targets('1.3.5')»
                $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));
            «ELSE»
                if (!SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN)) {
                    throw new AccessDeniedException();
                }
            «ENDIF»

            // TODO

            return true;
        }
    '''

    def private funcInteractiveDelete(Application it) '''
        /**
         * Interactive delete.
         *
         * @return string Output.
         «IF !targets('1.3.5')»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
        public function uninstall«IF !targets('1.3.5')»Action«ENDIF»()
        {
            «IF targets('1.3.5')»
                $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));
            «ELSE»
                if (!SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN)) {
                    throw new AccessDeniedException();
                }
            «ENDIF»

            // fetch and return the appropriate template
            «IF targets('1.3.5')»
            return $this->view->fetch('init/delete.tpl');
            «ELSE»
            return $this->response($this->view->fetch('Init/delete.tpl'));
            «ENDIF»
        }
    '''
}
