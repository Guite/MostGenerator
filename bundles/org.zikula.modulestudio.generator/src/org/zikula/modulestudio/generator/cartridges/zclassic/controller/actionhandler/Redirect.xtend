package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Redirect processing functions for edit form handlers.
 */
class Redirect {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def getRedirectCodes(Application it) '''
        /**
         * Get list of allowed redirect codes.
         *
         * @return array list of possible redirect codes
         */
        protected function getRedirectCodes()
        {
            $codes = [];

            // to be filled by subclasses

            return $codes;
        }
    '''

    def getRedirectCodes(Entity it, Application app) '''
        /**
         * Get list of allowed redirect codes.
         *
         * @return array list of possible redirect codes
         */
        protected function getRedirectCodes()
        {
            $codes = parent::getRedirectCodes();

            «IF hasIndexAction»
                // user index page of «name.formatForDisplay» area
                $codes[] = 'userIndex';
                // admin index page of «name.formatForDisplay» area
                $codes[] = 'adminIndex';
            «ENDIF»
            «IF hasViewAction»
                // user list of «nameMultiple.formatForDisplay»
                $codes[] = 'userView';
                // admin list of «nameMultiple.formatForDisplay»
                $codes[] = 'adminView';
                «IF standardFields»
                    // user list of own «nameMultiple.formatForDisplay»
                    $codes[] = 'userOwnView';
                    // admin list of own «nameMultiple.formatForDisplay»
                    $codes[] = 'adminOwnView';
                «ENDIF»
            «ENDIF»
            «IF hasDisplayAction»
                // user detail page of treated «name.formatForDisplay»
                $codes[] = 'userDisplay';
                // admin detail page of treated «name.formatForDisplay»
                $codes[] = 'adminDisplay';
            «ENDIF»

            «FOR incomingRelation : getIncomingJoinRelationsWithOneSource.filter[source.application == app && source instanceof Entity]»
                «val sourceEntity = incomingRelation.source as Entity»
                «IF sourceEntity.name != it.name»
                    «IF sourceEntity.hasViewAction»
                        // user list of «sourceEntity.nameMultiple.formatForDisplay»
                        $codes[] = 'userView«sourceEntity.nameMultiple.formatForCodeCapital»';
                        // admin list of «sourceEntity.nameMultiple.formatForDisplay»
                        $codes[] = 'adminView«sourceEntity.nameMultiple.formatForCodeCapital»';
                        «IF sourceEntity.standardFields»
                            // user list of own «sourceEntity.nameMultiple.formatForDisplay»
                            $codes[] = 'userOwnView«sourceEntity.nameMultiple.formatForCodeCapital»';
                            // admin list of own «sourceEntity.nameMultiple.formatForDisplay»
                            $codes[] = 'adminOwnView«sourceEntity.nameMultiple.formatForCodeCapital»';
                        «ENDIF»
                    «ENDIF»
                    «IF sourceEntity.hasDisplayAction»
                        // user detail page of related «sourceEntity.name.formatForDisplay»
                        $codes[] = 'userDisplay«sourceEntity.name.formatForCodeCapital»';
                        // admin detail page of related «sourceEntity.name.formatForDisplay»
                        $codes[] = 'adminDisplay«sourceEntity.name.formatForCodeCapital»';
                    «ENDIF»
                «ENDIF»
            «ENDFOR»

            return $codes;
        }
    '''

    def getDefaultReturnUrl(Entity it, Application app) '''
        /**
         * Get the default redirect url. Required if no returnTo parameter has been supplied.
         * This method is called in handleCommand so we know which command has been performed.
         *
         * @param array $args List of arguments
         *
         * @return string The default redirect url
         */
        protected function getDefaultReturnUrl($args)
        {
            $objectIsPersisted = $args['commandName'] != 'delete' && !($this->templateParameters['mode'] == 'create' && $args['commandName'] == 'cancel');

            if (null !== $this->returnTo) {
                $isDisplayOrEditPage = substr($this->returnTo, -7) == 'display' || substr($this->returnTo, -4) == 'edit';«/* TODO improve this check considering slugs */»
                if (!$isDisplayOrEditPage || $objectIsPersisted) {
                    // return to referer
                    return $this->returnTo;
                }
            }

            «IF hasIndexAction || hasViewAction || hasDisplayAction && tree != EntityTreeType.NONE»
                $routeArea = array_key_exists('routeArea', $this->templateParameters) ? $this->templateParameters['routeArea'] : '';
                $routePrefix = '«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea;

            «ENDIF»
            «IF hasViewAction»
                // redirect to the list of «nameMultiple.formatForCode»
                $url = $this->router->generate($routePrefix . 'view'«IF tree != EntityTreeType.NONE», ['tpl' => 'tree']«ENDIF»);
            «ELSEIF hasIndexAction»
                // redirect to the index page
                $url = $this->router->generate($routePrefix . 'index');
            «ELSE»
                $url = $this->router->generate('home');
            «ENDIF»
            «IF hasDisplayAction && tree != EntityTreeType.NONE»

                if ($objectIsPersisted) {
                    // redirect to the detail page of treated «name.formatForCode»
                    $url = $this->router->generate($routePrefix . 'display', [«routeParams('this->idValues', false)»]);
                }
            «ENDIF»

            return $url;
        }
    '''

