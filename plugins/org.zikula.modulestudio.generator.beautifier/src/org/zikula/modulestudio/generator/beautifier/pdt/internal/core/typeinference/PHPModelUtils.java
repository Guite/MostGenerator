package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference;

/*******************************************************************************
 * Copyright (c) 2009 IBM Corporation and others. All rights reserved. This
 * program and the accompanying materials are made available under the terms of
 * the Eclipse Public License v1.0 which accompanies this distribution, and is
 * available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: IBM Corporation - initial API and implementation Zend
 * Technologies
 * 
 * 
 * 
 * Based on package org.eclipse.php.internal.core.typeinference;
 * 
 */

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.Modifiers;
import org.eclipse.dltk.ast.declarations.MethodDeclaration;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.declarations.TypeDeclaration;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.references.VariableReference;
import org.eclipse.dltk.ast.statements.Statement;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.Flags;
import org.eclipse.dltk.core.IField;
import org.eclipse.dltk.core.IMember;
import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ITypeHierarchy;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.SourceParserUtil;
import org.eclipse.dltk.core.index2.search.ISearchEngine.MatchRule;
import org.eclipse.dltk.core.search.IDLTKSearchScope;
import org.eclipse.dltk.core.search.SearchEngine;
import org.eclipse.dltk.internal.core.ModelElement;
import org.eclipse.dltk.internal.core.SourceField;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.core.compiler.PHPFlags;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCoreConstants;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCorePlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.GlobalStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.IPHPDocAwareDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.NamespaceReference;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocBlock;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.UsePart;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser.ASTUtils;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.filenetwork.FileNetworkUtility;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.filenetwork.ReferenceTree;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.language.LanguageModelInitializer;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.model.PhpModelAccess;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference.DeclarationSearcher.DeclarationType;

public class PHPModelUtils {

    /**
     * Extracts the element name from the given fully qualified name
     * 
     * @param element
     *            Element name
     * @return element name without the namespace prefix
     */
    public static String extractElementName(String element) {
        final int i = element
                .lastIndexOf(NamespaceReference.NAMESPACE_SEPARATOR);
        if (i != -1) {
            element = element.substring(i + 1).trim();
        }
        return element;
    }

    /**
     * if the elementName is a class alias for a namespace class,we get its
     * original name from its alias
     * 
     * @param elementName
     * @param sourceModule
     * @param offset
     * @param defaultClassName
     * @return
     */
    public static String getRealName(String elementName,
            ISourceModule sourceModule, final int offset,
            String defaultClassName) {

        // Check class name aliasing:
        final ModuleDeclaration moduleDeclaration = SourceParserUtil
                .getModuleDeclaration(sourceModule);
        final UsePart usePart = ASTUtils.findUseStatementByAlias(
                moduleDeclaration, elementName, offset);
        if (usePart != null) {
            elementName = usePart.getNamespace().getFullyQualifiedName();
            final int nsIndex = elementName
                    .lastIndexOf(NamespaceReference.NAMESPACE_SEPARATOR);
            if (nsIndex != -1) {
                defaultClassName = elementName.substring(nsIndex + 1);
            }
        }
        return defaultClassName;
    }

    /**
     * Extracts the namespace name from the specified element name and resolves
     * it using USE statements that present in the file.
     * 
     * @param elementName
     *            The name of the element, like: \A\B or A\B\C.
     * @param sourceModule
     *            Source module where the element is referenced
     * @param offset
     *            The offset where element is referenced
     * @return namespace name:
     * 
     *         <pre>
     *   1. &lt;code&gt;&quot;&quot;&lt;/code&gt; (empty string) indicates global namespace
     *   2. non-empty string indicates a real namespace
     *   3. &lt;code&gt;null&lt;/code&gt; indicates that there's no namespace prefix in element name
     * </pre>
     */
    public static String extractNamespaceName(String elementName,
            ISourceModule sourceModule, final int offset) {

        // Check class name aliasing:
        final ModuleDeclaration moduleDeclaration = SourceParserUtil
                .getModuleDeclaration(sourceModule);
        UsePart usePart = ASTUtils.findUseStatementByAlias(moduleDeclaration,
                elementName, offset);
        if (usePart != null) {
            elementName = usePart.getNamespace().getFullyQualifiedName();
            if (elementName.charAt(0) != NamespaceReference.NAMESPACE_SEPARATOR) {
                elementName = NamespaceReference.NAMESPACE_SEPARATOR
                        + elementName;
            }
        }

        boolean isGlobal = false;
        if (elementName.charAt(0) == NamespaceReference.NAMESPACE_SEPARATOR) {
            isGlobal = true;
        }

        final int nsIndex = elementName
                .lastIndexOf(NamespaceReference.NAMESPACE_SEPARATOR);
        if (nsIndex != -1) {
            String namespace = elementName.substring(0, nsIndex);
            if (isGlobal && namespace.length() > 0) {
                namespace = namespace.substring(1);
            }

            if (!isGlobal) {
                // 1. It can be a special 'namespace' keyword, which points to
                // the current namespace:
                if ("namespace".equalsIgnoreCase(namespace)) {
                    final IType currentNamespace = PHPModelUtils
                            .getCurrentNamespace(sourceModule, offset);
                    return currentNamespace.getElementName();
                }

                // 2. it can be an alias - try to find relevant USE statement
                if (namespace.indexOf('\\') == -1) {
                    usePart = ASTUtils.findUseStatementByAlias(
                            moduleDeclaration, namespace, offset);
                    if (usePart != null) {
                        return usePart.getNamespace().getFullyQualifiedName();
                    }
                }

                // 3. it can be a sub-namespace of the current namespace:
                final IType currentNamespace = PHPModelUtils
                        .getCurrentNamespace(sourceModule, offset);
                if (currentNamespace != null) {
                    return new StringBuilder(currentNamespace.getElementName())
                            .append(NamespaceReference.NAMESPACE_SEPARATOR)
                            .append(namespace).toString();
                }
            }

            // global namespace:
            return namespace;
        }

        return null;
    }

    /**
     * Filters model elements using file network.
     * 
     * @param sourceModule
     *            Source module
     * @param elements
     *            Model elements to filter
     * @return
     */
    public static <T extends IModelElement> Collection<T> fileNetworkFilter(
            ISourceModule sourceModule, Collection<T> elements) {
        return fileNetworkFilter(sourceModule, elements, null);
    }

