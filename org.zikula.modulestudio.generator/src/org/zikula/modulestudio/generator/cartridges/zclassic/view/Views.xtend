package org.zikula.modulestudio.generator.cartridges.zclassic.view

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.UserController
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
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
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Views {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils
    @Inject extension WorkflowExtensions = new WorkflowExtensions

    IFileSystemAccess fsa
    Relations relationHelper

    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        relationHelper = new Relations()
        for (controller : getAllControllers) {
            if (!(controller instanceof AjaxController)) {
                if (controller.tempIsUserController || controller.tempIsAdminController) {
                    generateViews(controller)
                }
                if (hasAttributableEntities) {
                    new Attributes().generate(it, controller, fsa)
                }
                if (hasCategorisableEntities) {
                    new Categories().generate(it, controller, fsa)
                }
                if (hasStandardFieldEntities) {
                    new StandardFields().generate(it, controller, fsa)
                }
                if (hasMetaDataEntities) {
                    new MetaData().generate(it, controller, fsa)
                }
            }
        }
        if (!targets('1.3.5')) {
            new FilterSyntaxDialog().generate(it, fsa)
        }
        if (needsConfig) {
            new Config().generate(it, fsa)
        }
        pdfHeaderFile
    }

    def private generateViews(Application it, Controller controller) {
        headerFooterFile(controller)
        if (controller.hasActions('index')) {
            var pageHelper = new Index()
            for (entity : getAllEntities) pageHelper.generate(entity, controller, fsa)
        }
        if (controller.hasActions('view')) {
            var pageHelperView = new View()
            for (entity : getAllEntities) pageHelperView.generate(entity, appName, controller, 3, fsa)
            var pageHelperViewTree = new ViewHierarchy()
            for (entity : getTreeEntities) pageHelperViewTree.generate(entity, appName, controller, fsa)
            if (generateCsvTemplates) {
                var pageHelperCsv = new Csv()
                for (entity : getAllEntities) pageHelperCsv.generate(entity, appName, controller, fsa)
            }
            if (generateRssTemplates) {
                var pageHelperRss = new Rss()
                for (entity : getAllEntities) pageHelperRss.generate(entity, appName, controller, fsa)
            }
            if (generateAtomTemplates) {
                var pageHelperAtom = new Atom()
                for (entity : getAllEntities) pageHelperAtom.generate(entity, appName, controller, fsa)
            }
        }
        if (controller.hasActions('view') || controller.hasActions('display')) {
            if (generateXmlTemplates) {
                var pageHelperXml = new Xml()
                for (entity : getAllEntities) pageHelperXml.generate(entity, appName, controller, fsa)
            }
            if (generateJsonTemplates) {
                var pageHelperJson = new Json()
                for (entity : getAllEntities) pageHelperJson.generate(entity, appName, controller, fsa)
            }
            if (generateKmlTemplates && hasGeographical) {
                var pageHelperKml = new Kml()
                for (entity : getAllEntities) pageHelperKml.generate(entity, appName, controller, fsa)
            }
        }
        if (controller.hasActions('display')) {
            var pageHelper = new Display()
            for (entity : getAllEntities) pageHelper.generate(entity, appName, controller, fsa)
        }
        if (controller.hasActions('delete')) {
            var pageHelper = new Delete()
            for (entity : getAllEntities) pageHelper.generate(entity, appName, controller, fsa)
        }
        var customHelper = new Custom()
        for (action : controller.getCustomActions) {
            customHelper.generate(action, it, controller, fsa)
        }

        if (controller.hasActions('display')) {
            // TODO: use relations to generate only required ones (???)
            for (entity : getAllEntities) {
                relationHelper.displayItemList(entity, it, controller, false, fsa)
                relationHelper.displayItemList(entity, it, controller, true, fsa)
            }
        }
    }

    def private tempIsAdminController(Controller it) {
        switch it {
            AdminController: true
            default: false
        }
    }

    def private tempIsUserController(Controller it) {
        switch it {
            UserController: true
            default: false
        }
    }

    def private headerFooterFile(Application it, Controller controller) {
        val templatePath = getViewPath + (if (targets('1.3.5')) controller.formattedName else controller.formattedName.toFirstUpper) + '/'
        fsa.generateFile(templatePath + 'header.tpl', headerImpl(controller))
        fsa.generateFile(templatePath + 'footer.tpl', footerImpl(controller))
    }

    def private headerImpl(Application it, Controller controller) '''
        {* purpose of this template: header for «controller.formattedName» area *}
        {pageaddvar name='javascript' value='prototype'}
        {pageaddvar name='javascript' value='validation'}
        {pageaddvar name='javascript' value='zikula'}
        {pageaddvar name='javascript' value='livepipe'}
        {pageaddvar name='javascript' value='zikula.ui'}
        {pageaddvar name='javascript' value='zikula.imageviewer'}
        {pageaddvar name='javascript' value='modules/«appName»/«IF targets('1.3.5')»javascript/«ELSE»«getAppJsPath»«ENDIF»«appName».js'}

        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «IF controller.tempIsAdminController»
                {adminheader}
            «ELSE»
                «IF targets('1.3.5')»
                    <div class="z-frontendbox">
                        <h2>{gt text='«name.formatForDisplayCapital»' comment='This is the title of the header template'}</h2>
                        {modulelinks modname='«appName»' type='«controller.formattedName»'}
                    </div>
                «ELSE»
                    <h2 class="userheader">{gt text='«name.formatForDisplayCapital»' comment='This is the title of the header template'}</h2>
                    {modulelinks modname='«appName»' type='«controller.formattedName»'}
                «ENDIF»
            «ENDIF»
            «IF generateModerationPanel && needsApproval && controller.tempIsUserController»
                {nocache}
                    {«appName.formatForDB»ModerationObjects assign='moderationObjects'}
                    {if count($moderationObjects) gt 0}
                        {foreach item='modItem' from=$moderationObjects}
                            <p class="«IF targets('1.3.5')»z-informationmsg z«ELSE»alert alert-info alert-dismissable text«ENDIF»-center">
                                «IF !targets('1.3.5')»
                                    <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                                «ENDIF»
                                <a href="{modurl modname='«appName»' type='admin' func='view' ot=$modItem.objectType workflowState=$modItem.state}" class="«IF targets('1.3.5')»z-«ENDIF»bold«IF !targets('1.3.5')» alert-link«ENDIF»">{$modItem.message}</a>
                            </p>
                        {/foreach}
                    {/if}
                {/nocache}
            «ENDIF»
        {/if}
        «IF controller.tempIsAdminController»
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
            «IF controller.tempIsAdminController»
                {adminfooter}
            «ENDIF»
        «IF hasEditActions»
        {elseif isset($smarty.get.func) && $smarty.get.func eq 'edit'}
            {pageaddvar name='stylesheet' value='style/core.css'}
            {pageaddvar name='stylesheet' value='modules/«appName»/«IF targets('1.3.5')»style/«ELSE»«getAppCssPath»«ENDIF»style.css'}
            «IF targets('1.3.5')»
            {pageaddvar name='stylesheet' value='system/Theme/style/form/style.css'}
            {pageaddvar name='stylesheet' value='themes/Andreas08/style/fluid960gs/reset.css'}
            «ELSE»
            {pageaddvar name='stylesheet' value='system/Zikula/Module/ThemeModule/Resources/public/css/form/style.css'}
            {pageaddvar name='stylesheet' value='themes/Zikula/Theme/Andreas08Theme/Resources/public/css/fluid960gs/reset.css'}
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
        fsa.generateFile(getViewPath + 'include_pdfheader.tpl', pdfHeaderImpl)
    }

    def private pdfHeaderImpl(Application it) '''
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{lang}" lang="{lang}">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <title>{pagegetvar name='title'}</title>
        <style>
            body {
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
