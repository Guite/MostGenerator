package org.zikula.modulestudio.generator.extensions

import com.google.common.base.Predicates
import de.guite.modulestudio.metamodel.modulestudio.NamedObject

class CollectionUtils {

    /**
     * Filters a collection using multiple types.
     */
    def Iterable<?> filter(Iterable<Object> unfiltered, Class<? extends NamedObject>... types) {
        val typeFilter = Predicates.or(types.map[Predicates.instanceOf(it)])
        unfiltered.filter(typeFilter)
    }

    /**
     * Filters a collection excluding a certain type.
     */
    def Iterable<?> exclude(Iterable<?> unfiltered, Class<? extends NamedObject> type) {
        val exclusionFilter = Predicates.not(Predicates.instanceOf(type))
        unfiltered.filter(exclusionFilter)
    }
}
