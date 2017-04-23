package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class FeatureActivationHelper {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for dynamic feature enablement");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/FeatureActivationHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.featureEnablementFunctionsBaseImpl(it)), fh.phpFileContent(it, this.featureEnablementFunctionsImpl(it)));
  }
  
  private CharSequence featureEnablementFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for dynamic feature enablement methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractFeatureActivationHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _featureConstants = this.featureConstants(it);
    _builder.append(_featureConstants, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _isEnabled = this.isEnabled(it);
    _builder.append(_isEnabled, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence featureConstants(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Categorisation feature");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("const CATEGORIES = \'categories\';");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
      if (_hasAttributableEntities) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Attribution feature");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("const ATTRIBUTES = \'attributes\';");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Translation feature");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("const TRANSLATIONS = \'translations\';");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Tree relatives feature");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("const TREE_RELATIVES = \'treeRelatives\';");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence isEnabled(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method checks whether a certain feature is enabled for a given entity type or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $feature     Name of requested feature");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType  Currently treated entity type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True if the feature is enabled, false otherwise");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function isEnabled($feature, $objectType)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("    ");
        _builder.append("if ($feature == self::CATEGORIES) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$method = \'hasCategories\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (method_exists($this, $method)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("return $this->$method($objectType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return in_array($objectType, [\'");
        final Function1<Entity, String> _function = (Entity e) -> {
          return this._formattingExtensions.formatForCode(e.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<Entity, String>map(this._modelBehaviourExtensions.getCategorisableEntities(it), _function), "\', \'");
        _builder.append(_join, "        ");
        _builder.append("\']);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
      if (_hasAttributableEntities) {
        _builder.append("    ");
        _builder.append("if ($feature == self::ATTRIBUTES) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$method = \'hasAttributes\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (method_exists($this, $method)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("return $this->$method($objectType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return in_array($objectType, [\'");
        final Function1<Entity, String> _function_1 = (Entity e) -> {
          return this._formattingExtensions.formatForCode(e.getName());
        };
        String _join_1 = IterableExtensions.join(IterableExtensions.<Entity, String>map(this._modelBehaviourExtensions.getAttributableEntities(it), _function_1), "\', \'");
        _builder.append(_join_1, "        ");
        _builder.append("\']);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.append("    ");
        _builder.append("if ($feature == self::TRANSLATIONS) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$method = \'hasTranslations\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (method_exists($this, $method)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("return $this->$method($objectType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return in_array($objectType, [\'");
        final Function1<Entity, String> _function_2 = (Entity e) -> {
          return this._formattingExtensions.formatForCode(e.getName());
        };
        String _join_2 = IterableExtensions.join(IterableExtensions.<Entity, String>map(this._modelBehaviourExtensions.getTranslatableEntities(it), _function_2), "\', \'");
        _builder.append(_join_2, "        ");
        _builder.append("\']);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.append("    ");
        _builder.append("if ($feature == self::TREE_RELATIVES) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$method = \'hasTreeRelatives\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (method_exists($this, $method)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("return $this->$method($objectType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return in_array($objectType, [\'");
        final Function1<Entity, String> _function_3 = (Entity e) -> {
          return this._formattingExtensions.formatForCode(e.getName());
        };
        String _join_3 = IterableExtensions.join(IterableExtensions.<Entity, String>map(this._modelBehaviourExtensions.getTreeEntities(it), _function_3), "\', \'");
        _builder.append(_join_3, "        ");
        _builder.append("\']);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence featureEnablementFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Helper\\Base\\AbstractFeatureActivationHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for dynamic feature enablement methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class FeatureActivationHelper extends AbstractFeatureActivationHelper");
    _builder.newLine();
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
