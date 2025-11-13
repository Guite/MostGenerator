package org.zikula.modulestudio.generator.application.config

import de.guite.modulestudio.metamodel.Field
import java.util.Collection
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Configuration settings representation.
 */
class ConfigSection {

    @Accessors
    String name = ''
    @Accessors
    String description = ''
    @Accessors
    Collection<Field> fields

    new(String name, String description) {
        this.name = name
        this.description = description
        fields = newArrayList
    }
}
