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

    /**
     * Extension methods for formatting names.
     */
    @Inject extension FormattingExtensions = new FormattingExtensions()

    /**
     * Extension methods related to the model layer.
     */
    @Inject extension ModelExtensions = new ModelExtensions()

    /**
     * Transformation entry point consuming the application instance.
     *
     * @param it The given {@link Application} instance.
     */
    def modify(Application it) {
        println('Starting model transformation')
        // handle all entities
        for (entity : getAllEntities)
            entity.handleEntity
    }

    /**
     * Transformation processing for a single entity.
     *
     * @param it The currently treated {@link Entity} instance.
     */
    def private void handleEntity(Entity it) {
        //println('Transforming entity ' + name)
        //println('Field size before: ' + fields.size + ' fields')
        if (getPrimaryKeyFields.isEmpty) addPrimaryKey
        //println('Added primary key, field size now: ' + fields.size + ' fields')
    }

    /**
     * Adds a primary key to a given entity.
     * 
     * @param entity The given {@link Entity} instance
     */
    def private addPrimaryKey(Entity entity) {
        entity.fields.add(0, createIdColumn('', true))
    }

    /**
     * Creates a new identifier field.
     *
     * @param colName The column name.
     * @param isPrimary Whether the field should be primary or not.
     * @return IntegerField The created column object.
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
