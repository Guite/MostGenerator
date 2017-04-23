package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Predicate;
import com.google.common.base.Predicates;
import java.util.List;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;

@SuppressWarnings("all")
public class CollectionUtils {
  /**
   * Filters a collection using multiple types.
   */
  public Iterable<?> filter(final Iterable<Object> unfiltered, final Class<? extends EObject>... types) {
    Iterable<Object> _xblockexpression = null;
    {
      final Function1<Class<? extends EObject>, Predicate<Object>> _function = (Class<? extends EObject> it) -> {
        return Predicates.instanceOf(it);
      };
      final Predicate<Object> typeFilter = Predicates.<Object>or(ListExtensions.<Class<? extends EObject>, Predicate<Object>>map(((List<Class<? extends EObject>>)Conversions.doWrapArray(types)), _function));
      _xblockexpression = IterableExtensions.<Object>filter(unfiltered, new Function1<Object, Boolean>() {
          public Boolean apply(Object arg0) {
            return typeFilter.apply(arg0);
          }
      });
    }
    return _xblockexpression;
  }
  
  /**
   * Filters a collection excluding a certain type.
   */
  public Iterable<?> exclude(final Iterable<?> unfiltered, final Class<? extends EObject> type) {
    Iterable<?> _xblockexpression = null;
    {
      final Predicate<Object> exclusionFilter = Predicates.<Object>not(Predicates.instanceOf(type));
      _xblockexpression = IterableExtensions.filter(unfiltered, new Function1<Object, Boolean>() {
          public Boolean apply(Object arg0) {
            return exclusionFilter.apply(arg0);
          }
      });
    }
    return _xblockexpression;
  }
}
