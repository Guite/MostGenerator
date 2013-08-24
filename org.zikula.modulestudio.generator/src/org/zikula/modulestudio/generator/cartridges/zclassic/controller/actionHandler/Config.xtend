package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ListVar
import de.guite.modulestudio.metamodel.modulestudio.ListVarItem
import de.guite.modulestudio.metamodel.modulestudio.Variable
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Config {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for config form handler.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (needsConfig) {
            val formHandlerFolder = getAppSourceLibPath + 'Form/Handler/' + configController.toFirstUpper + '/'
            val handlerSuffix = (if(targets('1.3.5')) '' else 'Handler')
            fsa.generateFile(formHandlerFolder + 'Base/Config' + handlerSuffix + '.php', configHandlerBaseFile)
            fsa.generateFile(formHandlerFolder + 'Config' + handlerSuffix + '.php', configHandlerFile)
        }
    }

    def private configHandlerBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «configHandlerBaseImpl»
    '''

    def private configHandlerFile(Application it) '''
        «fh.phpFileHeader(it)»
        «configHandlerImpl»
    '''

    def private configHandlerBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Form\Handler\«configController.toFirstUpper»\Base;

            use LogUtil;
            use ModUtil;
            use SecurityUtil;
            use Zikula_Form_AbstractHandler;
            use Zikula_Form_View;

        «ENDIF»
        /**
         * Configuration handler base class.
         */
        class «IF targets('1.3.5')»«appName»_Form_Handler_«configController.toFirstUpper»_Base_Config«ELSE»ConfigHandler«ENDIF» extends Zikula_Form_AbstractHandler
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
                if ($args['commandName'] == 'save') {
                    // check if all fields are valid
                    if (!$this->view->isValid()) {
                        return false;
                    }

                    // retrieve form data
                    $data = $this->view->getValues();

                    // update all module vars
                    if (!$this->setVars($data['config'])) {
                        return LogUtil::registerError($this->__('Error! Failed to set configuration variables.'));
                    }

                    LogUtil::registerStatus($this->__('Done! Module configuration updated.'));
                } else if ($args['commandName'] == 'cancel') {
                    // nothing to do there
                }

                // redirect back to the config page
                $url = ModUtil::url($this->name, '«configController.formatForDB»', 'config');

                return $this->view->redirect($url);
            }
        }
    '''

    def private dispatch init(Variable it) {
    }

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
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Form\Handler\«configController.toFirstUpper»;

        «ENDIF»
        /**
         * Configuration handler implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Handler_«configController.toFirstUpper»_Config extends «appName»_Form_Handler_«configController.toFirstUpper»_Base_Config
        «ELSE»
        class ConfigHandler extends Base\ConfigHandler
        «ENDIF»
        {
            // feel free to extend the base handler class here
        }
    '''
}
