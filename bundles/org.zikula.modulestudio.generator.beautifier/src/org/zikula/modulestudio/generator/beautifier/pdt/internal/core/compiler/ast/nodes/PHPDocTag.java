package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes;

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
 * Based on package org.eclipse.php.internal.core.compiler.ast.nodes;
 * 
 *******************************************************************************/

import java.util.LinkedList;
import java.util.List;

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.references.SimpleReference;
import org.eclipse.dltk.ast.references.TypeReference;
import org.eclipse.dltk.ast.references.VariableReference;

public class PHPDocTag extends ASTNode implements PHPDocTagKinds {

    public static final String ERROR = "ERROR!!!"; //$NON-NLS-1$
    public static final String THROWS_NAME = "throws"; //$NON-NLS-1$
    public static final String VERSION_NAME = "version"; //$NON-NLS-1$
    public static final String USES_NAME = "uses"; //$NON-NLS-1$
    public static final String TUTORIAL_NAME = "tutorial"; //$NON-NLS-1$
    public static final String SUBPACKAGE_NAME = "subpackage"; //$NON-NLS-1$
    public static final String SINCE_NAME = "since"; //$NON-NLS-1$
    public static final String LINK_NAME = "link"; //$NON-NLS-1$
    public static final String LICENSE_NAME = "license"; //$NON-NLS-1$
    public static final String INTERNAL_NAME = "internal"; //$NON-NLS-1$
    public static final String IGNORE_NAME = "ignore"; //$NON-NLS-1$
    public static final String FILESOURCE_NAME = "filesource"; //$NON-NLS-1$
    public static final String EXAMPLE_NAME = "example"; //$NON-NLS-1$
    public static final String DESC_NAME = "desc"; //$NON-NLS-1$
    public static final String COPYRIGHT_NAME = "copyright"; //$NON-NLS-1$
    public static final String CATEGORY_NAME = "category"; //$NON-NLS-1$
    public static final String ACCESS_NAME = "access"; //$NON-NLS-1$
    public static final String PACKAGE_NAME = "package"; //$NON-NLS-1$
    public static final String VAR_NAME = "var"; //$NON-NLS-1$
    public static final String TODO_NAME = "todo"; //$NON-NLS-1$
    public static final String STATICVAR_NAME = "staticvar"; //$NON-NLS-1$
    public static final String STATIC_NAME = "static"; //$NON-NLS-1$
    public static final String SEE_NAME = "see"; //$NON-NLS-1$
    public static final String PARAM_NAME = "param"; //$NON-NLS-1$
    public static final String RETURN_NAME = "return"; //$NON-NLS-1$
    public static final String NAME_NAME = "name"; //$NON-NLS-1$
    public static final String GLOBAL_NAME = "global"; //$NON-NLS-1$
    public static final String FINAL_NAME = "final"; //$NON-NLS-1$
    public static final String DEPRECATED_NAME = "deprecated"; //$NON-NLS-1$
    public static final String AUTHOR_NAME = "author"; //$NON-NLS-1$
    public static final String ABSTRACT_NAME = "abstract"; //$NON-NLS-1$
    public static final String PROPERTY_NAME = "property"; //$NON-NLS-1$
    public static final String PROPERTY_READ_NAME = "property-read"; //$NON-NLS-1$
    public static final String PROPERTY_WRITE_NAME = "property-write"; //$NON-NLS-1$
    public static final String METHOD_NAME = "method"; //$NON-NLS-1$

    private static final SimpleReference[] EMPTY = {};
    private final int tagKind;
    private final String value;
    private SimpleReference[] references;

    public PHPDocTag(int start, int end, int tagKind, String value) {
        super(start, end);
        this.tagKind = tagKind;
        this.value = value;
        updateReferences(start, end);
    }

    private static int getNonWhitespaceIndex(String line, int startIndex) {
        int i = startIndex;
        for (; i < line.length(); ++i) {
            if (!Character.isWhitespace(line.charAt(i))) {
                return i;
            }
        }
        return i;
    }

    private static int getWhitespaceIndex(String line, int startIndex) {
        int i = startIndex;
        for (; i < line.length(); ++i) {
            if (Character.isWhitespace(line.charAt(i))) {
                return i;
            }
        }
        return i;
    }

    private static int getClassStartIndex(String line, int startIndex) {
        int i = startIndex;
        for (; i < line.length(); ++i) {
            if (line.charAt(i) != '|') {
                return i;
            }
        }
        return i;
    }

    private static int getClassEndIndex(String line, int startIndex) {
        int i = startIndex;
        for (; i < line.length(); ++i) {
            if (line.charAt(i) == '|') {
                return i;
            }
        }
        return i;
    }

