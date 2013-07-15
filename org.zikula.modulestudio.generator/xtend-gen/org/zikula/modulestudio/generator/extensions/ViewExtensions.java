package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;

/**
 * This class contains view related extension methods.
 */
@SuppressWarnings("all")
public class ViewExtensions {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
  /**
   * Temporary hack due to Zikula core bug with theme parameter in short urls
   * as we use the Printer theme for the quick view.
   * 
   * @param it Given {@link Controller} instance.
   * @return String The output of this method.
   */
  public String additionalUrlParametersForQuickViewLink(final Controller it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof UserController) {
        final UserController _userController = (UserController)it;
        _matched=true;
        _switchResult = " forcelongurl=true";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Determines whether grouping panels with JavaScript for
   * toggling their visibility state are generated or not.
   * 
   * @param it Given {@link Entity} instance.
   * @param page The page template name.
   * @return Boolean The result.
   */
  public boolean useGroupingPanels(final Entity it, final String page) {
    boolean _and = false;
    boolean _isGeographical = it.isGeographical();
    boolean _not = (!_isGeographical);
    if (!_not) {
      _and = false;
    } else {
      int _panelWeight = this.panelWeight(it, page);
      boolean _greaterThan = (_panelWeight > 3);
      _and = (_not && _greaterThan);
    }
    return _and;
  }
  
  /**
   * Determines if a given relationship is part
   * of an edit form or not.
   * 
   * @param it Given {@link JoinRelationship} instance.
   * @param useTarget Whether the target side or the source side should be used.
   * @return Boolean The determined result.
   */
  private boolean isPartOfEditForm(final JoinRelationship it, final Boolean useTarget) {
    boolean _not = (!(useTarget).booleanValue());
    int _editStageCode = this._controllerExtensions.getEditStageCode(it, Boolean.valueOf(_not));
    boolean _greaterThan = (_editStageCode > 0);
    return _greaterThan;
  }
  
  /**
   * Counts the amount of visible groups of a given Entity
   * for display and edit pages.
   * 
   * @param it Given {@link Entity} instance.
   * @param page The page template name.
   * @return Integer The resulting panel weight.
   */
  private int panelWeight(final Entity it, final String page) {
    int _xblockexpression = (int) 0;
    {
      int weight = 1;
      boolean _and = false;
      boolean _equals = Objects.equal(page, "edit");
      if (!_equals) {
        _and = false;
      } else {
        EList<Relationship> _incoming = it.getIncoming();
        Iterable<JoinRelationship> _filter = Iterables.<JoinRelationship>filter(_incoming, JoinRelationship.class);
        final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
            public Boolean apply(final JoinRelationship e) {
              boolean _isPartOfEditForm = ViewExtensions.this.isPartOfEditForm(e, Boolean.valueOf(true));
              return Boolean.valueOf(_isPartOfEditForm);
            }
          };
        Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(_filter, _function);
        int _size = IterableExtensions.size(_filter_1);
        boolean _greaterThan = (_size > 1);
        _and = (_equals && _greaterThan);
      }
      if (_and) {
        int _plus = (weight + 1);
        weight = _plus;
      }
      boolean _and_1 = false;
      boolean _equals_1 = Objects.equal(page, "edit");
      if (!_equals_1) {
        _and_1 = false;
      } else {
        EList<Relationship> _outgoing = it.getOutgoing();
        Iterable<JoinRelationship> _filter_2 = Iterables.<JoinRelationship>filter(_outgoing, JoinRelationship.class);
        final Function1<JoinRelationship,Boolean> _function_1 = new Function1<JoinRelationship,Boolean>() {
            public Boolean apply(final JoinRelationship e) {
              boolean _isPartOfEditForm = ViewExtensions.this.isPartOfEditForm(e, Boolean.valueOf(false));
              return Boolean.valueOf(_isPartOfEditForm);
            }
          };
        Iterable<JoinRelationship> _filter_3 = IterableExtensions.<JoinRelationship>filter(_filter_2, _function_1);
        int _size_1 = IterableExtensions.size(_filter_3);
        boolean _greaterThan_1 = (_size_1 > 1);
        _and_1 = (_equals_1 && _greaterThan_1);
      }
      if (_and_1) {
        int _plus_1 = (weight + 1);
        weight = _plus_1;
      }
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        int _plus_2 = (weight + 1);
        weight = _plus_2;
      }
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        int _plus_3 = (weight + 1);
        weight = _plus_3;
      }
      boolean _isMetaData = it.isMetaData();
      if (_isMetaData) {
        int _plus_4 = (weight + 1);
        weight = _plus_4;
      }
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        int _plus_5 = (weight + 1);
        weight = _plus_5;
      }
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        int _plus_6 = (weight + 1);
        weight = _plus_6;
      }
      _xblockexpression = (weight);
    }
    return _xblockexpression;
  }
}
