package org.zikula.modulestudio.generator.cartridges.symfony.models.business

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.Relationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import java.util.ArrayList

class ValidationHelpProvider {

    def dispatch ArrayList<String> helpMessages(Field it) {
        newArrayList
    }

    def dispatch helpMessages(NumberField it) {
        val messages = newArrayList

        if (0 < minValue && 0 < maxValue) {
            if (minValue == maxValue) {
                messages += '''«''»'Note: this value must exactly be %value%.'«''»'''
            } else {
                messages += '''«''»'Note: this value must be between %minValue% and %maxValue%.'«''»'''
            }
        } else if (0 < minValue) {
            messages += '''«''»'Note: this value must not be lower than %minValue%.'«''»'''
        } else if (0 < maxValue) {
            messages += '''«''»'Note: this value must not be greater than %maxValue%.'«''»'''
        }

        messages
    }

    def dispatch helpMessages(StringField it) {
        val messages = newArrayList
        val isSelector = #[StringRole.COLOUR, StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)

        if (!isSelector) {
            if (0 < minLength) {
                messages += '''«''»'Note: this value must have a minimum length of %minLength% characters.'«''»'''
            }
        }
        if (role == StringRole.BIC) {
            messages += '''«''»'Note: this value must be a valid BIC (Business Identifier Code).'«''»'''
        } else if (role == StringRole.CREDIT_CARD) {
            messages += '''«''»'Note: this value must be a valid credit card number.'«''»'''
        } else if (role == StringRole.IBAN) {
            messages += '''«''»'Note: this value must be a valid IBAN (International Bank Account Number).'«''»'''
        } else if (role == StringRole.ISIN) {
            messages += '''«''»'Note: this value must be a valid ISIN (international securities identification number).'«''»'''
        //} else if (role == StringRole.PHONE_NUMBER) {
        //    messages += '''«''»'Note: this value must be a valid telephone number.'«''»'''
        } else if (role == StringRole.ULID) {
            messages += '''«''»'Note: this value must be a valid ULID (Universally Unique Lexicographically Sortable Identifier).'«''»'''
        } else if (role == StringRole.UUID) {
            messages += '''«''»'Note: this value must be a valid UUID (Universally Unique Identifier).'«''»'''
        }

        messages
    }

    def dispatch ArrayList<String> helpMessageParameters(Field it) {
        newArrayList
    }

    def dispatch helpMessageParameters(NumberField it) {
        val parameters = newArrayList

        if (0 < minValue && 0 < maxValue) {
            if (minValue == maxValue) {
                parameters += '''«''»'%value%' => «minValue»'''
            } else {
                parameters += '''«''»'%minValue%' => «minValue»'''
                parameters += '''«''»'%maxValue%' => «maxValue»'''
            }
        } else if (0 < minValue) {
            parameters += '''«''»'%minValue%' => «minValue»'''
        } else if (0 < maxValue) {
            parameters += '''«''»'%maxValue%' => «maxValue»'''
        }

        parameters
    }

    def dispatch helpMessageParameters(StringField it) {
        val parameters = newArrayList
        val isSelector = #[StringRole.COLOUR, StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)

        if (!isSelector) {
            if (0 < minLength) {
                parameters += '''«''»'%minLength%' => «minLength»'''
            }
        }

        parameters
    }

    def dispatch helpMessages(TextField it) {
        val messages = newArrayList

        messages += '''«''»'Note: this value must not exceed %length% characters.'«''»'''
        if (0 < minLength) {
            messages += '''«''»'Note: this value must have a minimum length of %minLength% characters.'«''»'''
        }

        messages
    }

    def dispatch helpMessages(ListField it) {
        val messages = newArrayList

        if (0 < minLength) {
            messages += '''«''»'Note: this value must have a minimum length of %minLength% characters.'«''»'''
        }

        if (!multiple) {
            return messages
        }
        if (0 < min && 0 < max) {
            if (min == max) {
                messages += '''«''»'Note: you must select exactly %amount% choices.'«''»'''
            } else {
                messages += '''«''»'Note: you must select between %min% and %max% choices.'«''»'''
            }
        } else if (0 < min) {
            messages += '''«''»'Note: you must select at least %min% choices.'«''»'''
        } else if (0 < max) {
            messages += '''«''»'Note: you must not select more than %max% choices.'«''»'''
        }

        messages
    }

