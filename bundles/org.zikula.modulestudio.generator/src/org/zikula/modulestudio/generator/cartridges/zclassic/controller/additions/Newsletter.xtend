package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
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
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginPath = getAppSourceLibPath + 'NewsletterPlugin/'
        val pluginClassSuffix = if (!targets('1.3.x')) 'Plugin' else ''
        var pluginFileName = 'ItemList' + pluginClassSuffix + '.php'
        if (!generateOnlyBaseClasses && !shouldBeSkipped(pluginPath + pluginFileName)) {
            if (shouldBeMarked(pluginPath + pluginFileName)) {
                pluginFileName = 'ItemList' + pluginClassSuffix + '.generated.php'
            }
            fsa.generateFile(pluginPath + pluginFileName, fh.phpFileContent(it, newsletterClass))
        }
        new NewsletterView().generate(it, fsa)
    }

    def private newsletterClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\NewsletterPlugin;

            use FormUtil;
            use ModUtil;
            use Newsletter_AbstractPlugin;
            use ServiceUtil;
        «ENDIF»

        /**
         * Newsletter plugin class.
         */
        class «IF targets('1.3.x')»«appName»_NewsletterPlugin_ItemList«ELSE»ItemListPlugin«ENDIF» extends Newsletter_AbstractPlugin
        {
            «newsletterImpl»
        }
    '''

    def private newsletterImpl(Application it) '''
        «val itemDesc = getLeadingEntity.nameMultiple.formatForDisplay»
        /**
         * Returns a title being used in the newsletter. Should be short.
         *
         * @return string Title in newsletter
         */
        public function getTitle()
        {
            «IF targets('1.3.x')»
                return $this->__('Latest «IF entities.size < 2»«itemDesc»«ELSE»«appName» items«ENDIF»');
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->get('translator.default')->__('Latest «IF entities.size < 2»«itemDesc»«ELSE»«appName» items«ENDIF»');
            «ENDIF»
        }

        /**
         * Returns a display name for the admin interface.
         *
         * @return string Display name in admin area
         */
        public function getDisplayName()
        {
            «IF targets('1.3.x')»
                return $this->__('List of «itemDesc»«IF entities.size > 1» and other «appName» items«ENDIF»');
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->get('translator.default')->__('List of «itemDesc»«IF entities.size > 1» and other «appName» items«ENDIF»');
            «ENDIF»
        }

        /**
         * Returns a description for the admin interface.
         *
         * @return string Description in admin area
         */
        public function getDescription()
        {
            «IF targets('1.3.x')»
                return $this->__('This plugin shows a list of «itemDesc»«IF entities.size > 1» and other items«ENDIF» of the «appName» module.');
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
            
                return $serviceManager->get('translator.default')->__('This plugin shows a list of «itemDesc»«IF entities.size > 1» and other items«ENDIF» of the «appName» module.');
            «ENDIF»
        }

        /**
         * Determines whether this plugin is active or not.
         * An inactive plugin is not shown in the newsletter.
         *
         * @return boolean Whether the plugin is available or not
         */
        public function pluginAvailable()
        {
            «IF targets('1.3.x')»
                return ModUtil::available($this->modname);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
                $kernel = $serviceManager->get('kernel');

                return null !== $kernel->getModule($this->modname);
            «ENDIF»
        }

        /**
         * Returns custom plugin variables.
         *
         * @return array List of variables
         */
        public function getParameters()
        {
            «IF !targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $translator = $serviceManager->get('translator.default');

            «ENDIF»
            $objectTypes = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            if ($this->pluginAvailable()«IF targets('1.3.x')» && ModUtil::loadApi($this->modname)«ENDIF») {
                «FOR entity : getAllEntities»
                    «IF targets('1.3.x')»
                        $objectTypes['«entity.name.formatForCode»'] = array('name' => $this->__('«entity.nameMultiple.formatForDisplayCapital»'));
                    «ELSE»
                        $objectTypes['«entity.name.formatForCode»'] = ['name' => $translator->__('«entity.nameMultiple.formatForDisplayCapital»')];
                    «ENDIF»
                «ENDFOR»
            }

            $active = $this->getPluginVar('ObjectTypes', «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»);
            foreach ($objectTypes as $k => $v) {
                $objectTypes[$k]['nwactive'] = in_array($k, $active);
            }

            $args = $this->getPluginVar('Args', «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»);

            return «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'number' => 1,
                'param'  => «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                    'ObjectTypes'=> $objectTypes,
                    'Args' => $args
                «IF targets('1.3.x')»)«ELSE»]«ENDIF»
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;
        }

        /**
         * Sets custom plugin variables.
         */
        public function setParameters()
        {
            // Object types to be used in the newsletter
            $objectTypes = FormUtil::getPassedValue($this->modname . 'ObjectTypes', «IF targets('1.3.x')»array()«ELSE»[]«ENDIF», 'POST');

            $this->setPluginVar('ObjectTypes', array_keys($objectTypes));

            // Additional arguments
            $args = FormUtil::getPassedValue($this->modname . 'Args', «IF targets('1.3.x')»array()«ELSE»[]«ENDIF», 'POST');

            $this->setPluginVar('Args', $args);
        }

        /**
         * Returns data for the Newsletter plugin.
         *
         * @param datetime $filtAfterDate Optional date filter (items should be newer), format yyyy-mm-dd hh:mm:ss or null if not set
         *
         * @return array List of affected content items
         */
        public function getPluginData($filtAfterDate = null)
        {
            if (!$this->pluginAvailable()) {
                return «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            }
            «IF targets('1.3.x')»
                ModUtil::initOOModule($this->modname);
            «ENDIF»

            // collect data for each activated object type
            $itemsGrouped = $this->getItemsPerObjectType($filtAfterDate);

            // now flatten for presentation
            $items = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
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
         * @return array Data grouped by object type
         */
        protected function getItemsPerObjectType($filtAfterDate = null)
        {
            $objectTypes = $this->getPluginVar('ObjectTypes', «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»);
            $args = $this->getPluginVar('Args', «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»);

            «IF !targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');

            «ENDIF»
            $output = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

            foreach ($objectTypes as $objectType) {
                if (!«IF targets('1.3.x')»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission($this->modname . ':' . ucfirst($objectType) . ':', '::', ACCESS_READ, $this->userNewsletter)) {
                    // the newsletter has no permission for these items
                    continue;
                }

                $otArgs = isset($args[$objectType]) ? $args[$objectType] : «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                $otArgs['objectType'] = $objectType;

                // perform the data selection
                $output[$objectType] = $this->selectPluginData($otArgs, $filtAfterDate);
            }

            return $output;
        }

        /**
         * Performs the internal data selection.
         *
         * @param array    $args          Arguments array (contains object type)
         * @param datetime $filtAfterDate Optional date filter (items should be newer), format yyyy-mm-dd hh:mm:ss or null if not set
         *
         * @return array List of selected items
         */
        protected function selectPluginData($args, $filtAfterDate = null)
        {
            $objectType = $args['objectType'];
            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $entityManager = $serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('«entityManagerService»');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $serviceManager->get('«appService».' . $objectType . '_factory')->getRepository();
            «ENDIF»

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
            $entities = $repository->retrieveCollectionResult($query, $orderBy, true);

            // post processing
            $descriptionFieldName = $repository->getDescriptionFieldName();
            «IF hasImageFields»
                $previewFieldName = $repository->getPreviewFieldName();
            «ENDIF»

            $items = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            foreach ($entities as $k => $item) {
                $items[$k] = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

                // Set title of this item.
                $items[$k]['nl_title'] = $item->getTitleFromDisplayPattern();

                «IF hasUserController && getMainUserController.hasActions('display')»
                    // Set (full qualified) link of title
                    $urlArgs = $item->createUrlArgs();
                    $urlArgs['lang'] = $this->lang;
                    «IF targets('1.3.x')»
                        $items[$k]['nl_url_title'] = ModUtil::url($this->modname, 'user', 'display', $urlArgs, null, null, true);
                    «ELSE»
                        $url = $serviceManager->get('router')->generate('«appName.formatForDB»_' . strtolower($objectType) . '_display', $urlArgs, true);
                    «ENDIF»
                «ELSE»
                    $items[$k]['nl_url_title'] = null;
                «ENDIF»

                // Set main content of the item.
                $items[$k]['nl_content'] = $descriptionFieldName ? $item[$descriptionFieldName] : '';

                // Url for further reading. In this case it is the same as used for the title.
                $items[$k]['nl_url_readmore'] = $items[$k]['nl_url_title'];

                // A picture to display in Newsletter next to the item
                «IF hasImageFields»
                    «IF targets('1.3.x')»
                        $items[$k]['nl_picture'] = $previewFieldName != '' && !empty($item[$previewFieldName) ? $item[$previewFieldName . 'FullPath'] : '';
                    «ELSE»
                        $items[$k]['nl_picture'] = $previewFieldName != '' && !empty($item[$previewFieldName) ? $item[$previewFieldName]->getRelativePathname() : '';
                    «ENDIF»
                «ELSE»
                    $items[$k]['nl_picture'] = '';
                «ENDIF»
            }

            return $items;
        }

        /**
         * Determines the order by parameter for item selection.
         *
         * @param array               $args       List of plugin variables
         * @param Doctrine_Repository $repository The repository used for data fetching
         *
         * @return string the sorting clause
         */
        protected function getSortParam($args, $repository)
        {
            if ($args['sorting'] == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($args['sorting'] == 'newest') {
                «IF targets('1.3.x')»
                    $idFields = ModUtil::apiFunc($this->modname, 'selection', 'getIdFields', array('ot' => $args['objectType']));
                «ELSE»
                    $selectionHelper = ServiceUtil::get('«appService».selection_helper');
                    $idFields = $selectionHelper->getIdFields($args['objectType']);
                «ENDIF»
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
