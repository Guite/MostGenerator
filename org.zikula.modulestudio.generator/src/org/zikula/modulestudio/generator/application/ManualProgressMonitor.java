package org.zikula.modulestudio.generator.application;

import org.eclipse.emf.mwe.core.WorkflowComponent;
import org.eclipse.emf.mwe.core.WorkflowContext;
import org.eclipse.emf.mwe.core.container.CompositeComponent;
import org.eclipse.emf.mwe.core.issues.Issues;
import org.eclipse.emf.mwe.core.monitor.NullProgressMonitor;
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor;
import org.eclipse.emf.mwe.internal.core.ast.parser.Location;

public class ManualProgressMonitor implements WorkflowComponent {

	  private String outputSlot = null;

	  public void setOutputSlot(String outputSlot) {
	    this.outputSlot = outputSlot;
	  }

	  public void invoke(WorkflowContext ctx, ProgressMonitor monitor, Issues issues) {
		  // look if monitor is already there
		  Boolean monitorFound = false;
		  for (String currentSlotName : ctx.getSlotNames()) {
			  if (currentSlotName.equals(outputSlot)) {
				  monitorFound = true;
				  break;
			  }
		  }
		  if (monitorFound == false) {
			  // use the monitor of MWE for our manual generator runs
			  //ctx.set(outputSlot, monitor);

			  // create dummy monitor and assign it to workflow context
			  ctx.set(outputSlot, new NullProgressMonitor());
		  }
	  }

	@Override
	public void checkConfiguration(Issues issues) {
	}

	@Override
	public String getComponentName() {
		return null;
	}

	@Override
	public CompositeComponent getContainer() {
		return null;
	}

	@Override
	public Location getLocation() {
		return null;
	}

	@Override
	public void setContainer(CompositeComponent container) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setLocation(Location location) {
		// TODO Auto-generated method stub
		
	}
}