    def dispatch helpMessages(UploadField it) {
        val messages = newArrayList

        if (!(allowSquare && allowLandscape && allowPortrait)) {
            if (allowSquare && !allowLandscape && !allowPortrait) {
                messages += '''«''»'Note: only square dimension (no portrait or landscape) is allowed.'«''»'''
            } else if (!allowSquare && allowLandscape && !allowPortrait) {
                messages += '''«''»'Note: only landscape dimension (no square or portrait) is allowed.'«''»'''
            } else if (!allowSquare && !allowLandscape && allowPortrait) {
                messages += '''«''»'Note: only portrait dimension (no square or landscape) is allowed.'«''»'''
            } else if (allowSquare && allowLandscape && !allowPortrait) {
                messages += '''«''»'Note: only square or landscape dimension (no portrait) is allowed.'«''»'''
            } else if (allowSquare && !allowLandscape && allowPortrait) {
                messages += '''«''»'Note: only square or portrait dimension (no landscape) is allowed.'«''»'''
            } else if (!allowSquare && allowLandscape && allowPortrait) {
                messages += '''«''»'Note: only landscape or portrait dimension (no square) is allowed.'«''»'''
            }
        }

        messages
    }

    def dispatch helpMessages(ArrayField it) {
        val messages = newArrayList

        if (0 < min && 0 < max) {
            if (min == max) {
                messages += '''«''»'Note: you must specify exactly %amount% values.'«''»'''
            } else {
                messages += '''«''»'Note: you must specify between %min% and %max% values.'«''»'''
            }
        } else if (0 < min) {
            messages += '''«''»'Note: you must specify at least %min% values.'«''»'''
        } else if (0 < max) {
            messages += '''«''»'Note: you must not specify more than %max% values.'«''»'''
        }

        messages
    }

    def dispatch helpMessageParameters(TextField it) {
        val parameters = newArrayList

        parameters += '''«''»'%length%' => «length»'''
        if (0 < minLength) {
            parameters += '''«''»'%minLength%' => «minLength»'''
        }

        parameters
    }

    def dispatch helpMessageParameters(ListField it) {
        val parameters = newArrayList

        if (0 < minLength) {
            parameters += '''«''»'%minLength%' => «minLength»'''
        }

        if (!multiple) {
            return parameters
        }
        if (0 < min && 0 < max) {
            if (min == max) {
                parameters += '''«''»'%amount%' => «min»'''
            } else {
                parameters += '''«''»'%min%' => «min»'''
                parameters += '''«''»'%max%' => «max»'''
            }
        } else if (0 < min) {
            parameters += '''«''»'%min%' => «min»'''
        } else if (0 < max) {
            parameters += '''«''»'%max%' => «max»'''
        }

        parameters
    }

    def dispatch helpMessageParameters(ArrayField it) {
        val parameters = newArrayList

        if (0 < min && 0 < max) {
            if (min == max) {
                parameters += '''«''»'%amount%' => «min»'''
            } else {
                parameters += '''«''»'%min%' => «min»'''
                parameters += '''«''»'%max%' => «max»'''
            }
        } else if (0 < min) {
            parameters += '''«''»'%min%' => «min»'''
        } else if (0 < max) {
            parameters += '''«''»'%max%' => «max»'''
        }

        parameters
    }

    def dispatch helpMessages(DatetimeField it) {
        val messages = newArrayList

        if (past) {
            messages += '''«''»'Note: this value must be in the past.'«''»'''
        } else if (future) {
            messages += '''«''»'Note: this value must be in the future.'«''»'''
        }

        messages
    }

