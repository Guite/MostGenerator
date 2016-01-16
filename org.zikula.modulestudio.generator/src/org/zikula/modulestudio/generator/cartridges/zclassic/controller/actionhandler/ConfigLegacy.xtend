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

class ConfigLegacy {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for config form handler.
     * 1.3.x only.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!needsConfig) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Handler/' + configController.toFirstUpper + '/Config.php',
            fh.phpFileContent(it, configLegacyHandlerBaseImpl), fh.phpFileContent(it, configLegacyHandlerImpl)
        )
    }

    def private configLegacyHandlerBaseImpl(Application it) '''
        /**
         * Configuration handler base class.
         */
        class «appName»_Form_Handler_«configController.toFirstUpper»_Base_Config extends Zikula_Form_AbstractHandler
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
             */
            public function initialize(Zikula_Form_View $view)
            {
                // permission check
                if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                    return $view->registerError(LogUtil::registerPermissionError());
                }
                «IF !getAllVariables.filter(IntVar).filter[isUserGroupSelector].empty»

                    // prepare list of user groups for moderation group selectors
                    $userGroups = ModUtil::apiFunc('Groups', 'user', 'getall');
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

                // everything okay, no initialization errors occured
                return true;
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
                if ($args['commandName'] == 'save') {
                    // check if all fields are valid
                    if (!$this->view->isValid()) {
                        return false;
                    }

                    // retrieve form data
                    $data = $this->view->getValues();

                    // update all module vars
                    try {
                        $this->setVars($data['config']);
                    } catch (\Exception $e) {
                        $msg = $this->__('Error! Failed to set configuration variables.');
                        if (System::isDevelopmentMode()) {
                            $msg .= ' ' . $e->getMessage();
                        }

                        return LogUtil::registerError($msg);
                    }

                    LogUtil::registerStatus($this->__('Done! Module configuration updated.'));
                } else if ($args['commandName'] == 'cancel') {
                    LogUtil::registerStatus($this->__('Operation cancelled.'));
                }

                // redirect back to the config page
                $url = ModUtil::url($this->name, '«configController.formatForDB»', 'config');

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
            «IF (eContainer as ListVar).container.application.targets('1.3.x')»array(«ELSE»[«ENDIF»'value' => '«name.formatForCode»', 'text' => '«name.formatForDisplayCapital»'«IF (eContainer as ListVar).container.application.targets('1.3.x')»)«ELSE»]«ENDIF»
    '''

    def private configLegacyHandlerImpl(Application it) '''
        /**
         * Configuration handler implementation class.
         */
        class «appName»_Form_Handler_«configController.toFirstUpper»_Config extends «appName»_Form_Handler_«configController.toFirstUpper»_Base_Config
        {
            // feel free to extend the base handler class here
        }
    '''
}