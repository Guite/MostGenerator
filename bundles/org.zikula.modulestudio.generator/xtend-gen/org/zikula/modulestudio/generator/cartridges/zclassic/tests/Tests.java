package org.zikula.modulestudio.generator.cartridges.zclassic.tests;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Tests {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  /**
   * Entry point for module unit test classes.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String testsPath = this._namingExtensions.getAppTestsPath(it);
    String fileName = "bootstrap.php";
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (testsPath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (testsPath + fileName));
      if (_shouldBeMarked) {
        fileName = "bootstrap.generated.php";
      }
      fsa.generateFile((testsPath + fileName), this.fh.phpFileContent(it, this.bootstrapImpl(it)));
    }
    fileName = "AllTests.php";
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (testsPath + fileName));
    boolean _not_1 = (!_shouldBeSkipped_1);
    if (_not_1) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (testsPath + fileName));
      if (_shouldBeMarked_1) {
        fileName = "AllTests.generated.php";
      }
      fsa.generateFile((testsPath + fileName), this.fh.phpFileContent(it, this.testSuiteImpl(it)));
    }
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
