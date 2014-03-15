package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Ics {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' ics view templates for entity "' + name.formatForDisplay + '"')
        val templateFilePath = templateFileWithExtension(controller, name, 'display', 'ics')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, icsDisplay(appName, controller))
        }
    }

    def private icsDisplay(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display ics view in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='text/calendar; charset=iso-8859-15'}{*charset=utf-8'*}
        {php}
            $«objName» = $this->get_template_vars('«objName»');
            «IF hasSluggableFields»
                header('Content-Disposition: attachment; filename="«name.formatForCode»_' . $«objName»['slug'] . '.ics"');
            «ELSE»
                header('Content-Disposition: attachment; filename="«name.formatForCode»_' . $«objName»->getTitleFromDisplayPattern() . '.ics"');
            «ENDIF»
        {/php}
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:{$baseurl}
        METHOD:PUBLISH
        BEGIN:VEVENT
        DTSTART:{php}$«objName» = $this->get_template_vars('«objName»'); echo gmdate('Ymd\THi00\Z', $«objName»['«getStartDateField.name.formatForCode»']) . "\r\n";{/php}
        DTEND:{php}$«objName» = $this->get_template_vars('«objName»'); echo gmdate('Ymd\THi00\Z', $«objName»['«getEndDateField.name.formatForCode»']) . "\r\n";{/php}
        {*if $«objName».zipcode ne '' && $«objName».city ne ''}{assign var='location' value="`$«objName».zipcode` `$«objName».city`"}LOCATION{$location|«appName.formatForDB»FormatIcalText}{/if}
        «IF geographical»
            {if $«objName».latitude && $«objName».longitude}GEO:{$«objName».longitude};{$«objName».latitude}
            {/if}
        «ENDIF»
        TRANSP:OPAQUE
        SEQUENCE:0
        UID:{php}$«objName» = $this->get_template_vars('«objName»'); echo md5('ICAL' . $«objName»['«getStartDateField.name.formatForCode»'] . rand(1, 5000) . $«objName»['«getEndDateField.name.formatForCode»']) . "\r\n";{/php}
        DTSTAMP:{php}echo gmdate('Ymd\THi00\Z', time()) . "\r\n";{/php}
        «IF standardFields»
            ORGANIZER;CN="{usergetvar name='uname' uid=$«objName».createdUserId}":MAILTO:{usergetvar name='email' uid=$«objName».createdUserId}
        «ENDIF»
        «IF categorisable»
            CATEGORIES:{foreach name='categoryLoop' key='propName' item='catMapping' from=$obj.categories}{if !$smarty.foreach.categoryLoop.first},{/if}{$catMapping.category.name|safetext|upper}{/foreach}
        «ENDIF»
        SUMMARY{$«objName»->getTitleFromDisplayPattern()|«appName.formatForDB»FormatIcalText}
        «IF hasTextFieldsEntity»
            «val field = getTextFieldsEntity.head»
            {if $«objName».«field.name.formatForCode» ne ''}DESCRIPTION{$«objName».«field.name.formatForCode»|«appName.formatForDB»FormatIcalText}{/if}
        «ENDIF»
        PRIORITY:5
        «IF hasUploadFieldsEntity»
            «FOR field : getUploadFieldsEntity»
                {if $«objName».«field.name.formatForCode»}ATTACH;VALUE=URL:{$«objName».«field.name.formatForCode»FullPathURL}
                {/if}
            «ENDFOR»
        «ENDIF»
        «IF !fields.filter(UrlField).empty»
            «FOR field : fields.filter(UrlField)»
                {if $«objName».«field.name.formatForCode»}ATTACH;VALUE=URL:{$«objName».«field.name.formatForCode»}
                {/if}
            «ENDFOR»
        «ENDIF»
        CLASS:PUBLIC
        STATUS:CONFIRMED
        END:VEVENT
        END:VCALENDAR
    '''
}
