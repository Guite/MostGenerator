package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.EntityTimestampableType
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.eclipse.xtext.generator.IFileSystemAccess

class Extensions {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def imports(Entity it) '''
        use Gedmo\Mapping\Annotation as Gedmo;
    '''

    /**
     * Class annotations.
     */
    def classExtensions(Entity it) '''
        «IF loggable»
         * @Gedmo\Loggable(logEntryClass="«implClassModel('', 'logEntry')»")
        «ENDIF»
        «IF hasTranslatableFields»
         * @Gedmo\TranslationEntity(class="«implClassModel('', 'translation')»")
        «ENDIF»
        «IF tree != EntityTreeType::NONE»
         * @Gedmo\Tree(type="«tree.asConstant»")
            «IF tree == EntityTreeType::CLOSURE»
             * @Gedmo\TreeClosure(class="«implClassModel('', 'closure')»")
            «ENDIF»
        «ENDIF»
    '''

    /**
     * Column annotations.
     */
    def private columnExtensionsDefault(DerivedField it) '''
        «IF translatable» * @Gedmo\Translatable
        «ENDIF»
        «IF sluggablePosition > 0» * @Gedmo\Sluggable(slugField="slug", position=«sluggablePosition»)
        «ENDIF»
        «IF sortableGroup» * @Gedmo\SortableGroup
        «ENDIF»
    '''
    def columnExtensions(DerivedField it) {
        switch (it) {
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

    def private timestampableDetails(AbstractDateField it) '''
        «IF timestampable == EntityTimestampableType::CHANGE»
            field="«timestampableChangeTriggerField.formatForCode»"«IF timestampableChangeTriggerValue != null && timestampableChangeTriggerValue != ''», value="«timestampableChangeTriggerValue.formatForCode»"«ENDIF»
        «ENDIF»
    '''

    /**
     * Additional column definitions.
     */
    def additionalProperties(Entity it) '''
        «IF geographical»

            /**
             * The coordinate's latitude part.
             *
             * @ORM\Column(type="decimal", precision=10, scale=7)
             * @var decimal $latitude.
             */
            protected $latitude = 0.00;

            /**
             * The coordinate's longitude part.
             *
             * @ORM\Column(type="decimal", precision=10, scale=7)
             * @var decimal $longitude.
             */
            protected $longitude = 0.00;
        «ENDIF»
        «IF hasSluggableFields»

            /**
             «IF hasTranslatableSlug»
                 * @Gedmo\Translatable
             «ENDIF»
             * @Gedmo\Slug(style="«slugStyle.asConstant»", separator="«slugSeparator»"«IF !slugUnique», unique=false«ENDIF»«IF !slugUpdatable», updatable=false«ENDIF»)
             * @ORM\Column(type="string", length=«slugLength»«IF !slugUnique», unique=false«ENDIF»)
             * @var string $slug.
             */
            protected $slug;
        «ENDIF»
        «IF hasTranslatableFields»

            /**
             * Field for storing the locale of this entity.
             * Overrides the locale set in translationListener (as pointed out in https://github.com/l3pp4rd/DoctrineExtensions/issues/130#issuecomment-1790206 ).
             *
             * @Gedmo\Locale«/*the same as @Gedmo\Language*/»
             * @var string $locale.
             */
            protected $locale;
        «ENDIF»
        «IF tree != EntityTreeType::NONE»

            /**
             * @Gedmo\TreeLeft
             * @ORM\Column(type="integer")
             * @var integer $lft.
             */
            protected $lft;

            /**
             * @Gedmo\TreeLevel
             * @ORM\Column(type="integer")
             * @var integer $lvl.
             */
            protected $lvl;

            /**
             * @Gedmo\TreeRight
             * @ORM\Column(type="integer")
             * @var integer $rgt.
             */
            protected $rgt;

            /**
             * @Gedmo\TreeRoot
             * @ORM\Column(type="integer", nullable=true)
             * @var integer $root.
             */
            protected $root;

            /**
             * Bidirectional - Many children [«name.formatForDisplay»] are linked by one parent [«name.formatForDisplay»] (OWNING SIDE).
             *
             * @Gedmo\TreeParent
             * @ORM\ManyToOne(targetEntity="«implClassModelEntity»", inversedBy="children")
             * @ORM\JoinColumn(name="parent_id", referencedColumnName="«getPrimaryKeyFields.head.name.formatForDisplay»", onDelete="SET NULL")
             * @var «implClassModelEntity» $parent.
             */
            protected $parent;

            /**
             * Bidirectional - One parent [«name.formatForDisplay»] has many children [«name.formatForDisplay»] (INVERSE SIDE).
             *
             * @ORM\OneToMany(targetEntity="«implClassModelEntity»", mappedBy="parent")
             * @ORM\OrderBy({"lft" = "ASC"})
             * @var «implClassModelEntity» $children.
             */
            protected $children;
        «ENDIF»
        «IF metaData»

            /**
             * @ORM\OneToOne(targetEntity="«implClassModel('', 'metaData')»", 
             *               mappedBy="entity", cascade={"all"},
             *               orphanRemoval=true)
             * @var «implClassModel('', 'metaData')»
             */
            protected $metadata;
        «ENDIF»
        «IF attributable»

            /**
             * @ORM\OneToMany(targetEntity="«implClassModel('', 'attribute')»", 
             *                mappedBy="entity", cascade={"all"}, 
             *                orphanRemoval=true, indexBy="name")
             * @var «implClassModel('', 'attribute')»
             */
            protected $attributes;
        «ENDIF»
        «IF categorisable»

            /**
             * @ORM\OneToMany(targetEntity="«implClassModel('', 'category')»", 
             *                mappedBy="entity", cascade={"all"}, 
             *                orphanRemoval=true, indexBy="categoryRegistryId")
             * @var «implClassModel('', 'category')»
             */
            protected $categories;
        «ENDIF»
        «IF standardFields»

            /**
             * @ORM\Column(type="integer")
             * @ZK\StandardFields(type="userid", on="create")
             * @var integer $createdUserId.
             */
            protected $createdUserId;

            /**
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
        «IF hasSluggableFields»
            «fh.getterMethod(it, 'slug', 'string', false)»
            «/*fh.getterAndSetterMethods(it, 'slug', 'string', false, false, '', '')*/»
        «ENDIF»
        «IF tree != EntityTreeType::NONE»
            «fh.getterAndSetterMethods(it, 'lft', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'lvl', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'rgt', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'root', 'integer', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'parent', implClassModelEntity, false, true, 'null', '')»
            «fh.getterAndSetterMethods(it, 'children', 'array', true, false, '', '')»
        «ENDIF»
        «IF hasTranslatableFields»
            «fh.getterAndSetterMethods(it, 'locale', 'string', false, false, '', '')»
        «ENDIF»
        «IF metaData»
            «fh.getterAndSetterMethods(it, 'metadata', implClassModel('', 'metaData'), false, true, 'null', '')»
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
                        $this->attributes[$name] = new «implClassModel('', 'attribute')»($name, $value, $this);
                    }
                }
        «ENDIF»
        «IF categorisable»
            «fh.getterAndSetterMethods(it, 'categories', 'array', true, false, '', '')»
        «ENDIF»
        «IF standardFields»
            «fh.getterAndSetterMethods(it, 'createdUserId', 'integer', true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'updatedUserId', 'integer', true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'createdDate', 'datetime', true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'updatedDate', 'datetime', true, false, '', '')»
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
            for (entity : getTreeEntities.filter(e|e.tree == EntityTreeType::CLOSURE)) entity.extensionClasses(it, 'closure', fsa)
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
        if (!isInheriting) {
            fsa.generateFile(getAppSourcePath(app.appName) + baseClassModel('', classType).asFile, extensionClassBaseFile(it, app, classType))
            if (classType != 'closure') {
                fsa.generateFile(getAppSourcePath(app.appName) + baseClassModel('repository', classType).asFile, extensionClassRepositoryBaseFile(it, app, classType))
            }
        }
        fsa.generateFile(getAppSourcePath(app.appName) + implClassModel('', classType).asFile, extensionClassFile(it, app, classType))
        if (classType != 'closure') {
            fsa.generateFile(getAppSourcePath(app.appName) + implClassModel('repository', classType).asFile, extensionClassRepositoryFile(it, app, classType))
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
        «IF classType == 'closure'»
            use Gedmo\Tree\Entity\AbstractClosure;
        «ELSEIF classType == 'translation'»
            use Gedmo\Translatable\Entity\AbstractTranslation;
        «ELSEIF classType == 'logEntry'»
            use Gedmo\Loggable\Entity\AbstractLogEntry;
        «ELSEIF classType == 'metaData' || classType == 'attribute' || classType == 'category'»
            use Doctrine\ORM\Mapping as ORM;
        «ENDIF»

        /**
         * «extensionClassDesc(classType)»
         *
         * This is the base «classType.formatForDisplay» class for «name.formatForDisplay» entities.
         */
        «IF classType == 'closure'»
        class «baseClassModel('', classType)» extends AbstractClosure
        «ELSEIF classType == 'translation'»
        class «baseClassModel('', classType)» extends AbstractTranslation
        «ELSEIF classType == 'logEntry'»
        class «baseClassModel('', classType)» extends AbstractLogEntry
        «ELSEIF classType == 'metaData'»
        class «baseClassModel('', classType)» extends Zikula_Doctrine2_Entity_EntityMetadata
        «ELSEIF classType == 'attribute'»
        class «baseClassModel('', classType)» extends Zikula_Doctrine2_Entity_EntityAttribute
        «ELSEIF classType == 'category'»
        class «baseClassModel('', classType)» extends Zikula_Doctrine2_Entity_EntityCategory
        «ENDIF»
        {
        «IF classType == 'metaData' || classType == 'attribute' || classType == 'category'»
            /**
        «IF classType == 'metaData'»     * @ORM\OneToOne(targetEntity="«implClassModelEntity»", inversedBy="metadata")
        «ELSEIF classType == 'attribute'»     * @ORM\ManyToOne(targetEntity="«implClassModelEntity»", inversedBy="attributes")
        «ELSEIF classType == 'category'»     * @ORM\ManyToOne(targetEntity="«implClassModelEntity»", inversedBy="categories")
        «ENDIF»
             * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKeyFields.head.name.formatForCode»"«IF classType == 'metaData'», unique=true«ENDIF»)
             * @var «implClassModelEntity»
             */
            protected $entity;

            /**
             * Get reference to owning entity.
             *
             * @return «implClassModelEntity»
             */
            public function getEntity()
            {
                return $this->entity;
            }

            /**
             * Set reference to owning entity.
             *
             * @param «implClassModelEntity» $entity
             */
            public function setEntity(/*«implClassModelEntity» */$entity)
            {
                $this->entity = $entity;
            }
        «ENDIF»
        }
    '''

    def private extensionClassImpl(Entity it, Application app, String classType) '''
        use Doctrine\ORM\Mapping as ORM;

        /**
         * «extensionClassDesc(classType)»
         *
         * This is the concrete «classType.formatForDisplay» class for «name.formatForDisplay» entities.
        «IF classType == 'closure'»
        «ELSEIF classType == 'translation'»
             *
             * @ORM\Entity(repositoryClass="«baseClassModel('repository', classType)»")
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
             * @ORM\Entity(repositoryClass="«baseClassModel('repository', classType)»")
             * @ORM\Table(name="«fullEntityTableName»_log_entry",
             *     indexes={
             *         @ORM\Index(name="log_class_lookup_idx", columns={"object_class"}),
             *         @ORM\Index(name="log_date_lookup_idx", columns={"logged_at"}),
             *         @ORM\Index(name="log_user_lookup_idx", columns={"username"})
             *     }
             * )
        «ELSEIF classType == 'metaData' || classType == 'attribute' || classType == 'category'»
             * @ORM\Entity(repositoryClass="«baseClassModel('repository', classType)»")
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
        class «implClassModel('', classType)» extends «IF isInheriting»«parentType.implClassModel('', classType)»«ELSE»«baseClassModel('', classType)»«ENDIF»
        {
            // feel free to add your own methods here
        }
    '''


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
        class «baseClassModel('repository', classType)» extends «IF classType == 'translation'»Translation«ELSEIF classType == 'logEntry'»LogEntry«ELSE»Entity«ENDIF»Repository
        {
        }
    '''

    def private extensionClassRepositoryImpl(Entity it, Application app, String classType) '''
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «name.formatForDisplay» «classType.formatForDisplay» entities.
         */
        class «implClassModel('repository', classType)» extends «IF isInheriting»«parentType.implClassModel('repository', classType)»«ELSE»«baseClassModel('repository', classType)»«ENDIF»
        {
            // feel free to add your own methods here
        }
    '''
}
