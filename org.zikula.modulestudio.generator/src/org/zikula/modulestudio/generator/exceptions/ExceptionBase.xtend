package org.zikula.modulestudio.generator.exceptions

/**
 * Base exception class used by the generator.
 */
class ExceptionBase extends Exception {

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