    def getRedirectUrl(Entity it, Application app) '''
        /**
         * Get url to redirect to.
         *
         * @param array $args List of arguments
         *
         * @return string The redirect url
         */
        protected function getRedirectUrl($args)
        {
            «IF app.needsAutoCompletion && (!incoming.empty || !outgoing.empty)»
                if (true === $this->templateParameters['inlineUsage']) {
                    $urlArgs = [
                        'idPrefix' => $this->idPrefix,
                        'commandName' => $args['commandName']
                    ];
                    foreach ($this->idFields as $idField) {
                        $urlArgs[$idField] = $this->idValues[$idField];
                    }

                    // inline usage, return to special function for closing the modal window instance
                    return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_handleinlineredirect', $urlArgs);
                }

            «ENDIF»
            if ($this->repeatCreateAction) {
                return $this->repeatReturnUrl;
            }

            if ($this->request->getSession()->has('«app.appName.formatForDB»Referer')) {
                $this->request->getSession()->del('«app.appName.formatForDB»Referer');
            }

            // normal usage, compute return url from given redirect code
            if (!in_array($this->returnTo, $this->getRedirectCodes())) {
                // invalid return code, so return the default url
                return $this->getDefaultReturnUrl($args);
            }

            $routeArea = substr($this->returnTo, 0, 5) == 'admin' ? 'admin' : '';
            $routePrefix = '«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea;

            // parse given redirect code and return corresponding url
            switch ($this->returnTo) {
                «IF hasIndexAction»
                    case 'userIndex':
                    case 'adminIndex':
                        return $this->router->generate($routePrefix . 'index');
                «ENDIF»
                «IF hasViewAction»
                    case 'userView':
                    case 'adminView':
                        return $this->router->generate($routePrefix . 'view');
                    «IF standardFields»
                        case 'userOwnView':
                        case 'adminOwnView':
                            return $this->router->generate($routePrefix . 'view', [ 'own' => 1 ]);
                    «ENDIF»
                «ENDIF»
                «IF hasDisplayAction»
                    case 'userDisplay':
                    case 'adminDisplay':
                        if ($args['commandName'] != 'delete' && !($this->templateParameters['mode'] == 'create' && $args['commandName'] == 'cancel')) {
                            foreach ($this->idFields as $idField) {
                                $urlArgs[$idField] = $this->idValues[$idField];
                            }

                            return $this->router->generate($routePrefix . 'display', $urlArgs);
                        }

                        return $this->getDefaultReturnUrl($args);
                «ENDIF»
                «FOR incomingRelation : getIncomingJoinRelationsWithOneSource.filter[source.application == app && source instanceof Entity]»
                    «val sourceEntity = incomingRelation.source as Entity»
                    «IF sourceEntity.name != it.name»
                        «IF sourceEntity.hasViewAction»
                            case 'userView«sourceEntity.nameMultiple.formatForCodeCapital»':
                            case 'adminView«sourceEntity.nameMultiple.formatForCodeCapital»':
                                return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_' . $routeArea . 'view');
                            «IF sourceEntity.standardFields»
                                case 'userOwnView«sourceEntity.nameMultiple.formatForCodeCapital»':
                                case 'adminOwnView«sourceEntity.nameMultiple.formatForCodeCapital»':
                                    return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_' . $routeArea . 'view', [ 'own' => 1 ]);
                            «ENDIF»
                        «ENDIF»
                        «IF sourceEntity.hasDisplayAction»
                            case 'userDisplay«sourceEntity.name.formatForCodeCapital»':
                            case 'adminDisplay«sourceEntity.name.formatForCodeCapital»':
                                if (!empty($this->relationPresets['«incomingRelation.getRelationAliasName(false)»'])) {
                                    return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_' . $routeArea . 'display',  ['id' => $this->relationPresets['«incomingRelation.getRelationAliasName(false)»']«IF sourceEntity.hasSluggableFields»«/*, 'slug' => 'TODO add slug argument for redirect to relation preset'*/»«ENDIF»]);
                                }

                                return $this->getDefaultReturnUrl($args);
                        «ENDIF»
                    «ENDIF»
                «ENDFOR»
                default:
                    return $this->getDefaultReturnUrl($args);
            }
        }
    '''
}
