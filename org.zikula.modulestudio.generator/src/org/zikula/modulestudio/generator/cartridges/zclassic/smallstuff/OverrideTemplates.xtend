package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.AjaxController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class OverrideTemplates {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    /**
     * Entry point for module documentation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        val docPath = getAppDocPath

        var fileName = 'overridesTemplate_config.yml'
        if (!shouldBeSkipped(docPath + 'overridesTemplate_config.yml')) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'overridesTemplate_config.generated.yml'
            }
            fsa.generateFile(docPath + fileName, overrides('config'))
        }

        fileName = 'overridesTemplate_theme.yml'
        if (!shouldBeSkipped(docPath + 'overridesTemplate_theme.yml')) {
            if (shouldBeMarked(docPath + fileName)) {
                fileName = 'overridesTemplate_theme.generated.yml'
            }
            fsa.generateFile(docPath + fileName, overrides('theme'))
        }
    }

    def overrides(Application it, String mapType) '''
        «val isLegacy = if (targets('1.3.x')) true else false»
        «var sourcePath = getViewPath»
        «IF isLegacy»
            «{sourcePath = sourcePath.replace('src/', '');''}»
        «ELSE»
            «{sourcePath = rootFolder + '/' + (if (systemModule) name.formatForCodeCapital else vendorAndName) + '/' + sourcePath;''}»
        «ENDIF»
        «val destinationPath = if (mapType == 'config') 'config/templates/' + appName + '/' else 'themes/YourTheme/' + (if (isLegacy) 'templates' else 'Resources/views') + '/modules/' + appName + '/'»
        «var templateFolder = ''»
        «IF !isLegacy»
            «sourcePath»«templateFolder»base«templateExtension('html')»: «destinationPath»«templateFolder»base«templateExtension('html')»
            «sourcePath»«templateFolder»adminBase«templateExtension('html')»: «destinationPath»«templateFolder»adminBase«templateExtension('html')»
        «ENDIF»
        «FOR entity : getAllEntities»
            «{templateFolder = (if (isLegacy) entity.name.formatForCode else entity.name.formatForCodeCapital) + '/';''}»
            «IF entity.hasActions('index')»
                «val pageName = (if (isLegacy) 'main' else 'index')»
                «sourcePath»«templateFolder»«pageName»«templateExtension('html')»: «destinationPath»«templateFolder»«pageName»«templateExtension('html')»
            «ENDIF»
            «IF entity.hasActions('view')»
                «sourcePath»«templateFolder»view«templateExtension('html')»: «destinationPath»«templateFolder»view«templateExtension('html')»
                «sourcePath»«templateFolder»viewQuickNav«templateExtension('html')»: «destinationPath»«templateFolder»viewQuickNav«templateExtension('html')»
                «IF entity.tree != EntityTreeType.NONE»
                    «sourcePath»«templateFolder»viewTree«templateExtension('html')»: «destinationPath»«templateFolder»viewTree«templateExtension('html')»
                    «sourcePath»«templateFolder»viewTreeItems«templateExtension('html')»: «destinationPath»«templateFolder»viewTreeItems«templateExtension('html')»
                «ENDIF»
                «IF generateCsvTemplates»
                    «sourcePath»«templateFolder»view«templateExtension('csv')»: «destinationPath»«templateFolder»view«templateExtension('csv')»
                «ENDIF»
                «IF generateRssTemplates»
                    «sourcePath»«templateFolder»view«templateExtension('rss')»: «destinationPath»«templateFolder»view«templateExtension('rss')»
                «ENDIF»
                «IF generateAtomTemplates»
                    «sourcePath»«templateFolder»view«templateExtension('atom')»: «destinationPath»«templateFolder»view«templateExtension('atom')»
                «ENDIF»
            «ENDIF»
            «IF entity.hasActions('view') || entity.hasActions('display')»
                «IF generateXmlTemplates»
                    «IF entity.hasActions('view')»
                        «sourcePath»«templateFolder»view«templateExtension('xml')»: «destinationPath»«templateFolder»view«templateExtension('xml')»
                    «ENDIF»
                    «IF entity.hasActions('display')»
                        «sourcePath»«templateFolder»display«templateExtension('xml')»: «destinationPath»«templateFolder»display«templateExtension('xml')»
                    «ENDIF»
                    «sourcePath»«templateFolder»include«templateExtension('xml')»: «destinationPath»«templateFolder»include«templateExtension('xml')»
                «ENDIF»
                «IF generateJsonTemplates»
                    «IF entity.hasActions('view')»
                        «sourcePath»«templateFolder»view«templateExtension('json')»: «destinationPath»«templateFolder»view«templateExtension('json')»
                    «ENDIF»
                    «IF entity.hasActions('display')»
                        «sourcePath»«templateFolder»display«templateExtension('json')»: «destinationPath»«templateFolder»display«templateExtension('json')»
                    «ENDIF»
                «ENDIF»
                «IF generateKmlTemplates && entity.geographical»
                    «IF entity.hasActions('view')»
                        «sourcePath»«templateFolder»view«templateExtension('kml')»: «destinationPath»«templateFolder»view«templateExtension('kml')»
                    «ENDIF»
                    «IF entity.hasActions('display')»
                        «sourcePath»«templateFolder»display«templateExtension('kml')»: «destinationPath»«templateFolder»display«templateExtension('kml')»
                    «ENDIF»
                «ENDIF»
            «ENDIF»
            «IF entity.hasActions('display')»
                «IF generateIcsTemplates && null !== entity.startDateField && null !== entity.endDateField»
                    «sourcePath»«templateFolder»display«templateExtension('ics')»: «destinationPath»«templateFolder»display«templateExtension('ics')»
                «ENDIF»
            «ENDIF»
            «IF entity.hasActions('display')»
                «sourcePath»«templateFolder»display«templateExtension('html')»: «destinationPath»«templateFolder»display«templateExtension('html')»
                «IF entity.tree != EntityTreeType.NONE»
                    «sourcePath»«templateFolder»displayTreeRelatives«templateExtension('html')»: «destinationPath»«templateFolder»displayTreeRelatives«templateExtension('html')»
                «ENDIF»
            «ENDIF»
            «IF entity.hasActions('delete')»
                «sourcePath»«templateFolder»delete«templateExtension('html')»: «destinationPath»«templateFolder»delete«templateExtension('html')»
            «ENDIF»
            «FOR action : entity.getCustomActions»
                «sourcePath»«templateFolder»«action.name.formatForCode.toFirstLower»«templateExtension('html')»: «destinationPath»«templateFolder»«action.name.formatForCode.toFirstLower»«templateExtension('html')»
            «ENDFOR»
            «val refedElems = entity.getIncomingJoinRelations.filter[e|e.source instanceof Entity && e.source.application == entity.application] + entity.outgoing.filter(ManyToManyRelationship).filter[e|e.target instanceof Entity && e.target.application == entity.application]»
            «IF !refedElems.empty»
                «sourcePath»«templateFolder»includeDisplayItemListOne«templateExtension('html')»: «destinationPath»«templateFolder»includeDisplayItemListOne«templateExtension('html')»
                «sourcePath»«templateFolder»includeDisplayItemListMany«templateExtension('html')»: «destinationPath»«templateFolder»includeDisplayItemListMany«templateExtension('html')»
            «ENDIF»
        «ENDFOR»
        «FOR controller : adminAndUserControllers»
            «{templateFolder = (if (isLegacy) controller.formattedName else controller.formattedName.toFirstUpper) + '/';''}»
            «IF isLegacy»
                «sourcePath»«templateFolder»header«templateExtension('html')»: «destinationPath»«templateFolder»header«templateExtension('html')»
                «sourcePath»«templateFolder»footer«templateExtension('html')»: «destinationPath»«templateFolder»footer«templateExtension('html')»
            «ENDIF»
            «FOR action : controller.getCustomActions»
                «sourcePath»«templateFolder»«action.name.formatForCode.toFirstLower»«templateExtension('html')»: «destinationPath»«templateFolder»«action.name.formatForCode.toFirstLower»«templateExtension('html')»
            «ENDFOR»
        «ENDFOR»
        «FOR controller : controllers»
            «IF !(controller instanceof AjaxController)»
                «FOR action : controller.actions.filter(EditAction)»
                    «{templateFolder = (if (isLegacy) controller.formattedName else controller.formattedName.toFirstUpper) + '/';''}»
                    «sourcePath»«templateFolder»inlineRedirectHandler«templateExtension('html')»: «destinationPath»«templateFolder»inlineRedirectHandler«templateExtension('html')»
                «ENDFOR»
            «ENDIF»
        «ENDFOR»
        «FOR entity : getAllEntities.filter[hasActions('edit')]»
            «{templateFolder = (if (isLegacy) entity.name.formatForCode else entity.name.formatForCodeCapital) + '/';''}»
            «sourcePath»«templateFolder»edit«templateExtension('html')»: «destinationPath»«templateFolder»edit«templateExtension('html')»
            «sourcePath»«templateFolder»inlineRedirectHandler«templateExtension('html')»: «destinationPath»«templateFolder»inlineRedirectHandler«templateExtension('html')»
            «FOR relation : entity.getBidirectionalIncomingJoinRelations.filter[source.application == it && getEditStageCode(true) > 0]»
                «val useTarget = false»
                «IF (useTarget || relation instanceof ManyToManyRelationship)»
                    «val editSnippet = if (relation.getEditStageCode(true) > 1) 'Edit' else ''»
                    «var templateName = 'includeSelect' + editSnippet + relation.getTargetMultiplicity(useTarget)»
                    «var templateNameItemList = 'includeSelect' + editSnippet + 'ItemList' + relation.getTargetMultiplicity(useTarget)»
                    «sourcePath»«templateFolder»«templateName»«templateExtension('html')»: «destinationPath»«templateFolder»«templateName»«templateExtension('html')»
                    «sourcePath»«templateFolder»«templateNameItemList»«templateExtension('html')»: «destinationPath»«templateFolder»«templateNameItemList»«templateExtension('html')»
                «ENDIF»
            «ENDFOR»
            «FOR relation : entity.getOutgoingJoinRelations.filter[target.application == it && getEditStageCode(false) > 0]»
                «val useTarget = true»
                «IF (useTarget || relation instanceof ManyToManyRelationship)»
                    «val editSnippet = if (relation.getEditStageCode(false) > 1) 'Edit' else ''»
                    «var templateName = 'includeSelect' + editSnippet + relation.getTargetMultiplicity(useTarget)»
                    «var templateNameItemList = 'includeSelect' + editSnippet + 'ItemList' + relation.getTargetMultiplicity(useTarget)»
                    «sourcePath»«templateFolder»«templateName»«templateExtension('html')»: «destinationPath»«templateFolder»«templateName»«templateExtension('html')»
                    «sourcePath»«templateFolder»«templateNameItemList»«templateExtension('html')»: «destinationPath»«templateFolder»«templateNameItemList»«templateExtension('html')»
                «ENDIF»
            «ENDFOR»
        «ENDFOR»
        «{templateFolder = (if (isLegacy) 'helper' else 'Helper') + '/';''}»
        «IF hasAttributableEntities»
            «IF hasViewActions || hasDisplayActions»
                «sourcePath»«templateFolder»includeAttributesDisplay«templateExtension('html')»: «destinationPath»«templateFolder»includeAttributesDisplay«templateExtension('html')»
            «ENDIF»
            «IF hasEditActions»
                «sourcePath»«templateFolder»includeAttributesEdit«templateExtension('html')»: «destinationPath»«templateFolder»includeAttributesEdit«templateExtension('html')»
            «ENDIF»
        «ENDIF»
        «IF hasCategorisableEntities»
            «IF hasViewActions || hasDisplayActions»
                «sourcePath»«templateFolder»includeCategoriesDisplay«templateExtension('html')»: «destinationPath»«templateFolder»includeCategoriesDisplay«templateExtension('html')»
            «ENDIF»
            «IF hasEditActions»
                «sourcePath»«templateFolder»includeCategoriesEdit«templateExtension('html')»: «destinationPath»«templateFolder»includeCategoriesEdit«templateExtension('html')»
            «ENDIF»
        «ENDIF»
        «IF hasStandardFieldEntities»
            «IF hasViewActions || hasDisplayActions»
                «sourcePath»«templateFolder»includeStandardFieldsDisplay«templateExtension('html')»: «destinationPath»«templateFolder»includeStandardFieldsDisplay«templateExtension('html')»
            «ENDIF»
            «IF hasEditActions»
                «sourcePath»«templateFolder»includeStandardFieldsEdit«templateExtension('html')»: «destinationPath»«templateFolder»includeStandardFieldsEdit«templateExtension('html')»
            «ENDIF»
        «ENDIF»
        «IF hasMetaDataEntities»
            «IF hasViewActions || hasDisplayActions»
                «sourcePath»«templateFolder»includeMetaDataDisplay«templateExtension('html')»: «destinationPath»«templateFolder»includeMetaDataDisplay«templateExtension('html')»
            «ENDIF»
            «IF hasEditActions»
                «sourcePath»«templateFolder»includeMetaDataEdit«templateExtension('html')»: «destinationPath»«templateFolder»includeMetaDataEdit«templateExtension('html')»
            «ENDIF»
        «ENDIF»
        «IF !isLegacy»
            «sourcePath»includeFilterSyntaxDialog«templateExtension('html')»: «destinationPath»includeFilterSyntaxDialog«templateExtension('html')»
        «ENDIF»
        «IF needsConfig»
            «{templateFolder = (if (isLegacy) configController.formatForDB else configController.formatForDB.toFirstUpper) + '/';''}»
            «sourcePath»«templateFolder»config«templateExtension('html')»: «destinationPath»«templateFolder»config«templateExtension('html')»
        «ENDIF»
        «IF needsApproval»
            «{templateFolder = (if (isLegacy) 'email' else 'Email') + '/';''}»
            «val entitiesWithWorkflow = getAllEntities.filter[workflow != EntityWorkflowType.NONE]»
            «FOR entity : entitiesWithWorkflow»
                «sourcePath»«templateFolder»notify«entity.name.formatForCodeCapital»Creator«templateExtension('html')»: «destinationPath»«templateFolder»notify«entity.name.formatForCodeCapital»Creator«templateExtension('html')»
                «sourcePath»«templateFolder»notify«entity.name.formatForCodeCapital»Moderator«templateExtension('html')»: «destinationPath»«templateFolder»notify«entity.name.formatForCodeCapital»Moderator«templateExtension('html')»
            «ENDFOR»
        «ENDIF»
        «sourcePath»includePdfHeader«templateExtension('html')»: «destinationPath»includePdfHeader«templateExtension('html')»
    '''

    def private templateExtension(Application it, String format) {
        var ^extension = if (targets('1.3.x')) '.tpl' else '.twig'
        if (!targets('1.3.x') || format != 'html') {
            ^extension = '.' + format + ^extension
        }
        ^extension
    }
}
