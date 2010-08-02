package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.format;

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
 * Based on package org.eclipse.php.internal.core.format;
 * 
 *******************************************************************************/

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IRegion;
import org.eclipse.wst.sse.core.internal.format.IStructuredFormatContraints;
import org.eclipse.wst.sse.core.internal.format.IStructuredFormatPreferences;
import org.eclipse.wst.sse.core.internal.format.IStructuredFormatter;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocument;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocumentRegion;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegion;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegionContainer;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegionList;
import org.eclipse.wst.sse.core.internal.text.rules.SimpleStructuredRegion;
import org.eclipse.wst.xml.core.internal.provisional.document.IDOMNode;
import org.w3c.dom.Node;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.dom.AttrImplForPhp;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.dom.ElementImplForPhp;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.IPhpScriptRegion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.PHPRegionTypes;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.PhpScriptRegion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.partitioner.PHPPartitionTypes;

public class PhpFormatter implements IStructuredFormatter {

    private final IIndentationStrategy defaultIndentationStrategy = new DefaultIndentationStrategy();
    private final IIndentationStrategy curlyCloseIndentationStrategy = new CurlyCloseIndentationStrategy();
    private final IIndentationStrategy caseDefaultIndentationStrategy = new CaseDefaultIndentationStrategy();
    private final IIndentationStrategy commentIndentationStrategy = new CommentIndentationStrategy();
    private final IIndentationStrategy phpCloseTagIndentationStrategy = new PHPCloseTagIndentationStrategy();

    protected PhpFormatConstraints fFormatContraints = null;
    protected IStructuredFormatPreferences fFormatPreferences = null;
    protected IProgressMonitor fProgressMonitor = null;
    private final int length;
    private final int start;

    private static final byte CHAR_TAB = '\t';
    private static final byte CHAR_SPACE = ' ';

    public PhpFormatter(int start, int length) {
        this.start = start;
        this.length = length;
    }

    @Override
    public void format(Node node) {
        format(node, getFormatContraints());
    }

    @Override
    public void format(Node node, IStructuredFormatContraints formatContraints) {
        if (node instanceof IDOMNode) {
            formatNode((IDOMNode) node, formatContraints);
        }

    }

    /**
     * Recursivly call the format node on every node in the model
     * 
     * @param node
     *            - to fotmat
     * @param formatContraints
     */
    private void formatNode(IDOMNode node,
            IStructuredFormatContraints formatContraints) {

        // if it is php node - format
        if (node instanceof ElementImplForPhp
                && ((ElementImplForPhp) node).isPhpTag()) {
            final IStructuredDocumentRegion sdRegionStart = node
                    .getStartStructuredDocumentRegion();
            // IStructuredDocumentRegion sdRegionEnd =
            // node.getLastStructuredDocumentRegion();
            // sdRegionEnd = sdRegionEnd == null ? sdRegionStart : sdRegionEnd;
            format(sdRegionStart);
        }

        if (node instanceof AttrImplForPhp) {
            // calculate lines
            final IStructuredDocument document = node.getStructuredDocument();
            int lineIndex = document.getLineOfOffset(node.getStartOffset());
            final int endLineIndex = document.getLineOfOffset(node
                    .getEndOffset());

            // format each line
            for (; lineIndex <= endLineIndex; lineIndex++) {
                formatLine(document, lineIndex);
            }
        }

        if (node.hasChildNodes()) { // container
            IDOMNode child = (IDOMNode) node.getFirstChild();
            while (child != null) {
                formatNode(child, formatContraints);
                child = (IDOMNode) child.getNextSibling();
            }
        }
    }

    @Override
    public IStructuredFormatContraints getFormatContraints() {
        if (fFormatContraints == null) {
            fFormatContraints = new PhpFormatConstraints();
        }
        return fFormatContraints;
    }

    @Override
    public IStructuredFormatPreferences getFormatPreferences() {
        return fFormatPreferences;
    }

    @Override
    public void setFormatPreferences(
            IStructuredFormatPreferences formatPreferences) {
        this.fFormatPreferences = formatPreferences;
    }

