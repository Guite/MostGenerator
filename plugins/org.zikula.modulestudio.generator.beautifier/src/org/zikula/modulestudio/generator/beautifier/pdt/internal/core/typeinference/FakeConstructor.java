package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference;

import org.eclipse.dltk.core.IMethod;
import org.eclipse.dltk.core.ISourceRange;
import org.eclipse.dltk.core.IType;
import org.eclipse.dltk.core.ITypeHierarchy;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.internal.core.ModelElement;
import org.zikula.modulestudio.generator.beautifier.pdt.core.compiler.PHPFlags;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPCorePlugin;

public class FakeConstructor extends FakeMethod {
    /**
     * the code assist if happens in the class itself for example class Foo{
     * function Foo($name){} function clone(){return new Foo("foo")} }
     */
    private boolean isEnclosingClass;

    public FakeConstructor(ModelElement parent, String name, int offset,
            int length, int nameOffset, int nameLength, boolean isEnclosingClass) {
        super(parent, name, offset, length, nameOffset, nameLength);
        this.isEnclosingClass = isEnclosingClass;
    }

    @Override
    public boolean isConstructor() throws ModelException {
        return true;
    }

    public boolean isEnclosingClass() {
        return isEnclosingClass;
    }

    public void setEnclosingClass(boolean isEnclosingClass) {
        this.isEnclosingClass = isEnclosingClass;
    }

    public static FakeConstructor createFakeConstructor(IMethod ctor,
            IType type, boolean isEnclosingClass) {
        ISourceRange sourceRange;
        try {
            sourceRange = type.getSourceRange();
            final FakeConstructor ctorMethod = new FakeConstructor(
                    (ModelElement) type, type.getElementName(),
                    sourceRange.getOffset(), sourceRange.getLength(),
                    sourceRange.getOffset(), sourceRange.getLength(),
                    isEnclosingClass);
            if (ctor != null) {
                ctorMethod.setParameters(ctor.getParameters());
            }

            return ctorMethod;
        } catch (final ModelException e) {
            PHPCorePlugin.log(e);
        }
        return null;
    }

    /**
     * 
     * @param type
     * @param isEnclosingClass
     * @return IMethod[] constructors[0] is the type's constructor
     *         constructors[1] is an available FakeConstructor for
     *         constructors[0] both constructors[0] and constructors[1] could be
     *         null
     */
    public static IMethod[] getConstructors(IType type, boolean isEnclosingClass) {
        IMethod[] constructors = new IMethod[2];
        try {
            constructors = getConstructorsOfType(type, isEnclosingClass);

            // try to find constructor in super classes
            if (constructors[0] == null) {
                final ITypeHierarchy newSupertypeHierarchy = type
                        .newSupertypeHierarchy(null);
                final IType[] allSuperclasses = newSupertypeHierarchy
                        .getAllSuperclasses(type);
                if (allSuperclasses != null && allSuperclasses.length > 0) {
                    for (final IType superClass : allSuperclasses) {
                        if (constructors[0] == null) {
                            constructors = getConstructorsOfType(superClass,
                                    isEnclosingClass);
                        }
                        else {
                            break;
                        }
                    }
                }
            }

        } catch (final ModelException e) {
            PHPCorePlugin.log(e);
        }
        return constructors;
    }

    private static IMethod[] getConstructorsOfType(IType type,
            boolean isEnclosingClass) throws ModelException {
        final IMethod[] constructors = new IMethod[2];
        final IMethod[] methods = type.getMethods();
        if (methods != null && methods.length > 0) {
            for (final IMethod method : methods) {
                if (method.isConstructor() && method.getParameters() != null
                        && method.getParameters().length > 0) {
                    constructors[0] = method;
                    if (isEnclosingClass
                            || !PHPFlags.isPrivate(constructors[0].getFlags())) {
                        constructors[1] = FakeConstructor
                                .createFakeConstructor(constructors[0], type,
                                        isEnclosingClass);
                    }
                }
            }
        }
        return constructors;
    }
}
