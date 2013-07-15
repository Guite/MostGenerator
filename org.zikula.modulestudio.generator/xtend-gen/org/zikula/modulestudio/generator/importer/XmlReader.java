package org.zikula.modulestudio.generator.importer;

import java.io.File;
import java.io.IOException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import org.zikula.modulestudio.generator.importer.XmlReadErrorHandler;

/**
 * Xml reader class.
 */
@SuppressWarnings("all")
public class XmlReader {
  /**
   * Handle for the input file.
   */
  private File inputFile;
  
  /**
   * The xml input document.
   */
  public Document document;
  
  /**
   * The constructor.
   * 
   * @param fileName Name of the xml input file.
   * @throws Exception In case something goes wrong.
   */
  public XmlReader(final String fileName) throws Exception {
    boolean _isEmpty = fileName.isEmpty();
    if (_isEmpty) {
      Exception _exception = new Exception(
        "Error: invalid filename given. Please provide an xml file.");
      throw _exception;
    }
    File _file = new File(fileName);
    this.inputFile = _file;
    this.readFileContent();
  }
  
  /**
   * Reads in the file content.
   * 
   * @return Object the {@link Document} instance.
   */
  private Object readFileContent() {
    Object _xtrycatchfinallyexpression = null;
    try {
      Document _xblockexpression = null;
      {
        final DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        builderFactory.setValidating(true);
        final DocumentBuilder builder = builderFactory.newDocumentBuilder();
        XmlReadErrorHandler _xmlReadErrorHandler = new XmlReadErrorHandler();
        final XmlReadErrorHandler errorHandler = _xmlReadErrorHandler;
        builder.setErrorHandler(errorHandler);
        Document _parse = builder.parse(this.inputFile);
        Document _document = this.document = _parse;
        _xblockexpression = (_document);
      }
      _xtrycatchfinallyexpression = _xblockexpression;
    } catch (final Throwable _t) {
      if (_t instanceof ParserConfigurationException) {
        final ParserConfigurationException e = (ParserConfigurationException)_t;
        String _string = e.toString();
        String _println = InputOutput.<String>println(_string);
        _xtrycatchfinallyexpression = _println;
      } else if (_t instanceof SAXException) {
        final SAXException e_1 = (SAXException)_t;
        String _string_1 = e_1.toString();
        String _println_1 = InputOutput.<String>println(_string_1);
        _xtrycatchfinallyexpression = _println_1;
      } else if (_t instanceof IOException) {
        final IOException e_2 = (IOException)_t;
        String _string_2 = e_2.toString();
        String _println_2 = InputOutput.<String>println(_string_2);
        _xtrycatchfinallyexpression = _println_2;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return _xtrycatchfinallyexpression;
  }
}
