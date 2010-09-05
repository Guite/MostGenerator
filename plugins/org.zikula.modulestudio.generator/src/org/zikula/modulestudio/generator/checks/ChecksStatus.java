package org.zikula.modulestudio.generator.checks;

import java.util.Set;

import org.eclipse.core.runtime.Status;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.validation.model.IConstraintStatus;
import org.eclipse.emf.validation.model.IModelConstraint;

public class ChecksStatus extends Status implements IConstraintStatus {

    private final EObject target;

    public ChecksStatus(EObject target, int severity, String pluginId, int code,
            String message, Throwable exception) {
        super(severity, pluginId, code, message, exception);
        this.target = target;
    }

    public ChecksStatus(EObject target, int severity, String pluginId,
            String message, Throwable exception) {
        super(severity, pluginId, message, exception);
        this.target = target;
    }

    public ChecksStatus(EObject target, int severity, String pluginId,
            String message) {
        super(severity, pluginId, message);
        this.target = target;
    }

    @Override
    public IModelConstraint getConstraint() {
        return null;
    }

    @Override
    public Set<EObject> getResultLocus() {
        return null;
    }

    @Override
    public EObject getTarget() {
        return target;
    }
}
