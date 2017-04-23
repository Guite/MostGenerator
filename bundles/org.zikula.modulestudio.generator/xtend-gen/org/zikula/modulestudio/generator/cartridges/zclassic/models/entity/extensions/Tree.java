package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.AbstractExtension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.EntityExtensionInterface;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Tree extends AbstractExtension implements EntityExtensionInterface {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  /**
   * Generates additional annotations on class level.
   */
  @Override
  public CharSequence classAnnotations(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("* @Gedmo\\Tree(type=\"");
    String _lowerCase = it.getTree().getLiteral().toLowerCase();
    _builder.append(_lowerCase);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    {
      EntityTreeType _tree = it.getTree();
      boolean _equals = Objects.equal(_tree, EntityTreeType.CLOSURE);
      if (_equals) {
        _builder.append("* @Gedmo\\TreeClosure(class=\"\\");
        String _entityClassName = this._namingExtensions.entityClassName(it, "closure", Boolean.valueOf(false));
        _builder.append(_entityClassName);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  /**
   * Additional field annotations.
   */
  @Override
  public CharSequence columnAnnotations(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  /**
   * Generates additional entity properties.
   */
  @Override
  public CharSequence properties(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @Gedmo\\TreeLeft");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"integer\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Assert\\Type(type=\"integer\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var integer $lft");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $lft;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    {
      boolean _isLoggable_1 = it.isLoggable();
      if (_isLoggable_1) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @Gedmo\\TreeLevel");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"integer\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Assert\\Type(type=\"integer\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var integer $lvl");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $lvl;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    {
      boolean _isLoggable_2 = it.isLoggable();
      if (_isLoggable_2) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @Gedmo\\TreeRight");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"integer\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Assert\\Type(type=\"integer\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var integer $rgt");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $rgt;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    {
      boolean _isLoggable_3 = it.isLoggable();
      if (_isLoggable_3) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Versioned");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @Gedmo\\TreeRoot");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"integer\", nullable=true)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var integer $root");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $root;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Bidirectional - Many children [");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append("] are linked by one parent [");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, " ");
    _builder.append("] (OWNING SIDE).");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Gedmo\\TreeParent");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\ManyToOne(targetEntity=\"\\");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName, " ");
    _builder.append("\", inversedBy=\"children\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\JoinColumn(name=\"parent_id\", referencedColumnName=\"");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(IterableExtensions.<DerivedField>head(this._modelExtensions.getPrimaryKeyFields(it)).getName());
    _builder.append(_formatForDisplay_2, " ");
    _builder.append("\", onDelete=\"SET NULL\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var \\");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, " ");
    _builder.append(" $parent");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $parent;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Bidirectional - One parent [");
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_3, " ");
    _builder.append("] has many children [");
    String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_4, " ");
    _builder.append("] (INVERSE SIDE).");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\OneToMany(targetEntity=\"\\");
    String _entityClassName_2 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_2, " ");
    _builder.append("\", mappedBy=\"parent\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\OrderBy({\"lft\" = \"ASC\"})");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var \\");
    String _entityClassName_3 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_3, " ");
    _builder.append(" $children");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $children;");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * Generates additional accessor methods.
   */
  @Override
  public CharSequence accessors(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final FileHelper fh = new FileHelper();
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods = fh.getterAndSetterMethods(it, "lft", "integer", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods);
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_1 = fh.getterAndSetterMethods(it, "lvl", "integer", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_1);
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_2 = fh.getterAndSetterMethods(it, "rgt", "integer", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_2);
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_3 = fh.getterAndSetterMethods(it, "root", "integer", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_3);
    _builder.newLineIfNotEmpty();
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    String _plus = ("\\" + _entityClassName);
    CharSequence _terAndSetterMethods_4 = fh.getterAndSetterMethods(it, "parent", _plus, Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(true), "null", "");
    _builder.append(_terAndSetterMethods_4);
    _builder.newLineIfNotEmpty();
    CharSequence _terAndSetterMethods_5 = fh.getterAndSetterMethods(it, "children", "array", Boolean.valueOf(true), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_5);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Returns the extension class type.
   */
  @Override
  public String extensionClassType(final Entity it) {
    String _xifexpression = null;
    EntityTreeType _tree = it.getTree();
    boolean _equals = Objects.equal(_tree, EntityTreeType.CLOSURE);
    if (_equals) {
      _xifexpression = "closure";
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
  
  /**
   * Returns the extension class import statements.
   */
  @Override
  public String extensionClassImports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("use Gedmo\\Tree\\Entity\\MappedSuperclass\\");
    String _extensionBaseClass = this.extensionBaseClass(it);
    _builder.append(_extensionBaseClass);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    return _builder.toString();
  }
  
  /**
   * Returns the extension base class.
   */
  @Override
  public String extensionBaseClass(final Entity it) {
    return "AbstractClosure";
  }
  
  /**
   * Returns the extension class description.
   */
  @Override
  public String extensionClassDescription(final Entity it) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Entity extension domain class storing " + _formatForDisplay);
    return (_plus + " tree closures.");
  }
}
