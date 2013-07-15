package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Predicate;
import com.google.common.base.Predicates;
import java.util.List;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;

@SuppressWarnings("all")
public class CollectionUtils {
  /**
   * Filters a collection using multiple types.
   */
  public Iterable filter(final Iterable<Object> unfiltered, final Class... types) {
    Iterable<Object> _xblockexpression = null;
    {
      final Function1<Class<? extends Object>,Predicate<Object>> _function = new Function1<Class<? extends Object>,Predicate<Object>>() {
          public Predicate<Object> apply(final Class<? extends Object> it) {
            Predicate<Object> _instanceOf = Predicates.instanceOf(it);
            return _instanceOf;
          }
        };
      List<Predicate<Object>> _map = ListExtensions.<Class<? extends Object>, Predicate<Object>>map(((List<Class<? extends Object>>)Conversions.doWrapArray(types)), _function);
      final Predicate<Object> typeFilter = Predicates.<Object>or(_map);
      Iterable<Object> _filter = IterableExtensions.<Object>filter(unfiltered, new Function1<Object,Boolean>() {
          public Boolean apply(Object p) {
            return typeFilter.apply(p);
          }
      });
      _xblockexpression = (_filter);
    }
    return _xblockexpression;
  }
  
  /**
   * Filters a collection excluding a certain type.
   */
  public Iterable<? extends Object> exclude(final Iterable<? extends Object> unfiltered, final Class type) {
    Iterable<? extends Object> _xblockexpression = null;
    {
      Predicate<Object> _instanceOf = Predicates.instanceOf(type);
      final Predicate<Object> exclusionFilter = Predicates.<Object>not(_instanceOf);
      Iterable<? extends Object> _filter = IterableExtensions.filter(unfiltered, new Function1<Object,Boolean>() {
          public Boolean apply(Object p) {
            return exclusionFilter.apply(p);
          }
      });
      _xblockexpression = (_filter);
    }
    return _xblockexpression;
  }
}
