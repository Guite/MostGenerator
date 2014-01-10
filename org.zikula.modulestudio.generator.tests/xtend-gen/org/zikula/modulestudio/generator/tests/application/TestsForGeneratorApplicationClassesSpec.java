package org.zikula.modulestudio.generator.tests.application;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import java.util.Map;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.InMemoryFileSystemAccess;
import org.eclipse.xtext.junit4.util.ParseHelper;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.jnario.lib.Assert;
import org.jnario.lib.Should;
import org.jnario.runner.CreateWith;
import org.jnario.runner.ExampleGroupRunner;
import org.jnario.runner.Named;
import org.jnario.runner.Order;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.zikula.modulestudio.generator.tests.lib.GuiceSpecCreator;

/**
 * This class tests certain aspects of the Application meta class.
 */
@Named("Tests for generator application classes")
@RunWith(ExampleGroupRunner.class)
@CreateWith(GuiceSpecCreator.class)
@SuppressWarnings("all")
public class TestsForGeneratorApplicationClassesSpec {
  @Inject
  IGenerator generator;
  
  @Inject
  @Extension
  @org.jnario.runner.Extension
  public ParseHelper<Application> _parseHelper;
  
  InMemoryFileSystemAccess fsa;
  
  /**
   * Testing a code generator.
   */
  @Test
  @Named("First generator test")
  @Order(1)
  public void _firstGeneratorTest() throws Exception {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("application SimpleNews {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("documentation \'Simple news extension\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("vendor \'Guite\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("author \'Axel Guckelsberger\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("email \'info@guite.de\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("url \'http://guite.de\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("prefix \'sinew\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("modelLayer {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("modelContainer Models {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("controllingLayer {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("controllerContainer Controller {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("modelContext ( \'SimpleNews.Model\' )");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("processViews = \'SimpleNews.Views\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("viewLayer {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("viewContainer Views {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("controller \'SimpleNews.Controller\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    final Application app = this._parseHelper.parse(_builder);
    InMemoryFileSystemAccess _inMemoryFileSystemAccess = new InMemoryFileSystemAccess();
    this.fsa = _inMemoryFileSystemAccess;
    Resource _eResource = app.eResource();
    this.generator.doGenerate(_eResource, this.fsa);
    InputOutput.<String>println("Binary files:");
    Map<String,byte[]> _binaryFiles = this.fsa.getBinaryFiles();
    InputOutput.<Map<String,byte[]>>println(_binaryFiles);
    InputOutput.<String>println("Text files:");
    Map<String,CharSequence> _textFiles = this.fsa.getTextFiles();
    InputOutput.<Map<String,CharSequence>>println(_textFiles);
    Map<String,CharSequence> _textFiles_1 = this.fsa.getTextFiles();
    int _size = _textFiles_1.size();
    boolean _should_be = Should.<Integer>should_be(Integer.valueOf(_size), Integer.valueOf(0));
    Assert.assertFalse("\nExpected fsa.textFiles.size should not be 0 but"
     + "\n     fsa.textFiles.size is " + new org.hamcrest.StringDescription().appendValue(Integer.valueOf(_size)).toString()
     + "\n     fsa.textFiles is " + new org.hamcrest.StringDescription().appendValue(_textFiles_1).toString()
     + "\n     fsa is " + new org.hamcrest.StringDescription().appendValue(this.fsa).toString() + "\n", _should_be);
    
    StringConcatenation _builder_1 = new StringConcatenation();
    _builder_1.append("here comes the expected output");
    _builder_1.newLine();
    this.checkTextFile("bootstrap.php", _builder_1.toString());
    StringConcatenation _builder_2 = new StringConcatenation();
    _builder_2.append("public class SomeClass");
    _builder_2.newLine();
    _builder_2.append("{");
    _builder_2.newLine();
    _builder_2.append("     ");
    _builder_2.append("// expected code");
    _builder_2.newLine();
    _builder_2.append("}");
    _builder_2.newLine();
    this.checkTextFile("SomeClass.php", _builder_2.toString());
  }
  
  private boolean checkTextFile(final String fileName, final String content) {
    boolean _xblockexpression = false;
    {
      final String filePath = (IFileSystemAccess.DEFAULT_OUTPUT + fileName);
      Map<String,CharSequence> _textFiles = this.fsa.getTextFiles();
      boolean _containsKey = _textFiles.containsKey(filePath);
      boolean _should_be = Should.<Boolean>should_be(Boolean.valueOf(_containsKey), true);
      Assert.assertTrue("\nExpected fsa.textFiles.containsKey(filePath) should be true but"
       + "\n     fsa.textFiles.containsKey(filePath) is " + new org.hamcrest.StringDescription().appendValue(Boolean.valueOf(_containsKey)).toString()
       + "\n     fsa.textFiles is " + new org.hamcrest.StringDescription().appendValue(_textFiles).toString()
       + "\n     fsa is " + new org.hamcrest.StringDescription().appendValue(this.fsa).toString()
       + "\n     filePath is " + new org.hamcrest.StringDescription().appendValue(filePath).toString() + "\n", _should_be);
      
      Map<String,CharSequence> _textFiles_1 = this.fsa.getTextFiles();
      CharSequence _get = _textFiles_1.get(filePath);
      String _string = _get.toString();
      Assert.assertTrue("\nExpected fsa.textFiles.get(filePath).toString should be content but"
       + "\n     fsa.textFiles.get(filePath).toString is " + new org.hamcrest.StringDescription().appendValue(_string).toString()
       + "\n     fsa.textFiles.get(filePath) is " + new org.hamcrest.StringDescription().appendValue(_get).toString()
       + "\n     fsa.textFiles is " + new org.hamcrest.StringDescription().appendValue(_textFiles_1).toString()
       + "\n     fsa is " + new org.hamcrest.StringDescription().appendValue(this.fsa).toString()
       + "\n     filePath is " + new org.hamcrest.StringDescription().appendValue(filePath).toString()
       + "\n     content is " + new org.hamcrest.StringDescription().appendValue(content).toString() + "\n", Should.<String>should_be(_string, content));
      
      _xblockexpression = (true);
    }
    return _xblockexpression;
  }
}