    /**
     * Filters model elements using file network.
     * 
     * @param sourceModule
     *            Source module
     * @param elements
     *            Model elements to filter
     * @param referenceTree
     *            Cached instance of file hierarchy
     * @return
     */
    public static <T extends IModelElement> Collection<T> fileNetworkFilter(
            ISourceModule sourceModule, Collection<T> elements,
            ReferenceTree referenceTree) {

        if (elements != null && elements.size() > 0) {
            final List<T> filteredElements = new LinkedList<T>();

            // If some of elements belong to current file return just it:
            for (final T element : elements) {
                if (sourceModule.equals(element.getOpenable())) {
                    filteredElements.add(element);
                }
            }
            if (filteredElements.size() == 0) {
                // Filter by includes network
                if (referenceTree == null) {
                    referenceTree = FileNetworkUtility
                            .buildReferencedFilesTree(sourceModule, null);
                }
                for (final T element : elements) {
                    if (LanguageModelInitializer
                            .isLanguageModelElement(element)
                            || referenceTree.find(((ModelElement) element)
                                    .getSourceModule())) {
                        filteredElements.add(element);
                    }
                }
            }
            if (filteredElements.size() > 0) {
                elements = filteredElements;
            }
        }
        return elements;
    }

    /**
     * Determine whether givent elements represent the same type and name, but
     * declared in different files (determine whether file network filtering can
     * be used)
     * 
     * @param elements
     *            Model elements list
     * @return
     */
    private static <T extends IModelElement> boolean canUseFileNetworkFilter(
            Collection<T> elements) {
        int elementType = 0;
        String elementName = null;
        for (final T element : elements) {
            if (elementName == null) {
                elementType = element.getElementType();
                elementName = element.getElementName();
                continue;
            }
            if (!elementName.equalsIgnoreCase(element.getElementName())
                    || elementType != element.getElementType()) {
                return false;
            }
        }
        return true;
    }

    /**
     * Leaves most 'suitable' for current source module elements
     * 
     * @param sourceModule
     * @param elements
     * @return
     */
    public static <T extends IModelElement> Collection<T> filterElements(
            ISourceModule sourceModule, Collection<T> elements) {
        if (elements == null) {
            return null;
        }
        if (canUseFileNetworkFilter(elements)) {
            return fileNetworkFilter(sourceModule, elements);
        }
        return elements;
    }

    /**
     * Returns the current method or function by the specified file and offset
     * 
     * @param sourceModule
     *            The file where current namespace is requested
     * @param offset
     *            The offset where current namespace is requested
     * @return method element, or <code>null</code> if the scope not a method
     *         scope
     */
    public static IMethod getCurrentMethod(ISourceModule sourceModule,
            int offset) {
        try {
            IModelElement currentMethod = sourceModule.getElementAt(offset);
            while (currentMethod != null) {
                if (currentMethod instanceof IMethod) {
                    return (IMethod) currentMethod;
                }
                if (!(currentMethod instanceof IField)) {
                    break;
                }
                currentMethod = currentMethod.getParent();
            }
        } catch (final ModelException e) {
            PHPCorePlugin.log(e);
        }
        return null;
    }

    /**
     * Returns the current namespace by the specified model element
     * 
     * @param element
     *            Model element
     * @return namespace element, or <code>null</code> if the scope is global
     *         under the specified cursor position
     */
    public static IType getCurrentNamespace(IModelElement element) {
        try {
            IModelElement currentNs = element;
            while (currentNs != null) {
                if (currentNs instanceof IType
                        && PHPFlags.isNamespace(((IType) currentNs).getFlags())) {
                    return (IType) currentNs;
                }
                currentNs = currentNs.getParent();
            }
        } catch (final ModelException e) {
            PHPCorePlugin.log(e);
        }
        return null;
    }

    /**
     * Returns the current namespace by the specified file and offset
     * 
     * @param sourceModule
     *            The file where current namespace is requested
     * @param sourceModule
     *            The offset where current namespace is requested
     * @return namespace element, or <code>null</code> if the scope is global
     *         under the specified cursor position
     */
    public static IType getCurrentNamespace(ISourceModule sourceModule,
            int offset) {
        try {
            IModelElement currentNs = sourceModule.getElementAt(offset);
            while (currentNs instanceof IField) {
                currentNs = sourceModule.getElementAt(((IField) currentNs)
                        .getSourceRange().getOffset() - 1);
            }
            while (currentNs != null) {
                if (currentNs instanceof IType
                        && PHPFlags.isNamespace(((IType) currentNs).getFlags())) {
                    return (IType) currentNs;
                }
                currentNs = currentNs.getParent();
            }
        } catch (final ModelException e) {
            PHPCorePlugin.log(e);
        }
        return null;
    }

    /**
     * Returns the current class or interface by the specified file and offset
     * 
     * @param sourceModule
     *            The file where current namespace is requested
     * @param offset
     *            The offset where current namespace is requested
     * @return type element, or <code>null</code> if the scope not a class or
     *         interface scope
     */
    public static IType getCurrentType(IModelElement element) {
        try {
            while (element != null) {
                if (element instanceof IType) {
                    if (!PHPFlags.isNamespace(((IType) element).getFlags())) {
                        return (IType) element;
                    }
                    break;
                }
                element = element.getParent();
            }
        } catch (final ModelException e) {
            PHPCorePlugin.log(e);
        }
        return null;
    }

    /**
     * Returns the current class or interface by the specified file and offset
     * 
     * @param sourceModule
     *            The file where current namespace is requested
     * @param offset
     *            The offset where current namespace is requested
     * @return type element, or <code>null</code> if the scope not a class or
     *         interface scope
     */
    public static IType getCurrentType(ISourceModule sourceModule, int offset) {
        try {
            return getCurrentType(sourceModule.getElementAt(offset));
        } catch (final ModelException e) {
            PHPCorePlugin.log(e);
        }
        return null;
    }

    /**
     * Returns PHPDoc block associated with the given IField element
     * 
     * @param field
     * @return
     */
    public static PHPDocBlock getDocBlock(IField field) {
        if (field == null) {
            return null;
        }
        try {
            final ISourceModule sourceModule = field.getSourceModule();
            final ModuleDeclaration moduleDeclaration = SourceParserUtil
                    .getModuleDeclaration(sourceModule);
            final ASTNode fieldDeclaration = PHPModelUtils.getNodeByField(
                    moduleDeclaration, field);
            if (fieldDeclaration instanceof IPHPDocAwareDeclaration) {
                return ((IPHPDocAwareDeclaration) fieldDeclaration).getPHPDoc();
            }
            else if (fieldDeclaration == null) {
                return DefineMethodUtils.getDefinePHPDocBlockByField(
                        moduleDeclaration, field);
            }
        } catch (final ModelException e) {
            if (DLTKCore.DEBUG) {
                GeneratorBeautifierPlugin.log(e);
                // Logger.logException(e);
            }
        }
        return null;
    }

    /**
     * Returns PHPDoc block associated with the given IMethod element
     * 
     * @param method
     * @return
     */
    public static PHPDocBlock getDocBlock(IMethod method) {
        if (method == null) {
            return null;
        }
        try {
            final ISourceModule sourceModule = method.getSourceModule();
            final ModuleDeclaration moduleDeclaration = SourceParserUtil
                    .getModuleDeclaration(sourceModule);
            final MethodDeclaration methodDeclaration = PHPModelUtils
                    .getNodeByMethod(moduleDeclaration, method);
            if (methodDeclaration instanceof IPHPDocAwareDeclaration) {
                return ((IPHPDocAwareDeclaration) methodDeclaration)
                        .getPHPDoc();
            }
        } catch (final ModelException e) {
            if (DLTKCore.DEBUG) {
                GeneratorBeautifierPlugin.log(e);
                // Logger.logException(e);
            }
        }
        return null;
    }

