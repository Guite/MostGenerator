package org.zikula.modulestudio.generator.exceptions

/**
 * Exception raised when no cartridges have been selected.
 */
class NoCartridgesSelected extends ExceptionBase {

    /**
     * Constructor with given message.
     *
     * @param s The given error message.
     */
    new(String s) {
        super(s)
    }

    /**
     * Constructor without given message.
     */
    new() {
        super()
    }
}
