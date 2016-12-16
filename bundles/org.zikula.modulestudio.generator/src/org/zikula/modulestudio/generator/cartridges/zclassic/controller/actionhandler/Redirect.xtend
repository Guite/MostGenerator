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
            $codes = «IF isLegacy»array()«ELSE»[]«ENDIF»;

            «FOR someController : controllers»
                «val controllerName = someController.formattedName»
                «IF someController.hasActions('index')»
                    // «IF isLegacy»main«ELSE»index«ENDIF» page of «controllerName» area
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
            $objectIsPersisted = $args['commandName'] != 'delete' && !($this->«IF app.isLegacy»mode«ELSE»templateParameters['mode']«ENDIF» == 'create' && $args['commandName'] == 'cancel');

            if (null !== $this->returnTo) {
                «/* TODO improve this check considering slugs */»
                $isDisplayOrEditPage = substr($this->returnTo, -7) == 'display' || substr($this->returnTo, -4) == 'edit';
                if (!$isDisplayOrEditPage || $objectIsPersisted) {
                    // return to referer
                    return $this->returnTo;
                }
            }

            «IF hasActions('view') || hasActions('index') || hasActions('display') && tree != EntityTreeType.NONE»
                «IF app.isLegacy»
                    $legacyControllerType = $this->request->query->filter('lct', 'user', FILTER_SANITIZE_STRING);
                «ELSE»
                    $routeArea = array_key_exists('routeArea', $this->templateParameters) ? $this->templateParameters['routeArea'] : '';
                «ENDIF»

            «ENDIF»
            «IF hasActions('view')»
                // redirect to the list of «nameMultiple.formatForCode»
                $viewArgs = «IF app.isLegacy»array('ot' => $this->objectType, 'lct' => $legacyControllerType)«ELSE»[]«ENDIF»;
                «IF tree != EntityTreeType.NONE»
                    $viewArgs['tpl'] = 'tree';
                «ENDIF»
                «IF app.isLegacy»
                    $url = ModUtil::url($this->name, FormUtil::getPassedValue('type', 'user', 'GETPOST'), 'view', $viewArgs);
                «ELSE»
                    $url = $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea . 'view', $viewArgs);
                «ENDIF»
            «ELSEIF hasActions('index')»
                // redirect to the «IF app.isLegacy»main«ELSE»index«ENDIF» page
                «IF app.isLegacy»
                    $indexArgs = array('lct' => $legacyControllerType);
                    $url = ModUtil::url($this->name, FormUtil::getPassedValue('type', 'user', 'GETPOST'), 'main', $indexArgs);
                «ELSE»
                    $url = $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea . 'index');
                «ENDIF»
            «ELSE»
                «IF app.isLegacy»
                    $url = System::getHomepageUrl();
                «ELSE»
                    $url = $this->router->generate('home');
                «ENDIF»
            «ENDIF»
            «IF hasActions('display') && tree != EntityTreeType.NONE»

                if ($objectIsPersisted) {
                    // redirect to the detail page of treated «name.formatForCode»
                    «IF app.isLegacy»
                        $currentType = FormUtil::getPassedValue('type', 'user', 'GETPOST');
                        $displayArgs = array('ot' => $this->objectType, «routeParamsLegacy('this->idValues', false, true)»);
                        $url = ModUtil::url($this->name, $currentType, 'display', $displayArgs);
                    «ELSE»
                        $displayArgs = [«routeParams('this->idValues', false)»];
                        $url = $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_' . $routeArea . 'display', $displayArgs);
                    «ENDIF»
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
                if (true === $this->«IF app.isLegacy»inlineUsage«ELSE»templateParameters['inlineUsage']«ENDIF») {
                    $urlArgs = «IF app.isLegacy»array(«ELSE»[«ENDIF»
                        'idPrefix' => $this->idPrefix,
                        'commandName' => $args['commandName']
                    «IF app.isLegacy»)«ELSE»]«ENDIF»;
                    foreach ($this->idFields as $idField) {
                        $urlArgs[$idField] = $this->idValues[$idField];
                    }

                    // inline usage, return to special function for closing the «IF app.isLegacy»Zikula.UI.Window«ELSE»modal window«ENDIF» instance
                    «IF app.isLegacy»
                        return ModUtil::url($this->name, FormUtil::getPassedValue('type', 'user', 'GETPOST'), 'handleInlineRedirect', $urlArgs);
                    «ELSE»
                        return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_handleinlineredirect', $urlArgs);
                    «ENDIF»
                }

            «ENDIF»
            if ($this->repeatCreateAction) {
                return $this->repeatReturnUrl;
            }

            «IF app.isLegacy»
                SessionUtil::delVar('referer');
            «ELSE»
                if ($this->request->getSession()->has('referer')) {
                    $this->request->getSession()->del('referer');
                }
            «ENDIF»

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
                            «IF app.isLegacy»
                                return ModUtil::url($this->name, '«controllerName»', 'main');
                            «ELSE»
                                return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_«IF someController instanceof AdminController»admin«ENDIF»index');
                            «ENDIF»
                    «ENDIF»
                    «IF someController.hasActions('view')»
                        case '«controllerName»View':
                            «IF app.isLegacy»
                                return ModUtil::url($this->name, '«controllerName»', 'view', array('ot' => $this->objectType));
                            «ELSE»
                                return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_«IF someController instanceof AdminController»admin«ENDIF»view');
                            «ENDIF»
                    «ENDIF»
                    «IF someController.hasActions('display')»
                        case '«controllerName»Display':
                            if ($args['commandName'] != 'delete' && !($this->«IF app.isLegacy»mode«ELSE»templateParameters['mode']«ENDIF» == 'create' && $args['commandName'] == 'cancel')) {
                                «IF app.isLegacy»
                                    $urlArgs['ot'] = $this->objectType;
                                «ENDIF»
                                foreach ($this->idFields as $idField) {
                                    $urlArgs[$idField] = $this->idValues[$idField];
                                }
                                «IF app.isLegacy»
                                    return ModUtil::url($this->name, '«controllerName»', 'display', $urlArgs);
                                «ELSE»
                                    return $this->router->generate('«app.appName.formatForDB»_' . $this->objectTypeLower . '_«IF someController instanceof AdminController»admin«ENDIF»display', $urlArgs);
                                «ENDIF»
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
                                    «IF app.isLegacy»
                                        return ModUtil::url($this->name, '«controllerName»', 'view', array('ot' => '«sourceEntity.name.formatForCode»'));
                                    «ELSE»
                                        return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_«IF someController instanceof AdminController»admin«ENDIF»view');
                                    «ENDIF»
                            «ENDIF»
                            «IF someController.hasActions('display')»
                                case '«controllerName»Display«sourceEntity.name.formatForCodeCapital»':
                                    if (!empty($this->relationPresets['«incomingRelation.getRelationAliasName(false)»'])) {
                                        «IF app.isLegacy»
                                            return ModUtil::url($this->name, '«controllerName»', 'display', array('ot' => '«sourceEntity.name.formatForCode»', 'id' => $this->relationPresets['«incomingRelation.getRelationAliasName(false)»']«IF sourceEntity.hasSluggableFields»«/*, 'slug' => 'TODO'*/»«ENDIF»));
                                        «ELSE»
                                            return $this->router->generate('«app.appName.formatForDB»_«sourceEntity.name.formatForDB»_«IF someController instanceof AdminController»admin«ENDIF»display',  ['id' => $this->relationPresets['«incomingRelation.getRelationAliasName(false)»']«IF sourceEntity.hasSluggableFields»«/*, 'slug' => 'TODO'*/»«ENDIF»]);
                                        «ENDIF»
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

    private def isLegacy(Application it) {
        targets('1.3.x')
    }
}
