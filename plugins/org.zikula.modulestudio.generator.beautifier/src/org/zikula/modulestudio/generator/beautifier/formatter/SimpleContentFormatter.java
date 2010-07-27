package org.zikula.modulestudio.generator.beautifier.formatter;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Stack;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.formatter.IContentFormatter;
import org.eclipse.jface.text.formatter.IFormattingStrategy;
import org.eclipse.ui.editors.text.EditorsUI;
import org.eclipse.ui.preferences.ScopedPreferenceStore;
import org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants;
import org.eclipse.wst.sse.core.StructuredModelManager;
import org.eclipse.wst.sse.core.internal.provisional.IModelManager;
import org.eclipse.wst.sse.core.internal.provisional.IStructuredModel;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocument;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocumentRegion;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegion;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.GeneratorFileUtil;
import org.zikula.modulestudio.generator.beautifier.formatter.preferences.PreferenceConstants;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.PHPRegionContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.PhpScriptRegion;

/**
 * Based on http://de.sourceforge.jp/projects/pdt-tools/
 */
public class SimpleContentFormatter implements IContentFormatter {

    private IDocument document;
    private String lineDelimiter;
    private String indentChar;
    private int baseIndentLevel;
    private int lineLengthLimit;
    private int tabSize;

    private int offset;
    private ITextRegion[] regions;
    private int index;

    private OutputBuffer outbuf;
    private Stack<ScopeUnit> scope;
    private int indentLevel;
    private int postIndent;
    private boolean reqPreNewLine;
    private boolean reqPostNewLine;
    private boolean reqNewLineImmediately;
    private boolean reqPreSpace;
    private boolean reqPostSpace;
    private boolean reqOpenBlock;
    private boolean reqOpenBlockNL;
    private boolean indentedInArray;
    private boolean indentedInConcat;
    private int indentedForArrow;

    private boolean prefNewLineForClass;
    private boolean prefNewLineForFunction;
    private boolean prefNewLineForTryCatch;
    private boolean prefNewLineForCatch;
    private boolean prefNewLineForElse;
    private boolean prefNewLineForBlock;
    private boolean prefIndentCaseBlock;
    private boolean prefSpacerForConcat;
    private boolean prefSpacerForArrayArrow;
    private boolean prefSpacerForFunctionDef;
    private boolean prefSpacerForComment;
    private boolean prefSpacerForShortcut;
    private boolean prefSpacerForShortcutClose;
    private boolean prefSpacerForCast;
    private boolean prefLeaveBlankLines1;
    private boolean prefShrinkBlankLines1;
    private boolean prefLeaveBlankLines2;
    private boolean prefShrinkBlankLines2;
    private boolean prefLeaveBlankLines3;
    private boolean prefShrinkBlankLines3;
    private boolean prefLeaveNewLineInArray;
    private boolean prefLeaveNewLineAfterComma;
    private boolean prefLeaveNewLineWithConcatOp;
    private boolean prefLeaveNewLineForArrow;
    private boolean prefLeaveNewLineForArrowNest;
    private boolean prefJoinConcatOpToPrevLine;
    private boolean prefJoinConcatOpToPostLine;
    private boolean prefAlignDoubleArrow;
    private boolean prefAlignDoubleArrowWithTab;
    private boolean prefEquateEleIfToElseif;
    private boolean prefSimpleStatementInOneLine;
    private boolean prefCompactEmptyBlock;

    private final boolean debugDump = false;

    private File inputFile;
    private IFile currentFile;

    public void format(File file) {
        inputFile = file;
        GeneratorFileUtil.applyFormatterOnSingleFileInEditor(file, this);
    }

    @SuppressWarnings("deprecation")
    private IStructuredModel buildStructuredModel(IDocument document)
            throws Exception {
        /*
         * if (GeneratorFileUtil.isIndebugMode) {
         * System.out.println("Current file: " + currentFile.getFullPath() +
         * ", " + ((currentFile.exists()) ? "existing" : "not existing")); }
         */
        final IModelManager modelManager = StructuredModelManager
                .getModelManager();

        IStructuredModel model = modelManager.getExistingModelForEdit(document);
        if (model == null) {
            model = modelManager.getModelForEdit(currentFile);
        }
        if (model == null) {
            model = modelManager.getModelForEdit(inputFile.getPath(),
                    new FileInputStream(inputFile), null);
        }
        return model;
    }

    @Override
    public void format(IDocument document, IRegion region) {
        IStructuredModel structuredModel = null;
        try {
            structuredModel = buildStructuredModel(document);
            if (structuredModel == null) {
                GeneratorBeautifierPlugin.logMessage(IStatus.WARNING,
                        "Skipped file because of missing structural model");
                return;
            }

            final IPreferenceStore pref = new ScopedPreferenceStore(
                    new InstanceScope(), GeneratorBeautifierPlugin.PLUGIN_ID);

            final IStructuredDocument doc = structuredModel
                    .getStructuredDocument();
            final Integer oldLength = doc.getLength();

            format(doc, region, pref);

            // System.out.println("Length changed from " + oldLength + " to "
            // + doc.getLength());

            if (!structuredModel.isSharedForEdit()
                    && structuredModel.isSaveNeeded()) {
                try {
                    structuredModel.save(currentFile);
                } catch (final UnsupportedEncodingException e) {
                    if (GeneratorFileUtil.isIndebugMode) {
                        System.out.println("Error 34211");
                    }
                    GeneratorBeautifierPlugin.log(e);
                } catch (final IOException e) {
                    if (GeneratorFileUtil.isIndebugMode) {
                        System.out.println("Error 34212");
                    }
                    GeneratorBeautifierPlugin.log(e);
                } catch (final CoreException e) {
                    if (GeneratorFileUtil.isIndebugMode) {
                        System.out.println("Error 34213");
                    }
                    GeneratorBeautifierPlugin.log(e);
                }
            }
        } catch (final IOException e) {
            if (GeneratorFileUtil.isIndebugMode) {
                System.out.println("Error 34214");
            }
            GeneratorBeautifierPlugin.log(e);
        } catch (final CoreException e) {
            if (GeneratorFileUtil.isIndebugMode) {
                System.out.println("Error 34215");
            }
            GeneratorBeautifierPlugin.log(e);
        } catch (final Exception e) {
            if (GeneratorFileUtil.isIndebugMode) {
                System.out.println("Error 34216");
            }
            // GeneratorBeautifierPlugin.log(e);
            e.printStackTrace();
        } finally {
            if (structuredModel != null) {
                structuredModel.releaseFromEdit();
            }
        }
    }

