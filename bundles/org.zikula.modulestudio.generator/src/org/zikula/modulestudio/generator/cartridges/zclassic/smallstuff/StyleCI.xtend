package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess

class StyleCI {

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('.styleci.yml', styleci)
    }

    def private styleci(Application it) '''
        preset: symfony

        enabled:
          - short_array_syntax

        disabled:
          - blank_line_before_break
          - blank_line_before_continue
          - blank_line_before_declare
          - blank_line_before_throw
          - blank_line_before_try
          - cast_spaces
          - concat_without_spaces
          - no_blank_lines_after_phpdoc
          - no_blank_lines_after_throw
          - php_unit_fqcn_annotation
          - phpdoc_align
          - phpdoc_no_empty_return
          - phpdoc_scalar
          - phpdoc_separation
          - phpdoc_summary
          - phpdoc_to_comment
          - phpdoc_type_to_var
          - pre_increment
          - single_quote
          - trailing_comma_in_multiline_array
          - unalign_double_arrow
          - unalign_equals

    '''
}
