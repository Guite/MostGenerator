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
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it) '''
        «new ControllerHelper().controllerPostInitialize(it, false)»

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
         */
        public function install()
        {
            $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));

            // fetch and return the appropriate template
            return $this->view->fetch('init/interactive.tpl');
        }
    '''

    def private funcInteractiveInitStep2(Application it) '''
        /**
         * Interactive installation procedure step 2.
         *
         * @return string|boolean Output.
         */
        public function interactiveinitstep2()
        {
            $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));

            $submit = $this->request->request->get('submit', null);
            if (!$submit) {
                // fetch and return the appropriate template
                return $this->view->fetch('init/step2.tpl');
            }

            $this->checkCsrfToken();

            «val modVarHelper = new ModVars()»
            «FOR modvar : getAllVariables»
                $formValue = $this->request->request->get('«modvar.name.formatForCode»', «modVarHelper.valForm2SessionDefault(modvar)»);
                SessionUtil::setVar('«formatForCode(name + '_' + modvar.name)»', $formValue);

            «ENDFOR»

            $activate = (bool) $this->request->request->filter('activate', false, FILTER_VALIDATE_BOOLEAN);
            $activate = (!empty($activate)) ? true : false;

            return System::redirect(ModUtil::url('«appName»', 'init', 'interactiveinitstep3', array('activate' => $activate)));
        }
    '''

    def private funcInteractiveInitStep3(Application it) '''
        /**
         * Interactive installation procedure step 3
         *
         * @return string|boolean Output.
         */
        public function interactiveinitstep3()
        {
            $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));

            $activate = (bool) $this->request->request->filter('activate', false, FILTER_VALIDATE_BOOLEAN);

            // assign activation flag
            $this->view->assign('activate', $activate);

            // fetch and return the appropriate template
            return $this->view->fetch('init/step3.tpl');
        }
    '''

    def private funcInteractiveUpdate(Application it) '''
        /**
         * Interactive update procedure
         *
         * @return string|boolean Output.
         */
        function upgrade()
        {
            $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));

            // TODO

            return true;
        }
    '''

    def private funcInteractiveDelete(Application it) '''
        /**
         * Interactive delete.
         *
         * @return string Output.
         */
        public function uninstall()
        {
            $this->throwForbiddenUnless(SecurityUtil::checkPermission('::', '::', ACCESS_ADMIN));

            // fetch and return the appropriate template
            return $this->view->fetch('init/delete.tpl');
        }
    '''
}
