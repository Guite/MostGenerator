package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;

@SuppressWarnings("all")
public class Tree {
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  public CharSequence generate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.newLine();
        CharSequence _selectTree = this.selectTree(it);
        _builder.append(_selectTree, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _selectAllTrees = this.selectAllTrees(it);
        _builder.append(_selectAllTrees, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence selectTree(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects tree of ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForCode = this._formattingExtensions.formatForCode(_nameMultiple);
    _builder.append(_formatForCode, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $rootId   Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|ArrayCollection retrieved data array or tree node objects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectTree($rootId = 0, $useJoins = true)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($rootId == 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// return all trees if no specific one has been asked for");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->selectAllTrees($useJoins);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// fetch root node");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$rootNode = $this->selectById($rootId, $useJoins);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// fetch children");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$children = $this->children($rootNode);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// alternatively we could probably select all nodes with root = $rootId");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array_merge(array($rootNode), $children);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectAllTrees(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects all trees at once.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $useJoins Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|ArrayCollection retrieved data array or tree node objects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function selectAllTrees($useJoins = true)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$trees = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$slimMode = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get all root nodes");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$qb = $this->_intBaseQuery(\'tbl.lvl = 0\', \'\', $useJoins, $slimMode);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$query = $this->getQueryFromBuilder($qb);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$rootNodes = $query->getResult();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($rootNodes as $rootNode) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// fetch children");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$children = $this->children($rootNode);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$trees[$rootNode->getId()] = array_merge(array($rootNode), $children);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $trees;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
