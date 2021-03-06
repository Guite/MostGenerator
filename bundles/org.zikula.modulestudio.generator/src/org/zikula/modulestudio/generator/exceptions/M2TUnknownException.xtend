package org.zikula.modulestudio.generator.exceptions

/**
 * Unknown exception raised during model to text transformations.
 */
class M2TUnknownException extends ExceptionBase {

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
