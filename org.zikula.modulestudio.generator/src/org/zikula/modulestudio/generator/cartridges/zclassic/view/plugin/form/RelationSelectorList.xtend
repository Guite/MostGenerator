package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class RelationSelectorList {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val formPluginPath = getAppSourceLibPath + 'Form/Plugin/'
        fsa.generateFile(formPluginPath + 'Base/RelationSelectorList.php', relationSelectorBaseFile)
        fsa.generateFile(formPluginPath + 'RelationSelectorList.php', relationSelectorFile)
        fsa.generateFile(viewPluginFilePath('function', 'RelationSelectorList'), relationSelectorPluginFile)
    }

    def private relationSelectorBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «relationSelectorBaseImpl»
    '''

    def private relationSelectorFile(Application it) '''
        «fh.phpFileHeader(it)»
        «relationSelectorImpl»
    '''

    def private relationSelectorPluginFile(Application it) '''
        «fh.phpFileHeader(it)»
        «relationSelectorPluginImpl»
    '''

    def private relationSelectorBaseImpl(Application it) '''
        /**
         * Relation selector plugin base class.
         */
        class «appName»_Form_Plugin_Base_RelationSelectorList extends «appName»_Form_Plugin_AbstractObjectSelector
        {
            /**
             * Get filename of this file.
             * The information is used to re-establish the plugins on postback.
             *
             * @return string
             */
            public function getFilename()
            {
                return __FILE__;
            }

            /**
             * Load event handler.
             *
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
             *
             * @return void
             */
            public function load(Zikula_Form_View $view, &$params)
            {
                $this->processRequestData($view, 'GET');

                // load list items
                parent::load($view, $params);

                // preprocess selection: collect id list for related items
                $this->preprocessIdentifiers($view, $params);
            }

            /**
             * Entry point for customised css class.
             */
            protected function getStyleClass()
            {
                return 'z-form-relationlist';
            }

            /**
             * Decode event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return void
             */
            public function decode(Zikula_Form_View $view)
            {
                parent::decode($view);

                // postprocess selection: reinstantiate objects for identifiers
                $this->processRequestData($view, 'POST');
            }
        }
    '''

    def private relationSelectorImpl(Application it) '''
        /**
         * Relation selector plugin implementation class.
         */
        class «appName»_Form_Plugin_RelationSelectorList extends «appName»_Form_Plugin_Base_RelationSelectorList
        {
            // feel free to add your customisation here
        }
    '''

    def private relationSelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»RelationSelectorList plugin provides a dropdown selector for related items.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»RelationSelectorList($params, $view)
        {
            return $view->registerPlugin('«appName»_Form_Plugin_RelationSelectorList', $params);
        }
    '''
}
