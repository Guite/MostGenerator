package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.util.text;

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
 * Based on package org.eclipse.php.internal.core.util.text;
 * 
 *******************************************************************************/

import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * @author seva, 2007 A hook to catch System.err and System.out
 */
public class StringOutputStream extends OutputStream {

    protected List<String> strings = new ArrayList<String>();
    protected StringBuffer buffer = new StringBuffer();

    @Override
    public void flush() {
        strings.add(buffer.toString());
        buffer = new StringBuffer();
    }

    @Override
    public void write(byte[] b) {
        final String str = new String(b);
        buffer.append(str);
    }

    @Override
    public void write(byte[] b, int off, int len) {
        final String str = new String(b, off, len);
        buffer.append(str);
    }

    @Override
    public void write(int b) {
        final String str = Integer.toString(b);
        buffer.append(str);
    }

    @Override
    public String toString() {
        return buffer.toString();
    }

    public String getString(int i) {
        return strings.get(i);
    }

    public String[] getStrings() {
        return strings.toArray(new String[strings.size()]);
    }
}