    public void format(IDocument document, IRegion region, IPreferenceStore pref) {
        if (!(document instanceof IStructuredDocument)) {
            GeneratorBeautifierPlugin.logMessage(IStatus.WARNING,
                    "Not supported");
            return;
        }

        this.document = document;
        final IStructuredDocument doc = (IStructuredDocument) document;
        lineDelimiter = doc.getLineDelimiter();
        if (pref.getBoolean(PreferenceConstants.INDENT_WITH_TAB)) {
            indentChar = "\t";
        }
        else {
            final int c = pref.getInt(PreferenceConstants.INDENT_SPACES);
            final char[] sp = new char[c];
            Arrays.fill(sp, ' ');
            indentChar = new String(sp);
        }
        baseIndentLevel = pref.getInt(PreferenceConstants.INDENT_BASE);
        lineLengthLimit = pref.getInt(PreferenceConstants.LINE_LENGTH);
        tabSize = EditorsUI
                .getPreferenceStore()
                .getInt(AbstractDecoratedTextEditorPreferenceConstants.EDITOR_TAB_WIDTH);
        scope = new Stack<ScopeUnit>();
        scope.push(new ScopeUnit(0));
        indentLevel = 0;
        postIndent = 0;
        reqPreNewLine = false;
        reqPostNewLine = false;
        reqNewLineImmediately = false;
        reqPreSpace = false;
        reqPostSpace = false;
        reqOpenBlock = false;
        reqOpenBlockNL = false;
        indentedInArray = false;
        indentedForArrow = 0;

        prefNewLineForClass = pref
                .getBoolean(PreferenceConstants.NEW_LINE_FOR_CLASS);
        prefNewLineForFunction = pref
                .getBoolean(PreferenceConstants.NEW_LINE_FOR_FUNCTION);
        prefNewLineForTryCatch = pref
                .getBoolean(PreferenceConstants.NEW_LINE_FOR_TRY_CATCH);
        prefNewLineForCatch = pref
                .getBoolean(PreferenceConstants.NEW_LINE_FOR_CATCH);
        prefNewLineForElse = pref
                .getBoolean(PreferenceConstants.NEW_LINE_FOR_ELSE);
        prefNewLineForBlock = pref
                .getBoolean(PreferenceConstants.NEW_LINE_FOR_BLOCK);
        prefIndentCaseBlock = pref
                .getBoolean(PreferenceConstants.INDENT_CASE_BLOCK);
        prefSpacerForConcat = pref
                .getBoolean(PreferenceConstants.SPACER_FOR_CONCAT);
        prefSpacerForArrayArrow = pref
                .getBoolean(PreferenceConstants.SPACER_FOR_ARRAY_ARROW);
        prefSpacerForFunctionDef = pref
                .getBoolean(PreferenceConstants.SPACER_FOR_FUNCTION_DEF);
        prefSpacerForComment = pref
                .getBoolean(PreferenceConstants.SPACER_FOR_COMMENT);
        prefSpacerForShortcut = pref
                .getBoolean(PreferenceConstants.SPACER_FOR_SHORTCUT);
        prefSpacerForShortcutClose = pref
                .getBoolean(PreferenceConstants.SPACER_FOR_SHORTCUT_CLOSE);
        prefSpacerForCast = pref
                .getBoolean(PreferenceConstants.SPACER_FOR_CAST);
        prefLeaveBlankLines1 = pref
                .getBoolean(PreferenceConstants.LEAVE_BLANK_LINES1);
        prefShrinkBlankLines1 = pref
                .getBoolean(PreferenceConstants.SHRINK_BLANK_LINES1);
        prefLeaveBlankLines2 = pref
                .getBoolean(PreferenceConstants.LEAVE_BLANK_LINES2);
        prefShrinkBlankLines2 = pref
                .getBoolean(PreferenceConstants.SHRINK_BLANK_LINES2);
        prefLeaveBlankLines3 = pref
                .getBoolean(PreferenceConstants.LEAVE_BLANK_LINES3);
        prefShrinkBlankLines3 = pref
                .getBoolean(PreferenceConstants.SHRINK_BLANK_LINES3);
        prefLeaveNewLineInArray = pref
                .getBoolean(PreferenceConstants.LEAVE_NEWLINE_IN_ARRAY);
        prefLeaveNewLineAfterComma = pref
                .getBoolean(PreferenceConstants.LEAVE_NEWLINE_AFTER_COMMA);
        prefLeaveNewLineWithConcatOp = pref
                .getBoolean(PreferenceConstants.LEAVE_NEWLINE_WITH_CONCAT_OP);
        prefLeaveNewLineForArrow = pref
                .getBoolean(PreferenceConstants.LEAVE_NEWLINE_FOR_ARROW);
        prefLeaveNewLineForArrowNest = pref
                .getBoolean(PreferenceConstants.LEAVE_NEWLINE_FOR_ARROW_NEST);
        prefJoinConcatOpToPrevLine = pref
                .getBoolean(PreferenceConstants.JOIN_CONCAT_OP_TO_PREV_LINE);
        prefJoinConcatOpToPostLine = pref
                .getBoolean(PreferenceConstants.JOIN_CONCAT_OP_TO_POST_LINE);
        prefAlignDoubleArrow = pref
                .getBoolean(PreferenceConstants.ALIGN_DOUBLE_ARROW);
        prefAlignDoubleArrowWithTab = pref
                .getBoolean(PreferenceConstants.ALIGN_DOUBLE_ARROW_WITH_TAB);
        prefEquateEleIfToElseif = pref
                .getBoolean(PreferenceConstants.EQUATE_ELSE_IF_TO_ELSEIF);
        prefSimpleStatementInOneLine = pref
                .getBoolean(PreferenceConstants.SIMPLE_STATEMENT_IN_ONE_LINE);
        prefCompactEmptyBlock = pref
                .getBoolean(PreferenceConstants.COMPACT_EMPTY_BLOCK);

        if (debugDump) {
            System.out.println("Region: " + region.getOffset() + ","
                    + region.getLength());
        }

        final IStructuredDocumentRegion[] regions = doc
                .getStructuredDocumentRegions();
        try {
            for (final IStructuredDocumentRegion region2 : regions) {
                final IStructuredDocumentRegion docRegion = region2;
                // System.out.println("TETE 1");
                if (docRegion.getType().equals(PHPRegionContext.PHP_CONTENT)) {
                    // System.out.println("TETE 2");

                    final String buf = formatPHP(docRegion);
                    final IResource resource = FormatterUtil
                            .getResource(document);
                    if (!FormatterUtil.verify(docRegion.getText(), buf,
                            resource)) {
                        // verify error
                        return;
                    }
                    document.replace(docRegion.getStart(),
                            docRegion.getLength(), buf);
                }
                else {
                    System.out.println("TETE 3" + docRegion.getType());
                }
            }
        } catch (final BadLocationException e) {
            GeneratorBeautifierPlugin.log(e);
        }
    }

    @Override
    public IFormattingStrategy getFormattingStrategy(String contentType) {
        return null;
    }

    @SuppressWarnings("unchecked")
    private String formatPHP(IStructuredDocumentRegion region)
            throws BadLocationException {
        outbuf = new OutputBuffer();
        final int docOffset = region.getStart();
        final Iterator<ITextRegion> it = region.getRegions().iterator();
        while (it.hasNext()) {
            final ITextRegion txtRegion = it.next();
            final String type = txtRegion.getType();
            if (type.equals(PHPRegionContext.PHP_CONTENT)) {
                final PhpScriptRegion phpRegion = (PhpScriptRegion) txtRegion;
                regions = phpRegion.getPhpTokens(0, phpRegion.getLength());
                offset = docOffset + phpRegion.getStart();

                formatCodeBlock();

                // } else if (type.equals(PHPRegionContext.PHP_OPEN)) {
                // outbuf.append(document.get(docOffset + txtRegion.getStart(),
                // txtRegion.getLength()));
                // } else if (type.equals(PHPRegionContext.PHP_CLOSE)) {
                // outbuf.append(document.get(docOffset + txtRegion.getStart(),
                // txtRegion.getLength()));
            }
            else {
                outbuf.append(document.get(docOffset + txtRegion.getStart(),
                        txtRegion.getLength()));
            }
        }
        return outbuf.toString();
    }

    private class OutputBuffer {
        StringBuffer buffer;
        StringBuffer lineBuffer;
        boolean lineWrappingEnabled;

        public OutputBuffer() {
            buffer = new StringBuffer();
            lineBuffer = new StringBuffer();
            lineWrappingEnabled = true;
        }

        public void enableLineWrapping(boolean enabled) {
            lineWrappingEnabled = enabled;
        }

        @Override
        public String toString() {
            return buffer.toString();
        }

