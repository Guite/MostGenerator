package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.EntityIdentifierStrategy
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper

class Property {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()

    FileHelper fh = new FileHelper()

    def dispatch persistentProperty(DerivedField it) {
        persistentProperty(name.formatForCode, fieldTypeAsString, '')
    }

    /**
     * Do only use integer (no smallint or bigint) for version fields.
     * This is just a hack for a minor bug in Doctrine 2.
     * See http://www.doctrine-project.org/jira/browse/DDC-1290 for more information.
     * After this has been fixed the following define for IntegerField can be removed
     * completely as the define for DerivedField can be used then instead.
     */
    def dispatch persistentProperty(IntegerField it) {
        if (version && entity.hasOptimisticLock)
            persistentProperty(name.formatForCode, 'integer', '')
        else
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
         * @var array $«name.formatForCode»Meta.
         */
        protected $«name.formatForCode»Meta = array();

        «persistentProperty(name.formatForCode, fieldTypeAsString, '')»
        /**
         * The full path to the «name.formatForDisplay».
         *
         * @var string $«name.formatForCode»FullPath.
         */
        protected $«name.formatForCode»FullPath = '';

        /**
         * Full «name.formatForDisplay» path as url.
         *
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
              * @ORM\GeneratedValue«IF entity.identifierStrategy != EntityIdentifierStrategy::NONE»(strategy="«entity.identifierStrategy.asConstant()»")«ENDIF»
            «ELSE»
              * @ORM\Id
          «ENDIF»
        «ENDIF»
        «new Extensions().columnExtensions(it)»
         * @ORM\Column(«persistentPropertyImpl(type)»«IF unique», unique=true«ENDIF»«IF nullable», nullable=true«ENDIF»)
        «persistentPropertyAdditions»
         * @var «type» $«name».
         */
        «modifier» $«name»«IF init != ''»«init»«ELSE» = «defaultFieldData»«ENDIF»;
        «/* this last line is on purpose */»
    '''

    def private persistentPropertyImpl(DerivedField it, String type) {
    	switch (it) {
    		DecimalField: '''type="«type»", precision=«it.length», scale=«it.scale»'''
    		TextField: '''type="«type»", length=«it.length»'''
    		StringField:
    		    '''«/*type="«type»", */»length=«it.length»'''
    		EmailField:
    		    '''«/*type="«type»", */»length=«it.length»'''
    		UrlField:
    		    '''«/*type="«type»", */»length=«it.length»'''
    		UploadField:
    		    '''«/*type="«type»", */»length=«it.length»'''
    		ListField:
    		    '''«/*type="«type»", */»length=«it.length»'''
    		default: '''type="«type»"'''
    	}
    }

    def private persistentPropertyAdditions(DerivedField it) {
    	switch (it) {
    	    IntegerField:
                if (it.version && entity.hasOptimisticLock) '''
                 * @ORM\Version
                '''
    	    DatetimeField:
                if (it.version && entity.hasOptimisticLock) '''
                 * @ORM\Version
                '''
    	}
    }

    def private defaultFieldData(EntityField it) {
    	switch (it) {
    		BooleanField:
    		    if (it.defaultValue == true || it.defaultValue == 'true') 'true' else 'false'
    	    AbstractIntegerField:
    	        if (it.defaultValue != null && it.defaultValue.length > 0) it.defaultValue else '0'
    	    DecimalField:
    	        if (it.defaultValue != null && it.defaultValue.length > 0) it.defaultValue else '0.00'
    	    ArrayField: 'array()'
    	    ObjectField: 'null'
    	    AbstractStringField: if (it.defaultValue != null && it.defaultValue.length > 0) '\'' + it.defaultValue + '\'' else '\'\''
    	    AbstractDateField:
                if (it.mandatory && it.defaultValue != null && it.defaultValue.length > 0 && it.defaultValue != 'now') '\'' + it.defaultValue + '\'' else 'null'
    	    FloatField:
    	        if (it.defaultValue != null && it.defaultValue.length > 0) it.defaultValue else '0'
    	    default: '\'\''
    	}
    }

    def private fieldAccessorDefault(DerivedField it) '''
        «IF isIndexByField»
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString, false)»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString, false, false, '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(DerivedField it) '''
        «fieldAccessorDefault»
    '''

    def dispatch fieldAccessor(IntegerField it) '''
        «IF isIndexByField/* || (aggregateFor != null && aggregateFor != ''*/»
            «fh.getterMethod(it, name.formatForCode, fieldTypeAsString, false)»
        «ELSE»
            «fh.getterAndSetterMethods(it, name.formatForCode, fieldTypeAsString, false, false, '')»
        «ENDIF»
    '''

    def dispatch fieldAccessor(UploadField it) '''
        «fieldAccessorDefault»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'FullPath', 'string', false, false, '')»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'FullPathUrl', 'string', false, false, '')»
        «fh.getterAndSetterMethods(it, name.formatForCode + 'Meta', 'array', true, false, 'Array()')»
    '''
}