    /**
     * Returns PHPDoc block associated with the given IType element
     * 
     * @param type
     * @return
     */
    public static PHPDocBlock getDocBlock(IType type) {
        if (type == null) {
            return null;
        }
        try {
            final ISourceModule sourceModule = type.getSourceModule();
            final ModuleDeclaration moduleDeclaration = SourceParserUtil
                    .getModuleDeclaration(sourceModule);
            final TypeDeclaration typeDeclaration = PHPModelUtils
                    .getNodeByClass(moduleDeclaration, type);
            if (typeDeclaration instanceof IPHPDocAwareDeclaration) {
                return ((IPHPDocAwareDeclaration) typeDeclaration).getPHPDoc();
            }
        } catch (final ModelException e) {
            if (DLTKCore.DEBUG) {
                GeneratorBeautifierPlugin.log(e);
                // Logger.logException(e);
            }
        }
        return null;
    }

    /**
     * This method returns field corresponding to its name and the file where it
     * was referenced. The field name may contain also the namespace part, like:
     * A\B\C or \A\B\C
     * 
     * @param fieldName
     *            Tye fully qualified field name
     * @param sourceModule
     *            The file where the element is referenced
     * @param offset
     *            The offset where the element is referenced
     * @param monitor
     *            Progress monitor
     * @return a list of relevant IField elements, or <code>null</code> in case
     *         there's no IField found
     * @throws ModelException
     */
    public static IField[] getFields(String fieldName,
            ISourceModule sourceModule, int offset, IProgressMonitor monitor)
            throws ModelException {
        return getFields(fieldName, sourceModule, offset, null, monitor);
    }

    /**
     * This method returns field corresponding to its name and the file where it
     * was referenced. The field name may contain also the namespace part, like:
     * A\B\C or \A\B\C
     * 
     * @param fieldName
     *            Tye fully qualified field name
     * @param sourceModule
     *            The file where the element is referenced
     * @param offset
     *            The offset where the element is referenced
     * @param cache
     *            Model access cache if available
     * @param monitor
     *            Progress monitor
     * @return a list of relevant IField elements, or <code>null</code> in case
     *         there's no IField found
     * @throws ModelException
     */
    public static IField[] getFields(String fieldName,
            ISourceModule sourceModule, int offset, IModelAccessCache cache,
            IProgressMonitor monitor) throws ModelException {
        if (fieldName == null || fieldName.length() == 0) {
            return PhpModelAccess.NULL_FIELDS;
        }
        if (!fieldName.startsWith("$")) { // variables are not supported by
            // namespaces in PHP 5.3
            String namespace = extractNamespaceName(fieldName, sourceModule,
                    offset);
            fieldName = extractElementName(fieldName);
            if (namespace != null) {
                if (namespace.length() > 0) {
                    final IField[] fields = getNamespaceField(namespace,
                            fieldName, true, sourceModule, cache, monitor);
                    if (fields.length > 0) {
                        return fields;
                    }
                    return PhpModelAccess.NULL_FIELDS;
                }
                // it's a global reference: \C
            }
            else {
                // look for the element in current namespace:
                final IType currentNamespace = getCurrentNamespace(
                        sourceModule, offset);
                if (currentNamespace != null) {
                    namespace = currentNamespace.getElementName();
                    IField[] fields = getNamespaceField(namespace, fieldName,
                            true, sourceModule, cache, monitor);
                    if (fields.length > 0) {
                        return fields;
                    }

                    // For functions and constants, PHP will fall back to global
                    // functions or constants if a namespaced function or
                    // constant does not exist:
                    final IDLTKSearchScope scope = SearchEngine
                            .createSearchScope(sourceModule.getScriptProject());
                    fields = PhpModelAccess.getDefault().findFields(fieldName,
                            MatchRule.EXACT,
                            Modifiers.AccConstant | Modifiers.AccGlobal, 0,
                            scope, null);

                    final Collection<IField> filteredElements = filterElements(
                            sourceModule, Arrays.asList(fields));
                    return filteredElements.toArray(new IField[filteredElements
                            .size()]);
                }
            }
        }
        final IDLTKSearchScope scope = SearchEngine
                .createSearchScope(sourceModule.getScriptProject());
        final IField[] fields = PhpModelAccess.getDefault()
                .findFields(fieldName, MatchRule.EXACT, Modifiers.AccGlobal, 0,
                        scope, null);

        Collection<IField> filteredElements = null;
        if (fields != null) {
            filteredElements = filterElements(sourceModule,
                    Arrays.asList(fields));
            return filteredElements
                    .toArray(new IField[filteredElements.size()]);
        }
        return PhpModelAccess.NULL_FIELDS;
    }

    /**
     * This method returns function corresponding to its name and the file where
     * it was referenced. The function name may contain also the namespace part,
     * like: A\B\foo() or \A\B\foo()
     * 
     * @param functionName
     *            The fully qualified function name
     * @param sourceModule
     *            The file where the element is referenced
     * @param offset
     *            The offset where the element is referenced
     * @param monitor
     *            Progress monitor
     * @return a list of relevant IMethod elements, or <code>null</code> in case
     *         there's no IMethod found
     * @throws ModelException
     */
    public static IMethod[] getFunctions(String functionName,
            ISourceModule sourceModule, int offset, IProgressMonitor monitor)
            throws ModelException {
        return getFunctions(functionName, sourceModule, offset, null, monitor);
    }

    /**
     * This method returns function corresponding to its name and the file where
     * it was referenced. The function name may contain also the namespace part,
     * like: A\B\foo() or \A\B\foo()
     * 
     * @param functionName
     *            The fully qualified function name
     * @param sourceModule
     *            The file where the element is referenced
     * @param offset
     *            The offset where the element is referenced
     * @param cache
     *            Temporary model cache instance
     * @param monitor
     *            Progress monitor
     * @return a list of relevant IMethod elements, or <code>null</code> in case
     *         there's no IMethod found
     * @throws ModelException
     */
    public static IMethod[] getFunctions(String functionName,
            ISourceModule sourceModule, int offset, IModelAccessCache cache,
            IProgressMonitor monitor) throws ModelException {

        if (functionName == null || functionName.length() == 0) {
            return PhpModelAccess.NULL_METHODS;
        }
        String namespace = extractNamespaceName(functionName, sourceModule,
                offset);
        functionName = extractElementName(functionName);
        if (namespace != null) {
            if (namespace.length() > 0) {
                final IMethod[] functions = getNamespaceFunction(namespace,
                        functionName, true, sourceModule, cache, monitor);
                if (functions.length > 0) {
                    return functions;
                }
                return PhpModelAccess.NULL_METHODS;
            }
            // it's a global reference: \foo()
        }
        else {
            // look for the element in current namespace:
            final IType currentNamespace = getCurrentNamespace(sourceModule,
                    offset);
            if (currentNamespace != null) {
                namespace = currentNamespace.getElementName();
                final IMethod[] functions = getNamespaceFunction(namespace,
                        functionName, true, sourceModule, cache, monitor);
                if (functions.length > 0) {
                    return functions;
                }
                // For functions and constants, PHP will fall back to global
                // functions or constants if a namespaced function or constant
                // does not exist:
                return getGlobalFunctions(sourceModule, functionName, cache,
                        monitor);
            }
        }
        return getGlobalFunctions(sourceModule, functionName, cache, monitor);
    }

