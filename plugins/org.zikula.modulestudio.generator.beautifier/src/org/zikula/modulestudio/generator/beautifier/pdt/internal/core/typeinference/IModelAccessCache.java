package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference;

import java.util.Collection;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ITypeHierarchy;
import org.eclipse.dltk.core.ModelException;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.filenetwork.ReferenceTree;

public interface IModelAccessCache {

    public abstract ITypeHierarchy getSuperTypeHierarchy(IType type,
            IProgressMonitor monitor) throws ModelException;

    /**
     * Analyzes file dependences, and builds tree of all source modules, which
     * are referenced by the given source module.
     * 
     * Uses local cache for repeating queries.
     */
    public abstract ReferenceTree getFileHierarchy(ISourceModule sourceModule,
            IProgressMonitor monitor);

    /**
     * Returns cached methods for the given name
     */
    public abstract Collection<IMethod> getGlobalFunctions(
            ISourceModule sourceModule, String functionName,
            IProgressMonitor monitor);

    /**
     * Returns cached types for the given name
     */
    public abstract Collection<IType> getTypes(ISourceModule sourceModule,
            String typeName, String namespaceName, IProgressMonitor monitor);

    /**
     * Returns cached classes for the given name
     */
    public abstract Collection<IType> getClasses(ISourceModule sourceModule,
            String typeName, String namespaceName, IProgressMonitor monitor)
            throws ModelException;

    /**
     * Returns cached interfaces for the given name
     */
    public abstract Collection<IType> getInterfaces(ISourceModule sourceModule,
            String typeName, String namespaceName, IProgressMonitor monitor)
            throws ModelException;

    /**
     * Returns cached interfaces for the given name
     */
    public abstract Collection<IType> getNamespaces(ISourceModule sourceModule,
            String namespaceName, IProgressMonitor monitor)
            throws ModelException;

    /**
     * Returns cached classes or interfaces for the given name
     */
    public abstract Collection<IType> getClassesOrInterfaces(
            ISourceModule sourceModule, String typeName, String namespaceName,
            IProgressMonitor monitor) throws ModelException;

}
