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
        «val isLegacy = if (targets('1.3.5')) true else false»
        «val sourcePath = getViewPath»
        «val destinationPath = if (mapType == 'config') 'config/templates/' + appName + '/' else 'themes/YourTheme/templates/modules/' + appName + '/'»
        «var templateFolder = ''»
        «FOR entity : getAllEntities»
            «{templateFolder = (if (isLegacy) entity.name.formatForCode else entity.name.formatForCodeCapital) + '/';''}»
            «IF entity.hasActions('index')»
                «val pageName = (if (isLegacy) 'main' else 'index')»
                «sourcePath»«templateFolder»«pageName».tpl: «destinationPath»«templateFolder»«pageName».tpl
            «ENDIF»
            «IF entity.hasActions('view')»
                «sourcePath»«templateFolder»view.tpl: «destinationPath»«templateFolder»view.tpl
                «sourcePath»«templateFolder»view_quickNav.tpl: «destinationPath»«templateFolder»view_quickNav.tpl
                «IF entity.tree != EntityTreeType.NONE»
                    «sourcePath»«templateFolder»view_tree.tpl: «destinationPath»«templateFolder»view_tree.tpl
                    «sourcePath»«templateFolder»view_tree_items.tpl: «destinationPath»«templateFolder»view_tree_items.tpl
                «ENDIF»
                «IF generateCsvTemplates»
                    «sourcePath»«templateFolder»view.csv.tpl: «destinationPath»«templateFolder»view.csv.tpl
                «ENDIF»
                «IF generateRssTemplates»
                    «sourcePath»«templateFolder»view.rss.tpl: «destinationPath»«templateFolder»view.rss.tpl
                «ENDIF»
                «IF generateAtomTemplates»
                    «sourcePath»«templateFolder»view.atom.tpl: «destinationPath»«templateFolder»view.atom.tpl
                «ENDIF»
            «ENDIF»
            «IF entity.hasActions('view') || entity.hasActions('display')»
                «IF generateXmlTemplates»
                    «IF entity.hasActions('view')»
                        «sourcePath»«templateFolder»view.xml.tpl: «destinationPath»«templateFolder»view.xml.tpl
                    «ENDIF»
                    «IF entity.hasActions('display')»
                        «sourcePath»«templateFolder»display.xml.tpl: «destinationPath»«templateFolder»display.xml.tpl
                    «ENDIF»
                    «sourcePath»«templateFolder»include.xml.tpl: «destinationPath»«templateFolder»include.xml.tpl
                «ENDIF»
                «IF generateJsonTemplates»
                    «IF entity.hasActions('view')»
                        «sourcePath»«templateFolder»view.json.tpl: «destinationPath»«templateFolder»view.json.tpl
                    «ENDIF»
                    «IF entity.hasActions('display')»
                        «sourcePath»«templateFolder»display.json.tpl: «destinationPath»«templateFolder»display.json.tpl
                    «ENDIF»
                «ENDIF»
                «IF generateKmlTemplates && entity.geographical»
                    «IF entity.hasActions('view')»
                        «sourcePath»«templateFolder»view.kml.tpl: «destinationPath»«templateFolder»view.kml.tpl
                    «ENDIF»
                    «IF entity.hasActions('display')»
                        «sourcePath»«templateFolder»display.kml.tpl: «destinationPath»«templateFolder»display.kml.tpl
                    «ENDIF»
                «ENDIF»
            «ENDIF»
            «IF entity.hasActions('display')»
                «IF generateIcsTemplates && entity.getStartDateField !== null && entity.getEndDateField !== null»
                    «sourcePath»«templateFolder»display.ics.tpl: «destinationPath»«templateFolder»display.ics.tpl
                «ENDIF»
            «ENDIF»
            «IF entity.hasActions('display')»
                «sourcePath»«templateFolder»display.tpl: «destinationPath»«templateFolder»display.tpl
                «IF entity.tree != EntityTreeType.NONE»
                    «sourcePath»«templateFolder»display_treeRelatives.tpl: «destinationPath»«templateFolder»display_treeRelatives.tpl
                «ENDIF»
            «ENDIF»
            «IF entity.hasActions('delete')»
                «sourcePath»«templateFolder»delete.tpl: «destinationPath»«templateFolder»delete.tpl
            «ENDIF»
            «val refedElems = entity.getIncomingJoinRelations.filter[e|e.source instanceof Entity && e.source.application == entity.application] + entity.outgoing.filter(ManyToManyRelationship).filter[e|e.target instanceof Entity && e.target.application == entity.application]»
            «IF !refedElems.empty»
                «sourcePath»«templateFolder»include_displayItemListOne.tpl: «destinationPath»«templateFolder»include_displayItemListOne.tpl
                «sourcePath»«templateFolder»include_displayItemListMany.tpl: «destinationPath»«templateFolder»include_displayItemListMany.tpl
            «ENDIF»
        «ENDFOR»
        «FOR controller : adminAndUserControllers»
            «{templateFolder = (if (isLegacy) controller.formattedName else controller.formattedName.toFirstUpper) + '/';''}»
            «sourcePath»«templateFolder»header.tpl: «destinationPath»«templateFolder»header.tpl
            «sourcePath»«templateFolder»footer.tpl: «destinationPath»«templateFolder»footer.tpl
            «FOR action : controller.getCustomActions»
                «sourcePath»«templateFolder»«action.name.formatForCode.toFirstLower».tpl: «destinationPath»«templateFolder»«action.name.formatForCode.toFirstLower».tpl
            «ENDFOR»
        «ENDFOR»
        «FOR controller : controllers»
            «IF !(controller instanceof AjaxController)»
                «FOR action : controller.actions.filter(EditAction)»
                    «{templateFolder = (if (isLegacy) controller.formattedName else controller.formattedName.toFirstUpper) + '/';''}»
                    «sourcePath»«templateFolder»inlineRedirectHandler.tpl: «destinationPath»«templateFolder»inlineRedirectHandler.tpl
                «ENDFOR»
            «ENDIF»
        «ENDFOR»
        «FOR entity : getAllEntities.filter[hasActions('edit')]»
            «{templateFolder = (if (isLegacy) entity.name.formatForCode else entity.name.formatForCodeCapital) + '/';''}»
            «sourcePath»«templateFolder»edit.tpl: «destinationPath»«templateFolder»edit.tpl
            «sourcePath»«templateFolder»inlineRedirectHandler.tpl: «destinationPath»«templateFolder»inlineRedirectHandler.tpl
            «FOR relation : entity.getBidirectionalIncomingJoinRelations.filter[source.application == it && getEditStageCode(true) > 0]»
                «val useTarget = false»
                «IF (useTarget || relation instanceof ManyToManyRelationship)»
                    «val editSnippet = if (relation.getEditStageCode(true) > 1) 'Edit' else ''»
                    «var templateName = 'include_select' + editSnippet + relation.getTargetMultiplicity(useTarget)»
                    «var templateNameItemList = 'include_select' + editSnippet + 'ItemList' + relation.getTargetMultiplicity(useTarget)»
                    «sourcePath»«templateFolder»«templateName».tpl: «destinationPath»«templateFolder»«templateName».tpl
                    «sourcePath»«templateFolder»«templateNameItemList».tpl: «destinationPath»«templateFolder»«templateNameItemList».tpl
                «ENDIF»
            «ENDFOR»
            «FOR relation : entity.getOutgoingJoinRelations.filter[target.application == it && getEditStageCode(false) > 0]»
                «val useTarget = true»
                «IF (useTarget || relation instanceof ManyToManyRelationship)»
                    «val editSnippet = if (relation.getEditStageCode(false) > 1) 'Edit' else ''»
                    «var templateName = 'include_select' + editSnippet + relation.getTargetMultiplicity(useTarget)»
                    «var templateNameItemList = 'include_select' + editSnippet + 'ItemList' + relation.getTargetMultiplicity(useTarget)»
                    «sourcePath»«templateFolder»«templateName».tpl: «destinationPath»«templateFolder»«templateName».tpl
                    «sourcePath»«templateFolder»«templateNameItemList».tpl: «destinationPath»«templateFolder»«templateNameItemList».tpl
                «ENDIF»
            «ENDFOR»
        «ENDFOR»
        «{templateFolder = (if (isLegacy) 'helper' else 'Helper') + '/';''}»
        «IF hasAttributableEntities»
            «IF hasViewActions || hasDisplayActions»
                «sourcePath»«templateFolder»include_attributes_display.tpl: «destinationPath»«templateFolder»include_attributes_display.tpl
            «ENDIF»
            «IF hasEditActions»
                «sourcePath»«templateFolder»include_attributes_edit.tpl: «destinationPath»«templateFolder»include_attributes_edit.tpl
            «ENDIF»
        «ENDIF»
        «IF hasCategorisableEntities»
            «IF hasViewActions || hasDisplayActions»
                «sourcePath»«templateFolder»include_categories_display.tpl: «destinationPath»«templateFolder»include_categories_display.tpl
            «ENDIF»
            «IF hasEditActions»
                «sourcePath»«templateFolder»include_categories_edit.tpl: «destinationPath»«templateFolder»include_categories_edit.tpl
            «ENDIF»
        «ENDIF»
        «IF hasStandardFieldEntities»
            «IF hasViewActions || hasDisplayActions»
                «sourcePath»«templateFolder»include_standardfields_display.tpl: «destinationPath»«templateFolder»include_standardfields_display.tpl
            «ENDIF»
            «IF hasEditActions»
                «sourcePath»«templateFolder»include_standardfields_edit.tpl: «destinationPath»«templateFolder»include_standardfields_edit.tpl
            «ENDIF»
        «ENDIF»
        «IF hasMetaDataEntities»
            «IF hasViewActions || hasDisplayActions»
                «sourcePath»«templateFolder»include_metadata_display.tpl: «destinationPath»«templateFolder»include_metadata_display.tpl
            «ENDIF»
            «IF hasEditActions»
                «sourcePath»«templateFolder»include_metadata_edit.tpl: «destinationPath»«templateFolder»include_metadata_edit.tpl
            «ENDIF»
        «ENDIF»
        «IF !isLegacy»
            «sourcePath»include_filterSyntaxDialog.tpl: «destinationPath»include_filterSyntaxDialog.tpl
        «ENDIF»
        «IF needsConfig»
            «{templateFolder = (if (isLegacy) configController.formatForDB else configController.formatForDB.toFirstUpper) + '/';''}»
            «sourcePath»«templateFolder»config.tpl: «destinationPath»«templateFolder»config.tpl
        «ENDIF»
        «IF needsApproval»
            «{templateFolder = (if (isLegacy) 'email' else 'Email') + '/';''}»
            «val entitiesWithWorkflow = getAllEntities.filter[workflow != EntityWorkflowType.NONE]»
            «FOR entity : entitiesWithWorkflow»
                «sourcePath»«templateFolder»notify«entity.name.formatForCode»Creator.tpl: «destinationPath»«templateFolder»notify«entity.name.formatForCode»Creator.tpl
                «sourcePath»«templateFolder»notify«entity.name.formatForCode»Moderator.tpl: «destinationPath»«templateFolder»notify«entity.name.formatForCode»Moderator.tpl
            «ENDFOR»
        «ENDIF»
        «sourcePath»include_pdfheader.tpl: «destinationPath»include_pdfheader.tpl
    '''
}
