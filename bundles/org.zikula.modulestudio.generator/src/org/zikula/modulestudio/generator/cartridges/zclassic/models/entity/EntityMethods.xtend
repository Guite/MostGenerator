package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TimeField
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityMethods {

    extension FormattingExtensions = new FormattingExtensions
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

        «toJson»

        «createUrlArgs»

        «createCompositeIdentifier»

        «supportsHookSubscribers»

        «IF !skipHookSubscribers»
            «getHookAreaPrefix»

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
        «val timeFields = fields.filter(TimeField)»
        «IF !timeFields.empty»
            «FOR timeField : timeFields»

                «thVal.validationMethods(timeField)»
            «ENDFOR»
        «ENDIF»
    '''

    def private propertyChangedListener(Entity it) '''
        «IF hasNotifyPolicy»
            /**
             * Adds a property change listener.
             *
             * @param PropertyChangedListener $listener The listener to be added
             */
            public function addPropertyChangedListener(PropertyChangedListener $listener)
            {
                $this->_propertyChangedListeners[] = $listener;
            }

            /**
             * Notify all registered listeners about a changed property.
             *
             * @param String $propName Name of property which has been changed
             * @param mixed  $oldValue The old property value
             * @param mixed  $newValue The new property value
             */
            protected function _onPropertyChanged($propName, $oldValue, $newValue)
            {
                if ($this->_propertyChangedListeners) {
                    foreach ($this->_propertyChangedListeners as $listener) {
                        $listener->propertyChanged($this, $propName, $oldValue, $newValue);
                    }
                }
            }

        «ENDIF»
    '''

    def private toJson(Entity it) '''
        /**
         * Return entity data in JSON format.
         *
         * @return string JSON-encoded data
         */
        public function toJson()
        {
            return json_encode($this->toArray());
        }
    '''


    def private createUrlArgs(Entity it) '''
        /**
         * Creates url arguments array for easy creation of display urls.
         *
         * @return array The resulting arguments list
         */
        public function createUrlArgs()
        {
            $args = [];

            «IF hasCompositeKeys»
                «FOR pkField : getPrimaryKeyFields»
                    $args['«pkField.name.formatForCode»'] = $this['«pkField.name.formatForCode»'];
                «ENDFOR»
            «ELSE»
                $args['«getFirstPrimaryKey.name.formatForCode»'] = $this['«getFirstPrimaryKey.name.formatForCode»'];
            «ENDIF»

            if (property_exists($this, 'slug')) {
                $args['slug'] = $this['slug'];
            }

            return $args;
        }
    '''

    def private createCompositeIdentifier(Entity it) '''
        /**
         * Create concatenated identifier string (for composite keys).
         *
         * @return String concatenated identifiers
         */
        public function createCompositeIdentifier()
        {
            «IF hasCompositeKeys»
                $itemId = '';
                «FOR pkField : getPrimaryKeyFields»
                    $itemId .= ((!empty($itemId)) ? '_' : '') . $this['«pkField.name.formatForCode»'];
                «ENDFOR»
            «ELSE»
                $itemId = $this['«getFirstPrimaryKey.name.formatForCode»'];
            «ENDIF»

            return $itemId;
        }
    '''

    def private supportsHookSubscribers(Entity it) '''
        /**
         * Determines whether this entity supports hook subscribers or not.
         *
         * @return boolean
         */
        public function supportsHookSubscribers()
        {
            return «IF !skipHookSubscribers»true«ELSE»false«ENDIF»;
        }
    '''

    def private getHookAreaPrefix(Entity it) '''
        /**
         * Return lower case name of multiple items needed for hook areas.
         *
         * @return string
         */
        public function getHookAreaPrefix()
        {
            return '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB»';
        }
    '''

    def private toStringImpl(DataObject it, Application app) '''
        /**
         * ToString interceptor implementation.
         * This method is useful for debugging purposes.
         *
         * @return string The output string for this entity
         */
        public function __toString()
        {
            return '«name.formatForDisplayCapital» ' . $this->createCompositeIdentifier()«IF !getSelfAndParentDataObjects.map[fields.filter(StringField)].flatten.empty» . ': ' . $this->get«getSelfAndParentDataObjects.map[fields.filter(StringField)].flatten.head.name.formatForCodeCapital»()«ENDIF»;
        }
    '''

    def private relatedObjectsImpl(DataObject it, Application app) '''
        /**
         * Returns an array of all related objects that need to be persisted after clone.
         * 
         * @param array $objects The objects are added to this array. Default: []
         * 
         * @return array of entity objects
         */
        public function getRelatedObjectsToPersist(&$objects = []) 
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
            if (!(«FOR field : primaryKeyFields SEPARATOR ' && '»$this->«field.name.formatForCode»«ENDFOR»)) {
                return;
            }

            // otherwise proceed

            // unset identifiers
            «FOR field : primaryKeyFields»
                $this->set«field.name.formatForCodeCapital»(«thProp.defaultFieldData(field)»);
            «ENDFOR»
            «IF !app.targets('1.5')»

                // reset workflow
                $this->resetWorkflow();
            «ENDIF»
            «IF hasUploadFieldsEntity»

                // reset upload fields
                «FOR field : getUploadFieldsEntity»
                    $this->set«field.name.formatForCodeCapital»(null);
                    $this->set«field.name.formatForCodeCapital»Meta([]);
                    $this->set«field.name.formatForCodeCapital»Url('');
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

                $ref = new \ReflectionClass(__CLASS__);
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