    def dispatch ArrayList<String> relationHelpMessages(Relationship it, Boolean outgoing) {
        newArrayList
    }
    def dispatch relationHelpMessages(OneToManyRelationship it, Boolean outgoing) {
        val messages = newArrayList

        if (!outgoing) {
            return messages
        }

        if (0 < minTarget && 0 < maxTarget) {
            if (minTarget == maxTarget) {
                messages += '''«''»'Note: you must select exactly %amount% choices.'«''»'''
            } else {
                messages += '''«''»'Note: you must select between %min% and %max% choices.'«''»'''
            }
        } else if (0 < minTarget) {
            messages += '''«''»'Note: you must select at least %min% choices.'«''»'''
        } else if (0 < maxTarget) {
            messages += '''«''»'Note: you must not select more than %max% choices.'«''»'''
        }

        messages
    }
    def dispatch relationHelpMessages(ManyToManyRelationship it, Boolean outgoing) {
        val messages = newArrayList

        if (!outgoing) {
            if (0 < minSource && 0 < maxSource) {
                if (minSource == maxSource) {
                    messages += '''«''»'Note: you must select exactly %amount% choices.'«''»'''
                } else {
                    messages += '''«''»'Note: you must select between %min% and %max% choices.'«''»'''
                }
            } else if (0 < minSource) {
                messages += '''«''»'Note: you must select at least %min% choices.'«''»'''
            } else if (0 < maxSource) {
                messages += '''«''»'Note: you must not select more than %max% choices.'«''»'''
            }
        } else {
            if (0 < minTarget && 0 < maxTarget) {
                if (minTarget == maxTarget) {
                    messages += '''«''»'Note: you must select exactly %amount% choices.'«''»'''
                } else {
                    messages += '''«''»'Note: you must select between %min% and %max% choices.'«''»'''
                }
            } else if (0 < minTarget) {
                messages += '''«''»'Note: you must select at least %min% choices.'«''»'''
            } else if (0 < maxTarget) {
                messages += '''«''»'Note: you must not select more than %max% choices.'«''»'''
            }
        }

        messages
    }
    def dispatch ArrayList<String> relationHelpMessageParameters(Relationship it, Boolean outgoing) {
        newArrayList
    }
    def dispatch relationHelpMessageParameters(OneToManyRelationship it, Boolean outgoing) {
        val parameters = newArrayList

        if (!outgoing) {
            return parameters
        }

        if (0 < minTarget && 0 < maxTarget) {
            if (minTarget == maxTarget) {
                parameters += '''«''»'%amount%' => «minTarget»'''
            } else {
                parameters += '''«''»'%min%' => «minTarget»'''
                parameters += '''«''»'%max%' => «maxTarget»'''
            }
        } else if (0 < minTarget) {
            parameters += '''«''»'%min%' => «minTarget»'''
        } else if (0 < maxTarget) {
            parameters += '''«''»'%max%' => «maxTarget»'''
        }

        parameters
    }
    def dispatch relationHelpMessageParameters(ManyToManyRelationship it, Boolean outgoing) {
        val parameters = newArrayList

        if (!outgoing) {
            if (0 < minSource && 0 < maxSource) {
                if (minSource == maxSource) {
                    parameters += '''«''»'%amount%' => «minSource»'''
                } else {
                    parameters += '''«''»'%min%' => «minSource»'''
                    parameters += '''«''»'%max%' => «maxSource»'''
                }
            } else if (0 < minSource) {
                parameters += '''«''»'%min%' => «minSource»'''
            } else if (0 < maxSource) {
                parameters += '''«''»'%max%' => «maxSource»'''
            }
        } else {
            if (0 < minTarget && 0 < maxTarget) {
                if (minTarget == maxTarget) {
                    parameters += '''«''»'%amount%' => «minTarget»'''
                } else {
                    parameters += '''«''»'%min%' => «minTarget»'''
                    parameters += '''«''»'%max%' => «maxTarget»'''
                }
            } else if (0 < minTarget) {
                parameters += '''«''»'%min%' => «minTarget»'''
            } else if (0 < maxTarget) {
                parameters += '''«''»'%max%' => «maxTarget»'''
            }
        }

        parameters
    }
}
