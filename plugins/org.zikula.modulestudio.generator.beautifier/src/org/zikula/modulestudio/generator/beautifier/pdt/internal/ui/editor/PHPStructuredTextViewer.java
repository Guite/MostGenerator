package org.zikula.modulestudio.generator.beautifier.pdt.internal.ui.editor;

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
 * Based on package org.eclipse.php.internal.ui.editor;
 * 
 *******************************************************************************/

import java.util.ArrayList;
import java.util.EventObject;

import org.eclipse.core.runtime.Assert;
import org.eclipse.emf.common.command.BasicCommandStack;
import org.eclipse.emf.common.command.CommandStack;
import org.eclipse.emf.common.command.CommandStackListener;
import org.eclipse.jface.internal.text.SelectionProcessor;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentAdapter;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextPresentationListener;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.formatter.FormattingContext;
import org.eclipse.jface.text.formatter.FormattingContextProperties;
import org.eclipse.jface.text.formatter.IContentFormatterExtension;
import org.eclipse.jface.text.formatter.IFormattingContext;
import org.eclipse.jface.text.information.IInformationPresenter;
import org.eclipse.jface.text.projection.ProjectionMapping;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.eclipse.jface.text.reconciler.IReconciler;
import org.eclipse.jface.text.source.IAnnotationHover;
import org.eclipse.jface.text.source.IAnnotationModel;
import org.eclipse.jface.text.source.IOverviewRuler;
import org.eclipse.jface.text.source.IVerticalRuler;
import org.eclipse.jface.text.source.SourceViewerConfiguration;
import org.eclipse.swt.custom.ST;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.texteditor.ITextEditor;
import org.eclipse.wst.sse.core.internal.provisional.events.RegionChangedEvent;
import org.eclipse.wst.sse.core.internal.provisional.events.RegionsReplacedEvent;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocument;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocumentRegion;
import org.eclipse.wst.sse.core.internal.text.TextRegionListImpl;
import org.eclipse.wst.sse.core.internal.undo.IStructuredTextUndoManager;
import org.eclipse.wst.sse.ui.internal.SSEUIMessages;
import org.eclipse.wst.sse.ui.internal.StructuredDocumentToTextAdapter;
import org.eclipse.wst.sse.ui.internal.StructuredTextViewer;
import org.eclipse.wst.sse.ui.internal.reconcile.StructuredRegionProcessor;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.PHPRegionContext;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.IPhpScriptRegion;

public class PHPStructuredTextViewer extends StructuredTextViewer {

    /**
     * Text operation code for requesting the outline for the current input.
     */
    public static final int SHOW_OUTLINE = 51;

    /**
     * Text operation code for requesting the outline for the element at the
     * current position.
     */
    public static final int OPEN_STRUCTURE = 52;

    /**
     * Text operation code for requesting the hierarchy for the current input.
     */
    public static final int SHOW_HIERARCHY = 53;

    private static final String FORMAT_DOCUMENT_TEXT = SSEUIMessages.Format_Document_UI_;

    private SourceViewerConfiguration fViewerConfiguration;
    private ITextEditor fTextEditor;
    private IInformationPresenter fOutlinePresenter;
    private IInformationPresenter fHierarchyPresenter;
    private IAnnotationHover fProjectionAnnotationHover;
    private boolean fFireSelectionChanged = true;

    private IDocumentAdapter documentAdapter;

    public PHPStructuredTextViewer(Composite parent,
            IVerticalRuler verticalRuler, IOverviewRuler overviewRuler,
            boolean showAnnotationsOverview, int styles) {
        super(parent, verticalRuler, overviewRuler, showAnnotationsOverview,
                styles);
    }

    public PHPStructuredTextViewer(ITextEditor textEditor, Composite parent,
            IVerticalRuler verticalRuler, IOverviewRuler overviewRuler,
            boolean showAnnotationsOverview, int styles) {
        super(parent, verticalRuler, overviewRuler, showAnnotationsOverview,
                styles);
        this.fTextEditor = textEditor;
    }

    public ITextEditor getTextEditor() {
        return fTextEditor;
    }

