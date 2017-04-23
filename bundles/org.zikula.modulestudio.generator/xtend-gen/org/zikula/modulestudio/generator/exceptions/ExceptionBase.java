package org.zikula.modulestudio.generator.exceptions;

/**
 * Base exception class used by the generator.
 */
@SuppressWarnings("all")
public class ExceptionBase extends Exception {
  /**
   * Constructor with given message.
   * 
   * @param s The given error message.
   */
  public ExceptionBase(final String s) {
    super(s);
  }
  
  /**
   * Constructor with given exception.
   * 
   * @param s The given error message.
   */
  public ExceptionBase(final Exception e) {
    super(e.getMessage());
  }
  
  /**
   * Constructor without given message.
   */
  public ExceptionBase() {
    super();
  }
}