    private static IMethod[] getGlobalFunctions(ISourceModule sourceModule,
            String functionName, IModelAccessCache cache,
            IProgressMonitor monitor) {

        if (cache != null) {
            final Collection<IMethod> functions = cache.getGlobalFunctions(
                    sourceModule, functionName, monitor);
            if (functions == null) {
                return PhpModelAccess.NULL_METHODS;
            }
            return functions.toArray(new IMethod[functions.size()]);
        }

        final IDLTKSearchScope scope = SearchEngine
                .createSearchScope(sourceModule.getScriptProject());
        final IMethod[] functions = PhpModelAccess.getDefault().findMethods(
                functionName, MatchRule.EXACT, Modifiers.AccGlobal, 0, scope,
                null);
        final Collection<IMethod> filteredElements = filterElements(
                sourceModule, Arrays.asList(functions));
        return filteredElements.toArray(new IMethod[filteredElements.size()]);
    }

    /**
     * This method searches for all fields that where declared in the specified
     * method (including global variables that where introduced to this method
     * using 'global' keyword)
     * 
     * @param method
     *            Method to look at
     * @param prefix
     *            Field name
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     */
    public static IModelElement[] getMethodFields(final IMethod method,
            final String prefix, final boolean exactName,
            IProgressMonitor monitor) {

        final List<IField> elements = new LinkedList<IField>();
        final Set<String> processedVars = new HashSet<String>();

        try {
            getMethodFields(method, prefix, exactName, elements, processedVars);

            // collect global variables
            final ModuleDeclaration rootNode = SourceParserUtil
                    .getModuleDeclaration(method.getSourceModule());
            final MethodDeclaration methodDeclaration = PHPModelUtils
                    .getNodeByMethod(rootNode, method);
            if (methodDeclaration != null) {
                methodDeclaration.traverse(new ASTVisitor() {
                    @Override
                    public boolean visit(Statement s) throws Exception {
                        if (s instanceof GlobalStatement) {
                            final GlobalStatement globalStatement = (GlobalStatement) s;
                            for (final Expression e : globalStatement
                                    .getVariables()) {
                                if (e instanceof VariableReference) {
                                    final VariableReference varReference = (VariableReference) e;
                                    final String varName = varReference
                                            .getName();
                                    if (!processedVars.contains(varName)
                                            && (exactName
                                                    && varName
                                                            .equalsIgnoreCase(prefix) || !exactName
                                                    && varName
                                                            .toLowerCase()
                                                            .startsWith(
                                                                    prefix.toLowerCase()))) {
                                        elements.add(new FakeField(
                                                (ModelElement) method, varName,
                                                e.sourceStart(), e.sourceEnd()
                                                        - e.sourceStart()));
                                        processedVars.add(varName);
                                    }
                                }
                            }
                        }
                        return super.visit(s);
                    }
                });
            }
        } catch (final Exception e) {
            PHPCorePlugin.log(e);
        }

        return elements.toArray(new IModelElement[elements.size()]);
    }

    public static void getMethodFields(final IMethod method,
            final String prefix, final boolean exactName,
            final List<IField> elements, final Set<String> processedVars)
            throws ModelException {
        final IModelElement[] children = method.getChildren();
        for (final IModelElement child : children) {
            if (child.getElementType() == IModelElement.FIELD) {
                final String elementName = child.getElementName();
                if (exactName
                        && elementName.equalsIgnoreCase(prefix)
                        || !exactName
                        && elementName.toLowerCase().startsWith(
                                prefix.toLowerCase())) {

                    final IField field = (IField) child;
                    if (!isSameFileExisiting(elements, field)) {
                        elements.add((IField) child);
                        processedVars.add(elementName);
                    }
                }
            }
        }
        if (isNestedAnonymousMethod(method)) {
            getMethodFields((IMethod) method.getParent().getParent(), prefix,
                    exactName, elements, processedVars);
        }
    }

    public static boolean isNestedAnonymousMethod(final IMethod method) {
        return PHPCoreConstants.ANONYMOUS.equals(method.getElementName())
                && method.getParent() instanceof IField
                && method.getParent().getParent() instanceof IMethod;
    }

    private static boolean isSameFileExisiting(List<IField> elements,
            IField field) {

        for (final IField current : elements) {
            if (isSameField(current, field)) {
                return true;
            }
        }
        return false;

    }

    public static boolean isSameField(IField current, IField field) {

        if (!(field instanceof SourceField)) {
            return false;
        }
        if (current == field) {
            return true;
        }

        return current.getElementName().equals(field.getElementName())
                && current.getParent().equals(field.getParent());

    }

    /**
     * This method searches for all global fields that where declared in the
     * specified file.
     * 
     * @param sourceModule
     *            Source module to look at
     * @param prefix
     *            Field name
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     */
    public static IField[] getFileFields(final ISourceModule sourceModule,
            final String prefix, final boolean exactName,
            IProgressMonitor monitor) {

        final List<IField> elements = new LinkedList<IField>();
        try {
            final IField[] sourceModuleFields = sourceModule.getFields();
            for (final IField field : sourceModuleFields) {
                final String elementName = field.getElementName();
                if (exactName
                        && elementName.equalsIgnoreCase(prefix)
                        || !exactName
                        && elementName.toLowerCase().startsWith(
                                prefix.toLowerCase())) {
                    elements.add(field);
                }
            }
        } catch (final Exception e) {
            PHPCorePlugin.log(e);
        }

        return elements.toArray(new IField[elements.size()]);
    }

    /**
     * This method returns field declared unders specified namespace
     * 
     * @param namespace
     *            Namespace name
     * @param prefix
     *            Field name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param sourceModule
     *            Source module where the field is referenced
     * @param monitor
     *            Progress monitor
     * @return field declarated in the specified namespace, or null if there is
     *         none
     * @throws ModelException
     */
    public static IField[] getNamespaceField(String namespace, String prefix,
            boolean exactName, ISourceModule sourceModule,
            IProgressMonitor monitor) throws ModelException {
        return getNamespaceField(namespace, prefix, exactName, sourceModule,
                null, monitor);
    }

