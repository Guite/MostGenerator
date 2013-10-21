package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
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
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension UrlExtensions = new UrlExtensions
    @Inject extension Utils = new Utils

    def getRedirectCodes(Controller it, Application app, String actionName) '''
        /**
         * Get list of allowed redirect codes.
         *
         * @return array list of possible redirect codes
         */
        protected function getRedirectCodes()
        {
            $codes = array();
            «FOR someController : app.getAllControllers»
                «val controllerName = someController.formattedName»
                «IF someController.hasActions('index')»
                    // «IF app.targets('1.3.5')»main«ELSE»index«ENDIF» page of «controllerName» area
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

    def getRedirectCodes(Entity it, Application app, Controller controller, String actionName) '''
        /**
         * Get list of allowed redirect codes.
         *
         * @return array list of possible redirect codes
         */
        protected function getRedirectCodes()
        {
            $codes = parent::getRedirectCodes();
            «FOR incomingRelation : getIncomingJoinRelationsWithOneSource.filter[source.container.application == app]»
                «val sourceEntity = incomingRelation.source»
                «IF sourceEntity.name != it.name»
                    «FOR someController : app.getAllControllers»
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

    def getDefaultReturnUrl(Entity it, Application app, Controller controller, String actionName) '''
        /**
         * Get the default redirect url. Required if no returnTo parameter has been supplied.
         * This method is called in handleCommand so we know which command has been performed.
         *
         * @param array  $args List of arguments.
         *
         * @return string The default redirect url.
         */
        protected function getDefaultReturnUrl($args)
        {
            «IF controller.hasActions('view')»
                // redirect to the list of «nameMultiple.formatForCode»
                $viewArgs = array('ot' => $this->objectType);
                «IF tree != EntityTreeType::NONE»
                    $viewArgs['tpl'] = 'tree';
                «ENDIF»
                $url = ModUtil::url($this->name, '«controller.formattedName»', 'view', $viewArgs);
            «ELSEIF controller.hasActions('index')»
                // redirect to the «IF app.targets('1.3.5')»main«ELSE»index«ENDIF» page
                $url = ModUtil::url($this->name, '«controller.formattedName»', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');
            «ELSE»
                $url = System::getHomepageUrl();
            «ENDIF»
            «IF controller.hasActions('display') && tree != EntityTreeType::NONE»

                if ($args['commandName'] != 'delete' && !($this->mode == 'create' && $args['commandName'] == 'cancel')) {
                    // redirect to the detail page of treated «name.formatForCode»
                    $url = ModUtil::url($this->name, '«controller.formattedName»', «modUrlDisplay('this->idValues', false)»);
                }
            «ENDIF»

            return $url;
        }
    '''

    def getRedirectUrl(Entity it, Application app, Controller controller, String actionName) '''
        /**
         * Get url to redirect to.
         *
         * @param array  $args List of arguments.
         *
         * @return string The redirect url.
         */
        protected function getRedirectUrl($args)
        {
            if ($this->inlineUsage == true) {
                $urlArgs = array('idPrefix'    => $this->idPrefix,
                                 'commandName' => $args['commandName']);
                $urlArgs = $this->addIdentifiersToUrlArgs($urlArgs);

                // inline usage, return to special function for closing the Zikula.UI.Window instance
                return ModUtil::url($this->name, '«controller.formattedName»', 'handleInlineRedirect', $urlArgs);
            }

            if ($this->repeatCreateAction) {
                return $this->repeatReturnUrl;
            }

            // normal usage, compute return url from given redirect code
            if (!in_array($this->returnTo, $this->getRedirectCodes())) {
                // invalid return code, so return the default url
                return $this->getDefaultReturnUrl($args);
            }

            // parse given redirect code and return corresponding url
            switch ($this->returnTo) {
                «FOR someController : app.getAllControllers.filter(AjaxController)»
                    «val controllerName = someController.formattedName»
                    «IF someController.hasActions('index')»
                        case '«controllerName»':
                                    return ModUtil::url($this->name, '«controllerName»', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');
                    «ENDIF»
                    «IF someController.hasActions('view')»
                        case '«controllerName»View':
                                    return ModUtil::url($this->name, '«controllerName»', 'view',
                                                             array('ot' => $this->objectType));
                    «ENDIF»
                    «IF someController.hasActions('display')»
                        case '«controllerName»Display':
                                    if ($args['commandName'] != 'delete' && !($this->mode == 'create' && $args['commandName'] == 'cancel')) {
                                        $urlArgs = $this->addIdentifiersToUrlArgs();
                                        $urlArgs['ot'] = $this->objectType;
                                        return ModUtil::url($this->name, '«controllerName»', 'display', $urlArgs);
                                    }
                                    return $this->getDefaultReturnUrl($args);
                    «ENDIF»
                «ENDFOR»
                «FOR incomingRelation : getIncomingJoinRelationsWithOneSource.filter[source.container.application == app]»
                    «val sourceEntity = incomingRelation.source»
                    «IF sourceEntity.name != it.name»
                        «FOR someController : app.getAllControllers.filter(AjaxController)»
                            «val controllerName = someController.formattedName»
                            «IF someController.hasActions('view')»
                                case '«controllerName»View«sourceEntity.name.formatForCodeCapital»':
                                    return ModUtil::url($this->name, '«controllerName»', 'view',
                                                             array('ot' => '«sourceEntity.name.formatForCode»'));
                            «ENDIF»
                            «IF someController.hasActions('display')»
                                case '«controllerName»Display«sourceEntity.name.formatForCodeCapital»':
                                    if (!empty($this->«incomingRelation.getRelationAliasName(false)»)) {
                                        return ModUtil::url($this->name, '«controllerName»', 'display', array('ot' => '«sourceEntity.name.formatForCode»', 'id' => $this->«incomingRelation.getRelationAliasName(false)»«IF sourceEntity.hasSluggableFields»«/*, 'slug' => 'TODO'*/»«ENDIF»));
                                    }
                                    return $this->getDefaultReturnUrl($args);
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
