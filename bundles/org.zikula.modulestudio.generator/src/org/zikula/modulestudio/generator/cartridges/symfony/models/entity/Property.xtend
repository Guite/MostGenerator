package org.zikula.modulestudio.generator.cartridges.symfony.models.entity

import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.NumberRole
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.cartridges.symfony.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.Sluggable
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class Property {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    FileHelper fh
    ExtensionManager extMan
    ValidationConstraints thVal = new ValidationConstraints

    new(Application it, ExtensionManager extMan) {
        fh = new FileHelper(it)
        this.extMan = extMan
    }

    def dispatch persistentProperty(Field it) {
        persistentProperty(name.formatForCode, fieldTypeAsString(true), fieldTypeAsString(false), '')
    }

    def dispatch persistentProperty(ArrayField it) {
        persistentProperty(name.formatForCode, fieldTypeAsString(true), fieldTypeAsString(false), ' = []')
    }

    def dispatch persistentProperty(UploadField it) '''
         #[Vich\UploadableField('«mappingName»', '«upProp».name', '«upProp».size', '«upProp».mimeType', '«upProp».originalName', '«upProp».dimensions')]
        «/* TODO wait for next release of VichUploaderBundle
        IF mandatory»
            #[VichAssert\FileRequired(target: '«name.formatForCode»')]
        «ENDIF*/»«thVal.fieldAnnotationsForUpload(it)»
        protected ?File $«name.formatForCode»File = null;

        #[ORM\Embedded(class: EmbeddedFile::class)]
        «persistentProperty(name.formatForCode, 'EmbeddedFile', '', ' = null')»
    '''

    def private upProp(UploadField it) '''«name.formatForCode»'''

    /**
     * Note we use protected and not private to let the developer change things in
     * concrete implementations
     */
    def persistentProperty(Field it, String name, String typePhp, String typeDoctrine, String init) {
        persistentProperty(name, typePhp, typeDoctrine, init, 'protected')
    }

    // NOTE: DateTime fields are always treated as nullable (for PHP, not for Doctrine) enforcing a default value
    // in order to to avoid "$foo must not be accessed before initialization"
    def persistentProperty(Field it, String name, String typePhp, String typeDoctrine, String init, String modifier) '''
        «IF null !== documentation && !documentation.empty»
            /**
             * «documentation»«IF !documentation.endsWith('.')».«ENDIF»
             */
        «ENDIF»
        «IF null !== entity»
            «IF primaryKey»
                #[ORM\Id]
                #[ORM\GeneratedValue(strategy: 'CUSTOM')]
                #[ORM\CustomIdGenerator(class: UuidStringGenerator::class)]
            «ENDIF»
            «IF null !== extMan»«extMan.columnAnnotations(it)»«ENDIF»
            «IF !(it instanceof UploadField || it instanceof UserField)»«/* upload fields are embeddables; user fields are implemented as join to user entity, see persistentPropertyAdditions */»
                #[ORM\Column(«IF null !== dbName && !dbName.empty»name: '«dbName.formatForCode»', «ELSEIF it instanceof UploadField»name: '«it.name.formatForCode»', «ENDIF»«persistentPropertyImpl(typeDoctrine.toLowerCase)»«IF unique», unique: true«ENDIF»«IF nullable», nullable: true«ENDIF»«IF primaryKey», options: ['fixed' => true]«ENDIF»)]
            «ENDIF»
            «persistentPropertyAdditions»
        «ENDIF»
        «thVal.fieldAnnotations(it)»
        «modifier» ?«IF typePhp == 'DateTime'»\DateTime«IF (it as DatetimeField).immutable»Immutable«ENDIF»«ELSEIF typePhp == 'Uuid'»string«ELSE»«typePhp»«ENDIF» $«name.formatForCode»«fieldAssignment(init)»;
        «/* this last line is on purpose */»
    '''

    def private fieldAssignment(Field it, String init) '''«IF !init.empty»«init»«ELSEIF it instanceof UserField || it instanceof DatetimeField || (it instanceof StringField && (StringRole.DATE_INTERVAL == (it as StringField).role))» = null«ELSEIF !(it instanceof StringField) || !(it as StringField).treatAsUuidType» = «defaultFieldData»«ENDIF»'''

    def private persistentPropertyImpl(Field it, String type) {
        switch it {
            NumberField: '''type: Types::«type.toUpperCase»«IF numberType == NumberFieldType.DECIMAL», precision: «it.length», scale: «it.scale»«ENDIF»'''
            TextField: '''type: Types::«type.toUpperCase», length: «it.length»'''
            StringField:
                '''«IF role == StringRole.DATE_INTERVAL»type: Types::DATEINTERVAL«ELSE»«/*type: Types::«type.toUpperCase», */»length: «it.length»«ENDIF»'''
            ArrayField:
                '''type: Types::«arrayType.literal.toUpperCase»«/*», length: «it.length*/»'''
            ListField:
                '''length: «it.length»'''
            DatetimeField:
                '''type: Types::«/*UTC*/»«type.toUpperCase»_«IF immutable»IM«ENDIF»MUTABLE'''
            default: '''type: Types::«type.toUpperCase»'''
        }
    }

    def private persistentPropertyAdditions(Field it) {
        switch it {
            NumberField:
                if (it.role == NumberRole.VERSION && entity.hasOptimisticLock) '''
                    #[ORM\Version]
                '''
            StringField:
                '''
                    «IF name === 'slug'»
                        «new Sluggable().slugFieldAttributes(entity)»
                    «ENDIF»
                '''
            UserField:
                '''
                    «IF #['createdBy', 'updatedBy'].contains(name)»
                        #[Gedmo\Blameable(on: '«name.substring(0, 6)»')]
                    «ENDIF»
                    #[ORM\ManyToOne(targetEntity: User::class)]
                    #[ORM\JoinColumn(referencedColumnName: 'id'«IF !nullable», nullable: false«ENDIF»)]
                '''
            DatetimeField:
                '''
                    «IF #['createdDate', 'updatedDate'].contains(name)»
                        #[Gedmo\Timestampable(on: '«name.substring(0, 6)»')]
                    «ENDIF»
                '''
        }
    }

    def static defaultFieldData(Field it) {
        switch it {
            BooleanField:
                if (it.defaultValue == 'true') 'true' else 'false'
            NumberField:
                if (it.role == NumberRole.VERSION) '1' 
                else if (null !== it.defaultValue && it.defaultValue.length > 0) it.defaultValue
                else if (it.nullable) 'null'
                else if (it.numberType == NumberFieldType.INTEGER) '0'
                else '0.00'
            ArrayField: '[]'
            UploadField: 'null'
            ListField:
                if (!items.filter[^default].empty) {
                    if (multiple) '[\'' + items.filter[^default].map[listItemValue].join('\', \'') + '\']'
                    else '\'' + items.filter[^default].head.listItemValue + '\''
                } else if (nullable) 'null' else '\'\''
            StringField:
                if (null !== it.defaultValue && it.defaultValue.length > 0) '\'' + it.defaultValue + '\''
                else if (it.nullable) 'null'
                else if (role === StringRole.CURRENCY) '\'EUR\''
                else '\'\''
            AbstractStringField: if (null !== it.defaultValue && it.defaultValue.length > 0) '\'' + it.defaultValue + '\'' else '\'\''
            default: '\'\''
        }
    }

    def static private listItemValue(ListFieldItem it) '''«IF null !== value»«value.replace("'", "")»«ELSE»«name/*.formatForCode.replace("'", "")*/»«ENDIF»'''

    def dispatch fieldAccessor(Field it) '''
        «IF it instanceof StringField && (it as StringField).treatAsUuidType»
            «fh.getterAndSetterMethodsForUuidString(it)»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString(true), true, '', '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(UploadField it) '''
        «fh.getterAndSetterMethods(it, name.formatForCode + 'File', 'File', true, '', fieldSetter)»
        «fh.getterAndSetterMethods(it, name.formatForCode, 'EmbeddedFile', true, '', '')»
    '''

    def private fieldSetter(UploadField it) '''
        $this->«name.formatForCode»File = $«name.formatForCode»File;
        «IF null !== entity && entity.standardFields»
            if (null !== $«name.formatForCode»File) {
                // make entity dirty to call Doctrine event listeners
                $this->updatedDate = new \DateTimeImmutable();
            }
        «ENDIF»
    '''
}
