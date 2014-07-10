package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class RelationSelectorAutoComplete {
    extension FormattingExtensions = new FormattingExtensions()
    extension ModelExtensions = new ModelExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/RelationSelectorAutoComplete.php',
            fh.phpFileContent(it, relationSelectorBaseImpl), fh.phpFileContent(it, relationSelectorImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'RelationSelectorAutoComplete'))) {
            fsa.generateFile(viewPluginFilePath('function', 'RelationSelectorAutoComplete'), fh.phpFileContent(it, relationSelectorPluginImpl))
        }
    }

    def private relationSelectorBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Form\Plugin\Base;

            use «appNamespace»\Form\Plugin\AbstractObjectSelector as BaseAbstractObjectSelector;

            use DataUtil;
            use Zikula_Form_View;
            use ZLanguage;

        «ENDIF»
        /**
         * Relation selector plugin base class.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Plugin_Base_RelationSelectorAutoComplete extends «appName»_Form_Plugin_AbstractObjectSelector
        «ELSE»
        class RelationSelectorAutoComplete extends BaseAbstractObjectSelector
        «ENDIF»
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
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
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
                return 'z-form-relationlist «IF targets('1.3.5')»autocomplete«ELSE»typeahead«ENDIF»';
            }

            /**
             * Render event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return string The rendered output
             */
            public function render(Zikula_Form_View $view)
            {
                $dom = ZLanguage::getModuleDomain('«appName»');
                $many = ($this->selectionMode == 'multiple');

                $entityNameTranslated = '';
                switch ($this->objectType) {
                    «FOR entity : getAllEntities»
                        case '«entity.name.formatForCode»':
                            $entityNameTranslated = __('«entity.name.formatForDisplay»', $dom);
                            break;
                    «ENDFOR»
                }

                $addLinkText = $many ? __f('Add %s', array($entityNameTranslated), $dom) : __f('Select %s', array($entityNameTranslated), $dom);
                $selectLabelText = __f('Find %s', array($entityNameTranslated), $dom);
                $searchIconText = __f('Search %s', array($entityNameTranslated), $dom);

                $idPrefix = $this->idPrefix;

                $addLink = '<a id="' . $idPrefix . 'AddLink" href="javascript:void(0);" class="«IF targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»">' . $addLinkText . '</a>';
                $createLink = '';
                if ($this->createLink != '') {
                    $createLink = '<a id="' . $idPrefix . 'SelectorDoNew" href="' . DataUtil::formatForDisplay($this->createLink) . '" title="' . __f('Create new %s', array($entityNameTranslated), $dom) . '" class="«IF targets('1.3.5')»z-button«ELSE»btn btn-default«ENDIF» «appName.toLowerCase»-inline-button">' . __('Create', $dom) . '</a>';
                }

                $alias = $this->id;
                $class = $this->getStyleClass();

                $result = '
                    <div class="«appName.toLowerCase»-relation-rightside">'
                        . $addLink . '
                        <div id="' . $idPrefix . 'AddFields «appName.toLowerCase»-autocomplete' . (($this->withImage) ? '-with-image' : '') . '">
                            <label for="' . $idPrefix . 'Selector">' . $selectLabelText . '</label>
                            <br />';

                «IF targets('1.3.5')»
                    $result .= '<img src="' . System::getBaseUrl() . 'images/icons/extrasmall/search.png" width="16" height="16" alt="' . $searchIconText . '" />
                                <input type="text" name="' . $idPrefix . 'Selector" id="' . $idPrefix . 'Selector" value="" />
                                <input type="hidden" name="' . $idPrefix . 'Scope" id="' . $idPrefix . 'Scope" value="' . ((!$many) ? '0' : '1') . '" />
                                <img src="' . System::getBaseUrl() . 'images/ajax/indicator_circle.gif" width="16" height="16" alt="" id="' . $idPrefix . 'Indicator" style="display: none" />
                                <span id="' . $idPrefix . 'NoResultsHint" class="z-hide">' . __('No results found!', $dom) . '</span>
                                <div id="' . $idPrefix . 'SelectorChoices" class=""></div>';
                «ELSE»
                    $result .= '<i class="fa fa-search" title="' . $searchIconText . '"><i>
                                <input type="hidden" name="' . $idPrefix . 'Scope" id="' . $idPrefix . 'Scope" value="' . ((!$many) ? '0' : '1') . '" />
                                <input type="text" id="' . $idPrefix . 'Selector" name="' . $idPrefix . 'Selector" value="' . DataUtil::formatForDisplay($this->text) . '" autocomplete="off" class="' . $class . '" />
                                <i class="fa fa-refresh fa-spin hidden" id="' . $idPrefix . 'Indicator"></i>
                                <span id="' . $idPrefix . 'NoResultsHint" class="hidden">' . __('No results found!', $dom) . '</span>';
                «ENDIF»
                $result .= '
                                <input type="button" id="' . $idPrefix . 'SelectorDoCancel" name="' . $idPrefix . 'SelectorDoCancel" value="' . __('Cancel', $dom) . '" class="«IF targets('1.3.5')»z-button«ELSE»btn btn-default«ENDIF» «appName.toLowerCase»-inline-button" />'
                                . $createLink . '
                                <noscript><p>' . __('This function requires JavaScript activated!', $dom) . '</p></noscript>
                            </div>
                        </div>' . "\n";

                return $result;
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
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Form\Plugin;

            use «appNamespace»\Form\Plugin\Base\RelationSelectorAutoComplete as BaseRelationSelectorAutoComplete;

        «ENDIF»
        /**
         * Relation selector plugin implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Plugin_RelationSelectorAutoComplete extends «appName»_Form_Plugin_Base_RelationSelectorAutoComplete
        «ELSE»
        class RelationSelectorAutoComplete extends BaseRelationSelectorAutoComplete
        «ENDIF»
        {
            // feel free to add your customisation here
        }
    '''

    def private relationSelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»RelationSelectorAutoComplete plugin provides an autocompleter for related items.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»RelationSelectorAutoComplete($params, $view)
        {
            return $view->registerPlugin('«IF targets('1.3.5')»«appName»_Form_Plugin_RelationSelectorAutoComplete«ELSE»\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Form\\Plugin\\RelationSelectorAutoComplete«ENDIF»', $params);
        }
    '''
}
