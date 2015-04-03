package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.UserController
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ShortUrlsLegacy {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    Application app

    new(Application it) {
        app = it
    }

    def dispatch generate(Controller it) {
    }

    def dispatch generate (UserController it) '''

        «encodeUrl»

        «decodeUrl»
    '''

    def encodeUrl (UserController it) '''
        /**
         * Forms custom url string.
         *
         * @param array $args List of arguments.
         *
         * @return string custom url string
         */
        public function encodeurl(array $args = array())
        {
            // check if we have the required input
            if (!isset($args['modname']) || !isset($args['func'])) {
                throw new \InvalidArgumentException(__('Invalid arguments array received.'));
            }

            // set default values
            if (!isset($args['type'])) {
                $args['type'] = 'user';
            }
            if (!isset($args['args'])) {
                $args['args'] = array();
            }

            // return if function url scheme is not being customised
            $customFuncs = array(«IF hasActions('view')»'view'«IF hasActions('display')», «ENDIF»«ENDIF»«IF hasActions('display')»'display'«ENDIF»);
            if (!in_array($args['func'], $customFuncs)) {
                return false;
            }

            // initialise url routing rules
            $routerFacade = new «IF app.targets('1.3.x')»«app.appName»_«ENDIF»RouterFacade();
            // get router itself for convenience
            $router = $routerFacade->getRouter();

            // initialise object type
            «IF app.targets('1.3.x')»
                $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->serviceManager->get('«app.appName.formatForDB».controller_helper');
            «ENDIF»
            $utilArgs = array('controller' => 'user', 'action' => 'encodeurl');
            $allowedObjectTypes = $controllerHelper->getObjectTypes('api', $utilArgs);
            $objectType = ((isset($args['args']['ot']) && in_array($args['args']['ot'], $allowedObjectTypes)) ? $args['args']['ot'] : $controllerHelper->getDefaultObjectType('api', $utilArgs));

            // initialise group folder
            $groupFolder = $routerFacade->getGroupingFolderFromObjectType($objectType, $args['func'], $args['args']);

            // start pre processing

            // convert object type to group folder
            $args['args']['ot'] = $groupFolder;

            // handle special templates
            $displayDefaultEnding = System::getVar('shorturlsext', 'html');
            $endingPrefix = ($args['func'] == 'view') ? '.' : '';
            foreach (array('csv', 'rss', 'atom', 'xml', 'pdf', 'json', 'kml') as $ending) {
                if (!isset($args['args']['use' . $ending . 'ext'])) {
                    continue;
                }
                if ($args['args']['use' . $ending . 'ext'] == '1') {
                    $args['args'][$args['func'] . 'ending'] = $endingPrefix . $ending;
                }
                unset($args['args']['use' . $ending . 'ext']);
            }
            // fallback to default templates
            if (!isset($args['args'][$args['func'] . 'ending'])) {
                if ($args['func'] == 'view') {
                    $args['args'][$args['func'] . 'ending'] = '';//'/';
                } else if ($args['func'] == 'display') {
                    $args['args'][$args['func'] . 'ending'] = $displayDefaultEnding;
                }
            }

            if ($args['func'] == 'view') {
                // TODO filter views (e.g. /orders/customer/mr-smith.csv)
                /**
                $filterEntities = array('customer', 'region', 'federalstate', 'country');
                foreach ($filterEntities as $filterEntity) {
                    $filterField = $filterEntity . 'id';
                    if (!isset($args['args'][$filterField]) || !$args['args'][$filterField]) {
                        continue;
                    }
                    $filterId = $args['args'][$filterField];
                    unset($args['args'][$filterField]);

                    $filterGroupFolder = $routerFacade->getGroupingFolderFromObjectType($filterEntity, 'display', $args['args']);
                    $filterSlug = $routerFacade->getFormattedSlug($filterEntity, 'display', $args['args'], $filterId);
                    $result .= $filterGroupFolder . '/' . $filterSlug .'/';
                    break;
                }
                */
            } elseif ($args['func'] == 'display') {
                // determine given id
                $id = 0;
                foreach (array('id', strtolower($objectType) . 'id', 'objectid') as $idFieldName) {
                    if (isset($args['args'][$idFieldName])) {
                        $id = $args['args'][$idFieldName];
                        unset($args['args'][$idFieldName]);
                    }
                }

                // check if we have a valid slug given
                if (isset($args['args']['slug']) && (!$args['args']['slug'] || $args['args']['slug'] == $id)) {
                    unset($args['args']['slug']);
                }
                // try to determine missing slug
                if (!isset($args['args']['slug'])) {
                    $slug = '';
                    if ($id > 0) {
                        $slug = $routerFacade->getFormattedSlug($objectType, $args['func'], $args['args'], $id);
                    }
                    if (!empty($slug) && $slug != $id) {
                        // add slug expression
                        $args['args']['slug'] = $slug;
                    }
                }
                // check if we have one now
                if (!isset($args['args']['slug'])) {
                    // readd id as fallback
                    $args['args']['id'] = $id;
                }
            }

            // add func as first argument
            $routerArgs = array_merge(array('func' => $args['func']), $args['args']);

            // now create url based on params
            $result = $router->generate(null, $routerArgs);

            // post processing
            if (
                ($args['func'] == 'view' && !empty($args['args']['viewending']))
                || $args['func'] == 'display') {
                // check if url ends with a trailing slash
                if (substr($result, -1) == '/') {
                    // remove the trailing slash
                    $result = substr($result, 0, strlen($result) - 1);
                }
            }

            // enforce url name of the module, but do only 1 replacement to avoid changing other params
            $modInfo = ModUtil::getInfoFromName('«app.appName»');
            $result = preg_replace('/' . $modInfo['name'] . '/', $modInfo['url'], $result, 1);

            return $result;
        }
    '''

    def decodeUrl (UserController it) '''
        /**
         * Decodes the custom url string.
         *
         * @param array $args List of arguments.
         *
         * @return bool true if successful, false otherwise
         */
        public function decodeurl(array $args = array())
        {
            // check we actually have some vars to work with
            if (!is_array($args) || !isset($args['vars']) || !is_array($args['vars']) || !count($args['vars'])) {
                throw new \InvalidArgumentException(__('Invalid arguments array received.'));
            }

            // define the available user functions
            $funcs = array(«FOR action : getAllUserActions SEPARATOR ', '»'«IF !application.targets('1.3.x') && action.toLowerCase == 'main'»index«ELSE»«action»«ENDIF»'«ENDFOR»);

            // return if function url scheme is not being customised
            $customFuncs = array(«IF hasActions('view')»'view'«IF hasActions('display')», «ENDIF»«ENDIF»«IF hasActions('display')»'display'«ENDIF»);

            // set the correct function name based on our input
            if (empty($args['vars'][2])) {
                // no func and no vars = «IF application.targets('1.3.x')»main«ELSE»index«ENDIF»
                System::queryStringSetVar('func', '«IF application.targets('1.3.x')»main«ELSE»index«ENDIF»');
                return true;
            } else if (in_array($args['vars'][2], $funcs) && !in_array($args['vars'][2], $customFuncs)) {
                // normal url scheme, no need for special decoding
                return false;
            }

            $func = $args['vars'][2];

            // usually the language is in $args['vars'][0], except no mod name is in the url and we are set as start app
            $modInfo = ModUtil::getInfoFromName('«app.appName»');
            $lang = (strtolower($args['vars'][0]) == $modInfo['url']) ? $args['vars'][1] : $args['vars'][0];

            // remove some unrequired parameters
            foreach ($_GET as $k => $v) {
                if (in_array($k, array('module', 'type', 'func', 'lang', 'ot')) === false) {
                    unset($_GET[$k]);
                }
            }

            // process all args except language and module
            $urlVars = array_slice($args['vars'], 2); // all except [0] and [1]

            // get arguments as string
            $url = implode('/', $urlVars);

            // check if default view urls end with a trailing slash
            if ($func == 'view' && strpos($url, '.') === false && substr($url, -1) != '/') {
                // add missing trailing slash
                $url .= '/';
            }

            $isDefaultModule = (System::getVar('shorturlsdefaultmodule', '') == $modInfo['name']);
            if (!$isDefaultModule) {
                $url = $modInfo['url'] . '/' . $url;
            }

            // initialise url routing rules
            $routerFacade = new «IF app.targets('1.3.x')»«app.appName»_«ENDIF»RouterFacade();
            // get router itself for convenience
            $router = $routerFacade->getRouter();

            // read params out of url
            $parameters = $router->parse($url);
            //var_dump($parameters);

            if (!$parameters || !is_array($parameters)) {
                return false;
            }

            // post processing
            if (!isset($parameters['func'])) {
                $parameters['func'] = '«IF hasActions('view')»view«ELSEIF hasActions('display')»display«ELSE»«IF application.targets('1.3.x')»main«ELSE»index«ENDIF»«ENDIF»';
            }

            $func = $parameters['func'];
            // convert group folder to object type
            $parameters['ot'] = $routerFacade->getObjectTypeFromGroupingFolder($parameters['ot'], $func);

            // handle special templates
            $displayDefaultEnding = System::getVar('shorturlsext', 'html');
            $endingPrefix = ($func == 'view') ? '.' : '';
            if (isset($parameters[$func . 'ending']) && !empty($parameters[$func . 'ending']) && $parameters[$func . 'ending'] != ($endingPrefix . $displayDefaultEnding)) {
                if ($func == 'view') {
                    $parameters[$func . 'ending'] = str_replace($endingPrefix, '', $parameters[$func . 'ending']);
                }
                $parameters['use' . $parameters[$func . 'ending'] . 'ext'] = '1';
                unset($parameters[$func . 'ending']);
            }

            // rename id to objid (primary key for display pages, optional filter id for view pages)
            /* may be obsolete now
            if (isset($parameters['id'])) {
                $parameters[strtolower($parameters['ot']) . 'id'] = $parameters['id'];
                unset($parameters['id']);
            }*/

            // write vars to GET
            foreach ($parameters as $k => $v) {
                System::queryStringSetVar($k, $v);
            }

            return true;
        }
    '''
}