        public void append(String str) {
            if (lineLengthLimit > 0) {
                if (str.equals(lineDelimiter)) {
                    lineBuffer.setLength(0);
                }
                else {
                    final int len = lineBuffer.toString().trim().length();
                    lineBuffer.append(str);
                    if (len > 0 && lineWrappingEnabled && !str.equals(" ")
                            && !str.equals(",") && !str.equals("{")
                            && !str.equals(";")) {
                        int i = lineBuffer.indexOf("\t");
                        while (i >= 0) {
                            final int j = i % tabSize;
                            final char[] sp = new char[tabSize - j];
                            Arrays.fill(sp, ' ');
                            lineBuffer.replace(i, i + 1, new String(sp));
                            i = lineBuffer.indexOf("\t");
                        }
                        if (lineBuffer.length() > lineLengthLimit) {
                            lineBuffer.setLength(0);
                            final int alpha = indentedInArray ? 0 : 1;
                            final String indent = indent(indentLevel + alpha,
                                    indentChar);
                            lineBuffer.append(indent);
                            lineBuffer.append(str);
                            buffer.append(lineDelimiter);
                            buffer.append(indent);
                        }
                    }
                }
            }
            buffer.append(str);
        }

        public int length() {
            return buffer.length();
        }

        public char charAt(int index) {
            return buffer.charAt(index);
        }

        public int indexOf(String str) {
            return buffer.indexOf(str);
        }

        public StringBuffer replace(int start, int end, String str) {
            return buffer.replace(start, end, str);
        }
    }

    private class TokenUnit {
        public int type;
        public String body;

        public TokenUnit() {
            type = 0;
            body = "";
        }
    }

    private class ScopeUnit {
        public int type; // token type
        public int count = 0; // paren/brace count
        public boolean fgCond = true; // flag for condition
        public boolean fgSingle = false; // for single if statement
        public boolean fgElse = false; // in else clause
        public boolean fgInterface = false; // in interface
        public boolean fgAbstract = false; // abstract function
        public boolean fgArrayIndent = false; // indent for array
        public boolean fgAligned = false; // already aligned
        public boolean fgBlock = false; // block statement (w/':')
        public int alignMax = 0; // max item length
        public int startIndex = -1; // ( starting index

        public ScopeUnit(int type) {
            this.type = type;
        }
    }

    private String indent(int indent, String indentChar) {
        final StringBuffer buf = new StringBuffer();
        for (int i = 0; i < indent + baseIndentLevel; i++) {
            buf.append(indentChar);
        }
        return buf.toString();
    }

    private int getNextToken(int index, boolean skipSpace, TokenUnit unit)
            throws BadLocationException {
        unit.type = 0;
        unit.body = "";
        boolean inLineComment = false;
        boolean inComment = false;
        boolean inHereDoc = false;
        while (index < regions.length) {
            final ITextRegion region = regions[index];
            final int type = PHPToken.getTokenNumber(region.getType());
            if (inLineComment) {
                if (type != PHPToken.PHP_LINE_COMMENT) {
                    inLineComment = false;
                }
                index++;
                continue;
            }
            if (inComment) {
                if (type == PHPToken.PHP_COMMENT_END) {
                    inComment = false;
                }
                index++;
                continue;
            }
            if (inHereDoc) {
                if (type == PHPToken.PHP_HEREDOC_TAG) {
                    inHereDoc = false;
                }
                index++;
                continue;
            }
            if (type == PHPToken.WHITESPACE && skipSpace) {
                index++;
                continue;
            }
            if (type == PHPToken.PHP_LINE_COMMENT && skipSpace) {
                inLineComment = true;
                index++;
                continue;
            }
            if (type == PHPToken.PHP_COMMENT_START && skipSpace) {
                inComment = true;
                index++;
                continue;
            }
            if (type == PHPToken.PHP_HEREDOC_TAG && skipSpace) {
                inHereDoc = true;
                index++;
                continue;
            }
            unit.type = type;
            unit.body = document.get(offset + region.getStart(),
                    region.getLength());
            break;
        }
        return index;
    }

    private int getNextNonWhiteToken(int index, TokenUnit unit)
            throws BadLocationException {
        unit.type = 0;
        unit.body = "";
        while (index < regions.length) {
            final ITextRegion region = regions[index];
            final int type = PHPToken.getTokenNumber(region.getType());
            if (type == PHPToken.WHITESPACE) {
                index++;
                continue;
            }
            unit.type = type;
            unit.body = document.get(offset + region.getStart(),
                    region.getLength());
            break;
        }
        return index;
    }

    private int getPrevToken(int index, boolean skipSpace, TokenUnit unit)
            throws BadLocationException {
        unit.type = 0;
        unit.body = "";
        boolean inLineComment = false;
        boolean inComment = false;
        boolean inHereDoc = false;
        while (index >= 0) {
            final ITextRegion region = regions[index];
            final int type = PHPToken.getTokenNumber(region.getType());
            if (inLineComment) {
                if (type != PHPToken.PHP_LINE_COMMENT) {
                    inLineComment = false;
                }
                index--;
                continue;
            }
            if (inComment) {
                if (type == PHPToken.PHP_COMMENT_START) {
                    inComment = false;
                }
                index--;
                continue;
            }
            if (inHereDoc) {
                if (type == PHPToken.PHP_HEREDOC_TAG) {
                    inHereDoc = false;
                }
                index--;
                continue;
            }
            if (type == PHPToken.WHITESPACE && skipSpace) {
                index--;
                continue;
            }
            if (type == PHPToken.PHP_LINE_COMMENT && skipSpace) {
                inLineComment = true;
                index--;
                continue;
            }
            if (type == PHPToken.PHP_COMMENT_END && skipSpace) {
                inComment = true;
                index--;
                continue;
            }
            if (type == PHPToken.PHP_HEREDOC_TAG && skipSpace) {
                inHereDoc = true;
                index--;
                continue;
            }
            unit.type = type;
            unit.body = document.get(offset + region.getStart(),
                    region.getLength());
            break;
        }
        return index;
    }

    private TokenUnit getToken() throws BadLocationException {
        final TokenUnit unit = new TokenUnit();
        final ITextRegion region = regions[index++];
        unit.type = PHPToken.getTokenNumber(region.getType());
        unit.body = document
                .get(offset + region.getStart(), region.getLength());
        if (debugDump) {
            System.out.println("token " + region.getStart() + ","
                    + region.getLength() + ": " + region.getType() + " ["
                    + unit.body + "]");
        }
        return unit;
    }

    private boolean isMatched(String str, String[] words) {
        for (final String word : words) {
            if (str.equalsIgnoreCase(word)) {
                return true;
            }
        }
        return false;
    }

    private boolean hasNewLine(String str) {
        return str.contains("\n") || str.contains("\r");
    }

    private boolean hasNewLine() throws BadLocationException {
        final int ix = getNextToken(index, true, new TokenUnit());
        final int currLine = document.getLineOfOffset(offset
                + regions[index - 1].getStart());
        final int nextLine = document.getLineOfOffset(offset
                + regions[ix].getStart());
        return (currLine != nextLine);
    }

    private void outputComments(StringBuffer commentBuffer) {
        final String[] buf = commentBuffer.toString().split(lineDelimiter);
        outbuf.append(buf[0]);
        final String spacerForMultiLineComment = " ";
        for (int i = 1; i < buf.length; i++) {
            int pos = 0;
            while (pos < buf[i].length()) {
                final char c = buf[i].charAt(pos);
                if (c == ' ' || c == '\t') {
                    pos++;
                    continue;
                }
                else if (c == '*') {
                    buf[i] = spacerForMultiLineComment + buf[i].substring(pos);
                    break;
                }
                else {
                    buf[i] = spacerForMultiLineComment + buf[i].substring(pos);
                    break;
                }
            }
            outbuf.append(lineDelimiter);
            outbuf.append(indent(indentLevel, indentChar));
            outbuf.append(buf[i]);
        }
        commentBuffer.setLength(0);
    }

