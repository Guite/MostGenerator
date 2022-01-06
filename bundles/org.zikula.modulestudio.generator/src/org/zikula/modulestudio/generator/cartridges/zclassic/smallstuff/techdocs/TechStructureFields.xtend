package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.techdocs

import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.ArrayType
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DateTimeComponents
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.EntityBlameableType
import de.guite.modulestudio.metamodel.EntityIpTraceableType
import de.guite.modulestudio.metamodel.EntityTimestampableType
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.IpAddressScope
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringIsbnStyle
import de.guite.modulestudio.metamodel.StringIssnStyle
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UploadNamingScheme
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class TechStructureFields {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions

    TechHelper helper = new TechHelper
    String language
    String prefix

    def dispatch generate(DataObject it, String language) {
        this.language = language
        prefix = 'Entity' + name.formatForCodeCapital + 'Field'
        helper.table(application, fieldColumns, fieldHeader, fieldContent)
    }

    def dispatch generate(Variables it, String language) {
        this.language = language
        prefix = 'Variables' + name.formatForCodeCapital + 'Field'
        helper.table(application, fieldColumns, fieldHeader, fieldContent)
    }

    def private fieldColumns(NamedObject it) '''
        <colgroup>
            <col id="c«prefix»Name" />
            <col id="c«prefix»Type" />
            <col id="c«prefix»Mandatory" />
            <col id="c«prefix»Default" />
            <col id="c«prefix»DisplayType" />
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
            <th id="h«prefix»DisplayType" scope="col">«IF language == 'de'»Anzeige«ELSE»Display«ENDIF»</th>
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
            <td headers="h«prefix»«name.formatForCodeCapital» h«prefix»DisplayType">«displayType.literal»</td>
            <td headers="h«prefix»«name.formatForCodeCapital» h«prefix»Constraints">
                <ul>
                    «FOR constraint : constraints»
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
    def private dispatch fieldType(ObjectField it) {
        if (language == 'de') 'Objekt' else 'Object'
    }
    def private dispatch fieldType(DatetimeField it) {
        if (language == 'de') {
            if (components == DateTimeComponents.DATE_TIME) 'Datum mit Zeit' else if (components == DateTimeComponents.DATE) 'Datum' else if (components == DateTimeComponents.TIME) 'Zeit'
        } else {
            if (components == DateTimeComponents.DATE_TIME) 'Date with time' else if (components == DateTimeComponents.DATE) 'Date' else if (components == DateTimeComponents.TIME) 'Time'
        }
    }

    def private dispatch fieldMandatory(Field it) {
        false
    }
    def private dispatch fieldMandatory(DerivedField it) {
        mandatory
    }

    def private dispatch constraints(Field it) {
        newArrayList
    }
    def private dispatch constraints(IntegerField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + '.'
            if (minValue.toString != '0' && maxValue.toString != '0') {
                if (minValue == maxValue) result += 'Die Werte müssen genau ' + minValue + ' betragen.'
                else result += 'Die Werte müssen zwischen ' + minValue + ' und ' + maxValue + ' liegen.'
            }
            else if (minValue.toString != '0') result += 'Die Werte dürfen nicht niedriger als ' + minValue + ' sein.'
            else if (maxValue.toString != '0') result += 'Die Werte dürfen nicht höher als ' + maxValue + ' sein.'
        } else {
            result += 'Has a length of ' + length + '.'
            if (minValue.toString != '0' && maxValue.toString != '0') {
                if (minValue == maxValue) result += 'Values must be exactly equal to ' + minValue + '.'
                else result += 'Values must be between ' + minValue + ' and ' + maxValue + '.'
            }
            else if (minValue.toString != '0') result += 'Values must not be lower than ' + minValue + '.'
            else if (maxValue.toString != '0') result += 'Values must not be greater than ' + maxValue + '.'
        }
        result
    }
    def private dispatch constraints(NumberField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' und eine Skalierung von ' + scale + '.'
            if (minValue > 0 && maxValue > 0) {
                if (minValue == maxValue) result += 'Die Werte müssen genau ' + minValue + ' betragen.'
                else result += 'Die Werte müssen zwischen ' + minValue + ' und ' + maxValue + ' liegen.'
            }
            else if (minValue > 0) result += 'Die Werte dürfen nicht niedriger als ' + minValue + ' sein.'
            else if (maxValue > 0) result += 'Die Werte dürfen nicht höher als ' + maxValue + ' sein.'
        } else {
            result += 'Has a length of ' + length + ' and a scale of ' + scale + '.'
            if (minValue > 0 && maxValue > 0) {
                if (minValue == maxValue) result += 'Values must be exactly equal to ' + minValue + '.'
                else result += 'Values must be between ' + minValue + ' and ' + maxValue + '.'
            }
            else if (minValue > 0) result += 'Values must not be lower than ' + minValue + '.'
            else if (maxValue > 0) result += 'Values must not be greater than ' + maxValue + '.'
        }
        result
    }
    def private dispatch constraints(UserField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + '.'
        } else {
            result += 'Has a length of ' + length + '.'
        }
        result
    }
    def private commonStringConstraints(AbstractStringField it) {
        val result = newArrayList
        if (language == 'de') {
            if (fixed) result += 'Die Feldlänge ist fixiert.'
            if (minLength > 0) result += 'Die minimale Länge beträgt ' + minLength + ' Zeichen.'
            if (null !== regexp && !regexp.empty) result += 'Die Werte werden gegen ' + (if (regexpOpposite) 'Nichtzutreffen' else 'Zutreffen') + ' auf den regulären Ausdruck <code>' + regexp + '</code> validiert.'
        } else {
            if (fixed) result += 'Field length is fixed.'
            if (minLength > 0) result += 'Minimum length is ' + minLength + ' chars.'
            if (null !== regexp && !regexp.empty) result += 'Values are validated against ' + (if (regexpOpposite) ' not') + ' matching the regular expression <code>' + regexp + '</code>.'
        }
        result
    }
    def private dispatch constraints(StringField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
        } else {
            result += 'Has a length of ' + length + ' chars.'
        }
        result += commonStringConstraints
        result
    }
    def private dispatch constraints(TextField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
        } else {
            result += 'Has a length of ' + length + ' chars.'
        }
        result += commonStringConstraints
        result
    }
    def private dispatch constraints(EmailField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
            result += commonStringConstraints
            result += 'Der Validierungsmodus ist auf "' + validationMode.validationModeAsString + '" eingestellt.'
        } else {
            result += 'Has a length of ' + length + ' chars.'
            result += commonStringConstraints
            result += 'Validation mode is set to "' + validationMode.validationModeAsString + '".'
        }
        result
    }
    def private dispatch constraints(UrlField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
            result += commonStringConstraints
        } else {
            result += 'Has a length of ' + length + ' chars.'
            result += commonStringConstraints
        }
        result
    }
    def private dispatch constraints(UploadField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
            result += commonStringConstraints
            result += 'Die erlaubten Dateierweiterungen sind "' + allowedExtensions + '".'
            result += 'Die erlaubten MIME-Typen sind "' + mimeTypes + '".'
            if (!maxSize.empty) result += 'Die maximale Dateigröße beträgt ' + maxSize + '.'
            if (isOnlyImageField) {
                if (minWidth > 0 && maxWidth > 0) {
                    if (minWidth == maxWidth) result += 'Die Breite von Bildern muß genau ' + minWidth + ' Pixel betragen.'
                    else result += 'Die Breite von Bildern muß zwischen ' + minWidth + ' und ' + maxWidth + ' Pixeln liegen.'
                }
                else if (minWidth > 0) result += 'Die Breite von Bildern darf nicht niedriger als ' + minWidth + ' Pixel sein.'
                else if (maxWidth > 0) result += 'Die Breite von Bildern darf nicht höher als ' + maxWidth + ' Pixel sein.'
                if (minHeight > 0 && maxHeight > 0) {
                    if (minHeight == maxHeight) result += 'Die Höhe von Bildern muß genau ' + minHeight + ' Pixel betragen.'
                    else result += 'Die Höhe von Bildern muß zwischen ' + minHeight + ' und ' + maxHeight + ' Pixeln liegen.'
                }
                else if (minHeight > 0) result += 'Die Höhe von Bildern darf nicht niedriger als ' + minHeight + ' Pixel sein.'
                else if (maxHeight > 0) result += 'Die Höhe von Bildern darf nicht höher als ' + maxHeight + ' Pixel sein.'
                if (minPixels > 0 && maxPixels > 0) {
                    if (minPixels == maxPixels) result += 'Die Anzahl von Pixeln muß genau ' + minPixels + ' Pixel betragen.'
                    else result += 'Die Anzahl von Pixeln muß zwischen ' + minPixels + ' und ' + maxPixels + ' Pixeln liegen.'
                }
                else if (minPixels > 0) result += 'Die Anzahl von Pixeln darf nicht niedriger als ' + minPixels + ' Pixel sein.'
                else if (maxPixels > 0) result += 'Die Anzahl von Pixeln darf nicht höher als ' + maxPixels + ' Pixel sein.'
                if (minRatio > 0 && maxRatio > 0) {
                    if (minRatio == maxRatio) result += 'Das Seitenverhältnis von Bildern (Breite / Höhe) muß genau ' + minRatio + ' betragen.'
                    else result += 'Das Seitenverhältnis von Bildern (Breite / Höhe) muß zwischen ' + minRatio + ' und ' + maxRatio + ' liegen.'
                }
                else if (minRatio > 0) result += 'Das Seitenverhältnis von Bildern (Breite / Höhe) darf nicht niedriger als ' + minRatio + ' sein.'
                else if (maxRatio > 0) result += 'Das Seitenverhältnis von Bildern (Breite / Höhe) darf nicht höher als ' + maxRatio + ' sein.'
                if (!(allowSquare && allowLandscape && allowPortrait)) {
                    if (allowSquare && !allowLandscape && !allowPortrait) {
                        result += 'Es ist nur Quadratformat (kein Hoch- oder Querformat) erlaubt.'
                    } else if (!allowSquare && allowLandscape && !allowPortrait) {
                        result += 'Es ist nur Querformat (kein Quadrat- oder Hochformat) erlaubt.'
                    } else if (!allowSquare && !allowLandscape && allowPortrait) {
                        result += 'Es ist nur Hochformat (kein Quadrat- oder Querformat) erlaubt.'
                    } else if (allowSquare && allowLandscape && !allowPortrait) {
                        result += 'Es sind nur Quadrat- oder Querformat (kein Hochformat) erlaubt.'
                    } else if (allowSquare && !allowLandscape && allowPortrait) {
                        result += 'Es sind nur Quadrat- oder Hochformat (kein Querformat) erlaubt.'
                    } else if (!allowSquare && allowLandscape && allowPortrait) {
                        result += 'Es sind nur Quer- oder Hochformat (kein Quadratformat) erlaubt.'
                    }
                }
                if (detectCorrupted) result += 'Bildinhalte werden gegen korrupte Daten geprüft.'
            }
        } else {
            result += 'Has a length of ' + length + ' chars.'
            result += commonStringConstraints
            result += 'Allowed file extensions are "' + allowedExtensions + '".'
            result += 'Allowed mime types are "' + mimeTypes + '".'
            if (!maxSize.empty) result += 'Maximum file size is ' + maxSize + '.'
            if (isOnlyImageField) {
                if (minWidth > 0 && maxWidth > 0) {
                    if (minWidth == maxWidth) result += 'Image width must be exactly equal to ' + minWidth + ' pixels.'
                    else result += 'Image width must be between ' + minWidth + ' and ' + maxWidth + ' pixels.'
                }
                else if (minWidth > 0) result += 'Image width must not be lower than ' + minWidth + ' pixels.'
                else if (maxWidth > 0) result += 'Image width must not be greater than ' + maxWidth + ' pixels.'
                if (minHeight > 0 && maxHeight > 0) {
                    if (minHeight == maxHeight) result += 'Image height must be exactly equal to ' + minHeight + ' pixels.'
                    else result += 'Image height must be between ' + minHeight + ' and ' + maxHeight + ' pixels.'
                }
                else if (minHeight > 0) result += 'Image height must not be lower than ' + minHeight + ' pixels.'
                else if (maxHeight > 0) result += 'Image height must not be greater than ' + maxHeight + ' pixels.'
                if (minPixels > 0 && maxPixels > 0) {
                    if (minPixels == maxPixels) result += 'The amount of pixels must be exactly equal to ' + minPixels + ' pixels.'
                    else result += 'The amount of pixels must be between ' + minPixels + ' and ' + maxPixels + ' pixels.'
                }
                else if (minPixels > 0) result += 'The amount of pixels must not be lower than ' + minPixels + ' pixels.'
                else if (maxPixels > 0) result += 'The amount of pixels must not be greater than ' + maxPixels + ' pixels.'
                if (minRatio > 0 && maxRatio > 0) {
                    if (minRatio == maxRatio) result += 'Image aspect ratio (width / height) must be exactly equal to ' + minRatio + '.'
                    else result += 'Image aspect ratio (width / height) must be between ' + minRatio + ' and ' + maxRatio + '.'
                }
                else if (minRatio > 0) result += 'Image aspect ratio (width / height) must not be lower than ' + minRatio + '.'
                else if (maxRatio > 0) result += 'Image aspect ratio (width / height) must not be greater than ' + maxRatio + '.'
                if (!(allowSquare && allowLandscape && allowPortrait)) {
                    if (allowSquare && !allowLandscape && !allowPortrait) {
                        result += 'Only square dimension (no portrait or landscape) is allowed.'
                    } else if (!allowSquare && allowLandscape && !allowPortrait) {
                        result += 'Only landscape dimension (no square or portrait) is allowed.'
                    } else if (!allowSquare && !allowLandscape && allowPortrait) {
                        result += 'Only portrait dimension (no square or landscape) is allowed.'
                    } else if (allowSquare && allowLandscape && !allowPortrait) {
                        result += 'Only square or landscape dimension (no portrait) is allowed.'
                    } else if (allowSquare && !allowLandscape && allowPortrait) {
                        result += 'Only square or portrait dimension (no landscape) is allowed.'
                    } else if (!allowSquare && allowLandscape && allowPortrait) {
                        result += 'Only landscape or portrait dimension (no square) is allowed.'
                    }
                }
                if (detectCorrupted) result += 'Image contents are validated against corrupted data.'
            }
        }
        result
    }
    def private dispatch constraints(ListField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
            result += commonStringConstraints
            if (min > 0 && max > 0) {
                if (min == max) result += 'Erfordert genau ' + min + ' ' + (if (min > 1) 'Einträge' else 'Eintrag') + '.'
                else result += 'Erfordert zwischen ' + min + ' und ' + max + ' Einträge.'
            }
            else if (min > 0) result += 'Erfordert mindestens ' + min + ' ' + (if (min > 1) 'Einträge' else 'Eintrag') + '.'
            else if (max > 0) result += 'Erfordert höchstens ' + max + ' Einträge.'
        } else {
            result += 'Has a length of ' + length + ' chars.'
            result += commonStringConstraints
            if (min > 0 && max > 0) {
                if (min == max) result += 'Requires exactly ' + min + ' ' + (if (min > 1) 'entries' else 'entry') + '.'
                else result += 'Requires between ' + min + ' and ' + max + ' entries.'
            }
            else if (min > 0) result += 'Requires at least ' + min + ' ' + (if (min > 1) 'entries' else 'entry') + '.'
            else if (max > 0) result += 'Requires at most ' + max + ' entries.'
        }
        result
    }
    def private dispatch constraints(ArrayField it) {
        val result = newArrayList
        if (language == 'de') {
            if (min > 0 && max > 0) {
                if (min == max) result += 'Erfordert genau ' + min + ' ' + (if (min > 1) 'Einträge' else 'Eintrag') + '.'
                else result += 'Erfordert zwischen ' + min + ' und ' + max + ' Einträge.'
            }
            else if (min > 0) result += 'Erfordert mindestens ' + min + ' ' + (if (min > 1) 'Einträge' else 'Eintrag') + '.'
            else if (max > 0) result += 'Erfordert höchstens ' + max + ' Einträge.'
        } else {
            if (min > 0 && max > 0) {
                if (min == max) result += 'Requires exactly ' + min + ' ' + (if (min > 1) 'entries' else 'entry') + '.'
                else result += 'Requires between ' + min + ' and ' + max + ' entries.'
            }
            else if (min > 0) result += 'Requires at least ' + min + ' ' + (if (min > 1) 'entries' else 'entry') + '.'
            else if (max > 0) result += 'Requires at most ' + max + ' entries.'
        }
        result
    }
    def private dispatch constraints(DatetimeField it) {
        val result = newArrayList
        if (language == 'de') {
            if (past) result += 'Die Werte müssen in der Vergangenheit liegen.'
            if (future) result += 'Die Werte müssen in der Zukunft liegen.'
            if (null !== validatorAddition && !validatorAddition.empty) result += 'Zusätzliche Validierung: <code>' + validatorAddition + '</code>.'
        } else {
            if (past) result += 'Values must be in the past.'
            if (future) result += 'Values must be in the future.'
            if (null !== validatorAddition && !validatorAddition.empty) result += 'Additional validation: <code>' + validatorAddition + '</code>.'
        }
        result
    }

    def private commonRemarks(DerivedField it) {
        val result = newArrayList
        if (null !== documentation && !documentation.empty) result += documentation + ' '
        if (language == 'de') {
            result += 'Dieses Feld ist ' + (if (!unique) 'nicht ' else '') + 'eindeutig und erlaubt ' + (if (!nullable) 'keine ' else '') + 'Null-Werte.'
            if (null !== dbName && !dbName.empty) result += 'Wird in der Datenbank als "' + dbName + '" gespeichert.'
            if (primaryKey) result += 'Fungiert als Primärschlüssel.'
            if (readonly) result += 'Erlaubt nur Lesezugriff.'
            if (!visible) result += 'Ist in Bearbeitungsformularen nicht sichtbar.'
            if (translatable) result += 'Dieses Feld ist übersetzbar.'
            if (sortableGroup) result += 'Fungiert als Gruppierkriterium für die Sortable-Erweiterung.'
        } else {
            result += 'This field is ' + (if (!unique) 'not ' else '') + 'unique and allows ' + (if (!nullable) 'no ' else '') + 'null values.'
            if (null !== dbName && !dbName.empty) result += 'Stored as "' + dbName + '" in the database.'
            if (primaryKey) result += 'Acts as primary key.'
            if (readonly) result += 'Allows read access only.'
            if (!visible) result += 'Is not visible in edit forms.'
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
            if (null !== aggregateFor && !aggregateFor.empty) result += 'Aggregiert eine 1:n Beziehung (' + aggregateFor + ').'
            if (percentage) result += 'Repräsentiert einen Prozentwert.'
            if (range) result += 'Repräsentiert einen Bereich.'
            if (version) result += 'Speichert die Version der Entität.'
            if (counter) result += 'Agiert als Zähler.'
        } else {
            if (sortablePosition) result += 'Stores the position for the Sortable extension.'
            if (null !== aggregateFor && !aggregateFor.empty) result += 'Aggregates a 1:n relation (' + aggregateFor + ').'
            if (percentage) result += 'Represents a percentage value.'
            if (range) result += 'Represents a range.'
            if (version) result += 'Stores the entity version.'
            if (counter) result += 'Acts as a counter.'
        }
        result
    }
    def private dispatch remarks(NumberField it) {
        val result = commonRemarks
        if (language == 'de') {
            if (aggregationField) result += 'Agiert als Aggregatsfeld.'
            if (currency) result += 'Repräsentiert einen Währungswert.'
            if (percentage) result += 'Repräsentiert einen Prozentwert.'
        } else {
            if (aggregationField) result += 'Acts as aggregation field.'
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
            if (isbn != StringIsbnStyle.NONE) result += '' + isbn.enumDescription
            if (issn != StringIssnStyle.NONE) result += 'Repräsentiert eine ISSN (internationale Standardsammelwerknummer).'
            if (ipAddress != IpAddressScope.NONE) result += 'Repräsentiert eine IP-Adresse (' + ipAddress.literal + ').'
            if (ipTraceable != EntityIpTraceableType.NONE) result += 'Verwendet die IpTraceable-Erweiterung (' + ipTraceable.literal + ').'
        } else {
            if (sluggablePosition > 0) result += 'Is part of the slug (position ' + sluggablePosition + ').'
            if (role != StringRole.NONE) result += '' + role.enumDescription
            if (isbn != StringIsbnStyle.NONE) result += '' + isbn.enumDescription
            if (issn != StringIssnStyle.NONE) result += 'Represents an ISSN (international standard serial number).'
            if (ipAddress != IpAddressScope.NONE) result += 'Represents an IP address (' + ipAddress.literal + ').'
            if (ipTraceable != EntityIpTraceableType.NONE) result += 'Uses the IpTraceable extension (' + ipTraceable.literal + ').'
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
            if (arrayType == ArrayType.ARRAY) {
                result += 'Verwendet ein normales Array.'
            } else if (arrayType == ArrayType.SIMPLE_ARRAY) {
                result += 'Verwendet ein einfaches Array, repräsentiert durch ein komma-getrenntes Textfeld.'
            } else if (arrayType == ArrayType.JSON_ARRAY) {
                result += 'Verwendet ein JSON Array.'
            }
        } else {
            if (arrayType == ArrayType.ARRAY) {
                result += 'Uses a normal array.'
            } else if (arrayType == ArrayType.SIMPLE_ARRAY) {
                result += 'Uses a simple array represented by a comma-separated text field.'
            } else if (arrayType == ArrayType.JSON_ARRAY) {
                result += 'Uses a JSON array.'
            }
        }
        result
    }
    def private dispatch remarks(ObjectField it) {
        commonRemarks
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
            case COLOUR:
                return if (language == 'de') 'Repräsentiert einen HTML-Farbcode (z. B. #003399).' else 'Represents a HTML colour code (e.g. #003399).'
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
            case UUID:
                return if (language == 'de') 'Repräsentiert eine UUID (Universally Unique Identifier).' else 'Represents an UUID (Universally Unique Identifier).'
            case WEEK:
                return if (language == 'de') 'Repräsentiert eine Wochennummer.' else 'Represents a week number.'
        }
    }

    def dispatch private enumDescription(StringIsbnStyle it) {
        switch it {
            case NONE:
                return ''
            case ISBN10:
                return if (language == 'de') 'Repräsentiert eine ISBN (internationale Standardbuchnummer) mit ISBN-10 Format.' else 'Represents an ISBN (international standard book number) with ISBN-10 format.'
            case ISBN13:
                return if (language == 'de') 'Repräsentiert eine ISBN (internationale Standardbuchnummer) mit ISBN-13 Format.' else 'Represents an ISBN (international standard book number) with ISBN-13 format.'
            case ALL:
                return if (language == 'de') 'Repräsentiert eine ISBN (internationale Standardbuchnummer) mit ISBN-10 und ISBN-13 Formaten.' else 'Represents an ISBN (international standard book number) with ISBN-10 and ISBN-13 formats.'
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