    /**
     * This method returns field declared unders specified namespace
     * 
     * @param namespace
     *            Namespace name
     * @param prefix
     *            Field name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param sourceModule
     *            Source module where the field is referenced
     * @param cache
     *            Model access cache if available
     * @param monitor
     *            Progress monitor
     * @return field declarated in the specified namespace, or null if there is
     *         none
     * @throws ModelException
     */
    public static IField[] getNamespaceField(String namespace, String prefix,
            boolean exactName, ISourceModule sourceModule,
            IModelAccessCache cache, IProgressMonitor monitor)
            throws ModelException {

        final IType[] namespaces = getNamespaces(sourceModule, namespace,
                cache, monitor);
        final List<IField> result = new LinkedList<IField>();
        for (final IType ns : namespaces) {
            result.addAll(Arrays.asList(PHPModelUtils.getTypeField(ns, prefix,
                    exactName)));
        }
        return result.toArray(new IField[result.size()]);
    }

    /**
     * This method returns method declared unders specified namespace
     * 
     * @param namespace
     *            Namespace name
     * @param prefix
     *            Function name or prefix
     * @param exactName
     *            Whether the type name is exact or it is prefix
     * @param sourceModule
     *            Source module where the function is referenced
     * @param monitor
     *            Progress monitor
     * @throws ModelException
     */
    public static IMethod[] getNamespaceFunction(String namespace,
            String prefix, boolean exactName, ISourceModule sourceModule,
            IProgressMonitor monitor) throws ModelException {
        return getNamespaceFunction(namespace, prefix, exactName, sourceModule,
                null, monitor);
    }

    /**
     * This method returns method declared unders specified namespace
     * 
     * @param namespace
     *            Namespace name
     * @param prefix
     *            Function name or prefix
     * @param exactName
     *            Whether the type name is exact or it is prefix
     * @param sourceModule
     *            Source module where the function is referenced
     * @param cache
     *            Model access cache if available
     * @param monitor
     *            Progress monitor
     * @throws ModelException
     */
    public static IMethod[] getNamespaceFunction(String namespace,
            String prefix, boolean exactName, ISourceModule sourceModule,
            IModelAccessCache cache, IProgressMonitor monitor)
            throws ModelException {

        final IType[] namespaces = getNamespaces(sourceModule, namespace,
                cache, monitor);
        final List<IMethod> result = new LinkedList<IMethod>();
        for (final IType ns : namespaces) {
            result.addAll(Arrays.asList(PHPModelUtils.getTypeMethod(ns, prefix,
                    exactName)));
        }
        return result.toArray(new IMethod[result.size()]);
    }

    /**
     * Guess the namespace where the specified element is declared.
     * 
     * @param elementName
     *            The name of the element, like: \A\B, A\B, namespace\B, \B,
     *            etc...
     * @param sourceModule
     *            Source module where the element is referenced
     * @param offset
     *            The offset in file where the element is referenced
     * @param monitor
     * @return model elements of found namespace, otherwise <code>null</code>
     *         (global namespace)
     * @throws ModelException
     */
    public static IType[] getNamespaceOf(String elementName,
            ISourceModule sourceModule, int offset, IProgressMonitor monitor)
            throws ModelException {
        return getNamespaceOf(elementName, sourceModule, offset, null, monitor);
    }

    /**
     * Guess the namespace where the specified element is declared.
     * 
     * @param elementName
     *            The name of the element, like: \A\B, A\B, namespace\B, \B,
     *            etc...
     * @param sourceModule
     *            Source module where the element is referenced
     * @param offset
     *            The offset in file where the element is referenced
     * @param cache
     *            Model access cache if available
     * @param monitor
     * @return model elements of found namespace, otherwise <code>null</code>
     *         (global namespace)
     * @throws ModelException
     */
    public static IType[] getNamespaceOf(String elementName,
            ISourceModule sourceModule, int offset, IModelAccessCache cache,
            IProgressMonitor monitor) throws ModelException {
        final String namespace = extractNamespaceName(elementName,
                sourceModule, offset);
        if (namespace != null && namespace.length() > 0) {
            return getNamespaces(sourceModule, namespace, cache, monitor);
        }
        return PhpModelAccess.NULL_TYPES;
    }

    /**
     * This method returns type declared unders specified namespace
     * 
     * @param namespace
     *            Namespace name
     * @param prefix
     *            Type name or prefix
     * @param exactName
     *            Whether the type name is exact or it is prefix
     * @param sourceModule
     *            Source module where the type is referenced
     * @param monitor
     *            Progress monitor
     * @return type declarated in the specified namespace, or null if there is
     *         none
     * @throws ModelException
     */
    public static IType[] getNamespaceType(String namespace, String prefix,
            boolean exactName, ISourceModule sourceModule,
            IProgressMonitor monitor) throws ModelException {
        return getNamespaceType(namespace, prefix, exactName, sourceModule,
                monitor);
    }

    /**
     * This method returns type declared unders specified namespace
     * 
     * @param namespace
     *            Namespace name
     * @param prefix
     *            Type name or prefix
     * @param exactName
     *            Whether the type name is exact or it is prefix
     * @param sourceModule
     *            Source module where the type is referenced
     * @param cache
     *            Model access cache if available
     * @param monitor
     *            Progress monitor
     * @return type declarated in the specified namespace, or null if there is
     *         none
     * @throws ModelException
     */
    public static IType[] getNamespaceType(String namespace, String prefix,
            boolean exactName, ISourceModule sourceModule,
            IModelAccessCache cache, IProgressMonitor monitor)
            throws ModelException {

        final IType[] namespaces = getNamespaces(sourceModule, namespace,
                cache, monitor);
        final List<IType> result = new LinkedList<IType>();
        for (final IType ns : namespaces) {
            result.addAll(Arrays.asList(PHPModelUtils.getTypeType(ns, prefix,
                    exactName)));
        }
        return result.toArray(new IType[result.size()]);
    }

    private static IType[] getNamespaces(ISourceModule sourceModule,
            String namespaceName, IModelAccessCache cache,
            IProgressMonitor monitor) throws ModelException {
        if (cache != null) {
            final Collection<IType> namespaces = cache.getNamespaces(
                    sourceModule, namespaceName, monitor);
            if (namespaces == null) {
                return PhpModelAccess.NULL_TYPES;
            }
            return namespaces.toArray(new IType[namespaces.size()]);
        }
        final IDLTKSearchScope scope = SearchEngine
                .createSearchScope(sourceModule.getScriptProject());
        final IType[] namespaces = PhpModelAccess.getDefault().findTypes(null,
                namespaceName, MatchRule.EXACT, Modifiers.AccNameSpace, 0,
                scope, monitor);
        return namespaces;
    }

    public static TypeDeclaration getNodeByClass(ModuleDeclaration rootNode,
            IType type) throws ModelException {
        final DeclarationSearcher visitor = new DeclarationSearcher(rootNode,
                type, DeclarationType.CLASS);
        try {
            rootNode.traverse(visitor);
        } catch (final Exception e) {
            if (DLTKCore.DEBUG) {
                GeneratorBeautifierPlugin.log(e);
                // Logger.logException(e);
            }
        }
        return (TypeDeclaration) visitor.getResult();
    }

