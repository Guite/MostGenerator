package org.zikula.modulestudio.generator.cartridges.symfony.models.entity

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class EntityConstructor {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def constructor(Entity it) '''
        /**
         * «name.formatForCodeCapital» constructor.
         *
         * Will not be called by Doctrine and can therefore be used
         * for own implementation purposes. It is also possible to add
         * arbitrary arguments as with every other class method.«/*IF isIndexByTarget»
         *
         * @param string $«getIndexByRelation.getIndexByField.formatForCode» Indexing field
         * @param «getIndexByRelation.source.name.formatForCodeCapital» $«getRelationAliasName(getIndexByRelation, false).formatForCode» Indexing relationship
         «ENDIF*/»
         */
        public function __construct(«constructorArguments»)
        {
            «constructorImpl»
        }
    '''

    def private constructorArguments(Entity it) '''
        «IF isIndexByTarget»
            «val indexRelation = getIndexByRelation»
            «val sourceAlias = getRelationAliasName(indexRelation, false)»
            «val indexBy = indexRelation.getIndexByField»
            string $«indexBy.formatForCode», «indexRelation.source.name.formatForCodeCapital» $«sourceAlias.formatForCode»
        «ENDIF»
    '''

    def private getIndexByRelation(Entity it) {
        incoming.filter[isIndexed].head
    }

    def private constructorImpl(Entity it) '''
        $this->set«getPrimaryKey.name.formatForCodeCapital»(Uuid::v4());
        «FOR field : getUploadFieldsEntity»
            $this->«field.name.formatForCode» = new EmbeddedFile();
        «ENDFOR»
        «IF isIndexByTarget»

            «val indexRelation = incoming.filter[isIndexed].head»
            «val sourceAlias = getRelationAliasName(indexRelation, false)»
            «val targetAlias = getRelationAliasName(indexRelation, true)»
            «val indexBy = indexRelation.getIndexByField»
            $this->«indexBy.formatForCode» = $«indexBy.formatForCode»;
            $this->«sourceAlias.formatForCode» = $«sourceAlias.formatForCode»;
            $«sourceAlias.formatForCode»->add«targetAlias.formatForCodeCapital»($this);
        «ENDIF»
        «new Association().initCollections(it)»
    '''
}
