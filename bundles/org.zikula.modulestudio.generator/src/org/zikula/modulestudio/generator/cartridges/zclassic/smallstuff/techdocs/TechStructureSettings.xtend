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
            <td headers="hSettingName2">«IF language == 'de'»Panel zur Moderation«ELSE»Moderation panel«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«helper.flag(it, generateModerationPanel)»</td>
        </tr>
        <tr>
            <td headers="hSettingName1">«IF language == 'de'»Externe Aufrufe und Finder«ELSE»External calls and Finder«ENDIF»</td>
            <td headers="hSettingValue1" class="text-center">«helper.flag(it, generateExternalControllerAndFinder)»</td>
            <td headers="hSettingName2">«IF language == 'de'»Authentifizierungsmethode«ELSE»Authentication method«ENDIF»</td>
            <td headers="hSettingValue2" class="text-center">«authenticationMethod.literal» &ndash; «authenticationMethod.authMethodDescription»</td>
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
