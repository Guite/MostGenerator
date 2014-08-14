package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.EntityIdentifierStrategy
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Property {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    ExtensionManager extMan
    ValidationConstraints thVal = new ValidationConstraints

    new(ExtensionManager extMan) {
        this.extMan = extMan
    }

    def dispatch persistentProperty(DerivedField it) {
        persistentProperty(name.formatForCode, fieldTypeAsString, '')
    }

    /**
     * Do only use integer (no smallint or bigint) for version fields.
     * This is just a hack for a minor bug in Doctrine 2.1 (fixed in 2.2).
     * After we dropped support for Zikula 1.3.x (#260) the following define for IntegerField
     * can be removed completely as the define for DerivedField can be used then instead.
     */
    def dispatch persistentProperty(IntegerField it) {
        if (version && entity instanceof Entity && (entity as Entity).hasOptimisticLock && entity.application.targets('1.3.5')) {
            persistentProperty(name.formatForCode, 'integer', '')
        } else {
            persistentProperty(name.formatForCode, fieldTypeAsString, '')
        }
    }

    def dispatch persistentProperty(UploadField it) '''
        /**
         * «name.formatForDisplayCapital» meta data array.
         *
         * @ORM\Column(type="array")
         «IF translatable»
          * @Gedmo\Translatable
         «ENDIF»
         «IF !entity.application.targets('1.3.5')»
         * @Assert\Type(type="array")
         «ENDIF»
         * @var array $«name.formatForCode»Meta.
         */
        protected $«name.formatForCode»Meta = array();

        «persistentProperty(name.formatForCode, fieldTypeAsString, '')»
        /**
         * The full path to the «name.formatForDisplay».
         *
         «IF !entity.application.targets('1.3.5')»
         * @Assert\Type(type="string")
         «ENDIF»
         * @var string $«name.formatForCode»FullPath.
         */
        protected $«name.formatForCode»FullPath = '';

        /**
         * Full «name.formatForDisplay» path as url.
         *
         «IF !entity.application.targets('1.3.5')»
         * @Assert\Type(type="string")
         «ENDIF»
         * @var string $«name.formatForCode»FullPathUrl.
         */
        protected $«name.formatForCode»FullPathUrl = '';
    '''

    def dispatch persistentProperty(ArrayField it) {
        persistentProperty(name.formatForCode, fieldTypeAsString, ' = array()')
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
         * @ORM\Column(«IF dbName !== null && dbName != ''»name="«dbName.formatForCode»", «ENDIF»«persistentPropertyImpl(type.toLowerCase)»«IF unique», unique=true«ENDIF»«IF nullable», nullable=true«ENDIF»)
        «persistentPropertyAdditions»
        «IF !entity.application.targets('1.3.5')»
            «thVal.fieldAnnotations(it)»
        «ENDIF»
         * @var «IF type == 'bigint' || type == 'smallint'»integer«ELSE»«type»«ENDIF» $«name.formatForCode».
         */
        «modifier» $«name.formatForCode»«IF init != ''»«init»«ELSE» = «defaultFieldData»«ENDIF»;
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
                '''type="«IF entity.application.targets('1.3.5')»array«ELSE»«arrayType.literal.toLowerCase»«ENDIF»"«/*», length=«it.length*/»'''
            UploadField:
                '''«/*type="«type»", */»length=«it.length»'''
            ListField:
                '''«/*type="«type»", */»length=«it.length»'''
            default: '''type="«type»"'''
        }
    }

    def private persistentPropertyAdditions(DerivedField it) {
        switch it {
            IntegerField:
                if (it.version && entity instanceof Entity && (entity as Entity).hasOptimisticLock) '''
                    «''» * @ORM\Version
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
                if (it.defaultValue == true || it.defaultValue == 'true') 'true' else 'false'
            AbstractIntegerField:
                if (it.defaultValue !== null && it.defaultValue.length > 0) it.defaultValue else '0'
            DecimalField:
                if (it.defaultValue !== null && it.defaultValue.length > 0) it.defaultValue else '0.00'
            ArrayField: 'array()'
            ObjectField: 'null'
            ListField: if (it.defaultValue !== null && it.defaultValue.length > 0) '\'' + it.defaultValue + '\'' else 'null'
            AbstractStringField: if (it.defaultValue !== null && it.defaultValue.length > 0) '\'' + it.defaultValue + '\'' else '\'\''
            AbstractDateField:
                if (it.mandatory && it.defaultValue !== null && it.defaultValue.length > 0 && it.defaultValue != 'now') '\'' + it.defaultValue + '\'' else 'null'
            FloatField:
                if (it.defaultValue !== null && it.defaultValue.length > 0) it.defaultValue else '0'
            default: '\'\''
        }
    }

    def private fieldAccessorDefault(DerivedField it) '''
        «IF isIndexByField»
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString, false)»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString, false, false, '', '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(DerivedField it) '''
        «fieldAccessorDefault»
    '''

    def dispatch fieldAccessor(IntegerField it) '''
        «IF isIndexByField/* || (aggregateFor != null && aggregateFor != ''*/»
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString, false)»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString, false, false, '', '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(UploadField it) '''
        «fieldAccessorDefault»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'FullPath', 'string', false, false, '', '')»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'FullPathUrl', 'string', false, false, '', '')»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'Meta', 'array', true, false, 'Array()', '')»
    '''
}
