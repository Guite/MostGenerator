package org.zikula.modulestudio.generator.cartridges.zclassic.tests;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Tests {
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
   * Entry point for module unit test classes.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String testsPath = this._namingExtensions.getAppTestsPath(it);
    String _plus = (testsPath + "bootstrap.php");
    CharSequence _bootstrapFile = this.bootstrapFile(it);
    fsa.generateFile(_plus, _bootstrapFile);
    String _plus_1 = (testsPath + "AllTests.php");
    CharSequence _testSuiteFile = this.testSuiteFile(it);
    fsa.generateFile(_plus_1, _testSuiteFile);
  }
  
  private CharSequence bootstrapFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _bootstrapImpl = this.bootstrapImpl(it);
    _builder.append(_bootstrapImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence testSuiteFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _testSuiteImpl = this.testSuiteImpl(it);
    _builder.append(_testSuiteImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence bootstrapImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("error_reporting(E_ALL | E_STRICT);");
    _builder.newLine();
    _builder.append("require_once \'PHPUnit/TextUI/TestRunner.php\';");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence testSuiteImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!defined(\'PHPUnit_MAIN_METHOD\')) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("define(\'PHPUnit_MAIN_METHOD\', \'AllTests::main\');");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("require_once dirname(__FILE__) . \'/bootstrap.php\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("class AllTests");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public static function main()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("PHPUnit_TextUI_TestRunner::run(self::suite());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public static function suite()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$suite = new PHPUnit_Framework_TestSuite(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append(" - All Tests\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $suite;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (PHPUnit_MAIN_METHOD == \'AllTests::main\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("AllTests::main();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
