package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.ListVar
import de.guite.modulestudio.metamodel.ListVarItem
import de.guite.modulestudio.metamodel.Variable
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Config {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for config form handler.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!needsConfig) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Handler/' + configController.toFirstUpper + '/Config' + (if (targets('1.3.x')) '' else 'Handler') + '.php',
            fh.phpFileContent(it, configHandlerBaseImpl), fh.phpFileContent(it, configHandlerImpl)
        )
    }

    def private configHandlerBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Form\Handler\«configController.toFirstUpper»\Base;

            use Symfony\Component\Security\Core\Exception\AccessDeniedException;

            use ModUtil;
            use ServiceUtil;
            use System;
            use UserUtil;
            use Zikula_Form_AbstractHandler;
            use Zikula_Form_View;

        «ENDIF»
        /**
         * Configuration handler base class.
         */
        class «IF targets('1.3.x')»«appName»_Form_Handler_«configController.toFirstUpper»_Base_Config«ELSE»ConfigHandler«ENDIF» extends Zikula_Form_AbstractHandler
        {
            /**
             * Post construction hook.
             *
             * @return mixed
             */
            public function setup()
            {
            }

            /**
             * Initialize form handler.
             *
             * This method takes care of all necessary initialisation of our data and form states.
             *
             * @param Zikula_Form_View $view The form view instance.
             *
             * @return boolean False in case of initialization errors, otherwise true.
             «IF !targets('1.3.x')»
             *
             * @throws AccessDeniedException Thrown if the user doesn't have admin permissions
             * @throws RuntimeException          Thrown if persisting configuration vars fails
             «ENDIF»
             */
            public function initialize(Zikula_Form_View $view)
            {
                // permission check
                «IF targets('1.3.x')»
                    if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                        return $view->registerError(LogUtil::registerPermissionError());
                    }
                «ELSE»
                    $serviceManager = ServiceUtil::getManager();
                    if (!$serviceManager->get('zikula_permissions_module.api.permission')->hasPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                        throw new AccessDeniedException();
                    }
                «ENDIF»
                «IF !getAllVariables.filter(IntVar).filter[isUserGroupSelector].empty»

                    // prepare list of user groups for moderation group selectors
                    $userGroups = ModUtil::apiFunc('«IF targets('1.3.x')»Groups«ELSE»ZikulaGroupsModule«ENDIF»', 'user', 'getall');
                    $userGroupItems = array();
                    foreach ($userGroups as $userGroup) {
                        $userGroupItems[] = array(
                            'value' => $userGroup['gid'],
                            'text' => $userGroup['name']
                        );
                    }
                «ENDIF»

                // retrieve module vars
                $modVars = $this->getVars();

                «FOR modvar : getAllVariables»«modvar.init»«ENDFOR»

                // assign all module vars
                $this->view->assign('config', $modVars);

                // custom initialisation aspects
                $this->initializeAdditions();

                // everything okay, no initialization errors occured
                return true;
            }

            /**
             * Method stub for own additions in subclasses.
             */
            protected function initializeAdditions()
            {
            }

            /**
             * Pre-initialise hook.
             *
             * @return void
             */
            public function preInitialize()
            {
            }

            /**
             * Post-initialise hook.
             *
             * @return void
             */
            public function postInitialize()
            {
            }

            /**
             * Command event handler.
             *
             * This event handler is called when a command is issued by the user. Commands are typically something
             * that originates from a {@link Zikula_Form_Plugin_Button} plugin. The passed args contains different properties
             * depending on the command source, but you should at least find a <var>$args['commandName']</var>
             * value indicating the name of the command. The command name is normally specified by the plugin
             * that initiated the command.
             *
             * @param Zikula_Form_View $view The form view instance.
             * @param array            $args Additional arguments.
             *
             * @see Zikula_Form_Plugin_Button
             * @see Zikula_Form_Plugin_ImageButton
             *
             * @return mixed Redirect or false on errors.
             */
            public function handleCommand(Zikula_Form_View $view, &$args)
            {
                «IF !targets('1.3.x')»
                    $serviceManager = ServiceUtil::getManager();
                    $flashBag = $serviceManager->get('request')->getSession()->getFlashBag();

                «ENDIF»
                if ($args['commandName'] == 'save') {
                    // check if all fields are valid
                    if (!$this->view->isValid()) {
                        return false;
                    }

                    // retrieve form data
                    $data = $this->view->getValues();

                    // update all module vars
                    try {
                        «IF targets('1.3.x')»
                            $this->setVars($data['config']);
                        «ELSE»
                            $serviceManager->get('zikula_extensions_module.api.variable')->setAll('«appName»', $data['config']);
                        «ENDIF»
                    } catch (\Exception $e) {
                        $msg = $this->__('Error! Failed to set configuration variables.');
                        if (System::isDevelopmentMode()) {
                            $msg .= ' ' . $e->getMessage();
                        }
                        «IF targets('1.3.x')»
                            return LogUtil::registerError($msg);
                        «ELSE»
                            $flashBag->add('error', $msg);
                            return false;
                        «ENDIF»
                    }

                    «IF targets('1.3.x')»
                        LogUtil::registerStatus($this->__('Done! Module configuration updated.'));
                    «ELSE»
                        $flashBag->add('status', $this->__('Done! Module configuration updated.'));

                        $logger = $serviceManager->get('logger');
                        $logger->notice('{app}: User {user} updated the configuration.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname')));
                    «ENDIF»
                } else if ($args['commandName'] == 'cancel') {
                    // nothing to do there
                }

                // redirect back to the config page
                «IF targets('1.3.x')»
                    $url = ModUtil::url($this->name, '«configController.formatForDB»', 'config');
                «ELSE»
                    $url = $serviceManager->get('router')->generate('«appName.formatForDB»_«configController.formatForDB»_config');
                «ENDIF»

                return $this->view->redirect($url);
            }
        }
    '''

    def private dispatch init(Variable it) {
    }

    def private dispatch init(IntVar it) '''
        «IF isUserGroupSelector»
            $modVars['«name.formatForCode»Items'] = $userGroupItems;
        «ENDIF»
    '''

    def private dispatch init(ListVar it) '''
        // initialise list entries for the '«name.formatForDisplay»' setting
        «/*        $listEntries = $modVars['«name.formatForCode)»'];*/»
        $modVars['«name.formatForCode»Items'] = array(«FOR item : items SEPARATOR ','»«item.itemDefinition»«ENDFOR»
        );
    '''

    def private itemDefinition(ListVarItem it) '''
            array('value' => '«name.formatForCode»', 'text' => '«name.formatForDisplayCapital»')
    '''

    def private configHandlerImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Form\Handler\«configController.toFirstUpper»;

            use «appNamespace»\Form\Handler\«configController.toFirstUpper»\Base\ConfigHandler as BaseConfigHandler;

        «ENDIF»
        /**
         * Configuration handler implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Form_Handler_«configController.toFirstUpper»_Config extends «appName»_Form_Handler_«configController.toFirstUpper»_Base_Config
        «ELSE»
        class ConfigHandler extends BaseConfigHandler
        «ENDIF»
        {
            // feel free to extend the base handler class here
        }
    '''
}
