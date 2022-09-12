package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FileHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    new(Application it) {
    }

    def msWeblink() '''
        <p id="poweredByMost" class="text-center">
            Powered by <a href="«msUrl»" title="Get the MOST out of Zikula!">ModuleStudio «msVersion»</a>
        </p>
    '''

    def getterAndSetterMethods(Object it, String name, String type, Boolean nullable, String init, CharSequence customImpl) '''
        «getterMethod(name, type, nullable)»
        «setterMethod(name, type, nullable, init, customImpl)»
    '''

    def getterMethod(Object it, String name, String type, Boolean nullable) '''

        «IF type.definesGeneric»
            /**
             * @return «type»
             */
        «ENDIF»
        public function get«name.formatForCodeCapital»(): «IF nullable»?«ENDIF»«normalizeTypeHint(type)»
        {
            return «IF type == 'float' /* needed because decimals are mapped to string properties */»(float) «ENDIF»$this->«name»;
        }
    '''

    def private setterMethod(Object it, String name, String type, Boolean nullable, String init, CharSequence customImpl) '''

        «IF type.definesGeneric»
            /**
             * @param «type» $«name»
             */
        «ENDIF»
        public function set«name.formatForCodeCapital»(«IF nullable && !type.definesGeneric»?«ENDIF»«normalizeTypeHint(type)»«IF type.definesGeneric»|array«IF nullable»|null«ENDIF»«ENDIF» $«name»«IF !init.empty» = «init»«ELSEIF nullable» = null«ENDIF»): self
        {
            «IF type.definesGeneric»«/* array may be set by Forms */»
                if (is_array($«name»)) {
                    $«name» = new ArrayCollection($«name»);
                }
            «ENDIF»
            «IF null !== customImpl && customImpl != ''»
                «customImpl»
            «ELSE»
                «setterMethodImpl(name, type, nullable)»
            «ENDIF»

            return $this;
        }
    '''

    def private normalizeTypeHint(String type) '''«IF type.definesGeneric»«type.split('<').head»«ELSEIF type == 'smallint' || type == 'bigint'»int«ELSEIF type.toLowerCase == 'datetime'»\DateTimeInterface«ELSE»«type»«ENDIF»'''

    def private definesGeneric(String type) { type.contains('Collection<') }

    def private dispatch setterMethodImpl(Object it, String name, String type, Boolean nullable) '''
        «IF #['latitude', 'longitude'].contains(name)»
            $«name» = (string) round((float) $«name», 7);
        «ENDIF»
        if ($this->«name» !== $«name») {
            «setterAssignment(name, type, nullable)»
        }
    '''

    def triggerPropertyChangeListeners(DerivedField it, String name) '''
        «IF null !== entity && ((entity instanceof Entity && (entity as Entity).hasNotifyPolicy) || entity.getInheritingEntities.exists[hasNotifyPolicy])»
            $this->_onPropertyChanged('«name.formatForCode»', $this->«name.formatForCode», $«name»);
        «ENDIF»
    '''

    def private dispatch setterMethodImpl(DerivedField it, String name, String type, Boolean nullable) '''
        «IF it instanceof NumberField»
            $«name» = «IF it.numberType == NumberFieldType::DECIMAL»(string) «ENDIF»round((float) $«name», «scale»);
        «ENDIF»
        if ($this->«name.formatForCode» !== $«name») {
            «triggerPropertyChangeListeners(name)»
            «setterAssignment(name)»
        }
    '''

    def private setterAssignment(Object it, String name, String type, Boolean nullable) '''
        «IF nullable»
            $this->«name» = $«name»;
        «ELSE»
            $this->«name» = $«name» ?? «IF type == 'float'»0.00«ELSEIF type == 'int'»0«ELSE»''«ENDIF»;
        «ENDIF»
    '''
    def private dispatch setterAssignment(DerivedField it, String name) '''
        «IF nullable»
            $this->«name» = $«name»;
        «ELSE»
            $this->«name» = $«name» ?? «fallbackValue»;
        «ENDIF»
    '''
    def private dispatch fallbackValue(DerivedField it) {
        '\'\''
    }
    def private dispatch fallbackValue(ArrayField it) {
        '[]'
    }

    def private dispatch setterAssignment(BooleanField it, String name) '''
        $this->«name» = $«name»;
    '''

    def private dispatch setterAssignment(UserField it, String name) '''
        «IF nullable»
            $this->«name» = $«name»;
        «ELSE»
            if ($«name» instanceof User) {
                $this->«name» = $«name»;
            }
        «ENDIF»
    '''

    def private dispatch setterAssignment(IntegerField it, String name) '''
        «setterAssignmentNumeric(name)»
    '''
    def private dispatch setterAssignment(NumberField it, String name) '''
        «setterAssignmentNumeric(name)»
    '''

    def private setterAssignmentNumeric(DerivedField it, String name) '''
        «val aggregators = getAggregatingRelationships»
        «IF !aggregators.empty»
            $diff = abs($this->«name» - $«name»);
        «ENDIF»
        $this->«name» = $«name»;
        «IF !aggregators.empty»
            «FOR aggregator : aggregators»
            $this->«aggregator.sourceAlias.formatForCode»->add«name.formatForCodeCapital»Without«entity.name.formatForCodeCapital»($diff);
            «ENDFOR»
        «ENDIF»
    '''

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
