package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.AjaxController
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

            «FOR someController : controllers»
                «val controllerName = someController.formattedName»
                «IF someController.hasActions('index')»
                    // index page of «controllerName» area
                    $codes[] = '«controllerName»';
                «ENDIF»
                «IF someController.hasActions('view')»
                    // «controllerName» list of entities
                    $codes[] = '«controllerName»View';
                «ENDIF»
                «IF someController.hasActions('display')»
                    // «controllerName» display page of treated entity
                    $codes[] = '«controllerName»Display';
                «ENDIF»
            «ENDFOR»

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

            «FOR incomingRelation : getIncomingJoinRelationsWithOneSource.filter[source.application == app && source instanceof Entity]»
                «val sourceEntity = incomingRelation.source as Entity»
                «IF sourceEntity.name != it.name»
                    «FOR someController : app.controllers»
                        «val controllerName = someController.formattedName»
                        «IF someController.hasActions('view')»
                            // «controllerName» list of «sourceEntity.nameMultiple.formatForDisplay»
                            $codes[] = '«controllerName»View«sourceEntity.name.formatForCodeCapital»';
                        «ENDIF»
                        «IF someController.hasActions('display')»
                            // «controllerName» display page of treated «sourceEntity.name.formatForDisplay»
                            $codes[] = '«controllerName»Display«sourceEntity.name.formatForCodeCapital»';
                        «ENDIF»
                    «ENDFOR»
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
                «/* TODO improve this check considering slugs */»
                $isDisplayOrEditPage = substr($this->returnTo, -7) == 'display' || substr($this->returnTo, -4) == 'edit';
                if (!$isDisplayOrEditPage || $objectIsPersisted) {
                    // return to referer
                    return $this->returnTo;
                }
            }

            «IF hasActions('view') || hasActions('index') || hasActions('display') && tree != EntityTreeType.NONE»
                $routeArea = array_key_exists('routeArea', $this->templateParameters) ? $this->templateParameters['routeArea'] : '';

            «ENDIF»
            «IF hasActions('view')»
                // redirect to the list of «nameMultiple.formatForCode»
                $viewArgs = [];
                «IF tree != EntityTreeType.NONE»
                    $viewArgs['tpl'] = 'tree';
                «ENDIF»
                $url = $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea . 'view', $viewArgs);
            «ELSEIF hasActions('index')»
                // redirect to the index page
                $url = $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea . 'index');
            «ELSE»
                $url = $this->router->generate('home');
            «ENDIF»
            «IF hasActions('display') && tree != EntityTreeType.NONE»

                if ($objectIsPersisted) {
                    // redirect to the detail page of treated «name.formatForCode»
                    $displayArgs = [«routeParams('this->idValues', false)»];
                    $url = $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea . 'display', $displayArgs);
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
            «IF !incoming.empty || !outgoing.empty»
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

            if ($this->request->getSession()->has('referer')) {
                $this->request->getSession()->del('referer');
            }

            // normal usage, compute return url from given redirect code
            if (!in_array($this->returnTo, $this->getRedirectCodes())) {
                // invalid return code, so return the default url
                return $this->getDefaultReturnUrl($args);
            }

            // parse given redirect code and return corresponding url
            switch ($this->returnTo) {
                «FOR someController : app.controllers»
                «IF !(someController instanceof AjaxController)»
                    «val controllerName = someController.formattedName»
                    «IF someController.hasActions('index')»
                        case '«controllerName»':
                            return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_«IF someController instanceof AdminController»admin«ENDIF»index');
                    «ENDIF»
                    «IF someController.hasActions('view')»
                        case '«controllerName»View':
                            return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_«IF someController instanceof AdminController»admin«ENDIF»view');
                    «ENDIF»
                    «IF someController.hasActions('display')»
                        case '«controllerName»Display':
                            if ($args['commandName'] != 'delete' && !($this->templateParameters['mode'] == 'create' && $args['commandName'] == 'cancel')) {
                                foreach ($this->idFields as $idField) {
                                    $urlArgs[$idField] = $this->idValues[$idField];
                                }
                                return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_«IF someController instanceof AdminController»admin«ENDIF»display', $urlArgs);
                            }

                            return $this->getDefaultReturnUrl($args);
                    «ENDIF»
                «ENDIF»
                «ENDFOR»
                «FOR incomingRelation : getIncomingJoinRelationsWithOneSource.filter[source.application == app && source instanceof Entity]»
                    «val sourceEntity = incomingRelation.source as Entity»
                    «IF sourceEntity.name != it.name»
                        «FOR someController : app.controllers»
                        «IF !(someController instanceof AjaxController)»
                            «val controllerName = someController.formattedName»
                            «IF someController.hasActions('view')»
                                case '«controllerName»View«sourceEntity.name.formatForCodeCapital»':
                                    return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_«IF someController instanceof AdminController»admin«ENDIF»view');
                            «ENDIF»
                            «IF someController.hasActions('display')»
                                case '«controllerName»Display«sourceEntity.name.formatForCodeCapital»':
                                    if (!empty($this->relationPresets['«incomingRelation.getRelationAliasName(false)»'])) {
                                        return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_«IF someController instanceof AdminController»admin«ENDIF»display',  ['id' => $this->relationPresets['«incomingRelation.getRelationAliasName(false)»']«IF sourceEntity.hasSluggableFields»«/*, 'slug' => 'TODO'*/»«ENDIF»]);
                                    }

                                    return $this->getDefaultReturnUrl($args);
                            «ENDIF»
                        «ENDIF»
                        «ENDFOR»
                    «ENDIF»
                «ENDFOR»
                default:
                    return $this->getDefaultReturnUrl($args);
            }
        }
    '''
}
