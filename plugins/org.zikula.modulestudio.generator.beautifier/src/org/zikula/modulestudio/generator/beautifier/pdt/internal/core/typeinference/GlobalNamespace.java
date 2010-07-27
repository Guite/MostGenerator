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
 *******************************************************************************/

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

import org.eclipse.dltk.ast.Modifiers;
import org.eclipse.dltk.core.IField;
import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.IScriptProject;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.index2.search.ISearchEngine.MatchRule;
import org.eclipse.dltk.core.search.IDLTKSearchScope;
import org.eclipse.dltk.core.search.SearchEngine;
import org.eclipse.dltk.internal.core.ModelElement;
import org.eclipse.dltk.internal.core.SourceType;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.model.PhpModelAccess;

/**
 * Fake model element representing global namespace type
 * 
 * @author michael
 */
public class GlobalNamespace extends SourceType {

    public static final String NAME = "<global>";

    public GlobalNamespace(IScriptProject project) {
        super((ModelElement) project, NAME);
    }

    @Override
    public IField[] getFields() throws ModelException {
        final IDLTKSearchScope scope = SearchEngine.createSearchScope(
                getParent(), IDLTKSearchScope.SOURCES);
        return PhpModelAccess.getDefault().findFields(null, MatchRule.PREFIX,
                Modifiers.AccGlobal, 0, scope, null);
    }

    @Override
    public IMethod[] getMethods() throws ModelException {
        final IDLTKSearchScope scope = SearchEngine.createSearchScope(
                getParent(), IDLTKSearchScope.SOURCES);
        return PhpModelAccess.getDefault().findMethods(null, MatchRule.PREFIX,
                Modifiers.AccGlobal, 0, scope, null);
    }

    @Override
    public IType[] getTypes() throws ModelException {
        final IDLTKSearchScope scope = SearchEngine.createSearchScope(
                getParent(), IDLTKSearchScope.SOURCES);
        return PhpModelAccess.getDefault().findTypes(null, MatchRule.PREFIX,
                Modifiers.AccGlobal, Modifiers.AccNameSpace, scope, null);
    }

    @Override
    public IModelElement[] getChildren() throws ModelException {
        final List<IModelElement> result = new LinkedList<IModelElement>();
        result.addAll(Arrays.asList(getFields()));
        result.addAll(Arrays.asList(getMethods()));
        result.addAll(Arrays.asList(getTypes()));
        return result.toArray(new IModelElement[result.size()]);
    }

    @Override
    public int getFlags() throws ModelException {
        return Modifiers.AccNameSpace;
    }

    @Override
    public boolean exists() {
        return true;
    }
}