    /**
     * Format PHP Code Block
     * 
     * @throws BadLocationException
     */
    private void formatCodeBlock() throws BadLocationException {

        final StringBuffer commentBuffer = new StringBuffer();
        boolean inComment = false;
        boolean inPHPDocComment = false;
        boolean inLineComment = false;
        boolean inHereDoc = false;
        String terminator = "";

        boolean isShortcut = false;
        boolean inCaseSt = false;
        boolean isReference = false;
        boolean inConstantEncapsedString = false;
        int newLines = 1;
        boolean justAfterOpenTag = true;

        final Stack<TokenUnit> ternaryStack = new Stack<TokenUnit>();

        index = 0;

        while (index < regions.length) {

            final TokenUnit token = getToken();

            final TokenUnit nextToken = new TokenUnit();
            final TokenUnit prevToken = new TokenUnit();

            if (inComment) {
                commentBuffer.append(token.body);
                if (token.type == PHPToken.PHP_COMMENT_END) {
                    inComment = false;
                    outputComments(commentBuffer);
                }
                continue;
            }
            if (inPHPDocComment) {
                commentBuffer.append(token.body);
                if (token.type == PHPToken.PHPDOC_COMMENT_END) {
                    inPHPDocComment = false;
                    outputComments(commentBuffer);
                }
                continue;
            }
            if (inLineComment) {
                if (token.body.endsWith("\n\r") || token.body.endsWith("\r\n")) {
                    token.body = token.body.substring(0,
                            token.body.length() - 2);
                    inLineComment = false;
                }
                else if (token.body.endsWith("\n") || token.body.endsWith("\r")) {
                    token.body = token.body.substring(0,
                            token.body.length() - 1);
                    inLineComment = false;
                }
                outbuf.append(token.body);
                if (!inLineComment) {
                    reqPreNewLine = true;
                    reqPostNewLine = false;
                }
                continue;
            }
            if (inHereDoc) {
                if (reqPreNewLine) {
                    outbuf.append(lineDelimiter);
                    reqPreNewLine = false;
                }
                outbuf.append(token.body);
                if (token.type == PHPToken.PHP_CONSTANT_ENCAPSED_STRING) {
                    final Pattern pattern = Pattern.compile("[\\n\\r]+"
                            + terminator + ";$", Pattern.MULTILINE);
                    final Matcher matcher = pattern.matcher(token.body);
                    if (matcher.find()) {
                        inHereDoc = false;
                        reqPostNewLine = true;
                        final int idx = getNextToken(index, true, nextToken);
                        if (nextToken.type == PHPToken.PHP_CONSTANT_ENCAPSED_STRING) {
                            index = idx + 1;
                        }
                    }
                }
                continue;
            }
            outbuf.enableLineWrapping(true);

            String tokenBody = token.body.trim();

            switch (token.type) {

                case PHPToken.WHITESPACE:
                    getNextToken(index, true, nextToken);
                    if (nextToken.type == PHPToken.PHP_TOKEN
                            && nextToken.body.trim().equals(".")) {
                        if (prefLeaveNewLineWithConcatOp) {
                            break;
                        }
                        continue;
                    }
                    if (hasNewLine(token.body)) {
                        reqPreNewLine = false;
                        reqPostNewLine = true;
                    }
                    else {
                        reqPreSpace = true;
                    }
                    break;

                case PHPToken.PHP_SEMICOLON:
                    switch (scope.peek().type) {
                        case PHPToken.PHP_FOR:
                            if (scope.peek().fgCond) {
                                getNextToken(index, true, nextToken);
                                final String body = nextToken.body.trim();
                                if (!body.equals(";") && !body.equals(")")) {
                                    reqPostSpace = true;
                                }
                                break;
                            }

                            //$FALL-THROUGH$
                        default:
                            reqPostNewLine = true;
                            while (scope.peek().fgSingle) {
                                if (!prefSimpleStatementInOneLine) { // #16894
                                    postIndent--;
                                }
                                boolean terminate = true;
                                if (!scope.peek().fgElse) {
                                    getNextToken(index, true, nextToken);
                                    switch (nextToken.type) {
                                        case PHPToken.PHP_ELSE:
                                        case PHPToken.PHP_ELSEIF:
                                            terminate = false;
                                    }
                                }
                                if (terminate) {
                                    scope.pop();
                                }
                                else {
                                    break;
                                }
                            }
                    }
                    if (indentedForArrow > 0) {
                        indentLevel -= indentedForArrow;
                        indentedForArrow = 0;
                    }
                    break;

                case PHPToken.PHP_CURLY_OPEN:
                    if (scope.peek().type == PHPToken.PHP_VARIABLE) { // #16076
                        break;
                    }
                    if (inConstantEncapsedString) {
                        break; // XXX 2010/04/09
                    }
                    if (scope.peek().type != 0) {
                        scope.peek().count++;
                    }
                    if (reqOpenBlock) {
                        reqOpenBlock = false;
                        indentLevel++;
                        reqPreSpace = true;
                        reqPostNewLine = true;
                        if (scope.peek().type == PHPToken.PHP_SWITCH) {
                            if (prefIndentCaseBlock) {
                                postIndent++;
                            }
                        }
                    }
                    else if (reqOpenBlockNL) {
                        reqOpenBlockNL = false;
                        reqPreNewLine = true;
                        postIndent++;
                        reqPostNewLine = true;
                        if (scope.peek().type == PHPToken.PHP_SWITCH) {
                            if (prefIndentCaseBlock) {
                                postIndent++;
                            }
                        }
                    }
                    else if (!inConstantEncapsedString) {
                        scope.peek().count--;
                        scope.push(new ScopeUnit(PHPToken.NAMELESS_BLOCK));
                        scope.peek().count++;
                        reqPostNewLine = true;
                        postIndent++;
                    }
                    if (prefCompactEmptyBlock) {
                        getNextToken(index, true, nextToken);
                        if (nextToken.type == PHPToken.PHP_CURLY_CLOSE) {
                            reqPostNewLine = false;
                        }
                    }
                    break;

                case PHPToken.PHP_CURLY_CLOSE:
                    if (scope.peek().type == PHPToken.PHP_VARIABLE) { // #16076
                        scope.pop();
                        break;
                    }
                    if (inConstantEncapsedString) {
                        break; // XXX 2010/04/09
                    }
                    if (scope.peek().type != 0) {
                        scope.peek().count--;
                    }
                    if (scope.peek().type != 0 && scope.peek().count == 0) {
                        switch (scope.peek().type) {
                            case PHPToken.PHP_CLASS:
                            case PHPToken.PHP_INTERFACE:
                            case PHPToken.PHP_FUNCTION:
                            case PHPToken.PHP_FOR:
                            case PHPToken.PHP_FOREACH:
                            case PHPToken.PHP_WHILE:
                            case PHPToken.NAMELESS_BLOCK:
                                reqPostNewLine = true;
                                indentLevel--;
                                scope.pop();
                                break;
                            case PHPToken.PHP_TRY:
                                indentLevel--;
                                if (prefNewLineForCatch) {
                                    reqPostNewLine = true;
                                }
                                else {
                                    reqPostSpace = true;
                                }
                                scope.pop();
                                break;
                            case PHPToken.PHP_CATCH:
                                indentLevel--;
                                reqPostNewLine = true;
                                scope.pop();
                                break;
                            case PHPToken.PHP_IF:
                                indentLevel--;
                                boolean terminate = true;
                                if (!scope.peek().fgElse) {
                                    getNextToken(index, true, nextToken);
                                    switch (nextToken.type) {
                                        case PHPToken.PHP_ELSE:
                                        case PHPToken.PHP_ELSEIF:
                                            if (prefNewLineForElse) {
                                                reqPostNewLine = true;
                                            }
                                            else {
                                                reqPostSpace = true;
                                            }
                                            terminate = false;
                                            // XXX 2010/04/09
                                            getNextNonWhiteToken(index,
                                                    nextToken);
                                            switch (nextToken.type) {
                                                case PHPToken.PHP_LINE_COMMENT:
                                                    reqPostNewLine = true;
                                                    break;
                                            }
                                            break;
                                    }
                                }
                                if (terminate) {
                                    scope.pop();
                                    reqPostNewLine = true;
                                }
                                break;
                            case PHPToken.PHP_DO:
                                indentLevel--;
                                reqPostSpace = true;
                                break;
                            case PHPToken.PHP_SWITCH:
                                if (prefIndentCaseBlock) {
                                    indentLevel--;
                                }
                                reqPostNewLine = true;
                                indentLevel--;
                                scope.pop();
                                break;
                        }
                        while (scope.peek().fgSingle) {
                            if (!prefSimpleStatementInOneLine) { // #16894
                                postIndent--;
                            }
                            boolean terminate = true;
                            if (!scope.peek().fgElse) {
                                getNextToken(index, true, nextToken);
                                switch (nextToken.type) {
                                    case PHPToken.PHP_ELSE:
                                    case PHPToken.PHP_ELSEIF:
                                        terminate = false;
                                }
                            }
                            if (terminate) {
                                scope.pop();
                            }
                            else {
                                break;
                            }
                        }
                    }
                    break;

                case PHPToken.PHP_OPERATOR:
                    final String[] operators = { ".=", "+=", "-=", "*=", "/=",
                            "<<=", ">>=", "&&", "||", "==", "!=", "<>", "===",
                            "!==", "<<", ">>", "<=", ">=", "and", "or", "xor" };
                    if (isMatched(tokenBody, operators)) {
                        reqPreSpace = true;
                        reqPostSpace = true;
                    }
                    else if (tokenBody.equals("=>")) {
                        if (prefSpacerForArrayArrow) {
                            tokenBody = " => ";
                        }
                        if (prefAlignDoubleArrow
                                && scope.peek().type == PHPToken.PHP_ARRAY) {
                            {
                                boolean singleLine = true;
                                int tmpIndex = scope.peek().startIndex;
                                int tmpCount = 0;
                                while (++tmpIndex < regions.length) {
                                    getNextToken(tmpIndex, false, nextToken);
                                    if (hasNewLine(nextToken.body)) {
                                        singleLine = false;
                                    }
                                    if (nextToken.type == PHPToken.PHP_TOKEN) {
                                        final String tmpBody = nextToken.body
                                                .trim();
                                        if (tmpBody.equals("(")) {
                                            tmpCount++;
                                        }
                                        else if (tmpBody.equals(")")) {
                                            tmpCount--;
                                            if (tmpCount < 0) {
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (singleLine) {
                                    break; // case
                                }
                            }
                            if (!scope.peek().fgAligned) {
                                scope.peek().alignMax = doubleArrow(index);
                                scope.peek().fgAligned = true;
                            }
                            getPrevToken(index - 2, true, prevToken);
                            final int len = doubleByte(prevToken.body.trim());
                            int max = scope.peek().alignMax;
                            char[] sp;
                            if (prefAlignDoubleArrowWithTab) {
                                max = ((max + tabSize - 1) / tabSize) * tabSize;
                                final int rem = Math.max(max - len, 0);
                                final int tab = (rem + tabSize - 1) / tabSize;
                                sp = new char[tab];
                                Arrays.fill(sp, '\t');
                            }
                            else {
                                sp = new char[Math.max(max - len, 0)];
                                Arrays.fill(sp, ' ');
                            }
                            tokenBody = String.valueOf(sp) + tokenBody;
                        }
                    }
                    break;

                case PHPToken.PHP_TOKEN:
                    if (tokenBody.length() == 1) {
                        switch (tokenBody.charAt(0)) {
                            case '+':
                            case '-':
                                // try to detect signum
                                boolean isSignum = false;
                                getPrevToken(index - 2, true, prevToken);
                                switch (prevToken.type) {
                                    case PHPToken.PHP_TOKEN:
                                        final String body = prevToken.body
                                                .trim();
                                        if (body.length() == 1) {
                                            switch (body.charAt(0)) {
                                                case '=':
                                                case '(':
                                                case ',':
                                                case '[':
                                                case '+':
                                                case '-':
                                                case '*':
                                                case '/':
                                                case '?':
                                                case ':':
                                                case '<':
                                                case '>':
                                                case '%':
                                                case '&':
                                                case '|':
                                                case '^':
                                                case '.':
                                                    isSignum = true;
                                                    break;
                                            }
                                        }
                                        break;
                                    case PHPToken.PHP_RETURN:
                                    case PHPToken.PHP_CASTING:
                                        isSignum = true;
                                        break;
                                }
                                if (!isSignum) {
                                    reqPreSpace = true;
                                    reqPostSpace = true;
                                }
                                break;

                            case '*':
                            case '/':
                            case '%':
                            case '|':
                            case '^':
                            case '<':
                            case '>':
                                reqPreSpace = true;
                                reqPostSpace = true;
                                break;

                            case '&':
                                if (isReference) {
                                    isReference = false;
                                    reqPostSpace = true;
                                }
                                else {
                                    getPrevToken(index - 2, false, prevToken);
                                    switch (prevToken.type) {
                                        case PHPToken.PHP_TOKEN:
                                            final String body = prevToken.body
                                                    .trim();
                                            if (body.equals("(")
                                                    || body.equals(",")) {
                                            }
                                            else {
                                                reqPreSpace = true;
                                                reqPostSpace = true;
                                            }
                                            break;
                                        case PHPToken.PHP_FUNCTION:
                                            break;
                                        default:
                                            reqPreSpace = true;
                                            reqPostSpace = true;
                                    }
                                }
                                break;

                            case '=':
                                if (index == 1) {
                                    // <?=
                                    isShortcut = true;
                                    if (prefSpacerForShortcut) {
                                        reqPostSpace = true;
                                    }
                                }
                                else {
                                    getNextToken(index, true, nextToken);
                                    if (nextToken.type == PHPToken.PHP_TOKEN
                                            && nextToken.body.trim()
                                                    .equals("&")) {
                                        isReference = true;
                                    }
                                    else {
                                        reqPostSpace = true;
                                    }
                                    reqPreSpace = true;
                                }
                                break;

                            case '.':
                                if (prefSpacerForConcat) {
                                    reqPreSpace = true;
                                    reqPostSpace = true;
                                }
                                else {
                                    // XXX 2010/04/11
                                    getPrevToken(index - 2, true, prevToken);
                                    if (prevToken.type == PHPToken.PHP_NUMBER) {
                                        reqPreSpace = true;
                                    }
                                    // XXX 2010/04/12
                                    getNextToken(index, true, nextToken);
                                    if (nextToken.type == PHPToken.PHP_NUMBER) {
                                        reqPostSpace = true;
                                    }
                                }
                                if (prefLeaveNewLineWithConcatOp) {
                                    boolean newline = false;
                                    if (hasNewLine(token.body)) {
                                        if (prefJoinConcatOpToPostLine) {
                                            reqPreNewLine = true;
                                            reqPreSpace = false;
                                        }
                                        else {
                                            reqPostNewLine = true;
                                            reqPostSpace = false;
                                        }
                                        newline = true;
                                    }
                                    getPrevToken(index - 2, false, prevToken);
                                    if (hasNewLine(prevToken.body)) {
                                        if (prefJoinConcatOpToPrevLine) {
                                            reqPostNewLine = true;
                                            reqPostSpace = false;
                                        }
                                        else {
                                            reqPreNewLine = true;
                                            reqPreSpace = false;
                                        }
                                        newline = true;
                                    }
                                    if (newline) {
                                        indentLevel++;
                                        indentedInConcat = true;
                                    }
                                }
                                break;

                            case ',':
                                switch (scope.peek().type) {
                                    case PHPToken.PHP_ARRAY:
                                        if (prefLeaveNewLineInArray) {
                                            // bug #15264
                                            if (hasNewLine()) {
                                                reqPostNewLine = true;
                                                if (!scope.peek().fgArrayIndent) {
                                                    scope.peek().fgArrayIndent = true;
                                                    indentLevel++;
                                                }
                                                break;
                                            }
                                        }
                                        // dive into default
                                        //$FALL-THROUGH$
                                    default:
                                        if (prefLeaveNewLineAfterComma) {
                                            // bug #15264
                                            if (hasNewLine()) {
                                                reqPostNewLine = true;
                                                if (!indentedInArray) {
                                                    indentedInArray = true;
                                                    indentLevel++;
                                                }
                                                break;
                                            }
                                        }
                                        reqPostSpace = true;
                                }
                                break;

                            case ':':
                                if (!ternaryStack.empty()) {
                                    ternaryStack.pop();
                                    reqPreSpace = true;
                                    reqPostSpace = true;
                                    break;
                                }
                                switch (scope.peek().type) {
                                    case PHPToken.PHP_IF:
                                        scope.peek().fgBlock = true;
                                        // Fall Through
                                        //$FALL-THROUGH$
                                    case PHPToken.PHP_FOR:
                                    case PHPToken.PHP_FOREACH:
                                    case PHPToken.PHP_WHILE:
                                        if (reqOpenBlock || reqOpenBlockNL) {
                                            postIndent++;
                                            reqPreSpace = true;
                                            reqPostNewLine = true;
                                            reqOpenBlock = reqOpenBlockNL = false;
                                        }
                                        else {
                                            reqPreSpace = true;
                                            reqPostSpace = true;
                                        }
                                        break;
                                    case PHPToken.PHP_SWITCH:
                                        if (reqOpenBlock || reqOpenBlockNL) {
                                            indentLevel++;
                                            reqPreSpace = true;
                                            reqPostNewLine = true;
                                            reqOpenBlock = reqOpenBlockNL = false;
                                            if (prefIndentCaseBlock) {
                                                postIndent++;
                                            }
                                        }
                                        else if (inCaseSt) {
                                            inCaseSt = false;
                                            reqPostNewLine = true;
                                            indentLevel++;
                                        }
                                        else {
                                            reqPreSpace = true;
                                            reqPostSpace = true;
                                        }
                                        break;
                                    default:
                                        reqPreSpace = true;
                                        reqPostSpace = true;
                                }
                                break;

                            case '?':
                                ternaryStack.push(token);
                                reqPreSpace = true;
                                reqPostSpace = true;
                                break;

                            case '(':
                                if (scope.peek().type != 0) {
                                    scope.peek().count++;
                                }
                                switch (scope.peek().type) {
                                    case PHPToken.PHP_FUNCTION:
                                        if (prefSpacerForFunctionDef
                                                && scope.peek().fgCond) {
                                            reqPreSpace = true;
                                        }
                                        break;
                                    case PHPToken.PHP_ARRAY:
                                        if (scope.peek().startIndex < 0) {
                                            scope.peek().startIndex = index;
                                        }
                                        if (prefLeaveNewLineInArray
                                                && hasNewLine(token.body)) {
                                            reqPostNewLine = true;
                                            if (!scope.peek().fgArrayIndent) {
                                                scope.peek().fgArrayIndent = true;
                                                indentLevel++;
                                            }
                                            break;
                                        }
                                        break;
                                }
                                break;

                            case ')':
                                if (scope.peek().type != 0) {
                                    scope.peek().count--;
                                }
                                if (scope.peek().type != 0
                                        && scope.peek().count == 0
                                        && scope.peek().fgCond) {
                                    if (indentedForArrow > 0) {
                                        indentLevel -= indentedForArrow;
                                        indentedForArrow = 0;
                                    }
                                    scope.peek().fgCond = false;
                                    switch (scope.peek().type) {
                                        case PHPToken.PHP_IF:
                                        case PHPToken.PHP_FOR:
                                        case PHPToken.PHP_FOREACH:
                                        case PHPToken.PHP_WHILE:
                                            getNextToken(index, true, nextToken);
                                            if (nextToken.type != PHPToken.PHP_CURLY_OPEN
                                                    && !nextToken.body.trim()
                                                            .equals(":")) {
                                                reqOpenBlock = reqOpenBlockNL = false;
                                                if (prefSimpleStatementInOneLine) { // #16894
                                                    reqPostSpace = true;
                                                }
                                                else {
                                                    reqPostNewLine = true;
                                                    indentLevel++;
                                                }
                                                scope.peek().fgSingle = true;
                                            }
                                            else {
                                                scope.peek().fgSingle = false;
                                            }
                                            break;
                                        case PHPToken.PHP_FUNCTION:
                                            if (scope.peek().fgInterface
                                                    || scope.peek().fgAbstract) {
                                                scope.pop();
                                            }
                                            break;
                                        case PHPToken.PHP_ARRAY:
                                            if (prefLeaveNewLineInArray) {
                                                getPrevToken(index - 2, true,
                                                        prevToken);
                                                if (!prevToken.body.trim()
                                                        .equals(",")) {
                                                    if (hasNewLine(prevToken.body)) {
                                                        reqPreNewLine = true;
                                                    }
                                                }
                                            }
                                            if (scope.peek().fgArrayIndent) {
                                                indentLevel--;
                                            }
                                            scope.pop();
                                            break;
                                    }
                                }
                                else {
                                    if (prefSpacerForCast) {
                                        final int ix = getPrevToken(index - 2,
                                                true, prevToken);
                                        final String[] cast = { "int",
                                                "integer", "bool", "boolean",
                                                "float", "double", "real",
                                                "string", "binary", "array",
                                                "object" };
                                        if (isMatched(prevToken.body.trim(),
                                                cast)) {
                                            getPrevToken(ix - 1, true,
                                                    prevToken);// ok
                                            if (prevToken.body.trim().equals(
                                                    "(")) {
                                                reqPostSpace = true;
                                            }
                                        }
                                    }
                                }
                                break;

                            case '$': // #16076
                                getNextToken(index, true, nextToken);
                                if (nextToken.type == PHPToken.PHP_CURLY_OPEN) {
                                    scope.push(new ScopeUnit(
                                            PHPToken.PHP_VARIABLE));
                                }
                                break;
                        }
                    }
                    else { // #16076
                        if (tokenBody.equals("${")) {
                            scope.push(new ScopeUnit(PHPToken.PHP_VARIABLE));
                        }
                    }
                    break;

                case PHPToken.PHP_CASTING:
                    tokenBody = tokenBody.replaceAll("^\\(\\s+", "\\(");
                    tokenBody = tokenBody.replaceAll("\\s+\\)$", "\\)");
                    if (prefSpacerForCast) {
                        reqPostSpace = true;
                    }
                    break;

                case PHPToken.PHP_CLASS:
                case PHPToken.PHP_INTERFACE:
                    reqPostSpace = true;
                    if (prefNewLineForClass) {
                        reqOpenBlockNL = true;
                    }
                    else {
                        reqOpenBlock = true;
                    }
                    scope.push(new ScopeUnit(token.type));
                    break;

                case PHPToken.PHP_FUNCTION:
                    reqPostSpace = true;
                    if (prefNewLineForFunction) {
                        reqOpenBlockNL = true;
                    }
                    else {
                        reqOpenBlock = true;
                    }
                    final int parentType = scope.peek().type;
                    scope.push(new ScopeUnit(token.type));
                    switch (parentType) {
                        case PHPToken.PHP_INTERFACE:
                            scope.peek().fgInterface = true;
                            reqOpenBlock = reqOpenBlockNL = false;
                            break;
                        case PHPToken.PHP_CLASS:
                            int ix = index - 2;
                            while (ix >= 0) {
                                ix = getPrevToken(ix, true, prevToken);
                                if (prevToken.type == PHPToken.PHP_ABSTRACT) {
                                    scope.peek().fgAbstract = true;
                                    reqOpenBlock = reqOpenBlockNL = false;
                                    break;
                                }
                                if (isMatched(prevToken.body.trim(),
                                        new String[] { ";", "}", "{" })) {
                                    break;
                                }
                                ix--;
                            }
                            break;
                    }
                    break;

                case PHPToken.PHP_TRY:
                case PHPToken.PHP_CATCH:
                    scope.push(new ScopeUnit(token.type));
                    reqPostSpace = true;
                    if (prefNewLineForTryCatch) {
                        reqOpenBlockNL = true;
                    }
                    else {
                        reqOpenBlock = true;
                    }
                    break;

                case PHPToken.PHP_ARRAY:
                    if (scope.peek().type == PHPToken.PHP_FUNCTION
                            && scope.peek().fgCond) {
                        getNextToken(index, true, nextToken);
                        if (nextToken.type == PHPToken.PHP_TOKEN
                                && nextToken.body.trim().equals("(")) {
                            // assumed default value
                        }
                        else {
                            // assumed type-hinting
                            reqPostSpace = true;
                        }
                        break;
                    }
                    scope.push(new ScopeUnit(token.type));
                    break;

                case PHPToken.PHP_DO:
                    scope.push(new ScopeUnit(token.type));
                    scope.peek().fgCond = false;
                    if (prefNewLineForBlock) {
                        reqOpenBlockNL = true;
                    }
                    else {
                        reqOpenBlock = true;
                        reqPostSpace = true;
                    }
                    break;

                case PHPToken.PHP_WHILE:
                    if (scope.peek().type == PHPToken.PHP_DO) {
                        scope.pop();
                        reqPostSpace = true;
                        break;
                    }
                    //$FALL-THROUGH$
                case PHPToken.PHP_IF:
                case PHPToken.PHP_FOR:
                case PHPToken.PHP_FOREACH:
                case PHPToken.PHP_SWITCH:
                    scope.push(new ScopeUnit(token.type));
                    if (prefNewLineForBlock) {
                        reqOpenBlockNL = true;
                    }
                    else {
                        reqOpenBlock = true;
                    }
                    reqPostSpace = true;
                    break;

                case PHPToken.PHP_ELSEIF:
                    scope.peek().fgCond = true;
                    if (scope.peek().fgBlock) {
                        indentLevel--;
                    }
                    if (prefNewLineForBlock) {
                        reqOpenBlockNL = true;
                    }
                    else {
                        reqOpenBlock = true;
                    }
                    reqPostSpace = true;
                    break;

                case PHPToken.PHP_ELSE:
                    scope.peek().fgElse = true;
                    getNextToken(index, true, nextToken);
                    if (nextToken.type != PHPToken.PHP_CURLY_OPEN) {
                        // #16194
                        if (prefEquateEleIfToElseif
                                && nextToken.type == PHPToken.PHP_IF) {
                            reqPostSpace = true;
                            scope.pop();
                            break;
                        }
                        if (scope.peek().fgBlock) {
                            indentLevel--;
                            if (prefNewLineForBlock) {
                                reqOpenBlockNL = true;
                            }
                            else {
                                reqOpenBlock = true;
                                reqPostSpace = true;
                            }
                            scope.peek().fgSingle = false;
                        }
                        else {
                            reqOpenBlock = false;
                            if (prefSimpleStatementInOneLine) { // #16894
                                reqPostSpace = true;
                            }
                            else {
                                reqPostNewLine = true;
                                postIndent++;
                            }
                            scope.peek().fgSingle = true;
                        }
                    }
                    else {
                        if (prefNewLineForBlock) {
                            reqOpenBlockNL = true;
                        }
                        else {
                            reqOpenBlock = true;
                            reqPostSpace = true;
                        }
                        scope.peek().fgSingle = false;
                    }
                    break;

                case PHPToken.PHP_CASE:
                    reqPostSpace = true;
                    // Fall Through
                    //$FALL-THROUGH$
                case PHPToken.PHP_DEFAULT:
                    indentLevel--;
                    inCaseSt = true;
                    break;

                case PHPToken.PHP_NEW:
                case PHPToken.PHP_ABSTRACT:
                case PHPToken.PHP_PUBLIC:
                case PHPToken.PHP_PROTECTED:
                case PHPToken.PHP_PRIVATE:
                case PHPToken.PHP_VAR:
                case PHPToken.PHP_CONST:
                case PHPToken.PHP_GLOBAL:
                case PHPToken.PHP_THROW:
                case PHPToken.PHP_STATIC:
                case PHPToken.PHP_FINAL:
                    reqPostSpace = true;
                    break;

                case PHPToken.PHP_EXTENDS:
                case PHPToken.PHP_IMPLEMENTS:
                case PHPToken.PHP_AS:
                case PHPToken.PHP_INSTANCEOF:
                    reqPostSpace = true;
                    reqPreSpace = true;
                    break;

                case PHPToken.PHP_ECHO:
                case PHPToken.PHP_PRINT:
                case PHPToken.PHP_INCLUDE:
                case PHPToken.PHP_INCLUDE_ONCE:
                case PHPToken.PHP_REQUIRE:
                case PHPToken.PHP_REQUIRE_ONCE:
                    getNextToken(index, true, nextToken);
                    if (!(nextToken.type == PHPToken.PHP_TOKEN && nextToken.body
                            .trim().equals("("))) {
                        reqPostSpace = true;
                    }
                    break;

                case PHPToken.PHP_VARIABLE:
                    getPrevToken(index - 2, true, prevToken);
                    if (prevToken.type == PHPToken.PHP_STRING) {
                        // assumed type-hinting/catch-clause
                        reqPreSpace = true;
                    }
                    break;

                case PHPToken.PHP_ENCAPSED_AND_WHITESPACE:
                    tokenBody = token.body;
                    break;

                case PHPToken.PHP_CONSTANT_ENCAPSED_STRING:
                    if (tokenBody.equals("\"")) {
                        inConstantEncapsedString = !inConstantEncapsedString;
                    }
                    else if (tokenBody.startsWith("\"")
                            && tokenBody.endsWith("\"")) {
                        // simple(non-divided) string
                    }
                    else if (!tokenBody.startsWith("'")) {
                        tokenBody = token.body;
                    }
                    else {

                    }
                    break;

                case PHPToken.PHP_COMMENT_START:
                    inComment = true;
                    commentBuffer.setLength(0);
                    commentBuffer.append(token.body);
                    tokenBody = "";
                    if (prefSpacerForComment) {
                        reqPreSpace = true;
                    }
                    outbuf.enableLineWrapping(false);
                    break;

                case PHPToken.PHPDOC_COMMENT_START:
                    inPHPDocComment = true;
                    commentBuffer.setLength(0);
                    commentBuffer.append(token.body);
                    tokenBody = "";
                    outbuf.enableLineWrapping(false);
                    break;

                case PHPToken.PHP_LINE_COMMENT:
                    inLineComment = true;
                    if (prefSpacerForComment) {
                        reqPreSpace = true;
                    }
                    outbuf.enableLineWrapping(false);
                    break;

                case PHPToken.PHP_HEREDOC_TAG:
                    terminator = tokenBody.substring(3).trim();
                    tokenBody = "<<<" + terminator;
                    inHereDoc = true;
                    reqPostNewLine = true;
                    outbuf.enableLineWrapping(false);
                    break;

                case PHPToken.PHP_ENDIF:
                    if (scope.peek().type == PHPToken.PHP_IF) {
                        scope.pop();
                    }
                    indentLevel--;
                    break;

                case PHPToken.PHP_ENDFOR:
                    if (scope.peek().type == PHPToken.PHP_FOR) {
                        scope.pop();
                    }
                    indentLevel--;
                    break;

                case PHPToken.PHP_ENDFOREACH:
                    if (scope.peek().type == PHPToken.PHP_FOREACH) {
                        scope.pop();
                    }
                    indentLevel--;
                    break;

                case PHPToken.PHP_ENDWHILE:
                    if (scope.peek().type == PHPToken.PHP_WHILE) {
                        scope.pop();
                    }
                    indentLevel--;
                    break;

                case PHPToken.PHP_ENDSWITCH:
                    if (scope.peek().type == PHPToken.PHP_SWITCH) {
                        scope.pop();
                    }
                    indentLevel--;
                    if (prefIndentCaseBlock) {
                        indentLevel--;
                    }
                    break;

                case PHPToken.PHP_OBJECT_OPERATOR:
                    if (prefLeaveNewLineForArrow) {
                        getPrevToken(index - 2, false, prevToken);
                        if (hasNewLine(prevToken.body)) {
                            reqPreNewLine = true;
                            if (indentedForArrow == 0
                                    || prefLeaveNewLineForArrowNest) {
                                indentedForArrow++;
                                indentLevel++;
                            }
                        }
                    }
                    getNextToken(index, false, nextToken);
                    if (nextToken.type == PHPToken.WHITESPACE
                            && nextToken.body.trim().equals("")) {
                        index++;
                        if (prefLeaveNewLineForArrow) {
                            if (hasNewLine(nextToken.body)) {
                                reqPostNewLine = true;
                                if (indentedForArrow == 0
                                        || prefLeaveNewLineForArrowNest) {
                                    indentedForArrow++;
                                    postIndent++;
                                }
                            }
                        }
                    }
                    break;

                case PHPToken.PHP_CLONE:
                    reqPostSpace = true;
                    break;

                case PHPToken.PHP_RETURN:
                case PHPToken.PHP_BREAK:
                case PHPToken.PHP_CONTINUE:
                    getNextToken(index, true, nextToken);
                    if (nextToken.type != PHPToken.PHP_SEMICOLON) {
                        reqPostSpace = true;
                    }
                    break;

                case PHPToken.PHP_EXIT:
                default:
                    break;
            }

            if (reqPreNewLine) {
                // #16941
                if (justAfterOpenTag) {
                    if (prefLeaveBlankLines1) {
                        if (prefShrinkBlankLines1 && newLines > 2) {
                            newLines = 2;
                        }
                    }
                    else {
                        newLines = 1;
                    }
                    justAfterOpenTag = false;
                }
                else {
                    if (prefLeaveBlankLines2) {
                        if (prefShrinkBlankLines2 && newLines > 2) {
                            newLines = 2;
                        }
                    }
                    else {
                        newLines = 1;
                    }
                }
                for (int i = 0; i < newLines; i++) {
                    outbuf.append(lineDelimiter);
                }
                newLines = 1;
                outbuf.append(indent(indentLevel, indentChar));
                if (indentedInArray) {
                    indentedInArray = false;
                    indentLevel--;
                }
                if (indentedInConcat) {
                    indentedInConcat = false;
                    indentLevel--;
                }
                reqPreNewLine = false;
            }
            if (reqPreSpace) {
                if (outbuf.length() > 0) {
                    final char c = outbuf.charAt(outbuf.length() - 1);
                    if (c != ' ' && c != '\t' && c != '\n' && c != '\r') {
                        outbuf.append(" ");
                    }
                }
                else {
                    outbuf.append(" ");
                }
                reqPreSpace = false;
            }

            outbuf.append(tokenBody);

            // #16941
            if (justAfterOpenTag) {
                justAfterOpenTag = tokenBody.trim().equals("");
            }

            if (reqPostSpace) {
                outbuf.append(" ");
                reqPostSpace = false;
            }
            if (reqPostNewLine) {
                boolean newLine = hasNewLine(token.body);
                if (!newLine) {
                    getNextToken(index, false, nextToken);
                    switch (nextToken.type) {
                        case PHPToken.PHP_COMMENT_START:
                        case PHPToken.PHP_LINE_COMMENT:
                            break;
                        default:
                            newLine = true;
                            break;
                    }
                }
                if (newLine) {
                    String str = token.body;
                    if (index > 1 && token.type == PHPToken.WHITESPACE) {
                        getPrevToken(index - 2, false, prevToken);
                        // #17012
                        if (prevToken.body.endsWith("\n\r")
                                || prevToken.body.endsWith("\r\n")) {
                            str = prevToken.body.substring(prevToken.body
                                    .length() - 2) + str;
                        }
                        else if (prevToken.body.endsWith("\n")
                                || prevToken.body.endsWith("\r")) {
                            str = prevToken.body.substring(prevToken.body
                                    .length() - 1) + str;
                        }
                    }
                    int count = 0;
                    int ix = 0;
                    while ((ix = str.indexOf(lineDelimiter, ix)) != -1) {
                        count++;
                        ix += lineDelimiter.length();
                    }
                    if (count > 0) {
                        newLines = count;
                    }
                    reqPreNewLine = true;
                    reqPostNewLine = false;
                }
            }
            if (reqNewLineImmediately) {
                outbuf.append(lineDelimiter);
                outbuf.append(indent(indentLevel, indentChar));
                reqNewLineImmediately = false;
            }
            indentLevel += postIndent;
            postIndent = 0;
        }

        final String buf = outbuf.toString();
        if (buf.contains(lineDelimiter)) {
            if (reqPreNewLine) {
                // #16941
                if (prefLeaveBlankLines3) {
                    if (prefShrinkBlankLines3 && newLines > 2) {
                        newLines = 2;
                    }
                }
                else {
                    newLines = 1;
                }
                for (int i = 0; i < newLines; i++) {
                    outbuf.append(lineDelimiter);
                }
            }
        }
        else { // <?php ... ?> in a line
            switch (buf.charAt(buf.length() - 1)) {
                case ' ':
                case '\t':
                case '\n':
                case '\r':
                    break;
                default:
                    if (isShortcut && !prefSpacerForShortcutClose) {
                        break;
                    }
                    outbuf.append(" ");
            }
        }
        if (isShortcut && prefSpacerForShortcutClose) {
            switch (outbuf.charAt(outbuf.length() - 1)) {
                case ' ':
                case '\t':
                case '\n':
                case '\r':
                    break;
                default:
                    outbuf.append(" ");
            }
        }
        reqPreNewLine = false;

        final String trimStr = " " + lineDelimiter;
        final int trimLen = trimStr.length();
        int i = outbuf.indexOf(trimStr);
        while (i >= 0) {
            outbuf.replace(i, i + trimLen, lineDelimiter);
            i = outbuf.indexOf(trimStr);
        }
    }

    private int doubleArrow(int index) {
        int itemLength = 0;
        int depth = 1;
        final TokenUnit token = new TokenUnit();
        try {
            getPrevToken(index - 2, true, token);
            if (token.type == PHPToken.PHP_CONSTANT_ENCAPSED_STRING) {
                itemLength = doubleByte(token.body.trim());
                while (index < regions.length && depth > 0) {
                    getNextToken(index, true, token);
                    final String tokenBody = token.body.trim();
                    switch (token.type) {
                        case PHPToken.PHP_TOKEN:
                            if (tokenBody.length() == 1) {
                                switch (tokenBody.charAt(0)) {
                                    case '(':
                                        depth++;
                                        break;
                                    case ')':
                                        depth--;
                                        break;
                                }
                            }
                            break;
                        case PHPToken.PHP_CONSTANT_ENCAPSED_STRING:
                            if (depth == 1) {
                                final int length = doubleByte(tokenBody);
                                getNextToken(index + 1, true, token);
                                if (token.type == PHPToken.PHP_OPERATOR) {
                                    if (token.body.trim().equals("=>")) {
                                        if (itemLength < length) {
                                            itemLength = length;
                                        }
                                    }
                                }
                            }
                            break;
                    }
                    index++;
                }
            }
        } catch (final BadLocationException e) {
            e.printStackTrace();
        }
        return itemLength;
    }

    private int doubleByte(String string) {
        int length = 0;
        for (final char ch : string.toCharArray()) {
            length += (ch > 0x00ff) ? 2 : 1;
        }
        return length;
    }

    /**
     * @return the currentFile
     */
    protected IFile getCurrentFile() {
        return currentFile;
    }

    /**
     * @param currentFile
     *            the currentFile to set
     */
    public void setCurrentFile(IFile currentFile) {
        this.currentFile = currentFile;
    }
}
