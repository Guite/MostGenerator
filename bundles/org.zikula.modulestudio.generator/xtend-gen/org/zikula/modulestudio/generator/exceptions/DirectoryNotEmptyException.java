package org.zikula.modulestudio.generator.exceptions;

import org.zikula.modulestudio.generator.exceptions.ExceptionBase;

/**
 * Exception raised during model to text transformations when the target directory is not empty.
 */
@SuppressWarnings("all")
public class DirectoryNotEmptyException extends ExceptionBase {
  /**
   * Constructor with given message.
   * 
   * @param s The given error message.
   */
  public DirectoryNotEmptyException(final String s) {
    super(s);
  }
  
  /**
   * Constructor with given exception.
   * 
   * @param s The given error message.
   */
  public DirectoryNotEmptyException(final Exception e) {
    super(e.getMessage());
  }
  
  /**
   * Constructor without given message.
   */
  public DirectoryNotEmptyException() {
    super();
  }
}
