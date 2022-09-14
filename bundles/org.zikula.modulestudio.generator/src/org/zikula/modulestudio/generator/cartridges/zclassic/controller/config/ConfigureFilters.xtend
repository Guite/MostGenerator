package org.zikula.modulestudio.generator.cartridges.zclassic.controller.config

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerMethodInterface
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

    Iterable<JoinRelationship> incomingRelations
    Iterable<JoinRelationship> outgoingRelations

    override void init(Entity it) {
        incomingRelations = getJoinRelationsWithEntities(true)
        outgoingRelations = getJoinRelationsWithEntities(false)
    }

    override imports(Entity it) {
        val imports = newArrayList
        imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Filters')
        val nsEabFilter = 'EasyCorp\\Bundle\\EasyAdminBundle\\Filter\\'
        if (!getAllEntityFields.filter(ArrayField).empty) {
            imports.add(nsEabFilter + 'ArrayFilter')
        }      
        if (!hasVisibleWorkflow && hasListFieldsEntity || hasVisibleWorkflow && 1 < getListFieldsEntity.length) {
            imports.add(nsEabFilter + 'ChoiceFilter')
        }
        if (!allEntityFields.filter(DatetimeField).empty) {
            imports.add(nsEabFilter + 'DateTimeFilter')
        }
        imports.add(nsEabFilter + 'TextFilter')
        imports.add('Translation\\Extractor\\Annotation\\Ignore')

        val nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'
        if (!allEntityFields.filter(StringField).filter[f|f.role === StringRole.COLOUR].empty) {
            imports.add(nsSymfonyFormType + 'ColorType')
        }
        if (hasCountryFieldsEntity) {
            imports.add(nsSymfonyFormType + 'CountryType')
        }
        if (hasCurrencyFieldsEntity) {
            imports.add(nsSymfonyFormType + 'CurrencyType')
        }
        if (hasLanguageFieldsEntity) {
            imports.add(nsSymfonyFormType + 'LanguageType')
        }
        if (hasLocaleFieldsEntity) {
            imports.add(nsSymfonyFormType + 'LocaleType')
            imports.add('Zikula\\Bundle\\CoreBundle\\Api\\ApiInterface\\LocaleApiInterface')
        }
        if (hasTimezoneFieldsEntity) {
            imports.add(nsSymfonyFormType + 'TimezoneType')
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

    // TODO remove this (same in ConfigureFields)
    def private fetchListEntries(ListField it) '''
        $listEntries = $this->listEntriesHelper->getEntries('«entity.name.formatForCode»', '«name.formatForCode»');
        $«name.formatForCode»Choices = [];
        foreach ($listEntries as $entry) {
            $«name.formatForCode»Choices[$entry['text']] = $entry['value'];
        }
    '''

    def private methodBody(Entity it) '''
        «/* TODO categories
        IF categorisable»
            if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, '«name.formatForCode»')) {
                $this->addCategoriesField($builder, $options);
            }
        «ENDIF*/»«FOR field : getAllEntityFields.filter[f|!f.name.equals('workflowState') || hasVisibleWorkflow]»«/* hide workflow filter if not needed */»
            «field.filter»
        «ENDFOR»
        «FOR relation : incomingRelations»
            «relation.relationFilter(false)»
        «ENDFOR»
        «FOR relation : outgoingRelations»
            «relation.relationFilter(true)»
        «ENDFOR»
    '''

    def private dispatch filter(Field it) ''''''
    def private dispatch filter(DerivedField it) '''
        ->add('«name.formatForCode»')«options»
    '''
    def private dispatch options(DerivedField it) ''''''
    def private placeholderOption(Object it) ''', 'value_type_options.placeholder' => t('All')'''

    /*def private dispatch filter(UserField it) '''
        ->add(TextFilter::new('«name.formatForCode»')«options»)
    '''
    //def private dispatch options(UserField it) '''«placeholderOption»'''
    */

    def private dispatch filter(StringField it) '''
        «IF hasSelectorRole»
            ->add(TextFilter::new('«name.formatForCode»')«options»)
        «ELSE»
            ->add('«name.formatForCode»')«options»
        «ENDIF»
    '''
    def private dispatch options(StringField it) {
        if (role === StringRole.COLOUR) '''->setFormTypeOptions(['value_type' => ColorType::class])''' else
        if (role === StringRole.COUNTRY) '''->setFormTypeOptions(['value_type' => CountryType::class«placeholderOption»])''' else
        if (role === StringRole.CURRENCY) '''->setFormTypeOptions(['value_type' => CurrencyType::class«placeholderOption»])''' else
        if (role === StringRole.LANGUAGE) '''->setFormTypeOptions(['value_type' => LanguageType::class«placeholderOption»])''' else
        if (role === StringRole.LOCALE) '''->setFormTypeOptions(['value_type' => LocaleType::class«placeholderOption»])''' else
        if (role === StringRole.TIME_ZONE) '''->setFormTypeOptions(['value_type' => TimezoneType::class«placeholderOption»])''' else
        ''
    }
    def private hasSelectorRole(StringField it) {
        #[StringRole.COLOUR, StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)
    }
    def private dispatch filter(ArrayField it) '''
        ->add(ArrayFilter::new('«name.formatForCode»')->canSelectMultiple())
    '''
    def private dispatch filter(ListField it) '''
        «/* explicit Filter class needed until Types::JSON is mapped in https://github.com/EasyCorp/EasyAdminBundle/blob/4.x/src/Factory/FilterFactory.php#L28 */»
        ->add(ChoiceFilter::new('«name.formatForCode»')->setChoices($«name.formatForCode»Choices)«IF expanded»->renderExpanded()«ENDIF»«IF multiple»->canSelectMultiple()«ENDIF»)
    '''
    def private dispatch filter(DatetimeField it) '''
        ->add(DateTimeFilter::new('«name.formatForCode»')«IF immutable»«/* avoid choices */»->setFormTypeOption('value_type_options.widget', 'single_text')«ENDIF»)
    '''
    def private relationFilter(JoinRelationship it, Boolean outgoing) '''
        «val aliasName = getRelationAliasName(outgoing)»
        ->add('«aliasName.formatForCode»')
    '''

    /* TODO review leftovers of old code

    def private addRelationshipFields(Entity it, String mode) '''
        public function add«mode.toFirstUpper»RelationshipFields(FormBuilderInterface $builder, array $options = []): void
        {
            $request = $this->requestStack->getCurrentRequest();
            $entityDisplayHelper = $this->entityDisplayHelper;
            «FOR relation : (if (mode == 'incoming') incomingRelations else outgoingRelations)»
                «relation.relationImpl(mode == 'outgoing')»

            «ENDFOR»
        }
    '''

    def private relationImpl(JoinRelationship it, Boolean useTarget) '''
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
            'choices' => /** @Ignore * /$choices,
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
        if (!incomingRelations.empty || !outgoingRelations.empty) {
            imports.add('Symfony\\Component\\HttpFoundation\\RequestStack')
        }
        if (categorisable) {
            imports.add('Zikula\\CategoriesBundle\\Form\\Type\\CategoriesType')
        }
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
                protected readonly RequestStack $requestStack,
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

        public function buildForm(FormBuilderInterface $builder, array $options)
        {
            «IF !incomingRelations.empty»
                $this->addIncomingRelationshipFields($builder, $options);
            «ENDIF»
            «IF !outgoingRelations.empty»
                $this->addOutgoingRelationshipFields($builder, $options);
            «ENDIF»
        }

        «IF categorisable»
            «addCategoriesField»

        «ENDIF»
        «IF !incomingRelations.empty»
            «addRelationshipFields('incoming')»

        «ENDIF»
        «IF !outgoingRelations.empty»
            «addRelationshipFields('outgoing')»

        «ENDIF»
    '''

    def private addCategoriesField(Entity it) '''
        public function addCategoriesField(FormBuilderInterface $builder, array $options = []): void
        {
            $objectType = '«name.formatForCode»';
            $entityCategoryClass = '«app.appNamespace»\Entity\\' . ucfirst($objectType) . 'CategoryEntity';
            $builder->add('categories', CategoriesType::class, [
                'label' => '«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»',
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'form-control-sm category-selector',
                    'title' => 'This is an optional filter.',
                ],
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'bundle' => '«app.appName»',
                'entity' => ucfirst($objectType) . 'Entity',
                'entityCategoryClass' => $entityCategoryClass,
                'showRegistryLabels' => true,
            ]);
        }
    '''
    */
}
