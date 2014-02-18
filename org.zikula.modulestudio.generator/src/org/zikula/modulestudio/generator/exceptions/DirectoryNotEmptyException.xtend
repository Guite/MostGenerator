package org.zikula.modulestudio.generator.exceptions

/**
 * Exception raised during model to text transformations when the target directory is not empty.
 */
class DirectoryNotEmptyException extends ExceptionBase {

    /**
     * Constructor with given message.
     *
     * @param s The given error message.
     */
    new(String s) {
        super(s)
    }

    /**
     * Constructor with given exception.
     *
     * @param s The given error message.
     */
    new(Exception e) {
        super(e.message)
    }

    /**
     * Constructor without given message.
     */
    new() {
        super()
    }
}
