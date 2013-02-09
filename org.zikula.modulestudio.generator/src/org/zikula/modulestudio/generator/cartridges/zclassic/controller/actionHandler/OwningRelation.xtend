package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions

class OwningRelation {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    def memberFields(Controller it) '''

        /**
         * List of identifiers for incoming relationships.
         *
         * @var mixed
         */
        protected $incomingIds = array();
    '''

    def initOwningAssociation(Entity it) '''
        «val owningAssociations = getOwningAssociations(it.container.application)»
        «IF !owningAssociations.isEmpty»

            // save parent identifiers of incoming relationships
            «FOR relation : owningAssociations»
                $this->incomingIds['«relation.getRelationAliasName(false)»'] = FormUtil::getPassedValue('«relation.getRelationAliasName(false)»', '', 'GET');
            «ENDFOR»
        «ENDIF»
        «val ownedMMAssociations = getOwnedMMAssociations(it.container.application)»
        «IF !ownedMMAssociations.isEmpty»

            // save identifiers of outgoing many to many relationships
            «FOR relation : ownedMMAssociations»
                $this->incomingIds['«relation.getRelationAliasName(true)»'] = FormUtil::getPassedValue('«relation.getRelationAliasName(true)»', '', 'GET');
            «ENDFOR»
        «ENDIF»
    '''

    def private getOwningAssociations(Entity it, Application refApp) {
        getIncomingJoinRelations
            .filter(e|e.source.container.application == refApp)
            .filter(e|e.getEditStageCode(true) == 0)
    }

    def private getOwnedMMAssociations(Entity it, Application refApp) {
        getOutgoingJoinRelations
            .filter(typeof(ManyToManyRelationship))
            .filter(e|e.source.container.application == refApp)
            .filter(e|e.getEditStageCode(false) == 0)
    }

    def saveOwningAssociation(Entity it, Application app) '''
        «val owningAssociations = getOwningAssociations(app)»
        «IF !owningAssociations.isEmpty»

            // save incoming relationship from parent entity
            if ($args['commandName'] == 'create') {
                «FOR owningAssociation : owningAssociations»
                    if (!empty($this->incomingIds['«owningAssociation.getRelationAliasName(false)»'])) {
                        $relObj = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => '«owningAssociation.source.name.formatForCode»', 'id' => $this->incomingIds['«owningAssociation.getRelationAliasName(false)»']));
                        if ($relObj != null) {
                            $relObj->add«owningAssociation.getRelationAliasName(true).toFirstUpper»($entity);
                        }
                    }
                «ENDFOR»
                $this->entityManager->flush();
            }
        «ENDIF»
        «val ownedMMAssociations = getOwnedMMAssociations(app)»
        «IF !ownedMMAssociations.isEmpty»

            // save outgoing relationship to child entity
            if ($args['commandName'] == 'create') {
                «FOR ownedMMAssociation : ownedMMAssociations»
                    if (!empty($this->incomingIds['«ownedMMAssociation.getRelationAliasName(true)»'])) {
                        $relObj = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => '«ownedMMAssociation.target.name.formatForCode»', 'id' => $this->incomingIds['«ownedMMAssociation.getRelationAliasName(true)»']));
                        if ($relObj != null) {
                            $relObj->add«ownedMMAssociation.getRelationAliasName(false).toFirstUpper»($entity);
                        }
                    }
                «ENDFOR»
                $this->entityManager->flush();
            }
        «ENDIF»
    '''
}
