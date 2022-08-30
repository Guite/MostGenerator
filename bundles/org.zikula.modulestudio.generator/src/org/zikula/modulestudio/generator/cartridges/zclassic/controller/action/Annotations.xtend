package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DetailAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.IndexAction
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Annotations {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ViewExtensions = new ViewExtensions

    Application app

    new(Application app) {
        this.app = app
    }

    def generate(Action it, Entity entity, Boolean isAdmin, Boolean dummy) '''
        «actionRoute(entity, isAdmin)»
        «IF isAdmin»
            #[Theme('admin')]
        «ENDIF»
    '''

    def private dispatch actionRoute(Action it, Entity entity, Boolean isAdmin) '''
    '''

    def private dispatch actionRoute(IndexAction it, Entity entity, Boolean isAdmin) '''
        #[Route('/«IF isAdmin»admin/«ENDIF»«entity.nameMultiple.formatForCode»/view/{sort}/{sortdir}/{page}/{num}.{_format}',
            name: '«entity.application.name.formatForDB»_«entity.name.formatForDB»_«IF isAdmin»admin«ENDIF»index',
            requirements: ['sortdir' => 'asc|desc|ASC|DESC', 'page' => '\d+', 'num' => '\d+', '_format' => 'html«IF app.getListOfViewFormats.size > 0»|«app.getListOfViewFormats.join('|')»«ENDIF»'],
            defaults: ['sort' => '', 'sortdir' => 'asc', 'page' => 1, 'num' => 10, '_format' => 'html'],
            methods: ['GET']
        )]
    '''

    def private actionRouteForSingleEntity(Entity it, Action action, Boolean isAdmin) '''
        #[Route('/«IF isAdmin»admin/«ENDIF»«name.formatForCode»/«IF !(action instanceof DetailAction)»«action.name.formatForCode»/«ENDIF»«actionRouteParamsForSingleEntity(action)».{_format}',
            name: '«application.name.formatForDB»_«name.formatForDB»_«IF isAdmin»admin«ENDIF»detail',
            requirements: [«actionRouteRequirementsForSingleEntity(action)», '_format' => 'html«IF action instanceof DetailAction && app.getListOfDisplayFormats.size > 0»|«app.getListOfDisplayFormats.join('|')»«ENDIF»'],
            defaults: [«IF action instanceof EditAction»«actionRouteDefaultsForSingleEntity(action)», «ENDIF»'_format' => 'html'],
            methods: ['GET'«IF action instanceof EditAction || action instanceof DeleteAction», 'POST'«ENDIF»]«IF tree != EntityTreeType.NONE»,
            options: ['expose' => true]«ENDIF»
        )]
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
        output = output + '{' + getPrimaryKey.name.formatForCode + '}'

        output
    }

    def private actionRouteRequirementsForSingleEntity(Entity it, Action action) {
        var output = ''
        if (hasSluggableFields && !(action instanceof EditAction)) {
            output = '''«''»'slug' => '«IF tree != EntityTreeType.NONE»[^.]+«ELSE»[^/.]+«ENDIF»'«''»'''
            if (slugUnique) {
                return output
            }
            output = output + ', '
        }
        output = output + '''«''»'«getPrimaryKey.name.formatForCode»' => '\d+'«''»'''

        output
    }

    def private actionRouteDefaultsForSingleEntity(Entity it, Action action) {
        var output = ''
        if (hasSluggableFields && action instanceof DetailAction) {
            output = '''«''»'slug' => ''«''»'''
            if (slugUnique) {
                return output
            }
            output = output + ', '
        }
        output = output + '''«''»'«getPrimaryKey.name.formatForCode»' => 0'''

        output
    }

    def private dispatch actionRoute(DetailAction it, Entity entity, Boolean isAdmin) '''
        «actionRouteForSingleEntity(entity, it, isAdmin)»
    '''

    def private dispatch actionRoute(EditAction it, Entity entity, Boolean isAdmin) '''
        «actionRouteForSingleEntity(entity, it, isAdmin)»
    '''

    def private dispatch actionRoute(DeleteAction it, Entity entity, Boolean isAdmin) '''
        «actionRouteForSingleEntity(entity, it, isAdmin)»
    '''

    def private dispatch actionRoute(CustomAction it, Entity entity, Boolean isAdmin) '''
        #[Route('/«IF isAdmin»admin/«ENDIF»«entity.nameMultiple.formatForCode»/«name.formatForCode»',
            name: '«entity.application.name.formatForDB»_«entity.name.formatForDB»_«IF isAdmin»admin«ENDIF»«name.formatForDB»',
            methods: ['GET', 'POST']
        )]
    '''
}
