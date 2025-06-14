package org.zikula.modulestudio.generator.cartridges.symfony.controller.actionhandler

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.Relationship
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class RelationPresets {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def memberFields(Application it) '''

        /**
         * List of identifiers for predefined relationships.
         */
        protected array $relationPresets = [];
    '''

    def baseMethod(Application it) '''

        /**
         * Initialises relationship presets.
         */
        protected function initRelationPresets(): void
        {
            // to be customised in sub classes
        }
    '''

    def callBaseMethod(Application it) '''

        $this->initRelationPresets();
    '''

    def childMethod(Entity it) '''
        «val owningAssociations = getOwningAssociations(application)»
        «val ownedMMAssociations = getOwnedMMAssociations(application)»
        «IF !owningAssociations.empty || !ownedMMAssociations.empty»

            protected function initRelationPresets(): void
            {
                $entity = $this->entityRef;
                «initPresets»

                // save entity reference for later reuse
                $this->entityRef = $entity;
            }
        «ENDIF»
    '''

    def initPresets(Entity it) '''
        «val owningAssociations = getOwningAssociations(application)»
        «val ownedMMAssociations = getOwnedMMAssociations(application)»
        «IF !owningAssociations.empty»

            // assign identifiers of predefined incoming relationships
            «FOR relation : owningAssociations»
                «IF !relation.isShownInForm(true)»
                    // non-editable relation, we store the id and assign it in handleCommand
                «ELSE»
                    // editable relation, we store the id and assign it now to show it in UI
                «ENDIF»
                «relation.initSinglePreset(false)»
                «IF relation.isShownInForm(true)»
                    «relation.saveSinglePreset(false)»
                «ENDIF»
            «ENDFOR»
        «ENDIF»
        «IF !ownedMMAssociations.empty»

            // assign identifiers of predefined outgoing many to many relationships
            «FOR relation : ownedMMAssociations»
                «IF !relation.isShownInForm(false)»
                    // non-editable relation, we store the id and assign it in handleCommand
                «ELSE»
                    // editable relation, we store the id and assign it now to show it in UI
                «ENDIF»
                «relation.initSinglePreset(true)»
                «IF relation.isShownInForm(false)»
                    «relation.saveSinglePreset(true)»
                «ENDIF»
            «ENDFOR»
        «ENDIF»
    '''

    def private initSinglePreset(Relationship it, Boolean useTarget) '''
        «val alias = getRelationAliasName(useTarget)»
        $this->relationPresets['«alias»'] = $this->requestStack->getCurrentRequest()->query->get('«alias»', '');
    '''

    def private getOwningAssociations(Entity it, Application refApp) {
        getBidirectionalIncomingRelations
            .filter[source.application == refApp]
    }

    def private getOwnedMMAssociations(Entity it, Application refApp) {
        outgoing
            .filter(ManyToManyRelationship)
            .filter[source.application == refApp]
    }

    def private isShownInForm(Relationship it, Boolean incoming) {
        getEditStageCode(incoming) > 0
    }

    def saveNonEditablePresets(Entity it, Application app) '''
        «val owningAssociationsNonEditable = getOwningAssociations(app).filter[!isShownInForm(true)]»
        «val ownedMMAssociationsNonEditable = getOwnedMMAssociations(app).filter[!isShownInForm(false)]»
        «IF !owningAssociationsNonEditable.empty || !ownedMMAssociationsNonEditable.empty»

            if ('create' == $this->templateParameters['mode']) {
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
                $this->entityFactory->getEntityManager()->flush();
            }
        «ENDIF»
    '''

    def private saveSinglePreset(Relationship it, Boolean useTarget) '''
        «val alias = getRelationAliasName(useTarget)»
        «val aliasInverse = getRelationAliasName(!useTarget)»
        «val otherEntity = (if (useTarget) target else source)»
        «val otherObjectType = otherEntity.name.formatForCode»
        «val selectField = if (otherEntity.hasSluggableFields) 'slug' else 'id'»
        if (!empty($this->relationPresets['«alias»'])) {
            $repository = $this->entityFactory->getRepository('«otherObjectType»');
            $relObj = $repository->selectBy«selectField.toFirstUpper»($this->relationPresets['«alias»']);
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
