package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UrlRouting {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Start point for the router creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating router facade for short url resolution')
        fsa.generateFile(appName.getAppSourceLibPath + 'Base/RouterFacade.php', routerFacadeBaseFile)
        fsa.generateFile(appName.getAppSourceLibPath + 'RouterFacade.php', routerFacadeFile)
    }

    def private routerFacadeBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«routerFacadeBaseImpl»
    '''

    def private routerFacadeFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«routerFacadeImpl»
    '''

    def private routerFacadeBaseImpl(Application it) '''
        /**
         * Url router facade base class
         */
        class «appName»_Base_RouterFacade
        {
            /**
             * @var Zikula_Routing_UrlRouter The router which is used internally
             */
            protected $router;

            /**
             * @var array Common requirement definitions
             */
            protected $requirements;

            /**
             * Constructor.
             */
            function __construct()
            {
                $displayDefaultEnding = System::getVar('shorturlsext', 'html');
                «/*Modifier: + (1..n), * (0..n), ? (0..1), {x,y} (x..y)*/»
                $this->requirements = array(
                    'func'          => '\w+',
                    'ot'            => '\w+',
                    'slug'          => '[^/.]+', // slugs ([^/.]+ = all chars except / and .)
                    'displayending' => '(?:' . $displayDefaultEnding . '|xml|pdf|json|kml)',
                    'viewending'    => '(?:\.csv|\.rss|\.atom|\.xml|\.pdf|\.json|\.kml)?',
                    'id'            => '\d+'
                );

                // initialise and reference router instance
                $this->router = new Zikula_Routing_UrlRouter();

                // add generic routes
                return $this->initUrlRoutes();
            }

            «initUrlRoutes»

            «getGroupingFolderFromObjectType»

            «getObjectTypeFromGroupingFolder»

            «getFormattedSlug»

            «fh.getterAndSetterMethods(it, 'router', 'Zikula_Routing_UrlRouter', false, true, 'null')»
        }
    '''

    def private initUrlRoutes(Application it) '''
        «val userController = getMainUserController»
        /**
         * Initialise the url routes for this application.
         *
         * @return Zikula_Routing_UrlRouter The router instance treating all initialised routes
         */
        protected function initUrlRoutes()
        {
            $fieldRequirements = $this->requirements;
            $isDefaultModule = (System::getVar('shorturlsdefaultmodule', '') == '«appName»');

            $defaults = array();
            $modulePrefix = '';
            if (!$isDefaultModule) {
                $defaults['module'] = '«appName»';
                $modulePrefix = ':module/';
            }

            «IF userController.hasActions('view')»
                $defaults['func'] = 'view';
                $viewFolder = 'view';
                // normal views (e.g. orders/ or customers.xml)
                $this->router->set('va', new Zikula_Routing_UrlRoute($modulePrefix . $viewFolder . '/:ot:viewending', $defaults, $fieldRequirements));

                // TODO filter views (e.g. /orders/customer/mr-smith.csv)
                // $this->initRouteForEachSlugType('vn', $modulePrefix . $viewFolder . '/:ot/:filterot/', ':viewending', $defaults, $fieldRequirements);
            «ENDIF»

            «IF userController.hasActions('display')»
                $defaults['func'] = 'display';
                // normal display pages including the group folder corresponding to the object type
                $this->initRouteForEachSlugType('dn', $modulePrefix . ':ot/', ':displayending', $defaults, $fieldRequirements);

                // additional rules for the leading object type (where ot is omitted)
                $defaults['ot'] = '«getLeadingEntity.name.formatForCode»';
                $this->initRouteForEachSlugType('dl', $modulePrefix . '', ':displayending', $defaults, $fieldRequirements);
            «ENDIF»

            return $this->router;
        }

        /**
         * Helper function to route permalinks for different slug types.
         *
         * @param string $prefix
         * @param string $patternStart
         * @param string $patternEnd
         * @param string $defaults
         * @param string $fieldRequirements
         */
        protected function initRouteForEachSlugType($prefix, $patternStart, $patternEnd, $defaults, $fieldRequirements)
        {
            // entities with unique slug (slug only)
            $this->router->set($prefix . 'a', new Zikula_Routing_UrlRoute($patternStart . ':slug.' . $patternEnd,        $defaults, $fieldRequirements));
            // entities with non-unique slug (slug and id)
            $this->router->set($prefix . 'b', new Zikula_Routing_UrlRoute($patternStart . ':slug.:id.' . $patternEnd,    $defaults, $fieldRequirements));
            // entities without slug (id)
            $this->router->set($prefix . 'c', new Zikula_Routing_UrlRoute($patternStart . 'id.:id.' . $patternEnd,        $defaults, $fieldRequirements));
        }
    '''

    def private getGroupingFolderFromObjectType(Application it) '''
        /**
         * Get name of grouping folder for given object type and function.
         *
         * @param string $objectType Name of treated entity type.
         * @param string $func       Name of function.
         *
         * @return string Name of the group folder
         */
        public function getGroupingFolderFromObjectType($objectType, $func)
        {
            // object type will be used as a fallback
            $groupFolder = $objectType;

            if ($func == 'view') {
                switch ($objectType) {
                    «FOR entity : getAllEntities»«entity.getGroupingFolderFromObjectType(true)»«ENDFOR»
                    default: return '';
                }
            } else if ($func == 'display') {
                switch ($objectType) {
                    «FOR entity : getAllEntities»«entity.getGroupingFolderFromObjectType(false)»«ENDFOR»
                    default: return '';
                }
            }

            return $groupFolder;
        }
    '''

    def private getObjectTypeFromGroupingFolder(Application it) '''
        /**
         * Get name of object type based on given grouping folder.
         *
         * @param string $groupFolder Name of group folder.
         * @param string $func        Name of function.
         *
         * @return string Name of the object type.
         */
        public function getObjectTypeFromGroupingFolder($groupFolder, $func)
        {
            // group folder will be used as a fallback
            $objectType = $groupFolder;

            if ($func == 'view') {
                switch ($groupFolder) {
                    «FOR entity : getAllEntities»«entity.getObjectTypeFromGroupingFolder(true)»«ENDFOR»
                    default: return '';
                }
            } else if ($func == 'display') {
                switch ($groupFolder) {
                    «FOR entity : getAllEntities»«entity.getObjectTypeFromGroupingFolder(false)»«ENDFOR»
                    default: return '';
                }
            }

            return $objectType;
        }
    '''

    def private getGroupingFolderFromObjectType(Entity it, Boolean plural) '''
                case '«name.formatForCode»':
                            $groupFolder = '«getEntityNameSingularPlural(plural).formatForDB»';
                            break;
    '''

    def private getObjectTypeFromGroupingFolder(Entity it, Boolean plural) '''
                case '«getEntityNameSingularPlural(plural).formatForDB»':
                            $objectType = '«name.formatForCode»';
                            break;
    '''

    def private getFormattedSlug(Application it) '''
        /**
         * Get permalink value based on slug properties.
         *
         * @param string  $objectType Name of treated entity type.
         * @param string  $func       Name of function.
         * @param array   $args       Additional parameters.
         * @param integer $itemid     Identifier of treated item.
         *
         * @return string The resulting url ending.
         */
        public function getFormattedSlug($objectType, $func, $args, $itemid)
        {
            $slug = '';

            switch ($objectType) {
                «FOR entity : getAllEntities»«entity.getSlugForItem»«ENDFOR»
            }

            return $slug;
        }
    '''

    def private getSlugForItem(Entity it) '''
            case '«name.formatForCode»':
                «IF hasSluggableFields»
                        $item = ModUtil::apiFunc('«container.application.appName»', 'selection', 'getEntity', array('ot' => $objectType, 'id' => $itemid, 'slimMode' => true));
                        «IF slugUnique»
                            $slug = $item['slug'];
                        «ELSE»
                            // make non-unique slug unique by adding the identifier
                            $idFields = ModUtil::apiFunc('«container.application.appName»', 'selection', 'getIdFields', array('ot' => $objectType));

                            // concatenate identifiers (for composite keys)
                            $itemId = '';
                            foreach ($idFields as $idField) {
                                $itemId .= ((!empty($itemId)) ? '_' : '') . $item[$idField];
                            }
                            $slug = $item['slug'] . '.' . $itemId;
                        «ENDIF»
                «ELSE»
                        $slug = $itemid;
                «ENDIF»
                        break;
    '''

    def private routerFacadeImpl(Application it) '''
        /**
         * Url router facade implementation class.
         */
        class «appName»_RouterFacade extends «appName»_Base_RouterFacade
        {
            // here you can customise the data which is provided to the url router.
        }
    '''
}
