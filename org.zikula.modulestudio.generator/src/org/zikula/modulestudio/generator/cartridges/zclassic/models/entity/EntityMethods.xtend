package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityMethods {

    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Entity it, Application app, Property thProp) '''
        «propertyChangedListener»

        «getTitleFromDisplayPattern(app)»

        «IF app.targets('1.3.5')»
            «initValidator»
        «ELSE»
            «val thVal = new ValidationConstraints»
            «IF hasListFieldsEntity»
                «FOR listField : getListFieldsEntity»

                    «thVal.validationMethods(listField)»
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR userField : getUserFieldsEntity»

                    «thVal.validationMethods(userField)»
                «ENDFOR»
            «ENDIF»
            «val dateTimeFields = fields.filter(AbstractDateField)»
            «IF !dateTimeFields.empty»
                «FOR dateField : dateTimeFields»

                    «thVal.validationMethods(dateField)»
                «ENDFOR»
            «ENDIF»
        «ENDIF»

        «initWorkflow(app)»

        «resetWorkflow(app)»

        «validate»

        «toJson»

        «new ItemActions().prepareItemActions(it, app)»

        «createUrlArgs»

        «createCompositeIdentifier»

        «getHookAreaPrefix»

        «relatedObjectsImpl(app)»

        «toStringImpl(app)»

        «cloneImpl(app, thProp)»
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

    def private getTitleFromDisplayPattern(Entity it, Application app) '''
        /**
         * Returns the formatted title conforming to the display pattern
         * specified for this entity.
         */
        public function getTitleFromDisplayPattern()
        {
            «IF displayPattern === null || displayPattern == ''»
                «val leadingField = getLeadingField»
                «IF leadingField !== null»
                    $formattedTitle = $this->get«leadingField.name.formatForCodeCapital»();
                «ELSE»
                    $dom = ZLanguage::getModuleDomain('«app.appName»');
                    $formattedTitle = __('«name.formatForDisplayCapital»', $dom);
                «ENDIF»
            «ELSE»
                «IF hasListFieldsEntity»
                    $serviceManager = ServiceUtil::getManager();
                    «IF app.targets('1.3.5')»
                        $listHelper = new «app.appName»_Util_ListEntries(ServiceUtil::getManager());
                    «ELSE»
                        $listHelper = $serviceManager->get('«app.appName.formatForDB».listentries_helper');
                    «ENDIF»

                «ENDIF»
                $formattedTitle = «parseDisplayPattern»;
            «ENDIF»

            return $formattedTitle;
        }
    '''

    def private parseDisplayPattern(Entity it) {
        var result = ''
        val patternParts = displayPattern.split('#')
        for (patternPart : patternParts) {
            if (result != '') {
                result = result.concat("\n" + '        . ')
            }

            var CharSequence formattedPart = ''
            // check if patternPart equals a field name
            var matchedFields = fields.filter[name == patternPart]
            if (!matchedFields.empty) {
                // field referencing part
                formattedPart = formatFieldValue(matchedFields.head, '$this->get' + patternPart.toFirstUpper + '()')
            } else if (geographical && (patternPart == 'latitude' || patternPart == 'longitude')) {
                // geo field referencing part
                formattedPart = 'number_format($this->get' + patternPart.toFirstUpper + '(), 7, \'.\', \'\')'
            } else {
                // static part
                formattedPart = '\'' + patternPart.replace('\'', '') + '\''
            }
            result = result.concat(formattedPart.toString)
        }
        result
    }

    def private formatFieldValue(EntityField it, CharSequence value) {
        switch it {
            DecimalField: '''DataUtil::format«IF currency»Currency(«value»)«ELSE»Number(«value», 2)«ENDIF»'''
            FloatField: '''DataUtil::format«IF currency»Currency(«value»)«ELSE»Number(«value», 2)«ENDIF»'''
            ListField: '''$listHelper->resolve(«value», '«entity.name.formatForCode»', '«name.formatForCode»')'''
            DateField: '''DateUtil::formatDatetime(«value», 'datebrief')'''
            DatetimeField: '''DateUtil::formatDatetime(«value», 'datetimebrief')'''
            TimeField: '''DateUtil::formatDatetime(«value», 'timebrief')'''
            default: value
        }
    }

    /**
     * Initialises the validator instance. Used for 1.3.x target only, replaced by Symfony Validator in 1.4.x.
     */
    def private initValidator(Entity it) '''
        «val validatorClassLegacy = container.application.appName + '_Entity_Validator_' + name.formatForCodeCapital»
        /**
         * Initialises the validator and return it's instance.
         *
         * @return «validatorClassLegacy» The validator for this entity.
         */
        public function initValidator()
        {
            if (!is_null($this->_validator)) {
                return $this->_validator;
            }
            $this->_validator = new «validatorClassLegacy»($this);

            return $this->_validator;
        }
    '''

    def private initWorkflow(Entity it, Application app) '''
        /**
         * Sets/retrieves the workflow details.
         *
         * @param boolean $forceLoading load the workflow record.
         «IF !app.targets('1.3.5')»
         *
         * @throws RuntimeException Thrown if retrieving the workflow object fails
         «ENDIF»
         */
        public function initWorkflow($forceLoading = false)
        {
            $currentFunc = FormUtil::getPassedValue('func', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'GETPOST', FILTER_SANITIZE_STRING);
            $isReuse = FormUtil::getPassedValue('astemplate', '', 'GETPOST', FILTER_SANITIZE_STRING);

            «loadWorkflow»
        }
    '''

    def private resetWorkflow(Entity it, Application app) '''
        /**
         * Resets workflow data back to initial state.
         * To be used after cloning an entity object.
         */
        public function resetWorkflow()
        {
            $this->setWorkflowState('initial');

            $serviceManager = ServiceUtil::getManager();
            «IF app.targets('1.3.5')»
                $workflowHelper = new «app.appName»_Util_Workflow($serviceManager);
            «ELSE»
                $workflowHelper = $serviceManager->get('«app.appName.formatForDB».workflow_helper');
            «ENDIF»

            $schemaName = $workflowHelper->getWorkflowName($this['_objectType']);
            $this['__WORKFLOW__'] = array(
                'module' => '«app.appName»',
                'state' => $this['workflowState'],
                «IF app.targets('1.3.5')»
                    'obj_table' => $this['_objectType'],
                    'obj_idcolumn' => '«primaryKeyFields.head.name.formatForCode»',
                    'obj_id' => 0,
                «ELSE»
                    'objTable' => $this['_objectType'],
                    'objIdcolumn' => '«primaryKeyFields.head.name.formatForCode»',
                    'objId' => 0,
                «ENDIF»
                'schemaname' => $schemaName);
        }
    '''

    /**
     * Performs validation.
     */
    def private validate(Entity it) '''
        /**
         * Start validation and raise exception if invalid data is found.
         *
         * @return void.
        «IF container.application.targets('1.3.5')»
            «' '»*
            «' '»* @throws Zikula_Exception Thrown if a validation error occurs
        «ENDIF»
         */
        public function validate()
        {
            if ($this->_bypassValidation === true) {
                return;
            }

        «val emailFields = getDerivedFields.filter(EmailField)»
            «IF emailFields.size > 0»
                // decode possibly encoded mail addresses (#201)
                «FOR emailField : emailFields»
                    if (strpos($this['«emailField.name.formatForCode»'], '&#') !== false) {
                        $this['«emailField.name.formatForCode»'] = html_entity_decode($this['«emailField.name.formatForCode»']);
                    }
                «ENDFOR»
            «ENDIF»
            «IF container.application.targets('1.3.5')»
                $result = $this->initValidator()->validateAll();
                if (is_array($result)) {
                    throw new Zikula_Exception($result['message'], $result['code'], $result['debugArray']);
                }
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                $validator = $serviceManager->get('validator');
                $errors = $validator->validate($this);

                if (count($errors) > 0) {
                    $session = $serviceManager->get('session');
                    foreach ($errors as $error) {
                        $session->getFlashBag()->add('error', $error->getMessage());
                    }
                }
            «ENDIF»
        }
    '''

    def private toJson(Entity it) '''
        /**
         * Return entity data in JSON format.
         *
         * @return string JSON-encoded data.
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
         * @return Array The resulting arguments list.
         */
        public function createUrlArgs()
        {
            $args = array(«IF container.application.targets('1.3.5')»'ot' => $this['_objectType']«ENDIF»);

            «IF hasCompositeKeys»
                «FOR pkField : getPrimaryKeyFields»
                    $args['«pkField.name.formatForCode»'] = $this['«pkField.name.formatForCode»'];
                «ENDFOR»
            «ELSE»
                $args['«getFirstPrimaryKey.name.formatForCode»'] = $this['«getFirstPrimaryKey.name.formatForCode»'];
            «ENDIF»

            if (isset($this['slug'])) {
                $args['slug'] = $this['slug'];
            }

            return $args;
        }
    '''

    def private createCompositeIdentifier(Entity it) '''
        /**
         * Create concatenated identifier string (for composite keys).
         *
         * @return String concatenated identifiers.
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

    def private getHookAreaPrefix(Entity it) '''
        /**
         * Return lower case name of multiple items needed for hook areas.
         *
         * @return string
         */
        public function getHookAreaPrefix()
        {
            return '«container.application.name.formatForDB».ui_hooks.«nameMultiple.formatForDB»';
        }
    '''

    def private loadWorkflow(Entity it) '''
        «val app = container.application»
        // apply workflow with most important information
        $idColumn = '«primaryKeyFields.head.name.formatForCode»';

        $serviceManager = ServiceUtil::getManager();
        «IF app.targets('1.3.5')»
            $workflowHelper = new «app.appName»_Util_Workflow($serviceManager);
        «ELSE»
            $workflowHelper = $serviceManager->get('«app.appName.formatForDB».workflow_helper');
        «ENDIF»

        $schemaName = $workflowHelper->getWorkflowName($this['_objectType']);
        $this['__WORKFLOW__'] = array(
            'module' => '«app.appName»',
            'state' => $this['workflowState'],
            «IF app.targets('1.3.5')»
                'obj_table' => $this['_objectType'],
                'obj_idcolumn' => $idColumn,
                'obj_id' => $this[$idColumn],
            «ELSE»
                'objTable' => $this['_objectType'],
                'objIdcolumn' => $idColumn,
                'objId' => $this[$idColumn],
            «ENDIF»
            'schemaname' => $schemaName);

        // load the real workflow only when required (e. g. when func is edit or delete)
        if ((!in_array($currentFunc, array('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'view', 'display')) && empty($isReuse)) || $forceLoading) {
            $result = Zikula_Workflow_Util::getWorkflowForObject($this, $this['_objectType'], $idColumn, '«app.appName»');
            if (!$result) {
                $dom = ZLanguage::getModuleDomain('«app.appName»');
                «IF app.targets('1.3.5')»
                    LogUtil::registerError(__('Error! Could not load the associated workflow.', $dom));
                «ELSE»
                    $serviceManager = ServiceUtil::getManager();
                    $session = $serviceManager->get('session');
                    $session->getFlashBag()->add('error', __('Error! Could not load the associated workflow.', $dom));
                «ENDIF»
            }
        }

        if (!is_object($this['__WORKFLOW__']) && !isset($this['__WORKFLOW__']['schemaname'])) {
            $workflow = $this['__WORKFLOW__'];
            $workflow['schemaname'] = $schemaName;
            $this['__WORKFLOW__'] = $workflow;
        }
    '''

    def private toStringImpl(Entity it, Application app) '''
        /**
         * ToString interceptor implementation.
         * This method is useful for debugging purposes.
         */
        public function __toString()
        {
            «IF hasCompositeKeys»
                $output = '';
                «FOR field : primaryKeyFields»
                    if (!empty($output)) {
                        $output .= "\n";
                    }
                    $output .= $this->get«field.name.formatForCodeCapital»();
                «ENDFOR»

                return $output;
            «ELSE»
                return $this->get«primaryKeyFields.head.name.formatForCodeCapital»();
            «ENDIF»
        }
    '''

    def private relatedObjectsImpl(Entity it, Application app) '''
        /**
         * Returns an array of all related objects that need to be persited after clone.
         * 
         * @param array $objects The objects are added to this array. Default: array()
         * 
         * @return array of entity objects.
         */
        public function getRelatedObjectsToPersist(&$objects = array()) {
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
                return array();
             «ENDIF»
         }
    '''

    def private cloneImpl(Entity it, Application app, Property thProp) '''
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
         * (4) http://www.pantovic.com/article/26/doctrine2-entity-cloning
         */
        public function __clone()
        {
            // If the entity has an identity, proceed as normal.
            if («FOR field : primaryKeyFields SEPARATOR ' && '»$this->«field.name.formatForCode»«ENDFOR») {
                // unset identifiers
                «FOR field : primaryKeyFields»
                    $this->set«field.name.formatForCodeCapital»(«thProp.defaultFieldData(field)»);
                «ENDFOR»
                «IF app.targets('1.3.5')»

                    // init validator
                    $this->initValidator();
                «ENDIF»

                // reset Workflow
                $this->resetWorkflow();
                «IF hasUploadFieldsEntity»

                    // reset upload fields
                    «FOR field : getUploadFieldsEntity»
                        $this->set«field.name.formatForCodeCapital»('');
                        $this->set«field.name.formatForCodeCapital»Meta(array());
                    «ENDFOR»
                «ENDIF»
                «IF standardFields»

                    $this->setCreatedDate(null);
                    $this->setCreatedUserId(null);
                    $this->setUpdatedDate(null);
                    $this->setUpdatedUserId(null);
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
                «/* TODO consider other extensions here (meta data, translatable, loggable, maybe more) */»
            }
            // otherwise do nothing, do NOT throw an exception!
        }
    '''
}