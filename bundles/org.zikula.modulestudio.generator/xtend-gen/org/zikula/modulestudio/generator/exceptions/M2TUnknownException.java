package org.zikula.modulestudio.generator.exceptions;

import org.zikula.modulestudio.generator.exceptions.ExceptionBase;

/**
 * Unknown exception raised during model to text transformations.
 */
@SuppressWarnings("all")
public class M2TUnknownException extends ExceptionBase {
  /**
   * Constructor with given message.
   * 
   * @param s The given error message.
   */
  public M2TUnknownException(final String s) {
    super(s);
  }
  
  /**
   * Constructor with given exception.
   * 
   * @param s The given error message.
   */
  public M2TUnknownException(final Exception e) {
    super(e.getMessage());
  }
  
  /**
   * Constructor without given message.
   */
  public M2TUnknownException() {
    super();
  }
}
