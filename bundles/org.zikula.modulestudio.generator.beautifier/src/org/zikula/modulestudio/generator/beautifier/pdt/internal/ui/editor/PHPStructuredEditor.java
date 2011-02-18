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
import java.util.Iterator;
import java.util.List;
import java.util.ResourceBundle;

import org.eclipse.core.filebuffers.FileBuffers;
import org.eclipse.core.filebuffers.IFileBufferStatusCodes;
import org.eclipse.core.filebuffers.ITextFileBuffer;
import org.eclipse.core.filebuffers.manipulation.MultiTextEditWithProgress;
import org.eclipse.core.filebuffers.manipulation.RemoveTrailingWhitespaceOperation;
import org.eclipse.core.internal.filebuffers.Progress;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.ListenerList;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.core.runtime.Status;
import org.eclipse.dltk.core.IMember;
import org.eclipse.dltk.core.IModelElement;
import org.eclipse.dltk.core.IScriptProject;
import org.eclipse.dltk.core.ISourceModule;
import org.eclipse.dltk.core.ISourceRange;
import org.eclipse.dltk.core.ISourceReference;
import org.eclipse.dltk.core.ModelException;
import org.eclipse.dltk.core.ScriptModelUtil;
import org.eclipse.dltk.internal.ui.actions.CompositeActionGroup;
import org.eclipse.dltk.internal.ui.editor.EditorUtility;
import org.eclipse.dltk.internal.ui.editor.ExternalStorageEditorInput;
import org.eclipse.dltk.internal.ui.editor.ISavePolicy;
import org.eclipse.dltk.internal.ui.editor.ISourceModuleDocumentProvider;
import org.eclipse.dltk.internal.ui.text.IScriptReconcilingListener;
import org.eclipse.dltk.ui.DLTKUIPlugin;
import org.eclipse.emf.common.command.BasicCommandStack;
import org.eclipse.emf.common.command.CommandStack;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.internal.text.html.HTMLTextPresenter;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.text.AbstractInformationControlManager;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DefaultInformationControl;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentListener;
import org.eclipse.jface.text.IInformationControl;
import org.eclipse.jface.text.IInformationControlCreator;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextHover;
import org.eclipse.jface.text.ITextInputListener;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.ITextViewerExtension2;
import org.eclipse.jface.text.ITextViewerExtension4;
import org.eclipse.jface.text.ITextViewerExtension5;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.TextSelection;
import org.eclipse.jface.text.TextUtilities;
import org.eclipse.jface.text.information.IInformationProvider;
import org.eclipse.jface.text.information.IInformationProviderExtension;
import org.eclipse.jface.text.information.IInformationProviderExtension2;
import org.eclipse.jface.text.information.InformationPresenter;
import org.eclipse.jface.text.source.IAnnotationHover;
import org.eclipse.jface.text.source.IAnnotationHoverExtension;
import org.eclipse.jface.text.source.ILineRange;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.ISourceViewerExtension3;
import org.eclipse.jface.text.source.IVerticalRuler;
import org.eclipse.jface.text.source.IVerticalRulerInfo;
import org.eclipse.jface.text.source.SourceViewerConfiguration;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IPostSelectionProvider;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.ISelectionProvider;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.custom.TextChangeListener;
import org.eclipse.swt.custom.TextChangedEvent;
import org.eclipse.swt.custom.TextChangingEvent;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.text.edits.DeleteEdit;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IPartService;
import org.eclipse.ui.IWindowListener;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.actions.ActionGroup;
import org.eclipse.ui.editors.text.EditorsUI;
import org.eclipse.ui.texteditor.ChainedPreferenceStore;
import org.eclipse.ui.texteditor.IDocumentProvider;
import org.eclipse.ui.texteditor.IUpdate;
import org.eclipse.ui.texteditor.TextEditorAction;
import org.eclipse.ui.texteditor.TextNavigationAction;
import org.eclipse.ui.texteditor.TextOperationAction;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocument;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegion;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegionContainer;
import org.eclipse.wst.sse.ui.StructuredTextEditor;
import org.eclipse.wst.sse.ui.internal.SSEUIPlugin;
import org.eclipse.wst.sse.ui.internal.StructuredTextViewer;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.PHPToolkitUtil;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.ASTNode;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.ast.nodes.Program;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.dom.IImplForPhp;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.PhpSourceParser;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.IPhpScriptRegion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.partitioner.PHPPartitionTypes;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.preferences.PreferencesSupport;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.ui.PHPUIMessages;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.ui.preferences.PreferenceConstants;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.ui.viewsupport.ISelectionListenerWithAST;

