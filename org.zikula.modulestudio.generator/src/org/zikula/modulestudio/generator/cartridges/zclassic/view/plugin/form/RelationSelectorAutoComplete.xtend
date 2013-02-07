package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class RelationSelectorAutoComplete {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val formPluginPath = getAppSourceLibPath + 'Form/Plugin/'
        fsa.generateFile(formPluginPath + 'Base/RelationSelectorAutoComplete.php', relationSelectorBaseFile)
        fsa.generateFile(formPluginPath + 'RelationSelectorAutoComplete.php', relationSelectorFile)
        fsa.generateFile(viewPluginFilePath('function', 'RelationSelectorAutoComplete'), relationSelectorPluginFile)
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
        «IF !targets('1.3.5')»
            namespace «appName»\Form\Plugin\Base;

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
        class RelationSelectorAutoComplete extends \«appName»\Form\Plugin\AbstractObjectSelector
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
             * Name of entity to be selected.
             *
             * @var string
             */
            public $selectedEntityName = '';

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

                if (isset($params['selectedEntityName'])) {
                    $this->selectedEntityName = $params['selectedEntityName'];
                    unset($params['selectedEntityName']);
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
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return string The rendered output
             */
            public function render(Zikula_Form_View $view)
            {
                $dom = ZLanguage::getModuleDomain('«appName»');
                $many = ($this->selectionMode == 'multiple');

                $entityName = $this->selectedEntityName;
                $addLinkText = $many ? __f('Add %s', array($entityName), $dom) : __f('Select %s', array($entityName), $dom);
                $selectLabelText = __f('Find %s', array($entityName), $dom);
                $searchIconText = __f('Search %s', array($entityName), $dom);

                $idPrefix = $this->idPrefix;

                $addLink = '<a id="' . $idPrefix . 'AddLink" href="javascript:void(0);" class="z-hide">' . $addLinkText . '</a>';
                $createLink = '';
                if ($this->createLink != '') {
                    $createLink = '<a id="' . 'SelectorDoNew" href="' . DataUtil::formatForDisplay($this->createLink) . '" title="' . __f('Create new %s', array($entityName), $dom) . '" class="z-button «prefix()»InlineButton">' . __('Create', $dom) . '</a>';
                }

                $alias = $this->id;

                $result = '
                    <div class="«prefix()»RelationRightSide">'
                        . $addLink . '
                        <div id="' . $idPrefix . 'AddFields">
                            <label for="' . $idPrefix . 'Selector">' . $selectLabelText . '</label>
                            <br />
                            <img src="/images/icons/extrasmall/search.png" width="16" height="16" alt="' . $searchIconText . '" />
                            <input type="text" name="' . $idPrefix . 'Selector" id="' . $idPrefix . 'Selector" value="" />
                            <input type="hidden" name="' . $idPrefix . 'Scope" id="' . $idPrefix . 'Scope" value="' . ((!$many) ? '0' : '1') . '" />
                            <img src="/images/ajax/indicator_circle.gif" width="16" height="16" alt="" id="' . $idPrefix . 'Indicator" style="display: none" />
                            <span id="' . $idPrefix . 'NoResultsHint" class="z-hide">' . __('No results found!', $dom) . '</span>
                            <div id="' . $idPrefix . 'SelectorChoices" class="«prefix()»AutoComplete' . (($this->withImage) ? 'WithImage' : '') . '"></div>
                            <input type="button" id="' . $idPrefix . 'SelectorDoCancel" name="' . $idPrefix . 'SelectorDoCancel" value="' . __('Cancel', $dom) . '" class="z-button «prefix()»InlineButton" />'
                            . $createLink . '
                            <noscript><p>' . __('This function requires JavaScript activated!', $dom) . '</p></noscript>
                        </div>
                    </div>';

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
            namespace «appName»\Form\Plugin;

        «ENDIF»
        /**
         * Relation selector plugin implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Plugin_RelationSelectorAutoComplete extends «appName»_Form_Plugin_Base_RelationSelectorAutoComplete
        «ELSE»
        class RelationSelectorAutoComplete extends Base\RelationSelectorAutoComplete
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
            return $view->registerPlugin('«IF targets('1.3.5')»«appName»_Form_Plugin_RelationSelectorAutoComplete«ELSE»\\«appName»\\Form\\Plugin\\RelationSelectorAutoComplete«ENDIF»', $params);
        }
    '''
}
