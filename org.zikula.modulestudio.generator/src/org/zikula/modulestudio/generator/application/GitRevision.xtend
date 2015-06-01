package org.zikula.modulestudio.generator.application

import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.IOException
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Path

class GitRevision {

	def static read() throws IOException {
		val bundle = Activator.getDefault.bundle
		var url = FileLocator.find(bundle, new Path('gitrevision.txt'), null)
		
		if (url === null) {
			url = FileLocator.find(bundle, new Path('src/gitrevision.txt'), null)
			if (url === null) {
				return 'error reading data.'
			}
		}

		var BufferedReader br
		try {
			var fileUrl = FileLocator.toFileURL(url)
			val file = new File(fileUrl.path)
			br = new BufferedReader(new FileReader(file))
			val commit = br.readLine
			if (commit === null) {
				return 'error reading data.'
			}
			commit
		}
		catch (IOException e) {
			// Will happen if the file cannot be read for some reason
			e.printStackTrace
			return 'error reading data.'
		}
		finally {
			br?.close
		}
	}
}
