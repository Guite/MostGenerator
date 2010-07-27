package org.zikula.modulestudio.generator.beautifier.formatter;

import java.io.IOException;
import java.io.StringReader;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.wst.sse.core.StructuredModelManager;
import org.eclipse.wst.sse.core.internal.ltk.parser.BlockTokenizer;
import org.eclipse.wst.sse.core.internal.provisional.IStructuredModel;
import org.eclipse.wst.sse.core.internal.provisional.text.IStructuredDocument;
import org.eclipse.wst.sse.core.internal.provisional.text.ITextRegion;
import org.zikula.modulestudio.generator.beautifier.GeneratorBeautifierPlugin;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.PhpSourceParser;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.PHPRegionTypes;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.parser.regions.PhpScriptRegion;
import org.zikula.modulestudio.generator.beautifier.pdt.internal.core.documentModel.provisional.contenttype.ContentTypeIdForPHP;

/**
 * Based on http://de.sourceforge.jp/projects/pdt-tools/
 */
public class FormatterUtil {

	public static boolean verify(String prev, String post, IResource resource) {
		try {
			RegionReader prevReader = new RegionReader(prev);
			RegionReader postReader = new RegionReader(post);
			ITextRegion prevRegion = prevReader.getNext();
			ITextRegion postRegion = postReader.getNext();
			while (prevRegion != null && postRegion != null) {
				if (!prevRegion.getType().equals(postRegion.getType())) {
					logError("token type mismatch", prevReader, resource);
					return false;
				}
				int offset;
				offset = prevReader.getOffset();
				String prevText = prev.substring(offset, offset + prevRegion.getTextLength());
				offset = postReader.getOffset();
				String postText = post.substring(offset, offset + postRegion.getTextLength());
				if (postReader.isPhpScriptRegion()) {
					String regionType = postRegion.getType();
					if (PHPRegionTypes.PHP_COMMENT.equals(regionType)
							|| PHPRegionTypes.PHPDOC_COMMENT.equals(regionType)) {
						String prevStr = prevText.replaceAll("(\\s)*([\\n\\r])+(\\s)*", "");
						String postStr = postText.replaceAll("(\\s)*([\\n\\r])+(\\s)*", "");
						if (!prevStr.trim().equals(postStr.trim())) {
							logError("content mismatch in comment", prevReader, resource);
							return false;
						}
					} else if (PHPRegionTypes.PHP_CONSTANT_ENCAPSED_STRING.equals(regionType)
							|| PHPRegionTypes.PHP_ENCAPSED_AND_WHITESPACE.equals(regionType)) {
						String prevStr = prevText.replaceAll("(\\s)*([\\n\\r])+", "");
						String postStr = postText.replaceAll("(\\s)*([\\n\\r])+", "");
						if (!prevStr.equals(postStr)) {
							logError("content mismatch in literal", prevReader, resource);
							return false;
						}
					} else if (PHPRegionTypes.PHP_CASTING.equals(regionType)) {
						String casting = prevText.trim().replaceAll(" |\t", "");
						if (!casting.equals(postText.trim())) {
							logError("content mismatch in casting", prevReader, resource);
							return false;
						}
					} else if (PHPRegionTypes.PHP_HEREDOC_TAG.equals(regionType)) {
						if (!prevText.replaceAll(" ", "").trim().equals(postText.replaceAll(" ", "").trim())) {
							logError("content mismatch in heredoc tag", prevReader, resource);
							return false;
						}
					} else {
						if (!prevText.trim().equals(postText.trim())) {
							logError("content mismatch in token", prevReader, resource);
							return false;
						}
					}
				} else {
					if (!prevText.equals(postText)) {
						logError("content mismatch in xml", prevReader, resource);
						return false;
					}
				}
				prevRegion = prevReader.getNext();
				postRegion = postReader.getNext();
			}
			if (prevRegion != null || postRegion != null) {
				logError("unmatched regions", prevReader, resource);
				return false;
			}
			return true;
		} catch (IOException e) {
			GeneratorBeautifierPlugin.log(e);
		} catch (BadLocationException e) {
			GeneratorBeautifierPlugin.log(e);
		}
		return false;
	}

	private static void logError(String message, RegionReader reader, IResource resource) {
		String document = reader.getText();
		int offset = reader.getOffset();
		IStructuredDocument sDoc = StructuredModelManager.getModelManager()
				.createStructuredDocumentFor(ContentTypeIdForPHP.ContentTypeID_PHP);
		sDoc.set(document);
		int line = sDoc.getLineOfOffset(offset);
		String err = null;
		try {
			err = sDoc.get(sDoc.getLineOffset(line), sDoc.getLineLength(line));
		} catch (BadLocationException e) {
		}
		GeneratorBeautifierPlugin.logMessage(IStatus.ERROR, message + " on line " + (line + 1)
				+ ((err != null) ? "\n>" + err : ""));
		if (resource != null) {
			GeneratorBeautifierPlugin.logMessage(IStatus.ERROR,
					"File: " + resource.getLocation().toOSString());
		}
	}

	private static class RegionReader {
		private String string;
		private BlockTokenizer tokenizer;
		private ITextRegion currentRegion;
		private ITextRegion[] phpTokens;
		private int tokenIndex;

		public RegionReader(String string) {
			this.string = string;
			PhpSourceParser parser = new PhpSourceParser();
			parser.reset(new StringReader(string), 0);
			tokenizer = parser.getTokenizer();
		}

		public ITextRegion getNext() throws IOException, BadLocationException {
			ITextRegion region = getNextRegion();
			while (region != null) {
				int start = getOffset();
				String body = string.substring(start, start + region.getLength());
				if (!body.trim().equals("")) {
					break;
				}
				region = getNextRegion();
			}
			return region;
		}

		private ITextRegion getNextRegion() throws IOException, BadLocationException {
			if (currentRegion instanceof PhpScriptRegion) {
				if (tokenIndex < phpTokens.length) {
					return phpTokens[tokenIndex++];
				}
			}
			if (!tokenizer.isEOF()) {
				currentRegion = tokenizer.getNextToken();
				if (currentRegion instanceof PhpScriptRegion) {
					PhpScriptRegion scriptRegion = (PhpScriptRegion) currentRegion;
					phpTokens = scriptRegion.getPhpTokens(0, scriptRegion.getLength());
					tokenIndex = 0;
					return getNext();
				}
				return currentRegion;
			}
			return null;
		}

		public int getOffset() {
			int offset = currentRegion.getStart();
			if (currentRegion instanceof PhpScriptRegion) {
				offset += phpTokens[tokenIndex - 1].getStart();
			}
			return offset;
		}

		public boolean isPhpScriptRegion() {
			return currentRegion instanceof PhpScriptRegion;
		}

		public String getText() {
			return string;
		}
	}

	public static IResource getResource(IDocument document) {
		IResource resource = null;
		IStructuredModel structuredModel = null;
		try {
			structuredModel = StructuredModelManager.getModelManager()
					.getExistingModelForRead(document);
			if (structuredModel != null) {
				String location = structuredModel.getBaseLocation();
				if (location != null) {
					resource = ResourcesPlugin.getWorkspace().getRoot().getFile(
							new Path(location));
				}
			}
		} finally {
			if (structuredModel != null) {
				structuredModel.releaseFromRead();
			}
		}
		return resource;
	}

}
