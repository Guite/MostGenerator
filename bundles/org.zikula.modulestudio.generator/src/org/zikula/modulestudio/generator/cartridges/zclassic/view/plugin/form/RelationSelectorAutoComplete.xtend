package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class RelationSelectorAutoComplete {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    // 1.3.x only
    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/RelationSelectorAutoComplete.php',
            fh.phpFileContent(it, relationSelectorBaseImpl), fh.phpFileContent(it, relationSelectorImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'RelationSelectorAutoComplete'))) {
            fsa.generateFile(viewPluginFilePath('function', 'RelationSelectorAutoComplete'), fh.phpFileContent(it, relationSelectorPluginImpl))
        }
    }

    def private relationSelectorBaseImpl(Application it) '''
        /**
         * Relation selector plugin base class.
         */
        class «appName»_Form_Plugin_Base_AbstractRelationSelectorAutoComplete extends «appName»_Form_Plugin_AbstractObjectSelector
        {
            /**
             * Identifier prefix (unique name for JS).
             *
             * @var string
             */
            public $idPrefix = '';

            /**
             * Url for inline creation of new related items (if allowed).
             *
             * @var string
             */
            public $createLink = '';

            /**
             * Whether the treated entity has an image field or not.
             *
             * @var boolean
             */
            public $withImage = false;

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

                $params['fetchItemsDuringLoad'] = false;
                // load list items
                parent::load($view, $params);

                if (isset($params['idPrefix'])) {
                    $this->idPrefix = $params['idPrefix'];
                    unset($params['idPrefix']);
                    $this->inputName = $this->idPrefix . 'ItemList';
                }

                if (isset($params['createLink'])) {
                    $this->createLink = $params['createLink'];
                    unset($params['createLink']);
                }

                if (isset($params['withImage'])) {
                    $this->withImage = $params['withImage'];
                    unset($params['withImage']);
                }

                // preprocess selection: collect id list for related items
                $this->preprocessIdentifiers($view, $params);
            }

            /**
             * Entry point for customised css class.
             */
            protected function getStyleClass()
            {
                return 'z-form-relationlist autocomplete';
            }

            /**
             * Render event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object
             *
             * @return string The rendered output
             */
            public function render(Zikula_Form_View $view)
            {
                $dom = ZLanguage::getModuleDomain('«appName»');
                $many = $this->selectionMode == 'multiple';

                $entityNameTranslated = '';
                switch ($this->objectType) {
                    «FOR entity : entities»
                        case '«entity.name.formatForCode»':
                            $entityNameTranslated = __('«entity.name.formatForDisplay»', $dom);
                            break;
                    «ENDFOR»
                }

                $addLinkText = $many ? __f('Add %s', array($entityNameTranslated), $dom) : __f('Select %s', array($entityNameTranslated), $dom);
                $selectLabelText = __f('Find %s', array($entityNameTranslated), $dom);
                $searchIconText = __f('Search %s', array($entityNameTranslated), $dom);

                $idPrefix = $this->idPrefix;

                $addLink = '<a id="' . $idPrefix . 'AddLink" href="javascript:void(0);" class="z-hide">' . $addLinkText . '</a>';
                $createLink = '';
                if ($this->createLink != '') {
                    $createLink = '<a id="' . $idPrefix . 'SelectorDoNew" href="' . DataUtil::formatForDisplay($this->createLink) . '" title="' . __f('Create new %s', array($entityNameTranslated), $dom) . '" class="z-button «appName.toLowerCase»-inline-button">' . __('Create', $dom) . '</a>';
                }

                $result = '
                    <div class="«appName.toLowerCase»-relation-rightside">'
                        . $addLink . '
                        <div id="' . $idPrefix . 'AddFields" class="«appName.toLowerCase»-autocomplete' . ($this->withImage ? '-with-image' : '') . '">
                            <label for="' . $idPrefix . 'Selector">' . $selectLabelText . '</label>
                            <br />
                            <img src="' . System::getBaseUrl() . 'images/icons/extrasmall/search.png" width="16" height="16" alt="' . $searchIconText . '" />
                            <input type="text" name="' . $idPrefix . 'Selector" id="' . $idPrefix . 'Selector" value="" />
                            <input type="hidden" name="' . $idPrefix . 'Scope" id="' . $idPrefix . 'Scope" value="' . (!$many ? '0' : '1') . '" />
                            <img src="' . System::getBaseUrl() . 'images/ajax/indicator_circle.gif" width="16" height="16" alt="" id="' . $idPrefix . 'Indicator" style="display: none" />
                            <span id="' . $idPrefix . 'NoResultsHint" class="z-hide">' . __('No results found!', $dom) . '</span>
                            <div id="' . $idPrefix . 'SelectorChoices" class=""></div>';
                            <input type="button" id="' . $idPrefix . 'SelectorDoCancel" name="' . $idPrefix . 'SelectorDoCancel" value="' . __('Cancel', $dom) . '" class="z-button «appName.toLowerCase»-inline-button" />'
                            . $createLink . '
                            <noscript><p>' . __('This function requires JavaScript activated!', $dom) . '</p></noscript>
                        </div>
                    </div>' . "\n";

                return $result;
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
        class «appName»_Form_Plugin_RelationSelectorAutoComplete extends «appName»_Form_Plugin_Base_AbstractRelationSelectorAutoComplete
        {
            // feel free to add your customisation here
        }
    '''

    def private relationSelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»RelationSelectorAutoComplete plugin provides an autocompleter for related items.
         *
         * @param  array            $params All attributes passed to this function from the template
         * @param  Zikula_Form_View $view   Reference to the view object
         *
         * @return string The output of the plugin
         */
        function smarty_function_«appName.formatForDB»RelationSelectorAutoComplete($params, $view)
        {
            return $view->registerPlugin('«appName»_Form_Plugin_RelationSelectorAutoComplete', $params);
        }
    '''
}
