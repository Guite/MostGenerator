package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityIdentifierStrategy
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions

class Property {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions

    FileHelper fh = new FileHelper
    ExtensionManager extMan
    ValidationConstraints thVal = new ValidationConstraints

    new(ExtensionManager extMan) {
        this.extMan = extMan
    }

    def dispatch persistentProperty(DerivedField it) {
        persistentProperty(name.formatForCode, fieldTypeAsString, '')
    }

    def dispatch persistentProperty(UploadField it) '''
        /**
         * «name.formatForDisplayCapital» meta data array.
         *
         «IF null !== entity»
         * @ORM\Column(type="array")
         «IF translatable»
          * @Gedmo\Translatable
         «ENDIF»
         «ENDIF»
         * @Assert\Type(type="array")
         * @var array $«name.formatForCode»Meta
         */
        protected $«name.formatForCode»Meta = [];

        «persistentProperty(name.formatForCode + 'FileName', fieldTypeAsString, '')»
        /**
         * Full «name.formatForDisplay» path as url.
         *
         * @Assert\Type(type="string")
         «/* * @Assert\Url() disabled due to problems with space chars in file names
         */»* @var string $«name.formatForCode»Url
         */
        protected $«name.formatForCode»Url = '';

        /**
         * «name.formatForDisplayCapital» file object.
         *
        «thVal.uploadFileAnnotations(it)»
         * @var File $«name.formatForCode»
         */
        protected $«name.formatForCode» = null;
        «/* this last line is on purpose */»
    '''

    def dispatch persistentProperty(ArrayField it) {
        persistentProperty(name.formatForCode, fieldTypeAsString, ' = []')
    }

    /**
     * Note we use protected and not private to let the dev change things in
     * concrete implementations
     */
    def persistentProperty(DerivedField it, String name, String type, String init) {
        persistentProperty(name, type, init, 'protected')
    }

    def persistentProperty(DerivedField it, String name, String type, String init, String modifier) '''
        /**
         «IF null !== documentation && !documentation.empty»
          * «documentation»
          *
         «ENDIF»
        «IF null !== entity»
             «IF primaryKey»
                 * @ORM\Id
                 «IF entity instanceof Entity && (entity as Entity).identifierStrategy != EntityIdentifierStrategy.NONE»
                     * @ORM\GeneratedValue(strategy="«(entity as Entity).identifierStrategy.literal»")
                 «ENDIF»
             «ENDIF»
            «IF null !== extMan»«extMan.columnAnnotations(it)»«ENDIF»
             «IF !(it instanceof UserField)»«/* user fields are implemented as join to UserEntity, see persistentPropertyAdditions */»
             * @ORM\Column(«IF null !== dbName && !dbName.empty»name="«dbName.formatForCode»", «ELSEIF it instanceof UploadField»name="«it.name.formatForCode»", «ENDIF»«persistentPropertyImpl(type.toLowerCase)»«IF unique», unique=true«ENDIF»«IF nullable», nullable=true«ENDIF»)
             «ENDIF»
            «persistentPropertyAdditions»
        «ENDIF»
        «thVal.fieldAnnotations(it)»
         * @var «IF type == 'bigint' || type == 'smallint'»integer«ELSEIF type == 'datetime'»\DateTime«IF (it as DatetimeField).immutable»Immutable«ENDIF»«ELSE»«type»«ENDIF» $«name.formatForCode»
         */
        «modifier» $«name.formatForCode»«IF !init.empty»«init»«ELSE»«IF !(it instanceof DatetimeField)» = «defaultFieldData»«ENDIF»«ENDIF»;
        «/* this last line is on purpose */»
    '''

    def private persistentPropertyImpl(DerivedField it, String type) {
        switch it {
            NumberField: '''type="«type»"«IF numberType == NumberFieldType.DECIMAL», precision=«it.length», scale=«it.scale»«ENDIF»'''
            TextField: '''type="«type»", length=«it.length»'''
            StringField:
                /* disabled until DBAL 2.6
                if (role == StringRole.DATE_INTERVAL) '''type="dateinterval", length=«it.length»'''
                else */'''«/*type="«type»", */»length=«it.length»'''
            EmailField:
                '''«/*type="«type»", */»length=«it.length»'''
            UrlField:
                '''«/*type="«type»", */»length=«it.length»'''
            ArrayField:
                '''type="«/* disabled until DBAL 2.6 IF arrayType == ArrayType.JSON_ARRAY»json«ELSE*/»«arrayType.literal.toLowerCase»«/*ENDIF*/»"«/*», length=«it.length*/»'''
            UploadField:
                '''«/*type="«type»", */»length=«it.length»'''
            ListField:
                '''«/*type="«type»", */»length=«it.length»'''
            DatetimeField:
                '''type="«/*utc*/»«type»«/* disabled until DBAL 2.6 IF immutable»_immutable«ENDIF*/»"'''
            default: '''type="«type»"'''
        }
    }

