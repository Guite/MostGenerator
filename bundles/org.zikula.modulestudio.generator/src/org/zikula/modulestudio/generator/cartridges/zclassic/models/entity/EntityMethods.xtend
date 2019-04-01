package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityMethods {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def dispatch generate(DataObject it, Application app, Property thProp) '''
        «validationMethods»

        «relatedObjectsImpl(app)»

        «toStringImpl(app)»

        «cloneImpl(app, thProp)»
    '''

    def dispatch generate(Entity it, Application app, Property thProp) '''
        «propertyChangedListener»
        «validationMethods»

        «createUrlArgs»

        «getKey»

        «IF app.hasHookSubscribers»
            «supportsHookSubscribers»

            «IF !skipHookSubscribers»
                «getHookAreaPrefix»

            «ENDIF»
        «ENDIF»
        «relatedObjectsImpl(app)»

        «toStringImpl(app)»

        «cloneImpl(app, thProp)»
    '''

    def validationMethods(DataObject it) '''
        «val thVal = new ValidationConstraints»
        «IF hasUserFieldsEntity»
            «FOR userField : getUserFieldsEntity»

                «thVal.validationMethods(userField)»
            «ENDFOR»
        «ENDIF»
        «IF hasDirectTimeFields»
            «FOR timeField : getDirectTimeFields»

                «thVal.validationMethods(timeField)»
            «ENDFOR»
        «ENDIF»
    '''

    def private propertyChangedListener(Entity it) '''
        «IF hasNotifyPolicy»
            /**
             * Adds a property change listener.
             */
            public function addPropertyChangedListener(PropertyChangedListener $listener)«IF application.targets('3.0')»: void«ENDIF»
            {
                $this->_propertyChangedListeners[] = $listener;
            }

            /**
             * Notify all registered listeners about a changed property.
             *
             «IF !application.targets('3.0')»
             * @param string $propName Name of property which has been changed
             «ENDIF»
             * @param mixed $oldValue The old property value
             * @param mixed $newValue The new property value
             */
            protected function _onPropertyChanged(«IF application.targets('3.0')»string «ENDIF»$propName, $oldValue, $newValue)«IF application.targets('3.0')»: void«ENDIF»
            {
                if ($this->_propertyChangedListeners) {
                    foreach ($this->_propertyChangedListeners as $listener) {
                        $listener->propertyChanged($this, $propName, $oldValue, $newValue);
                    }
                }
            }

        «ENDIF»
    '''

    def private createUrlArgs(Entity it) '''
        /**
         * Creates url arguments array for easy creation of display urls.
         «IF !application.targets('3.0')»
         *
         «IF hasSluggableFields && slugUnique»
         * @param bool $forEditing
         *
         «ENDIF»
         * @return array List of resulting arguments
         «ENDIF»
         */
        public function createUrlArgs(«IF hasSluggableFields && slugUnique»«IF application.targets('3.0')»bool «ENDIF»$forEditing = false«ENDIF»)«IF application.targets('3.0')»: array«ENDIF»
        {
            «IF hasSluggableFields && slugUnique»
                if (true === $forEditing) {
                    return [
                        '«getPrimaryKey.name.formatForCode»' => $this->get«getPrimaryKey.name.formatForCodeCapital»(),
                        'slug' => $this->getSlug()
                    ];
                }

                return [
                    'slug' => $this->getSlug()
                ];
            «ELSE»
                return [
                    '«getPrimaryKey.name.formatForCode»' => $this->get«getPrimaryKey.name.formatForCodeCapital»()«IF hasSluggableFields»,
                    'slug' => $this->getSlug()«ENDIF»
                ];
            «ENDIF»
        }
    '''

    def private getKey(Entity it) '''
        /**
         * Returns the primary key.
         «IF !application.targets('3.0')»
         *
         * @return int The identifier
         «ENDIF»
         */
        public function getKey()«IF application.targets('3.0')»: int«ENDIF»
        {
            return $this->get«getPrimaryKey.name.formatForCodeCapital»();
        }
    '''

    def private supportsHookSubscribers(Entity it) '''
        /**
         * Determines whether this entity supports hook subscribers or not.
         «IF !application.targets('3.0')»
         *
         * @return bool
         «ENDIF»
         */
        public function supportsHookSubscribers()«IF application.targets('3.0')»: bool«ENDIF»
        {
            return «IF !skipHookSubscribers»true«ELSE»false«ENDIF»;
        }
    '''

    def private getHookAreaPrefix(Entity it) '''
        /**
         * Return lower case name of multiple items needed for hook areas.
         «IF !application.targets('3.0')»
         *
         * @return string
         «ENDIF»
         */
        public function getHookAreaPrefix()«IF application.targets('3.0')»: string«ENDIF»
        {
            return '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB»';
        }
    '''

    def private toStringImpl(DataObject it, Application app) '''
        /**
         * ToString interceptor implementation.
         * This method is useful for debugging purposes.
         «IF !application.targets('3.0')»
         *
         * @return string The output string for this entity
         «ENDIF»
         */
        public function __toString()«IF application.targets('3.0')»: string«ENDIF»
        {
            return '«name.formatForDisplayCapital» ' . $this->getKey()«IF hasDisplayStringFieldsEntity» . ': ' . $this->get«getDisplayStringFieldsEntity.head.name.formatForCodeCapital»()«ENDIF»;
        }
    '''

    def private relatedObjectsImpl(DataObject it, Application app) '''
        /**
         * Returns an array of all related objects that need to be persisted after clone.
         «IF !application.targets('3.0')»
         * 
         * @param array $objects Objects that are added to this array
         * 
         * @return array List of entity objects
         «ENDIF»
         */
        public function getRelatedObjectsToPersist(«IF application.targets('3.0')»array «ENDIF»&$objects = [])«IF application.targets('3.0')»: array«ENDIF»
        {
            «val joinsIn = incomingJoinRelationsForCloning.filter[!(it instanceof ManyToManyRelationship)]»
            «val joinsOut = outgoingJoinRelationsForCloning.filter[!(it instanceof ManyToManyRelationship)]»
            «IF !joinsIn.empty || !joinsOut.empty»
                «FOR out : newArrayList(false, true)»
                    «FOR relation : if (out) joinsOut else joinsIn»
                        «var aliasName = relation.getRelationAliasName(out)»
                        foreach ($this->«aliasName» as $rel) {
                            if (!in_array($rel, $objects, true)) {
                                $objects[] = $rel;
                                $rel->getRelatedObjectsToPersist($objects);
                            }
                        }
                    «ENDFOR»
                «ENDFOR»

                return $objects;
            «ELSE»
                return [];
            «ENDIF»
        }
    '''

    def private cloneImpl(DataObject it, Application app, Property thProp) '''
        «val joinsIn = incomingJoinRelationsForCloning»
        «val joinsOut = outgoingJoinRelationsForCloning»
        /**
         * Clone interceptor implementation.
         * This method is for example called by the reuse functionality.
         «IF joinsIn.empty && joinsOut.empty»
         * Performs a quite simple shallow copy.
         «ELSE»
         * Performs a deep copy.
         «ENDIF»
         *
         * See also:
         * (1) http://docs.doctrine-project.org/en/latest/cookbook/implementing-wakeup-or-clone.html
         * (2) http://www.php.net/manual/en/language.oop5.cloning.php
         * (3) http://stackoverflow.com/questions/185934/how-do-i-create-a-copy-of-an-object-in-php
         */
        public function __clone()
        {
            // if the entity has no identity do nothing, do NOT throw an exception
            if (!$this->«getPrimaryKey.name.formatForCode») {
                return;
            }

            // otherwise proceed

            // unset identifier
            $this->set«getPrimaryKey.name.formatForCodeCapital»(«/* thProp.defaultFieldData(getPrimaryKey) */Property.defaultFieldData(getPrimaryKey)»);

            // reset workflow
            $this->setWorkflowState('initial');
            «IF hasUploadFieldsEntity»

                // reset upload fields
                «FOR field : getUploadFieldsEntity»
                    $this->set«field.name.formatForCodeCapital»(null);
                «ENDFOR»
            «ENDIF»
            «IF it instanceof Entity && (it as Entity).standardFields»

                $this->setCreatedBy(null);
                $this->setCreatedDate(null);
                $this->setUpdatedBy(null);
                $this->setUpdatedDate(null);
            «ENDIF»

            «IF !joinsIn.empty || !joinsOut.empty»
                // handle related objects
                // prevent shared references by doing a deep copy - see (2) and (3) for more information
                // clone referenced objects only if a new record is necessary
                «FOR out: newArrayList(false, true)»
                    «FOR relation : if (out) joinsOut else joinsIn»
                        «var aliasName = relation.getRelationAliasName(out)»
                        $collection = $this->«aliasName»;
                        $this->«aliasName» = new ArrayCollection();
                        foreach ($collection as $rel) {
                            $this->add«aliasName.formatForCodeCapital»(«IF !(relation instanceof ManyToManyRelationship)» clone«ENDIF» $rel);
                        }
                    «ENDFOR»
                «ENDFOR»
            «ENDIF»
            «IF it instanceof Entity»
                «IF categorisable»

                    // clone categories
                    $categories = $this->categories;
                    $this->categories = new ArrayCollection();
                    foreach ($categories as $c) {
                        $newCat = clone $c;
                        $this->categories->add($newCat);
                        $newCat->setEntity($this);
                    }
                «ENDIF»
                «IF attributable»

                    // clone attributes
                    $attributes = $this->attributes;
                    $this->attributes = new ArrayCollection();
                    foreach ($attributes as $a) {
                        $newAttr = clone $a;
                        $this->attributes->add($newAttr);
                        $newAttr->setEntity($this);
                    }
                «ENDIF»
            «ENDIF»
        }
        «IF it instanceof Entity && (it as Entity).loggable && hasUploadFieldsEntity»

            /**
             * Custom serialise method to process File objects during serialisation.
             */
            public function __sleep()
            {
                $uploadFields = ['«getUploadFieldsEntity.map[name.formatForCode].join('\', \'')»'];
                foreach ($uploadFields as $uploadField) {
                    if ($this[$uploadField] instanceof File) {
                        $this[$uploadField] = $this[$uploadField]->getFilename();
                    }
                }

                $ref = new ReflectionClass(__CLASS__);
                $props = $ref->getProperties();

                $serializeFields = [];

                foreach ($props as $prop) {
                    $serializeFields[] = $prop->name;
                }

                return $serializeFields;
            }
        «ENDIF»
    '''
}
