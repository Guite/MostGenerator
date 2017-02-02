package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.ViewAction
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Annotations {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    Application app

    new(Application app) {
        this.app = app
    }

    def generate(Action it, Entity entity, Boolean isBase, Boolean isAdmin) '''
        «IF !isBase»
            «actionRoute(entity, isAdmin)»
            «IF isAdmin»
                «' '»* @Theme("admin")
            «ENDIF»
        «ELSE»
            «IF null !== entity»
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
    '''

    def private dispatch actionRoute(Action it, Entity entity, Boolean isAdmin) '''
    '''

    def private dispatch actionRoute(MainAction it, Entity entity, Boolean isAdmin) '''
         «' '»*
         «' '»* @Route("/«IF null !== entity»«IF isAdmin»admin/«ENDIF»«entity.nameMultiple.formatForCode»«ELSE»«controller.formattedName»«ENDIF»",
         «' '»*        methods = {"GET"}
         «' '»* )
    '''

    def private dispatch actionRoute(ViewAction it, Entity entity, Boolean isAdmin) '''
         «' '»*
         «' '»* @Route("/«IF isAdmin»admin/«ENDIF»«entity.nameMultiple.formatForCode»/view/{sort}/{sortdir}/{pos}/{num}.{_format}",
         «' '»*        requirements = {"sortdir" = "asc|desc|ASC|DESC", "pos" = "\d+", "num" = "\d+", "_format" = "html«IF app.getListOfViewFormats.size > 0»|«FOR format : app.getListOfViewFormats SEPARATOR '|'»«format»«ENDFOR»«ENDIF»"},
         «' '»*        defaults = {"sort" = "", "sortdir" = "asc", "pos" = 1, "num" = 10, "_format" = "html"},
         «' '»*        methods = {"GET"}
         «' '»* )
    '''

    def private actionRouteForSingleEntity(Entity it, Action action, Boolean isAdmin) '''
         «' '»*
         «' '»* @Route("/«IF isAdmin»admin/«ENDIF»«name.formatForCode»/«IF !(action instanceof DisplayAction)»«action.name.formatForCode»/«ENDIF»«actionRouteParamsForSingleEntity(action)».{_format}",
         «' '»*        requirements = {«actionRouteRequirementsForSingleEntity(action)», "_format" = "html«IF action instanceof DisplayAction && app.getListOfDisplayFormats.size > 0»|«FOR format : app.getListOfDisplayFormats SEPARATOR '|'»«format»«ENDFOR»«ENDIF»"},
         «' '»*        defaults = {«IF action instanceof EditAction»«actionRouteDefaultsForSingleEntity(action)», «ENDIF»"_format" = "html"},
         «' '»*        methods = {"GET"«IF action instanceof EditAction || action instanceof DeleteAction», "POST"«ENDIF»}«IF tree != EntityTreeType.NONE»,
         «' '»*        options={"expose"=true}«ENDIF»
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
            output = output + ', '
        }
        output = output + getPrimaryKeyFields.map['''"«name.formatForCode»" = "\d+"'''].join(', ')

        output
    }

    def private actionRouteDefaultsForSingleEntity(Entity it, Action action) {
        var output = ''
        if (hasSluggableFields && action instanceof DisplayAction) {
            output = '''"slug" = ""'''
            if (slugUnique) {
                return output
            }
            output = output + ', '
        }
        output = output + getPrimaryKeyFields.map['''"«name.formatForCode»" = "0"'''].join(', ')

        output
    }

    def private dispatch actionRoute(DisplayAction it, Entity entity, Boolean isAdmin) '''
        «actionRouteForSingleEntity(entity, it, isAdmin)»
    '''

    def private dispatch actionRoute(EditAction it, Entity entity, Boolean isAdmin) '''
        «actionRouteForSingleEntity(entity, it, isAdmin)»
    '''

    def private dispatch actionRoute(DeleteAction it, Entity entity, Boolean isAdmin) '''
        «actionRouteForSingleEntity(entity, it, isAdmin)»
    '''

    def private dispatch actionRoute(CustomAction it, Entity entity, Boolean isAdmin) '''
         «' '»*
         «' '»* @Route("/«IF null !== entity»«IF isAdmin»admin/«ENDIF»«entity.nameMultiple.formatForCode»«ELSE»«controller.formattedName»«ENDIF»/«name.formatForCode»",
         «' '»*        methods = {"GET", "POST"}
         «' '»* )
    '''

    // currently called for DisplayAction and DeleteAction
    def private paramConverter(Entity it) '''
         «' '»* @ParamConverter("«name.formatForCode»", class="«app.appName»:«name.formatForCodeCapital»Entity", options = {«paramConverterOptions»})
    '''

    def private paramConverterOptions(Entity it) {
        if (hasSluggableFields && slugUnique) {
            // since we use the id property selectBySlug receives the slug value directly instead ['slug' => 'my-title']
            return '"id" = "slug", "repository_method" = "selectBySlug"'
        }
        val needsMapping = hasSluggableFields || hasCompositeKeys
        if (!needsMapping) {
            // since we use the id property selectById receives the identifier value directly instead ['id' => 123]
            return '"id" = "' + getFirstPrimaryKey.name.formatForCode + '", "repository_method" = "selectById"'
        }

        // we have no single primary key or unique slug so we need to define a mapping hash option
        var output = '"mapping: {'
        if (hasSluggableFields) {
            output = output + '"slug": "slug", '
        }

        output = output + getPrimaryKeyFields.map['"' + name.formatForCode + '": "' + name.formatForCode + '"'].join(', ')
        output = output + '}, "repository_method" = "selectByIdList"'
        // selectByIdList receives an array like ['fooid' => 123, 'otherfield' => 456]

        output
    }
}
