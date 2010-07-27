package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.util.collections;

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
 * Based on package org.eclipse.php.internal.core.util.collections;
 * 
 *******************************************************************************/

public class IntList implements Cloneable {

    private final int minimumSize;
    private int[] data;
    private int size;

    /**
     * Construct a new IntList with default size of 5.
     */
    public IntList() {
        this(5);
    }

    /**
     * Construct a new IntList.
     * 
     * @param size
     *            The initial size of the list.
     */
    public IntList(int size) {
        data = new int[size];
        minimumSize = size;
        this.size = -1;
    }

    /**
     * Construct a new IntList.
     * 
     * @param data
     *            The initial values of the list.
     */
    public IntList(int[] data) {
        this.data = data;
        minimumSize = data.length;
        this.size = data.length;
    }

    /**
     * Return if the list is empty.
     */
    public boolean isEmpty() {
        return size == -1;
    }

    /**
     * Returns the last value in the list.
     */
    public int top() {
        try {
            return data[size];
        } catch (final RuntimeException exc) {
            throw exc;
        }
    }

    /**
     * Remove and Return the last value in the list.
     */
    public int popStack() {
        final int result = data[size];
        size--;
        reductListSize();
        return result;
    }

    /**
     * Remove and Return the last value in the list.
     */
    public int remove(int index) {
        if (index < 0 || index > size) {
            throw new IndexOutOfBoundsException(
                    "index must be at range 0.." + size + ". got index " + index); //$NON-NLS-1$ //$NON-NLS-2$
        }
        final int result = data[index];
        for (int i = index; i < size; i++) {
            data[i] = data[i + 1];
        }
        size--;
        reductListSize();
        return result;
    }

    /**
     * Add a new value to the end of the list.
     */
    public void pushStack(int val) {
        size++;
        verifySizeBeforeAdding();
        data[size] = val;
    }

    /**
     * Add a new value to the list in a specific indexend.
     */
    public void add(int index, int val) {
        if (index < 0 || index > size) {
            throw new IndexOutOfBoundsException(
                    "index must be at range 0.." + size + ". got index " + index); //$NON-NLS-1$ //$NON-NLS-2$
        }
        size++;
        verifySizeBeforeAdding();
        for (int i = size; i > index; i--) {
            data[i] = data[i - 1];
        }
        data[index] = val;
    }

    /**
     * Add a new value to the end of the list.
     */
    public void add(int val) {
        pushStack(val);
    }

    /**
     * return the item in the 'index' position
     * 
     * @throws IndexOutOfBoundsException
     */
    public int get(int index) {
        if (index < 0 || index > size) {
            throw new IndexOutOfBoundsException(
                    "index must be at range 0.." + size + ". got index " + index); //$NON-NLS-1$ //$NON-NLS-2$
        }
        return this.data[index];
    }

    /**
     * deletes all the calues from the list.
     */
    public int clear() {
        return size = -1;
    }

    /**
     * return the size of the l;is
     */
    public int size() {
        return size + 1;
    }

    /**
     * Return if the specific Object equals to this list
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || !(obj instanceof IntList)) {
            return false;
        }
        final IntList s2 = (IntList) obj;
        if (this.size != s2.size) {
            return false;
        }
        for (int i = size; i >= 0; i--) {
            if (this.data[i] != s2.data[i]) {
                return false;
            }
        }
        return true;
    }

    // multiply list size if necessary.
    private void verifySizeBeforeAdding() {
        final int length = data.length;
        if (size == data.length) {
            final int[] temp = new int[length * 2];
            System.arraycopy(data, 0, temp, 0, length);
            data = temp;
        }
    }

    // Divide list size if necessary.
    private void reductListSize() {
        if (size / 4 < data.length) {
            final int newSize = Math.max(size / 2, minimumSize);
            final int[] temp = new int[newSize];
            System.arraycopy(data, 0, temp, 0, size + 1);
            data = temp;
        }
    }

    /**
     * Copies all the vlues from the specific list
     */
    public void copyFrom(IntList s) {
        this.size = s.size;
        for (int i = 0; i <= s.size; i++) {
            add(s.data[i]);
        }
    }

    /**
     * return true if the list contaons the 'val'.
     */
    public boolean contains(int val) {
        for (int i = 0; i <= size; i++) {
            if (data[i] == val) {
                return true;
            }
        }
        return false;
    }

    /**
     * Return a string representation of the list.
     */
    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer(50);
        for (int i = 0; i <= size; i++) {
            sb.append(" stack[" + i + "]= " + data[i]); //$NON-NLS-1$ //$NON-NLS-2$
        }
        return sb.toString();
    }

    /**
     * Returns a shallow copy of this list.
     */
    @Override
    public Object clone() {
        final IntList rv = new IntList(this.size());
        rv.copyFrom(this);
        return rv;
    }

    /**
     * Returns an araay of all the objects that in the list
     */
    public int[] toIntArray() {
        final int rv[] = new int[size()];
        return toIntArray(rv);
    }

    /**
     * Copy all the objects from the list to the specific array.
     */
    public int[] toIntArray(int array[]) {
        for (int i = 0; i <= this.size; i++) {
            array[i] = this.data[i];
        }
        return array;
    }

    public static class Iterator {
        int lastIndex = -1;
    }

    public static Iterator createIterator() {
        return new Iterator();
    }

    public void startIterating(Iterator i) {
        i.lastIndex = size;
    }

    public boolean hasNext(Iterator i) {
        return i.lastIndex != -1;
    }

    public int next(Iterator i) {
        return data[i.lastIndex--];
    }

    @Override
    public int hashCode() {
        // TODO Auto-generated method stub
        return super.hashCode();
    }

}
