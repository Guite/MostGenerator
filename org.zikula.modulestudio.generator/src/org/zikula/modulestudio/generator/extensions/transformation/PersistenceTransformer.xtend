package org.zikula.modulestudio.generator.extensions.transformation

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.impl.ModulestudioFactoryImpl
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

/**
 * This class adds primary key fields to all entities of an application.
 */
class PersistenceTransformer {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()

    /**
     * Transformation entrypoint consuming the application instance.
     */
    def modify(Application it) {
        println('Starting model transformation')
        // handle all entities
        for (entity : getAllEntities)
            entity.handleEntity
    }

    /**
     * Transformation processing for a single entity.
     */
    def private handleEntity(Entity it) {
        //println('Transforming entity ' + name)
        //println('Field size before: ' + fields.size + ' fields')
        if (getPrimaryKeyFields.isEmpty) addPrimaryKey
        //println('Added primary key, field size now: ' + fields.size + ' fields')
    }

    /**
     * Adds a primary key to a given entity.
     * 
     * @param Entity
     *            given Entity instance
     * @return flag if insertion was successful
     */
    def private addPrimaryKey(Entity entity) {
        try {
            entity.fields.add(0,
                    createIdColumn('', true))
        } catch (Exception e) {
            false
        } finally {
            // nothing to do here (yet)
        }
        true
    }

    /**
     * Returns a new primary key field field.
     * 
     * @param Entity
     *            given Entity instance
     * @return flag if insertion was successful
     */
    def private createIdColumn(String colName, Boolean isPrimary) {
        val factory = new ModulestudioFactoryImpl()
        val idField = factory.createIntegerField
        if (isPrimary)
            idField.name = 'id'
        else
            idField.name = colName.formatForCode + '_id'
        idField.length = 9
        idField.primaryKey = isPrimary
        idField.unique = isPrimary
        idField
    }
}
