package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class RelationPresets {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def memberFields(Application it) '''

        /**
         * List of identifiers for predefined relationships.
         *
         * @var mixed
         */
        protected $relationPresets = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
    '''

    def initPresets(Entity it) '''
        «val owningAssociations = getOwningAssociations(it.application)»
        «val ownedMMAssociations = getOwnedMMAssociations(it.application)»
        «IF !application.targets('1.3.x') && (!owningAssociations.empty || !ownedMMAssociations.empty)»
            $selectionHelper = $this->get('«application.appService».selection_helper');
        «ENDIF»
        «IF !owningAssociations.empty»

            // assign identifiers of predefined incoming relationships
            «FOR relation : owningAssociations»
                «IF !relation.isEditable(false)»
                    // non-editable relation, we store the id and assign it in handleCommand
                «ELSE»
                    // editable relation, we store the id and assign it now to show it in UI
                «ENDIF»
                «relation.initSinglePreset(false)»
                «IF relation.isEditable(false)»
                    «relation.saveSinglePreset(false)»
                «ENDIF»
            «ENDFOR»
        «ENDIF»
        «IF !ownedMMAssociations.empty»

            // assign identifiers of predefined outgoing many to many relationships
            «FOR relation : ownedMMAssociations»
                «IF !relation.isEditable(true)»
                    // non-editable relation, we store the id and assign it in handleCommand
                «ELSE»
                    // editable relation, we store the id and assign it now to show it in UI
                «ENDIF»
                «relation.initSinglePreset(true)»
                «IF relation.isEditable(true)»
                    «relation.saveSinglePreset(true)»
                «ENDIF»
            «ENDFOR»
        «ENDIF»
    '''

    def private initSinglePreset(JoinRelationship it, Boolean useTarget) '''
        «val alias = getRelationAliasName(useTarget)»
        «IF source.application.targets('1.3.x')»
            $this->relationPresets['«alias»'] = FormUtil::getPassedValue('«alias»', '', 'GET');
        «ELSE»
            $this->relationPresets['«alias»'] = $this->request->get('«alias»', '');
        «ENDIF»
    '''

    def private getOwningAssociations(Entity it, Application refApp) {
        getBidirectionalIncomingJoinRelations
            .filter[source.application == refApp]
    }

    def private getOwnedMMAssociations(Entity it, Application refApp) {
        getOutgoingJoinRelations
            .filter(ManyToManyRelationship)
            .filter[source.application == refApp]
    }

    def private isEditable(JoinRelationship it, Boolean useTarget) {
        getEditStageCode(!useTarget) > 0
    }

    def saveNonEditablePresets(Entity it, Application app) '''
        «val owningAssociationsNonEditable = getOwningAssociations(app).filter[!isEditable(false)]»
        «val ownedMMAssociationsNonEditable = getOwnedMMAssociations(app).filter[!isEditable(true)]»
        «IF !owningAssociationsNonEditable.empty || !ownedMMAssociationsNonEditable.empty»

            if ($args['commandName'] == 'create') {
                «IF !app.targets('1.3.x')»
                    $selectionHelper = $this->get('«app.appService».selection_helper');
                «ENDIF»
                «IF !owningAssociationsNonEditable.empty»
                // save predefined incoming relationship from parent entity
                «FOR relation : owningAssociationsNonEditable»
                    «relation.saveSinglePreset(false)»
                «ENDFOR»
                «ENDIF»
                «IF !ownedMMAssociationsNonEditable.empty»
                // save predefined outgoing relationship to child entity
                «FOR relation : ownedMMAssociationsNonEditable»
                    «relation.saveSinglePreset(true)»
                «ENDFOR»
                «ENDIF»
                «IF app.targets('1.3.x')»
                    $this->entityManager->flush();
                «ELSE»
                    $this->container->get('doctrine.orm.entity_manager')->flush();
                «ENDIF»
            }
        «ENDIF»
    '''

    def private saveSinglePreset(JoinRelationship it, Boolean useTarget) '''
        «val alias = getRelationAliasName(useTarget)»
        «val aliasInverse = getRelationAliasName(!useTarget)»
        «val otherObjectType = (if (useTarget) target else source).name.formatForCode»
        if (!empty($this->relationPresets['«alias»'])) {
            «IF application.targets('1.3.x')»
                $relObj = ModUtil::apiFunc('«application.appName»', 'selection', 'getEntity', array('ot' => '«otherObjectType»', 'id' => $this->relationPresets['«alias»']));
            «ELSE»
                $relObj = $selectionHelper->getEntity('«otherObjectType»', $this->relationPresets['«alias»']);
            «ENDIF»
            if (null !== $relObj) {
                «IF !useTarget && it instanceof ManyToManyRelationship»
                    $entity->«IF isManySide(useTarget)»add«ELSE»set«ENDIF»«alias.toFirstUpper»($relObj);
                «ELSE»
                    $relObj->«IF isManySide(!useTarget)»add«ELSE»set«ENDIF»«aliasInverse.toFirstUpper»($entity);
                «ENDIF»
            }
        }
    '''
}
