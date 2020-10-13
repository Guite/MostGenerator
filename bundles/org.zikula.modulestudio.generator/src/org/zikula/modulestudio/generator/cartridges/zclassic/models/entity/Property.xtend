package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
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
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.ArrayType

class Property {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    FileHelper fh
    ExtensionManager extMan
    ValidationConstraints thVal = new ValidationConstraints

    new(Application it, ExtensionManager extMan) {
        fh = new FileHelper(it)
        this.extMan = extMan
    }

    def dispatch persistentProperty(DerivedField it) {
        persistentProperty(name.formatForCode, fieldTypeAsString(true), fieldTypeAsString(false), '')
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
         *
         * @var array
         */
        protected $«name.formatForCode»Meta = [];

        «persistentProperty(name.formatForCode + 'FileName', fieldTypeAsString(true), fieldTypeAsString(false), '')»
        /**
         * Full «name.formatForDisplay» path as url.
         *
         * @Assert\Type(type="string")
         «/* * @Assert\Url() disabled due to problems with space chars in file names
         */»*
         * @var string
         */
        protected $«name.formatForCode»Url = '';

        /**
         * «name.formatForDisplayCapital» file object.
         *
        «thVal.uploadFileAnnotations(it)»
         *
         * @var File
         */
        protected $«name.formatForCode» = null;
        «/* this last line is on purpose */»
    '''

    def dispatch persistentProperty(ArrayField it) {
        persistentProperty(name.formatForCode, fieldTypeAsString(true), fieldTypeAsString(false), ' = []')
    }

    /**
     * Note we use protected and not private to let the developer change things in
     * concrete implementations
     */
    def persistentProperty(DerivedField it, String name, String typePhp, String typeDoctrine, String init) {
        persistentProperty(name, typePhp, typeDoctrine, init, 'protected')
    }

    def persistentProperty(DerivedField it, String name, String typePhp, String typeDoctrine, String init, String modifier) '''
        /**
         «IF null !== documentation && !documentation.empty»
          * «documentation»«IF !documentation.endsWith('.')».«ENDIF»
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
             * @ORM\Column(«IF null !== dbName && !dbName.empty»name="«dbName.formatForCode»", «ELSEIF it instanceof UploadField»name="«it.name.formatForCode»", «ENDIF»«persistentPropertyImpl(typeDoctrine.toLowerCase)»«IF unique», unique=true«ENDIF»«IF nullable», nullable=true«ENDIF»)
             «ENDIF»
            «persistentPropertyAdditions»
        «ENDIF»
        «thVal.fieldAnnotations(it)»
         *
         * @var «IF typePhp == 'DateTime'»\DateTime«IF (it as DatetimeField).immutable»Immutable«ENDIF»«ELSE»«typePhp»«ENDIF»
         */
        «modifier» $«name.formatForCode»«IF !init.empty»«init»«ELSE»«IF !(it instanceof DatetimeField)» = «defaultFieldData»«ENDIF»«ENDIF»;
        «/* this last line is on purpose */»
    '''

    def private persistentPropertyImpl(DerivedField it, String type) {
        switch it {
            NumberField: '''type="«type»"«IF numberType == NumberFieldType.DECIMAL», precision=«it.length», scale=«it.scale»«ENDIF»'''
            TextField: '''type="«type»", length=«it.length»'''
            StringField:
                '''«IF ((null !== entity && entity.application.targets('3.0')) || (null !== varContainer && varContainer.application.targets('3.0'))) && role == StringRole.DATE_INTERVAL»type="dateinterval"«ELSE»«/*type="«type»", */»length=«it.length»«ENDIF»'''
            EmailField:
                '''«/*type="«type»", */»length=«it.length»'''
            UrlField:
                '''«/*type="«type»", */»length=«it.length»'''
            ArrayField:
                '''type="«IF entity.application.targets('3.0') && ArrayType.JSON_ARRAY == arrayType»json«ELSE»«arrayType.literal.toLowerCase»«ENDIF»"«/*», length=«it.length*/»'''
            UploadField:
                '''«/*type="«type»", */»length=«it.length»'''
            ListField:
                '''«/*type="«type»", */»length=«it.length»'''
            DatetimeField:
                '''type="«/*utc*/»«type»«IF ((null !== entity && entity.application.targets('3.0')) || (null !== varContainer && varContainer.application.targets('3.0'))) && immutable»_immutable«ENDIF»"'''
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
                if (it instanceof IntegerField && (it as IntegerField).version) '1' 
                else if (null !== it.defaultValue && it.defaultValue.length > 0) it.defaultValue
                else if (it.nullable) 'null'
                else '0'
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
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString(true), false, nullable, application.targets('3.0'))»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString(true), false, nullable, application.targets('3.0'), '', '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(DerivedField it) '''
        «fieldAccessorDefault»
    '''

    def dispatch fieldAccessor(IntegerField it) '''
        «IF isIndexByField/* || (null !== aggregateFor && !aggregateFor.empty*/»
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString(true), false, nullable, application.targets('3.0'))»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString(true), false, nullable || primaryKey, application.targets('3.0'), '', '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(UploadField it) '''

