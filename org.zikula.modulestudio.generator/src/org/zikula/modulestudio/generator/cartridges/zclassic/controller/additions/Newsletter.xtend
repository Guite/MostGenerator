package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.NewsletterView
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Newsletter {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginPath = getAppSourceLibPath + 'NewsletterPlugin/'
        val pluginClassSuffix = if (!targets('1.3.5')) 'Plugin' else ''
        val pluginFileName = 'ItemList' + pluginClassSuffix + '.php'
        if (!generateOnlyBaseClasses && !shouldBeSkipped(pluginPath + pluginFileName)) {
            fsa.generateFile(pluginPath + pluginFileName, newsletterFile)
        }
        new NewsletterView().generate(it, fsa)
    }

    def private newsletterFile(Application it) '''
        «fh.phpFileHeader(it)»
        «newsletterClass»
    '''

    def private newsletterClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\NewsletterPlugin;

            use FormUtil;
            use ModUtil;
            use Newsletter_AbstractPlugin;
            use SecurityUtil;
            use ServiceUtil;
        «ENDIF»

        /**
         * Newsletter plugin class.
         */
        class «IF targets('1.3.5')»«appName»_NewsletterPlugin_ItemList«ELSE»ItemListPlugin«ENDIF» extends Newsletter_AbstractPlugin
        {
            «newsletterImpl»
        }
    '''

    def private newsletterImpl(Application it) '''
        «val itemDesc = getLeadingEntity.nameMultiple.formatForDisplay»
        /**
         * Returns a title being used in the newsletter. Should be short.
         *
         * @return string Title in newsletter.
         */
        public function getTitle()
        {
            return $this->__('Latest «IF getAllEntities.size < 2»«itemDesc»«ELSE»«appName» items«ENDIF»');
        }

        /**
         * Returns a display name for the admin interface.
         *
         * @return string Display name in admin area.
         */
        public function getDisplayName()
        {
            return $this->__('List of «itemDesc»«IF getAllEntities.size > 1» and other «appName» items«ENDIF»');
        }

        /**
         * Returns a description for the admin interface.
         *
         * @return string Description in admin area.
         */
        public function getDescription()
        {
            return $this->__('This plugin shows a list of «itemDesc»«IF getAllEntities.size > 1» and other items«ENDIF» of the «appName» module.');
        }

        /**
         * Determines whether this plugin is active or not.
         * An inactive plugin is not shown in the newsletter.
         *
         * @return boolean Whether the plugin is available or not.
         */
        public function pluginAvailable()
        {
            return ModUtil::available($this->modname);
        }

        /**
         * Returns custom plugin variables.
         *
         * @return array List of variables.
         */
        public function getParameters()
        {
            $objectTypes = array();
            if (ModUtil::available($this->modname) && ModUtil::loadApi($this->modname)) {
                «FOR entity : getAllEntities»
                    $objectTypes['«entity.name.formatForCode»'] = array('name' => $this->__('«entity.nameMultiple.formatForDisplayCapital»'));
                «ENDFOR»
            }
        
            $active = $this->getPluginVar('ObjectTypes', array());
            foreach ($objectTypes as $k => $v) {
                $objectTypes[$k]['nwactive'] = in_array($k, $active);
            }

            $args = $this->getPluginVar('Args', array());
        
            return array('number' => 1,
                         'param'  => array(
                               'ObjectTypes'=> $objectTypes,
                               'Args' => $args));
        }

        /**
         * Sets custom plugin variables.
         */
        public function setParameters()
        {
            // Object types to be used in the newsletter
            $objectTypes = FormUtil::getPassedValue($this->modname . 'ObjectTypes', array(), 'POST');

            $this->setPluginVar('ObjectTypes', array_keys($objectTypes));

            // Additional arguments
            $args = FormUtil::getPassedValue($this->modname . 'Args', array(), 'POST');

            $this->setPluginVar('Args', $args);
        }

        /**
         * Returns data for the Newsletter plugin.
         *
         * @param datetime $filtAfterDate Optional date filter (items should be newer), format yyyy-mm-dd hh:mm:ss or null if not set
         *
         * @return array List of affected content items.
         */
        public function getPluginData($filtAfterDate = null)
        {
            if (!$this->pluginAvailable()) {
                return array();
            }
            ModUtil::initOOModule($this->modname);

            // collect data for each activated object type
            $itemsGrouped = $this->getItemsPerObjectType($filtAfterDate);

            // now flatten for presentation
            $items = array();
            if ($itemsGrouped) {
                foreach ($itemsGrouped as $objectTypes => $itemList) {
                    foreach ($itemList as $item) {
                        $items[] = $item;
                    }
                }
            }

            return $items;
        }

        /**
         * Collects newsletter data for each activated object type.
         *
         * @param datetime $filtAfterDate Optional date filter (items should be newer), format yyyy-mm-dd hh:mm:ss or null if not set
         *
         * @return array Data grouped by object type.
         */
        protected function getItemsPerObjectType($filtAfterDate = null)
        {
            $objectTypes = $this->getPluginVar('ObjectTypes', array());
            $args = $this->getPluginVar('Args', array());

            $output = array();

            foreach ($objectTypes as $objectType) {
                if (!SecurityUtil::checkPermission($this->modname . ':' . ucwords($objectType) . ':', '::', ACCESS_READ, $this->userNewsletter)) {
                    // the newsletter has no permission for these items
                    continue;
                }

                $otArgs = isset($args[$objectType]) ? $args[$objectType] : array();
                $otArgs['objectType'] = $objectType;

                // perform the data selection
                $output[$objectType] = $this->selectPluginData($otArgs, $filtAfterDate);
            }

            return $output;
        }

        /**
         * Performs the internal data selection.
         *
         * @param array    $args          Arguments array (contains object type).
         * @param datetime $filtAfterDate Optional date filter (items should be newer), format yyyy-mm-dd hh:mm:ss or null if not set
         *
         * @return array List of selected items.
         */
        protected function selectPluginData($args, $filtAfterDate = null)
        {
            $objectType = $args['objectType'];
            «IF targets('1.3.5')»
                $entityClass = '«appName»_Entity_' . ucwords($objectType);
            «ELSE»
                $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucwords($objectType) . 'Entity';
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);

            // create query
            $where = isset($args['filter']) ? $args['filter'] : '';
            $orderBy = $this->getSortParam($args, $repository);
            $qb = $repository->genericBaseQuery($where, $orderBy);

            if ($filtAfterDate) {
                $startDateFieldName = $repository->getStartDateFieldName();
                if ($startDateFieldName == 'createdDate') {
                    $qb->andWhere('tbl.createdDate > :afterDate')
                       ->setParameter('afterDate', $filtAfterDate);
                }
            }

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = isset($args['amount']) && is_numeric($args['amount']) ? $args['amount'] : $this->nItems;
            list($query, $count) = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            $entities = $query->getResult();

            // post processing
            $descriptionFieldName = $repository->getDescriptionFieldName();
            «IF hasImageFields»
                $previewFieldName = $repository->getPreviewFieldName();
            «ENDIF»

            $items = array();
            foreach ($entities as $k => $item) {
                $items[$k] = array();

                // Set title of this item.
                $items[$k]['nl_title'] = $item->getTitleFromDisplayPattern();

                «IF hasUserController && getMainUserController.hasActions('display')»
                    // Set (full qualified) link of title
                    $urlArgs = $item->createUrlArgs();
                    $urlArgs['lang'] = $this->lang;
                    $items[$k]['nl_url_title'] = ModUtil::url($this->modname, 'user', 'display', $urlArgs, null, null, true);
                «ELSE»
                    $items[$k]['nl_url_title'] = null;
                «ENDIF»

                // Set main content of the item.
                $items[$k]['nl_content'] = $descriptionFieldName ? $item[$descriptionFieldName] : '';

                // Url for further reading. In this case it is the same as used for the title.
                $items[$k]['nl_url_readmore'] = $items[$k]['nl_url_title'];

                // A picture to display in Newsletter next to the item
                «IF hasImageFields»
                    $items[$k]['nl_picture'] = $previewFieldName != '' ? $item[$previewFieldName . 'FullPath'] : null;
                «ELSE»
                    $items[$k]['nl_picture'] = '';
                «ENDIF»
            }

            return $items;
        }

        /**
         * Determines the order by parameter for item selection.
         *
         * @param array               $args       List of plugin variables.
         * @param Doctrine_Repository $repository The repository used for data fetching.
         *
         * @return string the sorting clause.
         */
        protected function getSortParam($args, $repository)
        {
            if ($args['sorting'] == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($args['sorting'] == 'newest') {
                $idFields = ModUtil::apiFunc($this->modname, 'selection', 'getIdFields', array('ot' => $args['objectType']));
                if (count($idFields) == 1) {
                    $sortParam = $idFields[0] . ' DESC';
                } else {
                    foreach ($idFields as $idField) {
                        if (!empty($sortParam)) {
                            $sortParam .= ', ';
                        }
                        $sortParam .= $idField . ' DESC';
                    }
                }
            } elseif ($args['sorting'] == 'default') {
                $sortParam = $repository->getDefaultSortingField() . ' ASC';
            }

            return $sortParam;
        }
    '''
}
