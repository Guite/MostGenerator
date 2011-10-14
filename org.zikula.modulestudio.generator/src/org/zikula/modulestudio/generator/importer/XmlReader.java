package org.zikula.modulestudio.generator.importer;

import java.io.File;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

public class XmlReader {

    private final String DTD = "resources/pntables.dtd";
    private final File inputFile;
    private Document document;

    public XmlReader(String fileName) throws Exception {
        if (fileName.isEmpty()) {
            throw new Exception(
                    "Error: invalid filename given. Please provide an xml file.");
        }
        inputFile = new File(fileName);
        readFileContent();
    }

    private void readFileContent() {
        try {
            final DocumentBuilderFactory builderFactory = DocumentBuilderFactory
                    .newInstance();
            // Activate validation against document type definition
            builderFactory.setValidating(true);
            final DocumentBuilder builder = builderFactory.newDocumentBuilder();

            // Set error handler
            // ErrorHandler errorHandler = new DefaultHandler();
            final ErrorHandler errorHandler = new XmlReadErrorHandler();
            builder.setErrorHandler(errorHandler);

            // Parse xml document and generate document object tree
            document = builder.parse(inputFile);
        } catch (final ParserConfigurationException e) {
            System.out.println(e.toString());
        } catch (final SAXException e) {
            System.out.println(e.toString());
        } catch (final IOException e) {
            System.out.println(e.toString());
        }
        /**
         * try { final DOMSource source = new DOMSource(this.document); final
         * StreamResult result = new StreamResult(System.out); final
         * TransformerFactory tf = TransformerFactory.newInstance(); final
         * Transformer transformer = tf.newTransformer(); // pass dtd file for
         * validation transformer.setOutputProperty(OutputKeys.DOCTYPE_SYSTEM,
         * this.DTD); transformer.transform(source, result); } catch (final
         * TransformerConfigurationException e) {
         * System.out.println(e.toString()); } catch (final TransformerException
         * e) { System.out.println(e.toString()); }
         */
    }

    private static class XmlReadErrorHandler implements ErrorHandler {
        @Override
        public void warning(SAXParseException e) throws SAXException {
            System.out.println("Warning: ");
            printInfo(e);
        }

        @Override
        public void error(SAXParseException e) throws SAXException {
            final String skipError1 = "Document root element \"tables\", must match DOCTYPE root \"null\".";
            final String skipError2 = "Document is invalid: no grammar found.";
            if (!e.getMessage().equals(skipError1)
                    && !e.getMessage().equals(skipError2)) {
                System.out.println("Error: ");
                printInfo(e);
            }
        }

        @Override
        public void fatalError(SAXParseException e) throws SAXException {
            System.out.println("Fatal error: ");
            printInfo(e);
        }

        private void printInfo(SAXParseException e) {
            System.out.println("   Public ID: " + e.getPublicId());
            System.out.println("   System ID: " + e.getSystemId());
            System.out.println("   Line number: " + e.getLineNumber());
            System.out.println("   Column number: " + e.getColumnNumber());
            System.out.println("   Message: " + e.getMessage());
        }
    }

    public Document getDocument() {
        return document;
    }
}