    @Override
    public void setProgressMonitor(IProgressMonitor monitor) {
        this.fProgressMonitor = monitor;
    }

    protected final int getStart() {
        return start;
    }

    protected final int getLength() {
        return length;
    }

    public void format(IStructuredDocumentRegion sdRegion) {
        assert sdRegion != null;

        // resolce formatter range
        final int regionStart = sdRegion.getStartOffset();
        final int regionEnd = sdRegion.getEnd();

        final int formatRequestStart = getStart();
        final int formatRequestEnd = formatRequestStart + getLength();

        final int startFormat = Math.max(formatRequestStart, regionStart);
        final int endFormat = Math.min(formatRequestEnd, regionEnd);

        // calculate lines
        final IStructuredDocument document = sdRegion.getParentDocument();
        int lineIndex = document.getLineOfOffset(startFormat);
        int endLineIndex = document.getLineOfOffset(endFormat);
        final ITextRegionList textRegions = sdRegion.getRegions();
        final String newline = document.getLineDelimiter();
        for (int i = 0; i < textRegions.size(); i++) {
            final ITextRegion textRegion = textRegions.get(i);
            if (textRegion instanceof PhpScriptRegion) {
                final int startOffset = sdRegion.getStartOffset(textRegion);
                final PhpScriptRegion scriptRegion = (PhpScriptRegion) textRegion;
                ITextRegion[] phpTokens;
                try {
                    phpTokens = scriptRegion.getPhpTokens(0,
                            textRegion.getLength());
                    for (int j = phpTokens.length - 1; j >= 0; j--) {
                        final ITextRegion phpToken = phpTokens[j];
                        final int start = startOffset + phpToken.getStart();
                        final int end = start + phpToken.getLength();
                        if (/* endFormat >= end || */startFormat <= start
                                && endFormat >= end) {
                            if (phpToken.getType().equals(
                                    PHPRegionTypes.PHP_CURLY_OPEN)) {
                                if (j < phpTokens.length - 1 && j > 0) {
                                    if (phpTokens[j - 1].getType().equals(
                                            PHPRegionTypes.PHP_TOKEN)
                                            && document
                                                    .getLineOfOffset(startOffset
                                                            + phpToken
                                                                    .getStart()) == document
                                                    .getLineOfOffset(startOffset
                                                            + phpTokens[j + 1]
                                                                    .getStart())) {
                                        document.replace(
                                                startOffset + phpToken.getEnd(),
                                                0, newline);
                                        endLineIndex++;
                                    }
                                }
                            }
                            else if (phpToken.getType().equals(
                                    PHPRegionTypes.PHP_CURLY_CLOSE)) {
                                if (j > 0
                                        && (phpTokens[j - 1].getType().equals(
                                                PHPRegionTypes.PHP_SEMICOLON) || phpTokens[j - 1]
                                                .getType()
                                                .equals(PHPRegionTypes.PHP_CURLY_CLOSE))) {
                                    if (document.getLineOfOffset(startOffset
                                            + phpToken.getStart()) == document
                                            .getLineOfOffset(startOffset
                                                    + phpTokens[j - 1]
                                                            .getStart())) {
                                        document.replace(startOffset
                                                + phpTokens[j - 1].getEnd(), 0,
                                                newline);
                                        endLineIndex++;
                                    }
                                }
                            }
                        }

                    }
                } catch (final BadLocationException e) {
                }
            }
        }
        sdRegion.getRegionAtCharacterOffset(startFormat);
        // TODO get token of each line then insert line seporator after { and
        // after } if there is no line seporator
        // format each line
        for (; lineIndex <= endLineIndex; lineIndex++) {
            formatLine(document, lineIndex);
        }

    }

    private final StringBuffer resultBuffer = new StringBuffer();