    public static ASTNode getNodeByElement(ModuleDeclaration rootNode,
            IModelElement element) throws ModelException {
        switch (element.getElementType()) {
            case IModelElement.TYPE:
                return getNodeByClass(rootNode, (IType) element);
            case IModelElement.METHOD:
                return getNodeByMethod(rootNode, (IMethod) element);
            case IModelElement.FIELD:
                return getNodeByField(rootNode, (IField) element);
            default:
                throw new IllegalArgumentException("Unsupported element type: "
                        + element.getClass().getName());
        }
    }

    public static ASTNode getNodeByField(ModuleDeclaration rootNode,
            IField field) throws ModelException {
        final DeclarationSearcher visitor = new DeclarationSearcher(rootNode,
                field, DeclarationType.FIELD);
        try {
            rootNode.traverse(visitor);
        } catch (final Exception e) {
            if (DLTKCore.DEBUG) {
                GeneratorBeautifierPlugin.log(e);
                // Logger.logException(e);
            }
        }
        return visitor.getResult();
    }

    public static MethodDeclaration getNodeByMethod(ModuleDeclaration rootNode,
            IMethod method) throws ModelException {
        final DeclarationSearcher visitor = new DeclarationSearcher(rootNode,
                method, DeclarationType.METHOD);
        try {
            rootNode.traverse(visitor);
        } catch (final Exception e) {
            if (DLTKCore.DEBUG) {
                GeneratorBeautifierPlugin.log(e);
                // Logger.logException(e);
            }
        }
        return (MethodDeclaration) visitor.getResult();
    }

    /**
     * Returns all super classes filtered using file hierarchy
     * 
     * @throws ModelException
     */
    public static IType[] getSuperClasses(IType type, ITypeHierarchy hierarchy)
            throws ModelException {
        if (hierarchy == null) {
            hierarchy = type.newSupertypeHierarchy(null);
        }
        final Collection<IType> filtered = filterElements(
                type.getSourceModule(),
                Arrays.asList(hierarchy.getAllSuperclasses(type)));
        return filtered.toArray(new IType[filtered.size()]);
    }

    /**
     * Finds field in the super class hierarchy
     * 
     * @param type
     *            Class element
     * @param prefix
     *            Field name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @throws CoreException
     */
    public static IField[] getSuperTypeHierarchyField(IType type,
            String prefix, boolean exactName, IProgressMonitor monitor)
            throws CoreException {
        return getSuperTypeHierarchyField(type, null, prefix, exactName,
                monitor);
    }

    /**
     * Finds field in the super class hierarchy
     * 
     * @param type
     *            Class element
     * @param hierarchy
     *            Cached type hierarchy (<code>null</code> to build a new one)
     * @param prefix
     *            Field name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @throws CoreException
     */
    public static IField[] getSuperTypeHierarchyField(IType type,
            ITypeHierarchy hierarchy, String prefix, boolean exactName,
            IProgressMonitor monitor) throws CoreException {

        final IType[] allSuperclasses = getSuperClasses(type, hierarchy);
        return getTypesField(allSuperclasses, prefix, exactName);
    }

    /**
     * Finds method in the super class hierarchy
     * 
     * @param type
     *            Class element
     * @param prefix
     *            Method name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @throws CoreException
     */
    public static IMethod[] getSuperTypeHierarchyMethod(IType type,
            String prefix, boolean exactName, IProgressMonitor monitor)
            throws CoreException {
        return getSuperTypeHierarchyMethod(type, null, prefix, exactName,
                monitor);
    }

    /**
     * Finds method in the super class hierarchy
     * 
     * @param type
     *            Class element
     * @param hierarchy
     *            Cached type hierarchy (<code>null</code> to build a new one)
     * @param prefix
     *            Method name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @throws CoreException
     */
    public static IMethod[] getSuperTypeHierarchyMethod(IType type,
            ITypeHierarchy hierarchy, String prefix, boolean exactName,
            IProgressMonitor monitor) throws CoreException {

        final IType[] allSuperclasses = getSuperClasses(type, hierarchy);
        return getTypesMethod(allSuperclasses, prefix, exactName);
    }

    /**
     * Returns the type field element by name
     * 
     * @param type
     *            Type
     * @param prefix
     *            Field name or prefix
     * @param exactName
     *            Whether the name is exact name or prefix
     * @throws ModelException
     */
    public static IField[] getTypeField(IType type, String prefix,
            boolean exactName) throws ModelException {

        final List<IField> result = new LinkedList<IField>();
        final IField[] fields = type.getFields();
        for (final IField field : fields) {
            String elementName = field.getElementName();
            if (elementName.startsWith("$") && !prefix.startsWith("$")) {
                elementName = elementName.substring(1);
            }
            if (exactName
                    && elementName.equalsIgnoreCase(prefix)
                    || !exactName
                    && elementName.toLowerCase().startsWith(
                            prefix.toLowerCase())) {
                result.add(field);
            }
        }
        return result.toArray(new IField[result.size()]);
    }

    /**
     * Finds field by name in the class hierarchy
     * 
     * @param type
     *            Class element
     * @param hierarchy
     *            Cached type hierarchy
     * @param prefix
     *            Field name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     * @throws CoreException
     */
    public static IField[] getTypeHierarchyField(IType type,
            ITypeHierarchy hierarchy, String prefix, boolean exactName,
            IProgressMonitor monitor) throws CoreException {
        if (prefix == null) {
            throw new NullPointerException();
        }
        final List<IField> fields = new LinkedList<IField>();
        fields.addAll(Arrays.asList(getTypeField(type, prefix, exactName)));
        if (type.getSuperClasses() != null && type.getSuperClasses().length > 0) {
            fields.addAll(Arrays.asList(getSuperTypeHierarchyField(type,
                    hierarchy, prefix, exactName, monitor)));
        }
        return fields.toArray(new IField[fields.size()]);
    }

    /**
     * Finds field by name in the class hierarchy (including the class itself)
     * 
     * @param type
     *            Class element
     * @param prefix
     *            Field name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     * @throws CoreException
     */
    public static IField[] getTypeHierarchyField(IType type, String prefix,
            boolean exactName, IProgressMonitor monitor) throws CoreException {
        return getTypeHierarchyField(type, null, prefix, exactName, monitor);
    }

    /**
     * Finds field documentation by field name in the class hierarchy
     * 
     * @param type
     *            Class element
     * @param name
     *            Field name
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     * @throws CoreException
     */
    public static PHPDocBlock[] getTypeHierarchyFieldDoc(IType type,
            String name, boolean exactName, IProgressMonitor monitor)
            throws CoreException {

        if (name == null) {
            throw new NullPointerException();
        }
        final List<PHPDocBlock> docs = new LinkedList<PHPDocBlock>();
        for (final IField field : getTypeHierarchyField(type, name, exactName,
                monitor)) {
            final PHPDocBlock docBlock = getDocBlock(field);
            if (docBlock != null) {
                docs.add(docBlock);
            }
        }
        return docs.toArray(new PHPDocBlock[docs.size()]);
    }

