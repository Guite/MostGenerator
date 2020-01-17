package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.techdocs

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.AuthMethodType

class TechStructureSettings {

    TechHelper helper = new TechHelper
    String language

    def generate(Application it, String language) {
        this.language = language
        helper.table(it, settingsColumns, settingsHeader, settingsContent)
    }

    def private settingsColumns(Application it) '''
        <colgroup>
            <col id="cSettingName1" />
            <col id="cSettingValue1" />
            <col id="cSettingName2" />
            <col id="cSettingValue2" />
        </colgroup>
    '''

    def private settingsHeader(Application it) '''
        <tr>
            <th id="hSettingName1" scope="col" style="width: 25%">«IF language == 'de'»Einstellung«ELSE»Setting«ENDIF»</th>
            <th id="hSettingValue1" scope="col" class="text-center" style="width: 25%">«IF language == 'de'»Wert«ELSE»Value«ENDIF»</th>
            <th id="hSettingName2" scope="col" style="width: 25%">«IF language == 'de'»Einstellung«ELSE»Setting«ENDIF»</th>
            <th id="hSettingValue2" scope="col" class="text-center" style="width: 25%">«IF language == 'de'»Wert«ELSE»Value«ENDIF»</th>
        </tr>
    '''

    def private settingsContent(Application it) '''
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Systemmodul«ELSE»System module«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, isSystemModule)»</td>
            <td headers="hSettingName2">«IF language == 'de'»Anzahl Beispielsätze«ELSE»Amount of example rows«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«amountOfExampleRows»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Benutzerkonto«ELSE»Account panel«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateAccountApi)»</td>
            <td headers="hSettingName2">«IF language == 'de'»Suche«ELSE»Search integration«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateSearchApi)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Block für Listenansichten«ELSE»List view block«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateListBlock)»</td>
            <td headers="hSettingName2">«IF language == 'de'»Block für Detailansichten«ELSE»Detail view block«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateDetailBlock)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»ContentType für Listenansichten«ELSE»List view content type«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateListContentType)»</td>
            <td headers="hSettingName2">«IF language == 'de'»ContentType für Detailansichten«ELSE»Detail view content type«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateDetailContentType)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Support für Mailz«ELSE»Mailz support«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateMailzApi)»</td>
            <td headers="hSettingName2">«IF language == 'de'»Newsletter Plugin«ELSE»Newsletter plugin«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateNewsletterPlugin)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Block zur Moderation«ELSE»Moderation block«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateModerationBlock)»</td>
            <td headers="hSettingName2">«IF language == 'de'»Panel zur Moderation«ELSE»Moderation panel«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateModerationPanel)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Support für wartende Inhalte«ELSE»Pending content support«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generatePendingContentSupport)»</td>
            <td headers="hSettingName2">«IF language == 'de'»MultiHook Needles«ELSE»MultiHook needles«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateMultiHookNeedles)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Externe Aufrufe und Finder«ELSE»External calls and Finder«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateExternalControllerAndFinder)»</td>
            <td headers="hSettingName2">«IF language == 'de'»WYSIWYG-Plugins«ELSE»WYSIWYG plugins«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateScribitePlugins)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Authentifizierungsmethode«ELSE»Authentication method«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«authenticationMethod.literal» &ndash; «authenticationMethod.authMethodDescription»</td>
            <td headers="hSettingName2">«IF language == 'de'»Support für Tagging«ELSE»Tagging support«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateTagSupport)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Anbieter für Filter-Hooks«ELSE»Filter hooks provider«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«filterHookProvider.literal» &ndash; «helper.hookProviderDescription(filterHookProvider, language)»</td>
            <td headers="hSettingName2">«IF language == 'de'»Separate Admin-Templates«ELSE»Separate admin templates«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, separateAdminTemplates)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»RSS-Templates«ELSE»RSS templates«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateRssTemplates)»</td>
            <td headers="hSettingName2">«IF language == 'de'»Atom-Templates«ELSE»Atom templates«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateAtomTemplates)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»CSV-Templates«ELSE»CSV templates«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateCsvTemplates)»</td>
            <td headers="hSettingName2">«IF language == 'de'»XML-Templates«ELSE»XML templates«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateXmlTemplates)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»JSON-Templates«ELSE»JSON templates«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateJsonTemplates)»</td>
            <td headers="hSettingName2">«IF language == 'de'»KML-Templates«ELSE»KML templates«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateKmlTemplates)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»ICS-Templates«ELSE»ICS templates«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateIcsTemplates)»</td>
            <td headers="hSettingName2">«IF language == 'de'»PDF-Unterstützung«ELSE»PDF support«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generatePdfSupport)»</td>
        </tr>
    '''

    def authMethodDescription(AuthMethodType it) {
        switch it {
            case NONE:
                return if (language == 'de') 'keine Authentifizierungsmethode verfügbar.' else 'no authentication method available.'
            case REMOTE:
                return if (language == 'de') 'Wiederkehrende Authentifizierungsmethode.' else 'ReEntrant authentication method available.'
            case LOCAL:
                return if (language == 'de') 'Nicht wiederkehrende Authentifizierungsmethode.' else 'NonReEntrant authentication method.'
        }
    }
}