    /**
     * formats a PHP line according to the strategies and formatting conventions
     * 
     * @param document
     * @param lineNumber
     *            TODO: we should invoke document.replace() one and not twice!
     */
    private void formatLine(IStructuredDocument document, int lineNumber) {
        resultBuffer.setLength(0);

        try {

            // get original line information
            final IRegion originalLineInfo = document
                    .getLineInformation(lineNumber);
            final int orginalLineStart = originalLineInfo.getOffset();
            final int originalLineLength = originalLineInfo.getLength();

            // fast resolving of empty line
            if (originalLineLength == 0) {
                return;
            }

            // get formatted line information
            final String lineText = document.get(orginalLineStart,
                    originalLineLength);
            final IRegion formattedLineInformation = getFormattedLineInformation(
                    originalLineInfo, lineText);

            if (!shouldReformat(document, formattedLineInformation)) {
                return;
            }

            // remove ending spaces.
            final int formattedLineStart = formattedLineInformation.getOffset();
            final int formattedTextEnd = formattedLineStart
                    + formattedLineInformation.getLength();
            final int originalTextEnd = orginalLineStart + originalLineLength;
            if (formattedTextEnd != originalTextEnd) {
                document.replace(formattedTextEnd, originalTextEnd
                        - formattedTextEnd, ""); //$NON-NLS-1$
                // in case there is no text in the line just quit (since the
                // formatted of empty line is empty line)
                if (formattedLineStart == formattedTextEnd) {
                    return;
                }
            }

            // get regions
            final int startingWhiteSpaces = formattedLineStart
                    - orginalLineStart;
            final IIndentationStrategy insertionStrategy;
            final IStructuredDocumentRegion sdRegion = document
                    .getRegionAtCharacterOffset(formattedLineStart);
            ITextRegion firstTokenInLine = sdRegion
                    .getRegionAtCharacterOffset(formattedLineStart);
            int regionStart = sdRegion.getStartOffset(firstTokenInLine);
            if (firstTokenInLine instanceof ITextRegionContainer) {
                final ITextRegionContainer container = (ITextRegionContainer) firstTokenInLine;
                firstTokenInLine = container
                        .getRegionAtCharacterOffset(formattedLineStart);
                regionStart += firstTokenInLine.getStart();
            }

            if (firstTokenInLine instanceof IPhpScriptRegion) {
                final IPhpScriptRegion scriptRegion = (IPhpScriptRegion) firstTokenInLine;
                firstTokenInLine = scriptRegion.getPhpToken(formattedLineStart
                        - regionStart);
                if (firstTokenInLine != null
                        && firstTokenInLine.getStart()
                                + sdRegion.getStartOffset() < orginalLineStart
                        && firstTokenInLine.getType() == PHPRegionTypes.WHITESPACE) {
                    firstTokenInLine = scriptRegion
                            .getPhpToken(formattedLineStart - regionStart
                                    + firstTokenInLine.getLength());
                }
            }

            // if the first char is not from this line
            if (firstTokenInLine == null) {
                return;
            }

            /*
             * if (firstTokenInLine.getStart() + sdRegion.getStartOffset() <
             * originalLineInfo.getOffset() || firstTokenInLine.getType() ==
             * PHPRegionTypes.WHITESPACE) { //meaning we got previos line last
             * token firstTokenInLine =
             * sdRegion.getRegionAtCharacterOffset(sdRegion.getStartOffset() +
             * firstTokenInLine.getEnd()); } // if the next char is not from
             * this line if (firstTokenInLine == null) { return; }
             */

            final String firstTokenType = firstTokenInLine.getType();
            if (firstTokenType == PHPRegionTypes.PHP_CASE
                    || firstTokenType == PHPRegionTypes.PHP_DEFAULT) {
                insertionStrategy = caseDefaultIndentationStrategy;
            }
            else if (isPHPCommentRegion(firstTokenType)) {
                insertionStrategy = commentIndentationStrategy;
            }
            else if (firstTokenType == PHPRegionTypes.PHP_CLOSETAG) {
                insertionStrategy = phpCloseTagIndentationStrategy;
            }
            else {
                insertionStrategy = getIndentationStrategy(lineText
                        .charAt(startingWhiteSpaces));
            }

            // Fill the buffer with blanks as if we added a "\n" to the end of
            // the prev element.
            // insertionStrategy.placeMatchingBlanks(editor,doc,insertionStrtegyKey,resultBuffer,startOffset-1);
            insertionStrategy.placeMatchingBlanks(document, resultBuffer,
                    lineNumber, document.getLineOffset(lineNumber));

            // replace the starting spaces
            final String newIndentation = resultBuffer.toString();
            final String oldIndentation = lineText.substring(0,
                    startingWhiteSpaces);
            char newChar = '\0';
            if (newIndentation.length() > 0) {
                newChar = newIndentation.charAt(0);
            }
            char oldChar = '\0';
            if (oldIndentation.length() > 0) {
                oldChar = oldIndentation.charAt(0);
            }
            if (newIndentation.length() != oldIndentation.length()
                    || newChar != oldChar) {
                document.replaceText(sdRegion, orginalLineStart,
                        startingWhiteSpaces, newIndentation);
            }

        } catch (final BadLocationException e) {
            GeneratorBeautifierPlugin.log(e);
            // Logger.logException(e);
        }
    }