public class PHPStructuredEditor extends StructuredTextEditor implements
        IPhpScriptReconcilingListener {

    private static final String ORG_ECLIPSE_PHP_UI_ACTIONS_OPEN_FUNCTIONS_MANUAL_ACTION = "org.eclipse.php.ui.actions.OpenFunctionsManualAction"; //$NON-NLS-1$

    protected PHPPairMatcher fBracketMatcher = new PHPPairMatcher(BRACKETS);
    private CompositeActionGroup fActionGroups;

    private long fLastActionsUpdate;

    /** Indicates whether the structure editor is displaying an external file */
    protected boolean isExternal;

    /** The editor's save policy */
    protected ISavePolicy fSavePolicy = null;

    /**
     * The internal shell activation listener for updating occurrences.
     * 
     * @since 3.4
     */
    private final ActivationListener fActivationListener = new ActivationListener();
    private ISelectionListenerWithAST fPostSelectionListenerWithAST;
    // private OccurrencesFinderJob fOccurrencesFinderJob;
    /** The occurrences finder job canceler */
    // private OccurrencesFinderJobCanceler fOccurrencesFinderJobCanceler;

    /**
     * The cached selected range.
     * 
     * @see ITextViewer#getSelectedRange()
     * @since 3.3
     */
    private Point fCachedSelectedRange;

    /**
     * The selection used when forcing occurrence marking through code.
     * 
     * @since 3.4 / private ISelection fForcedMarkOccurrencesSelection; /** The
     *        document modification stamp at the time when the last occurrence
     *        marking took place.
     * 
     * @since 3.4 / private final long fMarkOccurrenceModificationStamp =
     *        IDocumentExtension4.UNKNOWN_MODIFICATION_STAMP; /** The region of
     *        the word under the caret used to when computing the current
     *        occurrence markings.
     * 
     * @since 3.4 / private IRegion fMarkOccurrenceTargetRegion;
     * 
     *        /** Holds the current occurrence annotations.
     * 
     * @since 3.4 / private final Annotation[] fOccurrenceAnnotations = null;
     *        /** Tells whether all occurrences of the element at the current
     *        caret location are automatically marked in this editor.
     * 
     * @since 3.4 / private boolean fMarkOccurrenceAnnotations; /** Tells
     *        whether the occurrence annotations are sticky i.e. whether they
     *        stay even if there's no valid Java element at the current caret
     *        position. Only valid if {@link #fMarkOccurrenceAnnotations} is
     *        <code>true</code>.
     * 
     * @since 3.4 / private boolean fStickyOccurrenceAnnotations; /** Tells
     *        whether to mark type occurrences in this editor. Only valid if
     *        {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkTypeOccurrences; /** Tells whether to
     *        mark method and declaration occurrences in this editor. Only valid
     *        if {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkMethodOccurrences; /** Tells whether to
     *        mark function occurrences in this editor. Only valid if
     *        {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkFunctionOccurrences; /** Tells whether
     *        to mark constant occurrences in this editor. Only valid if
     *        {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkConstantOccurrences; /** Tells whether
     *        to mark field global variable in this editor. Only valid if
     *        {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkGlobalVariableOccurrences; /** Tells
     *        whether to mark local variable occurrences in this editor. Only
     *        valid if {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkLocalVariableOccurrences; /** Tells
     *        whether to mark exception occurrences in this editor. Only valid
     *        if {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkExceptions; /** Tells whether to mark
     *        method exits in this editor. Only valid if
     *        {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkMethodExitPoints;
     * 
     *        /** Tells whether to mark targets of <code>break</code> and
     *        <code>continue</code> statements in this editor. Only valid if
     *        {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkBreakContinueTargets;
     * 
     *        /** Tells whether to mark implementors in this editor. Only valid
     *        if {@link #fMarkOccurrenceAnnotations} is <code>true</code>.
     * 
     * @since 3.4 / private boolean fMarkImplementors;
     */
    private final boolean saveActionsEnabled = false;
    private final boolean saveActionsIgnoreEmptyLines = false;

    /**
     * The override and implements indicator manager for this editor.
     * 
     * @since 3.0
     */
    // protected OverrideIndicatorManager fOverrideIndicatorManager;

    /**
     * Stores the current IModelElement used as the outline input.
     */
    private IModelElement fModelElement;

    /**
     * Tells whether text drag and drop has been installed on the control.
     * 
     * @since 3.3
     */
    private final boolean fIsTextDragAndDropInstalled = false;

    /**
     * Helper token to decide whether drag and drop happens inside the same
     * editor.
     * 
     * @since 3.3
     */
    private Object fTextDragAndDropToken;

    /**
     * we use this for updating the code folding listeners and other things
     */
    // private PHPFoldingStructureProviderProxy fProjectionModelUpdater;

    /**
     * mark if we have installed the projectionSupport.
     */
    private final boolean projectionSupportInstalled = false;

    /**
     * Internal implementation class for a change listener.
     * 
     * @since 3.0
     */
    protected abstract class AbstractSelectionChangedListener implements
            ISelectionChangedListener {

        /**
         * Installs this selection changed listener with the given selection
         * provider. If the selection provider is a post selection provider,
         * post selection changed events are the preferred choice, otherwise
         * normal selection changed events are requested.
         * 
         * @param selectionProvider
         */
        public void install(ISelectionProvider selectionProvider) {
            if (selectionProvider == null) {
                return;
            }

            if (selectionProvider instanceof IPostSelectionProvider) {
                final IPostSelectionProvider provider = (IPostSelectionProvider) selectionProvider;
                provider.addPostSelectionChangedListener(this);
            }
            else {
                selectionProvider.addSelectionChangedListener(this);
            }
        }

        /**
         * Removes this selection changed listener from the given selection
         * provider.
         * 
         * @param selectionProvider
         *            the selection provider
         */
        public void uninstall(ISelectionProvider selectionProvider) {
            if (selectionProvider == null) {
                return;
            }

            if (selectionProvider instanceof IPostSelectionProvider) {
                final IPostSelectionProvider provider = (IPostSelectionProvider) selectionProvider;
                provider.removePostSelectionChangedListener(this);
            }
            else {
                selectionProvider.removeSelectionChangedListener(this);
            }
        }
    }

    /**
     * Updates this editor's range indicator.
     * 
     * @since 3.0
     */
    private class EditorSelectionChangedListener extends
            AbstractSelectionChangedListener {

        /*
         * @see
         * org.eclipse.jface.viewers.ISelectionChangedListener#selectionChanged
         * (org.eclipse.jface.viewers.SelectionChangedEvent)
         */
        @Override
        public void selectionChanged(SelectionChangedEvent event) {
            // XXX: see https://bugs.eclipse.org/bugs/show_bug.cgi?id=56161
            PHPStructuredEditor.this.selectionChanged();
        }
    }

    /**
     * The editor selection changed listener.
     */
    private EditorSelectionChangedListener fEditorSelectionChangedListener;

    // private IPreferencesPropagatorListener fPhpVersionListener;
    // private IPreferenceChangeListener fPreferencesListener;

    private void doSelectionChanged(ISelection selection) {
        ISourceReference reference = null;
        final Iterator iter = ((IStructuredSelection) selection).iterator();
        while (iter.hasNext()) {
            final Object o = iter.next();
            if (o instanceof ISourceReference) {
                reference = (ISourceReference) o;
                break;
            }
        }
        if (!isActivePart() && PHPUiPlugin.getActivePage() != null) {
            PHPUiPlugin.getActivePage().bringToTop(this);
        }
        setSelection(reference, !isActivePart());

    }

    protected void doSelectionChanged(SelectionChangedEvent event) {
        final ISelection selection = event.getSelection();
        doSelectionChanged(selection);
    }

    protected void doSelectionChanged(DoubleClickEvent event) {
        final ISelection selection = event.getSelection();
        doSelectionChanged(selection);
    }

    /**
     * This action behaves in two different ways: If there is no current text
     * hover, the javadoc is displayed using information presenter. If there is
     * a current text hover, it is converted into a information presenter in
     * order to make it sticky.
     */
    class InformationDispatchAction extends TextEditorAction {

        /** The wrapped text operation action. */
        private final TextOperationAction fTextOperationAction;

        /**
         * Creates a dispatch action.
         * 
         * @param resourceBundle
         *            the resource bundle
         * @param prefix
         *            the prefix
         * @param textOperationAction
         *            the text operation action
         */
        public InformationDispatchAction(final ResourceBundle resourceBundle,
                final String prefix,
                final TextOperationAction textOperationAction) {
            super(resourceBundle, prefix, PHPStructuredEditor.this);
            if (textOperationAction == null) {
                throw new IllegalArgumentException();
            }
            fTextOperationAction = textOperationAction;
        }

        // modified version from TextViewer
        private int computeOffsetAtLocation(final ITextViewer textViewer,
                final int x, final int y) {

            final StyledText styledText = textViewer.getTextWidget();
            final IDocument document = textViewer.getDocument();

            if (document == null) {
                return -1;
            }

            try {
                int widgetOffset = styledText.getOffsetAtLocation(new Point(x,
                        y));
                final Point p = styledText.getLocationAtOffset(widgetOffset);
                if (p.x > x) {
                    widgetOffset--;
                }

                if (textViewer instanceof ITextViewerExtension5) {
                    final ITextViewerExtension5 extension = (ITextViewerExtension5) textViewer;
                    return extension.widgetOffset2ModelOffset(widgetOffset);
                }
                final IRegion visibleRegion = textViewer.getVisibleRegion();
                return widgetOffset + visibleRegion.getOffset();
            } catch (final IllegalArgumentException e) {
                return -1;
            }

        }

        /**
         * Tries to make an annotation hover focusable (or "sticky").
         * 
         * @param sourceViewer
         *            the source viewer to display the hover over
         * @param annotationHover
         *            the hover to make focusable
         * @return <code>true</code> if successful, <code>false</code> otherwise
         * @since 3.2
         */
        private boolean makeAnnotationHoverFocusable(
                final ISourceViewer sourceViewer,
                final IAnnotationHover annotationHover) {
            final IVerticalRulerInfo info = getVerticalRuler();
            final int line = info.getLineOfLastMouseButtonActivity();
            if (line == -1) {
                return false;
            }

            try {

                // compute the hover information
                Object hoverInfo;
                if (annotationHover instanceof IAnnotationHoverExtension) {
                    final IAnnotationHoverExtension extension = (IAnnotationHoverExtension) annotationHover;
                    final ILineRange hoverLineRange = extension
                            .getHoverLineRange(sourceViewer, line);
                    if (hoverLineRange == null) {
                        return false;
                    }
                    final int maxVisibleLines = Integer.MAX_VALUE; // allow any
                    // number of
                    // lines
                    // being
                    // displayed,
                    // as we
                    // support scrolling
                    hoverInfo = extension.getHoverInfo(sourceViewer,
                            hoverLineRange, maxVisibleLines);
                }
                else {
                    hoverInfo = annotationHover
                            .getHoverInfo(sourceViewer, line);
                }

                // hover region: the beginning of the concerned line to place
                // the control right over the line
                final IDocument document = sourceViewer.getDocument();
                final int offset = document.getLineOffset(line);
                final String contentType = TextUtilities.getContentType(
                        document, PHPPartitionTypes.PHP_DOC, offset, true);

                final IInformationControlCreator controlCreator = null;

                /*
                 * XXX: This is a hack to avoid API changes at the end of 3.2,
                 */
                // if
                // ("org.eclipse.jface.text.source.projection.ProjectionAnnotationHover"
                // .equals(annotationHover.getClass().getName())) {
                // controlCreator = new IInformationControlCreator() {
                // public IInformationControl createInformationControl(
                // final Shell shell) {
                // final int shellStyle = SWT.RESIZE | SWT.TOOL
                // | getOrientation();
                // final int style = SWT.V_SCROLL | SWT.H_SCROLL;
                // return new PHPSourceViewerInformationControl(shell,
                // shellStyle, style);
                // }
                // };
                // }
                // else if (annotationHover instanceof
                // IInformationProviderExtension2) {
                // controlCreator = ((IInformationProviderExtension2)
                // annotationHover)
                // .getInformationPresenterControlCreator();
                // }
                // else if (annotationHover instanceof
                // IAnnotationHoverExtension) {
                // controlCreator = ((IAnnotationHoverExtension)
                // annotationHover)
                // .getHoverControlCreator();
                // }

                final IInformationProvider informationProvider = new InformationProvider(
                        new Region(offset, 0), hoverInfo, controlCreator);

                fInformationPresenter.setOffset(offset);
                fInformationPresenter
                        .setAnchor(AbstractInformationControlManager.ANCHOR_RIGHT);
                fInformationPresenter.setMargins(4, 0); // AnnotationBarHoverManager
                // sets (5,0), minus
                // SourceViewer.GAP_SIZE_1
                fInformationPresenter.setInformationProvider(
                        informationProvider, contentType);
                fInformationPresenter.showInformation();

                return true;

            } catch (final BadLocationException e) {
                return false;
            }
        }

        /**
         * Tries to make a text hover focusable (or "sticky").
         * 
         * @param sourceViewer
         *            the source viewer to display the hover over
         * @param textHover
         *            the hover to make focusable
         * @return <code>true</code> if successful, <code>false</code> otherwise
         * @since 3.2
         */
        private boolean makeTextHoverFocusable(
                final ISourceViewer sourceViewer, final ITextHover textHover) {
            final Point hoverEventLocation = ((ITextViewerExtension2) sourceViewer)
                    .getHoverEventLocation();
            final int offset = computeOffsetAtLocation(sourceViewer,
                    hoverEventLocation.x, hoverEventLocation.y);
            if (offset == -1) {
                return false;
            }

            try {
                final IRegion hoverRegion = textHover.getHoverRegion(
                        sourceViewer, offset);
                if (hoverRegion == null) {
                    return false;
                }

                @SuppressWarnings("deprecation")
                final String hoverInfo = textHover.getHoverInfo(sourceViewer,
                        hoverRegion);

                // if (textHover instanceof IPHPTextHover) {
                // final IHoverMessageDecorator decorator = ((IPHPTextHover)
                // textHover)
                // .getMessageDecorator();
                // if (decorator != null) {
                // final String decoratedMessage = decorator
                // .getDecoratedMessage(hoverInfo);
                // if (decoratedMessage != null
                // && decoratedMessage.length() > 0) {
                // hoverInfo = decoratedMessage;
                // }
                // }
                // }

                IInformationControlCreator controlCreator = null;
                if (textHover instanceof IInformationProviderExtension2) {
                    controlCreator = ((IInformationProviderExtension2) textHover)
                            .getInformationPresenterControlCreator();
                }

                final IInformationProvider informationProvider = new InformationProvider(
                        hoverRegion, hoverInfo, controlCreator);

                fInformationPresenter.setOffset(offset);
                fInformationPresenter
                        .setAnchor(AbstractInformationControlManager.ANCHOR_BOTTOM);
                fInformationPresenter.setMargins(6, 6); // default values from
                // AbstractInformationControlManager
                final String contentType = TextUtilities.getContentType(
                        sourceViewer.getDocument(), PHPPartitionTypes.PHP_DOC,
                        offset, true);
                fInformationPresenter.setInformationProvider(
                        informationProvider, contentType);
                fInformationPresenter.showInformation();

                return true;

            } catch (final BadLocationException e) {
                return false;
            }
        }

        /*
         * @see org.eclipse.jface.action.IAction#run()
         */
        @Override
        public void run() {

            final ISourceViewer sourceViewer = getSourceViewer();
            if (sourceViewer == null) {
                fTextOperationAction.run();
                return;
            }

            if (sourceViewer instanceof ITextViewerExtension4) {
                final ITextViewerExtension4 extension4 = (ITextViewerExtension4) sourceViewer;
                if (extension4.moveFocusToWidgetToken()) {
                    return;
                }
            }

            if (sourceViewer instanceof ITextViewerExtension2) {
                // does a text hover exist?
                final ITextHover textHover = ((ITextViewerExtension2) sourceViewer)
                        .getCurrentTextHover();
                if (textHover != null
                        && makeTextHoverFocusable(sourceViewer, textHover)) {
                    return;
                }
            }

            if (sourceViewer instanceof ISourceViewerExtension3) {
                // does an annotation hover exist?
                final IAnnotationHover annotationHover = ((ISourceViewerExtension3) sourceViewer)
                        .getCurrentAnnotationHover();
                if (annotationHover != null
                        && makeAnnotationHoverFocusable(sourceViewer,
                                annotationHover)) {
                    return;
                }
            }

            // otherwise, just run the action
            fTextOperationAction.run();
        }
    }

    /**
     * Internal activation listener.
     * 
     * @since 3.0
     */
    private class ActivationListener implements IWindowListener {

        /*
         * @seeorg.eclipse.ui.IWindowListener#windowActivated(org.eclipse.ui.
         * IWorkbenchWindow)
         * @since 3.1
         */
        @Override
        public void windowActivated(IWorkbenchWindow window) {
        }

        /*
         * @seeorg.eclipse.ui.IWindowListener#windowDeactivated(org.eclipse.ui.
         * IWorkbenchWindow)
         * @since 3.1
         */
        @Override
        public void windowDeactivated(IWorkbenchWindow window) {
        }

        /*
         * @seeorg.eclipse.ui.IWindowListener#windowClosed(org.eclipse.ui.
         * IWorkbenchWindow)
         * @since 3.1
         */
        @Override
        public void windowClosed(IWorkbenchWindow window) {
        }

        /*
         * @seeorg.eclipse.ui.IWindowListener#windowOpened(org.eclipse.ui.
         * IWorkbenchWindow)
         * @since 3.1
         */
        @Override
        public void windowOpened(IWorkbenchWindow window) {
        }
    }

    /**
     * Cancels the occurrences finder job upon document changes.
     * 
     * @since 3.0
     */
    class OccurrencesFinderJobCanceler implements IDocumentListener,
            ITextInputListener {

        public void install() {
            final ISourceViewer sourceViewer = getSourceViewer();
            if (sourceViewer == null) {
                return;
            }

            final StyledText text = sourceViewer.getTextWidget();
            if (text == null || text.isDisposed()) {
                return;
            }

            sourceViewer.addTextInputListener(this);

            final IDocument document = sourceViewer.getDocument();
            if (document != null) {
                document.addDocumentListener(this);
            }
        }

        public void uninstall() {
            final ISourceViewer sourceViewer = getSourceViewer();
            if (sourceViewer != null) {
                sourceViewer.removeTextInputListener(this);
            }

            final IDocumentProvider documentProvider = getDocumentProvider();
            if (documentProvider != null) {
                final IDocument document = documentProvider
                        .getDocument(getEditorInput());
                if (document != null) {
                    document.removeDocumentListener(this);
                }
            }
        }

        /*
         * @see
         * org.eclipse.jface.text.IDocumentListener#documentAboutToBeChanged
         * (org.eclipse.jface.text.DocumentEvent)
         */
        @Override
        public void documentAboutToBeChanged(DocumentEvent event) {
            // if (fOccurrencesFinderJob != null) {
            // fOccurrencesFinderJob.doCancel();
            // }
        }

        /*
         * @see
         * org.eclipse.jface.text.IDocumentListener#documentChanged(org.eclipse
         * .jface.text.DocumentEvent)
         */
        @Override
        public void documentChanged(DocumentEvent event) {
        }

        /*
         * @see
         * org.eclipse.jface.text.ITextInputListener#inputDocumentAboutToBeChanged
         * (org.eclipse.jface.text.IDocument, org.eclipse.jface.text.IDocument)
         */
        @Override
        public void inputDocumentAboutToBeChanged(IDocument oldInput,
                IDocument newInput) {
            if (oldInput == null) {
                return;
            }

            oldInput.removeDocumentListener(this);
        }

        /*
         * @see
         * org.eclipse.jface.text.ITextInputListener#inputDocumentChanged(org
         * .eclipse.jface.text.IDocument, org.eclipse.jface.text.IDocument)
         */
        @Override
        public void inputDocumentChanged(IDocument oldInput, IDocument newInput) {
            if (newInput == null) {
                return;
            }
            newInput.addDocumentListener(this);
        }
    }

    /**
     * Information provider used to present focusable information shells.
     * 
     * @since 3.2
     */
    private static final class InformationProvider implements
            IInformationProvider, IInformationProviderExtension,
            IInformationProviderExtension2 {

        private final IInformationControlCreator fControlCreator;
        private final Object fHoverInfo;
        private final IRegion fHoverRegion;

        InformationProvider(final IRegion hoverRegion, final Object hoverInfo,
                final IInformationControlCreator controlCreator) {
            fHoverRegion = hoverRegion;
            fHoverInfo = hoverInfo;
            fControlCreator = controlCreator;
        }

        /*
         * @see
         * org.eclipse.jface.text.information.IInformationProvider#getInformation
         * (org.eclipse.jface.text.ITextViewer, org.eclipse.jface.text.IRegion)
         */
        @Override
        public String getInformation(final ITextViewer textViewer,
                final IRegion subject) {
            return fHoverInfo.toString();
        }

        /*
         * @see
         * org.eclipse.jface.text.information.IInformationProviderExtension#
         * getInformation2(org.eclipse.jface.text.ITextViewer,
         * org.eclipse.jface.text.IRegion)
         * @since 3.2
         */
        @Override
        public Object getInformation2(final ITextViewer textViewer,
                final IRegion subject) {
            return fHoverInfo;
        }

        /*
         * @see
         * org.eclipse.jface.text.information.IInformationProviderExtension2
         * #getInformationPresenterControlCreator()
         */
        @Override
        public IInformationControlCreator getInformationPresenterControlCreator() {
            return fControlCreator;
        }

        /*
         * @see
         * org.eclipse.jface.text.information.IInformationProvider#getSubject
         * (org.eclipse.jface.text.ITextViewer, int)
         */
        @Override
        public IRegion getSubject(final ITextViewer textViewer,
                final int invocationOffset) {
            return fHoverRegion;
        }
    }

    /**
     * iterate over regions in case of PhpScriptRegion reparse the region. in
     * case of region contaioner iterate over the container regions.
     * 
     * @param doc
     *            structured document
     * @param regionsIt
     *            regions iterator
     * @param offset
     *            the container region start offset
     * @throws BadLocationException
     */
    private void reparseRegion(IDocument doc, Iterator regionsIt, int offset)
            throws BadLocationException {
        while (regionsIt.hasNext()) {
            final ITextRegion region = (ITextRegion) regionsIt.next();
            if (region instanceof ITextRegionContainer) {
                reparseRegion(doc, ((ITextRegionContainer) region).getRegions()
                        .iterator(), offset + region.getStart());
            }
            if (region instanceof IPhpScriptRegion) {
                final IPhpScriptRegion phpRegion = (IPhpScriptRegion) region;
                try {
                    phpRegion.completeReparse(doc, offset + region.getStart(),
                            region.getLength());
                } catch (final Error e) {
                    // catch Error from PhpLexer.zzScanError
                    // without doing this,the editor will behavior unnormal
                    PHPUiPlugin.log(e);
                }

            }
        }
    }

    /** Cursor dependent actions. */
    private final List<String> fCursorActions = new ArrayList<String>(5);

    /** The information presenter. */
    protected InformationPresenter fInformationPresenter;

    public PHPStructuredEditor() {
        final boolean foldingEnabled = false;
        setDocumentProvider(DLTKUIPlugin.getDocumentProvider());
    }

    // added by zhaozw,or there will be a exception for files in the phar
    @Override
    protected void setDocumentProvider(IEditorInput input) {
        setDocumentProvider(DLTKUIPlugin.getDocumentProvider());
    }

    @Override
    public void init(IEditorSite site, IEditorInput input)
            throws PartInitException {
        if (input instanceof IFileEditorInput) {
            // This is the existing workspace file
            final IFileEditorInput fileInput = (IFileEditorInput) input;
            input = new RefactorableFileEditorInput(fileInput.getFile());
        }
        super.init(site, input);
    }

    @Override
    protected void initializeEditor() {
        super.initializeEditor();

        final IPreferenceStore store = createCombinedPreferenceStore();
        setPreferenceStore(store);
    }

    /**
     * Create a preference store that combines the source editor preferences
     * with the base editor's preferences.
     * 
     * @return IPreferenceStore
     */
    private IPreferenceStore createCombinedPreferenceStore() {
        final IPreferenceStore sseEditorPrefs = SSEUIPlugin.getDefault()
                .getPreferenceStore();
        final IPreferenceStore baseEditorPrefs = EditorsUI.getPreferenceStore();
        /*
         * final IPreferenceStore phpEditorPrefs = PHPUiPlugin.getDefault()
         * .getPreferenceStore();
         */
        return new ChainedPreferenceStore(new IPreferenceStore[] {
                sseEditorPrefs, baseEditorPrefs /* , phpEditorPrefs */});
    }

    @Override
    public void dispose() {
        if (fActionGroups != null) {
            fActionGroups.dispose();
            fActionGroups = null;
        }
        if (fInformationPresenter != null) {
            fInformationPresenter.dispose();
            fInformationPresenter = null;
        }

        if (fActivationListener != null) {
            PlatformUI.getWorkbench().removeWindowListener(fActivationListener);
            // fActivationListener = null;
        }

        super.dispose();
    }

    /**
     * Text navigation action to navigate to the next sub-word.
     */
    protected abstract class NextSubWordAction extends TextNavigationAction {

        /**
         * Creates a new next sub-word action.
         * 
         * @param code
         *            Action code for the default operation. Must be an action
         *            code from
         * @see org.eclipse.swt.custom.ST.
         */
        protected NextSubWordAction(int code) {
            super(getSourceViewer().getTextWidget(), code);
        }
    }

    /**
     * Returns the standard action group of this editor.
     * 
     * @return returns this editor's standard action group
     */
    public ActionGroup getActionGroup() {
        return fActionGroups;
    }

    @Override
    public void createPartControl(final Composite parent) {
        super.createPartControl(parent);

        final IInformationControlCreator informationControlCreator = new IInformationControlCreator() {
            @SuppressWarnings("deprecation")
            @Override
            public IInformationControl createInformationControl(Shell shell) {
                final boolean cutDown = false;
                final int style = cutDown ? SWT.NONE : SWT.V_SCROLL
                        | SWT.H_SCROLL;
                return new DefaultInformationControl(shell, SWT.RESIZE
                        | SWT.TOOL, style, new HTMLTextPresenter(cutDown));
            }
        };

        fInformationPresenter = new InformationPresenter(
                informationControlCreator);
        fInformationPresenter.setSizeConstraints(60, 10, true, true);
        fInformationPresenter.install(getSourceViewer());

        // bug fix - #154817
        final StyledText styledText = getTextViewer().getTextWidget();
        styledText.getContent().addTextChangeListener(new TextChangeListener() {

            @Override
            public void textChanging(TextChangingEvent event) {
            }

            @Override
            public void textChanged(TextChangedEvent event) {
            }

            @Override
            public void textSet(TextChangedEvent event) {
                refreshViewer();
            }

        });

        fEditorSelectionChangedListener = new EditorSelectionChangedListener();
        fEditorSelectionChangedListener.install(getSelectionProvider());
        PlatformUI.getWorkbench().addWindowListener(fActivationListener);
    }

    private void refreshViewer() {
        Display.getDefault().asyncExec(new Runnable() {
            @Override
            public void run() {
                final StructuredTextViewer viewer = getTextViewer();
                if (viewer != null) {
                    viewer.getTextWidget().redraw();
                }
            }
        });

    }

    @Override
    protected void doSetInput(IEditorInput input) throws CoreException {
        IResource resource = null;
        isExternal = false;

        if (input instanceof IFileEditorInput) {
            // This is the existing workspace file
            final IFileEditorInput fileInput = (IFileEditorInput) input;
            resource = fileInput.getFile();
            if (getRefactorableFileEditorInput() != null
                    && (getRefactorableFileEditorInput()).isRefactor()) {
                getRefactorableFileEditorInput().setRefactor(false);
                getDocumentProvider().disconnect(
                        getRefactorableFileEditorInput());
                getRefactorableFileEditorInput().setFile(fileInput.getFile());
                input = getRefactorableFileEditorInput();
            }
            else {
                input = new RefactorableFileEditorInput(fileInput.getFile());
            }

        }

        if (resource instanceof IFile) {
            if (PHPToolkitUtil.isPhpFile((IFile) resource)) {

                PhpSourceParser.editFile.set(resource);

                super.doSetInput(input);

                // initPHPVersionsListener();

            }
            else {
                super.doSetInput(input);
            }
        }
        else {
            isExternal = true;
            super.doSetInput(input);
        }

        final ImageDescriptor imageDescriptor = input.getImageDescriptor();
        if (imageDescriptor != null) {
            setTitleImage(JFaceResources.getResources().createImageWithDefault(
                    imageDescriptor));
        }
    }

    @Override
    protected boolean canHandleMove(IEditorInput originalElement,
            IEditorInput movedElement) {
        if (getRefactorableFileEditorInput() != null) {
            getRefactorableFileEditorInput().setRefactor(true);
        }
        return super.canHandleMove(originalElement, movedElement);
    }

    private RefactorableFileEditorInput getRefactorableFileEditorInput() {
        if (getEditorInput() instanceof RefactorableFileEditorInput) {
            return (RefactorableFileEditorInput) getEditorInput();
        }
        return null;
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object getAdapter(Class required) {

        final Object adapter = super.getAdapter(required);
        return adapter;
    }

    protected void clearStatusLine() {
        setStatusLineErrorMessage(null);
        setStatusLineMessage(null);
    }

    public SourceViewerConfiguration getSourceViwerConfiguration() {
        return super.getSourceViewerConfiguration();
    }

    /**
     * Returns the cached selected range, which allows to query it from a non-UI
     * thread.
     * <p>
     * The result might be outdated if queried from a non-UI thread.</em>
     * </p>
     * 
     * @return the caret offset in the master document
     * @see ITextViewer#getSelectedRange()
     * @since 3.3
     */
    public Point getCachedSelectedRange() {
        return fCachedSelectedRange;
    }

    /*
     * (non-Javadoc)
     * @see
     * org.eclipse.wst.sse.ui.StructuredTextEditor#handleCursorPositionChanged()
     */
    @Override
    protected void handleCursorPositionChanged() {
        updateCursorDependentActions();
        fCachedSelectedRange = getTextViewer().getSelectedRange();
        super.handleCursorPositionChanged();
    }

    @Override
    protected void handlePreferenceStoreChanged(final PropertyChangeEvent event) {
        final String property = event.getProperty();
        try {
            boolean newBooleanValue = false;
            final Object newValue = event.getNewValue();
            if (newValue != null) {
                newBooleanValue = Boolean.valueOf(newValue.toString())
                        .booleanValue();
            }
        } finally {
            super.handlePreferenceStoreChanged(event);
        }
    }

    /**
     * Returns the boolean preference for the given key.
     * 
     * @param store
     *            the preference store
     * @param key
     *            the preference key
     * @return <code>true</code> if the key exists in the store and its value is
     *         <code>true</code>
     * @since 3.0
     */
    private boolean getBoolean(IPreferenceStore store, String key) {
        return key != null && store.getBoolean(key);
    }

    @Override
    protected void initializeKeyBindingScopes() {
        //setKeyBindingScopes(new String[] { "org.eclipse.php.ui.phpEditorScope" }); //$NON-NLS-1$
    }

    /**
     * Marks or unmarks the given action to be updated on text cursor position
     * changes.
     * 
     * @param actionId
     *            the action id
     * @param mark
     *            <code>true</code> if the action is cursor position dependent
     */
    public void markAsCursorDependentAction(final String actionId,
            final boolean mark) {
        assert actionId != null;
        if (mark) {
            if (!fCursorActions.contains(actionId)) {
                fCursorActions.add(actionId);
            }
        }
        else {
            fCursorActions.remove(actionId);
        }
    }

    public IDocument getDocument() {
        if (getSourceViewer() != null) {
            return getSourceViewer().getDocument();
        }
        return null;
    }

    /**
     * Updates the specified action by calling <code>IUpdate.update</code> if
     * applicable.
     * 
     * @param actionId
     *            the action id
     */
    private void updateAction(final String actionId) {
        assert actionId != null;
        final IAction action = getAction(actionId);
        if (action instanceof IUpdate) {
            ((IUpdate) action).update();
        }
    }

    /**
     * Updates all cursor position dependent actions.
     */
    protected void updateCursorDependentActions() {
        if (fCursorActions != null) {

            final long currentTime = System.currentTimeMillis();
            if (fLastActionsUpdate > currentTime - 1000) { // only allow updates
                // at most once per
                // second
                return;
            }
            fLastActionsUpdate = currentTime;

            final Iterator<String> e = fCursorActions.iterator();
            while (e.hasNext()) {
                updateAction(e.next());
            }
        }
    }

    @Override
    protected StructuredTextViewer createStructedTextViewer(Composite parent,
            IVerticalRuler verticalRuler, int styles) {
        return new PHPStructuredTextViewer(this, parent, verticalRuler,
                getOverviewRuler(), isOverviewRulerVisible(), styles);
    }

    /*
     * @see org.eclipse.ui.texteditor.AbstractTextEditor#performSave(boolean,
     * org.eclipse.core.runtime.IProgressMonitor)
     */
    @Override
    protected void performSave(boolean overwrite,
            IProgressMonitor progressMonitor) {
        final IDocumentProvider p = getDocumentProvider();
        if (p instanceof ISourceModuleDocumentProvider) {
            final ISourceModuleDocumentProvider cp = (ISourceModuleDocumentProvider) p;
            cp.setSavePolicy(fSavePolicy);
        }
        try {
            super.performSave(overwrite, progressMonitor);
        } finally {
            if (p instanceof ISourceModuleDocumentProvider) {
                final ISourceModuleDocumentProvider cp = (ISourceModuleDocumentProvider) p;
                cp.setSavePolicy(null);
            }
        }
    }

    @Override
    public IDocumentProvider getDocumentProvider() {
        if (getEditorInput() instanceof ExternalStorageEditorInput) {
            final IDocumentProvider provider = LocalStorageModelProvider
                    .getInstance();
            if (provider != null) {
                return provider;
            }
        }
        return super.getDocumentProvider();
    }

    /**
     * IScriptReconcilingListener methods - reconcile listeners
     */
    private final ListenerList fReconcilingListeners = new ListenerList(
            ListenerList.IDENTITY);

    public void addReconcileListener(
            IPhpScriptReconcilingListener reconcileListener) {
        synchronized (fReconcilingListeners) {
            fReconcilingListeners.add(reconcileListener);
        }
    }

    public void removeReconcileListener(
            IPhpScriptReconcilingListener reconcileListener) {
        synchronized (fReconcilingListeners) {
            fReconcilingListeners.remove(reconcileListener);
        }
    }

    @Override
    public void aboutToBeReconciled() {

        // Notify AST provider
        PHPUiPlugin.getDefault().getASTProvider()
                .aboutToBeReconciled((ISourceModule) getModelElement());

        // Notify listeners
        final Object[] listeners = fReconcilingListeners.getListeners();
        for (int i = 0, length = listeners.length; i < length; ++i) {
            ((IScriptReconcilingListener) listeners[i]).aboutToBeReconciled();
        }
    }

    /*
     * @see
     * org.eclipse.jdt.internal.ui.text.java.IJavaReconcilingListener#reconciled
     * (CompilationUnit, boolean, IProgressMonitor)
     * @since 3.0
     */
    @Override
    public void reconciled(Program ast, boolean forced,
            IProgressMonitor progressMonitor) {

        // see: https://bugs.eclipse.org/bugs/show_bug.cgi?id=58245
        final PHPUiPlugin phpPlugin = PHPUiPlugin.getDefault();
        if (phpPlugin == null) {
            return;
        }

        // Always notify AST provider
        final ISourceModule inputModelElement = (ISourceModule) getModelElement();
        // TODO: notify AST provider
        phpPlugin.getASTProvider().reconciled(ast, inputModelElement,
                progressMonitor);

        // Notify listeners
        final Object[] listeners = fReconcilingListeners.getListeners();
        for (int i = 0, length = listeners.length; i < length; ++i) {
            ((IPhpScriptReconcilingListener) listeners[i]).reconciled(ast,
                    forced, progressMonitor);
        }
    }

    /**
     * Returns the model element wrapped by this editors input. Most likely to
     * be the relevant source module
     * 
     * @return the model element wrapped by this editors input.
     * 
     */
    public IModelElement getModelElement() {
        return EditorUtility.getEditorInputModelElement(this, false);
    }

    /**
     * Returns the most narrow model element including the given offset.
     * 
     * @param offset
     *            the offset inside of the requested element
     * @return the most narrow model element
     */
    protected IModelElement getElementAt(int offset) {
        return getElementAt(offset, true);
    }

    /**
     * Returns the most narrow element including the given offset. If
     * <code>reconcile</code> is <code>true</code> the editor's input element is
     * reconciled in advance. If it is <code>false</code> this method only
     * returns a result if the editor's input element does not need to be
     * reconciled.
     * 
     * @param offset
     *            the offset included by the retrieved element
     * @param reconcile
     *            <code>true</code> if working copy should be reconciled
     * @return the most narrow element which includes the given offset
     */
    protected IModelElement getElementAt(int offset, boolean reconcile) {
        final ISourceModule unit = (ISourceModule) getModelElement();
        if (unit != null) {
            try {
                if (reconcile) {
                    ScriptModelUtil.reconcile(unit);
                    return unit.getElementAt(offset);
                }
                else if (unit.isConsistent()) {
                    return unit.getElementAt(offset);
                }
            } catch (final ModelException x) {
                if (!x.isDoesNotExist()) {
                    // DLTKUIPlugin.log(x.getStatus());
                    System.err.println(x.getStatus());
                    // nothing found, be tolerant and go on
                }
            }
        }
        return null;
    }

    /**
     * Returns project that holds the edited file (if any)
     * 
     * @return project or <code>null</code> if there's no one
     */
    public IScriptProject getProject() {
        final IModelElement modelElement = getModelElement();
        if (modelElement != null) {
            return modelElement.getScriptProject();
        }
        return null;
    }

    /**
     * Support mark occurrences in PHP Editor
     */

    /**
     * Checks whether or not the node is a scalar and return true only if the
     * scalar is not part of a string
     * 
     * @param node
     * @return
     */
    private boolean isScalarButNotInString(ASTNode node) {
        return (node.getType() == ASTNode.SCALAR)
                && (node.getParent().getType() != ASTNode.QUOTE);
    }

    protected boolean isActivePart() {
        final IWorkbenchPart part = getActivePart();
        return part != null && part.equals(this);
    }

    private IWorkbenchPart getActivePart() {
        final IWorkbenchWindow window = getSite().getWorkbenchWindow();
        final IPartService service = window.getPartService();
        final IWorkbenchPart part = service.getActivePart();
        return part;
    }

    /**
     * React to changed selection.
     * 
     * @since 3.0
     */
    protected void selectionChanged() {
        if (getSelectionProvider() == null) {
            return;
        }
        final ISourceReference element = computeHighlightRangeSourceReference();
        setSelection(element, false);
    }

    /**
     * Computes and returns the source reference that includes the caret and
     * serves as provider for the editor range indication.
     * 
     * @return the computed source reference
     */
    public ISourceReference computeHighlightRangeSourceReference() {
        final ISourceViewer sourceViewer = getSourceViewer();
        if (sourceViewer == null) {
            return null;
        }
        final StyledText styledText = sourceViewer.getTextWidget();
        if (styledText == null) {
            return null;
        }
        int caret = 0;
        if (sourceViewer instanceof ITextViewerExtension5) {
            final ITextViewerExtension5 extension = (ITextViewerExtension5) sourceViewer;
            caret = extension.widgetOffset2ModelOffset(styledText
                    .getCaretOffset());
        }
        else {
            final int offset = sourceViewer.getVisibleRegion().getOffset();
            caret = offset + styledText.getCaretOffset();
        }
        final IModelElement element = getElementAt(caret, false);
        if (!(element instanceof ISourceReference)) {
            return null;
        }
        return (ISourceReference) element;
    }

    protected void setSelection(ISourceReference reference, boolean moveCursor) {
        if (getSelectionProvider() == null) {
            return;
        }
        final ISelection selection = getSelectionProvider().getSelection();
        if (selection instanceof TextSelection) {
            final TextSelection textSelection = (TextSelection) selection;
            if (textSelection instanceof IStructuredSelection) {
                final Object firstElement = ((IStructuredSelection) textSelection)
                        .getFirstElement();
                if (firstElement instanceof IImplForPhp) {
                    ((IImplForPhp) firstElement)
                            .setModelElement(getModelElement());
                }
            }
            // PR 39995: [navigation] Forward history cleared after going back
            // in navigation history:
            // mark only in navigation history if the cursor is being moved
            // (which it isn't if
            // this is called from a PostSelectionEvent that should only update
            // the magnet)
            if (moveCursor
                    && (textSelection.getOffset() != 0 || textSelection
                            .getLength() != 0)) {
                markInNavigationHistory();
            }
        }
        if (reference != null) {
            StyledText textWidget = null;
            final ISourceViewer sourceViewer = getSourceViewer();
            if (sourceViewer != null) {
                textWidget = sourceViewer.getTextWidget();
            }
            if (textWidget == null) {
                return;
            }
            try {
                ISourceRange range = null;
                range = reference.getSourceRange();
                if (range == null) {
                    return;
                }
                int offset = range.getOffset();
                int length = range.getLength();
                if (offset < 0 || length < 0) {
                    return;
                }
                setHighlightRange(offset, length, moveCursor);
                if (!moveCursor) {
                    return;
                }
                offset = -1;
                length = -1;
                if (reference instanceof IMember) {
                    range = ((IMember) reference).getNameRange();
                    if (range != null) {
                        offset = range.getOffset();
                        length = range.getLength();
                    }
                }
                if (offset > -1 && length > 0) {
                    try {
                        textWidget.setRedraw(false);
                        sourceViewer.revealRange(offset, length);
                        sourceViewer.setSelectedRange(offset, length);
                    } finally {
                        textWidget.setRedraw(true);
                    }
                    markInNavigationHistory();
                }
            } catch (final ModelException x) {
            } catch (final IllegalArgumentException x) {
            }
        }
        else if (moveCursor) {
            resetHighlightRange();
            markInNavigationHistory();
        }
    }

    /*
     * Gets the preferences set for this editor in the Save Actions section
     */
    public void updateSaveActionsState(IProject project) {
        @SuppressWarnings("deprecation")
        final PreferencesSupport prefSupport = new PreferencesSupport(
                PHPUiPlugin.ID, PHPUiPlugin.getDefault().getPluginPreferences());
        final String doCleanupPref = prefSupport.getPreferencesValue(
                PreferenceConstants.FORMAT_REMOVE_TRAILING_WHITESPACES, null,
                project);
        final String ignoreEmptyPref = prefSupport
                .getPreferencesValue(
                        PreferenceConstants.FORMAT_REMOVE_TRAILING_WHITESPACES_IGNORE_EMPTY,
                        null, project);

        // saveActionsEnabled = Boolean.parseBoolean(doCleanupPref);
        // saveActionsIgnoreEmptyLines = Boolean.parseBoolean(ignoreEmptyPref);
    }

    /*
     * Added the handling of Save Actions (non-Javadoc)
     * @see
     * org.eclipse.wst.sse.ui.StructuredTextEditor#doSave(org.eclipse.core.runtime
     * .IProgressMonitor)
     */
    @Override
    public void doSave(IProgressMonitor progressMonitor) {
        if (getDocument() instanceof IStructuredDocument) {
            final CommandStack commandStack = ((IStructuredDocument) getDocument())
                    .getUndoManager().getCommandStack();
            if (commandStack instanceof BasicCommandStack) {
                ((BasicCommandStack) commandStack).saveIsDone();
            }
        }
        final IScriptProject project = getProject();
        if (project != null) {
            updateSaveActionsState(project.getProject());
        }

        if (saveActionsEnabled) {
            final RemoveTrailingWhitespaceOperation op = new ExtendedRemoveTrailingWhitespaceOperation(
                    saveActionsIgnoreEmptyLines);
            try {
                op.run(FileBuffers.getTextFileBufferManager()
                        .getTextFileBuffer(getDocument()), progressMonitor);
            } catch (final OperationCanceledException e) {
                GeneratorBeautifierPlugin.log(e);
                // Logger.logException(e);
            } catch (final CoreException e) {
                GeneratorBeautifierPlugin.log(e);
                // Logger.logException(e);
            }
        }
        super.doSave(progressMonitor);
    }

    /*
     * Operation used for removing whitepsaces from line ends
     */
    class ExtendedRemoveTrailingWhitespaceOperation extends
            RemoveTrailingWhitespaceOperation {

        // skip empty lines when removing whitespaces
        private final boolean fIgnoreEmptyLines;

        public ExtendedRemoveTrailingWhitespaceOperation(
                boolean ignoreEmptyLines) {
            super();
            fIgnoreEmptyLines = ignoreEmptyLines;
        }

        /*
         * Same as in parent, with the addition of the ability to ignore empty
         * lines - depending on the value of fIgnoreEmptyLines
         */
        @Override
        protected MultiTextEditWithProgress computeTextEdit(
                ITextFileBuffer fileBuffer, IProgressMonitor progressMonitor)
                throws CoreException {
            final IDocument document = fileBuffer.getDocument();
            final int lineCount = document.getNumberOfLines();

            progressMonitor = Progress.getMonitor(progressMonitor);
            progressMonitor
                    .beginTask(
                            PHPUIMessages
                                    .getString("RemoveTrailingWhitespaceOperation_task_generatingChanges"),
                            lineCount);
            try {

                final MultiTextEditWithProgress multiEdit = new MultiTextEditWithProgress(
                        PHPUIMessages
                                .getString("RemoveTrailingWhitespaceOperation_task_applyingChanges"));

                for (int i = 0; i < lineCount; i++) {
                    if (progressMonitor.isCanceled()) {
                        throw new OperationCanceledException();
                    }
                    final IRegion region = document.getLineInformation(i);
                    if (region.getLength() == 0) {
                        continue;
                    }
                    final int lineStart = region.getOffset();
                    final int lineExclusiveEnd = lineStart + region.getLength();
                    int j = lineExclusiveEnd - 1;
                    while (j >= lineStart
                            && Character.isWhitespace(document.getChar(j))) {
                        --j;
                    }
                    ++j;
                    // A flag for skipping empty lines, if required
                    if (fIgnoreEmptyLines && j == lineStart) {
                        continue;
                    }
                    if (j < lineExclusiveEnd) {
                        multiEdit.addChild(new DeleteEdit(j, lineExclusiveEnd
                                - j));
                    }
                    progressMonitor.worked(1);
                }

                return multiEdit.getChildrenSize() <= 0 ? null : multiEdit;

            } catch (final BadLocationException x) {
                throw new CoreException(new Status(IStatus.ERROR,
                        PHPUiPlugin.ID,
                        IFileBufferStatusCodes.CONTENT_CHANGE_FAILED, "", x)); //$NON-NLS-1$
            } finally {
                progressMonitor.done();
            }
        }
    }

    public ISourceViewer getViewer() {
        return super.getSourceViewer();
    }

    @Override
    public boolean isDirty() {
        if (getDocument() instanceof IStructuredDocument) {
            final CommandStack commandStack = ((IStructuredDocument) getDocument())
                    .getUndoManager().getCommandStack();
            if (commandStack instanceof BasicCommandStack) {
                return ((BasicCommandStack) commandStack).isSaveNeeded();
            }
        }

        return super.isDirty();
    }

    @Override
    public void firePropertyChange(int property) {
        super.firePropertyChange(property);
    }
}
