package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CoreVersion;
import de.guite.modulestudio.metamodel.Variable;
import de.guite.modulestudio.metamodel.Variables;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;

/**
 * Miscellaneous utility methods.
 */
@SuppressWarnings("all")
public class Utils {
  /**
   * Extensions used for formatting element names.
   */
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  /**
   * Helper methods for generator settings.
   */
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  /**
   * Returns the version number of ModuleStudio.
   * 
   * @return String The version number.
   */
  public String msVersion() {
    return "0.7.4";
  }
  
  /**
   * Returns the website url of ModuleStudio.
   * 
   * @return String The website url.
   */
  public String msUrl() {
    return "http://modulestudio.de";
  }
  
  /**
   * Creates a placeholder file in a given file path.
   * 
   * @param it The {@link Application} instance.
   * @param fsa The file system access.
   * @param path The file path.
   */
  public void createPlaceholder(final Application it, final IFileSystemAccess fsa, final String path) {
    String fileName = "README";
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("This file is a placeholder.");
    _builder.newLine();
    final String fileContent = _builder.toString();
    fsa.generateFile((path + fileName), fileContent);
  }
  
  /**
   * Returns a combined title consisting of vendor and name.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return String The formatted name.
   */
  public String vendorAndName(final Application it) {
    String _formatForCode = this._formattingExtensions.formatForCode(it.getVendor());
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    return (_formatForCode + _formatForCodeCapital);
  }
  
  /**
   * Returns the formatted name of the application.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return String The formatted name.
   */
  public String appName(final Application it) {
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus = (_formatForCodeCapital + _formatForCodeCapital_1);
    return (_plus + "Module");
  }
  
  /**
   * Returns the base namespace of the application.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return String The formatted namespace.
   */
  public String appNamespace(final Application it) {
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    String _plus = (_formatForCodeCapital + "\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus_1 = (_plus + _formatForCodeCapital_1);
    return (_plus_1 + "Module");
  }
  
  /**
   * Returns prefix for service names for this application.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return String The formatted service prefix.
   */
  public String appService(final Application it) {
    String _formatForDB = this._formattingExtensions.formatForDB(it.getVendor());
    String _plus = (_formatForDB + "_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    String _plus_1 = (_plus + _formatForDB_1);
    return (_plus_1 + "_module");
  }
  
  /**
   * Returns the lowercase application-specific prefix.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return String The prefix.
   */
  public String prefix(final Application it) {
    return this._formattingExtensions.formatForDB(it.getPrefix());
  }
  
  /**
   * Checks whether a given core version is targeted or not.
   * 
   * @param it The {@link Application} instance.
   * @param version The version in question
   * 
   * @return Boolean The result.
   */
  public Boolean targets(final Application it, final String version) {
    boolean _xblockexpression = false;
    {
      boolean _contains = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("1.4-dev", "1.5", "1.5-dev")).contains(version);
      final boolean useStable14 = (!_contains);
      boolean _switchResult = false;
      CoreVersion _coreVersion = this._generatorSettingsExtensions.getCoreVersion(it);
      if (_coreVersion != null) {
        switch (_coreVersion) {
          case ZK20:
            _switchResult = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("2.0", "1.5", "1.5-dev")).contains(version);
            break;
          case ZK15:
            _switchResult = Objects.equal(version, "1.5");
            break;
          case ZK15DEV:
            _switchResult = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("1.5", "1.5-dev")).contains(version);
            break;
          case ZK14:
            _switchResult = useStable14;
            break;
          case ZK14DEV:
            _switchResult = Objects.equal(version, "1.4-dev");
            break;
          default:
            _switchResult = useStable14;
            break;
        }
      } else {
        _switchResult = useStable14;
      }
      _xblockexpression = _switchResult;
    }
    return Boolean.valueOf(_xblockexpression);
  }
  
  /**
   * Checks whether any variables are part of the model or not.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return Boolean The result.
   */
  public boolean needsConfig(final Application it) {
    boolean _isEmpty = this.getAllVariables(it).isEmpty();
    return (!_isEmpty);
  }
  
  /**
   * Checks whether there exist multiple variables containers.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return Boolean The result.
   */
  public boolean hasMultipleConfigSections(final Application it) {
    int _size = it.getVariables().size();
    return (_size > 1);
  }
  
  /**
   * Returns the variables containers sorted by their sort order.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return List<Variables> The selected list.
   */
  public List<Variables> getSortedVariableContainers(final Application it) {
    final Function1<Variables, Integer> _function = (Variables it_1) -> {
      return Integer.valueOf(it_1.getSortOrder());
    };
    return IterableExtensions.<Variables, Integer>sortBy(it.getVariables(), _function);
  }
  
  /**
   * Returns all variables for a given application.
   * 
   * @param it The {@link Application} instance.
   * 
   * @return List<Variable> The selected list.
   */
  public List<Variable> getAllVariables(final Application it) {
    final Function1<Variables, EList<Variable>> _function = (Variables it_1) -> {
      return it_1.getVars();
    };
    return IterableExtensions.<Variable>toList(Iterables.<Variable>concat(ListExtensions.<Variables, EList<Variable>>map(it.getVariables(), _function)));
  }
  
  /**
   * Helper function for building id attributes for input fields in edit templates.
   * 
   * @param name The given name.
   * @param suffix The given suffix.
   * 
   * @return String The concatenated identifier.
   */
  public String templateIdWithSuffix(final String name, final String suffix) {
    String _xifexpression = null;
    if (((null != suffix) && (!Objects.equal(suffix, "")))) {
      _xifexpression = (((("\"" + name) + "`") + suffix) + "`\"");
    } else {
      _xifexpression = (("\'" + name) + "\'");
    }
    return _xifexpression;
  }
  
  /**
   * Returns the current timestamp to mark the generation time.
   * 
   * @return String The current timestamp.
   */
  public String timestamp() {
    long _currentTimeMillis = System.currentTimeMillis();
    return new Date(_currentTimeMillis).toString();
  }
}
