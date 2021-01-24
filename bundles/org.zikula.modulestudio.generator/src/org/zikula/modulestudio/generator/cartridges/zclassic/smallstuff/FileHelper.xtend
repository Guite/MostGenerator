package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FileHelper {

    Application app

    new(Application it) {
        app = it
    }

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    def msWeblink() '''
        <p id="poweredByMost" class="text-center">
            Powered by <a href="«msUrl»" title="Get the MOST out of Zikula!">ModuleStudio «msVersion»</a>
        </p>
    '''

    def getterAndSetterMethods(Object it, String name, String type, Boolean isMany, Boolean nullable, Boolean useHint, String init, CharSequence customImpl) '''
        «getterMethod(name, type, isMany, nullable, useHint && app.targets('3.0'))»
        «setterMethod(name, type, isMany, nullable, useHint, init, customImpl)»
    '''

    def getterMethod(Object it, String name, String type, Boolean isMany, Boolean nullable, Boolean useHint) '''

        «IF !app.targets('3.0')»
        /**
         * Returns the «name.formatForDisplay».
         *
         * @return «IF type == 'smallint' || type == 'bigint'»int«ELSEIF type.toLowerCase == 'datetime'»\DateTimeInterface«ELSE»«type»«ENDIF»«IF type.toLowerCase != 'array' && isMany»[]«ENDIF»
         */
        «ENDIF»
        public function get«name.formatForCodeCapital»()«IF useHint»«IF skipTypeHint»/*«ENDIF»: «IF nullable»?«ENDIF»«IF type == 'smallint' || type == 'bigint'»int«ELSEIF type.toLowerCase == 'datetime'»\DateTimeInterface«ELSE»«type»«ENDIF»«IF skipTypeHint»*/«ENDIF»«ENDIF»
        {
            return «IF type == 'float'&& #['latitude', 'longitude'].contains(name)»(float)«ENDIF»$this->«name»;
        }
    '''

    def setterMethod(Object it, String name, String type, Boolean isMany, Boolean nullable, Boolean useHint, String init, CharSequence customImpl) '''

        «IF !app.targets('3.0')»
        /**
         * Sets the «name.formatForDisplay».
         *
         * @param «IF type == 'smallint' || type == 'bigint'»int«ELSEIF type.toLowerCase == 'datetime'»\DateTimeInterface«ELSE»«type»«ENDIF»«IF type.toLowerCase != 'array' && isMany»[]«ENDIF» $«name»
         *
         * @return self
         */
        «ENDIF»
        public function set«name.formatForCodeCapital»(«IF useHint»«IF skipTypeHint»/*«ENDIF»«IF nullable»?«ENDIF»«IF type == 'smallint' || type == 'bigint'»int«ELSEIF type.toLowerCase == 'datetime'»\DateTimeInterface«ELSE»«type»«ENDIF» «IF skipTypeHint»*/«ENDIF»«ENDIF»$«name»«IF !init.empty» = «init»«ELSEIF nullable» = null«ENDIF»)«IF app.targets('3.0')»: self«ENDIF»
        {
            «IF null !== customImpl && customImpl != ''»
                «customImpl»
            «ELSE»
                «setterMethodImpl(name, type, nullable)»
            «ENDIF»

            return $this;
        }
    '''

    def private skipTypeHint(Object it) {
        (it instanceof IntegerField && (it as IntegerField).isUserGroupSelector) || (it instanceof UserField)
    }

    def private dispatch setterMethodImpl(Object it, String name, String type, Boolean nullable) '''
        «IF type == 'float'»
            «IF #['latitude', 'longitude'].contains(name)»
                $«name» = round((float) $«name», 7);
            «ENDIF»
            if ((float) $this->«name» !== «IF !app.targets('3.0')»(float) «ENDIF»$«name») {
                «IF nullable»
                    $this->«name» = «IF !app.targets('3.0')»(float) «ENDIF»$«name»;
                «ELSE»
                    $this->«name» = «IF app.targets('3.0')»$«name» ?? 0.00«ELSE»isset($«name») ? (float) $«name» : 0.00«ENDIF»;
                «ENDIF»
            }
        «ELSE»
            if ($this->«name» !== $«name») {
                «IF nullable»
                    $this->«name» = $«name»;
                «ELSE»
                    $this->«name» = «IF app.targets('3.0')»$«name» ?? ''«ELSE»isset($«name») ? $«name» : ''«ENDIF»;
                «ENDIF»
            }
        «ENDIF»
    '''

    def triggerPropertyChangeListeners(DerivedField it, String name) '''
        «IF null !== entity && ((entity instanceof Entity && (entity as Entity).hasNotifyPolicy) || entity.getInheritingEntities.exists[hasNotifyPolicy])»
            $this->_onPropertyChanged('«name.formatForCode»', $this->«name.formatForCode», $«name»);
        «ENDIF»
    '''

    def private dispatch setterMethodImpl(DerivedField it, String name, String type, Boolean nullable) '''
        «IF it instanceof NumberField»
            $«name» = round((float) $«name», «scale»);
        «ENDIF»
        if ($this->«name.formatForCode» !== $«name») {
            «triggerPropertyChangeListeners(name)»
            «setterAssignment(name)»
        }
    '''

    def private dispatch setterMethodImpl(BooleanField it, String name, String type, Boolean nullable) '''
        if ((bool) $this->«name.formatForCode» !== «IF !app.targets('3.0')»(bool) «ENDIF»$«name») {
            «triggerPropertyChangeListeners(name)»
            «setterAssignment(name)»
        }
    '''

    def private dispatch setterAssignment(DerivedField it, String name) '''
        «IF nullable»
            $this->«name» = $«name»;
        «ELSE»
            $this->«name» = «IF app.targets('3.0')»$«name» ?? «fallbackValue»«ELSE»isset($«name») ? $«name» : «fallbackValue»«ENDIF»;
        «ENDIF»
    '''
    def private dispatch fallbackValue(DerivedField it) {
        '\'\''
    }
    def private dispatch fallbackValue(ArrayField it) {
        '[]'
    }

    def private dispatch setterAssignment(BooleanField it, String name) '''
        $this->«name» = «IF !app.targets('3.0')»(bool) «ENDIF»$«name»;
    '''

    def private dispatch setterAssignment(UserField it, String name) '''
        «IF nullable»
            $this->«name» = $«name»;
        «ELSE»
            if ($«name» instanceof UserEntity) {
                $this->«name» = $«name»;
            }
        «ENDIF»
    '''

    def private setterAssignmentNumeric(DerivedField it, String name) '''
        «val aggregators = getAggregatingRelationships»
        «IF !aggregators.empty»
            $diff = abs($this->«name» - $«name»);
        «ENDIF»
        $this->«name» = «IF app.targets('3.0')»$«name»«ELSE»«numericCast('$' + name)»«ENDIF»;
        «IF !aggregators.empty»
            «FOR aggregator : aggregators»
            $this->«aggregator.sourceAlias.formatForCode»->add«name.formatForCodeCapital»Without«entity.name.formatForCodeCapital»($diff);
            «ENDFOR»
        «ENDIF»
    '''

    def private dispatch setterMethodImpl(IntegerField it, String name, String type, Boolean nullable) '''
        if («numericCast('$this->' + name.formatForCode)» !== «IF app.targets('3.0')»$«name»«ELSE»«numericCast('$' + name)»«ENDIF») {
            «triggerPropertyChangeListeners(name)»
            «setterAssignmentNumeric(name)»
        }
    '''
    def private dispatch setterMethodImpl(UserField it, String name, String type, Boolean nullable) '''
        if ($this->«name.formatForCode» !== $«name») {
            «triggerPropertyChangeListeners(name)»
            «setterAssignment(name)»
        }
    '''
    def private dispatch setterMethodImpl(NumberField it, String name, String type, Boolean nullable) '''
        if («numericCast('$this->' + name.formatForCode)» !== «IF app.targets('3.0')»$«name»«ELSE»«numericCast('$' + name)»«ENDIF») {
            «triggerPropertyChangeListeners(name)»
            «setterAssignmentNumeric(name)»
        }
    '''

    def private numericCast(DerivedField it, String variable) {
        if (notOnlyNumericInteger) {
            return variable
        }
        if (it instanceof AbstractIntegerField) {
            return '(int) ' + variable
        } else {
            return '(float) ' + variable
        }
    }

    def private dispatch setterAssignment(DatetimeField it, String name) '''
        if (
            !(null === $«name» && empty($«name»))
            && !(is_object($«name») && $«name» instanceof \DateTimeInterface)
        ) {
            $«name» = new \DateTime«IF immutable»Immutable«ENDIF»($«name»);
        }
        «IF !nullable»

            if (null === $«name» || empty($«name»)) {
                $«name» = new \DateTime«IF immutable»Immutable«ENDIF»();
            }
        «ENDIF»

        if ($this->«name» !== $«name») {
            $this->«name» = $«name»;
        }
    '''
}
