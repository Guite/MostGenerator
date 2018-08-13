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
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerAction {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    Application app
    Actions actionsImpl

    new(Application app) {
        this.app = app
        actionsImpl = new Actions(app)
    }

    def generate(Entity it, Action action, Boolean isBase, Boolean isAdmin) '''
        «action.actionDoc(it, isBase, isAdmin)»
        public function «action.methodName(isAdmin)»Action(«methodArgs(it, action)»)
        {
            «IF isBase»
                «IF action instanceof DisplayAction»
                    $«name.formatForCode» = $this->get('«application.appService».entity_factory')->getRepository('«name.formatForCode»')->«IF hasSluggableFields && slugUnique»selectBySlug($slug)«ELSE»selectById($id)«ENDIF»;
                    if (null === $«name.formatForCode») {
                        throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
                    }

                    return $this->«action.methodName(false)»Internal($request, $«name.formatForCode», «isAdmin.displayBool»);
                «ELSE»
                    return $this->«action.methodName(false)»Internal(«methodArgsCall(it, action)», «isAdmin.displayBool»);
                «ENDIF»
            «ELSE»
                return parent::«action.methodName(isAdmin)»Action(«methodArgsCall(it, action)»);
            «ENDIF»
        }
        «IF isBase && !isAdmin»

            /**
             * This method includes the common implementation code for «action.methodName(true)»() and «action.methodName(false)»().
             */
            protected function «action.methodName(false)»Internal(«IF action instanceof DisplayAction»Request $request, «name.formatForCodeCapital»Entity $«name.formatForCode»«ELSE»«methodArgs(it, action)»«ENDIF», $isAdmin = false)
            {
                «actionsImpl.actionImpl(it, action)»
            }
        «ENDIF»
    '''

    def private actionDoc(Action it, Entity entity, Boolean isBase, Boolean isAdmin) '''
        /**
         «IF isBase»
         * «actionDocMethodDescription(isAdmin)»
         «ELSE»
         * @inheritDoc
         «ENDIF»
        «IF isBase»«actionDocMethodDocumentation»
        «ELSE»
        «new Annotations(app).generate(it, entity, isAdmin)»
        «ENDIF»
        «IF isBase»
         *
         * @param Request $request Current request instance
        «actionDocMethodParams(entity, it)»
         *
         * @return Response Output
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «IF it instanceof DisplayAction»
         * @throws NotFoundHttpException Thrown if «entity.name.formatForDisplay» to be displayed isn't found
         «ELSEIF it instanceof EditAction»
         * @throws RuntimeException      Thrown if another critical error occurs (e.g. workflow actions not available)
         «ELSEIF it instanceof DeleteAction»
         * @throws NotFoundHttpException Thrown if «entity.name.formatForDisplay» to be deleted isn't found
         * @throws RuntimeException      Thrown if another critical error occurs (e.g. workflow actions not available)
         «ENDIF»
        «ENDIF»
         */
    '''

    def private actionDocMethodDescription(Action it, Boolean isAdmin) {
        switch it {
            MainAction: 'This is the default action handling the ' + controllerName + (if (isAdmin) ' admin' else '') + ' area called without defining arguments.'
            ViewAction: 'This action provides an item list overview' + (if (isAdmin) ' in the admin area' else '') + '.'
            DisplayAction: 'This action provides a item detail view' + (if (isAdmin) ' in the admin area' else '') + '.'
            EditAction: 'This action provides a handling of edit requests' + (if (isAdmin) ' in the admin area' else '') + '.'
            DeleteAction: 'This action provides a handling of simple delete requests' + (if (isAdmin) ' in the admin area' else '') + '.'
            CustomAction: 'This is a custom action' + (if (isAdmin) ' in the admin area' else '') + '.'
            default: ''
        }
    }

    def private actionDocMethodDocumentation(Action it) {
        if (null !== documentation && !documentation.empty) {
            ' * ' + documentation.replace('*/', '*')
        } else {
            ''
        }
    }

    def private actionDocMethodParams(Entity it, Action action) {
        if (!(action instanceof MainAction || action instanceof CustomAction)) {
            '''«actionDocAdditionalParams(action, it)»'''
        }
    }

    def private actionDocAdditionalParams(Action it, Entity refEntity) {
        switch it {
            ViewAction:
                 ' * @param string $sort         Sorting field\n'
               + ' * @param string $sortdir      Sorting direction\n'
               + ' * @param int    $pos          Current pager position\n'
               + ' * @param int    $num          Amount of entries to display\n'
            DisplayAction:
                if (refEntity.hasUniqueSlug) {
                    ' * @param string $slug Slug of treated ' + refEntity.name.formatForDisplay + ' instance\n'
                } else {
                    ' * @param integer $id Identifier of treated ' + refEntity.name.formatForDisplay + ' instance\n'
                }
            DeleteAction:
                if (refEntity.hasUniqueSlug) {
                    ' * @param string $slug Slug of treated ' + refEntity.name.formatForDisplay + ' instance\n'
                } else {
                    ' * @param integer $id Identifier of treated ' + refEntity.name.formatForDisplay + ' instance\n'
                }
            default: ''
        }
    }

    def private dispatch methodName(Action it, Boolean isAdmin) '''«IF !isAdmin»«name.formatForCode.toFirstLower»«ELSE»admin«name.formatForCodeCapital»«ENDIF»'''

    def private dispatch methodName(MainAction it, Boolean isAdmin) '''«IF isAdmin»adminIndex«ELSE»index«ENDIF»'''

    def private dispatch methodArgs(Entity it, Action action) '''Request $request''' 
    def private dispatch methodArgsCall(Entity it, Action action) '''$request''' 

    def private dispatch methodArgs(Entity it, ViewAction action) '''Request $request, $sort, $sortdir, $pos, $num''' 
    def private dispatch methodArgsCall(Entity it, ViewAction action) '''$request, $sort, $sortdir, $pos, $num''' 

    def private dispatch methodArgs(Entity it, DisplayAction action) '''Request $request, $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»''' 
    def private dispatch methodArgsCall(Entity it, DisplayAction action) '''$request, $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»''' 

    def private dispatch methodArgs(Entity it, EditAction action) '''Request $request''' 
    def private dispatch methodArgsCall(Entity it, EditAction action) '''$request''' 

    def private dispatch methodArgs(Entity it, DeleteAction action) '''Request $request, $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»''' 
    def private dispatch methodArgsCall(Entity it, DeleteAction action) '''$request, $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»''' 

    def private hasUniqueSlug(Entity it) {
        hasSluggableFields && slugUnique
    }
}