    /**
     * This method overrides WST since sometimes we get a subset of the document
     * and NOT the whole document, although the case is FORMAT_DOCUMENT. In all
     * other cases we call the parent method.
     */
    @Override
    public void doOperation(int operation) {
        Point selection = getTextWidget().getSelection();
        final int cursorPosition = selection.x;
        // save the last cursor position and the top visible line.
        int selectionLength = selection.y - selection.x;
        final int topLine = getTextWidget().getTopIndex();

        switch (operation) {
            case FORMAT_DOCUMENT:
                try {
                    setRedraw(false);
                    // begin recording
                    beginRecording(FORMAT_DOCUMENT_TEXT, FORMAT_DOCUMENT_TEXT,
                            cursorPosition, selectionLength);

                    // format the whole document !
                    IRegion region;
                    if (selectionLength != 0) {
                        region = new Region(cursorPosition, selectionLength);
                    }
                    else {
                        region = new Region(0, getDocument().getLength());
                    }
                    if (fContentFormatter instanceof IContentFormatterExtension) {
                        final IContentFormatterExtension extension = (IContentFormatterExtension) fContentFormatter;
                        final IFormattingContext context = new FormattingContext();
                        context.setProperty(
                                FormattingContextProperties.CONTEXT_DOCUMENT,
                                Boolean.TRUE);
                        context.setProperty(
                                FormattingContextProperties.CONTEXT_REGION,
                                region);
                        extension.format(getDocument(), context);
                    }
                    else {
                        fContentFormatter.format(getDocument(), region);
                    }
                } finally {
                    // end recording
                    selection = getTextWidget().getSelection();

                    selectionLength = selection.y - selection.x;
                    endRecording(cursorPosition, selectionLength);
                    // return the cursor to its original position after the
                    // formatter change its position.
                    getTextWidget().setSelection(cursorPosition);
                    getTextWidget().setTopIndex(topLine);
                    setRedraw(true);
                }
                return;

            case PASTE:
                super.doOperation(operation);
                return;

            case CONTENTASSIST_PROPOSALS:
                super.doOperation(operation);
                return;

            case SHOW_OUTLINE:
                if (fOutlinePresenter != null) {
                    fOutlinePresenter.showInformation();
                }
                return;

            case SHIFT_LEFT:
                shift(false, false, true);
                return;

            case SHOW_HIERARCHY:
                if (fHierarchyPresenter != null) {
                    fHierarchyPresenter.showInformation();
                }
                return;

            case DELETE:
                final StyledText textWidget = getTextWidget();
                if (textWidget == null) {
                    return;
                }
                ITextSelection textSelection = null;
                if (redraws()) {
                    try {
                        textSelection = (ITextSelection) getSelection();
                        final int length = textSelection.getLength();
                        if (!textWidget.getBlockSelection()
                                && (length == 0 || length == textWidget
                                        .getSelectionRange().y)) {
                            getTextWidget().invokeAction(ST.DELETE_NEXT);
                        }
                        else {
                            deleteSelection(textSelection, textWidget);
                        }

                        if (fFireSelectionChanged) {
                            final Point range = textWidget.getSelectionRange();
                            fireSelectionChanged(range.x, range.y);
                        }

                    } catch (final BadLocationException x) {
                        // ignore
                    }
                }
                return;
        }

        super.doOperation(operation);
    }

    public void setFireSelectionChanged(boolean fireSelectionChanged) {
        this.fFireSelectionChanged = fireSelectionChanged;
    }

