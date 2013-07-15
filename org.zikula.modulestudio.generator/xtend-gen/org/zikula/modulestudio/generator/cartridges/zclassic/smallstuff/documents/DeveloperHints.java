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
    _builder.append("He\u00ADre are a few short hints which be\u00ADco\u00ADme hel\u00ADpful for cust\u00ADo\u00ADmi\u00ADsing your ge\u00ADne\u00ADra\u00ADted application:");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* Your mo\u00ADdel is the re\u00ADal soft\u00ADware so do all im\u00ADportant chan\u00ADges (li\u00ADke ad\u00ADding or mo\u00ADving ta\u00ADble co\u00ADlumns) on mo\u00ADdel le\u00ADvel.");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("Do not let your mo\u00ADdel be\u00ADco\u00ADme ob\u00ADso\u00ADle\u00ADte, which me\u00ADans lo\u00ADsing lots of ad\u00ADvan\u00ADta\u00ADges.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* Do all cosme\u00ADtic en\u00ADhan\u00ADce\u00ADments by tem\u00ADpla\u00ADte over\u00ADri\u00ADding:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("- pla\u00ADcing them in /con\u00ADfig/tem\u00ADpla\u00ADtes/ for ex\u00ADamp\u00ADle is a good idea for de\u00ADve\u00ADlop\u00ADment.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* If you need dis\u00ADplay-ori\u00ADen\u00ADted ad\u00ADdi\u00ADtio\u00ADnal lo\u00ADgic, sim\u00ADply crea\u00ADte a ren\u00ADder plu\u00ADgin en\u00ADcap\u00ADsu\u00ADla\u00ADting your ef\u00ADforts");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("in a fi\u00ADle which is not af\u00ADfec\u00ADted by the ge\u00ADne\u00ADra\u00ADtor.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* Per\u00ADform lo\u00ADgi\u00ADcal en\u00ADhan\u00ADce\u00ADments in the do\u00ADmain clas\u00ADses.");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("The Base classes contain generated code, while the actual objects extend from them.");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("So you can do all customisations in the empty classes, keeping your manual code separated.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* The controller util class contain some convenience methods which can be ea\u00ADsi\u00ADly used to enable/disa\u00ADble");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("certain use ca\u00ADses (li\u00ADke view, dis\u00ADplay, ...) for par\u00ADti\u00ADcu\u00ADlar ob\u00ADject ty\u00ADpes wi\u00ADt\u00ADhin cust\u00ADom con\u00ADdi\u00ADti\u00ADons.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* Do\u00ADcu\u00ADment your chan\u00ADges to sim\u00ADpli\u00ADfy mer\u00ADging pro\u00ADcess af\u00ADter re\u00ADge\u00ADne\u00ADra\u00ADti\u00ADon.");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("Be su\u00ADre you will need and love it: add so\u00ADme fields la\u00ADter on, get a new ge\u00ADne\u00ADra\u00ADtor ver\u00ADsi\u00ADon fi\u00ADxing");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("so\u00ADme bugs cen\u00ADtral\u00ADly, benefit from new features, and so on.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("* A ver\u00ADsi\u00ADon con\u00ADtrol sys\u00ADtem gi\u00ADves you ano\u00ADther ad\u00ADdi\u00ADtio\u00ADnal le\u00ADvel of roll\u00ADback sa\u00ADfe\u00ADty.");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
}
