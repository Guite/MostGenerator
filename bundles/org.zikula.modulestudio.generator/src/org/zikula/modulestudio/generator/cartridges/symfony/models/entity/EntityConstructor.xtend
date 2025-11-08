package org.zikula.modulestudio.generator.cartridges.symfony.models.entity

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class EntityConstructor {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    def constructor(Entity it) '''
        /**
         * «name.formatForCodeCapital» constructor.
         *
         * Will not be called by Doctrine and can therefore be used
         * for own implementation purposes. It is also possible to add
         * arbitrary arguments as with every other class method. They
         * should be nullable though because of the limitation reported
         * at https://github.com/EasyCorp/EasyAdminBundle/issues/6957 issue.
         */
        public function __construct()
        {
            «constructorImpl»
        }
    '''

    def private constructorImpl(Entity it) '''
        $this->set«getPrimaryKey.name.formatForCodeCapital»(Uuid::v4());
        «FOR field : getUploadFieldsEntity»
            $this->«field.name.formatForCode» = new EmbeddedFile();
        «ENDFOR»
        «new Association().initCollections(it)»
    '''
}