        «IF !application.targets('3.0')»
            /**
             * Returns the «name.formatForDisplay».
             *
             * @return File
             */
        «ENDIF»
        public function get«name.formatForCodeCapital»()«IF application.targets('3.0')»: ?File«ENDIF»
        {
            if (null !== $this->«name.formatForCode») {
                return $this->«name.formatForCode»;
            }

            $fileName = $this->«name.formatForCode»FileName;
            if (!empty($fileName) && !$this->_uploadBasePath«IF application.targets('3.0')»Relative«ENDIF») {
                throw new RuntimeException('Invalid upload base path in ' . static::class . '#get«name.formatForCodeCapital»().');
            }

            $filePath = $this->_uploadBasePath«IF application.targets('3.0')»Absolute«ENDIF» . '«subFolderPathSegment»/' . $fileName;
            if (!empty($fileName) && file_exists($filePath)) {
                $this->«name.formatForCode» = new File($filePath);
                «IF application.targets('3.0')»
                    $this->set«name.formatForCodeCapital»Url($this->_uploadBaseUrl . '/' . $this->_uploadBasePathRelative . '«subFolderPathSegment»/' . $fileName);
                «ELSE»
                    $this->set«name.formatForCodeCapital»Url($this->_uploadBaseUrl . '/' . $filePath);
                «ENDIF»
            } else {
                $this->set«name.formatForCodeCapital»FileName('');
                $this->set«name.formatForCodeCapital»Url('');«/* disabled to avoid persisting empty meta array after fresh upload
                $this->set«name.formatForCodeCapital»Meta([]);*/»
            }

            return $this->«name.formatForCode»;
        }

        /**
         * Sets the «name.formatForDisplay».
         «IF !application.targets('3.0')»
         *
         * @return void
         «ENDIF»
         */
        public function set«name.formatForCodeCapital»(?File $«name.formatForCode» = null)«IF application.targets('3.0')»: void«ENDIF»
        {
            if (null === $this->«name.formatForCode» && null === $«name.formatForCode») {
                return;
            }
            if (
                null !== $this->«name.formatForCode»
                && null !== $«name.formatForCode»
                && $this->«name.formatForCode» instanceof File
                && $this->«name.formatForCode»->getRealPath() === $«name.formatForCode»->getRealPath()
            ) {
                return;
            }
            «fh.triggerPropertyChangeListeners(it, name)»
            «IF nullable»
                $this->«name.formatForCode» = $«name.formatForCode»;
            «ELSE»
                $this->«name.formatForCode» = «IF application.targets('3.0')»$«name.formatForCode» ?? ''«ELSE»isset($«name.formatForCode») ? $«name.formatForCode» : ''«ENDIF»;
            «ENDIF»

            if (null === $this->«name.formatForCode» || '' === $this->«name.formatForCode») {
                $this->set«name.formatForCodeCapital»FileName('');
                $this->set«name.formatForCodeCapital»Url('');
                $this->set«name.formatForCodeCapital»Meta([]);
            } else {
                $this->set«name.formatForCodeCapital»FileName($this->«name.formatForCode»->getFilename());
            }
        }
        «IF application.targets('3.0')»
            «fh.getterAndSetterMethods(it, name.formatForCode + 'FileName', 'string', false, true, true, '', '')»
            «fh.getterAndSetterMethods(it, name.formatForCode + 'Url', 'string', false, true, true, '', '')»
            «fh.getterAndSetterMethods(it, name.formatForCode + 'Meta', 'array', true, false, true, '[]', '')»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode + 'FileName', 'string', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, name.formatForCode + 'Url', 'string', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, name.formatForCode + 'Meta', 'array', true, true, true, '[]', '')»
        «ENDIF»
    '''
}
