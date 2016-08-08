package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import java.util.List
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Attributes
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Categories
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Geographical
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Loggable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.MetaData
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Sluggable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.SoftDeleteable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Sortable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.StandardFields
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Translatable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.Tree
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions

class ExtensionManager {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    Entity entity
    List<EntityExtensionInterface> extensions

    new(Entity entity) {
        this.entity = entity

        this.extensions = newArrayList()
        if (entity.geographical) {
            this.extensions += new Geographical
        }
        if (entity.loggable) {
            this.extensions += new Loggable
        }
        if (entity.softDeleteable) {
            this.extensions += new SoftDeleteable
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
        if (entity.tree != EntityTreeType.NONE) {
            this.extensions += new Tree
        }
        if (entity.attributable) {
            this.extensions += new Attributes
        }
        if (entity.metaData) {
            this.extensions += new MetaData
        }
        if (entity.categorisable) {
            this.extensions += new Categories
        }
        if (entity.standardFields) {
            this.extensions += new StandardFields
        }
    }

    /**
     * Generates separate extension classes.
     */
    def extensionClasses(IFileSystemAccess fsa) '''
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
    def columnAnnotations(DerivedField it) '''
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
