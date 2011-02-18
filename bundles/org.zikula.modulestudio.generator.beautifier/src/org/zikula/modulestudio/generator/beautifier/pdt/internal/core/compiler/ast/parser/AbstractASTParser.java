package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser;

/*******************************************************************************
 * Copyright (c) 2009 IBM Corporation and others. All rights reserved. This
 * program and the accompanying materials are made available under the terms of
 * the Eclipse Public License v1.0 which accompanies this distribution, and is
 * available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: IBM Corporation - initial API and implementation Zend
 * Technologies
 * 
 * 
 * 
 * Based on package org.eclipse.php.internal.core.compiler.ast.parser;
 * 
 *******************************************************************************/

import java.util.LinkedList;
import java.util.List;
import java.util.Stack;

import java_cup.runtime.Scanner;
import java_cup.runtime.Symbol;
import java_cup.runtime.lr_parser;

import org.eclipse.dltk.ast.declarations.MethodDeclaration;
import org.eclipse.dltk.ast.declarations.TypeDeclaration;
import org.eclipse.dltk.ast.statements.Block;
import org.eclipse.dltk.ast.statements.Statement;
import org.eclipse.dltk.compiler.problem.DefaultProblem;
import org.eclipse.dltk.compiler.problem.IProblem;
import org.eclipse.dltk.compiler.problem.IProblemReporter;
import org.eclipse.dltk.compiler.problem.ProblemSeverities;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.scanner.AstLexer;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ASTError;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ASTNodeKinds;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.IRecoverable;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.NamespaceDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPModuleDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.VarComment;

abstract public class AbstractASTParser extends lr_parser {

    private final PHPModuleDeclaration program = new PHPModuleDeclaration(0, 0,
            new LinkedList<Statement>(), new LinkedList<ASTError>(),
            new LinkedList<VarComment>());
    private IProblemReporter problemReporter;
    private String fileName;

    /**
     * This is a place holder for statements that were found after unclosed
     * classes
     */
    public Statement pendingStatement = null;

    /** This is a latest non-bracketed namespace declaration */
    public NamespaceDeclaration currentNamespace = null;

    /** Whether we've met the unbracketed namespace declaration in this file */
    public boolean metUnbracketedNSDecl;

    /** Whether we've met the bracketed namespace declaration in this file */
    public boolean metBracketedNSDecl;

    /** Top declarations stack */
    public Stack<Statement> declarations = new Stack<Statement>();

    public AbstractASTParser() {
        super();
    }

    public AbstractASTParser(Scanner s) {
        super(s);
    }

    public void setProblemReporter(IProblemReporter problemReporter) {
        this.problemReporter = problemReporter;
    }

