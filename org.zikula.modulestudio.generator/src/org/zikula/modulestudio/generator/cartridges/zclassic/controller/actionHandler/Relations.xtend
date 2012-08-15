package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Relation processing functions for edit form handlers.
 */
class Relations {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def incomingInitialisation(Entity it) '''
        «val uniOwningAssociations = getIncomingJoinRelations.filter(e|!e.bidirectional).filter(e|e.source.container.application == it.container.application)»
        «IF !uniOwningAssociations.isEmpty»

            // save parent identifiers of unidirectional incoming relationships
            «FOR uniOwningAssociation : uniOwningAssociations»
                $this->incomingIds['«uniOwningAssociation.getRelationAliasName(false)»'] = FormUtil::getPassedValue('«uniOwningAssociation.getRelationAliasName(false)»', '', 'GET');
            «ENDFOR»
        «ENDIF»
    '''

    def initRelatedObjectDefault(JoinRelationship it, Boolean incoming) '''
        «val useTarget = !incoming»
        «val relationAliasName = getRelationAliasName(useTarget).toFirstLower»
        «val many = it.isManySide(useTarget)»
        $entity['«relationAliasName»'] = $this->retrieveRelatedObjects('«(if (incoming) source else target).name.formatForCode»', '«relationAliasName.formatForDB»', «IF !many»false«ELSE»true«ENDIF»);
    '''

    def dispatch reassignRelatedObjects(Controller it) '''
        /**
         * Reassign options chosen by the user to avoid unwanted form state resets.
         * Necessary until issue #23 is solved.
         */
        public function reassignRelatedObjects()
        {
            // stub for subclasses
        }
    '''

    def dispatch reassignRelatedObjects(Entity it) '''
        /**
         * Reassign options chosen by the user to avoid unwanted form state resets.
         * Necessary until issue #23 is solved.
         */
        public function reassignRelatedObjects()
        {
            $selectedRelations = array();
            «FOR relation : incoming.filter(typeof(JoinRelationship)).filter(e|e.bidirectional).filter(e|e.source.container.application == it.container.application)»«relation.reassignRelatedObjects(true)»«ENDFOR»
            «FOR relation : outgoing.filter(typeof(JoinRelationship)).filter(e|e.target.container.application == it.container.application)»«relation.reassignRelatedObjects(false)»«ENDFOR»
            $this->view->assign('selectedRelations', $selectedRelations);
        }
    '''

    def private reassignRelatedObjects(JoinRelationship it, Boolean incoming) '''
        «val useTarget = !incoming»
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val many = it.isManySide(useTarget)»
        «val uniqueNameForJs = getUniqueRelationNameForJs(container.application, (if (incoming) target else source), false, incoming, relationAliasName)»
        // reassign the «(if (incoming) source else target).getEntityNameSingularPlural(many).formatForDisplay» eventually chosen by the user
        $selectedRelations['«relationAliasName.toFirstLower»'] = «retrieveRelatedObjectsCall((if (incoming) source else target).name, uniqueNameForJs, many)»;
    '''

    /**
     * Assign input value from incoming 1:1 and 1:n relationships (example: get customerid for an order).
     * As the autocomplete fields are not done with a Form plugin (yet, see #23), we do that manually.
     */
    def fetchRelationValue(JoinRelationship it, Boolean incoming) '''
        «IF !incoming || bidirectional || tempFetchRelationValueIsManyToMany»
            «val relationAliasName = getRelationAliasName(!incoming).formatForCodeCapital»
            «val uniqueNameForJs = getUniqueRelationNameForJs(container.application, target, false, incoming, relationAliasName)»
            $entityData['«relationAliasName.toFirstLower»'] = ((isset($selectedRelations['«relationAliasName.toFirstLower»'])) ? $selectedRelations['«relationAliasName.toFirstLower»'] : «retrieveRelatedObjectsCall((if (incoming) source else target).name, uniqueNameForJs, false)»);
            «IF !nullable»
                if (!$entityData['«relationAliasName.toFirstLower»']) {
                    return LogUtil::registerError($this->__('Invalid value received for relation field "«relationAliasName.formatForDisplay»".'));
                }
            «ENDIF»
        «ENDIF»
    '''

    def private tempFetchRelationValueIsManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }

    def private retrieveRelatedObjectsCall(Object it, String objectType, String uniqueNameForJs, Boolean many) '''$this->retrieveRelatedObjects('«objectType.formatForCode»', '«uniqueNameForJs»ItemList', «IF !many»false«ELSE»true«ENDIF», 'POST')'''

    def retrieveRelatedObjects(Controller it, Application app) '''
        /**
         * Select a related object in create mode.
         *
         * @param string  $objectType             The currently treated object type.
         * @param string  $relationInputFieldName Name of input field for storing the relations.
         * @param boolean $many                   Whether one or many objects are assigned.
         * @param string  $source                 The data source used (GET or POST).
         *
         * @return array Single result or list of results.
         */
        protected function retrieveRelatedObjects($objectType, $relationInputFieldName, $many = false, $source = 'GET')
        {
            $repository = $this->entityManager->getRepository($this->name . '_Entity_' . ucfirst($objectType));

            $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

            $where = '';

            $inputValue = '';
            if ($source == 'POST') {
                $inputValue = $this->request->request->get($relationInputFieldName, '');
            } else {
                $inputValue = $this->request->query->get($relationInputFieldName, '');
            }
            if (empty($inputValue)) {
                return $many ? array() : null;
            }

            $inputValueParts = explode('_', $inputValue);
            $i = 0;
            foreach ($idFields as $idField) {
                if (!empty($where)) {
                    $where .= ' AND ';
                }

                if ($many) {
                    $where .= 'tbl.' . $idField . ' IN (' . DataUtil::formatForStore($inputValueParts[$i]) . ')';
                } else {
                    $where .= 'tbl.' . $idField . ' = ' . DataUtil::formatForStore($inputValueParts[$i]);
                }
                $i++;
            }
            $selectionArgs = array(
                'ot' => $objectType,
                'where' => $where,
                'orderBy' => $repository->getDefaultSortingField() . ' asc',
                'currentPage' => 1,
                'resultsPerPage' => 50
            );
            list($entities, $objectCount) = ModUtil::apiFunc($this->name, 'selection', 'getEntitiesPaginated', $selectionArgs);
            return (($many) ? $entities : $entities[0]);
        }
    '''



    def updateRelationLinks(Entity it) '''
        /**
         * Helper method for updating links to related records.
         *
         * @param object $entity Currently treated entity instance.
         */
        protected function updateRelationLinks($entity)
        {
            «FOR relation : incoming.filter(typeof(ManyToManyRelationship)).filter(e|e.source.container.application == it.container.application)»«relation.updateRelationLinks(true)»«ENDFOR»
            «FOR relation : outgoing.filter(typeof(JoinRelationship)).filter(e|e.target.container.application == it.container.application)»«relation.updateRelationLinks(false)»«ENDFOR»
        }
    '''

    def private updateRelationLinks(JoinRelationship it, Boolean incoming) '''
        «val relationAliasName = getRelationAliasName(!incoming).formatForCodeCapital»
        «val relationAliasNameReverse = getRelationAliasName(incoming).formatForCodeCapital»
        «val many = isManySide(!incoming)»
        «val manyOtherSide = isManySide(incoming)»
        «val uniqueNameForJs = getUniqueRelationNameForJs(container.application, (if (incoming) target else source), false, incoming, relationAliasName)»
        «IF many && getEditStageCode(incoming) > 0»
        «IF (incoming && bidirectional) || many»«/*only incoming for now, see https://github.com/Guite/MostGenerator/issues/10*/»
            $relatedIds = $this->request->request->get('«uniqueNameForJs»ItemList', '');
            if ($this->mode != 'create') {
                // remove all existing references
                «IF many»
                    «IF !incoming»
                        foreach ($entity->get«relationAliasName»() as $relatedItem) {
                            «IF bidirectional»
                                «IF manyOtherSide»
                                    $relatedItem->remove«relationAliasNameReverse.toFirstUpper»($entity);
                                «ELSE»
                                    $relatedItem->set«relationAliasNameReverse.toFirstUpper»(null);
                                «ENDIF»
                            «ENDIF»
                            $entity->remove«relationAliasName»($relatedItem);
                        }
                    «ELSEIF bidirectional»
                        foreach ($entity->get«relationAliasName»() as $relatedItem) {
                            «IF manyOtherSide»
                                $relatedItem->remove«relationAliasNameReverse.toFirstUpper»($entity);
                            «ELSE»
                                $relatedItem->set«relationAliasNameReverse.toFirstUpper»(null);
                            «ENDIF»
                            $entity->remove«relationAliasName»($relatedItem);
                        }
                    «ENDIF»
                «ELSEIF nullable && (!incoming || bidirectional)»
                    $entity->set«relationAliasName»(null);
                «ENDIF»
            }
            if (!empty($relatedIds)) {
                if (!is_array($relatedIds)) {
                    $relatedIds = explode(',', $relatedIds);
                }
                «val objectType = (if (incoming) source else target).name.formatForCode»
                if (is_array($relatedIds) && count($relatedIds)) {
                    $idFields = ModUtil::apiFunc('«container.application.appName»', 'selection', 'getIdFields', array('ot' => '«objectType»'));
                    $relatedIdValues = $this->decodeCompositeIdentifier($relatedIds, $idFields);

                    $where = '';
                    foreach ($idFields as $idField) {
                        if (!empty($where)) {
                            $where .= ' AND ';
                        }
                        $where .= 'tbl.' . $idField . ' IN (' . implode(', ', $relatedIdValues[$idField]) . ')';
                    }
                    $linkObjects = ModUtil::apiFunc($this->name, 'selection', 'getEntities', array('ot' => '«objectType»', 'where' => $where));
                    «IF !incoming || bidirectional»
                        if (!is_object($entity->get«relationAliasName»())) {
                            $entity->set«relationAliasName»(new Doctrine\Common\Collections\ArrayCollection());
                        }
                    «ENDIF»
                    // create new links
                    foreach ($linkObjects as $relatedObject) {
                        «IF many»
                            if ($entity->get«relationAliasName»()->contains($relatedObject)) {
                                continue;
                            }
                            $entity->add«relationAliasName»($relatedObject);
                        «ELSEIF !incoming || bidirectional»
                            $entity->set«relationAliasName»($relatedObject);
                        «ENDIF»
                    }
                }
            }
        «ENDIF»
        «ENDIF»
    '''
}
