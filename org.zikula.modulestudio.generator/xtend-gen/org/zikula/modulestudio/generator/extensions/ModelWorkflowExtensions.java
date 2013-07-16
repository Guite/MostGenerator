package org.zikula.modulestudio.generator.extensions;

import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

@SuppressWarnings("all")
public class ModelWorkflowExtensions {
  /**
   * Returns a list of all entities in this application.
   */
  public EList<Entity> getAllEntities(final Application it) {
    EList<Entity> _xblockexpression = null;
    {
      EList<Models> _models = it.getModels();
      Models _head = IterableExtensions.<Models>head(_models);
      EList<Entity> allEntities = _head.getEntities();
      EList<Models> _models_1 = it.getModels();
      Iterable<Models> _tail = IterableExtensions.<Models>tail(_models_1);
      for (final Models entityContainer : _tail) {
        EList<Entity> _entities = entityContainer.getEntities();
        allEntities.addAll(_entities);
      }
      _xblockexpression = (allEntities);
    }
    return _xblockexpression;
  }
}
