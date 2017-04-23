package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action;

import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class InlineRedirect {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Entity it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _handleInlineRedirectDocBlock = this.handleInlineRedirectDocBlock(it, isBase);
    _builder.append(_handleInlineRedirectDocBlock);
    _builder.newLineIfNotEmpty();
    _builder.append("public function handleInlineRedirectAction($idPrefix, $commandName, $id = 0)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        CharSequence _handleInlineRedirectBaseImpl = this.handleInlineRedirectBaseImpl(it);
        _builder.append(_handleInlineRedirectBaseImpl, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("return parent::handleInlineRedirectAction($idPrefix, $commandName, $id);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleInlineRedirectDocBlock(final Entity it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method cares for a redirect within an inline frame.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, " ");
        _builder.append("/handleInlineRedirect/{idPrefix}/{commandName}/{id}\",");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*        requirements = {\"id\" = \"\\d+\"},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        defaults = {\"commandName\" = \"\", \"id\" = 0},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        methods = {\"GET\"}");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* )");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $idPrefix    Prefix for inline window element identifier");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $commandName Name of action to be performed (create or edit)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $id          Identifier of created ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" (used for activating auto completion after closing the modal window)");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return PlainResponse Output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleInlineRedirectBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (empty($idPrefix)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'itemId\' => $id,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'idPrefix\' => $idPrefix,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'commandName\' => $commandName");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("return new PlainResponse($this->get(\'twig\')->render(\'@");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append("/");
    String _firstUpper = StringExtensions.toFirstUpper(this._formattingExtensions.formatForCode(it.getName()));
    _builder.append(_firstUpper);
    _builder.append("/inlineRedirectHandler.html.twig\', $templateParameters));");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
