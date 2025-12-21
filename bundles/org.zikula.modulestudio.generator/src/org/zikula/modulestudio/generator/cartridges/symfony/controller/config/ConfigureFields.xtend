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
import de.guite.modulestudio.metamodel.RelationEditMode
import de.guite.modulestudio.metamodel.Relationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TextRole
import de.guite.modulestudio.metamodel.UploadField
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
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ConfigureFields implements ControllerMethodInterface {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

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
            if (!imports.contains(nsEabField + field.fieldType + 'Field')) {
                imports.add(nsEabField + field.fieldType + 'Field')
            }
        }
        if (hasSluggableFields) {
            imports.add(nsEabField + 'SlugField')
            imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Crud')
        }

        val nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'
        if (!formFields.filter(NumberField).filter[NumberRole.RANGE == role && hasMinValue && hasMaxValue].empty) {
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
            imports.add('Zikula\\ThemeBundle\\Form\\Type\\IconType')
        }
        if (hasUploadFieldsEntity) {
            imports.add(nsEabField + 'Field')
            imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Asset')
            if (!getUploadFieldsEntity.filter[f|!f.isOnlyImageField].empty) {
                imports.add('Vich\\UploaderBundle\\Form\\Type\\VichFileType')
                imports.add('Vich\\UploaderBundle\\Templating\\Helper\\UploaderHelper')
            }
            if (!getUploadFieldsEntity.filter[f|f.isOnlyImageField].empty) {
                imports.add('Vich\\UploaderBundle\\Form\\Type\\VichImageType')
            }
        }

        // related entities (TODO filter)
        for (entity : application.entities) {
            imports.add(application.appNamespace + '\\Entity\\' + entity.name.formatForCodeCapital)
        }

        // TODO refactor following imports
        val importsUNUSED = newArrayList
        if (!formFields.filter[!mandatory && !nullable].empty) {
            importsUNUSED.add('Zikula\\ThemeBundle\\Form\\DataTransformer\\NullToEmptyTransformer')
        }
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
        «IF hasUploadFieldsEntity»
            «IF !getUploadFieldsEntity.filter[f|f.isOnlyImageField].empty»
                $imaginePattern = match($pageName) {
                    Crud::PAGE_DETAIL => 'thumb_detail',
                    Crud::PAGE_EDIT => 'thumb_edit',
                    Crud::PAGE_INDEX => 'thumb_list',
                    Crud::PAGE_NEW => 'thumb_edit',
                    default => 'zkroot',
                };«/* TODO later: utilize thumb_related (for related items) */»
            «ENDIF»
            «IF !getUploadFieldsEntity.filter[f|!f.isOnlyImageField].empty»
                $uploaderHelper = $this->uploaderHelper;
            «ENDIF»
        «ENDIF»
        «FOR field : getAllEntityFields»
            «IF field instanceof UploadField»
                $basePath = str_replace('public/', '', $this->uploadHelper->getFileBaseFolder('«name.formatForCode»', '«field.name.formatForCode»'));
            «ELSEIF field instanceof ListField»
                «fetchListEntries(field)»

            «ENDIF»
            «IF field.name == 'slug'»
                «field.slugDefinition»
            «ELSE»
                «IF hasEditAction && field instanceof UploadField»
                    «(field as UploadField).uploadDefinition»
                «ENDIF»
                «field.definition»;
            «ENDIF»
        «ENDFOR»
        «FOR relation : incomingRelations»
            «val autoComplete = relation.usesAutoCompletion(false)»
            «relation.relationDefinition(false, autoComplete)»;
        «ENDFOR»
        «FOR relation : outgoingRelations»
            «val autoComplete = relation.usesAutoCompletion(true)»
            «relation.relationDefinition(true, autoComplete)»;
        «ENDFOR»
    '''

    def private fetchListEntries(ListField it) '''
        [$«name.formatForCode»Choices, $«name.formatForCode»ChoiceAttributes] = $this->listEntriesHelper->getFormChoices('«entity.name.formatForCode»', '«name.formatForCode»', true);
    '''

    def private definition(Field it) '''
        yield '«name.formatForCode»' => «fieldType»Field::new('«name.formatForCode»«IF it instanceof UploadField».name«ENDIF»', t('«name.formatForDisplayCapital»'))
            «IF !visibility(entity).empty»
                «visibility(entity)»
            «ENDIF»
            «IF !options.empty»
                «options»
            «ENDIF»
            «IF !formatValue.toString.empty»
                ->formatValue(«formatValue»)
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

    def private dispatch slugDefinition(Field it) '''
    '''

    // https://symfony.com/bundles/EasyAdminBundle/current/fields/SlugField.html
    def private dispatch slugDefinition(StringField it) '''
        if (Crud::PAGE_NEW === $pageName) {
            yield SlugField::new('«name.formatForCode»', t('«name.formatForDisplayCapital»'))
                ->setTargetFieldName(['«entity.getSluggableFields.map[name.formatForCode].join('\', \'')»'])
            «/* setUnlockConfirmationMessage(...) */»;
        } else {
            yield TextField::new('«name.formatForCode»', t('«name.formatForDisplayCapital»'))
                ->setRequired(false)
            ;
        }
    '''

    def private visibility(Field it, Entity entity) {
        var calls = ''
        if (entity.hasIndexAction && !visibleOnIndex) {
            calls += '->hideOnIndex()'
        }
        if (entity.hasDetailAction && !visibleOnDetail) {
            calls += '->hideOnDetail()'
        }
        if (entity.hasEditAction) {
            if (it instanceof UploadField) {
                calls += '->hideOnForm()'
            } else if (!visibleOnNew && !visibleOnEdit) {
                calls += '->hideOnForm()'
            } else if (!visibleOnNew) {
                calls += '->hideWhenCreating()'
            } else if (!visibleOnEdit) {
                calls += '->hideWhenUpdating()'
            }
        }
        if (entity.hasIndexAction && !(mightBeSortable && visibleOnSort)) {
            calls += '->setSortable(false)'
        }
        calls
    }

    def private mightBeSortable(Field it) {
        switch (it) {
            UploadField: false
            ArrayField: false
            default: true
        }
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
            if ('false' === requiredOption && nullable) {
                calls += '''->setEmptyData(«emptyData»)'''
            }
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

    def private emptyData(Object it) {
        switch it {
            BooleanField: 'false'
            NumberField: '\'0\'' // string because of https://github.com/EasyCorp/EasyAdminBundle/issues/5723
            UserField: '\'0\''
            ArrayField: '[]'
            default: '\'\''
        }
    }

    def private dispatch fieldType(BooleanField it) { 'Boolean' }
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/BooleanField.html
    def private dispatch options(BooleanField it) {
        var calls = commonOptions
        if (!renderAsSwitch || mandatory) {
            calls += '->renderAsSwitch(false)'
        }
        calls
    }

    def private dispatch fieldType(NumberField it) {
        if (primaryKey) 'Id'
        else if (NumberRole.MONEY == role) 'Money'
        else if (NumberRole.PERCENTAGE == role) 'Percent'
        else if (NumberFieldType.INTEGER == numberType) 'Integer'
        else 'Number'
    }
    def private dispatch options(NumberField it) {
        var calls = commonOptions
        if (NumberRole.MONEY == role) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/MoneyField.html
            if (entity.hasCurrencyFieldsEntity) {
                calls += '''->setCurrencyPropertyPath('«entity.getCurrencyFieldsEntity.head.name.formatForCode»')'''
            } else {
                calls += '''->setCurrency('EUR')'''
            }
            calls += '''->setNumDecimals(«scale»)'''
            // setStoredAsCents()
            // setDecimalSeparator()
        } else if (NumberRole.PERCENTAGE == role) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/PercentField.html
            calls += '''->setNumDecimals(«scale»)''' // https://github.com/EasyCorp/EasyAdminBundle/issues/6304
            // setRoundingMode()
            if (NumberFieldType.INTEGER == numberType) {
                calls += '''->setStoredAsFractional(false)'''
            }
            if (null !== unit && !unit.empty) {
                calls += '''->setSymbol('«unit»')'''
            }
        } else if (NumberFieldType.INTEGER == numberType) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/IntegerField.html
            // setNumberFormat()
            // setThousandsSeparator()
        } else {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/NumberField.html
            // setDecimalSeparator()
            // setNumberFormat()
            calls += '''->setNumDecimals(«scale»)'''
            // setRoundingMode()
            // setThousandsSeparator()
        }
        if (entity.geographical && #['latitude', 'longitude'].contains(name)) {
            calls += '''->setTemplatePath('@EasyAdmin/crud/field/geo.html.twig')'''
        }
        calls
    }

    // see https://symfony.com/bundles/EasyAdminBundle/current/fields.html#field-types
    def private dispatch fieldType(StringField it) {
        if (role === StringRole.COLOUR) 'Color' else
        if (role === StringRole.COUNTRY) 'Country' else
        if (role === StringRole.CURRENCY) 'Currency' else
        if (role === StringRole.DATE_INTERVAL) 'Integer' /* just to avoid TextConfigurator */ else
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
        if (primaryKey) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/IdField.html
            // calls += '''->setMaxLength(«length»)'''
        } else if (role === StringRole.COLOUR) {
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
        } else if (role === StringRole.DATE_INTERVAL) {
            // internally used with IntegerType; hence, no maxLength and stripTags
        } else if (role === StringRole.MAIL) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/EmailField.html
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
        } else if (role === StringRole.URL) {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/UrlField.html
        } else {
            // https://symfony.com/bundles/EasyAdminBundle/current/fields/TextField.html
            // renderAsHtml()
            // setMaxLength()
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
            calls += '''->setMaxLength(Crud::PAGE_DETAIL === $pageName ? «length» : 50)'''
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
        calls += '''->setTemplatePath('@EasyAdmin/crud/field/user.html.twig')'''
        // TODO association options
        calls
    }

    def private dispatch fieldType(UploadField it) {
        if (isOnlyImageField) 'Image'
        else 'Text'
    }

    // https://symfony.com/bundles/EasyAdminBundle/current/fields/ImageField.html
    def private dispatch options(UploadField it) {
        var calls = commonOptions
        if (isOnlyImageField) {
            calls += '''->setBasePath($basePath)->setTemplatePath('@EasyAdmin/crud/field/image_imagine.html.twig')->setCustomOption('imaginePattern', $imaginePattern)'''
        }
        calls
    }

    def private dispatch formatValue(UploadField it) '''
        «IF !isOnlyImageField»
            static fn (string $value, «entity.name.formatForCodeCapital» $entity)
                => '<a class="ea-vich-file-name" href="'
                 . $uploaderHelper->asset($entity, '«name.formatForCode»File')
                 . '" title="' . t('Download «name.formatForDisplay»') . '">'
                 . '<i class="fa fa-download"></i>&nbsp;' . t('Download') . '</a>'
        «ENDIF»
    '''

    def private uploadDefinition(UploadField it) '''
        yield '«name.formatForCode»File' => Field::new('«name.formatForCode»File', t('Upload «name.formatForDisplay»'))
            ->setRequired(«requiredOption»)
            ->setFormType(«uploadFieldType»Type::class)
            «IF visibleOnNew && visibleOnEdit»
                ->onlyOnForms()
            «ELSEIF !visibleOnNew && !visibleOnEdit»
                «IF null !== entity && entity.hasIndexAction»
                    ->hideOnIndex()
                «ENDIF»
                «IF null !== entity && entity.hasDetailAction»
                    ->hideOnDetail()
                «ENDIF»
                ->hideOnForms()
            «ELSE»
                «IF !visibleOnNew»
                    ->onlyWhenUpdating()
                «ELSEIF !visibleOnEdit»
                    ->onlyWhenCreating()
                «ENDIF»
            «ENDIF»
            ->setFormTypeOptions([
                «uploadOptions»
            ])
            ->addJsFiles(Asset::fromEasyAdminAssetPackage('field-image.js'))
        ;
    '''

    def private uploadFieldType(UploadField it) {
        if (isOnlyImageField) 'VichImage'
        else 'VichFile'
    }

    // https://github.com/dustin10/VichUploaderBundle/blob/master/docs/form/vich_file_type.md
    // https://github.com/dustin10/VichUploaderBundle/blob/master/docs/form/vich_image_type.md
    def private uploadOptions(UploadField it) '''
        'allow_delete' => «(!mandatory).displayBool»,
        'delete_label' => t('Delete «name.formatForDisplay»')->getMessage(),
        'download_label' => t('Download «name.formatForDisplay»')->getMessage(),
        «IF isOnlyImageField»
            'imagine_pattern' => $imaginePattern,
        «ELSE»
            'attr' => [
                'accept' => '.' . implode(',.', $this->uploadHelper->getAllowedFileExtensions('«entity.name.formatForCode»', '«name.formatForCode»')),
            ],
        «ENDIF»
    '''

    def private dispatch fieldType(ListField it) { 'Choice' }
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/ChoiceField.html
    def private dispatch options(ListField it) {
        var calls = commonOptions
        if (multiple) {
            calls += '''->allowMultipleChoices()'''
        }
        if (autocomplete) {
            calls += '''->autocomplete()'''
        } else if (!expanded) {
            calls += '''->renderAsNativeWidget()'''
        }
        // escapeHtml(false)
        if ('workflowState' === name && entity.hasVisibleWorkflow) {
            calls += '''->renderAsBadges($this->workflowHelper->getBadgeTypes())'''
        }
        if (expanded) {
            calls += '''->renderExpanded()'''
        }
        calls += '''->setTranslatableChoices($«name.formatForCode»Choices)'''
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
                    «IF NumberRole.RANGE == role && hasMinValue && hasMaxValue»
                        'min' => «formattedMinValue»,
                        'max' => «formattedMaxValue»,
                    «ELSE»
                        «IF hasMinValue»
                            'min' => «formattedMinValue»,
                        «ENDIF»
                        «IF hasMaxValue»
                            'max' => «formattedMaxValue»,
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

    def private dispatch titleAttribute(Field it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay».'''
    def private dispatch additionalAttributes(Field it) ''''''
    def private dispatch additionalOptions(Field it) ''''''
    def private dispatch customFormType(Field it) ''''''
    def private dispatch formatValue(Field it) ''''''

    def private dispatch titleAttribute(BooleanField it) '''«name.formatForDisplay» ?'''
    def private dispatch additionalAttributes(BooleanField it) ''''''

    def private dispatch customFormType(NumberField it) '''«IF NumberRole.RANGE == role && hasMinValue && hasMaxValue»Range«ELSEIF #['latitude', 'longitude'].contains(name)»Geo«ENDIF»'''

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
        «IF unit != '' && !#[NumberRole.MONEY, NumberRole.PERCENTAGE].contains(role)»
            'input_group' => ['right' => t('«unit»')],
        «ENDIF»
    '''

    def private dispatch customFormType(StringField it) '''«IF role == StringRole.DATE_INTERVAL»DateInterval«ELSEIF role == StringRole.PASSWORD»Password«ELSEIF role == StringRole.WEEK»Week«ELSEIF role == StringRole.ICON»Icon«ENDIF»'''
    def private dispatch titleAttribute(StringField it) '''«IF #[StringRole.COLOUR, StringRole.COUNTRY, StringRole.CURRENCY, StringRole.DATE_INTERVAL, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)»Choose the «name.formatForDisplay»«ELSE»Enter the «name.formatForDisplay»«ENDIF» of the «entity.name.formatForDisplay».'''
    def private dispatch additionalAttributes(StringField it) '''
        'maxlength' => «length»,
    '''
    def private dispatch additionalOptions(StringField it) '''
        «IF unit != ''»
            'input_group' => ['right' => t('«unit»')],
        «ENDIF»
        «IF role == StringRole.COLOUR»
            'html5' => true,
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
            'input' => 'dateinterval',
            'widget' => 'choice',
            'with_years' => false,
            'with_months' => false,
            'with_weeks' => false,
            'with_days' => false,
            'with_hours' => true,
            'with_minutes' => true,
            'with_seconds' => false,
        «ENDIF»
        «IF role == StringRole.WEEK»
            'input' => 'string',
        «ENDIF»
    '''


    def private dispatch formatValue(NumberField it) '''
        «IF null !== unit && !unit.empty»
            static fn (string $value) => $value ? $value . t('«unit»') : ''
        «ENDIF»
    '''

    def private dispatch formatValue(StringField it) '''
        «IF role == StringRole.DATE_INTERVAL»
            fn (\DateInterval $value) => $this->viewHelper->getFormattedDateInterval($value)
        «ELSEIF role == StringRole.ICON»
            static fn (string $value) => '<i class="' . $value . '"></i>'
        «ELSEIF role == StringRole.PASSWORD»
            static fn (string $value) => '*********'
        «ELSEIF null !== unit && !unit.empty»
            static fn (string $value) => $value ? $value . t('«unit»') : ''
        «ENDIF»
    '''

    def private dispatch additionalAttributes(TextField it) '''
        'maxlength' => «length»,
    '''

    def private dispatch titleAttribute(ListField it) '''Choose the «name.formatForDisplay».'''
    def private dispatch additionalOptions(ListField it) '''
        «IF !expanded && !mandatory»
            'placeholder' => 'Choose an option',
        «ENDIF»
        'choice_attr' => $«name.formatForCode»ChoiceAttributes,
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
            «TODO IF !visibility(entity as Entity).empty»
                «visibility(entity as Entity)»
            «ENDIF*/»
            «IF !options(outgoing, relationFieldType(outgoing), autoComplete).empty»
                «options(outgoing, relationFieldType(outgoing), autoComplete)»
            «ENDIF»«/*
            «IF !customFormType.toString.empty»
                ->setFormType(«customFormType»Type::class)
            «ENDIF*/»
            «IF !relationFormOptions(outgoing).toString.empty»
                ->setFormTypeOptions([
                    «relationFormOptions(outgoing)»
                ])
            «ENDIF»
    '''

    // https://symfony.com/bundles/EasyAdminBundle/current/fields/AssociationField.html
    // https://symfony.com/bundles/EasyAdminBundle/current/fields/CollectionField.html
    def private relationFieldType(Relationship it, Boolean outgoing) {
        val editMode = if (outgoing) getSourceEditMode else getTargetEditMode
        if (editMode == RelationEditMode.EMBEDDED) 'Collection' // TODO maybe only for multi-valued sides...
        else 'Association'
    }

    def private options(Relationship it, Boolean outgoing, String relationFieldType, Boolean autoComplete) {
        val expanded = (!outgoing && expandedSource) || (outgoing && expandedTarget)
        val thisEntity = if (outgoing) source else target
        val relatedEntity = if (outgoing) target else source
        var calls = ''
        if ('Association' == relationFieldType) {
            if (autoComplete) {
                calls += '''->autocomplete()'''
            } else if (!expanded) {
                calls += '''->renderAsNativeWidget()'''
            }
            // renderAsEmbeddedForm
            if (thisEntity.hasEditAction) {
                calls += '''->setFormTypeOption('choice_label', fn («relatedEntity.name.formatForCodeCapital» $entity): string => $this->entityDisplayHelper->format«relatedEntity.name.formatForCodeCapital»($entity))'''
            }
        } else if ('Collection' == relationFieldType) {
            calls += '''->setEntryIsComplex()'''
            // setEntryType
            // useEntryCrudForm
            if (thisEntity.hasEditAction) {
                calls += '''->setEntryToStringMethod(fn («relatedEntity.name.formatForCodeCapital» $entity, TranslatorInterface $translator): string => $this->entityDisplayHelper->format«relatedEntity.name.formatForCodeCapital»($entity))'''
            }
        }
        if (expanded) {
            calls += '''->renderExpanded()'''
        }
        if (thisEntity.hasIndexAction || thisEntity.hasDetailAction) {
            calls += '''->setTemplatePath('@«application.vendor.formatForCodeCapital + application.name.formatForCodeCapital»/admin/crud/field/association.html.twig')'''
        }
        calls
    }

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
            $queryBuilder = function (EntityRepository $er) {«/* return $er->getListQueryBuilder('', '', false);* /»
                return $this->«relatedEntity.name.formatForCode»Repository->getListQueryBuilder('', '', false);
            };
            «IF (relatedEntity as Entity).ownerPermission»
                if (true === $options['filter_by_ownership']) {
                    $collectionFilterHelper = $this->collectionFilterHelper;
                    $queryBuilder = function (EntityRepository $er) use ($collectionFilterHelper) {
                        $qb = $this->«relatedEntity.name.formatForCode»Repository->getListQueryBuilder('', '', false);
                        $collectionFilterHelper->addCreatorFilter($qb);

                        return $qb;
                    };
                }
            «ENDIF»
            «IF !autoComplete»
                $choiceLabelClosure = fn ($entity) => $this->entityDisplayHelper->getFormattedTitle($entity);
            «ENDIF»
            ... already removed code ...
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
