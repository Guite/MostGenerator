package org.zikula.modulestudio.generator.cartridges.zclassic.models.business

import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class ValidationDocProvider {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions

    String language

    new(String language) {
        this.language = language
    }

    def dispatch constraints(Field it) {
        newArrayList
    }
    def dispatch constraints(IntegerField it) {
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
    def dispatch constraints(NumberField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' und eine Skalierung von ' + scale + '.'
            if (0 < minValue && 0 < maxValue) {
                if (minValue == maxValue) result += 'Die Werte müssen genau ' + minValue + ' betragen.'
                else result += 'Die Werte müssen zwischen ' + minValue + ' und ' + maxValue + ' liegen.'
            }
            else if (0 < minValue) result += 'Die Werte dürfen nicht niedriger als ' + minValue + ' sein.'
            else if (0 < maxValue) result += 'Die Werte dürfen nicht höher als ' + maxValue + ' sein.'
        } else {
            result += 'Has a length of ' + length + ' and a scale of ' + scale + '.'
            if (0 < minValue && 0 < maxValue) {
                if (minValue == maxValue) result += 'Values must be exactly equal to ' + minValue + '.'
                else result += 'Values must be between ' + minValue + ' and ' + maxValue + '.'
            }
            else if (0 < minValue) result += 'Values must not be lower than ' + minValue + '.'
            else if (0 < maxValue) result += 'Values must not be greater than ' + maxValue + '.'
        }
        result
    }
    def dispatch constraints(UserField it) {
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
            if (0 < minLength) result += 'Die minimale Länge beträgt ' + minLength + ' Zeichen.'
            if (null !== regexp && !regexp.empty) result += 'Die Werte werden gegen ' + (if (regexpOpposite) 'Nichtzutreffen' else 'Zutreffen') + ' auf den regulären Ausdruck <code>' + regexp + '</code> validiert.'
        } else {
            if (fixed) result += 'Field length is fixed.'
            if (0 < minLength) result += 'Minimum length is ' + minLength + ' chars.'
            if (null !== regexp && !regexp.empty) result += 'Values are validated against ' + (if (regexpOpposite) ' not') + ' matching the regular expression <code>' + regexp + '</code>.'
        }
        result
    }
    def dispatch constraints(StringField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
        } else {
            result += 'Has a length of ' + length + ' chars.'
        }
        result += commonStringConstraints
        result
    }
    def dispatch constraints(TextField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
        } else {
            result += 'Has a length of ' + length + ' chars.'
        }
        result += commonStringConstraints
        result
    }
    def dispatch constraints(EmailField it) {
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
    def dispatch constraints(UrlField it) {
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
    def dispatch constraints(UploadField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
            result += commonStringConstraints
            result += 'Die erlaubten Dateierweiterungen sind "' + allowedExtensions + '".'
            result += 'Die erlaubten MIME-Typen sind "' + mimeTypes + '".'
            if (!maxSize.empty) result += 'Die maximale Dateigröße beträgt ' + maxSize + '.'
            if (isOnlyImageField) {
                if (0 < minWidth && 0 < maxWidth) {
                    if (minWidth == maxWidth) result += 'Die Breite von Bildern muß genau ' + minWidth + ' Pixel betragen.'
                    else result += 'Die Breite von Bildern muß zwischen ' + minWidth + ' und ' + maxWidth + ' Pixeln liegen.'
                }
                else if (0 < minWidth) result += 'Die Breite von Bildern darf nicht niedriger als ' + minWidth + ' Pixel sein.'
                else if (0 < maxWidth) result += 'Die Breite von Bildern darf nicht höher als ' + maxWidth + ' Pixel sein.'
                if (0 < minHeight && 0 < maxHeight) {
                    if (minHeight == maxHeight) result += 'Die Höhe von Bildern muß genau ' + minHeight + ' Pixel betragen.'
                    else result += 'Die Höhe von Bildern muß zwischen ' + minHeight + ' und ' + maxHeight + ' Pixeln liegen.'
                }
                else if (0 < minHeight) result += 'Die Höhe von Bildern darf nicht niedriger als ' + minHeight + ' Pixel sein.'
                else if (0 < maxHeight) result += 'Die Höhe von Bildern darf nicht höher als ' + maxHeight + ' Pixel sein.'
                if (0 < minPixels && 0 < maxPixels) {
                    if (minPixels == maxPixels) result += 'Die Anzahl von Pixeln muß genau ' + minPixels + ' Pixel betragen.'
                    else result += 'Die Anzahl von Pixeln muß zwischen ' + minPixels + ' und ' + maxPixels + ' Pixeln liegen.'
                }
                else if (0 < minPixels) result += 'Die Anzahl von Pixeln darf nicht niedriger als ' + minPixels + ' Pixel sein.'
                else if (0 < maxPixels) result += 'Die Anzahl von Pixeln darf nicht höher als ' + maxPixels + ' Pixel sein.'
                if (0 < minRatio && 0 < maxRatio) {
                    if (minRatio == maxRatio) result += 'Das Seitenverhältnis von Bildern (Breite / Höhe) muß genau ' + minRatio + ' betragen.'
                    else result += 'Das Seitenverhältnis von Bildern (Breite / Höhe) muß zwischen ' + minRatio + ' und ' + maxRatio + ' liegen.'
                }
                else if (0 < minRatio) result += 'Das Seitenverhältnis von Bildern (Breite / Höhe) darf nicht niedriger als ' + minRatio + ' sein.'
                else if (0 < maxRatio) result += 'Das Seitenverhältnis von Bildern (Breite / Höhe) darf nicht höher als ' + maxRatio + ' sein.'
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
                if (0 < minWidth && 0 < maxWidth) {
                    if (minWidth == maxWidth) result += 'Image width must be exactly equal to ' + minWidth + ' pixels.'
                    else result += 'Image width must be between ' + minWidth + ' and ' + maxWidth + ' pixels.'
                }
                else if (0 < minWidth) result += 'Image width must not be lower than ' + minWidth + ' pixels.'
                else if (0 < maxWidth) result += 'Image width must not be greater than ' + maxWidth + ' pixels.'
                if (0 < minHeight && 0 < maxHeight) {
                    if (minHeight == maxHeight) result += 'Image height must be exactly equal to ' + minHeight + ' pixels.'
                    else result += 'Image height must be between ' + minHeight + ' and ' + maxHeight + ' pixels.'
                }
                else if (0 < minHeight) result += 'Image height must not be lower than ' + minHeight + ' pixels.'
                else if (0 < maxHeight) result += 'Image height must not be greater than ' + maxHeight + ' pixels.'
                if (0 < minPixels && 0 < maxPixels) {
                    if (minPixels == maxPixels) result += 'The amount of pixels must be exactly equal to ' + minPixels + ' pixels.'
                    else result += 'The amount of pixels must be between ' + minPixels + ' and ' + maxPixels + ' pixels.'
                }
                else if (0 < minPixels) result += 'The amount of pixels must not be lower than ' + minPixels + ' pixels.'
                else if (0 < maxPixels) result += 'The amount of pixels must not be greater than ' + maxPixels + ' pixels.'
                if (0 < minRatio && 0 < maxRatio) {
                    if (minRatio == maxRatio) result += 'Image aspect ratio (width / height) must be exactly equal to ' + minRatio + '.'
                    else result += 'Image aspect ratio (width / height) must be between ' + minRatio + ' and ' + maxRatio + '.'
                }
                else if (0 < minRatio) result += 'Image aspect ratio (width / height) must not be lower than ' + minRatio + '.'
                else if (0 < maxRatio) result += 'Image aspect ratio (width / height) must not be greater than ' + maxRatio + '.'
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
    def dispatch constraints(ListField it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Hat eine Länge von ' + length + ' Zeichen.'
            result += commonStringConstraints
            if (0 < min && 0 < max) {
                if (min == max) result += 'Erfordert genau ' + min + ' ' + (if (1 < min) 'Einträge' else 'Eintrag') + '.'
                else result += 'Erfordert zwischen ' + min + ' und ' + max + ' Einträge.'
            }
            else if (0 < min) result += 'Erfordert mindestens ' + min + ' ' + (if (1 < min) 'Einträge' else 'Eintrag') + '.'
            else if (0 < max) result += 'Erfordert höchstens ' + max + ' Einträge.'
        } else {
            result += 'Has a length of ' + length + ' chars.'
            result += commonStringConstraints
            if (0 < min && 0 < max) {
                if (min == max) result += 'Requires exactly ' + min + ' ' + (if (1 < min) 'entries' else 'entry') + '.'
                else result += 'Requires between ' + min + ' and ' + max + ' entries.'
            }
            else if (0 < min) result += 'Requires at least ' + min + ' ' + (if (1 < min) 'entries' else 'entry') + '.'
            else if (0 < max) result += 'Requires at most ' + max + ' entries.'
        }
        result
    }
    def dispatch constraints(ArrayField it) {
        val result = newArrayList
        if (language == 'de') {
            if (0 < min && 0 < max) {
                if (min == max) result += 'Erfordert genau ' + min + ' ' + (if (1 < min) 'Einträge' else 'Eintrag') + '.'
                else result += 'Erfordert zwischen ' + min + ' und ' + max + ' Einträge.'
            }
            else if (0 < min) result += 'Erfordert mindestens ' + min + ' ' + (if (1 < min) 'Einträge' else 'Eintrag') + '.'
            else if (0 < max) result += 'Erfordert höchstens ' + max + ' Einträge.'
        } else {
            if (0 < min && 0 < max) {
                if (min == max) result += 'Requires exactly ' + min + ' ' + (if (1 < min) 'entries' else 'entry') + '.'
                else result += 'Requires between ' + min + ' and ' + max + ' entries.'
            }
            else if (0 < min) result += 'Requires at least ' + min + ' ' + (if (1 < min) 'entries' else 'entry') + '.'
            else if (0 < max) result += 'Requires at most ' + max + ' entries.'
        }
        result
    }
    def dispatch constraints(DatetimeField it) {
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
    def dispatch constraints(OneToManyRelationship it) {
        val result = newArrayList
        if (language == 'de') {
            if (0 < minTarget || 0 < maxTarget) {
                if (0 < minTarget && 0 < maxTarget) {
                    if (minTarget === maxTarget) {
                        result += 'Es müssen genau ' + minTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                    } else {
                        result += 'Es können mindestens ' + minTarget + ' und höchstens ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                    }
                } else if (0 < minTarget) {
                    result += 'Es können mindestens ' + minTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (0 < maxTarget) {
                    result += 'Es können höchstens ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                }
            }
        } else {
            if (0 < minTarget || 0 < maxTarget) {
                if (0 < minTarget && 0 < maxTarget) {
                    if (minTarget === maxTarget) {
                        result += 'Exactly ' + minTarget + ' ' + targetAlias.formatForDisplay + ' must be assigned.'
                    } else {
                        result += 'At least ' + minTarget + ' and at most ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                    }
                } else if (0 < minTarget) {
                    result += 'At least ' + minTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                } else if (0 < maxTarget) {
                    result += 'At most ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                }
            }
        }
        result
    }
    def dispatch constraints(ManyToManyRelationship it) {
        val result = newArrayList
        if (language == 'de') {
            if (0 < minSource || 0 < maxSource) {
                if (0 < minSource && 0 < maxSource) {
                    if (minTarget === maxTarget) {
                        result += 'Es müssen genau ' + minSource + ' ' + sourceAlias.formatForDisplay + ' zugewiesen werden.'
                    } else {
                        result += 'Es können mindestens ' + minSource + ' und höchstens ' + maxSource + ' ' + sourceAlias.formatForDisplay + ' zugewiesen werden.'
                    }
                } else if (0 < minSource) {
                    result += 'Es können mindestens ' + minSource + ' ' + sourceAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (0 < maxSource) {
                    result += 'Es können höchstens ' + maxSource + ' ' + sourceAlias.formatForDisplay + ' zugewiesen werden.'
                }
            }
            if (0 < minTarget || 0 < maxTarget) {
                if (0 < minTarget && 0 < maxTarget) {
                    if (minTarget === maxTarget) {
                        result += 'Es müssen genau ' + minTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                    } else {
                        result += 'Es können mindestens ' + minTarget + ' und höchstens ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                    }
                } else if (0 < minTarget) {
                    result += 'Es können mindestens ' + minTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (0 < maxTarget) {
                    result += 'Es können höchstens ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                }
            }
        } else {
            if (0 < minSource || 0 < maxSource) {
                if (0 < minSource && 0 < maxSource) {
                    if (minTarget === maxTarget) {
                        result += 'Exactly ' + minSource + ' ' + sourceAlias.formatForDisplay + ' must be assigned.'
                    } else {
                        result += 'At least ' + minSource + ' and at most ' + maxSource + ' ' + sourceAlias.formatForDisplay + ' may be assigned.'
                    }
                } else if (0 < minSource) {
                    result += 'At least ' + minSource + ' ' + sourceAlias.formatForDisplay + ' may be assigned.'
                } else if (0 < maxSource) {
                    result += 'At most ' + maxSource + ' ' + sourceAlias.formatForDisplay + ' may be assigned.'
                }
            }
            if (0 < minTarget || 0 < maxTarget) {
                if (0 < minTarget && 0 < maxTarget) {
                    if (minTarget === maxTarget) {
                        result += 'Exactly ' + minTarget + ' ' + targetAlias.formatForDisplay + ' must be assigned.'
                    } else {
                        result += 'At least ' + minTarget + ' and at most ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                    }
                } else if (0 < minTarget) {
                    result += 'At least ' + minTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                } else if (0 < maxTarget) {
                    result += 'At most ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                }
            }
        }
        result
    }
}
