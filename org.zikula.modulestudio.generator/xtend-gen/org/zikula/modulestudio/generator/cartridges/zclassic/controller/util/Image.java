package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Image {
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for the utility class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating utility class for image handling");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String utilPath = (_appSourceLibPath + "Util/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Util";
    }
    final String utilSuffix = _xifexpression;
    String _plus = (utilPath + "Base/Image");
    String _plus_1 = (_plus + utilSuffix);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _imageFunctionsBaseFile = this.imageFunctionsBaseFile(it);
    fsa.generateFile(_plus_2, _imageFunctionsBaseFile);
    String _plus_3 = (utilPath + "Image");
    String _plus_4 = (_plus_3 + utilSuffix);
    String _plus_5 = (_plus_4 + ".php");
    CharSequence _imageFunctionsFile = this.imageFunctionsFile(it);
    fsa.generateFile(_plus_5, _imageFunctionsFile);
  }
  
  private CharSequence imageFunctionsBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _imageFunctionsBaseImpl = this.imageFunctionsBaseImpl(it);
    _builder.append(_imageFunctionsBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence imageFunctionsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _imageFunctionsImpl = this.imageFunctionsImpl(it);
    _builder.append(_imageFunctionsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence imageFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Util\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use SystemPlugin_Imagine_Preset;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractBase;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility base class for image helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_Base_Image");
      } else {
        _builder.append("ImageUtil");
      }
    }
    _builder.append(" extends Zikula_AbstractBase");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _preset = this.getPreset(it);
    _builder.append(_preset, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _customPreset = this.getCustomPreset(it);
    _builder.append(_customPreset, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getPreset(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method returns an Imagine preset for the given arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Currently treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args       Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return SystemPlugin_Imagine_Preset The selected preset.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getPreset($objectType = \'\', $fieldName = \'\', $context = \'\', $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($context, array(\'controllerAction\', \'api\', \'actionHandler\', \'block\', \'contentType\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$context = \'controllerAction\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$presetName = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($context == \'controllerAction\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'controller\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'controller\'] = \'user\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'action\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'action\'] = \'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($args[\'controller\'] == \'ajax\' && $args[\'action\'] == \'getItemListAutoCompletion\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$presetName = $this->name . \'_ajax_autocomplete\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$presetName = $this->name . \'_\' . $args[\'controller\'] . \'_\' . $args[\'action\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($presetName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$presetName = $this->name . \'_default\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$preset = $this->getCustomPreset($objectType, $fieldName, $presetName, $context, $args);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $preset;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCustomPreset(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method returns an Imagine preset for the given arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Currently treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  Name of upload field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $presetName Name of desired preset.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args       Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return SystemPlugin_Imagine_Preset The selected preset.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getCustomPreset($objectType = \'\', $fieldName = \'\', $presetName = \'\', $context = \'\', $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$presetData = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'width\'     => 100,      // thumbnail width in pixels");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'height\'    => 100,      // thumbnail height in pixels");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'mode\'      => \'inset\',  // inset or outset");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'extension\' => null      // file extension for thumbnails (jpg, png, gif; null for original file type)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($presetName == $this->name . \'_ajax_autocomplete\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$presetData[\'width\'] = 100;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$presetData[\'height\'] = 80;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($presetName == $this->name . \'_relateditem\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$presetData[\'width\'] = 50;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$presetData[\'height\'] = 40;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($context == \'controllerAction\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($args[\'action\'] == \'view\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$presetData[\'width\'] = 32;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$presetData[\'height\'] = 20;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} elseif ($args[\'action\'] == \'display\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$presetData[\'width\'] = 250;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$presetData[\'height\'] = 150;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$preset = new SystemPlugin_Imagine_Preset($presetName, $presetData);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $preset;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence imageFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Util;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility implementation class for image helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_Image extends ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_Util_Base_Image");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ImageUtil extends Base\\ImageUtil");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own convenience methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
