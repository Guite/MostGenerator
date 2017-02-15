package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.Emails
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.Attributes
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.Categories
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.ModerationPanel
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.StandardFields
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.FilterSyntaxDialog
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Config
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Custom
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Delete
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Display
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.History
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Index
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.View
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.ViewHierarchy
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Csv
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Ics
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Json
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Kml
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export.Xml
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed.Atom
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed.Rss
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Views {

    extension ControllerExtensions = new ControllerExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IFileSystemAccess fsa
    Layout layoutHelper
    Relations relationHelper

    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        layoutHelper = new Layout(fsa)
        relationHelper = new Relations()

        // main action templates
        for (entity : getAllEntities) {
            generateViews(entity)
        }

        // helper templates
        if (hasAttributableEntities) {
            new Attributes().generate(it, fsa)
        }
        if (hasCategorisableEntities) {
            new Categories().generate(it, fsa)
        }
        if (generateModerationPanel && needsApproval) {
            new ModerationPanel().generate(it, fsa)
        }
        if (hasStandardFieldEntities) {
            new StandardFields().generate(it, fsa)
        }

        layoutHelper.baseTemplates(it)
        new FilterSyntaxDialog().generate(it, fsa)
        if (needsConfig) {
            new Config().generate(it, fsa)
        }
        if (needsApproval) {
            new Emails().generate(it, fsa)
        }
        if (generateExternalControllerAndFinder || !joinRelations.empty) {
            layoutHelper.rawPageFile(it)
        }
        layoutHelper.pdfHeaderFile(it)
    }

    def private generateViews(Application it, Entity entity) {
        if (entity.hasIndexAction) {
            new Index().generate(entity, fsa)
        }
        if (entity.hasViewAction) {
            new View().generate(entity, appName, 3, fsa)
            if (entity.tree != EntityTreeType.NONE) {
                new ViewHierarchy().generate(entity, appName, fsa)
            }
            if (generateCsvTemplates) {
                new Csv().generate(entity, appName, fsa)
            }
            if (generateRssTemplates) {
                new Rss().generate(entity, appName, fsa)
            }
            if (generateAtomTemplates) {
                new Atom().generate(entity, appName, fsa)
            }
        }
        if (entity.hasViewAction || entity.hasDisplayAction) {
            if (generateXmlTemplates) {
                new Xml().generate(entity, appName, fsa)
            }
            if (generateJsonTemplates) {
                new Json().generate(entity, appName, fsa)
            }
            if (generateKmlTemplates && entity.geographical) {
                new Kml().generate(entity, appName, fsa)
            }
        }
        if (entity.hasDisplayAction) {
            if (generateIcsTemplates && null !== entity.startDateField && null !== entity.endDateField) {
                new Ics().generate(entity, appName, fsa)
            }
        }
        if (entity.hasDisplayAction) {
            new Display().generate(entity, appName, fsa)
        }
        if (entity.hasDeleteAction) {
            new Delete().generate(entity, appName, fsa)
        }
        if (entity.loggable) {
            new History().generate(entity, appName, fsa)
        }

        var customHelper = new Custom()
        for (action : entity.getCustomActions) {
            customHelper.generate(action, it, entity, fsa)
        }

        // reverse logic like in the display template because we are treating the included template here
        val refedElems = entity.outgoing.filter(ManyToManyRelationship).filter[e|e.target instanceof Entity && e.target.application == entity.application]
                       + entity.getIncomingJoinRelations.filter[e|e.source instanceof Entity && e.source.application == entity.application]
        if (!refedElems.empty) {
            relationHelper.displayItemList(entity, it, false, fsa)
            relationHelper.displayItemList(entity, it, true, fsa)
        }
    }
}