    /**
     * Finds method by name in the class hierarchy (including the class itself)
     * 
     * @param type
     *            Class element
     * @param hierarchy
     *            Cached type hierarchy
     * @param prefix
     *            Method name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     * @throws CoreException
     */
    public static IMethod[] getTypeHierarchyMethod(IType type,
            ITypeHierarchy hierarchy, String prefix, boolean exactName,
            IProgressMonitor monitor) throws CoreException {

        if (prefix == null) {
            throw new NullPointerException();
        }
        final List<IMethod> methods = new LinkedList<IMethod>();
        methods.addAll(Arrays.asList(getTypeMethod(type, prefix, exactName)));
        if (type.getSuperClasses() != null && type.getSuperClasses().length > 0) {
            methods.addAll(Arrays.asList(getSuperTypeHierarchyMethod(type,
                    hierarchy, prefix, exactName, monitor)));
        }
        return methods.toArray(new IMethod[methods.size()]);
    }

    /**
     * Finds the first method by name in the class hierarchy (including the
     * class itself)
     * 
     * @param type
     *            Class element
     * @param hierarchy
     *            Cached type hierarchy
     * @param prefix
     *            Method name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     * @throws CoreException
     */
    public static IMethod[] getFirstTypeHierarchyMethod(IType type,
            ITypeHierarchy hierarchy, String prefix, boolean exactName,
            IProgressMonitor monitor) throws CoreException {

        if (prefix == null) {
            throw new NullPointerException();
        }
        final List<IMethod> methods = new LinkedList<IMethod>();
        methods.addAll(Arrays.asList(getTypeMethod(type, prefix, exactName)));
        if (type.getSuperClasses() != null && type.getSuperClasses().length > 0
                && methods.size() == 0) {
            final IType[] allSuperclasses = getSuperClasses(type, hierarchy);
            for (final IType superClass : allSuperclasses) {
                final IMethod[] method = getTypeMethod(superClass, prefix,
                        exactName);
                if (method != null && method.length > 0) {
                    methods.addAll(Arrays.asList(method));
                    break;
                }
            }

        }
        return methods.toArray(new IMethod[methods.size()]);
    }

    /**
     * Finds method by name in the class hierarchy (including the class itself)
     * 
     * @param type
     *            Class element
     * @param prefix
     *            Method name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     * @throws CoreException
     */
    public static IMethod[] getTypeHierarchyMethod(IType type, String prefix,
            boolean exactName, IProgressMonitor monitor) throws CoreException {
        return getTypeHierarchyMethod(type, null, prefix, exactName, monitor);
    }

    /**
     * Finds method documentation by method name in the class hierarchy
     * 
     * @param type
     *            Class element
     * @param prefix
     *            Method name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @param monitor
     *            Progress monitor
     * @throws CoreException
     */
    public static PHPDocBlock[] getTypeHierarchyMethodDoc(IType type,
            String prefix, boolean exactName, IProgressMonitor monitor)
            throws CoreException {

        if (prefix == null) {
            throw new NullPointerException();
        }
        final List<PHPDocBlock> docs = new LinkedList<PHPDocBlock>();
        for (final IMethod method : getTypeHierarchyMethod(type, prefix,
                exactName, monitor)) {
            final PHPDocBlock docBlock = getDocBlock(method);
            if (docBlock != null) {
                docs.add(docBlock);
            }
        }
        return docs.toArray(new PHPDocBlock[docs.size()]);
    }

    /**
     * Returns the type method element by name
     * 
     * @param type
     *            Type
     * @param prefix
     *            Method name or prefix
     * @param exactName
     *            Whether the name is exact name or prefix
     * @throws ModelException
     */
    public static IMethod[] getTypeMethod(IType type, String prefix,
            boolean exactName) throws ModelException {

        final List<IMethod> result = new LinkedList<IMethod>();
        final IMethod[] methods = type.getMethods();
        for (final IMethod method : methods) {
            final String elementName = method.getElementName();
            if (exactName
                    && elementName.equalsIgnoreCase(prefix)
                    || !exactName
                    && elementName.toLowerCase().startsWith(
                            prefix.toLowerCase())) {
                result.add(method);
            }
        }
        return result.toArray(new IMethod[result.size()]);
    }

    /**
     * This method returns type corresponding to its name and the file where it
     * was referenced. The type name may contain also the namespace part, like:
     * A\B\C or \A\B\C
     * 
     * @param typeName
     *            Tye fully qualified type name
     * @param sourceModule
     *            The file where the element is referenced
     * @param offset
     *            The offset where the element is referenced
     * @param monitor
     *            Progress monitor
     * @return a list of relevant IType elements, or <code>null</code> in case
     *         there's no IType found
     * @throws ModelException
     */
    public static IType[] getTypes(String typeName, ISourceModule sourceModule,
            int offset, IProgressMonitor monitor) throws ModelException {
        return getTypes(typeName, sourceModule, offset, null, monitor);
    }

    /**
     * This method returns type corresponding to its name and the file where it
     * was referenced. The type name may contain also the namespace part, like:
     * A\B\C or \A\B\C
     * 
     * @param typeName
     *            Tye fully qualified type name
     * @param sourceModule
     *            The file where the element is referenced
     * @param offset
     *            The offset where the element is referenced
     * @param cache
     *            Model access cache if available
     * @param monitor
     *            Progress monitor
     * @return a list of relevant IType elements, or <code>null</code> in case
     *         there's no IType found
     * @throws ModelException
     */
    public static IType[] getTypes(String typeName, ISourceModule sourceModule,
            int offset, IModelAccessCache cache, IProgressMonitor monitor)
            throws ModelException {

        if (typeName == null || typeName.length() == 0) {
            return PhpModelAccess.NULL_TYPES;
        }

        String namespace = extractNamespaceName(typeName, sourceModule, offset);
        typeName = extractElementName(typeName);
        if (namespace != null) {
            if (namespace.length() > 0) {
                final IType[] types = getNamespaceType(namespace, typeName,
                        true, sourceModule, cache, monitor);
                if (types.length > 0) {
                    return types;
                }
                return PhpModelAccess.NULL_TYPES;
            }
            // it's a global reference: \A
        }
        else {
            // look for the element in current namespace:
            final IType currentNamespace = getCurrentNamespace(sourceModule,
                    offset);
            if (currentNamespace != null) {
                namespace = currentNamespace.getElementName();
                final IType[] types = getNamespaceType(namespace, typeName,
                        true, sourceModule, cache, monitor);
                if (types.length > 0) {
                    return types;
                }
            }
        }

        Collection<IType> types;
        if (cache == null) {
            final IDLTKSearchScope scope = SearchEngine
                    .createSearchScope(sourceModule.getScriptProject());
            final IType[] r = PhpModelAccess.getDefault().findTypes(typeName,
                    MatchRule.EXACT, 0, 0, scope, null);
            types = filterElements(sourceModule, Arrays.asList(r));
        }
        else {
            types = cache.getTypes(sourceModule, typeName, null, monitor);
            if (types == null) {
                return PhpModelAccess.NULL_TYPES;
            }
        }
        final List<IType> result = new ArrayList<IType>(types.size());
        for (final IType type : types) {
            if (getCurrentNamespace(type) == null) {
                result.add(type);
            }
        }
        return result.toArray(new IType[result.size()]);
    }

