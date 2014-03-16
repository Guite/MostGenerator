package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTimestampableType
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Extensions {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    def imports(Entity it) '''
        use Gedmo\Mapping\Annotation as Gedmo;
    '''

    /**
     * Class annotations.
     */
    def classExtensions(Entity it) '''
         «IF loggable»
         * @Gedmo\Loggable(logEntryClass="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('logEntry', false)»")
         «ENDIF»
         «IF softDeleteable && !container.application.targets('1.3.5')»
         * @Gedmo\SoftDeleteable(fieldName="deletedAt")
         «ENDIF»
         «IF hasTranslatableFields»
         * @Gedmo\TranslationEntity(class="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('translation', false)»")
         «ENDIF»
         «IF tree != EntityTreeType::NONE»
         * @Gedmo\Tree(type="«tree.asConstant»")
            «IF tree == EntityTreeType::CLOSURE»
             * @Gedmo\TreeClosure(class="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('closure', false)»")
            «ENDIF»
         «ENDIF»
        «IF container.application.name == 'foo'»dummy for indentation«ENDIF»
    '''

    /**
     * Column annotations.
     */
    def private columnExtensionsDefault(DerivedField it) '''
        «IF entity.loggable» * @Gedmo\Versioned
        «ENDIF»
        «IF translatable» * @Gedmo\Translatable
        «ENDIF»
        «IF it instanceof AbstractStringField && (it as AbstractStringField).sluggablePosition > 0 && entity.container.application.targets('1.3.5')» * @Gedmo\Sluggable(slugField="slug", position=«(it as AbstractStringField).sluggablePosition»)
        «ENDIF»
        «IF sortableGroup» * @Gedmo\SortableGroup
        «ENDIF»
    '''
    def columnExtensions(DerivedField it) {
        switch it {
            AbstractIntegerField: '''
                «columnExtensionsDefault»
                 «IF it.sortablePosition»
                 * @Gedmo\SortablePosition
                 «ENDIF»
            '''
            AbstractDateField: '''
                «columnExtensionsDefault»
                 «IF it.timestampable != EntityTimestampableType::NONE»
                  * @Gedmo\Timestampable(on="«it.timestampable.asConstant»"«timestampableDetails»)
                 «ENDIF»
            '''
            default: columnExtensionsDefault
        }
    }

    def private timestampableDetails(AbstractDateField it) '''«IF timestampable == EntityTimestampableType::CHANGE», field="«timestampableChangeTriggerField.formatForCode»"«IF timestampableChangeTriggerValue !== null && timestampableChangeTriggerValue != ''», value="«timestampableChangeTriggerValue.formatForCode»"«ENDIF»«ENDIF»'''

    /**
     * Additional column definitions.
     */
    def additionalProperties(Entity it) '''
        «additionalPropertiesGeographical»
        «additionalPropertiesSoftDeleteable»
        «additionalPropertiesSluggable»
        «additionalPropertiesTranslatable»
        «additionalPropertiesTree»
        «additionalPropertiesMetaData»
        «additionalPropertiesAttributable»
        «additionalPropertiesCategorisable»
        «additionalPropertiesStandardFields»
    '''

    def private additionalPropertiesGeographical(Entity it) '''
        «IF geographical»

            /**
             * The coordinate's latitude part.
             *
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @ORM\Column(type="decimal", precision=10, scale=7)
             * @var decimal $latitude.
             */
            protected $latitude = 0.00;

            /**
             * The coordinate's longitude part.
             *
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @ORM\Column(type="decimal", precision=10, scale=7)
             * @var decimal $longitude.
             */
            protected $longitude = 0.00;
        «ENDIF»
    '''

    def private additionalPropertiesSoftDeleteable(Entity it) '''
        «IF softDeleteable»

            /**
             * Date of when this item has been marked as deleted.
             *
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @ORM\Column(type="datetime", nullable=true)
             * @var datetime $deletedAt.
             */
            protected $deletedAt;
        «ENDIF»
    '''

    def private additionalPropertiesSluggable(Entity it) '''
        «IF hasSluggableFields»

            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             «IF hasTranslatableSlug»
                 * @Gedmo\Translatable
             «ENDIF»
             «IF container.application.targets('1.3.5')»
             * @Gedmo\Slug(style="«slugStyle.asConstant»", separator="«slugSeparator»", unique=«slugUnique.displayBool», updatable=«slugUpdatable.displayBool»)
             «ELSE»
             * @Gedmo\Slug(fields={«FOR field : getSluggableFields SEPARATOR ', '»"«field.name.formatForCode»"«ENDFOR»}, updatable=«slugUpdatable.displayBool», unique=«slugUnique.displayBool», separator="«slugSeparator»", style="«slugStyle.asConstant»")
             «ENDIF»
             * @ORM\Column(type="string", length=«slugLength», unique=«slugUnique.displayBool»)
             * @var string $slug.
             */
            protected $slug;
        «ENDIF»
    '''

    def private additionalPropertiesTranslatable(Entity it) '''
        «IF hasTranslatableFields»

            /**
             * Field for storing the locale of this entity.
             * Overrides the locale set in translationListener (as pointed out in https://github.com/l3pp4rd/DoctrineExtensions/issues/130#issuecomment-1790206 ).
             *
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @Gedmo\Locale«/*the same as @Gedmo\Language*/»
             * @var string $locale.
             */
            protected $locale;
        «ENDIF»
    '''

    def private additionalPropertiesTree(Entity it) '''
        «IF tree != EntityTreeType::NONE»

            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @Gedmo\TreeLeft
             * @ORM\Column(type="integer")
             * @var integer $lft.
             */
            protected $lft;

            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @Gedmo\TreeLevel
             * @ORM\Column(type="integer")
             * @var integer $lvl.
             */
            protected $lvl;

            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @Gedmo\TreeRight
             * @ORM\Column(type="integer")
             * @var integer $rgt.
             */
            protected $rgt;

            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @Gedmo\TreeRoot
             * @ORM\Column(type="integer", nullable=true)
             * @var integer $root.
             */
            protected $root;

            /**
             * Bidirectional - Many children [«name.formatForDisplay»] are linked by one parent [«name.formatForDisplay»] (OWNING SIDE).
             *
             * @Gedmo\TreeParent
             * @ORM\ManyToOne(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", inversedBy="children")
             * @ORM\JoinColumn(name="parent_id", referencedColumnName="«getPrimaryKeyFields.head.name.formatForDisplay»", onDelete="SET NULL")
             * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)» $parent.
             */
            protected $parent;

            /**
             * Bidirectional - One parent [«name.formatForDisplay»] has many children [«name.formatForDisplay»] (INVERSE SIDE).
             *
             * @ORM\OneToMany(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", mappedBy="parent")
             * @ORM\OrderBy({"lft" = "ASC"})
             * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)» $children.
             */
            protected $children;
        «ENDIF»
    '''

    def private additionalPropertiesMetaData(Entity it) '''
        «IF metaData»

            /**
             * @ORM\OneToOne(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('metaData', false)»", 
             *               mappedBy="entity", cascade={"all"},
             *               orphanRemoval=true)
             * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('metaData', false)»
             */
            protected $metadata = null;
        «ENDIF»
    '''

    def private additionalPropertiesAttributable(Entity it) '''
        «IF attributable»

            /**
             * @ORM\OneToMany(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('attribute', false)»", 
             *                mappedBy="entity", cascade={"all"}, 
             *                orphanRemoval=true, indexBy="name")
             * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('attribute', false)»
             */
            protected $attributes = null;
        «ENDIF»
    '''

    def private additionalPropertiesCategorisable(Entity it) '''
        «IF categorisable»

            /**
             * @ORM\OneToMany(targetEntity="«IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('category', false)»", 
             *                mappedBy="entity", cascade={"all"}, 
             *                orphanRemoval=true«/*commented out as this causes only one category to be selected (#349)   , indexBy="categoryRegistryId"*/»)
             * @var «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('category', false)»
             */
            protected $categories = null;
        «ENDIF»
    '''

    def private additionalPropertiesStandardFields(Entity it) '''
        «IF standardFields»

            /**
             * @ORM\Column(type="integer")
             * @ZK\StandardFields(type="userid", on="create")
             * @var integer $createdUserId.
             */
            protected $createdUserId;
    
            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @ORM\Column(type="integer")
             * @ZK\StandardFields(type="userid", on="update")
             * @var integer $updatedUserId.
             */
            protected $updatedUserId;
    
            /**
             * @ORM\Column(type="datetime")
             * @Gedmo\Timestampable(on="create")
             * @var datetime $createdDate.
             */
            protected $createdDate;
    
            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @ORM\Column(type="datetime")
             * @Gedmo\Timestampable(on="update")
             * @var datetime $updatedDate.
             */
            protected $updatedDate;
        «ENDIF»
    '''

    def additionalAccessors(Entity it) '''
        «IF geographical»
            «fh.getterAndSetterMethods(it, 'latitude', 'decimal', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'longitude', 'decimal', false, false, '', '')»
        «ENDIF»
        «IF softDeleteable»
            «fh.getterAndSetterMethods(it, 'deletedAt', 'datetime', false, false, '', '')»
        «ENDIF»
        «IF hasSluggableFields»
            «IF container.application.targets('1.3.5')»
            «fh.getterMethod(it, 'slug', 'string', false)»
            «ELSE»
            «fh.getterAndSetterMethods(it, 'slug', 'string', false, false, '', '')»
            «ENDIF»
        «ENDIF»
        «IF tree != EntityTreeType::NONE»
            «fh.getterAndSetterMethods(it, 'lft', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'lvl', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'rgt', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'root', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'parent', (if (!container.application.targets('1.3.5')) '\\' else '') + entityClassName('', false), false, true, 'null', '')»
            «fh.getterAndSetterMethods(it, 'children', 'array', true, false, '', '')»
        «ENDIF»
        «IF hasTranslatableFields»
            «fh.getterAndSetterMethods(it, 'locale', 'string', false, false, '', '')»
        «ENDIF»
        «IF metaData»
            «fh.getterAndSetterMethods(it, 'metadata', (if (!container.application.targets('1.3.5')) '\\' else '') + entityClassName('metaData', false), false, true, 'null', '')»
        «ENDIF»
        «IF attributable»
            «fh.getterMethod(it, 'attributes', 'array', true)»
            /**
             * Set attribute.
             *
             * @param string $name.
             * @param string $value.
             *
             * @return void
             */
            public function setAttribute($name, $value)
            {
                if(isset($this->attributes[$name])) {
                    if($value == null) {
                        $this->attributes->remove($name);
                    } else {
                        $this->attributes[$name]->setValue($value);
                    }
                } else {
                    $this->attributes[$name] = new «IF !container.application.targets('1.3.5')»\«ENDIF»«entityClassName('attribute', false)»($name, $value, $this);
                }
            }

        «ENDIF»
        «IF categorisable»
            «fh.getterAndSetterMethods(it, 'categories', 'array', true, false, '', '')»
        «ENDIF»
        «IF standardFields»
            «fh.getterAndSetterMethods(it, 'createdUserId', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'updatedUserId', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'createdDate', 'datetime', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'updatedDate', 'datetime', false, false, '', '')»
        «ENDIF»
    '''


    /**
     * Separate extension classes.
     */
    def extensionClasses(Application it, IFileSystemAccess fsa) {
        if (hasLoggable) {
            // loggable log entry class
            for (entity : getLoggableEntities) entity.extensionClasses(it, 'logEntry', fsa)
        }
        if (hasTranslatable) {
            // translation entities
            for (entity : getTranslatableEntities) entity.extensionClasses(it, 'translation', fsa)
        }
        if (hasTrees) {
            // tree closure domain object
            for (entity : getTreeEntities.filter[tree == EntityTreeType::CLOSURE]) entity.extensionClasses(it, 'closure', fsa)
        }
        if (hasMetaDataEntities) {
            for (entity : getMetaDataEntities) entity.extensionClasses(it, 'metaData', fsa)
        }
        if (hasAttributableEntities) {
            for (entity : getAttributableEntities) entity.extensionClasses(it, 'attribute', fsa)
        }
        if (hasCategorisableEntities) {
            for (entity : getCategorisableEntities) entity.extensionClasses(it, 'category', fsa)
        }
    }

    /**
     * Single extension class.
     */
    def private extensionClasses(Entity it, Application app, String classType, IFileSystemAccess fsa) {
        val entityPath = app.getAppSourceLibPath + 'Entity/'
        val entitySuffix = if (app.targets('1.3.5')) '' else 'Entity'
        var classPrefix = name.formatForCodeCapital + classType.formatForCodeCapital
        val repositoryPath = entityPath + 'Repository/'
        var fileName = ''
        if (!isInheriting) {
            val entityPrefix = if (app.targets('1.3.5')) '' else 'Abstract'
            fileName = 'Base/' + entityPrefix + classPrefix + entitySuffix + '.php'
            if (!app.shouldBeSkipped(entityPath + fileName)) {
                if (app.shouldBeMarked(entityPath + fileName)) {
                    fileName = 'Base/' + entityPrefix + classPrefix + entitySuffix + '.generated.php'
                }
                fsa.generateFile(entityPath + fileName, extensionClassBaseFile(it, app, classType))
            }

            fileName = 'Base/' + classPrefix + '.php'
            if (classType != 'closure' && !app.shouldBeSkipped(repositoryPath + fileName)) {
                if (app.shouldBeMarked(repositoryPath + fileName)) {
                    fileName = 'Base/' + classPrefix + '.generated.php'
                }
                fsa.generateFile(repositoryPath + fileName, extensionClassRepositoryBaseFile(it, app, classType))
            }
        }
        if (!app.generateOnlyBaseClasses) {
            fileName = classPrefix + entitySuffix + '.php'
            if (!app.shouldBeSkipped(entityPath + fileName)) {
                if (app.shouldBeMarked(entityPath + fileName)) {
                    fileName = classPrefix + entitySuffix + '.generated.php'
                }
                fsa.generateFile(entityPath + fileName, extensionClassFile(it, app, classType))
            }

            fileName = classPrefix + '.php'
            if (classType != 'closure' && !app.shouldBeSkipped(repositoryPath + fileName)) {
                if (app.shouldBeMarked(repositoryPath + fileName)) {
                    fileName = classPrefix + '.generated.php'
                }
                fsa.generateFile(repositoryPath + fileName, extensionClassRepositoryFile(it, app, classType))
            }
        }
    }

    def private extensionClassBaseFile(Entity it, Application app, String classType) '''
        «fh.phpFileHeader(app)»
        «extensionClassBaseImpl(it, app, classType)»
    '''

    def private extensionClassFile(Entity it, Application app, String classType) '''
        «fh.phpFileHeader(app)»
        «extensionClassImpl(it, app, classType)»
    '''

    def private extensionClassRepositoryBaseFile(Entity it, Application app, String classType) '''
        «fh.phpFileHeader(app)»
        «extensionClassRepositoryBaseImpl(it, app, classType)»
    '''

    def private extensionClassRepositoryFile(Entity it, Application app, String classType) '''
        «fh.phpFileHeader(app)»
        «extensionClassRepositoryImpl(it, app, classType)»
    '''

    def private extensionClassBaseImpl(Entity it, Application app, String classType) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity\Base;

        «ENDIF»
        «extensionClassImports(app, classType)»

        /**
         * «extensionClassDesc(classType)»
         *
         * This is the base «classType.formatForDisplay» class for «name.formatForDisplay» entities.
         */
        «IF !app.targets('1.3.5')»abstract «ENDIF»class «IF !app.targets('1.3.5')»Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»Entity«ELSE»«entityClassName(classType, true)»«ENDIF» extends «extensionBaseClass(app, classType)»
        {
        «IF classType == 'metaData' || classType == 'attribute' || classType == 'category'»
            /**
        «IF classType == 'metaData'»     * @ORM\OneToOne(targetEntity="«IF !app.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", inversedBy="metadata")
        «ELSEIF classType == 'attribute'»     * @ORM\ManyToOne(targetEntity="«IF !app.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", inversedBy="attributes")
        «ELSEIF classType == 'category'»     * @ORM\ManyToOne(targetEntity="«IF !app.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", inversedBy="categories")
        «ENDIF»
             * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKeyFields.head.name.formatForCode»"«IF classType == 'metaData'», unique=true«ENDIF»)
             * @var «IF !app.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»
             */
            protected $entity;

            «extensionEntityAccessors(app)»
        «ENDIF»
        }
    '''

    def private extensionClassImports(Entity it, Application app, String classType) '''
        «IF classType == 'closure'»
            use Gedmo\Tree\Entity\«IF !app.targets('1.3.5')»MappedSuperclass\«ENDIF»AbstractClosure;
        «ELSEIF classType == 'translation'»
            use Gedmo\Translatable\Entity\«IF !app.targets('1.3.5')»MappedSuperclass\«ENDIF»AbstractTranslation;
        «ELSEIF classType == 'logEntry'»
            use Gedmo\Loggable\Entity\«IF !app.targets('1.3.5')»MappedSuperclass\«ENDIF»AbstractLogEntry;
        «ELSEIF classType == 'metaData' || classType == 'attribute' || classType == 'category'»
            use Doctrine\ORM\Mapping as ORM;
            «IF !app.targets('1.3.5')»
                «IF classType == 'metaData'»
                    use Zikula\Core\Doctrine\Entity\AbstractEntityMetadata;
                «ELSEIF classType == 'attribute' || classType == 'category'»
                    use Zikula\Core\Doctrine\Entity\AbstractEntity«classType.toFirstUpper»;
                «ENDIF»
            «ENDIF»
        «ENDIF»
    '''

    def private extensionBaseClass(Entity it, Application app, String classType) '''
        «IF classType == 'closure'»AbstractClosure
        «ELSEIF classType == 'translation'»AbstractTranslation
        «ELSEIF classType == 'logEntry'»AbstractLogEntry
        «ELSEIF classType == 'metaData'»«IF !app.targets('1.3.5')»AbstractEntityMetadata«ELSE»Zikula_Doctrine2_Entity_EntityMetadata«ENDIF»
        «ELSEIF classType == 'attribute' || classType == 'category'»«IF app.targets('1.3.5')»Zikula_Doctrine2_Entity_«ELSE»Abstract«ENDIF»Entity«classType.toFirstUpper»
        «ENDIF»
    '''

    def private extensionEntityAccessors(Entity it, Application app) '''
        /**
         * Get reference to owning entity.
         *
         * @return «IF !app.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»
         */
        public function getEntity()
        {
            return $this->entity;
        }

        /**
         * Set reference to owning entity.
         *
         * @param «IF !app.targets('1.3.5')»\«ENDIF»«entityClassName('', false)» $entity
         */
        public function setEntity(/*«IF !app.targets('1.3.5')»\«ENDIF»«entityClassName('', false)» */$entity)
        {
            $this->entity = $entity;
        }
    '''

    def private extensionClassImpl(Entity it, Application app, String classType) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity;

            use «app.appNamespace»\Entity\«IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»Entity«ELSE»Base\Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»Entity«ENDIF» as Base«IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»«ENDIF»Entity;

        «ENDIF»
        use Doctrine\ORM\Mapping as ORM;

        /**
         * «extensionClassDesc(classType)»
         *
         * This is the concrete «classType.formatForDisplay» class for «name.formatForDisplay» entities.
        «IF classType == 'closure'»
        «ELSEIF classType == 'translation'»
             *
             * @ORM\Entity(repositoryClass="«repositoryClass(app, classType)»")
             * @ORM\Table(name="«fullEntityTableName»_translation",
             *     indexes={
             *         @ORM\Index(name="translations_lookup_idx", columns={
             *             "locale", "object_class", "foreign_key"
             *         })
             *     }«/*,commented out because the length of these four fields * 3 is more than 1000 bytes with UTF-8 (requiring 3 bytes per char)
             *     uniqueConstraints={
             *         @ORM\UniqueConstraint(name="lookup_unique_idx", columns={
             *             "locale", "object_class", "field", "foreign_key"
             *         })
             *     }*/»
             * )
        «ELSEIF classType == 'logEntry'»
             *
             * @ORM\Entity(repositoryClass="«repositoryClass(app, classType)»")
             * @ORM\Table(name="«fullEntityTableName»_log_entry",
             *     indexes={
             *         @ORM\Index(name="log_class_lookup_idx", columns={"object_class"}),
             *         @ORM\Index(name="log_date_lookup_idx", columns={"logged_at"}),
             *         @ORM\Index(name="log_user_lookup_idx", columns={"username"})
             *     }
             * )
        «ELSEIF classType == 'metaData' || classType == 'attribute' || classType == 'category'»
             * @ORM\Entity(repositoryClass="«IF !app.targets('1.3.5')»\«ENDIF»«repositoryClass(app, classType)»")
                «IF classType == 'metaData'»
                 * @ORM\Table(name="«fullEntityTableName»_metadata")
                «ELSEIF classType == 'attribute'»
                 * @ORM\Table(name="«fullEntityTableName»_attribute",
                 *     uniqueConstraints={
                 *         @ORM\UniqueConstraint(name="cat_unq", columns={"name", "entityId"})
                 *     }
                 * )
                «ELSEIF classType == 'category'»
                 * @ORM\Table(name="«fullEntityTableName»_category",
                 *     uniqueConstraints={
                 *         @ORM\UniqueConstraint(name="cat_unq", columns={"registryId", "categoryId", "entityId"})
                 *     }
                 * )
                «ENDIF»
        «ENDIF»
         */
        «IF app.targets('1.3.5')»
        class «entityClassName(classType, false)» extends «IF isInheriting»«parentType.entityClassName(classType, false)»«ELSE»«entityClassName(classType, true)»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital»«classType.formatForCodeCapital»Entity extends Base«IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»«ENDIF»Entity
        «ENDIF»
        {
            // feel free to add your own methods here
        }
    '''

    def private repositoryClass(Entity it, Application app, String classType) {
        (if (app.targets('1.3.5')) app.appName + '_Entity_Repository_' else app.appNamespace + '\\Entity\\Repository\\') + name.formatForCodeCapital + classType.formatForCodeCapital
    }

    def private extensionClassDesc(Entity it, String classType) '''
        «IF classType == 'closure'»
            Entity extension domain class storing «name.formatForDisplay» tree closures.
        «ELSEIF classType == 'translation'»
            Entity extension domain class storing «name.formatForDisplay» translations.
        «ELSEIF classType == 'logEntry'»
            Entity extension domain class storing «name.formatForDisplay» log entries.
        «ELSEIF classType == 'metaData'»
            Entity extension domain class storing «name.formatForDisplay» meta data.
        «ELSEIF classType == 'attribute'»
            Entity extension domain class storing «name.formatForDisplay» attributes.
        «ELSEIF classType == 'category'»
            Entity extension domain class storing «name.formatForDisplay» categories.
        «ENDIF»
    '''


    def private extensionClassRepositoryBaseImpl(Entity it, Application app, String classType) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity\Repository\Base;

        «ENDIF»
        «IF classType == 'translation'»
            use Gedmo\Translatable\Entity\Repository\TranslationRepository;
        «ELSEIF classType == 'logEntry'»
            use Gedmo\Loggable\Entity\Repository\LogEntryRepository;
        «ELSE»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «name.formatForDisplay» «classType.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Repository_Base_«name.formatForCodeCapital»«classType.formatForCodeCapital» extends «IF classType == 'translation'»Translation«ELSEIF classType == 'logEntry'»LogEntry«ELSE»Entity«ENDIF»Repository
        «ELSE»
        class «name.formatForCodeCapital»«classType.formatForCodeCapital» extends «IF classType == 'translation'»Translation«ELSEIF classType == 'logEntry'»LogEntry«ELSE»Entity«ENDIF»Repository
        «ENDIF»
        {
        }
    '''

    def private extensionClassRepositoryImpl(Entity it, Application app, String classType) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity\Repository;

            use «app.appNamespace»\Entity\Repository\«IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»«ELSE»Base\«name.formatForCodeCapital»«classType.formatForCodeCapital»«ENDIF» as Base«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»«classType.formatForCodeCapital»;

        «ENDIF»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «name.formatForDisplay» «classType.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Repository_«name.formatForCodeCapital»«classType.formatForCodeCapital» extends «IF isInheriting»«app.appName»_Entity_Repository_«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»«ELSE»«app.appName»_Entity_Repository_Base_«name.formatForCodeCapital»«classType.formatForCodeCapital»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital»«classType.formatForCodeCapital» extends Base«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»«classType.formatForCodeCapital»
        «ENDIF»
        {
            // feel free to add your own methods here
        }
    '''
}
