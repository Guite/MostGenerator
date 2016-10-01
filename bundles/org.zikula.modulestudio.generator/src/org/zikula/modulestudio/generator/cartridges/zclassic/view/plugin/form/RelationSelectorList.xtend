package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class RelationSelectorList {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    // 1.3.x only
    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/RelationSelectorList.php',
            fh.phpFileContent(it, relationSelectorBaseImpl), fh.phpFileContent(it, relationSelectorImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'RelationSelectorList'))) {
            fsa.generateFile(viewPluginFilePath('function', 'RelationSelectorList'), fh.phpFileContent(it, relationSelectorPluginImpl))
        }
    }

    def private relationSelectorBaseImpl(Application it) '''
        /**
         * Relation selector plugin base class.
         */
        class «appName»_Form_Plugin_Base_AbstractRelationSelectorList extends «appName»_Form_Plugin_AbstractObjectSelector
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
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object
             * @param array            &$params Parameters passed from the Smarty plugin function
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
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object
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
        class «appName»_Form_Plugin_RelationSelectorList extends «appName»_Form_Plugin_Base_AbstractRelationSelectorList
        {
            // feel free to add your customisation here
        }
    '''

    def private relationSelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»RelationSelectorList plugin provides a dropdown selector for related items.
         *
         * @param  array            $params All attributes passed to this function from the template
         * @param  Zikula_Form_View $view   Reference to the view object
         *
         * @return string The output of the plugin
         */
        function smarty_function_«appName.formatForDB»RelationSelectorList($params, $view)
        {
            return $view->registerPlugin('«appName»_Form_Plugin_RelationSelectorList', $params);
        }
    '''
}
