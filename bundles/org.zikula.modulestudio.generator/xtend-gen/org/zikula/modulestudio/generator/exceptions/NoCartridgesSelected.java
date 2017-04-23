package org.zikula.modulestudio.generator.exceptions;

import org.zikula.modulestudio.generator.exceptions.ExceptionBase;

/**
 * Exception raised when no cartridges have been selected.
 */
@SuppressWarnings("all")
public class NoCartridgesSelected extends ExceptionBase {
  /**
   * Constructor with given message.
   * 
   * @param s The given error message.
   */
  public NoCartridgesSelected(final String s) {
    super(s);
  }
  
  /**
   * Constructor with given exception.
   * 
   * @param s The given error message.
   */
  public NoCartridgesSelected(final Exception e) {
    super(e.getMessage());
  }
  
  /**
   * Constructor without given message.
   */
  public NoCartridgesSelected() {
    super();
  }
}
