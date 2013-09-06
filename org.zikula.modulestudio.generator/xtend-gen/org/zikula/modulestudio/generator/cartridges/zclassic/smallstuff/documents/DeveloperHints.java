package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.documents;

import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class DeveloperHints {
  public CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("CUSTOMISATION");
    _builder.newLine();
    _builder.append("-------------");
    _builder.newLine();
    _builder.append("He­re are a few short hints which be­co­me hel­pful for cust­o­mi­sing your ge­ne­ra­ted application:");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* Your mo­del is the re­al soft­ware so do all im­portant chan­ges (li­ke ad­ding or mo­ving ta­ble co­lumns) on mo­del le­vel.");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("Do not let your mo­del be­co­me ob­so­le­te, which me­ans lo­sing lots of ad­van­ta­ges.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* Do all cosme­tic en­han­ce­ments by tem­pla­te over­ri­ding:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- pla­cing them in /con­fig/tem­pla­tes/ for ex­amp­le is a good idea for de­ve­lop­ment.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* If you need dis­play-ori­en­ted ad­di­tio­nal lo­gic, sim­ply crea­te a ren­der plu­gin en­cap­su­la­ting your ef­forts");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("in a fi­le which is not af­fec­ted by the ge­ne­ra­tor.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* Per­form lo­gi­cal en­han­ce­ments in the do­main clas­ses.");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("The Base classes contain generated code, while the actual objects extend from them.");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("So you can do all customisations in the empty classes, keeping your manual code separated.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* The controller util class contain some convenience methods which can be ea­si­ly used to enable/disa­ble");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("certain use ca­ses (li­ke view, dis­play, ...) for par­ti­cu­lar ob­ject ty­pes wi­t­hin cust­om con­di­ti­ons.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* Do­cu­ment your chan­ges to sim­pli­fy mer­ging pro­cess af­ter re­ge­ne­ra­ti­on.");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("Be su­re you will need and love it: add so­me fields la­ter on, get a new ge­ne­ra­tor ver­si­on fi­xing");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("so­me bugs cen­tral­ly, benefit from new features, and so on.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* A ver­si­on con­trol sys­tem gi­ves you ano­ther ad­di­tio­nal le­vel of roll­back sa­fe­ty.");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
}
