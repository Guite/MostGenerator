package org.zikula.modulestudio.generator.importer

import org.xml.sax.ErrorHandler
import org.xml.sax.SAXException
import org.xml.sax.SAXParseException

/**
 * This class handles read errors during the xml import.
 */
class XmlReadErrorHandler implements ErrorHandler {

    /**
     * Handles a warning.
     *
     * @param e The causing {@link SAXParseException}.
     * @throws SAXException The exception raised by this method.
     */
    @Override
    override warning(SAXParseException e) throws SAXException {
        println('Warning: ')
        printInfo(e)
    }

    /**
     * Handles an error.
     *
     * @param e The causing {@link SAXParseException}.
     * @throws SAXException The exception raised by this method.
     */
    @Override
    override error(SAXParseException e) throws SAXException {
        val skipError1 = 'Document root element "tables", must match DOCTYPE root "null".'
        val skipError2 = 'Document is invalid: no grammar found.'
        if (!e.message.equals(skipError1) && !e.message.equals(skipError2)) {
            println('Error: ')
            printInfo(e)
        }
    }

    /**
     * Handles a fatal error.
     *
     * @param e The causing {@link SAXParseException}.
     * @throws SAXException The exception raised by this method.
     */
    @Override
    override fatalError(SAXParseException e) throws SAXException {
        println('Fatal error: ')
        printInfo(e)
    }

    /**
     * Prints information about a given {@link SAXParseException}.
     *
     * @param e The causing {@link SAXParseException}.
     * @return String The information about this exception.
     */
    def private printInfo(SAXParseException e) {
        println('   Public ID: ' + e.publicId)
        println('   System ID: ' + e.systemId)
        println('   Line number: ' + e.lineNumber)
        println('   Column number: ' + e.columnNumber)
        println('   Message: ' + e.message)
    }
}
