package org.zikula.modulestudio.generator.cartridges.symfony.controller.config

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DateTimeRole
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.NumberRole
import de.guite.modulestudio.metamodel.RelationAutoCompletionUsage
import de.guite.modulestudio.metamodel.RelationEditMode
import de.guite.modulestudio.metamodel.Relationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TextRole
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UploadNamingScheme
import de.guite.modulestudio.metamodel.UserField
import java.util.ArrayList
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerMethodInterface
import org.zikula.modulestudio.generator.cartridges.symfony.models.business.ValidationHelpProvider
import org.zikula.modulestudio.generator.cartridges.symfony.view.formcomponents.ValidationCssHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigureFields implements ControllerMethodInterface {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    ValidationHelpProvider validationHelpProvider = new ValidationHelpProvider
    Iterable<Relationship> incomingRelations
    Iterable<Relationship> outgoingRelations

    override void init(Entity it) {
        incomingRelations = getCommonRelations(true)
        outgoingRelations = getCommonRelations(false)
    }

    override imports(Entity it) {
        val formFields = getAllEntityFields
        val imports = newArrayList
        imports.add('function Symfony\\Component\\Translation\\t')
        val nsEabField = 'EasyCorp\\Bundle\\EasyAdminBundle\\Field\\'
        for (field : formFields) {
            imports.add(nsEabField + field.fieldType + 'Field')
        }
        /* TODO do we want to use this instead of Sluggable? can only have one reference field...
        if (hasSluggableFields) {
            imports.add(nsEabField + 'SlugField')
        }*/

        val nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'
        if (!formFields.filter(NumberField).filter[NumberRole.RANGE == role].empty) {
            imports.add(nsSymfonyFormType + 'RangeType')
        }
        if (geographical) {
            imports.add(application.appNamespace + '\\Form\\Type\\Field\\GeoType')
        }
        if (!formFields.filter(StringField).filter[role == StringRole.DATE_INTERVAL].empty) {
            imports.add(nsSymfonyFormType + 'DateIntervalType')
        }
        if (!formFields.filter(StringField).filter[role == StringRole.PASSWORD].empty) {
            imports.add(nsSymfonyFormType + 'PasswordType')
        }
        if (!formFields.filter(StringField).filter[role == StringRole.WEEK].empty) {
            imports.add(nsSymfonyFormType + 'WeekType')
        }
        if (!formFields.filter(StringField).filter[role == StringRole.ICON].empty) {
            imports.add('Zikula\\FormExtensionBundle\\Form\\Type\\IconType')
        }
        if (!getUploadFieldsEntity.filter[f|!f.isOnlyImageField].empty) {
            imports.add(application.appNamespace + '\\Form\\Type\\Field\\UploadType')
        }

        // TODO refactor following imports
        val importsUNUSED = newArrayList
        importsUNUSED.add('Symfony\\Component\\Form\\AbstractType')
        importsUNUSED.add(nsSymfonyFormType + 'ResetType')
        importsUNUSED.add(nsSymfonyFormType + 'SubmitType')
        if (hasLocaleFieldsEntity || hasTranslatableFields) {
            importsUNUSED.add('Zikula\\CoreBundle\\Api\\ApiInterface\\LocaleApiInterface')
        }
        if (!formFields.filter[!mandatory && !nullable].empty) {
            importsUNUSED.add('Zikula\\FormExtensionBundle\\Form\\DataTransformer\\NullToEmptyTransformer')
        }
        importsUNUSED.add(application.appNamespace + '\\Entity\\Factory\\EntityFactory')
        if (hasTranslatableFields) {
            importsUNUSED.add(application.appNamespace + '\\Form\\Type\\Field\\TranslationType')
        }
        if (hasUploadFieldsEntity) {
            importsUNUSED.add('Symfony\\Component\\HttpFoundation\\File\\File')
        }

        if (!incomingRelations.empty || !outgoingRelations.empty) {
            imports.add('Doctrine\\ORM\\EntityRepository')
            for (relation : incomingRelations) {
                imports.add(nsEabField + relation.relationFieldType(false) + 'Field')
            }
            for (relation : outgoingRelations) {
                imports.add(nsEabField + relation.relationFieldType(true) + 'Field')
            }
        }

        imports
    }

    override generateMethod(Entity it) '''
        public function configureFields(string $pageName): iterable
        {
            «methodBody»
        }
    '''

    def private methodBody(Entity it) '''
        «FOR field : getAllEntityFields»
            «IF field instanceof UploadField»
                $basePath = $this->uploadHelper->getFileBaseFolder('«name.formatForCode»', '«field.name.formatForCode»');
            «ELSEIF field instanceof ListField»
                «fetchListEntries(field)»

            «ENDIF»
            «field.definition»;
        «ENDFOR»
        «FOR relation : incomingRelations»
            «val autoComplete = relation.useAutoCompletion != RelationAutoCompletionUsage.NONE && relation.useAutoCompletion != RelationAutoCompletionUsage.ONLY_TARGET_SIDE»
            «relation.relationDefinition(false, autoComplete)»;
        «ENDFOR»
        «FOR relation : outgoingRelations»
            «val autoComplete = relation.useAutoCompletion != RelationAutoCompletionUsage.NONE && relation.useAutoCompletion != RelationAutoCompletionUsage.ONLY_SOURCE_SIDE»
            «relation.relationDefinition(true, autoComplete)»;
        «ENDFOR»
        «/* TODO do we want to use this instead of Sluggable? can only have one reference field...
        «IF hasSluggableFields»
            yield 'slug' => «slugFieldDefinition»
        «ENDIF*/»
    '''

    // TODO remove this (same in ConfigureFilters)
    def private fetchListEntries(ListField it) '''
        $listEntries = $this->listEntriesHelper->getEntries('«entity.name.formatForCode»', '«name.formatForCode»');
        $choices = [];
        $choiceAttributes = [];
        foreach ($listEntries as $entry) {
            $choices[$entry['text']] = $entry['value'];
            $choiceAttributes[$entry['text']] = ['title' => $entry['title']];
        }
    '''

    def private definition(Field it) '''
        yield '«name.formatForCode»' => «fieldType»Field::new('«name.formatForCode»', t('«name.formatForDisplayCapital»'))
            «IF !visibility(entity).empty»
                «visibility(entity)»
            «ENDIF»
            «IF !options.empty»
                «options»
            «ENDIF»
            «IF !customFormType.toString.empty»
                ->setFormType(«customFormType»Type::class)
            «ENDIF»
            «IF !formOptions.toString.empty»
                ->setFormTypeOptions([
                    «formOptions»
                ])
            «ENDIF»
    '''

    /*def private slugFieldDefinition(Entity it) '''SlugField::new('slug', t('Slug'))«IF hasIndexAction»->hideOnIndex()«ENDIF»«IF '' !== slugOptions»
    «''»    «slugOptions»«ENDIF»'''*/

    def private visibility(Field it, Entity entity) {
        var calls = ''
        if (entity.hasIndexAction && !visibleOnIndex) {
            calls += '->hideOnIndex()'
        }
        if (entity.hasDetailAction && !visibleOnDetail) {
            calls += '->hideOnDetail()'
        }
        if (entity.hasEditAction) {
            if (!visibleOnNew && !visibleOnEdit) {
                calls += '->hideOnForm()'
            } else if (!visibleOnNew) {
                calls += '->hideWhenCreating()'
            } else if (!visibleOnEdit) {
                calls += '->hideWhenUpdating()'
            }
        }
        if (entity.hasIndexAction && !visibleOnSort) {
            calls += '->setSortable(false)'
        }
        calls
    }

    def private dispatch fieldType(Field it) { 'Text' }
    def private dispatch options(Field it) {
        commonOptions
    }
    def private commonOptions(Field it) {
        var calls = ''
        if (null !== documentation && !documentation.replaceAll('\\s+', '').empty) {
            calls += '''->setHelp(t('«documentation.replaceAll('\'', '"')»'))'''
        }
        if ('left' !== alignment) {
            calls += '''->setTextAlign('«alignment»')'''
        }
        if ('' !== requiredOption) {
            calls += '''->setRequired(«requiredOption»)'''
        }
        calls
    }

    def private alignment(Object it) {
        switch it {
            BooleanField: 'center'
            NumberField: 'right'
            StringField: if (#[StringRole.MAIL, StringRole.URL].contains(role)) 'center' else 'left'
            default: 'left'
        }
    }

    def private dispatch requiredOption(Field it) '''«mandatory.displayBool»'''
    def private dispatch requiredOption(UploadField it) {
        if (mandatory) '''Crud::PAGE_NEW === $pageName'''
        else 'false'
    }

    def private dispatch fieldType(BooleanField it) { 'Boolean' }
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/BooleanField.html
    def private dispatch options(BooleanField it) {
        var calls = commonOptions
        if (!renderAsSwitch) {
            calls += '->renderAsSwitch(false)'
        }
        calls
    }

    def private dispatch fieldType(NumberField it) {
        if (primaryKey) 'Id'
        else if (NumberRole.MONEY == role) 'Money'
        else if (NumberRole.PERCENTAGE == role) 'Percent'
        else if (NumberFieldType.DECIMAL == numberType) 'Integer'
        else 'Number'
    }
    def private dispatch options(NumberField it) {
        var calls = commonOptions
        if (primaryKey) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/IdField.html
            calls += '''->setMaxLength(«length»)'''
        } else if (NumberRole.MONEY == role) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/MoneyField.html
            if (entity.hasCurrencyFieldsEntity) {
                calls += '''->setCurrencyPropertyPath('«entity.getCurrencyFieldsEntity.head.name.formatForCode»')'''
            } else {
                calls += '''->setCurrency('EUR')'''
            }
            calls += '''->setNumDecimals(«scale»)'''
            // setStoredAsCents()
        } else if (NumberRole.PERCENTAGE == role) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/PercentField.html
            calls += '''->setNumDecimals(«scale»)'''
            // setRoundingMode(...)
            if (NumberFieldType.INTEGER == fieldType) {
                calls += '''->setStoredAsFractional(false)'''
            }
            if (null !== unit && !unit.empty) {
                calls += '''->setSymbol('«unit»')'''
            }
        } else if (NumberFieldType.INTEGER == fieldType) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/IntegerField.html
            // setNumberFormat(...)
        } else {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/NumberField.html
            // setNumberFormat(...)
            calls += '''->setNumDecimals(«scale»)'''
            // setRoundingMode(...)
        }
        calls
    }

    // see https://symfony.com/bundles/EasyAdminBundle/current/fields.html#field-types
    def private dispatch fieldType(StringField it) {
        if (role === StringRole.COLOUR) 'Color' else
        if (role === StringRole.COUNTRY) 'Country' else
        if (role === StringRole.CURRENCY) 'Currency' else
        if (role === StringRole.LANGUAGE) 'Language' else
        if (role === StringRole.LOCALE) 'Locale' else
        if (role === StringRole.MAIL) 'Email' else
        if (role === StringRole.PHONE_NUMBER) 'Telephone' else
        if (role === StringRole.TIME_ZONE) 'Timezone' else
        if (role === StringRole.URL) 'Url' else
        'Text'
    }
    def private dispatch options(StringField it) {
        var calls = commonOptions
        if (role === StringRole.COLOUR) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/ColorField.html
            // showSample(false)
            // showValue()
        } else if (role === StringRole.COUNTRY) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/CountryField.html
            // includeOnly([...])
            // remove([...])
            // showFlag(false)
            // showName(false)
            // useAlpha3Codes()
        } else if (role === StringRole.CURRENCY) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/CurrencyField.html
            // showCode()
            // showName(false)
            // showSymbol(false)
        } else if (role === StringRole.LANGUAGE) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/LanguageField.html
            // includeOnly([...])
            // remove([...])
            // showCode()
            // showName(false)
            // useAlpha3Codes()
        } else if (role === StringRole.LOCALE) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/LocaleField.html
            calls += '''->includeOnly($this->localeApi->getSupportedLocales())'''
            // remove([...])
            // showCode()
            // showName(false)
        } else if (role === StringRole.PHONE_NUMBER) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/TelephoneField.html
        } else if (role === StringRole.TIME_ZONE) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/TimezoneField.html
        } else {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/TextField.html
            // renderAsHtml()
            calls += '''->setMaxLength(«length»)'''
            // setMaxLength($pageName === Crud::PAGE_DETAIL ? 1024 : 32)
            calls += '''->stripTags()'''
        }
        calls
    }

    def private dispatch fieldType(TextField it) {
        if (role === TextRole.WYSIWYG) 'TextEditor' else
        if (!#[TextRole.PLAIN, TextRole.HTML].contains(role)) 'CodeEditor' else
        'Textarea' 
    }
    def private dispatch options(TextField it) {
        var calls = commonOptions
        if (role === TextRole.WYSIWYG) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/TextEditorField.html
            // setNumOfRows(30)
            // setTrixEditorConfig([...])
        } else if (!#[TextRole.PLAIN, TextRole.HTML].contains(role)) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/CodeEditorField.html
            // hideLineNumbers()
            // setIndentWithTabs()
            calls += '''->setLanguage('«role.textRoleAsCodeLanguage»')'''
            // setNumOfRows(30)
            // setTabSize(8)
        } else {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/TextareaField.html
            if (role === TextRole.HTML) {
                calls += '''->renderAsHtml()'''
            }
            calls += '''->setMaxLength(«length»)'''
            // setMaxLength($pageName === Crud::PAGE_DETAIL ? 1024 : 32)
            // setNumOfRows(30)
            if (role === TextRole.PLAIN) {
                calls += '''->stripTags()'''
            }
        }
        calls
    }

    def private dispatch fieldType(UserField it) { 'Association' }
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/AssociationField.html
    def private dispatch options(UserField it) {
        var calls = commonOptions
        calls += '''->autocomplete()'''
        // TODO association options
        calls
    }

    def private dispatch fieldType(UploadField it) {
        if (isOnlyImageField) 'Image'
        else 'Text' // TODO
    }
    // TODO UploadField
    def private dispatch options(UploadField it) {
        var calls = commonOptions
        if (isOnlyImageField) {
            calls += '''->setBasePath(str_replace('public/', '', $basePath))->setUploadDir($basePath)'''
        }
        calls
    }

    def private dispatch fieldType(ListField it) { 'Choice' }
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/ChoiceField.html
    def private dispatch options(ListField it) {
        var calls = commonOptions
        if (multiple) {
            calls += '''->allowMultipleChoices()'''
        }
        if (useAutoCompletion) {
            calls += '''->autocomplete()'''
        }
        // escapeHtml(false)
        // renderAsBadges([...]) // TODO migrate image of list item?
            // 'success', 'warning', 'danger', 'info', 'primary', 'secondary', 'light', 'dark'
        if (expanded) {
            calls += '''->renderExpanded()'''
        }
        calls += '''->setChoices($choices)'''
        // setTranslatableChoices([...]) // TODO choices
        calls
    }

    def private dispatch fieldType(ArrayField it) { 'Array' }
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/ArrayField.html

    def private dispatch fieldType(DatetimeField it) {
        if (role == DateTimeRole.DATE) 'Date' else
        if (role == DateTimeRole.TIME) '' else
        'DateTime'
    }
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/DateTimeField.html
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/DateField.html
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/TimeField.html
    def private dispatch options(DatetimeField it) {
        var calls = commonOptions
        // renderAsChoice() === form type: widget = choice and html5 = true
        // renderAsNativeWidget(false)
        // renderAsText()
        // setFormat(...)
        // setTimezone(...)
        calls
    }

    // https://symfony.com/bundles/EasyAdminBundle/current/fields/SlugField.html
    /*def private slugOptions(Entity it) {
        var calls = '' // no commonOptions needed here
        // setTargetFieldName(...)
        // setUnlockConfirmationMessage(...)
        calls
    }*/


    ValidationCssHelper validationCssHelper = new ValidationCssHelper

    def private formOptions(Field it) '''«/* No input fields for foreign keys, relations are processed further down */»
        «IF entity.incoming.filter[r|r.getSourceFields.head == name.formatForDB].empty»
            «IF null !== documentation && !documentation.empty»
                'label_attr' => [
                    'title' => '«documentation.replace("'", '"')»',
                ],
            «ENDIF»
            «helpAttribute»
            'attr' => [
                'class' => '«validationCssHelper.fieldValidationCssClass(it)»',
                «IF readonly»
                    'readonly' => 'readonly',
                «ENDIF»
                «IF it instanceof NumberField»
                    «IF NumberRole.RANGE == role»
                        'min' => «minValue»,
                        'max' => «maxValue»,
                    «ELSE»
                        «IF minValue > 0»
                            'min' => «minValue»,
                        «ENDIF»
                        «IF maxValue > 0»
                            'max' => «maxValue»,
                        «ENDIF»
                    «ENDIF»
                «ENDIF»
                'title' => '«titleAttribute»',
                «additionalAttributes»
            ],
            «additionalOptions»«/* TODO IF !mandatory && !nullable»->addModelTransformer(new NullToEmptyTransformer()))«ENDIF*/»
        «ENDIF»
    '''

    def private helpAttribute(Field it) {
        displayHelpMessages(application, helpMessages, validationHelpProvider.helpMessageParameters(it))
        /* TODO eliminate redundant ways for 'help' attribute
            ->setHelp(
                Crud::PAGE_EDIT === $pageName ? 'abc' : 'def'
            )
         */
    }

    def private helpMessages(Field it) {
        val messages = newArrayList
        if (null !== documentation && !documentation.empty) {
            messages += '\'' + documentation.replace("'", '"') + '\''
        }
        messages.addAll(validationHelpProvider.helpMessages(it))
        messages
    }

    def private dispatch customFormType(Field it) ''''''
    def private dispatch titleAttribute(Field it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay».'''
    def private dispatch additionalAttributes(Field it) ''''''
    def private dispatch additionalOptions(Field it) ''''''

    def private dispatch titleAttribute(BooleanField it) '''«name.formatForDisplay» ?'''
    def private dispatch additionalAttributes(BooleanField it) ''''''

    def private dispatch customFormType(NumberField it) '''«IF NumberRole.RANGE == role»Range«ELSEIF #['latitude', 'longitude'].contains(name)»Geo«ENDIF»'''

    def private dispatch additionalAttributes(NumberField it) '''
        «IF NumberFieldType.INTEGER == numberType»
            'maxlength' => «length»,
        «ELSE»
            'maxlength' => «(length+3+scale)»,
        «ENDIF»
    '''
    def private dispatch additionalOptions(NumberField it) '''
        «IF NumberRole.PERCENTAGE == role»
            'type' => 'integer',
        «ENDIF»
        «IF NumberFieldType.INTEGER != numberType»
            'scale' => «scale»,
        «ENDIF»
        «IF unit != ''»
            'input_group' => ['right' => t('«unit»')],
        «ENDIF»
    '''

    def private dispatch customFormType(StringField it) '''«IF role == StringRole.DATE_INTERVAL»DateInterval«ELSEIF role == StringRole.PASSWORD»Password«ELSEIF role == StringRole.WEEK»Week«ELSEIF role == StringRole.ICON»Icon«ENDIF»'''
    def private dispatch titleAttribute(StringField it) '''«IF #[StringRole.COLOUR, StringRole.COUNTRY, StringRole.CURRENCY, StringRole.DATE_INTERVAL, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)»Choose the «name.formatForDisplay»«ELSE»Enter the «name.formatForDisplay»«ENDIF» of the «entity.name.formatForDisplay».'''
    def private dispatch additionalAttributes(StringField it) '''
        'maxlength' => «length»,
    '''
    def private dispatch additionalOptions(StringField it) '''
        «IF !mandatory && #[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)»
            'placeholder' => t('All'),
        «ENDIF»
        «IF unit != ''»
            'input_group' => ['right' => t('«unit»')],
        «ENDIF»
        «IF role == StringRole.DATE_INTERVAL»
            'labels' => [
                'years' => t('Years'),
                'months' => t('Months'),
                'days' => t('Days'),
                'hours' => t('Hours'),
                'minutes' => t('Minutes'),
                'seconds' => t('Seconds'),
            ],
            «IF !mandatory»
                'placeholder' => [
                    'years' => t('Years'),
                    'months' => t('Months'),
                    'days' => t('Days'),
                    'hours' => t('Hours'),
                    'minutes' => t('Minutes'),
                    'seconds' => t('Seconds'),
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
            'with_seconds' => true,
        «ENDIF»
        «IF role == StringRole.COLOUR»
            'html5' => true,«/* Country EAB field uses Symfony ChoiceType instead of CountryType
        ELSEIF role == StringRole.COUNTRY»
            'choice_translation_locale' => $this->requestStack->getCurrentRequest()->getLocale(),*/»
        «ELSEIF role == StringRole.CURRENCY»
            'choice_translation_locale' => $this->requestStack->getCurrentRequest()->getLocale(),
        «ELSEIF role == StringRole.LANGUAGE»
            'choice_self_translation' => true,«/* not both allowed
            'choice_translation_locale' => $this->requestStack->getCurrentRequest()->getLocale(),*/»
        «/*ELSEIF role == StringRole.LOCALE»
            'choice_translation_locale' => $this->requestStack->getCurrentRequest()->getLocale(),
        */»«ELSEIF role == StringRole.TIME_ZONE»
            'choice_translation_locale' => $this->requestStack->getCurrentRequest()->getLocale(),
            'intl' => true,
        «ELSEIF role == StringRole.URL»«/*'default_protocol' => 'http'*/»
        «ELSEIF role == StringRole.WEEK»
            'input' => 'string',
        «ENDIF»
    '''

    def private dispatch additionalAttributes(TextField it) '''
        'maxlength' => «length»,
    '''

    // TODO UploadField
    def private dispatch customFormType(UploadField it) '''«IF !isOnlyImageField»Upload«ENDIF»'''
    def private dispatch additionalAttributes(UploadField it) '''
        «IF !isOnlyImageField»
            'accept' => '.' . implode(',.', $this->uploadHelper->getAllowedFileExtensions('«entity.name.formatForCode»', '«name.formatForCode»')),
        «ENDIF»
    '''
    def private dispatch additionalOptions(UploadField it) '''
        «IF !isOnlyImageField»
            'entity' => $this->getContext()->getEntity()->getInstance(),
            'allow_deletion' => «(!mandatory).displayBool»,
            'allowed_extensions' => implode(', ', $this->uploadHelper->getAllowedFileExtensions('«entity.name.formatForCode»', '«name.formatForCode»')),
            'allowed_size' => '«maxSize»',
            «IF namingScheme == UploadNamingScheme.USERDEFINEDWITHCOUNTER»
                'custom_filename' => true,
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch titleAttribute(ListField it) '''Choose the «name.formatForDisplay».'''
    def private dispatch additionalOptions(ListField it) '''
        «IF !expanded && !mandatory»
            'placeholder' => 'Choose an option',
        «ENDIF»
        'choice_attr' => $choiceAttributes,
    '''

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
        «ELSEIF isDateField»
            'empty_data' => «IF null !== defaultValue && !defaultValue.empty && defaultValue != 'now'»'«defaultValue»'«ELSEIF nullable»''«ELSE»«defaultValueForNow»«ENDIF»,
        «ELSEIF isTimeField»
            'empty_data' => '«defaultValue»',
            'with_seconds' => false,
        «ENDIF»
        «IF immutable»
            'input' => 'datetime_immutable',
        «ENDIF»
    '''

    def private relationDefinition(Relationship it, Boolean outgoing, Boolean autoComplete) '''
        «val aliasName = getRelationAliasName(outgoing)»
        «val editMode = if (outgoing) getSourceEditMode else getTargetEditMode»
        yield '«aliasName.formatForCode»' => «relationFieldType(outgoing)»Field::new('«aliasName.formatForCode»', t('«aliasName.formatForDisplayCapital»'))«IF RelationEditMode.NONE === editMode»->hideOnForm()«ENDIF»«/*
            «IF !visibility(entity as Entity).empty»
                «visibility(entity as Entity)»
            «ENDIF»
            «IF !options.empty»
                «options»
            «ENDIF»
            «IF !customFormType.toString.empty»
                ->setFormType(«customFormType»Type::class)
            «ENDIF*/»
            «IF !relationFormOptions(outgoing).toString.empty»
                ->setFormTypeOptions([
                    «relationFormOptions(outgoing)»
                ])
            «ENDIF»
    '''

    def private relationFieldType(Relationship it, Boolean outgoing) {
        val editMode = if (outgoing) getSourceEditMode else getTargetEditMode
        if (editMode == RelationEditMode.EMBEDDED) 'Collection' // TODO maybe only for multi-valued sides...
        else 'Association'
    }

/*
    def private formType(Relationship it, Boolean autoComplete) {
        if (autoComplete) '''«application.appNamespace»\Form\Type\Field\AutoCompletionRelation'''
        else '''Symfony\Bridge\Doctrine\Form\Type\Entity'''
    }
*/

    def private relationFormOptions(Relationship it, Boolean outgoing) '''
        «relationHelp(outgoing)»
    '''

/*
    def private relationDefinition(Relationship it, Boolean outgoing, Boolean autoComplete) '''
        «val relatedEntity = if (outgoing) target else source»
        «val editMode = if (outgoing) getSourceEditMode else getTargetEditMode»
        «IF editMode == RelationEditMode.EMBEDDED»«/* TODO entity option is missing if related entity contains an upload field * /»
            $builder->add('«aliasName.formatForCode»', '«app.appNamespace»\Form\Type\«relatedEntity.name.formatForCodeCapital»Type', [
                «IF isManySide(outgoing)»
                    'by_reference' => false,
                «ENDIF»
                «IF /*outgoing && * /nullable»
                    'required' => false,
                «ENDIF»
                'inline_usage' => true,
                'label' => '«aliasName.formatForDisplayCapital»',
                «relationHelp(outgoing)»
                'attr' => [
                    'title' => 'Choose the «aliasName.formatForDisplay».',
                ],
            ]);
        «ELSE»
            $queryBuilder = function (EntityRepository $er) {«/* get repo from entity factory to ensure CollectionFilterHelper is set return $er->getListQueryBuilder('', '', false);* /»
                return $this->entityFactory->getRepository('«relatedEntity.name.formatForCode»')->getListQueryBuilder('', '', false);
            };
            «IF (relatedEntity as Entity).ownerPermission»
                if (true === $options['filter_by_ownership']) {
                    $collectionFilterHelper = $this->collectionFilterHelper;
                    $queryBuilder = function (EntityRepository $er) use ($collectionFilterHelper) {
                        $qb = $this->entityFactory->getRepository('«relatedEntity.name.formatForCode»')->getListQueryBuilder('', '', false);
                        $collectionFilterHelper->addCreatorFilter($qb);

                        return $qb;
                    };
                }
            «ENDIF»
            «IF !autoComplete»
                $entityDisplayHelper = $this->entityDisplayHelper;
                $choiceLabelClosure = function ($entity) use ($entityDisplayHelper) {
                    return $entityDisplayHelper->getFormattedTitle($entity);
                };
            «ENDIF»
            «val isExpanded = if (outgoing) expandedTarget else expandedSource»
            $builder->add('«aliasName.formatForCode»', '«formType(autoComplete)»Type', [
                «IF autoComplete»
                    «val uniqueNameForJs = getUniqueRelationNameForJs((if (outgoing) source else target), aliasName.formatForCodeCapital)»
                    'object_type' => '«relatedEntity.name.formatForCode»',
                    «IF isManySide(outgoing)»
                        'by_reference' => false,
                    «ENDIF»
                    'multiple' => «isManySide(outgoing).displayBool»,
                    'unique_name_for_js' => '«uniqueNameForJs»',
                    'allow_editing' => «(getEditStageCode(!outgoing) > 1).displayBool»,
                    «IF outgoing && nullable»
                        'required' => false,
                    «ENDIF»
                «ELSE»
                    'class' => '«app.appName»:«relatedEntity.name.formatForCodeCapital»Entity',
                    'choice_label' => $choiceLabelClosure,
                    «IF isManySide(outgoing)»
                        'by_reference' => false,
                    «ENDIF»
                    'multiple' => «isManySide(outgoing).displayBool»,
                    'expanded' => «isExpanded.displayBool»,
                    'query_builder' => $queryBuilder,
                    «IF /*outgoing && * /nullable»
                        «IF !isManySide(outgoing) && !isExpanded/* expanded uses default: "None" * /»
                            'placeholder' => 'Please choose an option.',
                        «ENDIF»
                        'required' => false,
                    «ENDIF»
                «ENDIF»
                'label' => '«aliasName.formatForDisplayCapital»',
                «IF !autoComplete && isExpanded»
                    'label_attr' => [
                        'class' => '«IF isManySide(outgoing)»checkbox«ELSE»radio«ENDIF»-inline'
                    ],
                «ENDIF»
                «relationHelp(outgoing)»
                'attr' => [
                    'title' => 'Choose the «aliasName.formatForDisplay».',
                ],
            ]);
        «ENDIF»
    '''
*/

    def private relationHelp(Relationship it, Boolean outgoing) {
        displayHelpMessages(application, validationHelpProvider.relationHelpMessages(it, outgoing), validationHelpProvider.relationHelpMessageParameters(it, outgoing))
    }

    def private displayHelpMessages(Application it, ArrayList<String> messages, ArrayList<String> parameters) {
        if (!messages.empty) '''
            «IF messages.length > 1»
                'help' => [
                    «FOR message : messages»
                        t(«message»)«IF message != messages.tail»,«ENDIF»
                    «ENDFOR»
                ],
            «ELSE»
                'help' => «messages.head»,
            «ENDIF»
            «IF !parameters.empty»
                'help_translation_parameters' => [«parameters.join(', ')»],
            «ENDIF»
        '''
    }
}