    /**
     * Deletes the selection and sets the caret before the deleted range.
     * 
     * @param selection
     *            the selection to delete
     * @param textWidget
     *            the widget
     * @throws BadLocationException
     *             on document access failure
     * @since 3.5
     */
    private void deleteSelection(ITextSelection selection, StyledText textWidget)
            throws BadLocationException {
        new SelectionProcessor(this).doDelete(selection);
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.wst.sse.ui.internal.StructuredTextViewer#canDoOperation(int)
     */
    @Override
    public boolean canDoOperation(int operation) {
        if (operation == SHOW_HIERARCHY) {
            return fHierarchyPresenter != null;
        }
        if (operation == SHOW_OUTLINE) {
            return fOutlinePresenter != null;
        }
        return super.canDoOperation(operation);
    }

    private void beginRecording(String label, String description,
            int cursorPosition, int selectionLength) {
        final IDocument doc = getDocument();
        if (doc instanceof IStructuredDocument) {
            final IStructuredDocument structuredDocument = (IStructuredDocument) doc;
            final IStructuredTextUndoManager undoManager = structuredDocument
                    .getUndoManager();
            undoManager.beginRecording(this, label, description,
                    cursorPosition, selectionLength);
        }
        else {
            // TODO: how to handle other document types?
        }
    }

    private void endRecording(int cursorPosition, int selectionLength) {
        final IDocument doc = getDocument();
        if (doc instanceof IStructuredDocument) {
            final IStructuredDocument structuredDocument = (IStructuredDocument) doc;
            final IStructuredTextUndoManager undoManager = structuredDocument
                    .getUndoManager();
            undoManager.endRecording(this, cursorPosition, selectionLength);
        }
        else {
            // TODO: how to handle other document types?
        }
    }

    @Override
    protected IDocumentAdapter createDocumentAdapter() {
        documentAdapter = new StructuredDocumentToTextAdapterForPhp(
                getTextWidget());
        return documentAdapter;
    }

    public IDocumentAdapter getDocumentAdapter() {
        return documentAdapter;
    }

    /**
     * (non-Javadoc)
     * 
     * @see org.eclipse.jface.text.source.projection.ProjectionViewer#addVerticalRulerColumn(org.eclipse.jface.text.source.IVerticalRulerColumn)
     * 
     *      This method is only called to add Projection ruler column. It's
     *      actually a hack to override Projection presentation (information
     *      control) in order to enable syntax highlighting /
     * @Override public void addVerticalRulerColumn(IVerticalRulerColumn column)
     *           { // bug #210211 fix if (fProjectionAnnotationHover == null) {
     *           fProjectionAnnotationHover = new
     *           PHPStructuredTextProjectionAnnotationHover(); }
     *           ((AnnotationRulerColumn)
     *           column).setHover(fProjectionAnnotationHover);
     *           super.addVerticalRulerColumn(column); }
     */
    public class StructuredDocumentToTextAdapterForPhp extends
            StructuredDocumentToTextAdapter {

        public StructuredDocumentToTextAdapterForPhp() {
            super();
        }

        public StructuredDocumentToTextAdapterForPhp(StyledText styledTextWidget) {
            super(styledTextWidget);
        }

        @Override
        protected void redrawRegionChanged(
                RegionChangedEvent structuredDocumentEvent) {
            if (structuredDocumentEvent != null
                    && structuredDocumentEvent.getRegion() != null
                    && structuredDocumentEvent.getRegion().getType() == PHPRegionContext.PHP_CONTENT) {
                final IPhpScriptRegion region = (IPhpScriptRegion) structuredDocumentEvent
                        .getRegion();
                if (region.isFullReparsed()) {
                    final TextRegionListImpl newList = new TextRegionListImpl();
                    newList.add(region);
                    final IStructuredDocumentRegion structuredDocumentRegion = structuredDocumentEvent
                            .getStructuredDocumentRegion();
                    final IStructuredDocument structuredDocument = structuredDocumentEvent
                            .getStructuredDocument();
                    final RegionsReplacedEvent regionsReplacedEvent = new RegionsReplacedEvent(
                            structuredDocument, structuredDocumentRegion,
                            structuredDocumentRegion, null, newList, null, 0, 0);
                    redrawRegionsReplaced(regionsReplacedEvent);
                }
                else {
                    region.setFullReparsed(true);
                }
            }
            super.redrawRegionChanged(structuredDocumentEvent);
        }
    }

    /**
     * We override this function in order to use content assist for php and not
     * use the default one dictated by StructuredTextViewerConfiguration
     */
    @Override
    public void configure(SourceViewerConfiguration configuration) {

        super.configure(configuration);
        /**
         * // release old annotation hover before setting new one if
         * (fAnnotationHover instanceof StructuredTextAnnotationHover) {
         * ((StructuredTextAnnotationHover) fAnnotationHover).release(); } //
         * set PHP fAnnotationHover and initial the AnnotationHoverManager
         * setAnnotationHover(new PHPStructuredTextAnnotationHover());
         * 
         * ensureAnnotationHoverManagerInstalled();
         * 
         * if (!(configuration instanceof PHPStructuredTextViewerConfiguration))
         * { return; } fViewerConfiguration = configuration;
         * 
         * final PHPStructuredTextViewerConfiguration phpConfiguration =
         * (PHPStructuredTextViewerConfiguration) configuration; final
         * IContentAssistant newPHPAssistant = phpConfiguration
         * .getPHPContentAssistant(this, true);
         * 
         * // Uninstall content assistant created in super: if
         * (fContentAssistant != null) { fContentAssistant.uninstall(); }
         * 
         * // Assign, and configure our content assistant: fContentAssistant =
         * newPHPAssistant; if (fContentAssistant != null) {
         * fContentAssistant.install(this); fContentAssistantInstalled = true; }
         * else { // 248036 - disable the content assist operation if no content
         * // assistant enableOperation(CONTENTASSIST_PROPOSALS, false); }
         * 
         * fOutlinePresenter = phpConfiguration.getOutlinePresenter(this); if
         * (fOutlinePresenter != null) { fOutlinePresenter.install(this); }
         * 
         * fHierarchyPresenter = phpConfiguration .getHierarchyPresenter(this,
         * true); if (fHierarchyPresenter != null) {
         * fHierarchyPresenter.install(this); }
         */
    }

    /*
     * (non-Javadoc)
     * @see org.eclipse.wst.sse.ui.internal.StructuredTextViewer#unconfigure()
     */
    @Override
    public void unconfigure() {
        if (fHierarchyPresenter != null) {
            fHierarchyPresenter.uninstall();
            fHierarchyPresenter = null;
        }
        if (fOutlinePresenter != null) {
            fOutlinePresenter.uninstall();
            fOutlinePresenter = null;
        }
        super.unconfigure();
    }

    /**
     * override the parent method to prevent initialization of wrong
     * fAnnotationHover specific instance /
     * 
     * @Override protected void ensureAnnotationHoverManagerInstalled() { if
     *           (fAnnotationHover instanceof PHPStructuredTextAnnotationHover)
     *           { super.ensureAnnotationHoverManagerInstalled(); } }
     */

    /**
     * (non-Javadoc)
     * 
     * @see org.eclipse.wst.sse.ui.internal.StructuredTextViewer#modelLine2WidgetLine(int)
     *      Workaround for bug #195600 IllegalState is thrown by
     *      {@link ProjectionMapping#toImageLine(int)}
     */
    @Override
    public int modelLine2WidgetLine(int modelLine) {
        try {
            return super.modelLine2WidgetLine(modelLine);
        } catch (final IllegalStateException e) {
            return -1;
        }
    }

    /**
     * (non-Javadoc)
     * 
     * @see org.eclipse.jface.text.TextViewer#getClosestWidgetLineForModelLine(int)
     *      Workaround for bug #195600 IllegalState is thrown by
     *      {@link ProjectionMapping#toImageLine(int)}
     */
    @Override
    protected int getClosestWidgetLineForModelLine(int modelLine) {
        try {
            return super.getClosestWidgetLineForModelLine(modelLine);
        } catch (final IllegalStateException e) {
            return -1;
        }
    }

    /**
     * Reconciles the whole document (to re-run PHPValidator)
     */
    public void reconcile() {
        ((StructuredRegionProcessor) fReconciler)
                .processDirtyRegion(new DirtyRegion(0, getDocument()
                        .getLength(), DirtyRegion.INSERT, getDocument().get()));

    }

    /**
     * Sets the given reconciler.
     * 
     * @param reconciler
     *            the reconciler
     * 
     */
    void setReconciler(IReconciler reconciler) {
        fReconciler = reconciler;
    }

    /**
     * Returns the reconciler.
     * 
     * @return the reconciler or <code>null</code> if not set
     * 
     */
    IReconciler getReconciler() {
        return fReconciler;
    }

    /**
     * Prepends the text presentation listener at the beginning of the viewer's
     * list of text presentation listeners. If the listener is already
     * registered with the viewer this call moves the listener to the beginning
     * of the list.
     * 
     * @param listener
     *            the text presentation listener
     * @since 3.0
     */
    @Override
    public void prependTextPresentationListener(
            ITextPresentationListener listener) {

        Assert.isNotNull(listener);

        if (fTextPresentationListeners == null) {
            fTextPresentationListeners = new ArrayList();
        }

        fTextPresentationListeners.remove(listener);
        fTextPresentationListeners.add(0, listener);
    }

    /**
     * Sends out a text selection changed event to all registered listeners and
     * registers the selection changed event to be sent out to all post
     * selection listeners.
     * 
     * @param offset
     *            the offset of the newly selected range in the visible document
     * @param length
     *            the length of the newly selected range in the visible document
     */
    @Override
    protected void selectionChanged(int offset, int length) {
        if (fFireSelectionChanged) {
            super.selectionChanged(offset, length);
        }
    }

    public SourceViewerConfiguration getViewerConfiguration() {
        return fViewerConfiguration;
    }

    @Override
    public void setDocument(IDocument document,
            IAnnotationModel annotationModel, int modelRangeOffset,
            int modelRangeLength) {
        if (getDocument() instanceof IStructuredDocument) {
            final CommandStack commandStack = ((IStructuredDocument) getDocument())
                    .getUndoManager().getCommandStack();
            if (commandStack instanceof BasicCommandStack) {
                commandStack
                        .addCommandStackListener(getInternalCommandStackListener());
            }
        }
        super.setDocument(document, annotationModel, modelRangeOffset,
                modelRangeLength);
        if (getDocument() instanceof IStructuredDocument) {
            final CommandStack commandStack = ((IStructuredDocument) getDocument())
                    .getUndoManager().getCommandStack();
            if (commandStack instanceof BasicCommandStack) {
                commandStack
                        .addCommandStackListener(getInternalCommandStackListener());
            }
        }
    }

    private void fireDirty() {
        if (fTextEditor instanceof PHPStructuredEditor) {
            final PHPStructuredEditor phpEditor = (PHPStructuredEditor) fTextEditor;
            phpEditor.firePropertyChange(ITextEditor.PROP_DIRTY);
        }
    }

    private InternalCommandStackListener fInternalCommandStackListener;

    /**
     * @return
     */
    private CommandStackListener getInternalCommandStackListener() {
        if (fInternalCommandStackListener == null) {
            fInternalCommandStackListener = new InternalCommandStackListener();
        }
        return fInternalCommandStackListener;
    }

    class InternalCommandStackListener implements CommandStackListener {
        @Override
        public void commandStackChanged(EventObject event) {
            fireDirty();
        }
    }

}
