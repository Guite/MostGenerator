package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Variable
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class InstallerView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) 'init' else 'Init') + '/'

        var fileName = 'interactive.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'interactive.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, tplInit)
        }

        fileName = 'step2.tpl'
        if (needsConfig && !shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'step2.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, tplInitStep2)
        }

        fileName = 'step3.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'step3.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, tplInitStep3)
        }

        fileName = 'update.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'update.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, tplUpdate)
        }

        fileName = 'delete.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'delete.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, tplDelete)
        }
    }

    def private tplInit(Application it) '''
        {* Purpose of this template: 1st step of init process: welcome and information *}
        <h2>{gt text='Installation of «appName»'}</h2>
        <p>{gt text='Welcome to the installation of «appName»'}</p>
        <p>{gt text='Generated by <a href="«msUrl»" title="«msUrl»">ModuleStudio «msVersion»</a>.'}</p>
        <p>{gt text='Many features are contained in «appName» as for example:'}</p>
        <dl id="«appName.toFirstLower»FeatureList">
            <dt>{gt text='«getLeadingEntity.name.formatForDisplayCapital» management.'}</dt>
            <dd>{gt text='Easy management of «getLeadingEntity.nameMultiple.formatForDisplay»«IF entities.size > 1» and «IF relations.size > 1»related«ELSE»other«ENDIF» artifacts«ENDIF».'}</dd>
            <dd>{gt text='Included workflow support.'}</dd>
        «tplInitStep1Additions»
        «IF !controllers.filter[hasActions('view') || hasActions('display')].empty»
            <dt>{gt text='Output formats'}</dt>
            <dd>{gt text='Beside the normal templates «appName» includes also templates for various other output formats.'}</dd>
        «ENDIF»
            <dt>{gt text='Integration'}</dt>
            <dd>{gt text='«appName» offers a generic block allowing you to display arbitrary content elements in a block.'}</dd>
            <dd>{gt text='It is possible to integrate «appName» with Content. There is a corresponding content type available.'}</dd>
            «IF generateMailzApi || generateNewsletterPlugin»
                «IF targets('1.3.5')»
                    «IF generateMailzApi»
                        <dd>{gt text='There is also a Mailz plugin offering «appName» content for mailings and newsletters.'}</dd>
                    «ENDIF»
                «ELSE»
                    «IF generateMailzApi && generateNewsletterPlugin»
                        <dd>{gt text='There are also Newsletter and Mailz plugins offering «appName» content for mailings and newsletters.'}</dd>
                    «ELSEIF generateMailzApi»
                        <dd>{gt text='There is also a Mailz plugin offering «appName» content for mailings and newsletters.'}</dd>
                    «ELSEIF generateNewsletterPlugin»
                        <dd>{gt text='There is also a Newsletter plugin offering getting «appName» content for mailings and newsletters.'}</dd>
                    «ENDIF»
                «ENDIF»
            «ENDIF»
            <dd>{gt text='All these artifacts reuse the same templates for easier customisation. They can be extended by overriding and the addition of other template sets.'}</dd>
            «IF generateSearchApi»
                <dd>{gt text='«appName» integrates into the Zikula search module, too, of course.'}</dd>
            «ENDIF»
            <dt>{gt text='State-of-the-art technology'}</dt>
            <dd>{gt text='All parts of «appName» are always up to the latest version of the Zikula core«IF !targets('1.3.5')» and Symfony«ENDIF».'}</dd>
            <dd>{gt text='Entities, controllers, hooks, templates, plugins and more.'}</dd>
        </dl>
        <p>
            <a href="{modurl modname='«appName»' type='init' func='interactiveinitstep«IF needsConfig»2«ELSE»3«ENDIF»'}" title="{gt text='Continue'}">{gt text='Continue'}</a>
        </p>
    '''

    def private tplInitStep1Additions(Application it) '''
        «IF tplInitStep1HasAdditions»
            <dt>{gt text='Behaviours and extensions'}</dt>
        «IF hasAttributableEntities»
            <dd>{gt text='Automatic handling of generic attributes.'}</dd>
        «ENDIF»
        «IF hasCategorisableEntities»
            <dd>{gt text='Automatic handling of related categories.'}</dd>
        «ENDIF»
        «IF hasGeographical»
            <dd>{gt text='Coordinates handling including html5 geolocation support.'}</dd>
        «ENDIF»
        «IF hasLoggable»
            <dd>{gt text='Entity changes can be tracked automatically by creating corresponding version log entries.'}</dd>
        «ENDIF»
        «IF hasMetaDataEntities»
            <dd>{gt text='Automatic handling of attached meta data.'}</dd>
        «ENDIF»
        «IF hasStandardFieldEntities»
            <dd>{gt text='Automatic handling of standard fields, that are user id and date for creation and last update.'}</dd>
        «ENDIF»
        «IF hasTranslatable»
            <dd>{gt text='Translation management for data fields.'}</dd>
        «ENDIF»
        «IF hasTrees»
            <dd>{gt text='Tree structures can be managed in a hierarchy view with the help of ajax.'}</dd>
        «ENDIF»
        «ENDIF»
    '''

    def private tplInitStep1HasAdditions(Application it) {
        (hasAttributableEntities || hasCategorisableEntities || !hasGeographical
         || hasLoggable || hasMetaDataEntities || hasSortable || hasStandardFieldEntities || hasTranslatable || hasTrees)
    }

    def private tplInitStep2(Application it) '''
        {* Purpose of this template: 2nd step of init process: initial settings *}
        <h2>{gt text='Installation of «appName»'}</h2>
        <form action="{modurl modname='«appName»' type='init' func='interactiveinitstep2'}" method="post" enctype="application/x-www-form-urlencoded"«IF targets('1.3.5')» class="z-form"«ELSE» class="form-horizontal" role="form"«ENDIF»">
            <fieldset>
                <legend>{gt text='Settings'}</legend>
                <input type="hidden" name="csrftoken" value="{insert name='csrftoken'}" />

                «FOR modvar : getAllVariables»«modvar.tplInitStep2Var(it)»«ENDFOR»
            </fieldset>
            <fieldset>
                <legend>{gt text='Action'}</legend>

                <div class="«IF targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                    «IF targets('1.3.5')»
                        <label for="«appName»Activate">{gt text='Activate «appName» after installation?'}</label>
                        <input id="«appName»Activate" name="activate" type="checkbox" value="1" checked="checked" />
                    «ELSE»
                        <div class="col-lg-offset-3 col-lg-9">
                            <div class="checkbox">
                                <label>
                                    <input id="«appName»Activate" name="activate" type="checkbox" value="1" checked="checked" /> {gt text='Activate «appName» after installation?'}
                                </label>
                            </div>
                        </div>
                    «ENDIF»
                </div>

                <div class="«IF targets('1.3.5')»z-buttons z-formbuttons«ELSE»form-group form-buttons«ENDIF»">
                «IF !targets('1.3.5')»
                    <div class="col-lg-offset-3 col-lg-9">
                «ENDIF»
                    {formbutton commandName='submit' __text='Submit' class='«IF targets('1.3.5')»z-bt-save«ELSE»btn btn-success«ENDIF»'}
                «IF !targets('1.3.5')»
                    </div>
                «ENDIF»
                </div>
            </fieldset>
        </form>
    '''

    def private tplInitStep2Var(Variable it, Application app) '''
        <div class="«IF app.targets('1.3.4')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«formatForCode(app.name + '_' + name)»"«IF !app.targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='«name»'}</label>
            «IF !app.targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                <input id="«formatForCode(app.name + '_' + name)»" type="text" name="«name.formatForCode»" value="«value»" size="40"«IF !app.targets('1.3.5')» class="form-control"«ENDIF» />
            «IF !app.targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private tplInitStep3(Application it) '''
        {* Purpose of this template: 3rd step of init process: thanks *}
        <h2>{gt text='Installation of «appName»'}</h2>
        <p>{gt text='Last installation step'}</p>
        <p>{gt text='Thank you for installing «appName».<br />Click on the bottom link to finish the installation.' html='1'}</p>
        <p>
            {insert name='csrftoken' assign='csrftoken'}
            <a href="{modurl modname='Extensions' type='admin' func='initialise' csrftoken=$csrftoken activate=$activate}" title="{gt text='Continue'}">{gt text='Continue'}</a>
        </p>
    '''

    def private tplUpdate(Application it) '''

    '''

    def private tplDelete(Application it) '''
        {* Purpose of this template: delete process *}
        <h2>{gt text='Uninstall of «appName»'}</h2>
        <p>{gt text='Thank you for using «appName».<br />This application is going to be removed now!' html='1'}</p>
        <p>
            {insert name='csrftoken' assign='csrftoken'}
            <a href="{modurl modname='Extensions' type='admin' func='remove' csrftoken=$csrftoken}" title="{gt text='Uninstall «appName»'}">{gt text='Uninstall «appName»'}</a>
        </p>
        <p>
            <a href="{modurl modname='Extensions' type='admin' func='view'}" title="{gt text='Cancel uninstallation'}">{gt text='Cancel'}</a>
        </p>
    '''
}
