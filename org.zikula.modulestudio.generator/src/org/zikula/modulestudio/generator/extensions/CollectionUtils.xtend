package org.zikula.modulestudio.generator.extensions

import com.google.common.base.Predicates

class CollectionUtils {

    /**
     * Filters a collection using multiple types.
     */
    def Iterable filter(Iterable<Object> unfiltered, Class... types) {
        val typeFilter = Predicates::or(types.map[Predicates::instanceOf(it)])
        unfiltered.filter(typeFilter)
    }

    /**
     * Filters a collection excluding a certain type.
     */
    def Iterable<?> exclude(Iterable<?> unfiltered, Class type) {
        val exclusionFilter = Predicates::not(Predicates::instanceOf(type))
        unfiltered.filter(exclusionFilter)
    }
}
