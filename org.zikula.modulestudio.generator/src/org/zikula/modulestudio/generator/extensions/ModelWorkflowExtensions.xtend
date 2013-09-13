package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.modulestudio.Application

class ModelWorkflowExtensions {
	
    /**
     * Returns a list of all entities in this application.
     */
    def getAllEntities(Application it) {
        var allEntities = models.head.entities
        for (entityContainer : models.tail)
            allEntities.addAll(entityContainer.entities)
        allEntities
    }
}
