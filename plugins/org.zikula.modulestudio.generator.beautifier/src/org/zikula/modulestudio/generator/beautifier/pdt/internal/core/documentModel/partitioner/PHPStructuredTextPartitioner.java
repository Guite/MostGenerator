package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.partitioner;

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
 * Based on package org.eclipse.php.internal.core.documentModel.partitioner;
 * 
 *******************************************************************************/

import org.eclipse.jface.text.IDocumentPartitioner;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.wst.html.core.internal.text.StructuredTextPartitionerForHTML;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.PHPRegionContext;

public class PHPStructuredTextPartitioner extends
        StructuredTextPartitionerForHTML {

    public String getContentType(final int offset,
            final boolean preferOpenPartitions) {
        final ITypedRegion partition = getPartition(offset);
        return partition == null ? null : partition.getType();
    }

    @Override
    public String getPartitionType(final ITextRegion region, final int offset) {
        // if php region
        if (isPhpRegion(region.getType())) {
            return PHPPartitionTypes.PHP_DEFAULT;
        }

        // else do super
        return super.getPartitionType(region, offset);
    }

    /**
     * to be abstract eventually
     */
    @Override
    protected void initLegalContentTypes() {
        super.initLegalContentTypes();

        final int length = fSupportedTypes.length;
        final String[] types = new String[fSupportedTypes.length + 1];

        System.arraycopy(fSupportedTypes, 0, types, 0, length);
        types[length] = PHPPartitionTypes.PHP_DEFAULT;

        fSupportedTypes = types;
    }

    /**
     * @param regionType
     * @return
     */
    private static final boolean isPhpRegion(final String regionType) {
        return regionType == PHPRegionContext.PHP_OPEN
                || regionType == PHPRegionContext.PHP_CLOSE
                || regionType == PHPRegionContext.PHP_CONTENT;
    }

    private final static String[] configuredContentTypes = new String[] {
            PHPPartitionTypes.PHP_DEFAULT,
            PHPPartitionTypes.PHP_SINGLE_LINE_COMMENT,
            PHPPartitionTypes.PHP_MULTI_LINE_COMMENT,
            PHPPartitionTypes.PHP_DOC, PHPPartitionTypes.PHP_QUOTED_STRING };

    public static String[] getConfiguredContentTypes() {
        return configuredContentTypes;
    }

    public static boolean isPHPPartitionType(final String type) {
        for (final String configuredContentType : configuredContentTypes) {
            if (configuredContentType.equals(type)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public IDocumentPartitioner newInstance() {
        return new PHPStructuredTextPartitioner();
    }

    @Override
    public ITypedRegion getPartition(int offset) {

        // in case we are in the end of document
        // we return the partition of last region
        final int docLength = fStructuredDocument.getLength();
        if (offset == docLength && offset > 0) {
            return super.getPartition(offset - 1);
        }
        return super.getPartition(offset);
    }

    @Override
    public ITypedRegion[] computePartitioning(int offset, int length) {
        // workaround for https://bugs.eclipse.org/bugs/show_bug.cgi?id=268930
        ITypedRegion[] result = new ITypedRegion[0];
        try {
            result = super.computePartitioning(offset, length);
        } catch (final NullPointerException e) {
        }
        return result;
    }
}