    public IProblemReporter getProblemReporter() {
        return problemReporter;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFileName() {
        return fileName;
    }

    protected List<ASTError> getErrors() {
        return program.getErrors();
    }

    protected void reportError(IProblemReporter problemReporter,
            String fileName, int start, int end, int lineNumber, String message) {
        @SuppressWarnings("deprecation")
        final DefaultProblem problem = new DefaultProblem(fileName, message,
                IProblem.Syntax, new String[0], ProblemSeverities.Error, start,
                end, lineNumber);
        problemReporter.reportProblem(problem);
    }

    /**
     * Report on errors that will be added to the AST as statements
     */
    public void reportError() {
        program.setHasErrors(true);
    }

    public void reportError(ASTError error) {
        reportError(error, null);
    }

    /**
     * Reporting an error that cannot be added as a statement and has to be in a
     * separated list.
     * 
     * @param error
     */
    public void reportError(ASTError error, String message) {
        getErrors().add(error);
        reportError();

        if (message != null && problemReporter != null && fileName != null) {
            final int lineNumber = ((AstLexer) getScanner()).getCurrentLine();
            reportError(problemReporter, fileName, error.sourceStart(),
                    error.sourceEnd(), lineNumber, message);
        }
    }

    public void addStatement(Statement s) {
        final int kind = s.getKind();
        if (kind != ASTNodeKinds.EMPTY_STATEMENT
                && kind != ASTNodeKinds.DECLARE_STATEMENT
                && kind != ASTNodeKinds.NAMESPACE_DECLARATION
                && metBracketedNSDecl) {
            reportError(new ASTError(s.sourceStart(), s.sourceEnd()),
                    "No code may exist outside of namespace {}");
        }

        if (currentNamespace != null && currentNamespace != s) {
            currentNamespace.addStatement(s);
        }
        else {
            program.addStatement(s);
        }
    }

    public PHPModuleDeclaration getModuleDeclaration() {
        return program;
    }

    @Override
    public void report_error(String message, Object info) {
        if (info instanceof Symbol) {
            if (((Symbol) info).left != -1) {
                final ASTError error = new ASTError(((Symbol) info).left,
                        ((Symbol) info).right);
                reportError(error);
            }
            else {
                reportError(new ASTError(0, 1));
            }
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public void unrecovered_syntax_error(Symbol cur_token)
            throws java.lang.Exception {
        // in case
        int start = 0;
        int end = 0;
        final Object value = cur_token.value;
        final PHPModuleDeclaration program = getModuleDeclaration();
        final List<Statement> statements = program.getStatements();
        if (value instanceof List) {
            statements.addAll((List) value);
        }

        while (!declarations.isEmpty()) {
            statements.add(declarations.remove(0));
        }
        if (!statements.isEmpty()) {
            final Statement s1 = statements.get(0);
            final Statement s2 = statements.get(statements.size() - 1);
            start = s1.sourceStart();
            end = s2.sourceEnd();
        }
        final List<ASTError> errors = getErrors();
        if (!errors.isEmpty()) {
            final ASTError lastError = errors.get(errors.size() - 1);
            end = (end > lastError.sourceEnd()) ? end : lastError.sourceEnd();
        }
        program.setStart(start);
        program.setEnd(end);

        // Set end offset of recovered class/interface node to the end of file
        if (statements.size() > 0) {
            final Statement lastStatement = statements
                    .get(statements.size() - 1);
            if (lastStatement instanceof IRecoverable) {
                final IRecoverable recoverable = (IRecoverable) lastStatement;
                if (recoverable.isRecovered()) {
                    lastStatement.setEnd(end);
                }
            }
        }

        super.unrecovered_syntax_error(cur_token);
    }

    @Override
    public void syntax_error(Symbol cur_token) {
        super.syntax_error(cur_token);

        if (fileName == null || problemReporter == null) {
            return;
        }

        final int state = ((Symbol) stack.peek()).parse_state;

        final short[] rowOfProbe = action_tab[state];
        final int startPosition = cur_token.left;
        int endPosition = cur_token.right;
        final int lineNumber = ((AstLexer) getScanner()).getCurrentLine();

        final StringBuilder errorMessage = new StringBuilder("syntax error");

        // current token can be either null, string or phpdoc - according to
        // this resolve:
        String currentText = cur_token.value instanceof String ? (String) cur_token.value
                : null;
        if (currentText == null || currentText.length() == 0) {
            currentText = getTokenName(cur_token.sym);
        }
        if (currentText != null && currentText.length() > 0) {
            if (currentText.equals(";")) { // This means EOF, since it's
                // substituted by the lexer
                // explicitly.
                currentText = "EOF"; //$NON-NLS-1$
            }
            endPosition = startPosition + currentText.length();
            errorMessage.append(", unexpected '").append(currentText)
                    .append('\'');
        }

        if (rowOfProbe.length <= 6) {
            errorMessage.append(", expecting ");
            boolean first = true;
            for (int probe = 0; probe < rowOfProbe.length; probe += 2) {
                final String tokenName = getTokenName(rowOfProbe[probe]);
                if (tokenName != null) {
                    if (!first) {
                        errorMessage.append(" or ");
                    }
                    errorMessage.append('\'').append(tokenName).append('\'');
                    first = false;
                }
            }
        }

        reportError(problemReporter, fileName, startPosition, endPosition,
                lineNumber, errorMessage.toString());
    }

    protected abstract String getTokenName(int token);

    @Override
    public void report_fatal_error(String message, Object info)
            throws java.lang.Exception {
        /* stop parsing (not really necessary since we throw an exception, but) */
        done_parsing();

        /* use the normal error message reporting to put out the message */
        // report_error(message, info);

        // throw new Exception("Can't recover from previous error(s)");
    }

    public void addDeclarationStatement(Statement s) {
        if (declarations.isEmpty()) {
            if (s.getKind() == ASTNodeKinds.NAMESPACE_DECLARATION) {
                if (program.getStatements().size() > 0 && !metBracketedNSDecl
                        && !metUnbracketedNSDecl) {
                    boolean justDeclarationNodes = true;
                    for (final Object statement : program.getStatements()) {
                        if (((Statement) statement).getKind() != ASTNodeKinds.DECLARE_STATEMENT) {
                            justDeclarationNodes = false;
                            break;
                        }
                    }
                    if (!justDeclarationNodes) {
                        reportError(
                                new ASTError(s.sourceStart(), s.sourceEnd()),
                                "Namespace declaration statement has to be the very first statement in the script");
                    }
                }
            }

            // we don't add top level statements to the program node this way
            return;
        }
        final Statement node = declarations.peek();
        Block block = null;
        if (node instanceof TypeDeclaration) {
            block = ((TypeDeclaration) node).getBody();
        }
        else if (node instanceof MethodDeclaration) {
            block = ((MethodDeclaration) node).getBody();
        }
        else if (node instanceof Block) {
            block = (Block) node;
        }
        block.addStatement(s);
        block.setEnd(s.sourceEnd());
    }
}