    def private persistentPropertyAdditions(DerivedField it) {
        switch it {
            IntegerField:
                if (it.version && entity instanceof Entity && (entity as Entity).hasOptimisticLock) '''
                    «''» * @ORM\Version
                '''
            UserField:
                '''
                    «' '»* @ORM\ManyToOne(targetEntity="Zikula\UsersModule\Entity\UserEntity")
                    «' '»* @ORM\JoinColumn(referencedColumnName="uid"«IF nullable», nullable=true«ENDIF»)
                '''
        }
    }

    def static defaultFieldData(Field it) {
        switch it {
            BooleanField:
                if (it.defaultValue == 'true') 'true' else 'false'
            AbstractIntegerField:
                if (it instanceof IntegerField && (it as IntegerField).version) '1' else if (null !== it.defaultValue && it.defaultValue.length > 0) it.defaultValue else if (it instanceof UserField) 'null' else '0'
            NumberField:
                if (null !== it.defaultValue && it.defaultValue.length > 0) it.defaultValue else '0.00'
            ArrayField: '[]'
            UploadField: 'null'
            ObjectField: 'null'
            ListField:
                if (!items.filter[^default].empty) {
                    if (multiple) '\'' + items.filter[^default].map[listItemValue].join('###') + '\''
                    else '\'' + items.filter[^default].head.listItemValue + '\''
                } else if (nullable) 'null' else '\'\''
            AbstractStringField: if (null !== it.defaultValue && it.defaultValue.length > 0) '\'' + it.defaultValue + '\'' else '\'\''
            default: '\'\''
        }
    }

    def static private listItemValue(ListFieldItem it) '''«IF null !== value»«value.replace("'", "")»«ELSE»«name/*.formatForCode.replace("'", "")*/»«ENDIF»'''

    def private fieldAccessorDefault(DerivedField it) '''
        «IF isIndexByField»
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString, false)»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString, false, nullable, false, '', '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(DerivedField it) '''
        «fieldAccessorDefault»
    '''

    def dispatch fieldAccessor(IntegerField it) '''
        «IF isIndexByField/* || (null !== aggregateFor && !aggregateFor.empty*/»
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString, false)»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString, false, nullable, false, '', '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(UploadField it) '''
        /**
         * Returns the «name.formatForDisplay».
         *
         * @return File
         */
        public function get«name.formatForCodeCapital»()
        {
            if (null !== $this->«name.formatForCode») {
                return $this->«name.formatForCode»;
            }

            $fileName = $this->«name.formatForCode»FileName;
            if (!empty($fileName) && !$this->_uploadBasePath) {
                throw new \RuntimeException('Invalid upload base path in ' . get_class($this) . '#get«name.formatForCodeCapital»().');
            }

            $filePath = $this->_uploadBasePath . '«subFolderPathSegment»/' . $fileName;
            if (!empty($fileName) && file_exists($filePath)) {
                $this->«name.formatForCode» = new File($filePath);
                $this->set«name.formatForCodeCapital»Url($this->_uploadBaseUrl . '/' . $filePath);
            } else {
                $this->set«name.formatForCodeCapital»FileName('');
                $this->set«name.formatForCodeCapital»Url('');
                $this->set«name.formatForCodeCapital»Meta([]);
            }

            return $this->«name.formatForCode»;
        }

        /**
         * Sets the «name.formatForDisplay».
         *
         * @param File|null $«name.formatForCode»
         *
         * @return void
         */
        public function set«name.formatForCodeCapital»(«/* disabled due to #1206 IF !nullable»File «ENDIF*/»$«name.formatForCode»)
        {
            if (null === $this->«name.formatForCode» && null === $«name.formatForCode») {
                return;
            }
            if (null !== $this->«name.formatForCode» && null !== $«name.formatForCode» && $this->«name.formatForCode»->getRealPath() === $«name.formatForCode»->getRealPath()) {
                return;
            }
            «fh.triggerPropertyChangeListeners(it, name)»
            «IF nullable»
                $this->«name.formatForCode» = $«name.formatForCode»;
            «ELSE»
                $this->«name.formatForCode» = isset($«name.formatForCode») ? $«name.formatForCode» : '';
            «ENDIF»

            if (null === $this->«name.formatForCode» || '' == $this->«name.formatForCode») {
                $this->set«name.formatForCodeCapital»FileName('');
                $this->set«name.formatForCodeCapital»Url('');
                $this->set«name.formatForCodeCapital»Meta([]);
            } else {
                $this->set«name.formatForCodeCapital»FileName($this->«name.formatForCode»->getFilename());
            }
        }

        «fh.getterAndSetterMethods(it, name.formatForCode + 'FileName', 'string', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'Url', 'string', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'Meta', 'array', true, true, true, '[]', '')»
    '''
}
