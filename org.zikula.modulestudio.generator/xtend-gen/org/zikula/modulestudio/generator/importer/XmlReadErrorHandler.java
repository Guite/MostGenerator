package org.zikula.modulestudio.generator.importer;

import org.eclipse.xtext.xbase.lib.InputOutput;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

/**
 * This class handles read errors during the xml import.
 */
@SuppressWarnings("all")
public class XmlReadErrorHandler implements ErrorHandler {
  /**
   * Handles a warning.
   * 
   * @param e The causing {@link SAXParseException}.
   * @throws SAXException The exception raised by this method.
   */
  @Override
  public void warning(final SAXParseException e) throws SAXException {
    InputOutput.<String>println("Warning: ");
    this.printInfo(e);
  }
  
  /**
   * Handles an error.
   * 
   * @param e The causing {@link SAXParseException}.
   * @throws SAXException The exception raised by this method.
   */
  @Override
  public void error(final SAXParseException e) throws SAXException {
    final String skipError1 = "Document root element \"tables\", must match DOCTYPE root \"null\".";
    final String skipError2 = "Document is invalid: no grammar found.";
    boolean _and = false;
    String _message = e.getMessage();
    boolean _equals = _message.equals(skipError1);
    boolean _not = (!_equals);
    if (!_not) {
      _and = false;
    } else {
      String _message_1 = e.getMessage();
      boolean _equals_1 = _message_1.equals(skipError2);
      boolean _not_1 = (!_equals_1);
      _and = (_not && _not_1);
    }
    if (_and) {
      InputOutput.<String>println("Error: ");
      this.printInfo(e);
    }
  }
  
  /**
   * Handles a fatal error.
   * 
   * @param e The causing {@link SAXParseException}.
   * @throws SAXException The exception raised by this method.
   */
  @Override
  public void fatalError(final SAXParseException e) throws SAXException {
    InputOutput.<String>println("Fatal error: ");
    this.printInfo(e);
  }
  
  /**
   * Prints information about a given {@link SAXParseException}.
   * 
   * @param e The causing {@link SAXParseException}.
   * @return String The information about this exception.
   */
  private String printInfo(final SAXParseException e) {
    String _xblockexpression = null;
    {
      String _publicId = e.getPublicId();
      String _plus = ("   Public ID: " + _publicId);
      InputOutput.<String>println(_plus);
      String _systemId = e.getSystemId();
      String _plus_1 = ("   System ID: " + _systemId);
      InputOutput.<String>println(_plus_1);
      int _lineNumber = e.getLineNumber();
      String _plus_2 = ("   Line number: " + Integer.valueOf(_lineNumber));
      InputOutput.<String>println(_plus_2);
      int _columnNumber = e.getColumnNumber();
      String _plus_3 = ("   Column number: " + Integer.valueOf(_columnNumber));
      InputOutput.<String>println(_plus_3);
      String _message = e.getMessage();
      String _plus_4 = ("   Message: " + _message);
      String _println = InputOutput.<String>println(_plus_4);
      _xblockexpression = (_println);
    }
    return _xblockexpression;
  }
}
