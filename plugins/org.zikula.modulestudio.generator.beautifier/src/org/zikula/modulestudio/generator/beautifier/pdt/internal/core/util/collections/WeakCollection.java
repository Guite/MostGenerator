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

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.util.WeakObject;

/**
 * 
 * @author erez
 * @version
 */
public class WeakCollection implements Collection {

    private final Collection refrencedCollection;

    /**
     * Creates new WeakCollection
     */
    public WeakCollection(int capacity) {
        refrencedCollection = new ArrayList(capacity);
    }

    public WeakCollection() {
        refrencedCollection = new ArrayList();
    }

    /**
     * Returns the number of referenced elements in this collection. If this
     * collection contains more than <tt>Integer.MAX_VALUE</tt> elements,
     * returns <tt>Integer.MAX_VALUE</tt>.
     * 
     * @return the number of referenced elements in this collection
     */
    @Override
    public int size() {
        removeUnReferencedObjects();
        return refrencedCollection.size();
    }

    /**
     * Returns <tt>true</tt> if this collection contains no elements.
     * 
     * @return <tt>true</tt> if this collection contains no elements
     */
    @Override
    public boolean isEmpty() {
        removeUnReferencedObjects();
        return refrencedCollection.isEmpty();
    }

    /**
     * Returns <tt>true</tt> if this collection contains the specified element.
     * More formally, returns <tt>true</tt> if and only if this collection
     * contains at least one element <tt>e</tt> such that
     * <tt>(o==null ? e==null : o.equals(e))</tt>.
     * 
     * @param o
     *            element whose presence in this collection is to be tested.
     * @return <tt>true</tt> if this collection contains the specified element
     */
    @Override
    public boolean contains(Object o) {
        return refrencedCollection.contains(new WeakObject(o));
    }

    @Override
    public Iterator iterator() {
        return new WeakIterator();
    }

    @Override
    public Object[] toArray() {
        return toArray(null);
    }

    @Override
    public Object[] toArray(Object[] a) {
        removeUnReferencedObjects();
        final Object[] objects = refrencedCollection.toArray();
        if (a == null || a.length < objects.length) {
            a = new Object[objects.length];
        }
        for (int i = 0; i < objects.length; i++) {
            a[i] = (((WeakObject) objects[i]).get());
        }
        return a;
    }

    @Override
    public boolean add(Object o) {
        final WeakObject weakObject = new WeakObject(o);
        return refrencedCollection.add(weakObject);
    }

    @Override
    public boolean remove(Object o) {
        final WeakObject weakObject = new WeakObject(o);
        return refrencedCollection.remove(weakObject);
    }

    /**
     * Returns <tt>true</tt> if this collection contains all of the elements in
     * the specified collection.
     * 
     * @param c
     *            collection to be checked for containment in this collection.
     * @return <tt>true</tt> if this collection contains all of the elements in
     *         the specified collection
     * @see #contains(Object)
     */
    @Override
    public boolean containsAll(Collection c) {
        boolean containsAll = true;
        if (c instanceof WeakCollection) {
            containsAll = refrencedCollection
                    .containsAll(((WeakCollection) c).refrencedCollection);
        }
        else {
            final Iterator it = c.iterator();
            while (it.hasNext()) {
                if (!contains(it.next())) {
                    containsAll = false;
                }
            }
        }
        return containsAll;
    }

    @Override
    public boolean addAll(Collection c) {
        boolean modified = false;
        if (c instanceof WeakCollection) {
            modified = refrencedCollection
                    .addAll(((WeakCollection) c).refrencedCollection);
        }
        else {
            final Iterator it = c.iterator();
            while (it.hasNext()) {
                if (add(it.next())) {
                    modified = true;
                }
            }
        }
        return modified;
    }

    @Override
    public boolean removeAll(Collection c) {
        boolean modified = false;
        if (c instanceof WeakCollection) {
            modified = refrencedCollection
                    .removeAll(((WeakCollection) c).refrencedCollection);
        }
        else {
            final Iterator it = c.iterator();
            while (it.hasNext()) {
                if (remove(it.next())) {
                    modified = true;
                }
            }
        }
        return modified;
    }

    /**
     * Retains only the elements in this collection that are contained in the
     * specified collection (optional operation). In other words, removes from
     * this collection all of its elements that are not contained in the
     * specified collection.
     * 
     * @param c
     *            elements to be retained in this collection.
     * @return <tt>true</tt> if this collection changed as a result of the call
     * 
     * @throws UnsupportedOperationException
     *             if the <tt>retainAll</tt> method is not supported by this
     *             Collection.
     * 
     * @see #remove(Object)
     * @see #contains(Object)
     */
    @Override
    public boolean retainAll(Collection c) {
        boolean modified = false;
        if (c instanceof WeakCollection) {
            modified = refrencedCollection
                    .retainAll(((WeakCollection) c).refrencedCollection);
        }
        else {
            final Iterator it = iterator();
            while (it.hasNext()) {
                final Object o = it.next();
                if (!c.contains(o)) {
                    modified = remove(o);
                }
            }
        }
        return modified;
    }

    @Override
    public void clear() {
        refrencedCollection.clear();
    }

    @Override
    public boolean equals(Object o) {
        boolean isEqual = false;
        if (o instanceof WeakCollection) {
            if (refrencedCollection
                    .equals(((WeakCollection) o).refrencedCollection)) {
                isEqual = true;
            }
        }
        return isEqual;
    }

    @Override
    public int hashCode() {
        return refrencedCollection.hashCode();
    }

    /**
     * Removes all unreferenced objects in the collection simply by using the
     * weak iterator that while iterating the collection removes the
     * unreferenced objects.
     */
    protected void removeUnReferencedObjects() {
        final Iterator weakIterator = iterator();
        while (weakIterator.hasNext()) {
            weakIterator.next();
        }
    }

    /**
     * This class provides an implementation for the iterator interface. The
     * class returns only those objects that are still valid (were not collected
     * by the Garbage collector).
     */
    private class WeakIterator implements Iterator {

        private final Iterator referencedIterator;
        private Object nextObject = null;

        public WeakIterator() {
            referencedIterator = WeakCollection.this.refrencedCollection
                    .iterator();
        }

        /**
         * We can't delegate to the hasNext() method of referencedIterator
         * because there is a possibility that all of the remaining objects in
         * it are garbage collected. Instead we're checking the next returnable
         * object that will be returned in the next next() method.
         */
        @Override
        public boolean hasNext() {
            nextObject = nextImpl();
            return nextObject != null;
        }

        /**
         * We check that nextObject is non null in case there is a next() call
         * after a next() call without hasNext() in between.
         */
        @Override
        public Object next() {
            if (nextObject == null) {
                nextObject = nextImpl();
            }
            final Object rv = nextObject;
            nextObject = null;
            return rv;
        }

        @Override
        public void remove() {
            referencedIterator.remove();
        }

        /**
         * This method gets the next non null object from the referenced
         * collection.
         */
        private Object nextImpl() {
            Object referant;
            while (referencedIterator.hasNext()) {
                referant = ((WeakObject) referencedIterator.next()).get();
                if (referant != null) {
                    return referant;
                }
                referencedIterator.remove();
            }
            return null;
        }

    }

}
