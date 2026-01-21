package org.zikula.modulestudio.generator.cartridges.symfony.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
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
         * Returns a list of allowed redirect codes.
         *
         * @return string[] list of possible redirect codes
         */
        protected function getRedirectCodes(): array
        {
            $codes = [];

            // to be filled by subclasses

            return $codes;
        }
    '''

    def getRedirectCodes(Entity it, Application app) '''
        protected function getRedirectCodes(): array
        {
            $codes = parent::getRedirectCodes();
            «IF hasIndexAction»

                // user list of «nameMultiple.formatForDisplay»
                $codes[] = 'userIndex';
                // admin list of «nameMultiple.formatForDisplay»
                $codes[] = 'adminIndex';
                «IF standardFields»
                    // user list of own «nameMultiple.formatForDisplay»
                    $codes[] = 'userOwnIndex';
                    // admin list of own «nameMultiple.formatForDisplay»
                    $codes[] = 'adminOwnIndex';
                «ENDIF»
            «ENDIF»
            «IF hasDetailAction»

                // user detail page of treated «name.formatForDisplay»
                $codes[] = 'userDetail';
                // admin detail page of treated «name.formatForDisplay»
                $codes[] = 'adminDetail';
            «ENDIF»
            «FOR incomingRelation : getBidirectionalIncomingRelationsWithOneSource.filter[source.application == app]»
                «val sourceEntity = incomingRelation.source»
                «IF sourceEntity.name != it.name»

                    «IF sourceEntity.hasIndexAction»
                        // user list of «sourceEntity.nameMultiple.formatForDisplay»
                        $codes[] = 'userIndex«sourceEntity.nameMultiple.formatForCodeCapital»';
                        // admin list of «sourceEntity.nameMultiple.formatForDisplay»
                        $codes[] = 'adminIndex«sourceEntity.nameMultiple.formatForCodeCapital»';
                        «IF sourceEntity.standardFields»
                            // user list of own «sourceEntity.nameMultiple.formatForDisplay»
                            $codes[] = 'userOwnIndex«sourceEntity.nameMultiple.formatForCodeCapital»';
                            // admin list of own «sourceEntity.nameMultiple.formatForDisplay»
                            $codes[] = 'adminOwnIndex«sourceEntity.nameMultiple.formatForCodeCapital»';
                        «ENDIF»
                    «ENDIF»
                    «IF sourceEntity.hasDetailAction»
                        // user detail page of related «sourceEntity.name.formatForDisplay»
                        $codes[] = 'userDetail«sourceEntity.name.formatForCodeCapital»';
                        // admin detail page of related «sourceEntity.name.formatForDisplay»
                        $codes[] = 'adminDetail«sourceEntity.name.formatForCodeCapital»';
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
         */
        protected function getDefaultReturnUrl(array $args = []): string
        {
            $objectIsPersisted = 'delete' !== $args['commandName']
                && !('create' === $this->templateParameters['mode'] && 'cancel' === $args['commandName']
            );
            if (null !== $this->returnTo && $objectIsPersisted) {
                // return to referer
                return $this->returnTo;
            }

            «IF hasIndexAction || hasDetailAction && tree»
                $routePrefix = '«app.routePrefix»_' . $this->objectTypeLower . '_';

            «ENDIF»
            «IF hasIndexAction»
                // redirect to the list of «nameMultiple.formatForCode»
                $url = $this->router->generate($routePrefix . 'index'«/*IF tree != EntityTreeType.NONE», ['tpl' => 'tree']«ENDIF*/»);
            «ELSE»
                $url = $this->router->generate('home');
            «ENDIF»
            «IF hasDetailAction»

                if ($objectIsPersisted) {
                    // redirect to the detail page of treated «name.formatForCode»
                    $url = $this->router->generate($routePrefix . 'detail', $this->entityRef->getRouteParameters());
                }
            «ENDIF»

            return $url;
        }
    '''

    def getRedirectUrl(Entity it, Application app) '''
        /**
         * Get URL to redirect to.
         */
        protected function getRedirectUrl(array $args = []): string
        {
            «IF app.needsInlineEditing && (!incoming.empty || !outgoing.empty)»
                if (isset($this->templateParameters['inlineUsage']) && true === $this->templateParameters['inlineUsage']) {
                    $commandName = 'submit' === mb_substr($args['commandName'], 0, 6) ? 'create' : $args['commandName'];
                    $urlArgs = [
                        'idPrefix' => $this->idPrefix,
                        'commandName' => $commandName,
                        'id' => $this->idValue,
                    ];

                    // inline usage, return to special function for closing the modal window instance
                    return $this->router->generate('«app.routePrefix»_' . $this->objectTypeLower . '_handleinlineredirect', $urlArgs);
                }

            «ENDIF»
            if ($this->repeatCreateAction) {
                return $this->repeatReturnUrl;
            }

            $request = $this->requestStack->getCurrentRequest();
            if ($request->hasSession() && ($session = $request->getSession())) {
                $refererKey = '«app.appName.formatForDB»' . $this->objectTypeCapital . 'Referer';
                if ($session->has($refererKey)) {
                    $this->returnTo = $session->get($refererKey);
                    $session->remove($refererKey);
                }
            }

            «IF hasDetailAction && hasSluggableFields»
                if ('create' !== $this->templateParameters['mode']) {
                    // refresh entity because slugs may have changed (e.g. by translatable)
                    $this->entityManager->refresh($this->entityRef);
                }

            «ENDIF»
            // normal usage, compute return url from given redirect code
            if (!in_array($this->returnTo, $this->getRedirectCodes(), true)) {
                // invalid return code, so return the default url
                return $this->getDefaultReturnUrl($args);
            }

            $routePrefix = '«app.routePrefix»_' . $this->objectTypeLower . '_';

            // parse given redirect code and return corresponding url
            switch ($this->returnTo) {
                «IF hasIndexAction»
                    case 'userIndex':
                    case 'adminIndex':
                        return $this->router->generate($routePrefix . 'index');
                    «IF standardFields»
                        case 'userOwnIndex':
                        case 'adminOwnIndex':
                            return $this->router->generate($routePrefix . 'index', ['own' => 1]);
                    «ENDIF»
                «ENDIF»
                «IF hasDetailAction»
                    case 'userDetail':
                    case 'adminDetail':
                        if (
                            'delete' !== $args['commandName']
                            && !('create' === $this->templateParameters['mode'] && 'cancel' === $args['commandName'])
                        ) {
                            return $this->router->generate($routePrefix . 'detail', $this->entityRef->getRouteParameters());
                        }

                        return $this->getDefaultReturnUrl($args);
                «ENDIF»
                «FOR incomingRelation : getBidirectionalIncomingRelationsWithOneSource.filter[source.application == app]»
                    «val sourceEntity = incomingRelation.source»
                    «IF sourceEntity.name != it.name»
                        «IF sourceEntity.hasIndexAction»
                            case 'userIndex«sourceEntity.nameMultiple.formatForCodeCapital»':
                            case 'adminIndex«sourceEntity.nameMultiple.formatForCodeCapital»':
                                return $this->router->generate('«sourceEntity.route('index')»');
                            «IF sourceEntity.standardFields»
                                case 'userOwnIndex«sourceEntity.nameMultiple.formatForCodeCapital»':
                                case 'adminOwnIndex«sourceEntity.nameMultiple.formatForCodeCapital»':
                                    return $this->router->generate('«sourceEntity.route('index')»', ['own' => 1]);
                            «ENDIF»
                        «ENDIF»
                        «IF sourceEntity.hasDetailAction»
                            case 'userDetail«sourceEntity.name.formatForCodeCapital»':
                            case 'adminDetail«sourceEntity.name.formatForCodeCapital»':
                                if (!empty($this->relationPresets['«incomingRelation.getRelationAliasName(false)»']) || (method_exists($this->entityRef, 'get«incomingRelation.getRelationAliasName(false).toFirstUpper»') && null !== $this->entityRef->get«incomingRelation.getRelationAliasName(false).toFirstUpper»())) {
                                    $routeName = '«sourceEntity.route('detail')»';
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
