package org.zikula.modulestudio.generator.cartridges.symfony.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.view.additions.Categories
import org.zikula.modulestudio.generator.cartridges.symfony.view.additions.Emails
import org.zikula.modulestudio.generator.cartridges.symfony.view.additions.StandardFields
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.Relations
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.Custom
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.Delete
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.Detail
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.History
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.Index
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.export.Csv
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.export.Ics
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.export.Json
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.export.Kml
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.export.Xml
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.feed.Atom
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.feed.Rss
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.view.ViewHierarchy
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.view.ViewMap
import org.zikula.modulestudio.generator.cartridges.symfony.view.pages.view.ViewTable
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Views {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IMostFileSystemAccess fsa
    Layout layoutHelper
    Relations relationHelper

    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        layoutHelper = new Layout(fsa)
        relationHelper = new Relations()

        // main action templates
        for (entity : getAllEntities) {
            generateViews(entity)
        }

        // helper templates
        if (hasCategorisableEntities) {
            new Categories().generate(it, fsa)
        }
        if (hasStandardFieldEntities) {
            new StandardFields().generate(it, fsa)
        }

        layoutHelper.baseTemplates(it)
        if (needsApproval) {
            new Emails().generate(it, fsa)
        }
        if (generatePdfSupport) {
            layoutHelper.pdfHeaderFile(it)
        }
    }

    def private generateViews(Application it, Entity entity) {
        if (entity.hasIndexAction) {
            new Index().generate(entity, fsa)
        }
        if (entity.hasIndexAction) {
            new ViewTable().generate(entity, appName, 3, fsa)
            if (entity.geographical) {
                new ViewMap().generate(entity, appName, fsa)
            }
            if (entity.tree != EntityTreeType.NONE) {
                new ViewHierarchy().generate(entity, appName, fsa)
            }
            if (generateCsvTemplates) {
                new Csv().generate(entity, fsa)
            }
            if (generateRssTemplates) {
                new Rss().generate(entity, fsa)
            }
            if (generateAtomTemplates) {
                new Atom().generate(entity, fsa)
            }
        }
        if (entity.hasIndexAction || entity.hasDetailAction) {
            if (generateXmlTemplates) {
                new Xml().generate(entity, fsa)
            }
            if (generateJsonTemplates) {
                new Json().generate(entity, fsa)
            }
            if (generateKmlTemplates && entity.geographical) {
                new Kml().generate(entity, fsa)
            }
        }
        if (entity.hasDetailAction) {
            if (generateIcsTemplates && null !== entity.startDateField && null !== entity.endDateField) {
                new Ics().generate(entity, fsa)
            }
        }
        if (entity.hasDetailAction) {
            new Detail().generate(entity, appName, fsa)
        }
        if (entity.hasDeleteAction) {
            new Delete().generate(entity, appName, fsa)
        }
        if (entity.loggable) {
            new History().generate(entity, appName, fsa)
        }

        var customHelper = new Custom()
        for (action : entity.actions.filter(CustomAction)) {
            customHelper.generate(action, it, entity, fsa)
        }

        // reverse logic like in the display template because we are treating the included template here
        val refedElems = entity.outgoing.filter(ManyToManyRelationship).filter[r|r.target instanceof Entity && r.target.application == entity.application]
                       + entity.getIncomingJoinRelations.filter[r|r.source instanceof Entity && r.source.application == entity.application]
        if (!refedElems.empty) {
            relationHelper.displayItemList(entity, it, false, fsa)
            relationHelper.displayItemList(entity, it, true, fsa)
        }
    }
}
