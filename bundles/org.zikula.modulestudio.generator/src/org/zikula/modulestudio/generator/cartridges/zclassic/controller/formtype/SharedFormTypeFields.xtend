package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.IpAddressScope
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringIsbnStyle
import de.guite.modulestudio.metamodel.StringIssnStyle
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UploadNamingScheme
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import java.math.BigInteger
import java.util.List
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Validation
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SharedFormTypeFields {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    Validation validationHelper = new Validation
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    def formTypeImports(List<Field> fields, Application app, DataObject dataObject) '''
        «IF null === dataObject && app.hasUserGroupSelectors»
            use Symfony\Bridge\Doctrine\Form\Type\EntityType;
        «ENDIF»
        use Symfony\Component\Form\AbstractType;
        «IF !fields.filter(BooleanField).empty»
            use «nsSymfonyFormType»CheckboxType;
        «ENDIF»
        «IF !fields.filter(ListField).filter[!multiple].empty»
            use «nsSymfonyFormType»ChoiceType;
        «ENDIF»
        «IF !fields.filter(StringField).filter[role == StringRole.COLOUR].empty && app.targets('2.0')»
            use «nsSymfonyFormType»ColorType;
        «ENDIF»
        «IF !fields.filter(StringField).filter[role == StringRole.COUNTRY].empty»
            use «nsSymfonyFormType»CountryType;
        «ENDIF»
        «IF !fields.filter(StringField).filter[role == StringRole.CURRENCY].empty»
            use «nsSymfonyFormType»CurrencyType;
        «ENDIF»
        «IF app.targets('2.0') && !fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty»
            use «nsSymfonyFormType»DateIntervalType;
        «ENDIF»
        «IF null !== dataObject && dataObject.hasDirectDateTimeFields || !fields.filter(DatetimeField).filter[isDateTimeField].empty»
            use «nsSymfonyFormType»DateTimeType;
        «ENDIF»
        «IF null !== dataObject && dataObject.hasDirectDateFields || !fields.filter(DatetimeField).filter[isDateField].empty»
            use «nsSymfonyFormType»DateType;
        «ENDIF»
        «IF !fields.filter(EmailField).empty»
            use «nsSymfonyFormType»EmailType;
        «ENDIF»
        «IF !fields.filter(IntegerField).filter[!primaryKey && !percentage && !range && !isUserGroupSelector].empty»
            use «nsSymfonyFormType»IntegerType;
        «ENDIF»
        «IF !fields.filter(StringField).filter[role == StringRole.LANGUAGE].empty»
            use «nsSymfonyFormType»LanguageType;
        «ENDIF»
        «IF !fields.filter(NumberField).filter[currency].empty»
            use «nsSymfonyFormType»MoneyType;
        «ENDIF»
        «IF !fields.filter(NumberField).filter[!percentage && !currency].empty»
            use «nsSymfonyFormType»NumberType;
        «ENDIF»
        «IF !fields.filter(StringField).filter[role == StringRole.PASSWORD].empty»
            use «nsSymfonyFormType»PasswordType;
        «ENDIF»
        «IF !fields.filter(IntegerField).filter[percentage].empty || !fields.filter(NumberField).filter[percentage].empty»
            use «nsSymfonyFormType»PercentType;
        «ENDIF»
        «IF !fields.filter(IntegerField).filter[range].empty»
            use «nsSymfonyFormType»RangeType;
        «ENDIF»
        use «nsSymfonyFormType»ResetType;
        use «nsSymfonyFormType»SubmitType;
        «IF !fields.filter(StringField).filter[role == StringRole.PHONE_NUMBER].empty && app.targets('2.0')»
            use «nsSymfonyFormType»TelType;
        «ENDIF»
        «IF !fields.filter(TextField).empty || (null !== dataObject && dataObject instanceof Entity && (dataObject as Entity).workflow != EntityWorkflowType.NONE)»
            use «nsSymfonyFormType»TextareaType;
        «ENDIF»
        «IF (null !== dataObject && dataObject instanceof Entity &&
        	    (
        	        (dataObject as Entity).attributable
        	        ||
        	        ((dataObject as Entity).hasSluggableFields && (dataObject as Entity).slugUpdatable)
                )
            )
            || !fields.filter(StringField).filter[!#[StringRole.COLOUR, StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.PASSWORD, StringRole.PHONE_NUMBER, StringRole.TIME_ZONE].contains(role)].empty
        »
            use «nsSymfonyFormType»TextType;
        «ENDIF»
        «IF null !== dataObject && dataObject.hasDirectTimeFields || !fields.filter(DatetimeField).filter[isTimeField].empty»
            use «nsSymfonyFormType»TimeType;
        «ENDIF»
        «IF !fields.filter(StringField).filter[role == StringRole.TIME_ZONE].empty»
            use «nsSymfonyFormType»TimezoneType;
        «ENDIF»
        «IF !fields.filter(UrlField).empty»
            use «nsSymfonyFormType»UrlType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        «IF null !== dataObject»
            use Symfony\Component\Form\FormInterface;
        «ENDIF»
        «IF (null !== dataObject && dataObject.hasUploadFieldsEntity) || (null === dataObject && !fields.filter(UploadField).empty)»
            use Symfony\Component\HttpFoundation\File\File;
        «ENDIF»
        use Symfony\Component\OptionsResolver\OptionsResolver;
        «IF !fields.filter(StringField).filter[role == StringRole.LOCALE].empty»
            use Zikula\Bundle\FormExtensionBundle\Form\Type\LocaleType;
        «ENDIF»
        «IF null !== dataObject && dataObject instanceof Entity && (dataObject as Entity).categorisable»
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF null !== dataObject && dataObject instanceof Entity && (dataObject as Entity).hasTranslatableFields»
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        «IF (null !== dataObject && dataObject.hasLocaleFieldsEntity) || (null === dataObject && !fields.filter(StringField).filter[role == StringRole.LOCALE].empty)»
            use Zikula\SettingsModule\Api\ApiInterface\LocaleApiInterface;
        «ENDIF»
        «IF null !== dataObject»
            use «app.appNamespace»\Entity\Factory\EntityFactory;
        «ENDIF»
        «IF !fields.filter(ArrayField).empty»
            use «app.appNamespace»\Form\Type\Field\ArrayType;
        «ENDIF»
        «IF !fields.filter(StringField).filter[role == StringRole.COLOUR].empty && !app.targets('2.0')»
            use «app.appNamespace»\Form\Type\Field\ColourType;
        «ENDIF»
        «IF null !== dataObject && dataObject instanceof Entity && (dataObject as Entity).geographical»
            use «app.appNamespace»\Form\Type\Field\GeoType;
        «ENDIF»
        «IF !fields.filter(ListField).filter[multiple].empty»
            use «app.appNamespace»\Form\Type\Field\MultiListType;
        «ENDIF»
        «IF !fields.filter(StringField).filter[role == StringRole.PHONE_NUMBER].empty && !app.targets('2.0')»
            use «app.appNamespace»\Form\Type\Field\TelType;
        «ENDIF»
        «IF null !== dataObject && dataObject instanceof Entity && (dataObject as Entity).hasTranslatableFields»
            use «app.appNamespace»\Form\Type\Field\TranslationType;
        «ENDIF»
        «IF !fields.filter(UploadField).empty»
            use «app.appNamespace»\Form\Type\Field\UploadType;
        «ENDIF»
        «IF !fields.filter(UserField).empty»
            use Zikula\UsersModule\Form\Type\UserLiveSearchType;
        «ENDIF»
    '''

    def definition(DerivedField it) '''
        «/* No input fields for foreign keys, relations are processed further down */»
        «IF null === entity || entity.getIncomingJoinRelations.filter[r|r.getSourceFields.head == name.formatForDB].empty»
            «IF it instanceof ListField»
                «fetchListEntries»
            «ENDIF»
            «val isExpandedListField = it instanceof ListField && (it as ListField).expanded»
            $builder->add('«name.formatForCode»', «formType»Type::class, [
                'label' => $this->__('«name.formatForDisplayCapital»') . ':',
                «IF null !== documentation && !documentation.empty»
                    'label_attr' => [
                        'class' => 'tooltips«IF isExpandedListField» «IF (it as ListField).multiple»checkbox«ELSE»radio«ENDIF»-inline«ENDIF»',
                        'title' => $this->__('«documentation.replace("'", '"')»')
                    ],
                «ELSEIF isExpandedListField»
                    'label_attr' => [
                        'class' => '«IF (it as ListField).multiple»checkbox«ELSE»radio«ENDIF»-inline'
                    ],
                «ENDIF»
                «helpAttribute»
                «IF !(it instanceof BooleanField || it instanceof UploadField || it instanceof DatetimeField)»
                    'empty_data' => «Property.defaultFieldData(it)»,
                «ENDIF»
                'attr' => [
                    «additionalAttributes»
                    'class' => '«validationHelper.fieldValidationCssClass(it)»',
                    «IF readonly»
                        'readonly' => 'readonly',
                    «ENDIF»
                    «IF it instanceof IntegerField»
                        «IF range»
                            'min' => «minValue»,
                            'max' => «maxValue»,
                        «ELSE»
                            «IF minValue.compareTo(BigInteger.valueOf(0)) > 0»
                                'min' => «minValue»,
                            «ENDIF»
                            «IF maxValue.compareTo(BigInteger.valueOf(0)) > 0»
                                'max' => «maxValue»,
                            «ENDIF»
                        «ENDIF»
                    «ELSEIF it instanceof NumberField»
                        «IF minValue > 0»
                            'min' => «minValue»,
                        «ENDIF»
                        «IF maxValue > 0»
                            'max' => «maxValue»,
                        «ENDIF»
                    «ENDIF»
                    'title' => $this->__('«titleAttribute»')
                ],
                «requiredOption»
                «additionalOptions»
            ]);
        «ENDIF»
    '''

    def private helpAttribute(DerivedField it) '''«IF !helpMessages.empty»'help' => «IF helpMessages.length > 1»[«ENDIF»«helpMessages.join(', ')»«IF helpMessages.length > 1»]«ENDIF»,«ENDIF»'''

    def private helpDocumentation(DerivedField it) {
        val messages = newArrayList
        if (null !== documentation && !documentation.empty) {
            messages += '$this->__(\'' + documentation.replace("'", '"') + '\')'
        }
        messages
    }

    def private dispatch helpMessages(DerivedField it) {
        val messages = helpDocumentation
        messages
    }

    def private dispatch helpMessages(IntegerField it) {
        val messages = helpDocumentation

        val hasMin = minValue.compareTo(BigInteger.valueOf(0)) > 0
        val hasMax = maxValue.compareTo(BigInteger.valueOf(0)) > 0
        if (!range && (hasMin || hasMax)) {
            if (hasMin && hasMax) {
                if (minValue == maxValue) {
                    messages += '''$this->__f('Note: this value must exactly be %value%.', ['%value%' => «minValue»])'''
                } else {
                    messages += '''$this->__f('Note: this value must be between %minValue% and %maxValue%.', ['%minValue%' => «minValue», '%maxValue%' => «maxValue»])'''
                }
            } else if (hasMin) {
                messages += '''$this->__f('Note: this value must not be lower than %minValue%.', ['%minValue%' => «minValue»])'''
            } else if (hasMax) {
                messages += '''$this->__f('Note: this value must not be greater than %maxValue%.', ['%maxValue%' => «maxValue»])'''
            }
        }

        messages
    }

    def private dispatch helpMessages(NumberField it) {
        val messages = helpDocumentation

        if (minValue > 0 && maxValue > 0) {
            if (minValue == maxValue) {
                messages += '''$this->__f('Note: this value must exactly be %value%.', ['%value%' => «minValue»])'''
            } else {
                messages += '''$this->__f('Note: this value must be between %minValue% and %maxValue%.', ['%minValue%' => «minValue», '%maxValue%' => «maxValue»])'''
            }
        } else if (minValue > 0) {
            messages += '''$this->__f('Note: this value must not be lower than %minValue%.', ['%minValue%' => «minValue»])'''
        } else if (maxValue > 0) {
            messages += '''$this->__f('Note: this value must not be greater than %maxValue%.', ['%maxValue%' => «maxValue»])'''
        }

        messages
    }

    def private dispatch helpMessages(StringField it) {
        val messages = helpDocumentation
        val isSelector = #[StringRole.COLOUR, StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)

        if (!isSelector) {
            if (true === fixed) {
                messages += '''$this->__f('Note: this value must have a length of %amount% characters.', ['%amount%' => «length»])'''
            }
            if (minLength > 0) {
                messages += '''$this->__f('Note: this value must have a minimum length of %amount% characters.', ['%amount%' => «minLength»])'''
            }
        }
        if (null !== regexp && !regexp.empty) {
            messages += '''$this->__f('Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%pattern%".', ['%pattern%' => '«regexp.replace('\'', '')»'])'''
        }
        if (role == StringRole.BIC) {
            messages += '''$this->__('Note: this value must be a valid BIC (Business Identifier Code).')'''
        } else if (role == StringRole.CREDIT_CARD) {
            messages += '''$this->__('Note: this value must be a valid credit card number.')'''
        } else if (role == StringRole.IBAN) {
            messages += '''$this->__('Note: this value must be a valid IBAN (International Bank Account Number).')'''
        } else if (isbn != StringIsbnStyle.NONE) {
            messages += '''$this->__('Note: this value must be a valid ISBN (International Standard Book Number).«isbn.isbnMessage»')'''
        } else if (issn != StringIssnStyle.NONE) {
            messages += '''$this->__('Note: this value must be a valid ISSN (International Standard Serial Number.«issn.issnMessage»')'''
        } else if (ipAddress != IpAddressScope.NONE) {
            messages += '''$this->__('Note: this value must be a valid IP address.«ipAddress.scopeMessage»')'''
        //} else if (role == StringRole.PHONE_NUMBER) {
        //    messages += '''$this->__('Note: this value must be a valid telephone number.')'''
        } else if (role == StringRole.UUID) {
            messages += '''$this->__('Note: this value must be a valid UUID (Universally Unique Identifier).')'''
        }

        messages
    }

    def private isbnMessage(StringIsbnStyle it) {
        switch (it) {
            case NONE:
                ''
            case ISBN10:
                ' It needs to be an ISBN-10 code.'
            case ISBN13:
                ' It needs to be an ISBN-13 code.'
            case ALL:
                ' It needs to be either an ISBN-10 or an ISBN-13 code.'
        }
    }

    def private issnMessage(StringIssnStyle it) {
        switch (it) {
            case NONE:
                ''
            case NORMAL:
                ''
            case CASE_SENSITIVE:
                ' The X at the end needs to be upper case.'
            case REQUIRE_HYPHEN:
                ' The value needs to be hyphenated.'
            case STRICT:
                ' The value needs to be hyphenated and the X at the end needs to be upper case.'
        }
    }

    def private scopeMessage(IpAddressScope it) {
        switch (it) {
            case NONE:
                ''
            case IP4:
                ' Allowed are IPv4 addresses in all ranges.'
            case IP6:
                ' Allowed are IPv6 addresses in all ranges.'
            case ALL:
                ' Allowed IPv4 and IPv6 addresses in all ranges.'
            case IP4_NO_PRIV:
                ' Allowed are IPv4 addresses without private ranges.'
            case IP6_NO_PRIV:
                ' Allowed are IPv6 addresses without private ranges.'
            case ALL_NO_PRIV:
                ' Allowed IPv4 and IPv6 addresses without private ranges.'
            case IP4_NO_RES:
                ' Allowed are IPv4 addresses without reserved ranges.'
            case IP6_NO_RES:
                ' Allowed are IPv6 addresses without reserved ranges.'
            case ALL_NO_RES:
                ' Allowed IPv4 and IPv6 addresses without reserved ranges.'
            case IP4_PUBLIC:
                ' Allowed are IPv4 addresses using only public ranges (without private and reserved ranges).'
            case IP6_PUBLIC:
                ' Allowed are IPv6 addresses using only public ranges (without private and reserved ranges).'
            case ALL_PUBLIC:
                ' Allowed IPv4 and IPv6 addresses using only public ranges (without private and reserved ranges).'
        }
    }

    def private dispatch helpMessages(TextField it) {
        val messages = helpDocumentation

        if (true === fixed) {
            messages += '''$this->__f('Note: this value must have a length of %amount% characters.', ['%amount%' => «length»])'''
        } else {
            messages += '''$this->__f('Note: this value must not exceed %amount% characters.', ['%amount%' => «length»])'''
        }
        if (minLength > 0) {
            messages += '''$this->__f('Note: this value must have a minimum length of %amount% characters.', ['%amount%' => «minLength»])'''
        }
        if (null !== regexp && !regexp.empty) {
            messages += '''$this->__f('Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%pattern%".', ['%pattern%' => '«regexp.replace('\'', '')»'])'''
        }

        messages
    }

    def private dispatch helpMessages(ListField it) {
        val messages = helpDocumentation

        if (true === fixed) {
            messages += '''$this->__f('Note: this value must have a length of %amount% characters.', ['%amount%' => «length»])'''
        }
        if (minLength > 0) {
            messages += '''$this->__f('Note: this value must have a minimum length of %amount% characters.', ['%amount%' => «minLength»])'''
        }

        if (!multiple) {
            return messages
        }
        if (min > 0 && max > 0) {
            if (min == max) {
                messages += '''$this->__f('Note: you must select exactly %amount% choices.', ['%amount%' => «min»])'''
            } else {
                messages += '''$this->__f('Note: you must select between %min% and %max% choices.', ['%min%' => «min», '%max%' => «max»])'''
            }
        } else if (min > 0) {
            messages += '''$this->__f('Note: you must select at least %min% choices.', ['%min%' => «min»])'''
        } else if (max > 0) {
            messages += '''$this->__f('Note: you must not select more than %max% choices.', ['%max%' => «max»])'''
        }

        messages
    }

    def private dispatch helpMessages(UploadField it) {
        val messages = helpDocumentation

        if (minWidth > 0 && maxWidth > 0) {
            if (minWidth == maxWidth) {
                messages += '''$this->__f('Note: the image must have a width of %amount% pixels.', ['%amount%' => «minWidth»])'''
            } else {
                messages += '''$this->__f('Note: the image must have a width between %min% and %max% pixels.', ['%min%' => «minWidth», '%max%' => «maxWidth»])'''
            }
        } else if (minWidth > 0) {
            messages += '''$this->__f('Note: the image must have a width of at least %min% pixels.', ['%min%' => «minWidth»])'''
        } else if (maxWidth > 0) {
            messages += '''$this->__f('Note: the image must have a width of at most %max% pixels.', ['%max%' => «maxWidth»])'''
        }

        if (minHeight > 0 && maxHeight > 0) {
            if (minHeight == maxHeight) {
                messages += '''$this->__f('Note: the image must have a height of %amount% pixels.', ['%amount%' => «minHeight»])'''
            } else {
                messages += '''$this->__f('Note: the image must have a height between %min% and %max% pixels.', ['%min%' => «minHeight», '%max%' => «maxHeight»])'''
            }
        } else if (minHeight > 0) {
            messages += '''$this->__f('Note: the image must have a height of at least %min% pixels.', ['%min%' => «minHeight»])'''
        } else if (maxHeight > 0) {
            messages += '''$this->__f('Note: the image must have a height of at most %max% pixels.', ['%max%' => «maxHeight»])'''
        }

        if (application.targets('2.0')) {
            if (minPixels > 0 && maxPixels > 0) {
                if (minPixels == maxPixels) {
                    messages += '''$this->__f('Note: the amount of pixels must be exactly equal to %amount% pixels.', ['%amount%' => «minPixels»])'''
                } else {
                    messages += '''$this->__f('Note: the amount of pixels must be between %min% and %max% pixels.', ['%min%' => «minPixels», '%max%' => «maxPixels»])'''
                }
            }
            else if (minPixels > 0) {
                messages += '''$this->__f('Note: the amount of pixels must be at least %min% pixels.', ['%min%' => «minPixels»])'''
            } else if (maxPixels > 0) {
                messages += '''$this->__f('Note: the amount of pixels must be at most %max% pixels.', ['%max%' => «maxPixels»])'''
            }
        }

        if (minRatio > 0 && maxRatio > 0) {
            if (minRatio == maxRatio) {
                messages += '''$this->__f('Note: the image aspect ratio (width / height) must be %amount%.', ['%amount%' => «minRatio»])'''
            } else {
                messages += '''$this->__f('Note: the image aspect ratio (width / height) must be between %min% and %max%.', ['%min%' => «minRatio», '%max%' => «maxRatio»])'''
            }
        } else if (minRatio > 0) {
            messages += '''$this->__f('Note: the image aspect ratio (width / height) must be at least %min%.', ['%min%' => «minRatio»])'''
        } else if (maxRatio > 0) {
            messages += '''$this->__f('Note: the image aspect ratio (width / height) must be at most %max%.', ['%max%' => «maxRatio»])'''
        }

        if (!(allowSquare && allowLandscape && allowPortrait)) {
            if (allowSquare && !allowLandscape && !allowPortrait) {
                messages += '''$this->__('Note: only square dimension (no portrait or landscape) is allowed.')'''
            } else if (!allowSquare && allowLandscape && !allowPortrait) {
                messages += '''$this->__('Note: only landscape dimension (no square or portrait) is allowed.')'''
            } else if (!allowSquare && !allowLandscape && allowPortrait) {
                messages += '''$this->__('Note: only portrait dimension (no square or landscape) is allowed.')'''
            } else if (allowSquare && allowLandscape && !allowPortrait) {
                messages += '''$this->__('Note: only square or landscape dimension (no portrait) is allowed.')'''
            } else if (allowSquare && !allowLandscape && allowPortrait) {
                messages += '''$this->__('Note: only square or portrait dimension (no landscape) is allowed.')'''
            } else if (!allowSquare && allowLandscape && allowPortrait) {
                messages += '''$this->__('Note: only landscape or portrait dimension (no square) is allowed.')'''
            }
        }

        messages
    }

    def private dispatch helpMessages(ArrayField it) {
        val messages = helpDocumentation

        messages += '''$this->__('Enter one entry per line.')'''

        if (min > 0 && max > 0) {
            if (min == max) {
                messages += '''$this->__f('Note: you must specify exactly %amount% values.', ['%amount%' => «min»])'''
            } else {
                messages += '''$this->__f('Note: you must specify between %min% and %max% values.', ['%min%' => «min», '%max%' => «max»])'''
            }
        } else if (min > 0) {
            messages += '''$this->__f('Note: you must specify at least %min% values.', ['%min%' => «min»])'''
        } else if (max > 0) {
            messages += '''$this->__f('Note: you must not specify more than %max% values.', ['%max%' => «max»])'''
        }

        messages
    }

    def private dispatch helpMessages(DatetimeField it) {
        val messages = helpDocumentation

        if (past) {
            messages += '''$this->__('Note: this value must be in the past.')'''
        } else if (future) {
            messages += '''$this->__('Note: this value must be in the future.')'''
        }

        messages
    }

    def private dispatch formType(Field it) '''Text'''
    def private dispatch titleAttribute(Field it) '''Enter the «name.formatForDisplay»«IF null !== entity» of the «entity.name.formatForDisplay»«ENDIF».'''

    def private dispatch additionalAttributes(Field it) '''
        'maxlength' => 255,
    '''
    def private dispatch requiredOption(Field it) '''
        'required' => «IF it instanceof DerivedField»«mandatory.displayBool»«ELSE»true«ENDIF»,
    '''
    def private dispatch additionalOptions(Field it) ''''''

    def private dispatch formType(BooleanField it) '''Checkbox'''
    def private dispatch titleAttribute(BooleanField it) '''«IF null !== entity»«name.formatForDisplay» ?«ELSE»The «IF isShrinkEnableField»enable shrinking«ELSE»«name.formatForDisplay»«ENDIF» option«ENDIF»'''
    def private dispatch additionalAttributes(BooleanField it) ''''''

    def private dispatch formType(IntegerField it) '''«IF isUserGroupSelector»Entity«ELSEIF percentage»Percent«ELSEIF range»Range«ELSE»Integer«ENDIF»'''
    def private dispatch titleAttribute(IntegerField it) '''«IF isUserGroupSelector»Choose the «name.formatForDisplay»«ELSE»«IF isShrinkDimensionField || isThumbDimensionField»Enter the «labelText.toLowerCase»«ELSE»Enter the «name.formatForDisplay»«IF null !== entity» of the «entity.name.formatForDisplay»«ENDIF».') . ' ' . $this->__('Only digits are allowed.«ENDIF»«ENDIF»'''
    def private dispatch additionalAttributes(IntegerField it) '''
        «IF isUserGroupSelector»
            'maxlength' => 255,
        «ELSE»
            'maxlength' => «IF isShrinkDimensionField || isThumbDimensionField»4«ELSE»«length»«ENDIF»,
        «ENDIF»
    '''
    def private dispatch additionalOptions(IntegerField it) '''
        «IF isUserGroupSelector»
            // Zikula core should provide a form type for this to hide entity details
            'class' => 'ZikulaGroupsModule:GroupEntity',
            'choice_label' => 'name',
            'choice_value' => 'gid'
        «ELSE»
            «IF percentage»
                'type' => 'integer',
            «ENDIF»
            «IF !range»
                'scale' => 0«IF isShrinkDimensionField || isThumbDimensionField»,
                'input_group' => ['right' => $this->__('pixels')]«ENDIF»
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch formType(NumberField it) '''«IF percentage»Percent«ELSEIF currency»Money«ELSE»Number«ENDIF»'''
    def private dispatch additionalAttributes(NumberField it) '''
        'maxlength' => «(length+3+scale)»,
    '''
    def private dispatch additionalOptions(NumberField it) '''
        «/* not required since these are the default values IF currency»
            'currency' => 'EUR',
            'divisor' => 1,
        «ENDIF*/»
        «/* not required since these are the default values IF percentage»
            'type' => 'fractional',
        «ENDIF*/»
        'scale' => «scale»
    '''

    def private dispatch formType(StringField it) '''«IF role == StringRole.COLOUR»«IF application.targets('2.0')»Color«ELSE»Colour«ENDIF»«ELSEIF role == StringRole.COUNTRY»Country«ELSEIF role == StringRole.CURRENCY»Currency«ELSEIF role == StringRole.LANGUAGE»Language«ELSEIF role == StringRole.LOCALE»Locale«ELSEIF role == StringRole.PASSWORD»Password«ELSEIF role == StringRole.DATE_INTERVAL && application.targets('2.0')»DateInterval«ELSEIF role == StringRole.PHONE_NUMBER»Tel«ELSEIF role == StringRole.TIME_ZONE»Timezone«ELSE»Text«ENDIF»'''
    def private dispatch titleAttribute(StringField it) '''«IF role == StringRole.COLOUR || role == StringRole.COUNTRY || role == StringRole.CURRENCY || (role == StringRole.DATE_INTERVAL && application.targets('2.0')) || role == StringRole.LANGUAGE || role == StringRole.LOCALE || role == StringRole.TIME_ZONE»Choose the «name.formatForDisplay»«ELSE»Enter the «name.formatForDisplay»«ENDIF»«IF null !== entity» of the «entity.name.formatForDisplay»«ENDIF».'''
    def private dispatch additionalAttributes(StringField it) '''
        'maxlength' => «length»,
        «IF null !== regexp && !regexp.empty»
            «IF !regexpOpposite»
                'pattern' => '«regexWithoutLeadingAndTrailingSlashes»',
            «ENDIF»
        «ENDIF»
    '''
    def private dispatch additionalOptions(StringField it) '''
        «IF !mandatory && #[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)»
            'placeholder' => $this->__('All')«IF role == StringRole.LOCALE»,«ENDIF»
        «ENDIF»
        «IF role == StringRole.LOCALE»
            'choices' => $this->localeApi->getSupportedLocaleNames(),
            «IF !application.targets('2.0')»
                'choices_as_values' => true
            «ENDIF»
        «ENDIF»
        «IF role == StringRole.DATE_INTERVAL && application.targets('2.0')»
            'labels' => [
                'years' => $this->__('Years'),
                'months' => $this->__('Months'),
                'days' => $this->__('Days'),
                'hours' => $this->__('Hours'),
                'minutes' => $this->__('Minutes'),
                'seconds' => $this->__('Seconds')
            ],
            «IF !mandatory»
                'placeholder' => [
                    'years' => $this->__('Years'),
                    'months' => $this->__('Months'),
                    'days' => $this->__('Days'),
                    'hours' => $this->__('Hours'),
                    'minutes' => $this->__('Minutes'),
                    'seconds' => $this->__('Seconds')
                ],
            «ENDIF»
            'input' => 'string',
            'widget' => 'choice',
            'with_years' => true,
            'with_months' => true,
            'with_weeks' => false,
            'with_days' => true,
            'with_hours' => true,
            'with_minutes' => true,
            'with_seconds' => true
        «ENDIF»
    '''

    def private dispatch formType(TextField it) '''Textarea'''
    def private dispatch additionalAttributes(TextField it) '''
        'maxlength' => «length»,
        «IF null !== regexp && !regexp.empty»
            «IF !regexpOpposite»
                'pattern' => '«regexWithoutLeadingAndTrailingSlashes»',
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch formType(EmailField it) '''Email'''
    def private dispatch additionalAttributes(EmailField it) '''
        'maxlength' => «length»,
        «IF null !== regexp && !regexp.empty»
            «IF !regexpOpposite»
                'pattern' => '«regexWithoutLeadingAndTrailingSlashes»',
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch formType(UrlField it) '''Url'''
    def private dispatch additionalAttributes(UrlField it) '''
        'maxlength' => «length»,
        «IF null !== regexp && !regexp.empty»
            «IF !regexpOpposite»
                'pattern' => '«regexWithoutLeadingAndTrailingSlashes»',
            «ENDIF»
        «ENDIF»
    '''
    def private dispatch additionalOptions(UrlField it) '''«/*'default_protocol' => 'http'*/»'''

    def private regexWithoutLeadingAndTrailingSlashes(AbstractStringField it) '''«regexp.replaceAll('\'', '').replaceAll('^/+', '').replaceAll('/+$', '')»'''

    def private dispatch formType(UploadField it) '''Upload'''
    def private dispatch additionalAttributes(UploadField it) ''''''
    def private dispatch requiredOption(UploadField it) '''
        'required' => «mandatory.displayBool» && $options['mode'] == 'create',
    '''
    def private dispatch additionalOptions(UploadField it) '''
        'entity' => $options['entity'],
        'allowed_extensions' => implode(', ', $this->uploadHelper->getAllowedFileExtensions('«IF null !== entity»«entity.name.formatForCode»«ELSE»«varContainer.name.formatForCode»«ENDIF»', '«name.formatForCode»')),
        'allowed_size' => '«maxSize»'«IF namingScheme == UploadNamingScheme.USERDEFINEDWITHCOUNTER»,
        'custom_filename' => true«ENDIF»
    '''

    def private fetchListEntries(ListField it) '''
        $listEntries = $this->listHelper->getEntries('«IF null !== entity»«entity.name.formatForCode»«ELSE»appSettings«ENDIF»', '«name.formatForCode»');
        $choices = [];
        $choiceAttributes = [];
        foreach ($listEntries as $entry) {
            $choices[$entry['text']] = $entry['value'];
            $choiceAttributes[$entry['text']] = ['title' => $entry['title']];
        }
    '''

    def private dispatch formType(ListField it) '''«IF multiple»MultiList«ELSE»Choice«ENDIF»'''
    def private dispatch titleAttribute(ListField it) '''Choose the «IF isThumbModeField»thumbnail mode«ELSE»«name.formatForDisplay»«ENDIF».'''
    def private dispatch additionalAttributes(ListField it) ''''''
    def private dispatch additionalOptions(ListField it) '''
        «IF !expanded && !mandatory»
            'placeholder' => $this->__('Choose an option'),
        «ENDIF»
        'choices' => $choices,
        «IF !application.targets('2.0')»
            'choices_as_values' => true,
        «ENDIF»
        'choice_attr' => $choiceAttributes,
        'multiple' => «multiple.displayBool»,
        'expanded' => «expanded.displayBool»
    '''

    def private dispatch formType(UserField it) '''UserLiveSearch'''
    def private dispatch additionalAttributes(UserField it) '''
        'maxlength' => «length»,
    '''
    def private dispatch additionalOptions(UserField it) '''
        «IF null !== entity && (!entity.incoming.empty || !entity.outgoing.empty)»
            'inline_usage' => $options['inline_usage']
        «ENDIF»
    '''

    def private dispatch formType(ArrayField it) '''Array'''
    def private dispatch additionalAttributes(ArrayField it) '''
    '''

    def private dispatch formType(DatetimeField it) '''«IF isDateTimeField»DateTime«ELSEIF isDateField»Date«ELSEIF isTimeField»Time«ENDIF»'''
    def private dispatch additionalAttributes(DatetimeField it) {
        if (isTimeField) '''
            'maxlength' => 8,
        '''
        else '''«''»'''
    }
    def private dispatch additionalOptions(DatetimeField it) '''
        «IF isDateTimeField»
            'empty_data' => «IF null !== defaultValue && !defaultValue.empty && defaultValue != 'now'»'«defaultValue»'«ELSEIF nullable»''«ELSE»«defaultValueForNow»«ENDIF»,
            'with_seconds' => true,
            'date_widget' => 'single_text',
            'time_widget' => 'single_text'
        «ELSEIF isDateField»
            'empty_data' => «IF null !== defaultValue && !defaultValue.empty && defaultValue != 'now'»'«defaultValue»'«ELSEIF nullable»''«ELSE»«defaultValueForNow»«ENDIF»,
            'widget' => 'single_text'
        «ELSEIF isTimeField»
            'empty_data' => '«defaultValue»',
            'widget' => 'single_text'
        «ENDIF»
    '''

    def private labelText(Field it) {
        if (isShrinkEnableField) {
            return 'Enable shrinking'
        }
        if (isShrinkDimensionField) {
            if (name.startsWith('shrinkWidth')) {
                return 'Shrink width'
            }
            if (name.startsWith('shrinkHeight')) {
                return 'Shrink height'
            }
        }
        if (isThumbModeField) {
            return 'Thumbnail mode'
        }
        if (isThumbDimensionField) {
            var suffix = ''
            if (name.endsWith('View')) {
                suffix = ' view'
            } else if (name.endsWith('Display')) {
                suffix = ' display'
            } else if (name.endsWith('Edit')) {
                suffix = ' edit'
            }
            if (name.startsWith('thumbnailWidth')) {
                return 'Thumbnail width' + suffix
            }
            if (name.startsWith('thumbnailHeight')) {
                return 'Thumbnail height' + suffix
            }
        }
        name.formatForDisplayCapital
    }

    def private isShrinkEnableField(Field it) {
        it instanceof BooleanField && name.startsWith('enableShrinkingFor')
    }

    def private isShrinkDimensionField(Field it) {
        it instanceof IntegerField && (name.startsWith('shrinkWidth') || name.startsWith('shrinkHeight'))
    }

    def private isThumbModeField(Field it) {
        it instanceof ListField && name.startsWith('thumbnailMode')
    }

    def private isThumbDimensionField(Field it) {
        it instanceof IntegerField && (name.startsWith('thumbnailWidth') || name.startsWith('thumbnailHeight'))
    }

    def addCommonSubmitButtons(Application it) '''
        $builder->add('reset', ResetType::class, [
            'label' => $this->__('Reset'),
            'icon' => 'fa-refresh',
            'attr' => [
                'class' => 'btn btn-default',
                'formnovalidate' => 'formnovalidate'
            ]
        ]);
        $builder->add('cancel', SubmitType::class, [
            'label' => $this->__('Cancel'),
            'icon' => 'fa-times',
            'attr' => [
                'class' => 'btn btn-default',
                'formnovalidate' => 'formnovalidate'
            ]
        ]);
    '''
}
