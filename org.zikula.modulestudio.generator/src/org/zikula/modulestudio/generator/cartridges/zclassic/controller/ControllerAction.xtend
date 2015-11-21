package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.ViewAction
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.Actions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.Annotations
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerAction {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    Application app
    Actions actionsImpl

    new(Application app) {
        this.app = app
        actionsImpl = new Actions(app)
    }

    def generate(Action it, Boolean isBase) '''
        «actionDoc(null, isBase, false)»
        public function «methodName(false)»«IF isLegacy»()«ELSE»Action(«methodArgs»)«ENDIF»
        {
            «IF isBase»
                «actionsImpl.actionImpl(it)»
            «ELSE»
                return parent::«methodName(false)»Action(«IF !isLegacy»$request«ENDIF»);
            «ENDIF»
        }
    '''

    def generate(Entity it, Action action, Boolean isBase, Boolean isAdmin) '''
        «action.actionDoc(it, isBase, isAdmin)»
        public function «action.methodName(isAdmin)»«IF isLegacy»()«ELSE»Action(«methodArgs(it, action)»)«ENDIF»
        {
            «IF isBase»
                «IF isLegacy»
                    $legacyControllerType = $this->request->query->filter('lct', 'user', FILTER_SANITIZE_STRING);
                    System::queryStringSetVar('type', $legacyControllerType);
                    $this->request->query->set('type', $legacyControllerType);

                «ENDIF»
                «IF softDeleteable && !isLegacy»
                    «IF isAdmin»
                        //$this->entityManager->getFilters()->disable('softdeleteable');
                    «ELSE»
                        $this->entityManager->getFilters()->enable('softdeleteable');
                    «ENDIF»

                «ENDIF»
                «IF isLegacy»
                    «actionsImpl.actionImpl(it, action)»
                «ELSE»
                    return $this->«action.methodName(false)»Internal(«methodArgsCall(it, action)», «IF isAdmin»true«ELSE»false«ENDIF»)
                «ENDIF»
            «ELSE»
                return parent::«action.methodName(isAdmin)»Action(«methodArgsCall(it, action)»);
            «ENDIF»
        }
        «IF isLegacy && !isAdmin»

            /**
             * This method includes the common implementation code for «action.methodName(true)»() and «action.methodName(false)»().
             */
            protected function «action.methodName(false)»Internal(«methodArgs(it, action)», $isAdmin = false)
            {
                «actionsImpl.actionImpl(it, action)»
            }
        «ENDIF»
    '''

    def private actionDoc(Action it, Entity entity, Boolean isBase, Boolean isAdmin) '''
        /**
         * «actionDocMethodDescription(isAdmin)»
        «actionDocMethodDocumentation»
        «IF !isLegacy»
            «val annotationHelper = new Annotations(app)»
            «annotationHelper.generate(it, entity, isBase, isAdmin)»
        «ENDIF»
         *
         «IF !isLegacy»
         * @param Request  $request      Current request instance
         «ENDIF»
        «IF entity !== null»
            «actionDocMethodParams(entity, it)»
        «ELSE»
            «actionDocMethodParams»
        «ENDIF»
         *
         * @return mixed Output.
         «IF !isLegacy»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions.
         «IF it instanceof DisplayAction»
         * @throws NotFoundHttpException Thrown by param converter if item to be displayed isn't found.
         «ELSEIF it instanceof EditAction»
         * @throws NotFoundHttpException Thrown by form handler if item to be edited isn't found.
         * @throws RuntimeException      Thrown if another critical error occurs (e.g. workflow actions not available).
         «ELSEIF it instanceof DeleteAction»
         * @throws NotFoundHttpException Thrown by param converter if item to be deleted isn't found.
         * @throws RuntimeException      Thrown if another critical error occurs (e.g. workflow actions not available).
         «ENDIF»
         «ENDIF»
         */
    '''

    def private actionDocMethodDescription(Action it, Boolean isAdmin) {
        switch it {
            MainAction: 'This is the default action handling the ' + controllerName + (if (isAdmin) ' admin') + ' area called without defining arguments.'
            ViewAction: 'This action provides an item list overview' + (if (isAdmin) ' in the admin area') + '.'
            DisplayAction: 'This action provides a item detail view' + (if (isAdmin) ' in the admin area') + '.'
            EditAction: 'This action provides a handling of edit requests' + (if (isAdmin) ' in the admin area') + '.'
            DeleteAction: 'This action provides a handling of simple delete requests' + (if (isAdmin) ' in the admin area') + '.'
            CustomAction: 'This is a custom action' + (if (isAdmin) ' in the admin area') + '.'
            default: ''
        }
    }

    def private actionDocMethodDocumentation(Action it) {
        if (documentation !== null && documentation != '') {
            ' * ' + documentation.replace('*/', '*')
        } else {
            ''
        }
    }

    def private actionDocMethodParams(Action it) {
        if (!controller.application.targets('1.3.x') && it instanceof MainAction) {
            ' * @param string  $ot           Treated object type.\n'
        } else if (!(it instanceof MainAction || it instanceof CustomAction)) {
            ' * @param string  $ot           Treated object type.\n'
            + '''«actionDocAdditionalParams(null)»'''
            + ' * @param string  $tpl          Name of alternative template (to be used instead of the default template).\n'
            + (if (controller.application.targets('1.3.x')) ' * @param boolean $raw          Optional way to display a template instead of fetching it (required for standalone output).\n' else '')
        }
    }

    def private actionDocMethodParams(Entity it, Action action) {
        if (!(action instanceof MainAction || action instanceof CustomAction)) {
            '''«actionDocAdditionalParams(action, it)»'''
            + ' * @param string  $tpl          Name of alternative template (to be used instead of the default template).\n'
            + (if (application.targets('1.3.x')) ' * @param boolean $raw          Optional way to display a template instead of fetching it (required for standalone output).\n' else '')
        }
    }

    def private actionDocAdditionalParams(Action it, Entity refEntity) {
        switch it {
            ViewAction:
                 ' * @param string  $sort         Sorting field.\n'
               + ' * @param string  $sortdir      Sorting direction.\n'
               + ' * @param int     $pos          Current pager position.\n'
               + ' * @param int     $num          Amount of entries to display.\n'
            DisplayAction:
                (if (refEntity !== null && !refEntity.application.targets('1.3.x')) ' * @param ' + refEntity.name.formatForCodeCapital + 'Entity $' + refEntity.name.formatForCode + '      Treated ' + refEntity.name.formatForDisplay + ' instance.\n'
                 else ' * @param int     $id           Identifier of entity to be shown.\n')
            DeleteAction:
                (if (refEntity !== null && !refEntity.application.targets('1.3.x')) ' * @param ' + refEntity.name.formatForCodeCapital + 'Entity $' + refEntity.name.formatForCode + '      Treated ' + refEntity.name.formatForDisplay + ' instance.\n'
                 else ' * @param int     $id           Identifier of entity to be shown.\n')
               + ' * @param boolean $confirmation Confirm the deletion, else a confirmation page is displayed.\n'
            default: ''
        }
    }

    def private dispatch methodName(Action it, Boolean isAdmin) '''«IF isLegacy || !isAdmin»«name.formatForCode.toFirstLower»«ELSE»admin«name.formatForCodeCapital»«ENDIF»'''

    def private dispatch methodName(MainAction it, Boolean isAdmin) '''«IF isLegacy»main«ELSE»«IF isAdmin»adminIndex«ELSE»index«ENDIF»«ENDIF»'''

    def private methodArgs(Action action) '''Request $request''' 

    def private dispatch methodArgs(Entity it, Action action) '''Request $request''' 
    def private dispatch methodArgsCall(Entity it, Action action) '''$request''' 

    def private dispatch methodArgs(Entity it, ViewAction action) '''Request $request, $sort, $sortdir, $pos, $num''' 
    def private dispatch methodArgsCall(Entity it, ViewAction action) '''$request, $sort, $sortdir, $pos, $num''' 

    def private dispatch methodArgs(Entity it, DisplayAction action) '''Request $request, «name.formatForCodeCapital»Entity $«name.formatForCode»''' 
    def private dispatch methodArgsCall(Entity it, DisplayAction action) '''$request, $«name.formatForCode»''' 

    def private dispatch methodArgs(Entity it, EditAction action) '''Request $request«/* TODO migrate to Symfony forms #416 */»''' 
    def private dispatch methodArgsCall(Entity it, EditAction action) '''$request«/* TODO migrate to Symfony forms #416 */»''' 

    def private dispatch methodArgs(Entity it, DeleteAction action) '''Request $request, «name.formatForCodeCapital»Entity $«name.formatForCode»''' 
    def private dispatch methodArgsCall(Entity it, DeleteAction action) '''$request, $«name.formatForCode»''' 

    def private isLegacy() {
        app.targets('1.3.x')
    }
}
