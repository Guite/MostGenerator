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

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IRegion;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocument;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocumentRegion;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegion;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegionContainer;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.PHPRegionContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.IPhpScriptRegion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.PHPRegionTypes;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.partitioner.PHPPartitionTypes;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.partitioner.PHPStructuredTextPartitioner;

public class FormatterUtils {
    private static PHPStructuredTextPartitioner partitioner = new PHPStructuredTextPartitioner();

    public static String getRegionType(IStructuredDocument document, int offset) {
        try {
            final IStructuredDocumentRegion sdRegion = document
                    .getRegionAtCharacterOffset(offset);
            if (sdRegion == null) {
                return null;
            }

            ITextRegion tRegion = sdRegion.getRegionAtCharacterOffset(offset);
            if (tRegion == null && offset == document.getLength()) {
                offset -= 1;
                tRegion = sdRegion.getRegionAtCharacterOffset(offset);
            }
            // in case the cursor on the beginning of '?>' tag
            // we decrease the offset to get the PhpScriptRegion
            if (tRegion.getType().equals(PHPRegionContext.PHP_CLOSE)) {
                tRegion = sdRegion.getRegionAtCharacterOffset(offset - 1);
            }

            int regionStart = sdRegion.getStartOffset(tRegion);

            // in case of container we have the extract the PhpScriptRegion
            if (tRegion != null && tRegion instanceof ITextRegionContainer) {
                final ITextRegionContainer container = (ITextRegionContainer) tRegion;
                tRegion = container.getRegionAtCharacterOffset(offset);
                regionStart += tRegion.getStart();
            }

            if (tRegion != null && tRegion instanceof IPhpScriptRegion) {
                final IPhpScriptRegion scriptRegion = (IPhpScriptRegion) tRegion;
                final int regionOffset = offset - regionStart;
                final ITextRegion innerRegion = scriptRegion
                        .getPhpToken(regionOffset);
                return innerRegion.getType();
            }
        } catch (final BadLocationException e) {
        }

        return null;
    }

    public static String getPartitionType(IStructuredDocument document,
            int offset, boolean perferOpenPartitions) {
        try {
            final IStructuredDocumentRegion sdRegion = document
                    .getRegionAtCharacterOffset(offset);
            if (sdRegion == null) {
                return null;
            }

            ITextRegion tRegion = sdRegion.getRegionAtCharacterOffset(offset);
            if (tRegion == null && offset == document.getLength()) {
                offset -= 1;
                tRegion = sdRegion.getRegionAtCharacterOffset(offset);
            }
            // in case the cursor on the beginning of '?>' tag
            // we decrease the offset to get the PhpScriptRegion
            if (tRegion.getType().equals(PHPRegionContext.PHP_CLOSE)) {
                tRegion = sdRegion.getRegionAtCharacterOffset(offset - 1);
            }

            int regionStart = sdRegion.getStartOffset(tRegion);

            // in case of container we have the extract the PhpScriptRegion
            if (tRegion != null && tRegion instanceof ITextRegionContainer) {
                final ITextRegionContainer container = (ITextRegionContainer) tRegion;
                tRegion = container.getRegionAtCharacterOffset(offset);
                regionStart += tRegion.getStart();
            }

            if (tRegion != null && tRegion instanceof IPhpScriptRegion) {
                final IPhpScriptRegion scriptRegion = (IPhpScriptRegion) tRegion;
                final int regionOffset = offset - regionStart;
                final ITextRegion innerRegion = scriptRegion
                        .getPhpToken(regionOffset);
                final String partition = scriptRegion
                        .getPartition(regionOffset);
                // check if the offset is in the start of the php token
                // because if so this means we're at PHP_DEFAULT partition type
                if (offset
                        - (sdRegion.getStart() + regionStart + innerRegion
                                .getStart()) == 0) {
                    final String regionType = innerRegion.getType();
                    // except for cases we're inside the fragments of comments
                    if (PHPPartitionTypes.isPHPDocCommentState(regionType)
                            || regionType != PHPRegionTypes.PHPDOC_COMMENT_START) {
                        return partition;
                    }
                    if (PHPPartitionTypes
                            .isPHPMultiLineCommentState(regionType)
                            || regionType != PHPRegionTypes.PHP_COMMENT_START) {
                        return partition;
                    }

                    return PHPPartitionTypes.PHP_DEFAULT;
                }
                return partition;
            }
        } catch (final BadLocationException e) {
        }
        partitioner.connect(document);

        return partitioner.getContentType(offset, perferOpenPartitions);
    }

    public static String getPartitionType(IStructuredDocument document,
            int offset) {
        return getPartitionType(document, offset, false);
    }

    private static StringBuffer helpBuffer = new StringBuffer(50);

    /**
     * Return the blanks at the start of the line.
     */
    public static String getLineBlanks(IStructuredDocument document,
            IRegion lineInfo) throws BadLocationException {
        helpBuffer.setLength(0);
        final int startOffset = lineInfo.getOffset();
        final int length = lineInfo.getLength();
        final char[] line = document.get(startOffset, length).toCharArray();
        for (final char c : line) {
            if (Character.isWhitespace(c)) {
                helpBuffer.append(c);
            }
            else {
                break;
            }
        }
        return helpBuffer.toString();
    }

    /**
     * Returns the previous php structured document. Special cases : 1) previous
     * is null - returns null 2) previous is not PHP region - returns the last
     * region of the last php block
     * 
     * @param currentStructuredDocumentRegion
     */
    public static IStructuredDocumentRegion getLastPhpStructuredDocumentRegion(
            IStructuredDocumentRegion currentStructuredDocumentRegion) {
        assert currentStructuredDocumentRegion != null;

        // get last region
        currentStructuredDocumentRegion = currentStructuredDocumentRegion
                .getPrevious();

        // search for last php block (then returns the last region)
        while (currentStructuredDocumentRegion != null
                && currentStructuredDocumentRegion.getType() != PHPRegionContext.PHP_CONTENT) {
            currentStructuredDocumentRegion = currentStructuredDocumentRegion
                    .getPrevious();
        }

        return currentStructuredDocumentRegion;
    }
}
