package org.zikula.modulestudio.generator.cartridges.symfony.models.entity

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.zikula.modulestudio.generator.cartridges.symfony.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class EntityMethods {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def dispatch generate(DataObject it, Application app, Property thProp) '''
        «validationMethods»

        «relatedObjectsImpl(app)»

        «toStringImpl(app)»

        «cloneImpl(app, thProp)»
    '''

    def dispatch generate(Entity it, Application app, Property thProp) '''
        «validationMethods»

        «createUrlArgs»

        «getKey»

        «relatedObjectsImpl(app)»

        «toStringImpl(app)»

        «cloneImpl(app, thProp)»
    '''

    def validationMethods(DataObject it) '''
        «val thVal = new ValidationConstraints»
        «IF hasDirectTimeFields»
            «FOR timeField : getDirectTimeFields»

                «thVal.validationMethods(timeField)»
            «ENDFOR»
        «ENDIF»
    '''

    def private createUrlArgs(Entity it) '''
        /**
         * Creates url arguments array for easy creation of display urls.
         */
        public function createUrlArgs(«IF hasSluggableFields && slugUnique»bool $forEditing = false«ENDIF»): array
        {
            «IF hasSluggableFields && slugUnique»
                if (true === $forEditing) {
                    return [
                        '«getPrimaryKey.name.formatForCode»' => $this->get«getPrimaryKey.name.formatForCodeCapital»(),
                        'slug' => $this->getSlug(),
                    ];
                }

                return [
                    'slug' => $this->getSlug(),
                ];
            «ELSE»
                return [
                    '«getPrimaryKey.name.formatForCode»' => $this->get«getPrimaryKey.name.formatForCodeCapital»(),
                    «IF hasSluggableFields»
                        'slug' => $this->getSlug(),
                    «ENDIF»
                ];
            «ENDIF»
        }
    '''

    def private getKey(Entity it) '''
        /**
         * Returns the primary key.
         */
        public function getKey(): ?int
        {
            return $this->get«getPrimaryKey.name.formatForCodeCapital»();
        }
    '''

    def private toStringImpl(DataObject it, Application app) '''
        public function __toString(): string
        {
            return «IF hasDisplayStringFieldsEntity»$this->get«getDisplayStringFieldsEntity.head.name.formatForCodeCapital»()«ELSE»'«name.formatForDisplayCapital» ' . $this->getKey()«ENDIF»;
        }
    '''

    def private relatedObjectsImpl(DataObject it, Application app) '''
        /**
         * Returns an array of all related objects that need to be persisted after clone.
         */
        public function getRelatedObjectsToPersist(array &$objects = []): array
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
                            $this->add«aliasName.formatForCodeCapital»(«IF !(relation instanceof ManyToManyRelationship)»clone «ENDIF»$rel);
                        }
                    «ENDFOR»
                «ENDFOR»
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
