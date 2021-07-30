package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
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
    extension Utils = new Utils

    def getRedirectCodes(Application it) '''
        /**
         * Returns a list of allowed redirect codes.
         *
         * @return string[] list of possible redirect codes
         */
        protected function getRedirectCodes()«IF targets('3.0')»: array«ENDIF»
        {
            $codes = [];

            // to be filled by subclasses

            return $codes;
        }
    '''

    def getRedirectCodes(Entity it, Application app) '''
        protected function getRedirectCodes()«IF app.targets('3.0')»: array«ENDIF»
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
            «FOR incomingRelation : getBidirectionalIncomingJoinRelationsWithOneSource.filter[source.application == app && source instanceof Entity]»
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
         «IF !app.targets('3.0')»
         *
         * @param array $args List of arguments
         *
         * @return string The default redirect url
         «ENDIF»
         */
        protected function getDefaultReturnUrl(array $args = [])«IF app.targets('3.0')»: string«ENDIF»
        {
            $objectIsPersisted = 'delete' !== $args['commandName']
                && !('create' === $this->templateParameters['mode'] && 'cancel' === $args['commandName']
            );
            if (null !== $this->returnTo && $objectIsPersisted) {
                // return to referer
                return $this->returnTo;
            }

            «IF hasIndexAction || hasViewAction || hasDisplayAction && tree != EntityTreeType.NONE»
                $routeArea = array_key_exists('routeArea', $this->templateParameters)
                    ? $this->templateParameters['routeArea']
                    : ''
                ;
                $routePrefix = '«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea;

            «ENDIF»
            «IF hasViewAction»
                // redirect to the list of «nameMultiple.formatForCode»
                $url = $this->router->generate($routePrefix . 'view'«/*IF tree != EntityTreeType.NONE», ['tpl' => 'tree']«ENDIF*/»);
            «ELSEIF hasIndexAction»
                // redirect to the index page
                $url = $this->router->generate($routePrefix . 'index');
            «ELSE»
                $url = $this->router->generate('home');
            «ENDIF»
            «IF hasDisplayAction»

                if ($objectIsPersisted) {
                    // redirect to the detail page of treated «name.formatForCode»
                    $url = $this->router->generate($routePrefix . 'display', $this->entityRef->createUrlArgs());
                }
            «ENDIF»

            return $url;
        }
    '''

    def getRedirectUrl(Entity it, Application app) '''
        /**
         * Get URL to redirect to.
         «IF !app.targets('3.0')»
         *
         * @param array $args List of arguments
         *
         * @return string The redirect url
         «ENDIF»
         */
        protected function getRedirectUrl(array $args = [])«IF app.targets('3.0')»: string«ENDIF»
        {
            «IF app.needsInlineEditing && (!getIncomingJoinRelations.empty || !getOutgoingJoinRelations.empty)»
                if (isset($this->templateParameters['inlineUsage']) && true === $this->templateParameters['inlineUsage']) {
                    $commandName = 'submit' === mb_substr($args['commandName'], 0, 6) ? 'create' : $args['commandName'];
                    $urlArgs = [
                        'idPrefix' => $this->idPrefix,
                        'commandName' => $commandName,
                        'id' => $this->idValue,
                    ];

                    // inline usage, return to special function for closing the modal window instance
                    return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_handleinlineredirect', $urlArgs);
                }

            «ENDIF»
            if ($this->repeatCreateAction) {
                return $this->repeatReturnUrl;
            }

            $request = $this->requestStack->getCurrentRequest();
            if ($request->hasSession() && ($session = $request->getSession())) {
                if ($session->has('«app.appName.formatForDB»' . $this->objectTypeCapital . 'Referer')) {
                    $this->returnTo = $session->get('«app.appName.formatForDB»' . $this->objectTypeCapital . 'Referer');
                    $session->remove('«app.appName.formatForDB»' . $this->objectTypeCapital . 'Referer');
                }
            }

            «IF hasDisplayAction && hasSluggableFields»
                if ('create' !== $this->templateParameters['mode']) {
                    // refresh entity because slugs may have changed (e.g. by translatable)
                    $this->entityFactory->getEntityManager()->refresh($this->entityRef);
                }

            «ENDIF»
            // normal usage, compute return url from given redirect code
            if (!in_array($this->returnTo, $this->getRedirectCodes(), true)) {
                // invalid return code, so return the default url
                return $this->getDefaultReturnUrl($args);
            }

            $routeArea = 0 === mb_strpos($this->returnTo, 'admin') ? 'admin' : '';
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
                            return $this->router->generate($routePrefix . 'view', ['own' => 1]);
                    «ENDIF»
                «ENDIF»
                «IF hasDisplayAction»
                    case 'userDisplay':
                    case 'adminDisplay':
                        if (
                            'delete' !== $args['commandName']
                            && !('create' === $this->templateParameters['mode'] && 'cancel' === $args['commandName'])
                        ) {
                            return $this->router->generate($routePrefix . 'display', $this->entityRef->createUrlArgs());
                        }

                        return $this->getDefaultReturnUrl($args);
                «ENDIF»
                «FOR incomingRelation : getBidirectionalIncomingJoinRelationsWithOneSource.filter[source.application == app && source instanceof Entity]»
                    «val sourceEntity = incomingRelation.source as Entity»
                    «IF sourceEntity.name != it.name»
                        «IF sourceEntity.hasViewAction»
                            case 'userView«sourceEntity.nameMultiple.formatForCodeCapital»':
                            case 'adminView«sourceEntity.nameMultiple.formatForCodeCapital»':
                                return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_' . $routeArea . 'view');
                            «IF sourceEntity.standardFields»
                                case 'userOwnView«sourceEntity.nameMultiple.formatForCodeCapital»':
                                case 'adminOwnView«sourceEntity.nameMultiple.formatForCodeCapital»':
                                    return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_' . $routeArea . 'view', ['own' => 1]);
                            «ENDIF»
                        «ENDIF»
                        «IF sourceEntity.hasDisplayAction»
                            case 'userDisplay«sourceEntity.name.formatForCodeCapital»':
                            case 'adminDisplay«sourceEntity.name.formatForCodeCapital»':
                                if (!empty($this->relationPresets['«incomingRelation.getRelationAliasName(false)»']) || (method_exists($this->entityRef, 'get«incomingRelation.getRelationAliasName(false).toFirstUpper»') && null !== $this->entityRef->get«incomingRelation.getRelationAliasName(false).toFirstUpper»())) {
                                    $routeName = '«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_' . $routeArea . 'display';
                                    $«incomingRelation.getRelationAliasName(false)»Id = !empty($this->relationPresets['«incomingRelation.getRelationAliasName(false)»']) ? $this->relationPresets['«incomingRelation.getRelationAliasName(false)»'] : $this->entityRef->get«incomingRelation.getRelationAliasName(false).toFirstUpper»();

                                    return $this->router->generate($routeName, ['id' => $«incomingRelation.getRelationAliasName(false)»Id]);
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