    /**
     * Finds field in the list of given types
     * 
     * @param types
     *            List of types
     * @param prefix
     *            Field name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @throws ModelException
     */
    public static IField[] getTypesField(IType[] types, String prefix,
            boolean exactName) throws ModelException {
        final List<IField> result = new LinkedList<IField>();
        for (final IType type : types) {
            result.addAll(Arrays.asList(getTypeField(type, prefix, exactName)));
        }
        return result.toArray(new IField[result.size()]);
    }

    /**
     * Finds method in the list of given types
     * 
     * @param types
     *            List of types
     * @param prefix
     *            Method name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @throws ModelException
     */
    public static IMethod[] getTypesMethod(IType[] types, String prefix,
            boolean exactName) throws ModelException {
        final List<IMethod> result = new LinkedList<IMethod>();
        for (final IType type : types) {
            result.addAll(Arrays.asList(getTypeMethod(type, prefix, exactName)));
        }
        return result.toArray(new IMethod[result.size()]);
    }

    /**
     * Returns the type inner type element by name
     * 
     * @param type
     *            Type
     * @param prefix
     *            Enclosed type name or prefix
     * @param exactName
     *            Whether the name is exact or it is prefix
     * @throws ModelException
     */
    public static IType[] getTypeType(IType type, String prefix,
            boolean exactName) throws ModelException {
        final List<IType> result = new LinkedList<IType>();
        final IType[] types = type.getTypes();
        for (final IType t : types) {
            final String elementName = t.getElementName();
            if (exactName
                    && elementName.equalsIgnoreCase(prefix)
                    || !exactName
                    && elementName.toLowerCase().startsWith(
                            prefix.toLowerCase())) {
                result.add(t);
            }
        }
        return result.toArray(new IType[result.size()]);
    }

    /**
     * Returns methods that must be overridden in first non-abstract class in
     * hierarchy.
     * 
     * @param type
     *            Type to start the search from
     * @param monitor
     *            Progress monitor
     * @return unimplemented methods
     * @throws ModelException
     */
    public static IMethod[] getUnimplementedMethods(IType type,
            IProgressMonitor monitor) throws ModelException {

        return getUnimplementedMethods(type, null, monitor);
    }

    /**
     * Returns methods that must be overridden in first non-abstract class in
     * hierarchy.
     * 
     * @param type
     *            Type to start the search from
     * @param cache
     *            Temporary model cache instance
     * @param monitor
     *            Progress monitor
     * @return unimplemented methods
     * @throws ModelException
     */
    public static IMethod[] getUnimplementedMethods(IType type,
            IModelAccessCache cache, IProgressMonitor monitor)
            throws ModelException {

        final HashMap<String, IMethod> abstractMethods = new HashMap<String, IMethod>();
        final HashSet<String> nonAbstractMethods = new HashSet<String>();

        internalGetUnimplementedMethods(type, nonAbstractMethods,
                abstractMethods, new HashSet<String>(), cache, monitor);

        for (final String methodName : nonAbstractMethods) {
            abstractMethods.remove(methodName);
        }

        final Collection<IMethod> unimplementedMethods = abstractMethods
                .values();
        return unimplementedMethods.toArray(new IMethod[unimplementedMethods
                .size()]);
    }

    private static void internalGetUnimplementedMethods(IType type,
            HashSet<String> nonAbstractMethods,
            HashMap<String, IMethod> abstractMethods,
            Set<String> processedTypes, IModelAccessCache cache,
            IProgressMonitor monitor) throws ModelException {

        final int typeFlags = type.getFlags();
        for (final IMethod method : type.getMethods()) {
            final String methodName = method.getElementName();
            final int methodFlags = method.getFlags();
            final boolean isAbstract = PHPFlags.isAbstract(methodFlags);
            if (isAbstract || PHPFlags.isInterface(typeFlags)) {
                if (!abstractMethods.containsKey(methodName)) {
                    abstractMethods.put(methodName, method);
                }
            }
            else if (!isAbstract) {
                nonAbstractMethods.add(methodName);
            }
        }

        final String[] superClasses = type.getSuperClasses();
        if (superClasses != null) {
            for (String superClass : superClasses) {
                if (!processedTypes.add(superClass)) {
                    continue;
                }

                Collection<IType> types = null;
                if (cache == null) {
                    final IDLTKSearchScope scope = SearchEngine
                            .createSearchScope(type.getScriptProject());
                    final IType[] superTypes = PhpModelAccess.getDefault()
                            .findTypes(superClass, MatchRule.EXACT, 0,
                                    Modifiers.AccNameSpace, scope, null);
                    types = fileNetworkFilter(type.getSourceModule(),
                            Arrays.asList(superTypes), null);
                }
                else {
                    String namespaceName = null;
                    final int i = superClass
                            .lastIndexOf(NamespaceReference.NAMESPACE_SEPARATOR);
                    if (i != -1) {
                        namespaceName = superClass.substring(0, i);
                        superClass = superClass.substring(i + 1);
                    }
                    types = cache.getClassesOrInterfaces(
                            type.getSourceModule(), superClass, namespaceName,
                            monitor);
                }
                if (types != null) {
                    for (final IType superType : types) {
                        internalGetUnimplementedMethods(superType,
                                nonAbstractMethods, abstractMethods,
                                processedTypes, cache, monitor);
                    }
                }
            }
        }
    }

    /**
     * 
     * @param type
     *            the given type
     * @return if the given type has static member
     */
    public static boolean hasStaticMember(IType type) {
        try {
            final ITypeHierarchy hierarchy = type.newSupertypeHierarchy(null);
            IModelElement[] members = PHPModelUtils.getTypeHierarchyField(type,
                    hierarchy, "", false, null);
            if (hasStaticElement(members)) {
                return true;
            }
            members = PHPModelUtils.getTypeHierarchyMethod(type, hierarchy, "",
                    false, null);
            if (hasStaticElement(members)) {
                return true;
            }
        } catch (final ModelException e) {
            PHPCorePlugin.log(e);
        } catch (final CoreException e) {
            PHPCorePlugin.log(e);
        }
        return false;
    }

    public static boolean hasStaticElement(IModelElement[] elements)
            throws ModelException {
        for (final IModelElement modelElement : elements) {
            if (modelElement instanceof IMember) {
                final IMember member = (IMember) modelElement;
                if (Flags.isStatic(member.getFlags())) {
                    return true;
                }

            }
        }
        return false;
    }
}
