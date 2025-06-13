package org.zikula.modulestudio.generator.cartridges.symfony.controller.config

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.Relationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerMethodInterface
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.NumberField

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
        val formFields = getAllEntityFields
        val imports = newArrayList
        imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Filters')
        val nsEabFilter = 'EasyCorp\\Bundle\\EasyAdminBundle\\Filter\\'
        if (!formFields.filter(BooleanField).empty) {
            imports.add(nsEabFilter + 'BooleanFilter')
        }      
        if (!formFields.filter(ArrayField).empty) {
            imports.add(nsEabFilter + 'ArrayFilter')
        }      
        if (
            !formFields.filter(StringField).filter[f|f.role === StringRole.LOCALE].empty
            || !hasVisibleWorkflow && hasListFieldsEntity
            || hasVisibleWorkflow && 1 < getListFieldsEntity.length
        ) {
            imports.add(nsEabFilter + 'ChoiceFilter')
        }
        if (!allEntityFields.filter(DatetimeField).empty) {
            imports.add(nsEabFilter + 'DateTimeFilter')
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
        «FOR field : getAllEntityFields.filter[f|!f.name.equals('workflowState') || hasVisibleWorkflow]»«/* hide workflow filter if not needed */»
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
        ->add('«name.formatForCode»')«options»
    '''
    def private dispatch options(Field it) ''''''

    def private dispatch filter(BooleanField it) '''
        ->add(BooleanFilter::new('«name.formatForCode»')«options»)
    '''

    def private dispatch filter(StringField it) '''
        «IF role === StringRole.LOCALE»
            ->add(ChoiceFilter::new('«name.formatForCode»')«options»)
        «ELSEIF hasSelectorRole»
            ->add(TextFilter::new('«name.formatForCode»')«options»)
        «ELSE»
            ->add(TextFilter::new('«name.formatForCode»')«options»)
        «ENDIF»
    '''
    def private dispatch options(StringField it) {
        if (role === StringRole.COLOUR) '''->setFormTypeOptions(['value_type' => ColorType::class])''' else
        if (role === StringRole.COUNTRY) '''->setFormTypeOptions(['value_type' => CountryType::class])''' else
        if (role === StringRole.CURRENCY) '''->setFormTypeOptions(['value_type' => CurrencyType::class])''' else
        if (role === StringRole.ICON) '''->setFormTypeOptions(['value_type' => IconType::class])''' else
        if (role === StringRole.LANGUAGE) '''->setFormTypeOptions(['value_type' => LanguageType::class])''' else
        if (role === StringRole.LOCALE) '''->setChoices($this->localeApi->getSupportedLocaleNames())''' else
        if (role === StringRole.PASSWORD) '''->setFormTypeOptions(['value_type' => PasswordType::class])''' else
        if (role === StringRole.PHONE_NUMBER) '''->setFormTypeOptions(['value_type' => TelType::class])''' else
        if (role === StringRole.TIME_ZONE) '''->setFormTypeOptions(['value_type' => TimezoneType::class])''' else
        if (role === StringRole.URL) '''->setFormTypeOptions(['value_type' => UrlType::class])''' else
        if (role === StringRole.WEEK) '''->setFormTypeOptions(['value_type' => WeekType::class])''' else
        ''
    }
    def private hasSelectorRole(StringField it) {
        #[StringRole.COLOUR, StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)
    }
    def private dispatch filter(NumberField it) '''
        ->add(NumericFilter::new('«name.formatForCode»'))
    '''
    def private dispatch filter(ArrayField it) '''
        ->add(ArrayFilter::new('«name.formatForCode»')->canSelectMultiple(true))
    '''
    def private dispatch filter(ListField it) '''
        ->add(ChoiceFilter::new('«name.formatForCode»')->setChoices($«name.formatForCode»Choices)«IF expanded»->renderExpanded(true)«ENDIF»«IF multiple»->canSelectMultiple(true)«ENDIF»)
    '''
    def private dispatch filter(DatetimeField it) '''
        ->add(DateTimeFilter::new('«name.formatForCode»'))
    '''

    // relations

    /*
     * User fields are automatically recognized as associations and passed to EntityFilter during runtime.
     * Explicit handling should follow "relationFilter" below.
     *
     * def private dispatch filter(UserField it) '''
        ->add(TextFilter::new('«name.formatForCode»')«options»)
    '''
    //def private dispatch options(UserField it) '''«placeholderOption»'''
    */
    def private relationFilter(Relationship it, Boolean outgoing) '''
        «val aliasName = getRelationAliasName(outgoing)»
        ->add('«aliasName.formatForCode»')
    '''

    /* TODO review relation-related leftovers of old code

    def private addRelationshipFields(Entity it, String mode) '''
        public function add«mode.toFirstUpper»RelationshipFields(FormBuilderInterface $builder, array $options = []): void
        {
            $entityDisplayHelper = $this->entityDisplayHelper;
            «FOR relation : (if (mode == 'incoming') incomingRelations else outgoingRelations)»
                «relation.relationImpl(mode == 'outgoing')»

            «ENDFOR»
        }
    '''

    def private relationImpl(Relationship it, Boolean useTarget) '''
        «val sourceAliasName = getRelationAliasName(useTarget)»
        $objectType = '«(if (useTarget) target else source).name.formatForCode»';
        // select without joins
        $entities = $this->entityFactory->getRepository($objectType)->selectWhere('', '', false);
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

    def private collectBaseImports(Entity it) {
        val imports = new ImportList
        if (!fields.filter(UserField).empty) {
            imports.add('Zikula\\UsersBundle\\Entity\\User')
        }
        if (!incomingRelations.empty || !outgoingRelations.empty) {
            imports.add(app.appNamespace + '\\Entity\\Factory\\EntityFactory')
        }
        if (!incomingRelations.empty || !outgoingRelations.empty) {
            imports.add(app.appNamespace + '\\Helper\\EntityDisplayHelper')
        }
        if (needsFeatureActivationHelperEntity) {
            imports.add(app.appNamespace + '\\Helper\\FeatureActivationHelper')
        }
        if (hasListFieldsEntity) {
            imports.add(app.appNamespace + '\\Helper\\ListEntriesHelper')
        }
        if (!incomingRelations.empty || !outgoingRelations.empty) {
            imports.add(app.appNamespace + '\\Helper\\PermissionHelper')
        }
        imports
    }

    def private quickNavTypeBaseImpl(Entity it) '''
        public function __construct(
            «IF !incomingRelations.empty || !outgoingRelations.empty»
                protected readonly EntityFactory $entityFactory,
                protected readonly PermissionHelper $permissionHelper,
                protected readonly EntityDisplayHelper $entityDisplayHelper«IF hasListFieldsEntity || hasLocaleFieldsEntity || needsFeatureActivationHelperEntity»,«ENDIF»
            «ENDIF»
            «IF hasListFieldsEntity»
                protected readonly ListEntriesHelper $listHelper«IF hasLocaleFieldsEntity || needsFeatureActivationHelperEntity»,«ENDIF»
            «ENDIF»
            «IF hasLocaleFieldsEntity»
                protected readonly LocaleApiInterface $localeApi«IF needsFeatureActivationHelperEntity»,«ENDIF»
            «ENDIF»
            «IF needsFeatureActivationHelperEntity»
                protected readonly FeatureActivationHelper $featureActivationHelper
            «ENDIF»
        ) {
        }

        public function buildForm(FormBuilderInterface $builder, array $options): void
        {
            «IF !incomingRelations.empty»
                $this->addIncomingRelationshipFields($builder, $options);
            «ENDIF»
            «IF !outgoingRelations.empty»
                $this->addOutgoingRelationshipFields($builder, $options);
            «ENDIF»
        }

        «IF !incomingRelations.empty»
            «addRelationshipFields('incoming')»

        «ENDIF»
        «IF !outgoingRelations.empty»
            «addRelationshipFields('outgoing')»

        «ENDIF»
    '''
    */
}
