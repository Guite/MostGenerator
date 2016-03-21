package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityField
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.TimeField
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityMethods {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def dispatch generate(DataObject it, Application app, Property thProp) '''
        «IF !app.targets('1.3.x')»
            «validationMethods»
        «ENDIF»

        «validate»

        «relatedObjectsImpl(app)»

        «toStringImpl(app)»

        «cloneImpl(app, thProp)»
    '''

    def dispatch generate(Entity it, Application app, Property thProp) '''
        «propertyChangedListener»

        «getTitleFromDisplayPattern(app)»

        «IF app.targets('1.3.x')»
            «initValidator»
        «ELSE»
            «validationMethods»
        «ENDIF»

        «initWorkflow(app)»

        «resetWorkflow(app)»

        «validate»

        «toJson»

        «new ItemActions().prepareItemActions(it, app)»

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
            «IF hasListFieldsEntity»
                $serviceManager = ServiceUtil::getManager();
                «IF app.targets('1.3.x')»
                    $listHelper = new «app.appName»_Util_ListEntries(ServiceUtil::getManager());
                «ELSE»
                    $listHelper = $serviceManager->get('«app.appName.formatForDB».listentries_helper');
                «ENDIF»

            «ENDIF»
            $formattedTitle = «parseDisplayPattern»;

            return $formattedTitle;
        }
    '''

    def private parseDisplayPattern(Entity it) {
        var result = ''
        var usedDisplayPattern = displayPattern

        if (isInheriting && (null === usedDisplayPattern || usedDisplayPattern == '')) {
            // fetch inherited display pattern from parent entity
            if (parentType instanceof Entity) {
                usedDisplayPattern = (parentType as Entity).displayPattern
            }
        }

        if (null === usedDisplayPattern || usedDisplayPattern == '') {
            usedDisplayPattern = name.formatForDisplay
        }

        val patternParts = usedDisplayPattern.split('#')
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
        «val validatorClassLegacy = application.appName + '_Entity_Validator_' + name.formatForCodeCapital»
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
         «IF !app.targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if retrieving the workflow object fails
         «ENDIF»
         */
        public function initWorkflow($forceLoading = false)
        {
            $currentFunc = FormUtil::getPassedValue('func', '«IF app.targets('1.3.x')»main«ELSE»index«ENDIF»', 'GETPOST', FILTER_SANITIZE_STRING);
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
            «IF app.targets('1.3.x')»
                $workflowHelper = new «app.appName»_Util_Workflow($serviceManager);
            «ELSE»
                $workflowHelper = $serviceManager->get('«app.appName.formatForDB».workflow_helper');
            «ENDIF»

            $schemaName = $workflowHelper->getWorkflowName($this['_objectType']);
            $this['__WORKFLOW__'] = «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                'module' => '«app.appName»',
                'state' => $this['workflowState'],
                'obj_table' => $this['_objectType'],
                'obj_idcolumn' => '«primaryKeyFields.head.name.formatForCode»',
                'obj_id' => 0,
                'schemaname' => $schemaName
            «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
        }
    '''

    /**
     * Performs validation.
     */
    def private validate(DataObject it) '''
        /**
         * Start validation and raise exception if invalid data is found.
         *
        «IF application.targets('1.3.x')»
            «' '»* @return void.
            «' '»*
            «' '»* @throws Zikula_Exception Thrown if a validation error occurs
        «ELSE»
            «' '»* @return boolean Whether everything is valid or not.
        «ENDIF»
         */
        public function validate()
        {
            if ($this->_bypassValidation === true) {
                return«IF !application.targets('1.3.x')» true«ENDIF»;
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
            «IF application.targets('1.3.x')»
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
                        $session->getFlashBag()->add(\Zikula_Session::MESSAGE_ERROR, $error->getMessage());
                    }
                    return false;
                }
            «ENDIF»

            return true;
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
         * @return array The resulting arguments list.
         */
        public function createUrlArgs()
        {
            $args = «IF application.targets('1.3.x')»array('ot' => $this['_objectType'])«ELSE»[]«ENDIF»;

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
            return '«IF application.targets('1.3.x')»«application.name.formatForDB»«ELSE»«application.appName.formatForDB»«ENDIF».ui_hooks.«nameMultiple.formatForDB»';
        }
    '''

    def private loadWorkflow(Entity it) '''
        // apply workflow with most important information
        $idColumn = '«primaryKeyFields.head.name.formatForCode»';

        $serviceManager = ServiceUtil::getManager();
        «IF application.targets('1.3.x')»
            $workflowHelper = new «application.appName»_Util_Workflow($serviceManager);
        «ELSE»
            $workflowHelper = $serviceManager->get('«application.appName.formatForDB».workflow_helper');
        «ENDIF»

        $schemaName = $workflowHelper->getWorkflowName($this['_objectType']);
        $this['__WORKFLOW__'] = «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»
            'module' => '«application.appName»',
            'state' => $this['workflowState'],
            'obj_table' => $this['_objectType'],
            'obj_idcolumn' => $idColumn,
            'obj_id' => $this[$idColumn],
            'schemaname' => $schemaName
        «IF application.targets('1.3.x')»)«ELSE»]«ENDIF»;

        // load the real workflow only when required (e. g. when func is edit or delete)
        if ((!in_array($currentFunc, «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»'«IF application.targets('1.3.x')»main«ELSE»index«ENDIF»', 'view', 'display'«IF application.targets('1.3.x')»)«ELSE»]«ENDIF») && empty($isReuse)) || $forceLoading) {
            $result = Zikula_Workflow_Util::getWorkflowForObject($this, $this['_objectType'], $idColumn, '«application.appName»');
            if (!$result) {
                «IF application.targets('1.3.x')»
                    $dom = ZLanguage::getModuleDomain('«application.appName»');
                    LogUtil::registerError(__('Error! Could not load the associated workflow.', $dom));
                «ELSE»
                    $serviceManager = ServiceUtil::getManager();
                    $session = $serviceManager->get('session');
                    $session->getFlashBag()->add(\Zikula_Session::MESSAGE_ERROR, $serviceManager->get('translator.default')->__('Error! Could not load the associated workflow.'));
                «ENDIF»
            }
        }

        if (!is_object($this['__WORKFLOW__']) && !isset($this['__WORKFLOW__']['schemaname'])) {
            $workflow = $this['__WORKFLOW__'];
            $workflow['schemaname'] = $schemaName;
            $this['__WORKFLOW__'] = $workflow;
        }
    '''

    def private toStringImpl(DataObject it, Application app) '''
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

    def private relatedObjectsImpl(DataObject it, Application app) '''
        /**
         * Returns an array of all related objects that need to be persisted after clone.
         * 
         * @param array $objects The objects are added to this array. Default: «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»
         * 
         * @return array of entity objects.
         */
        public function getRelatedObjectsToPersist(&$objects = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF») 
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
                return «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»;
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
            // If the entity has an identity, proceed as normal.
            if («FOR field : primaryKeyFields SEPARATOR ' && '»$this->«field.name.formatForCode»«ENDFOR») {
                // unset identifiers
                «FOR field : primaryKeyFields»
                    $this->set«field.name.formatForCodeCapital»(«thProp.defaultFieldData(field)»);
                «ENDFOR»
                «IF app.targets('1.3.x')»

                    // init validator
                    $this->initValidator();
                «ENDIF»

                // reset Workflow
                $this->resetWorkflow();
                «IF hasUploadFieldsEntity»

                    // reset upload fields
                    «FOR field : getUploadFieldsEntity»
                        $this->set«field.name.formatForCodeCapital»('');
                        $this->set«field.name.formatForCodeCapital»Meta(«IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»);
                    «ENDFOR»
                «ENDIF»
                «IF it instanceof Entity && (it as Entity).standardFields»

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
                «/* TODO consider other extensions here (meta data, translatable, loggable, maybe more) */»
            }
            // otherwise do nothing, do NOT throw an exception!
        }
    '''
}
