package org.zikula.modulestudio.generator.exceptions;

/**
 * Base exception class used by the generator.
 */
@SuppressWarnings("all")
public class ExceptionBase extends Exception {
  /**
   * The constructor.
   */
  public ExceptionBase() {
    super();
  }
  
  /**
   * Alternative constructor.
   * 
   * @param s The given error message.
   */
  public ExceptionBase(final String s) {
    super(s);
  }
}
