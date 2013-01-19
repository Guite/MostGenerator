package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class OwningRelation {
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
        «val uniOwningAssociations = getUnidirectionalOwningAssociations(it.container.application)»
        «IF !uniOwningAssociations.isEmpty»

            // save parent identifiers of unidirectional incoming relationships
            «FOR relation : uniOwningAssociations»
                $this->incomingIds['«relation.getRelationAliasName(false)»'] = \FormUtil::getPassedValue('«relation.getRelationAliasName(false)»', '', 'GET');
            «ENDFOR»
        «ENDIF»
    '''

    def private getUnidirectionalOwningAssociations(Entity it, Application refApp) {
        getIncomingJoinRelations.filter(e|!e.bidirectional).filter(e|e.source.container.application == refApp)
    }

    def saveOwningAssociation(Entity it, Application app) '''
        «val uniOwningAssociations = getUnidirectionalOwningAssociations(app)»
        «IF !uniOwningAssociations.isEmpty»

            // save incoming relationship from parent entity
            if ($args['commandName'] == 'create') {
            «FOR uniOwningAssociation : uniOwningAssociations»
                if (!empty($this->incomingIds['«uniOwningAssociation.getRelationAliasName(false)»'])) {
                    $relObj = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => '«uniOwningAssociation.source.name.formatForCode»', 'id' => $this->incomingIds['«uniOwningAssociation.getRelationAliasName(false)»']));
                    if ($relObj != null) {
                        $relObj->add«uniOwningAssociation.getRelationAliasName(true).toFirstUpper»($entity);
                    }
                }
            «ENDFOR»
                $this->entityManager->flush();
            }
        «ENDIF»
    '''
}
