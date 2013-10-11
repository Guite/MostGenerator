package org.zikula.modulestudio.generator.extensions

import com.google.common.base.Predicates
import org.eclipse.emf.ecore.EObject

class CollectionUtils {

    /**
     * Filters a collection using multiple types.
     */
    def Iterable<?> filter(Iterable<Object> unfiltered, Class<? extends EObject>... types) {
        val typeFilter = Predicates.or(types.map[Predicates.instanceOf(it)])
        unfiltered.filter(typeFilter)
    }

    /**
     * Filters a collection excluding a certain type.
     */
    def Iterable<?> exclude(Iterable<?> unfiltered, Class<? extends EObject> type) {
        val exclusionFilter = Predicates.not(Predicates.instanceOf(type))
        unfiltered.filter(exclusionFilter)
    }
}
