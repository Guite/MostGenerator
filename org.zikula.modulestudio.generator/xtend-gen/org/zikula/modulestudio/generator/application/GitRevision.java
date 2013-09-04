package org.zikula.modulestudio.generator.application;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.URL;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.osgi.framework.Bundle;
import org.zikula.modulestudio.generator.application.Activator;

@SuppressWarnings("all")
public class GitRevision {
  public static String read() throws IOException {
    String _xblockexpression = null;
    {
      Activator _default = Activator.getDefault();
      final Bundle bundle = _default.getBundle();
      Path _path = new Path("gitrevision.txt");
      URL url = FileLocator.find(bundle, _path, null);
      boolean _tripleEquals = (url == null);
      if (_tripleEquals) {
        Path _path_1 = new Path("src/gitrevision.txt");
        URL _find = FileLocator.find(bundle, _path_1, null);
        url = _find;
        boolean _tripleEquals_1 = (url == null);
        if (_tripleEquals_1) {
          return "error reading data.";
        }
      }
      BufferedReader br = null;
      String _xtrycatchfinallyexpression = null;
      try {
        String _xblockexpression_1 = null;
        {
          URL fileUrl = FileLocator.toFileURL(url);
          String _path_2 = fileUrl.getPath();
          File _file = new File(_path_2);
          final File file = _file;
          FileReader _fileReader = new FileReader(file);
          BufferedReader _bufferedReader = new BufferedReader(_fileReader);
          br = _bufferedReader;
          final String commit = br.readLine();
          boolean _tripleEquals_2 = (commit == null);
          if (_tripleEquals_2) {
            return "error reading data.";
          }
          _xblockexpression_1 = (commit);
        }
        _xtrycatchfinallyexpression = _xblockexpression_1;
      } catch (final Throwable _t) {
        if (_t instanceof IOException) {
          final IOException e = (IOException)_t;
          e.printStackTrace();
          return "error reading data.";
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      } finally {
        if (br!=null) {
          br.close();
        }
      }
      _xblockexpression = (_xtrycatchfinallyexpression);
    }
    return _xblockexpression;
  }
}
