package org.zikula.modulestudio.generator.cartridges.symfony.controller.config

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.Relationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerMethodInterface
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ConfigureFilters implements ControllerMethodInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    Iterable<Relationship> incomingRelations
    Iterable<Relationship> outgoingRelations

    override void init(Entity it) {
        incomingRelations = getCommonRelations(true)
        outgoingRelations = getCommonRelations(false)
    }

    override imports(Entity it) {
        val formFields = getAllEntityFields.filter[f|!(f instanceof UploadField)]
        val imports = newArrayList
        imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Filters')
        val nsEabFilter = 'EasyCorp\\Bundle\\EasyAdminBundle\\Filter\\'
        if (!formFields.filter(BooleanField).empty) {
            imports.add(nsEabFilter + 'BooleanFilter')
        }      
        /*if (!formFields.filter(ArrayField).empty) {
            imports.add(nsEabFilter + 'ArrayFilter')
        }*/     
        if (
            !hasVisibleWorkflow && hasListFieldsEntity
            || hasVisibleWorkflow && 1 < getListFieldsEntity.length
        ) {
            imports.add(nsEabFilter + 'ChoiceFilter')
        }
        if (!allEntityFields.filter(DatetimeField).empty) {
            imports.add(nsEabFilter + 'DateTimeFilter')
        }
        if (!allEntityFields.filter(UserField).empty || !incomingRelations.empty || !outgoingRelations.empty) {
            imports.add(nsEabFilter + 'EntityFilter')
        }
        if (!formFields.filter(NumberField).empty) {
            imports.add(nsEabFilter + 'NumericFilter')
        }      
        imports.add(nsEabFilter + 'TextFilter')

        val nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'
        if (!formFields.filter(StringField).filter[f|f.role === StringRole.COLOUR].empty) {
            imports.add(nsSymfonyFormType + 'ColorType')
        }
        if (hasCountryFieldsEntity) {
            imports.add(nsSymfonyFormType + 'CountryType')
        }
        if (hasCurrencyFieldsEntity) {
            imports.add(nsSymfonyFormType + 'CurrencyType')
        }
        if (!formFields.filter(StringField).filter[role == StringRole.ICON].empty) {
            imports.add('Zikula\\ThemeBundle\\Form\\Type\\IconType')
        }
        if (hasLanguageFieldsEntity) {
            imports.add(nsSymfonyFormType + 'LanguageType')
        }
        if (hasLocaleFieldsEntity) {
            imports.add(nsSymfonyFormType + 'LocaleType')
        }
        if (!formFields.filter(StringField).filter[f|f.role === StringRole.PASSWORD].empty) {
            imports.add(nsSymfonyFormType + 'PasswordType')
        }
        if (!formFields.filter(StringField).filter[f|f.role === StringRole.PHONE_NUMBER].empty) {
            imports.add(nsSymfonyFormType + 'TelType')
        }
        if (hasTimezoneFieldsEntity) {
            imports.add(nsSymfonyFormType + 'TimezoneType')
        }
        if (!formFields.filter(StringField).filter[f|f.role === StringRole.URL].empty) {
            imports.add(nsSymfonyFormType + 'UrlType')
        }
        if (!formFields.filter(StringField).filter[f|f.role === StringRole.WEEK].empty) {
            imports.add(nsSymfonyFormType + 'WeekType')
        }

        imports
    }

    override generateMethod(Entity it) '''
        public function configureFilters(Filters $filters): Filters
        {
            if (!$this->permissionHelper->mayUseQuickNav('«name.formatForCode»')) {
                return $filters;
            }

            «FOR field : getListFieldsEntity»
                «fetchListEntries(field)»
            «ENDFOR»

            return $filters
                «methodBody»
            ;
        }
    '''

    def private fetchListEntries(ListField it) '''
        $«name.formatForCode»Choices = $this->listEntriesHelper->getFormChoices('«entity.name.formatForCode»', '«name.formatForCode»');
    '''

    def private methodBody(Entity it) '''
        «FOR field : getAllEntityFields.filter[f|!(f instanceof UploadField)].filter[f|!f.name.equals('workflowState') || hasVisibleWorkflow]»«/* hide workflow filter if not needed */»
            «field.filter»
        «ENDFOR»
        «FOR relation : incomingRelations»
            «relation.relationFilter(false)»
        «ENDFOR»
        «FOR relation : outgoingRelations»
            «relation.relationFilter(true)»
        «ENDFOR»
    '''

    def private dispatch filter(Field it) '''
        ->add('«name.formatForCode»')
    '''
    def private dispatch options(Field it) ''''''

    def private dispatch filter(BooleanField it) '''
        ->add(BooleanFilter::new('«name.formatForCode»', «label»)«options»)
    '''

    def private dispatch filter(StringField it) '''
        ->add(TextFilter::new('«name.formatForCode»', «label»)«options»)
    '''
    def private dispatch options(StringField it) {
        if (role === StringRole.COLOUR) '''->setFormTypeOptions(['value_type' => ColorType::class])''' else
        if (role === StringRole.COUNTRY) '''->setFormTypeOptions(['value_type' => CountryType::class])''' else
        if (role === StringRole.CURRENCY) '''->setFormTypeOptions(['value_type' => CurrencyType::class])''' else
        //if (role === StringRole.ICON) '''->setFormTypeOptions(['value_type' => IconType::class])''' else
        if (role === StringRole.LANGUAGE) '''->setFormTypeOptions(['value_type' => LanguageType::class])''' else
        if (role === StringRole.LOCALE) '''->setFormTypeOptions(['value_type' => LocaleType::class])''' else
        if (role === StringRole.PASSWORD) '''->setFormTypeOptions(['value_type' => PasswordType::class])''' else
        if (role === StringRole.PHONE_NUMBER) '''->setFormTypeOptions(['value_type' => TelType::class])''' else
        if (role === StringRole.TIME_ZONE) '''->setFormTypeOptions(['value_type' => TimezoneType::class])''' else
        if (role === StringRole.URL) '''->setFormTypeOptions(['value_type' => UrlType::class])''' else
        if (role === StringRole.WEEK) '''->setFormTypeOptions(['value_type' => WeekType::class])''' else
        ''
    }

    def private dispatch filter(TextField it) '''
        ->add(TextFilter::new('«name.formatForCode»', «label»)«options»)
    '''

    def private dispatch filter(NumberField it) '''
        ->add(NumericFilter::new('«name.formatForCode»', «label»)«options»)
    '''
    /* use TextFilter for array fields instead because its not easy to detect the choices
    def private dispatch filter(ArrayField it) '''
        ->add(ArrayFilter::new('«name.formatForCode»', «label»)->canSelectMultiple(true)->setTranslatableChoices(...))
    '''*/
    def private dispatch filter(ArrayField it) '''
        ->add(TextFilter::new('«name.formatForCode»', «label»)«options»)
    '''
    def private dispatch filter(ListField it) '''
        ->add(ChoiceFilter::new('«name.formatForCode»', «label»)«options»)
    '''
    def private dispatch options(ListField it) '''->setTranslatableChoices($«name.formatForCode»Choices)«IF expanded»->renderExpanded(true)«ENDIF»«IF multiple»->canSelectMultiple(true)«ENDIF»'''
    def private dispatch filter(DatetimeField it) '''
        ->add(DateTimeFilter::new('«name.formatForCode»', «label»)«options»)
    '''

    def private label(Field it) '''t('«name.formatForDisplayCapital»')'''

    // relations

    /*
     * User fields handling should follow "relationFilter" below.
     */
    def private dispatch filter(UserField it) '''
        ->add(EntityFilter::new('«name.formatForCode»', «label»)«options»)
    '''
    def private dispatch options(UserField it) '''->autocomplete()'''

    def private relationFilter(Relationship it, Boolean outgoing) '''
        «val aliasName = getRelationAliasName(outgoing)»
        ->add(EntityFilter::new('«aliasName.formatForCode»', t('«aliasName.formatForDisplayCapital»'))«options(outgoing)»)
    '''

    def private options(Relationship it, Boolean outgoing) {
        // ->canSelectMultiple(true) enabled automatically by default for *ToMany relationships
        '''->autocomplete()'''
    }

    /* TODO review relation-related leftovers of old code

    if (!incomingRelations.empty || !outgoingRelations.empty) {
        imports.add(app.appNamespace + '\\Helper\\EntityDisplayHelper')
        // ...
        protected readonly EntityDisplayHelper $entityDisplayHelper«IF hasListFieldsEntity || hasLocaleFieldsEntity || needsFeatureActivationHelperEntity»,«ENDIF»
    }

    def private relationImpl(Relationship it, Boolean useTarget) '''
        «val sourceAliasName = getRelationAliasName(useTarget)»
        $objectType = '«(if (useTarget) target else source).name.formatForCode»';
        // select without joins
        $entities = $this->«(if (useTarget) target else source).name.formatForCode»Repository->selectWhere('', '', false);
        $permLevel = «(if (useTarget) target else source).getPermissionAccessLevel(ModuleStudioFactory.eINSTANCE.createIndexAction)»;

        $entities = $this->permissionHelper->filterCollection($objectType, $entities, $permLevel);
        $choices = [];
        foreach ($entities as $entity) {
            $choices[$entity->getId()] = $entity;
        }

        $builder->add('«sourceAliasName.formatForCode»', ChoiceType::class, [
            'choices' => $choices,
            'choice_label' => function ($entity) use ($entityDisplayHelper) {
                return $entityDisplayHelper->getFormattedTitle($entity);
            },
            'placeholder' => 'All',
            'required' => false,
            'label' => '«sourceAliasName.formatForDisplayCapital»',
            'attr' => [
                'class' => 'form-control-sm',
            ],
        ]);
    '''
    */
}
