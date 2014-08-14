package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.modulestudio.Action
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.CustomAction
import de.guite.modulestudio.metamodel.modulestudio.DeleteAction
import de.guite.modulestudio.metamodel.modulestudio.DisplayAction
import de.guite.modulestudio.metamodel.modulestudio.EditAction
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.MainAction
import de.guite.modulestudio.metamodel.modulestudio.ViewAction
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.Actions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerAction {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app
    Actions actionsImpl

    new(Application app) {
        this.app = app
        actionsImpl = new Actions(app)
    }

    def generate(Action it, Boolean isBase) '''
        «IF isBase»
            «actionDoc(null, isBase)»
            public function «methodName»«IF app.targets('1.3.5')»()«ELSE»Action(«methodArgs»)«ENDIF»
            {
                «actionsImpl.actionImpl(it)»
            }
            «/* this line is on purpose */»
        «ENDIF»
    '''

    def generate(Entity it, Action action, Boolean isBase) '''
        «action.actionDoc(it, isBase)»
        public function «action.methodName»«IF app.targets('1.3.5')»()«ELSE»Action(«methodArgs(it, action)»)«ENDIF»
        {
            «IF isBase»
                $legacyControllerType = $«IF app.targets('1.3.5')»this->«ENDIF»request->query->filter('lct', 'user', FILTER_SANITIZE_STRING);
                System::queryStringSetVar('type', $legacyControllerType);
                $«IF app.targets('1.3.5')»this->«ENDIF»request->query->set('type', $legacyControllerType);

                «IF softDeleteable && !app.targets('1.3.5')»
                    if ($legacyControllerType == 'admin') {
                        //$this->entityManager->getFilters()->disable('softdeleteable');
                    } else {
                        $this->entityManager->getFilters()->enable('softdeleteable');
                    }

                «ENDIF»
                «actionsImpl.actionImpl(it, action)»
            «ELSE»
                return parent::«action.methodName»Action(«methodArgsCall(it, action)»);
            «ENDIF»
        }
        «/* this line is on purpose */»
    '''

    def private actionDoc(Action it, Entity entity, Boolean isBase) '''
        /**
         * «actionDocMethodDescription»
        «actionDocMethodDocumentation»
        «IF !app.targets('1.3.5') && entity !== null»
            «IF !isBase»
                «actionRoute(entity)»
            «ELSE»
                «IF it instanceof DisplayAction || it instanceof DeleteAction»
                    «paramConverter(entity)»
                «ENDIF»
                «IF it instanceof MainAction»
                    «' '»* @Cache(expires="+7 days", public=true)
                «ELSEIF it instanceof ViewAction»
                    «' '»* @Cache(expires="+2 hours", public=false)
                «ELSEIF !(it instanceof CustomAction)»
                    «IF entity.standardFields»
                        «' '»* @Cache(lastModified="«entity.name.formatForCode».getUpdatedDate()", ETag="'«entity.name.formatForCodeCapital»' ~ «entity.getPrimaryKeyFields.map[entity.name.formatForCode + '.get' + name.formatForCode + '()'].join(' ~ ')» ~ «entity.name.formatForCode».getUpdatedDate().format('U')")
                    «ELSE»
                        «IF it instanceof EditAction»
                            «' '»* @Cache(expires="+30 minutes", public=false)
                        «ELSE»
                            «' '»* @Cache(expires="+12 hours", public=false)
                        «ENDIF»
                    «ENDIF»
                «ENDIF»
            «ENDIF»
        «ENDIF»
         *
         «IF !app.targets('1.3.5')»
         * @param Request  $request      Current request instance
         «ENDIF»
        «IF entity !== null»
            «actionDocMethodParams(entity, it)»
        «ELSE»
            «actionDocMethodParams»
        «ENDIF»
         *
         * @return mixed Output.
         «IF !app.targets('1.3.5')»
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

    def private actionDocMethodDescription(Action it) {
        switch it {
            MainAction: 'This method is the default function handling the ' + controllerName + ' area called without defining arguments.'
            ViewAction: 'This method provides a item list overview.'
            DisplayAction: 'This method provides a item detail view.'
            EditAction: 'This method provides a handling of edit requests.'
            DeleteAction: 'This method provides a handling of simple delete requests.'
            CustomAction: 'This is a custom method.'
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
        if (!controller.application.targets('1.3.5') && it instanceof MainAction) {
            ' * @param string  $ot           Treated object type.\n'
        } else if (!(it instanceof MainAction || it instanceof CustomAction)) {
            ' * @param string  $ot           Treated object type.\n'
            + '''«actionDocAdditionalParams(null)»'''
            + ' * @param string  $tpl          Name of alternative template (to be used instead of the default template).\n'
            + (if (controller.application.targets('1.3.5')) ' * @param boolean $raw          Optional way to display a template instead of fetching it (required for standalone output).\n' else '')
        }
    }

    def private actionDocMethodParams(Entity it, Action action) {
        if (!(action instanceof MainAction || action instanceof CustomAction)) {
            '''«actionDocAdditionalParams(action, it)»'''
            + ' * @param string  $tpl          Name of alternative template (to be used instead of the default template).\n'
            + (if (application.targets('1.3.5')) ' * @param boolean $raw          Optional way to display a template instead of fetching it (required for standalone output).\n' else '')
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
                (if (refEntity !== null && !refEntity.application.targets('1.3.5')) ' * @param ' + refEntity.name.formatForCodeCapital + 'Entity $' + refEntity.name.formatForCode + '      Treated ' + refEntity.name.formatForDisplay + ' instance.\n'
                 else ' * @param int     $id           Identifier of entity to be shown.\n')
            DeleteAction:
                (if (refEntity !== null && !refEntity.application.targets('1.3.5')) ' * @param ' + refEntity.name.formatForCodeCapital + 'Entity $' + refEntity.name.formatForCode + '      Treated ' + refEntity.name.formatForDisplay + ' instance.\n'
                 else ' * @param int     $id           Identifier of entity to be shown.\n')
               + ' * @param boolean $confirmation Confirm the deletion, else a confirmation page is displayed.\n'
            default: ''
        }
    }

    def private dispatch methodName(Action it) '''«name.formatForCode.toFirstLower»'''

    def private dispatch methodName(MainAction it) '''«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»'''

    def private methodArgs(Action action) '''Request $request''' 

    def private dispatch methodArgs(Entity it, Action action) '''Request $request''' 
    def private dispatch methodArgsCall(Entity it, Action action) '''$request''' 

    def private dispatch actionRoute(Action it, Entity entity) '''
    '''

    def private dispatch actionRoute(MainAction it, Entity entity) '''
         «' '»*
         «' '»* @Route("/%«app.appName.formatForDB».routing.«entity.name.formatForCode».plural%",
         «' '»*        name = "«app.appName.formatForDB»_«entity.name.formatForCode»_index",
         «' '»*        methods = {"GET"}
         «' '»* )
    '''

    def private dispatch actionRoute(ViewAction it, Entity entity) '''
         «' '»*
         «' '»* @Route("/%«app.appName.formatForDB».routing.«entity.name.formatForCode».plural%/%«app.appName.formatForDB».routing.view.suffix%/{sort}/{sortdir}/{pos}/{num}.{_format}",
         «' '»*        name = "«app.appName.formatForDB»_«entity.name.formatForCode»_view",
         «' '»*        requirements = {"sortdir" = "asc|desc|ASC|DESC", "pos" = "\d+", "num" = "\d+", "_format" = "%«app.appName.formatForDB».routing.formats.view%"},
         «' '»*        defaults = {"sort" = "", "sortdir" = "asc", "pos" = 1, "num" = 0, "_format" = "html"},
         «' '»*        methods = {"GET"}
         «' '»* )
    '''

    def private actionRouteForSingleEntity(Entity it, Action action) '''
         «' '»*
         «' '»* @Route("/%«app.appName.formatForDB».routing.«name.formatForCode».singular%/«IF !(action instanceof DisplayAction)»«action.name.formatForCode»/«ENDIF»«actionRouteParamsForSingleEntity(action)».{_format}",
         «' '»*        name = "«app.appName.formatForDB»_«name.formatForCode»_«action.name.formatForCode»",
         «' '»*        requirements = {«actionRouteRequirementsForSingleEntity(action)», "_format" = "«IF action instanceof DisplayAction»%«app.appName.formatForDB».routing.formats.display%«ELSE»html«ENDIF»"},
         «' '»*        defaults = {«IF action instanceof EditAction»«actionRouteDefaultsForSingleEntity(action)», «ENDIF»"_format" = "html"},
         «' '»*        methods = {"GET"«IF action instanceof EditAction || action instanceof DeleteAction», "POST"«ENDIF»}
         «' '»* )
    '''

    def private actionRouteParamsForSingleEntity(Entity it, Action action) {
        var output = ''
        if (hasSluggableFields && !(action instanceof EditAction)) {
            output = '{slug}'
            if (slugUnique) {
                return output
            }
            output = output + '.'
        }
        output = output + getPrimaryKeyFields.map['{' + name.formatForCode + '}'].join('_')

        output
    }

    def private actionRouteRequirementsForSingleEntity(Entity it, Action action) {
        var output = ''
        if (hasSluggableFields && !(action instanceof EditAction)) {
            output = '''"slug" = "[^/.]+"'''
            if (slugUnique) {
                return output
            }
        }
        output = output + getPrimaryKeyFields.map['''"«name.formatForCode»" = "\d+"'''].join(', ')

        output
    }

    def private actionRouteDefaultsForSingleEntity(Entity it, Action action) {
        var output = ''
        if (hasSluggableFields && !(action instanceof EditAction)) {
            output = '''"slug" = ""'''
            if (slugUnique) {
                return output
            }
        }
        output = output + getPrimaryKeyFields.map['''"«name.formatForCode»" = "0"'''].join(', ')

        output
    }

    def private dispatch methodArgs(Entity it, ViewAction action) '''Request $request, $sort, $sortdir, $pos, $num''' 
    def private dispatch methodArgsCall(Entity it, ViewAction action) '''$request, $sort, $sortdir, $pos, $num''' 

    def private dispatch methodArgs(Entity it, DisplayAction action) '''Request $request, «name.formatForCodeCapital»Entity $«name.formatForCode»''' 
    def private dispatch methodArgsCall(Entity it, DisplayAction action) '''$request, $«name.formatForCode»''' 

    def private dispatch actionRoute(DisplayAction it, Entity entity) '''
        «actionRouteForSingleEntity(entity, it)»
    '''

    def private dispatch methodArgs(Entity it, EditAction action) '''Request $request«/* TODO migrate to Symfony forms #416 */»''' 
    def private dispatch methodArgsCall(Entity it, EditAction action) '''$request«/* TODO migrate to Symfony forms #416 */»''' 

    def private dispatch actionRoute(EditAction it, Entity entity) '''
        «actionRouteForSingleEntity(entity, it)»
    '''

    def private dispatch methodArgs(Entity it, DeleteAction action) '''Request $request, «name.formatForCodeCapital»Entity $«name.formatForCode»''' 
    def private dispatch methodArgsCall(Entity it, DeleteAction action) '''$request, $«name.formatForCode»''' 

    def private dispatch actionRoute(DeleteAction it, Entity entity) '''
        «actionRouteForSingleEntity(entity, it)»
    '''

    def private dispatch actionRoute(CustomAction it, Entity entity) '''
         «' '»*
         «' '»* @Route("/%«app.appName.formatForDB».routing.«entity.name.formatForCode».plural%/«name.formatForCode»",
         «' '»*        name = "«app.appName.formatForDB»_«entity.name.formatForCode»_«name.formatForCode»",
         «' '»*        methods = {"GET", "POST"}
         «' '»* )
    '''

    // currently called for DisplayAction and DeleteAction
    def private paramConverter(Entity it) '''
         «' '»* @ParamConverter("«name.formatForCode»", class="«app.appName»:«name.formatForCodeCapital»Entity", options={«paramConverterOptions»})
    '''

    def private paramConverterOptions(Entity it) {
        var output = ''
        if (hasSluggableFields && slugUnique) {
            output = '"id" = "slug", "repository_method" = "selectBySlug"'
            // since we use the id property selectBySlug receives the slug value directly instead array('slug' => 'my-title')
            return output
        }
        val needsMapping = hasSluggableFields || hasCompositeKeys
        if (!needsMapping) {
            output = '"id" = "' + getFirstPrimaryKey.name.formatForCode + '", "repository_method" = "selectById"'
            // since we use the id property selectById receives the slug value directly instead array('id' => 123)
            return output
        }

        // we have no single primary key or unique slug so we need to define a mapping hash option
        if (hasSluggableFields) {
            output = output + '"slug": "slug"'
        }

        output = output + getPrimaryKeyFields.map['"' + name.formatForCode + '": "' + name.formatForCode + '"'].join(', ')
        output = output + ', "repository_method" = "selectByIdList"'
        // selectByIdList receives an array like array('fooid' => 123, 'otherfield' => 456)

        // add mapping hash
        output = '"mapping": {' + output + '}'

        output
    }
}
