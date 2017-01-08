package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.SearchView
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SearchHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for search integration')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/SearchHelper.php',
            fh.phpFileContent(it, searchHelperBaseClass), fh.phpFileContent(it, searchHelperImpl)
        )
        new SearchView().generate(it, fsa)
    }

    def private searchHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use ServiceUtil;
        use Zikula\Core\RouteUrl;
        use Zikula\SearchModule\AbstractSearchable;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Search helper base class.
         */
        abstract class AbstractSearchHelper extends AbstractSearchable
        {
            «searchHelperBaseImpl»
        }
    '''

    def private searchHelperBaseImpl(Application it) '''
        «getOptions»

        «getResults»
    '''

    def private getOptions(Application it) '''
        «val entitiesWithStrings = entities.filter[hasAbstractStringFieldsEntity]»
        /**
         * Display the search form.
         *
         * @param boolean    $active  if the module should be checked as active
         * @param array|null $modVars module form vars as previously set
         *
         * @return string Template output
         */
        public function getOptions($active, $modVars = null)
        {
            $serviceManager = ServiceUtil::getManager();
            $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');

            if (!$permissionApi->hasPermission($this->name . '::', '::', ACCESS_READ)) {
                return '';
            }

            $templateParameters = [];

            $searchTypes = array(«FOR entity : entitiesWithStrings»'«entity.name.formatForCode»'«IF entity != entitiesWithStrings.last», «ENDIF»«ENDFOR»);
            foreach ($searchTypes as $searchType) {
                $templateParameters['active_' . $searchType] = (!isset($args['«appName.toFirstLower»SearchTypes']) || in_array($searchType, $args['«appName.toFirstLower»SearchTypes']));
            }

            return $this->getContainer()->get('twig')->render('@«appName»/Search/options.html.twig', $templateParameters);
        }
    '''

    def private getResults(Application it) '''
        /**
         * Returns the search results.
         *
         * @param array      $words      Array of words to search for
         * @param string     $searchType AND|OR|EXACT (defaults to AND)
         * @param array|null $modVars    Module form vars passed though
         *
         * @return array List of fetched results
         */
        public function getResults(array $words, $searchType = 'AND', $modVars = null)
        {
            $serviceManager = ServiceUtil::getManager();
            $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');
            «IF hasCategorisableEntities»
                $featureActivationHelper = $serviceManager->get('«appService».feature_activation_helper');
            «ENDIF»
            $request = $serviceManager->get('request_stack')->getCurrentRequest();

            if (!$permissionApi->hasPermission($this->name . '::', '::', ACCESS_READ)) {
                return [];
            }

            // save session id as it is used when inserting search results below
            $session = $serviceManager->get('session');
            $sessionId = $session->getId();

            // initialise array for results
            $records = [];

            // retrieve list of activated object types
            $searchTypes = isset($modVars['objectTypes']) ? (array)$modVars['objectTypes'] : [];
            if (!is_array($searchTypes) || !count($searchTypes)) {
                if ($request->isMethod('GET')) {
                    $searchTypes = $request->query->get('«appName.toFirstLower»SearchTypes', []);
                } elseif ($request->isMethod('POST')) {
                    $searchTypes = $request->request->get('«appName.toFirstLower»SearchTypes', []);
                }
            }

            $controllerHelper = $serviceManager->get('«appService».controller_helper');
            $allowedTypes = $controllerHelper->getObjectTypes('helper', ['helper' => 'search', 'action' => 'getResults']);

            foreach ($searchTypes as $objectType) {
                if (!in_array($objectType, $allowedTypes)) {
                    continue;
                }

                $whereArray = [];
                $languageField = null;
                switch ($objectType) {
                    «FOR entity : entities.filter[hasAbstractStringFieldsEntity]»
                        case '«entity.name.formatForCode»':
                            «FOR field : entity.getAbstractStringFieldsEntity»
                                $whereArray[] = 'tbl.«field.name.formatForCode»';
                            «ENDFOR»
                            «IF entity.hasLanguageFieldsEntity»
                                $languageField = '«entity.getLanguageFieldsEntity.head.name.formatForCode»';
                            «ENDIF»
                            break;
                    «ENDFOR»
                }

                $repository = $serviceManager->get('«appService».' . $objectType . '_factory')->getRepository();

                // build the search query without any joins
                $qb = $repository->genericBaseQuery('', '', false);

                // build where expression for given search type
                $whereExpr = $this->formatWhere($qb, $words, $whereArray, $searchType);
                $qb->andWhere($whereExpr);

                $query = $qb->getQuery();

                // set a sensitive limit
                $query->setFirstResult(0)
                      ->setMaxResults(250);

                // fetch the results
                $entities = $query->getResult();

                if (count($entities) == 0) {
                    continue;
                }

                $descriptionField = $repository->getDescriptionFieldName();

                $entitiesWithDisplayAction = ['«getAllEntities.filter[hasDisplayAction].map[name.formatForCode].join('\', \'')»'];

                foreach ($entities as $entity) {
                    $urlArgs = $entity->createUrlArgs();
                    $hasDisplayAction = in_array($objectType, $entitiesWithDisplayAction);

                    $instanceId = $entity->createCompositeIdentifier();
                    // perform permission check
                    if (!$permissionApi->hasPermission($this->name . ':' . ucfirst($objectType) . ':', $instanceId . '::', ACCESS_OVERVIEW)) {
                        continue;
                    }
                    «IF hasCategorisableEntities»
                        if (in_array($objectType, ['«getCategorisableEntities.map[e|e.name.formatForCode].join('\', \'')»'])) {
                            if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                                if (!$serviceManager->get('«appService».category_helper')->hasPermission($entity)) {
                                    continue;
                                }
                            }
                        }
                    «ENDIF»

                    $description = !empty($descriptionField) ? $entity[$descriptionField] : '';
                    $created = isset($entity['createdDate']) ? $entity['createdDate'] : null;

                    $urlArgs['_locale'] = (null !== $languageField && !empty($entity[$languageField])) ? $entity[$languageField] : $request->getLocale();

                    $displayUrl = $hasDisplayAction ? new RouteUrl('«appName.formatForDB»_' . $objectType . '_display', $urlArgs) : '';

                    $records[] = [
                        'title' => $entity->getTitleFromDisplayPattern(),
                        'text' => $description,
                        'module' => $this->name,
                        'sesid' => $sessionId,
                        'created' => $created,
                        'url' => $displayUrl
                    ];
                }
            }

            return $records;
        }
    '''

    def private searchHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractSearchHelper;

        /**
         * Search helper implementation class.
         */
        class SearchHelper extends AbstractSearchHelper
        {
            // feel free to extend the search helper here
        }
    '''
}
