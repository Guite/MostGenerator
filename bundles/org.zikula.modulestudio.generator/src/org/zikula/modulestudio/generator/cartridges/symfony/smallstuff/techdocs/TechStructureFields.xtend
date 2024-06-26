package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.techdocs

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.ArrayType
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DateTimeComponents
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.EntityBlameableType
import de.guite.modulestudio.metamodel.EntityTimestampableType
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UploadNamingScheme
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.cartridges.symfony.models.business.ValidationDocProvider
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class TechStructureFields {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    ValidationDocProvider validationDocProvider
    TechHelper helper = new TechHelper
    String language
    String prefix

    def dispatch generate(DataObject it, String language) {
        this.language = language
        validationDocProvider = new ValidationDocProvider(language)
        prefix = 'Entity' + name.formatForCodeCapital + 'Field'
        helper.table(application, fieldColumns, fieldHeader, fieldContent)
    }

    def dispatch generate(Variables it, String language) {
        this.language = language
        validationDocProvider = new ValidationDocProvider(language)
        prefix = 'Variables' + name.formatForCodeCapital + 'Field'
        helper.table(application, fieldColumns, fieldHeader, fieldContent)
    }

    def private fieldColumns(NamedObject it) '''
        <colgroup>
            <col id="c«prefix»Name" />
            <col id="c«prefix»Type" />
            <col id="c«prefix»Mandatory" />
            <col id="c«prefix»Default" />
            <col id="c«prefix»Visibility" />
            <col id="c«prefix»Constraints" />
            <col id="c«prefix»Remarks" />
        </colgroup>
    '''

    def private fieldHeader(NamedObject it) '''
        <tr>
            <th id="h«prefix»Name" scope="col">Name</th>
            <th id="h«prefix»Type" scope="col">«IF language == 'de'»Typ«ELSE»Type«ENDIF»</th>
            <th id="h«prefix»Mandatory" scope="col">«IF language == 'de'»Pflicht«ELSE»Mandatory«ENDIF»</th>
            <th id="h«prefix»Default" scope="col">«IF language == 'de'»Standardwert«ELSE»Default value«ENDIF»</th>
            <th id="h«prefix»Visibility" scope="col">«IF language == 'de'»Sichtbarkeit«ELSE»Visibility«ENDIF»</th>
            <th id="h«prefix»Constraints" scope="col">«IF language == 'de'»Beschränkungen«ELSE»Constraints«ENDIF»</th>
            <th id="h«prefix»Remarks" scope="col">«IF language == 'de'»Anmerkungen«ELSE»Remarks«ENDIF»</th>
        </tr>
    '''

    def private dispatch fieldContent(DataObject it) '''
        «FOR field : fields»
            «field.row»
        «ENDFOR»
    '''

    def private dispatch fieldContent(Variables it) '''
        «FOR field : fields»
            «field.row»
        «ENDFOR»
    '''

    def private row(Field it) '''
        <tr>
            <th id="h«prefix»«name.formatForCodeCapital»" scope="row" headers="h«prefix»Name">«name.formatForDisplayCapital»</th>
            <td headers="h«prefix»«name.formatForCodeCapital» h«prefix»Type">«fieldType»</td>
            <td headers="h«prefix»«name.formatForCodeCapital» h«prefix»Mandatory">«fieldMandatory»</td>
            <td headers="h«prefix»«name.formatForCodeCapital» h«prefix»Default">«fieldDefaultValue»</td>
            <td headers="h«prefix»«name.formatForCodeCapital» h«prefix»Visibility">
                <ul>
                    <li>«visibleFlag(visibleOnIndex)» «IF language == 'de'»auf Index-Seite«ELSE»on index page«ENDIF»</li>
                    <li>«visibleFlag(visibleOnDetail)» «IF language == 'de'»auf Detail-Seite«ELSE»on detail page«ENDIF»</li>
                    <li>«visibleFlag(visibleOnNew)» «IF language == 'de'»auf Erstellungsformular«ELSE»on creation form«ENDIF»</li>
                    <li>«visibleFlag(visibleOnEdit)» «IF language == 'de'»auf Bearbeitungsformular«ELSE»on editing form«ENDIF»</li>
                    <li>«usableFlag(visibleOnSort)» «IF language == 'de'»für Sortierung«ELSE»for sorting«ENDIF»</li>
                </ul>
            </td>
            <td headers="h«prefix»«name.formatForCodeCapital» h«prefix»Constraints">
                <ul>
                    «FOR constraint : validationDocProvider.constraints(it)»
                        <li>«constraint»</li>
                    «ENDFOR»
                </ul>
            </td>
            <td headers="h«prefix»«name.formatForCodeCapital» h«prefix»Remarks">
                <ul>
                    «FOR remark : remarks»
                        <li>«remark»</li>
                    «ENDFOR»
                </ul>
            </td>
        </tr>
    '''

    def private visibleFlag(Boolean flag) '''«IF flag»«IF language == 'de'»Sichtbar«ELSE»Visible«ENDIF»«ELSE»«IF language == 'de'»Nicht sichtbar«ELSE»Not visible«ENDIF»«ENDIF»'''
    def private usableFlag(Boolean flag) '''«IF flag»«IF language == 'de'»Nutzbar«ELSE»Usable«ENDIF»«ELSE»«IF language == 'de'»Nicht nutzbar«ELSE»Not usable«ENDIF»«ENDIF»'''

    def private dispatch fieldDefaultValue(Field it) {
        ''
    }
    def private dispatch fieldDefaultValue(DerivedField it) {
        defaultValue
    }

    def private dispatch fieldType(Field it) {
        ''
    }
    def private dispatch fieldType(BooleanField it) {
        if (language == 'de') 'Boolesches' else 'Boolean'
    }
    def private dispatch fieldType(IntegerField it) {
        if (language == 'de') 'Ganzzahl' else 'Integer'
    }
    def private dispatch fieldType(NumberField it) {
        if (language == 'de') {
            if (numberType == NumberFieldType.FLOAT) 'Fließkommazahl' else 'Dezimalzahl'
        } else {
            if (numberType == NumberFieldType.FLOAT) 'Floating number' else 'Decimal number'
        }
    }
    def private dispatch fieldType(UserField it) {
        if (language == 'de') 'Benutzer' else 'User'
    }
    def private dispatch fieldType(StringField it) {
        if (language == 'de') 'Zeichenkette' else 'String'
    }
    def private dispatch fieldType(TextField it) {
        'Text'
    }
    def private dispatch fieldType(EmailField it) {
        if (language == 'de') 'E-Mail-Adresse' else 'Email address'
    }
    def private dispatch fieldType(UrlField it) {
        'URL'
    }
    def private dispatch fieldType(UploadField it) {
        'Upload'
    }
    def private dispatch fieldType(ListField it) {
        if (language == 'de') 'Liste' else 'List'
    }
    def private dispatch fieldType(ArrayField it) {
        'Array'
    }
    def private dispatch fieldType(DatetimeField it) {
        if (language == 'de') {
            if (components == DateTimeComponents.DATE_TIME) 'Datum mit Zeit' else if (components == DateTimeComponents.DATE_TIME_TZ) 'Datum mit Zeit und Zeitzone' else if (components == DateTimeComponents.DATE) 'Datum' else if (components == DateTimeComponents.TIME) 'Zeit'
        } else {
            if (components == DateTimeComponents.DATE_TIME) 'Date with time' else if (components == DateTimeComponents.DATE_TIME_TZ) 'Date with time and time zone' else if (components == DateTimeComponents.DATE) 'Date' else if (components == DateTimeComponents.TIME) 'Time'
        }
    }

    def private dispatch fieldMandatory(Field it) {
        false
    }
    def private dispatch fieldMandatory(DerivedField it) {
        mandatory
    }


    def private commonRemarks(DerivedField it) {
        val result = newArrayList
        if (null !== documentation && !documentation.empty) result += documentation + ' '
        if (language == 'de') {
            result += 'Dieses Feld ist ' + (if (!unique) 'nicht ' else '') + 'eindeutig und erlaubt ' + (if (!nullable) 'keine ' else '') + 'Null-Werte.'
            if (null !== dbName && !dbName.empty) result += 'Wird in der Datenbank als "' + dbName + '" gespeichert.'
            if (primaryKey) result += 'Fungiert als Primärschlüssel.'
            if (readonly) result += 'Erlaubt nur Lesezugriff.'
            if (translatable) result += 'Dieses Feld ist übersetzbar.'
            if (sortableGroup) result += 'Fungiert als Gruppierkriterium für die Sortable-Erweiterung.'
        } else {
            result += 'This field is ' + (if (!unique) 'not ' else '') + 'unique and allows ' + (if (!nullable) 'no ' else '') + 'null values.'
            if (null !== dbName && !dbName.empty) result += 'Stored as "' + dbName + '" in the database.'
            if (primaryKey) result += 'Acts as primary key.'
            if (readonly) result += 'Allows read access only.'
            if (translatable) result += 'This field is translatable.'
            if (sortableGroup) result += 'Acts as grouping criteria for the Sortable extension.'
        }
        result
    }
    def private dispatch remarks(Field it) {
        newArrayList
    }
    def private dispatch remarks(BooleanField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (ajaxTogglability) result += 'Kann per Mausklick umgeschaltet werden.'
        } else {
            if (ajaxTogglability) result += 'Can be toggled at the click of a mouse.'
        }
        result
    }
    def private dispatch remarks(IntegerField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (sortablePosition) result += 'Speichert die Position für die Sortable-Erweiterung.'
            if (percentage) result += 'Repräsentiert einen Prozentwert.'
            if (range) result += 'Repräsentiert einen Bereich.'
            if (version) result += 'Speichert die Version der Entität.'
        } else {
            if (sortablePosition) result += 'Stores the position for the Sortable extension.'
            if (percentage) result += 'Represents a percentage value.'
            if (range) result += 'Represents a range.'
            if (version) result += 'Stores the entity version.'
        }
        result
    }
    def private dispatch remarks(NumberField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (currency) result += 'Repräsentiert einen Währungswert.'
            if (percentage) result += 'Repräsentiert einen Prozentwert.'
        } else {
            if (currency) result += 'Represents a currency value.'
            if (percentage) result += 'Represents a percentage value.'
        }
        result
    }
    def private dispatch remarks(UserField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (sortablePosition) result += 'Speichert die Position für die Sortable-Erweiterung.'
            if (blameable != EntityBlameableType.NONE) result += 'Verwendet die Blameable-Erweiterung (' + blameable.literal + ').'
        } else {
            if (sortablePosition) result += 'Stores the position for the Sortable extension.'
            if (blameable != EntityBlameableType.NONE) result += 'Uses the Blameable extension (' + blameable.literal + ').'
        }
        result
    }
    def private dispatch remarks(StringField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (sluggablePosition > 0) result += 'Ist Teil des Permalinks (Position ' + sluggablePosition + ').'
            if (role != StringRole.NONE) result += '' + role.enumDescription
        } else {
            if (sluggablePosition > 0) result += 'Is part of the slug (position ' + sluggablePosition + ').'
            if (role != StringRole.NONE) result += '' + role.enumDescription
        }
        result
    }
    def private dispatch remarks(TextField it) {
        commonRemarks
    }
    def private dispatch remarks(EmailField it) {
        commonRemarks
    }
    def private dispatch remarks(UrlField it) {
        commonRemarks
    }
    def private dispatch remarks(UploadField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (multiple) result += 'Das Feld erlaubt den Upload mehrerer Dateien.'
            result += 'Die hochgeladenen Dateien werden im Unterordner "' + subFolderPathSegment + '" gespeichert und ' + namingScheme.enumDescription
        } else {
            if (multiple) result += 'The field allows uploading multiple files.'
            result += 'Uploaded files are stored in the "' + subFolderPathSegment + '" subfolder and ' + namingScheme.enumDescription
        }
        result
    }
    def private dispatch remarks(ListField it) {
        val result = commonRemarks
        if (language == 'de') {
            result += 'Die Liste wird durch ' + (
                if (multiple) {
                    if (expanded) 'Checkboxen'
                    else 'eine mehrwertige Dropdownliste'
                } else {
                    if (expanded) 'Radio Buttons'
                    else 'eine einwertige Dropdownliste'
                }
            ) + ' repräsentiert.'
            result += 'Verfügbare Einträge: <ul>'
                + items.map['<li>' + name.toFirstUpper + ' (' + value + ')</li>'].join
                + '</ul>'
        } else {
            result += 'The list is represented by ' + (
                if (multiple) {
                    if (expanded) 'checkboxes'
                    else 'a multi-valued dropdown list'
                } else {
                    if (expanded) 'radio buttons'
                    else 'a single-valued dropdown list'
                }
            ) + '.'
            result += 'Available entries: <ul>'
                + items.map['<li>' + name.formatForDisplayCapital + ' (' + value + ')</li>'].join
                + '</ul>'
        }
        result
    }
    def private dispatch remarks(ArrayField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (arrayType == ArrayType.JSON) {
                result += 'Verwendet ein JSON Array.'
            } else if (arrayType == ArrayType.SIMPLE_ARRAY) {
                result += 'Verwendet ein einfaches Array, repräsentiert durch ein komma-getrenntes Textfeld.'
            }
        } else {
            if (arrayType == ArrayType.JSON) {
                result += 'Uses a JSON array.'
            } else if (arrayType == ArrayType.SIMPLE_ARRAY) {
                result += 'Uses a simple array represented by a comma-separated text field.'
            }
        }
        result
    }
    def private dispatch remarks(DatetimeField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (immutable) result += 'Die Werte sind unveränderbar.'
            if (startDate) result += 'Agiert als Startdatum.'
            if (endDate) result += 'Agiert als Enddatum.'
            if (timestampable != EntityTimestampableType.NONE) result += 'Verwendet die Timestampable-Erweiterung (' + timestampable.literal + ').'
        } else {
            if (immutable) result += 'Values are immutable.'
            if (startDate) result += 'Acts as start date.'
            if (endDate) result += 'Acts as end date.'
            if (timestampable != EntityTimestampableType.NONE) result += 'Uses the Timestampable extension (' + timestampable.literal + ').'
        }
        result
    }

    def dispatch private enumDescription(StringRole it) {
        switch it {
            case NONE:
                return ''
            case BIC:
                return if (language == 'de') 'Repräsentiert einen BIC (Business Identifier Code).' else 'Represents a BIC (business identifier code).'
            case CIDR:
                return if (language == 'de') 'Repräsentiert ein CIDR (classless inter-domain routing).' else 'Represents a CIDR (classless inter-domain routing).'
            case COLOUR:
                return if (language == 'de') 'Repräsentiert einen CSS-Farbcode.' else 'Represents a CSS colour code.'
            case COUNTRY:
                return if (language == 'de') 'Repräsentiert einen Ländercode.' else 'Represents a country code.'
            case CREDIT_CARD:
                return if (language == 'de') 'Repräsentiert eine Kreditkartennummer.' else 'Represents a credit card number.'
            case CURRENCY:
                return if (language == 'de') 'Repräsentiert einen Währungscode.' else 'Represents a currency code.'
            case DATE_INTERVAL:
                return if (language == 'de') 'Repräsentiert einen Zeitintervall.' else 'Represents an interval of time.'
            case HOSTNAME:
                return if (language == 'de') 'Repräsentiert einen Hostnamen inklusive einer Top-Level Domain.' else 'Represents a host name including a top-level domain.'
            case IBAN:
                return if (language == 'de') 'Repräsentiert eine IBAN (internationale Bankkontonummer).' else 'Represents an IBAN (international bank account number).'
            case ICON:
                return if (language == 'de') 'Repräsentiert ein Font Awesome Icon.' else 'Represents a Font Awesome icon.'
            case ISIN:
                return if (language == 'de') 'Repräsentiert eine ISIN (internationale Sicherheitsidentifikationsnummer).' else 'Represents an ISIN (international securities identification number).'
            case LANGUAGE:
                return if (language == 'de') 'Repräsentiert einen Unicode-Sprachcode.' else 'Represents an Unicode language identifier.'
            case LOCALE:
                return if (language == 'de') 'Repräsentiert eine Locale.' else 'Represents a locale.'
            case PASSWORD:
                return if (language == 'de') 'Repräsentiert ein Kennwort.' else 'Represents a password.'
            case PHONE_NUMBER:
                return if (language == 'de') 'Repräsentiert eine Telefonnummer.' else 'Represents a telephone number.'
            case TIME_ZONE:
                return if (language == 'de') 'Repräsentiert eine Zeitzone.' else 'Represents a time zone.'
            case ULID:
                return if (language == 'de') 'Repräsentiert eine ULID (Universally Unique Lexicographically Sortable Identifier).' else 'Represents an ULID (Universally Unique Lexicographically Sortable Identifier).'
            case UUID:
                return if (language == 'de') 'Repräsentiert eine UUID (Universally Unique Identifier).' else 'Represents an UUID (Universally Unique Identifier).'
            case WEEK:
                return if (language == 'de') 'Repräsentiert eine Wochennummer.' else 'Represents a week number.'
        }
    }

    def dispatch private enumDescription(UploadNamingScheme it) {
        switch it {
            case ORIGINALWITHCOUNTER:
                return if (language == 'de') 'behalten ihren originalen Dateinamen, der bei Bedarf um einen Zähler erweitert wird.' else 'keep their original file name which is extended by a counter if needed.'
            case RANDOMCHECKSUM:
                return if (language == 'de') 'werden mit einer zufälligen Prüfsumme umbenannt.' else 'are renamed using a random checksum.'
            case FIELDNAMEWITHCOUNTER:
                return if (language == 'de') 'werden nach dem Feldnamen als Präfix mit einem Zähler umbenannt.' else 'are renamed according to the field name as a prefix together with a counter.'
            case USERDEFINEDWITHCOUNTER:
                return if (language == 'de') 'können optional anhand eines individuellen Dateinamens umbenannt werden.' else 'may be renamed using an individual file name.'
        }
    }
}
