package org.zikula.modulestudio.generator.cartridges;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.EntityField;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.generator.GeneratorDelegate;
import org.eclipse.xtext.generator.IFileSystemAccess2;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.IGenerator2;
import org.eclipse.xtext.generator.IGeneratorContext;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.ZclassicGenerator;
import org.zikula.modulestudio.generator.extensions.transformation.PersistenceTransformer;

@SuppressWarnings("all")
public class MostGenerator extends GeneratorDelegate implements IGenerator, IGenerator2 {
  private String cartridge = "";
  
  private IProgressMonitor monitor = null;
  
  @Override
  public void doGenerate(final Resource input, final IFileSystemAccess2 fsa, final IGeneratorContext context) {
    EObject _head = IterableExtensions.<EObject>head(input.getContents());
    final Application app = ((Application) _head);
    final DataObject firstEntity = IterableExtensions.<DataObject>head(app.getEntities());
    final Function1<EntityField, Boolean> _function = (EntityField it) -> {
      return Boolean.valueOf("id".equals(it.getName()));
    };
    final Iterable<EntityField> pkFields = IterableExtensions.<EntityField>filter(firstEntity.getFields(), _function);
    boolean _isEmpty = IterableExtensions.isEmpty(pkFields);
    if (_isEmpty) {
      this.transform(app);
    }
    boolean _equals = "zclassic".equals(this.cartridge);
    if (_equals) {
      new ZclassicGenerator().generate(app, fsa, this.monitor);
    }
  }
  
  private void transform(final Application it) {
    new PersistenceTransformer().modify(it);
  }
  
  public String setCartridge(final String cartridgeName) {
    return this.cartridge = cartridgeName;
  }
  
  public IProgressMonitor setMonitor(final IProgressMonitor pm) {
    return this.monitor = pm;
  }
  
  @Override
  public void beforeGenerate(final Resource input, final IFileSystemAccess2 fsa, final IGeneratorContext context) {
  }
  
  @Override
  public void afterGenerate(final Resource input, final IFileSystemAccess2 fsa, final IGeneratorContext context) {
  }
}
