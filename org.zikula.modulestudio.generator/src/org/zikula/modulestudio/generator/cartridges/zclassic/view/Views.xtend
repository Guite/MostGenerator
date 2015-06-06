package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.UserController
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.Emails
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.Attributes
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.Categories
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.MetaData
import org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions.StandardFields
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.FilterSyntaxDialog
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Config
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Custom
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Delete
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.Display
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
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Views {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IFileSystemAccess fsa
    Relations relationHelper

    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        relationHelper = new Relations()

        // main action templates
        for (entity : getAllEntities) {
            generateViews(entity)
        }

        // helper templates
        var customHelper = new Custom()
        for (controller : adminAndUserControllers) {
            headerFooterFile(controller)
            for (action : controller.getCustomActions) {
                customHelper.generate(action, it, controller, fsa)
            }
        }

        if (hasAttributableEntities) {
            new Attributes().generate(it, fsa)
        }
        if (hasCategorisableEntities) {
            new Categories().generate(it, fsa)
        }
        if (hasStandardFieldEntities) {
            new StandardFields().generate(it, fsa)
        }
        if (hasMetaDataEntities) {
            new MetaData().generate(it, fsa)
        }

        if (!targets('1.3.x')) {
            new FilterSyntaxDialog().generate(it, fsa)
        }
        if (needsConfig) {
            new Config().generate(it, fsa)
        }
        if (needsApproval) {
            new Emails().generate(it, fsa)
        }
        pdfHeaderFile
    }

    def private generateViews(Application it, Entity entity) {
        if (entity.hasActions('index')) {
            new Index().generate(entity, fsa)
        }
        if (entity.hasActions('view')) {
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
        if (entity.hasActions('view') || entity.hasActions('display')) {
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
        if (entity.hasActions('display')) {
            if (generateIcsTemplates && entity.getStartDateField !== null && entity.getEndDateField !== null) {
                new Ics().generate(entity, appName, fsa)
            }
        }
        if (entity.hasActions('display')) {
            new Display().generate(entity, appName, fsa)
        }
        if (entity.hasActions('delete')) {
            new Delete().generate(entity, appName, fsa)
        }

        var customHelper = new Custom()
        for (action : entity.getCustomActions) {
            customHelper.generate(action, it, entity, fsa)
        }

        val refedElems = entity.getOutgoingJoinRelations.filter[e|e.target instanceof Entity && e.target.application == entity.application] + entity.incoming.filter(ManyToManyRelationship).filter[e|e.source instanceof Entity && e.source.application == entity.application]
        if (!refedElems.empty) {
            relationHelper.displayItemList(entity, it, false, fsa)
            relationHelper.displayItemList(entity, it, true, fsa)
        }
    }

    def private headerFooterFile(Application it, Controller controller) {
        val templatePath = getViewPath + (if (targets('1.3.x')) controller.formattedName else controller.formattedName.toFirstUpper) + '/'
        var fileName = 'header.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'header.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, headerImpl(controller))
        }
        fileName = 'footer.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'footer.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, footerImpl(controller))
        }
    }

    def private headerImpl(Application it, Controller controller) '''
        {* purpose of this template: header for «controller.formattedName» area *}
        «IF targets('1.3.x')»
            {pageaddvar name='javascript' value='prototype'}
            {pageaddvar name='javascript' value='validation'}
            {pageaddvar name='javascript' value='zikula'}
            {pageaddvar name='javascript' value='livepipe'}
            {pageaddvar name='javascript' value='zikula.ui'}
            «IF hasUploads»
                {pageaddvar name='javascript' value='zikula.imageviewer'}
            «ENDIF»
        «ELSE»
            {pageaddvar name='stylesheet' value='web/bootstrap/css/bootstrap.min.css'}
            {pageaddvar name='stylesheet' value='web/bootstrap/css/bootstrap-theme.min.css'}
            {pageaddvar name='javascript' value='jquery'}
            {pageaddvar name='javascript' value='web/bootstrap/js/bootstrap.min.js'}
            {pageaddvar name='javascript' value='zikula'}{* still required for Gettext *}
            «IF hasUploads»
                {pageaddvar name='javascript' value='web/bootstrap-media-lightbox/bootstrap-media-lightbox.min.js'}
                {pageaddvar name='stylesheet' value='web/bootstrap-media-lightbox/bootstrap-media-lightbox.css'}
            «ENDIF»
            «IF controller.hasActions('view') || controller.hasActions('display') || controller.hasActions('edit')»
                {pageaddvar name='stylesheet' value='web/bootstrap-jqueryui/bootstrap-jqueryui.min.css'}
                {pageaddvar name='javascript' value='web/bootstrap-jqueryui/bootstrap-jqueryui.min.js'}
                «IF controller.hasActions('edit')»
                    {pageaddvar name='javascript' value='polyfill' features='forms'}
                «ENDIF»
            «ENDIF»
        «ENDIF»
        «IF targets('1.3.x')»
            {pageaddvar name='javascript' value='«rootFolder»/«appName»/javascript/«appName».js'}
        «ELSE»
            {pageaddvar name='javascript' value='@«appName»/Resources/public/js/«appName».js'}
        «ENDIF»

        {* initialise additional gettext domain for translations within javascript *}
        {pageaddvar name='jsgettext' value='«IF targets('1.3.x')»module_«ENDIF»«appName.formatForDB»_js:«appName»'}

        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «IF controller instanceof AdminController»
                {adminheader}
            «ELSE»
                «IF targets('1.3.x')»
                    <div class="z-frontendbox">
                        <h2>{gt text='«name.formatForDisplayCapital»' comment='This is the title of the header template'}</h2>
                        {modulelinks modname='«appName»' type='«controller.formattedName»'}
                    </div>
                «ELSE»
                    <h2 class="userheader">{gt text='«name.formatForDisplayCapital»' comment='This is the title of the header template'}</h2>
                    {modulelinks modname='«appName»' type='«controller.formattedName»'}
                «ENDIF»
            «ENDIF»
            «IF generateModerationPanel && needsApproval && controller instanceof UserController»
                {nocache}
                    {«appName.formatForDB»ModerationObjects assign='moderationObjects'}
                    {if count($moderationObjects) gt 0}
                        {foreach item='modItem' from=$moderationObjects}
                            <p class="«IF targets('1.3.x')»z-informationmsg z«ELSE»alert alert-info alert-dismissable text«ENDIF»-center">
                                «IF targets('1.3.x')»
                                    <a href="{modurl modname='«appName»' type='admin' func='view' ot=$modItem.objectType workflowState=$modItem.state}" class="z-bold">{$modItem.message}</a>
                                «ELSE»
                                    <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                                    {assign var='itemObjectType' value=$modItem.objectType|lower}
                                    <a href="{route name="«appName.formatForDB»_`$itemObjectType`_view" lct='admin' workflowState=$modItem.state}" class="bold alert-link">{$modItem.message}</a>
                                «ENDIF»
                            </p>
                        {/foreach}
                    {/if}
                {/nocache}
            «ENDIF»
        {/if}
        «IF controller instanceof AdminController»
        «ELSE»
            {insert name='getstatusmsg'}
        «ENDIF»
    '''

    def private footerImpl(Application it, Controller controller) '''
        {* purpose of this template: footer for «controller.formattedName» area *}
        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «IF generatePoweredByBacklinksIntoFooterTemplates»
                «new FileHelper().msWeblink(it)»
            «ENDIF»
            «IF controller instanceof AdminController»
                {adminfooter}
            «ENDIF»
        «IF hasEditActions»
        {elseif isset($smarty.get.func) && $smarty.get.func eq 'edit'}
            {pageaddvar name='stylesheet' value='style/core.css'}
            «IF targets('1.3.x')»
                {pageaddvar name='stylesheet' value='«rootFolder»/«appName»/style/style.css'}
                {pageaddvar name='stylesheet' value='system/Theme/style/form/style.css'}
                {pageaddvar name='stylesheet' value='themes/Andreas08/style/fluid960gs/reset.css'}
            «ELSE»
                {pageaddvar name='stylesheet' value='@«appName»/Resources/public/css/style.css'}
                {pageaddvar name='stylesheet' value='@ZikulaThemeModule/Resources/public/css/form/style.css'}
                {pageaddvar name='stylesheet' value='@ZikulaAndreas08Theme/Resources/public/css/fluid960gs/reset.css'}
            «ENDIF»
            {capture assign='pageStyles'}
            <style type="text/css">
                body {
                    font-size: 70%;
                }
            </style>
            {/capture}
            {pageaddvar name='header' value=$pageStyles}
        «ENDIF»
        {/if}
    '''

    def private pdfHeaderFile(Application it) {
        var fileName = 'include_pdfheader.tpl'
        if (!shouldBeSkipped(getViewPath + fileName)) {
            if (shouldBeMarked(getViewPath + fileName)) {
                fileName = 'include_pdfheader.generated.tpl'
            }
            fsa.generateFile(getViewPath + fileName, pdfHeaderImpl)
        }
    }

    def private pdfHeaderImpl(Application it) '''
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{lang}" lang="{lang}">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <title>{pagegetvar name='title'}</title>
        <style>
            @page {
                margin: 0 2cm 1cm 1cm;
            }

            img {
                border-width: 0;
                vertical-align: middle;
            }
        </style>
        </head>
        <body>
    '''
}
