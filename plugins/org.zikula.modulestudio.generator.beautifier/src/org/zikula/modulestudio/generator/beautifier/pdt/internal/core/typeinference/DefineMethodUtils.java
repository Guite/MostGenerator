package org.zikula.modulestudio.generator.beautifier.pdt.internal.core.typeinference;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

import org.eclipse.dltk.ast.ASTNode;
import org.eclipse.dltk.ast.ASTVisitor;
import org.eclipse.dltk.ast.declarations.ModuleDeclaration;
import org.eclipse.dltk.ast.expressions.CallArgumentsList;
import org.eclipse.dltk.ast.expressions.Expression;
import org.eclipse.dltk.ast.statements.Statement;
import org.eclipse.dltk.core.DLTKCore;
import org.eclipse.dltk.core.IField;
import org.eclipse.dltk.core.IMember;
import org.eclipse.dltk.core.ISourceRange;
import org.eclipse.dltk.core.ModelException;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.ExpressionStatement;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPCallExpression;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPDocBlock;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.PHPModuleDeclaration;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.nodes.Scalar;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.compiler.ast.parser.ASTUtils;

public class DefineMethodUtils {

    public static String DEFINE = "define";

    public static PHPCallExpression getDefineNodeByField(
            ModuleDeclaration module, IField field) throws ModelException {
        final FunctionInvocationSearcher visitor = new FunctionInvocationSearcher(
                module, field);
        try {
            module.traverse(visitor);
        } catch (final Exception e) {
            if (DLTKCore.DEBUG) {
                // Logger.logException(e);
                GeneratorBeautifierPlugin.log(e);
            }
        }
        return visitor.getResult();
    }

    public static PHPDocBlock getDefinePHPDocBlockByField(
            ModuleDeclaration module, IField field) throws ModelException {
        if (module instanceof PHPModuleDeclaration) {
            if (getDefineNodeByField(module, field) == null) {
                return null;
            }
            final PHPModuleDeclaration phpModule = (PHPModuleDeclaration) module;
            List<PHPDocBlock> phpDocBlocks = phpModule.getPhpDocBlocks();
            if (phpDocBlocks != null && !phpDocBlocks.isEmpty()) {
                final List statements = phpModule.getStatements();
                final ISourceRange sourceRange = field.getNameRange();
                ASTNode previousStatement = null;
                for (final Iterator iterator = statements.iterator(); iterator
                        .hasNext();) {
                    final ASTNode statement = (ASTNode) iterator.next();
                    if (statement.sourceStart() <= sourceRange.getOffset()
                            && statement.sourceEnd() >= (sourceRange
                                    .getOffset() + sourceRange.getLength())) {
                        // define statement
                        phpDocBlocks = getPHPDocBlockBetweenStatements(
                                previousStatement, statement, phpDocBlocks);
                        if (phpDocBlocks.isEmpty()) {
                            return null;
                        }
                        Collections.sort(phpDocBlocks,
                                new Comparator<PHPDocBlock>() {
                                    @Override
                                    public int compare(PHPDocBlock o1,
                                            PHPDocBlock o2) {
                                        return o1.sourceStart()
                                                - o2.sourceStart();
                                    }
                                });
                        return phpDocBlocks.get(phpDocBlocks.size() - 1);
                    }
                    previousStatement = statement;
                }
                final PHPCallExpression callExpression = getDefineNodeByField(
                        phpModule, field);
                callExpression.getReceiver();
            }
        }
        return null;
    }

    private static List<PHPDocBlock> getPHPDocBlockBetweenStatements(
            ASTNode previousStatement, ASTNode statement,
            List<PHPDocBlock> phpDocBlocks) {
        if (previousStatement == null) {
            return getPHPDocBlockBetweenRange(-1, statement.sourceStart(),
                    phpDocBlocks);
        }
        return getPHPDocBlockBetweenRange(previousStatement.sourceEnd(),
                statement.sourceStart(), phpDocBlocks);
    }

    private static List<PHPDocBlock> getPHPDocBlockBetweenRange(int start,
            int end, List<PHPDocBlock> phpDocBlocks) {
        final List<PHPDocBlock> result = new ArrayList<PHPDocBlock>();
        for (final Object element : phpDocBlocks) {
            final PHPDocBlock phpDocBlock = (PHPDocBlock) element;
            if (phpDocBlock.sourceStart() >= start
                    && phpDocBlock.sourceEnd() <= end) {
                result.add(phpDocBlock);
            }
        }
        return result;
    }

    public static class FunctionInvocationSearcher extends ASTVisitor {

        private int bestScore = Integer.MAX_VALUE;
        private final int modelStart;
        private final int modelEnd;
        private final int modelCutoffStart;
        private final int modelCutoffEnd;
        private final String elementName;
        private PHPCallExpression result;

        public FunctionInvocationSearcher(ModuleDeclaration moduleDeclaration,
                IMember modelElement) throws ModelException {
            final ISourceRange sourceRange = modelElement.getSourceRange();
            modelStart = sourceRange.getOffset();
            modelEnd = modelStart + sourceRange.getLength();
            modelCutoffStart = modelStart - 100;
            modelCutoffEnd = modelEnd + 100;
            elementName = modelElement.getElementName();
        }

        public PHPCallExpression getResult() {
            return result;
        }

        protected void checkElementDeclaration(PHPCallExpression s) {
            if (s.getName().equals(DEFINE)) {
                final CallArgumentsList args = s.getArgs();
                if (args != null && args.getChilds() != null) {
                    final ASTNode argument = (ASTNode) args.getChilds().get(0);
                    if (argument instanceof Scalar) {
                        final String constant = ASTUtils
                                .stripQuotes(((Scalar) argument).getValue());
                        if (constant.equals(elementName)) {
                            final int astStart = s.sourceStart();
                            final int astEnd = s.sourceEnd();
                            final int diff1 = modelStart - astStart;
                            final int diff2 = modelEnd - astEnd;
                            final int score = diff1 * diff1 + diff2 * diff2;
                            if (score < bestScore) {
                                bestScore = score;
                                result = s;
                            }
                        }
                    }

                }
            }
        }

        protected boolean interesting(ASTNode s) {
            if (s.sourceStart() < 0 || s.sourceEnd() < s.sourceStart()) {
                return true;
            }
            if (modelCutoffEnd < s.sourceStart()
                    || modelCutoffStart >= s.sourceEnd()) {
                return false;
            }
            return true;
        }

        @Override
        public boolean visit(Expression s) throws Exception {
            if (!interesting(s)) {
                return false;
            }
            return true;
        }

        @Override
        public boolean visit(Statement s) throws Exception {
            if (!interesting(s)) {
                return false;
            }
            if (s instanceof ExpressionStatement) {
                if (((ExpressionStatement) s).getExpr() instanceof PHPCallExpression) {
                    checkElementDeclaration((PHPCallExpression) ((ExpressionStatement) s)
                            .getExpr());

                }
            }
            return true;
        }

        @Override
        public boolean visit(ModuleDeclaration s) throws Exception {
            if (!interesting(s)) {
                return false;
            }
            return true;
        }

        @Override
        public boolean visitGeneral(ASTNode s) throws Exception {
            if (!interesting(s)) {
                return false;
            }
            return true;
        }
    }
}
