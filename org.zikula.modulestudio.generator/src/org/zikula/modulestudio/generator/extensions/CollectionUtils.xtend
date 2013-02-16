package org.zikula.modulestudio.generator.extensions

import com.google.common.base.Predicates

class CollectionUtils {

    /**
     * Filters a collection using multiple types.
     */
    def Iterable filter(Iterable<?> unfiltered, Class... types) {
        unfiltered.filter(Predicates::or(types.map[Predicates::instanceOf(it)]))
    }

    /**
     * Filters a collection excluding a certain type.
     */
    def Iterable exclude(Iterable<?> unfiltered, Class type) {
        unfiltered.filter(Predicates::not(Predicates::instanceOf(type)))
    }
}
