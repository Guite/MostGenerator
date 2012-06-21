package org.zikula.modulestudio.generator.exceptions

/**
 * Exception raised during model to text transformations when a generator cartridge did not finish successfully.
 */
public class M2TFailedCartridgeIncomplete extends ExceptionBase {

    /**
     * The constructor.
     *
     * @param s The given error message.
     */
    new(String s) {
        super(s)
    }
}