    private void updateReferences(int start, int end) {

        final int valueStart = start + getTagKind(tagKind).length() + 1;

        if (tagKind == RETURN || tagKind == VAR || tagKind == THROWS) {

            final int wordStart = getNonWhitespaceIndex(value, 0);
            final int wordEnd = getWhitespaceIndex(value, wordStart);
            if (wordStart < wordEnd) {

                final String word = value.substring(wordStart, wordEnd);

                int classStart = getClassStartIndex(word, 0);
                int classEnd = getClassEndIndex(word, classStart);
                final List<TypeReference> types = new LinkedList<TypeReference>();

                while (classStart < classEnd) {
                    final String className = word.substring(classStart,
                            classEnd);
                    types.add(new TypeReference(valueStart + wordStart
                            + classStart, valueStart + wordStart + classEnd,
                            className));

                    classStart = getClassStartIndex(word, classEnd);
                    classEnd = getClassEndIndex(word, classStart);
                }
                if (types.size() > 0) {
                    references = types.toArray(new TypeReference[types.size()]);
                }
            }
        }
        else if (tagKind == PARAM) {

            final int firstWordStart = getNonWhitespaceIndex(value, 0);
            final int firstWordEnd = getWhitespaceIndex(value, firstWordStart);
            if (firstWordStart < firstWordEnd) {

                final int secondWordStart = getNonWhitespaceIndex(value,
                        firstWordEnd);
                final int secondWordEnd = getWhitespaceIndex(value,
                        secondWordStart);
                if (secondWordStart < secondWordEnd) {

                    final String firstWord = value.substring(firstWordStart,
                            firstWordEnd);
                    final String secondWord = value.substring(secondWordStart,
                            secondWordEnd);
                    if (firstWord.charAt(0) == '$') {
                        references = new SimpleReference[2];
                        references[0] = new VariableReference(valueStart
                                + firstWordStart, valueStart + firstWordEnd,
                                firstWord);
                        references[1] = new TypeReference(valueStart
                                + secondWordStart, valueStart + secondWordEnd,
                                secondWord);
                    }
                    else if (secondWord.charAt(0) == '$') {
                        references = new SimpleReference[2];
                        references[0] = new VariableReference(valueStart
                                + secondWordStart, valueStart + secondWordEnd,
                                secondWord);
                        references[1] = new TypeReference(valueStart
                                + firstWordStart, valueStart + firstWordEnd,
                                firstWord);
                    }
                }
            }
        }
        if (references == null) {
            references = EMPTY;
        }
    }

    @Override
    public void traverse(ASTVisitor visitor) throws Exception {
        final boolean visit = visitor.visit(this);
        if (visit) {
            for (final SimpleReference ref : references) {
                ref.traverse(visitor);
            }
        }
        visitor.endvisit(this);
    }

    public int getKind() {
        return ASTNodeKinds.PHP_DOC_TAG;
    }

    public int getTagKind() {
        return this.tagKind;
    }

    public String getValue() {
        return value;
    }

    public SimpleReference[] getReferences() {
        return references;
    }

    public void adjustStart(int start) {
        setStart(sourceStart() + start);
        setEnd(sourceEnd() + start);
    }

    public static String getTagKind(int kind) {
        switch (kind) {
            case ABSTRACT:
                return ABSTRACT_NAME;
            case AUTHOR:
                return AUTHOR_NAME;
            case DEPRECATED:
                return DEPRECATED_NAME;
            case FINAL:
                return FINAL_NAME;
            case GLOBAL:
                return GLOBAL_NAME;
            case NAME:
                return NAME_NAME;
            case RETURN:
                return RETURN_NAME;
            case PARAM:
                return PARAM_NAME;
            case SEE:
                return SEE_NAME;
            case STATIC:
                return STATIC_NAME;
            case STATICVAR:
                return STATICVAR_NAME;
            case TODO:
                return TODO_NAME;
            case VAR:
                return VAR_NAME;
            case PACKAGE:
                return PACKAGE_NAME;
            case ACCESS:
                return ACCESS_NAME;
            case CATEGORY:
                return CATEGORY_NAME;
            case COPYRIGHT:
                return COPYRIGHT_NAME;
            case DESC:
                return DESC_NAME;
            case EXAMPLE:
                return EXAMPLE_NAME;
            case FILESOURCE:
                return FILESOURCE_NAME;
            case IGNORE:
                return IGNORE_NAME;
            case INTERNAL:
                return INTERNAL_NAME;
            case LICENSE:
                return LICENSE_NAME;
            case LINK:
                return LINK_NAME;
            case SINCE:
                return SINCE_NAME;
            case SUBPACKAGE:
                return SUBPACKAGE_NAME;
            case TUTORIAL:
                return TUTORIAL_NAME;
            case USES:
                return USES_NAME;
            case VERSION:
                return VERSION_NAME;
            case THROWS:
                return THROWS_NAME;
            case PROPERTY:
                return PROPERTY_NAME;
            case PROPERTY_READ:
                return PROPERTY_READ_NAME;
            case PROPERTY_WRITE:
                return PROPERTY_WRITE_NAME;
            case METHOD:
                return METHOD_NAME;
        }
        return ERROR;
    }
}
