package org.zikula.modulestudio.generator.cartridges.symfony.models.entity

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.Field
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.Blameable
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.EntityExtensionInterface
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.Loggable
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.Sluggable
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.Sortable
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.Timestampable
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.Translatable
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions.Tree
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions

class ExtensionManager {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    Entity entity
    List<EntityExtensionInterface> extensions

    new(Entity entity) {
        this.entity = entity

        this.extensions = newArrayList
        if (entity.hasBlameableFields) {
            this.extensions += new Blameable
        }
        if (entity.loggable) {
            this.extensions += new Loggable
        }
        if (entity.hasSluggableFields) {
            this.extensions += new Sluggable
        }
        if (entity.hasTranslatableFields) {
            this.extensions += new Translatable
        }
        if (entity.hasSortableFields) {
            this.extensions += new Sortable
        }
        if (entity.hasTimestampableFields) {
            this.extensions += new Timestampable
        }
        if (entity.tree != EntityTreeType.NONE) {
            this.extensions += new Tree
        }
    }

    /**
     * Generates separate extension classes.
     */
    def extensionClasses(IMostFileSystemAccess fsa) '''
        «FOR ext : this.extensions»
            «ext.extensionClasses(entity, fsa)»
        «ENDFOR»
    '''

    /**
     * Additional class annotations.
     */
    def classAnnotations() '''
        «FOR ext : this.extensions»
            «ext.classAnnotations(entity)»
        «ENDFOR»
    '''

    /**
     * Additional field annotations.
     */
    def columnAnnotations(Field it) '''
        «FOR ext : this.extensions»
            «ext.columnAnnotations(it)»
        «ENDFOR»
    '''

    /**
     * Additional column definitions.
     */
    def additionalProperties() '''
        «FOR ext : this.extensions»
            «ext.properties(entity)»
        «ENDFOR»
    '''

    /**
     * Additional accessor methods.
     */
    def additionalAccessors() '''
        «FOR ext : this.extensions»
            «ext.accessors(entity)»
        «ENDFOR»
    '''
}
