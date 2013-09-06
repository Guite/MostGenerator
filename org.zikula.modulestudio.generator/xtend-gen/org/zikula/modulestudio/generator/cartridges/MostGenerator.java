package org.zikula.modulestudio.generator.cartridges;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.ZclassicGenerator;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.transformation.PersistenceTransformer;

@SuppressWarnings("all")
public class MostGenerator implements IGenerator {
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  private String cartridge = "";
  
  private IProgressMonitor monitor = null;
  
  public void doGenerate(final Resource resource, final IFileSystemAccess fsa) {
    EList<EObject> _contents = resource.getContents();
    EObject _head = IterableExtensions.<EObject>head(_contents);
    final Application app = ((Application) _head);
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(app);
    final Entity firstEntity = IterableExtensions.<Entity>head(_allEntities);
    EList<EntityField> _fields = firstEntity.getFields();
    final Function1<EntityField,Boolean> _function = new Function1<EntityField,Boolean>() {
      public Boolean apply(final EntityField e) {
        String _name = e.getName();
        boolean _equals = Objects.equal(_name, "id");
        return Boolean.valueOf(_equals);
      }
    };
    final Iterable<EntityField> pkFields = IterableExtensions.<EntityField>filter(_fields, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(pkFields);
    if (_isEmpty) {
      this.transform(app);
    }
    boolean _equals = Objects.equal(this.cartridge, "zclassic");
    if (_equals) {
      ZclassicGenerator _zclassicGenerator = new ZclassicGenerator();
      _zclassicGenerator.generate(app, fsa, this.monitor);
    }
  }
  
  private void transform(final Application it) {
    PersistenceTransformer _persistenceTransformer = new PersistenceTransformer();
    _persistenceTransformer.modify(it);
  }
  
  public String setCartridge(final String cartridgeName) {
    String _cartridge = this.cartridge = cartridgeName;
    return _cartridge;
  }
  
  public IProgressMonitor setMonitor(final IProgressMonitor pm) {
    IProgressMonitor _monitor = this.monitor = pm;
    return _monitor;
  }
}
