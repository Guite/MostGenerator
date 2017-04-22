package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityField
import de.guite.modulestudio.metamodel.EntityIdentifierStrategy
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
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
         * @ORM\Column(type="array")
         «IF translatable»
          * @Gedmo\Translatable
         «ENDIF»
         * @Assert\Type(type="array")
         * @var array $«name.formatForCode»Meta
         */
        protected $«name.formatForCode»Meta = [];

        «persistentProperty(name.formatForCode, fieldTypeAsString, '')»
        /**
         * Full «name.formatForDisplay» path as url.
         *
         * @Assert\Type(type="string")
         «/* * @Assert\Url() disabled due to problems with space chars in file names
         */»* @var string $«name.formatForCode»Url
         */
        protected $«name.formatForCode»Url = '';
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
         «IF null !== documentation && documentation != ''»
          * «documentation»
         «ENDIF»
         «IF primaryKey»
             «IF !entity.hasCompositeKeys»«/* || entity.identifierStrategy == EntityIdentifierStrategy::ASSIGNED-»*/»
              * @ORM\Id
              «IF entity instanceof Entity && (entity as Entity).identifierStrategy != EntityIdentifierStrategy::NONE»
               * @ORM\GeneratedValue(strategy="«(entity as Entity).identifierStrategy.literal»")
              «ENDIF»
            «ELSE»
              * @ORM\Id
          «ENDIF»
        «ENDIF»
        «extMan.columnAnnotations(it)»
         «IF !(it instanceof UserField)»«/* user fields are implemented as join to UserEntity, see persistentPropertyAdditions */»
         * @ORM\Column(«IF null !== dbName && dbName != ''»name="«dbName.formatForCode»", «ENDIF»«persistentPropertyImpl(type.toLowerCase)»«IF unique», unique=true«ENDIF»«IF nullable», nullable=true«ENDIF»)
         «ENDIF»
        «persistentPropertyAdditions»
        «thVal.fieldAnnotations(it)»
         * @var «IF type == 'bigint' || type == 'smallint'»integer«ELSEIF type == 'datetime'»\DateTime«ELSE»«type»«ENDIF» $«name.formatForCode»
         */
        «modifier» $«name.formatForCode»«IF init != ''»«init»«ELSE»«IF !(it instanceof AbstractDateField)» = «defaultFieldData»«ENDIF»«ENDIF»;
        «/* this last line is on purpose */»
    '''

    def private persistentPropertyImpl(DerivedField it, String type) {
        switch it {
            DecimalField: '''type="«type»", precision=«it.length», scale=«it.scale»'''
            TextField: '''type="«type»", length=«it.length»'''
            StringField:
                '''«/*type="«type»", */»length=«it.length»'''
            EmailField:
                '''«/*type="«type»", */»length=«it.length»'''
            UrlField:
                '''«/*type="«type»", */»length=«it.length»'''
            ArrayField:
                '''type="«arrayType.literal.toLowerCase»"«/*», length=«it.length*/»'''
            UploadField:
                '''«/*type="«type»", */»length=«it.length»'''
            ListField:
                '''«/*type="«type»", */»length=«it.length»'''
            DatetimeField:
                '''type="«/*IF entity.application.targets('1.5')»utc«ENDIF*/»«type»"'''
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
                    «' '»* @ORM\JoinColumn(referencedColumnName="uid")
                '''
            DatetimeField:
                if (it.version && entity instanceof Entity && (entity as Entity).hasOptimisticLock) '''
                    «''» * @ORM\Version
                '''
        }
    }

    def defaultFieldData(EntityField it) {
        switch it {
            BooleanField:
                if (it.defaultValue == 'true') 'true' else 'false'
            AbstractIntegerField:
                if (it instanceof IntegerField && (it as IntegerField).version) '1' else if (null !== it.defaultValue && it.defaultValue.length > 0) it.defaultValue else if (it instanceof UserField) 'null' else '0'
            DecimalField:
                if (null !== it.defaultValue && it.defaultValue.length > 0) it.defaultValue else '0.00'
            ArrayField: '[]'
            UploadField: 'null'
            ObjectField: 'null'
            ListField: if (null !== it.defaultValue && it.defaultValue.length > 0) '\'' + it.defaultValue + '\'' else if (nullable) 'null' else '\'\''
            AbstractStringField: if (null !== it.defaultValue && it.defaultValue.length > 0) '\'' + it.defaultValue + '\'' else '\'\''
            FloatField:
                if (null !== it.defaultValue && it.defaultValue.length > 0) it.defaultValue else '0'
            default: '\'\''
        }
    }

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
        «IF isIndexByField/* || (null !== aggregateFor && aggregateFor != ''*/»
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString, false)»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString, false, nullable, false, '', '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(UploadField it) '''
        «fieldAccessorDefault»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'Url', 'string', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'Meta', 'array', true, true, true, '[]', '')»
    '''
}
