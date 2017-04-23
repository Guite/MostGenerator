package org.zikula.modulestudio.generator.exceptions;

import org.zikula.modulestudio.generator.exceptions.ExceptionBase;

/**
 * Exception raised during model to text transformations when a resource could not be found.
 */
@SuppressWarnings("all")
public class M2TFailedGeneratorResourceNotFound extends ExceptionBase {
  /**
   * Constructor with given message.
   * 
   * @param s The given error message.
   */
  public M2TFailedGeneratorResourceNotFound(final String s) {
    super(s);
  }
  
  /**
   * Constructor with given exception.
   * 
   * @param s The given error message.
   */
  public M2TFailedGeneratorResourceNotFound(final Exception e) {
    super(e.getMessage());
  }
  
  /**
   * Constructor without given message.
   */
  public M2TFailedGeneratorResourceNotFound() {
    super();
  }
}