    /**
     * @return whether we are inside a php comment
     */
    private boolean isPHPCommentRegion(String tokenType) {
        return (tokenType == PHPRegionTypes.PHP_COMMENT
                || tokenType == PHPRegionTypes.PHP_COMMENT_END
                || tokenType == PHPRegionTypes.PHPDOC_COMMENT || tokenType == PHPRegionTypes.PHPDOC_COMMENT_END);
    }

    /**
     * @return the formatted line (without whitespaces) information Note: this
     *         is an O(n) implementation (firstly it looks a bit complicated but
     *         it worth it, the previous version was 3*n on the string's length)
     */
    private IRegion getFormattedLineInformation(IRegion lineInfo,
            String lineText) {
        // start checking from left and right to the center
        int leftNonWhitespaceChar = 0;
        int rightNonWhitespaceChar = lineText.length() - 1;
        final char[] chars = lineText.toCharArray();
        boolean keepSearching = true;

        while (keepSearching) {
            final boolean leftIsWhiteSpace = chars[leftNonWhitespaceChar] == CHAR_SPACE
                    || chars[leftNonWhitespaceChar] == CHAR_TAB;
            final boolean rightIsWhiteSpace = chars[rightNonWhitespaceChar] == CHAR_SPACE
                    || chars[rightNonWhitespaceChar] == CHAR_TAB;
            if (leftIsWhiteSpace) {
                leftNonWhitespaceChar++;
            }
            if (rightIsWhiteSpace) {
                rightNonWhitespaceChar--;
            }
            keepSearching = (leftIsWhiteSpace || rightIsWhiteSpace)
                    && (leftNonWhitespaceChar < rightNonWhitespaceChar);
        }

        // if line is empty then the indexes were switched
        if (leftNonWhitespaceChar > rightNonWhitespaceChar) {
            return new SimpleStructuredRegion(lineInfo.getOffset(), 0);
        }

        // if there are no changes - return the original line information, else
        // build a fixed region
        return leftNonWhitespaceChar == 0
                && rightNonWhitespaceChar == lineText.length() - 1 ? lineInfo
                : new SimpleStructuredRegion(lineInfo.getOffset()
                        + leftNonWhitespaceChar, rightNonWhitespaceChar
                        - leftNonWhitespaceChar + 1);
    }

    private boolean shouldReformat(IStructuredDocument document,
            IRegion lineInfo) {
        final String checkedLineBeginState = FormatterUtils.getPartitionType(
                document, lineInfo.getOffset());
        return ((checkedLineBeginState == PHPPartitionTypes.PHP_DEFAULT)
                || (checkedLineBeginState == PHPPartitionTypes.PHP_MULTI_LINE_COMMENT)
                || (checkedLineBeginState == PHPPartitionTypes.PHP_SINGLE_LINE_COMMENT) || (checkedLineBeginState == PHPPartitionTypes.PHP_DOC));
    }

    protected IIndentationStrategy getIndentationStrategy(char c) {
        if (c == '}') {
            return curlyCloseIndentationStrategy;
        }
        return getDefaultIndentationStrategy();
    }

    private IIndentationStrategy getDefaultIndentationStrategy() {
        return defaultIndentationStrategy;
    }
}
