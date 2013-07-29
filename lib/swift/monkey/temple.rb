if Padrino.env == :development
  module Temple
    module HTML
      class Pretty
        def on_dynamic(code)
          if @pretty
            tmp = unique_name
            indent_code = ''
            indent_code << "#{tmp} = #{tmp}.sub(/\\A\\s*\\n?/, \"\\n\"); " #if options[:indent_tags].include?(@last)
            indent_code << "#{tmp} = #{tmp}.gsub(\"\n\", #{indent.inspect}); "
            if ''.respond_to?(:html_safe)
              safe = unique_name
              # we have to first save if the string was html_safe
              # otherwise the gsub operation will lose that knowledge
              indent_code = "#{safe} = #{tmp}.html_safe?; #{indent_code}#{tmp} = #{tmp}.html_safe if #{safe}; "
            end
            @last = :dynamic
            [:multi,
             [:code, "#{tmp} = (#{code}).to_s"],
             [:code, "if #{@pre_tags_name} !~ #{tmp}; #{indent_code}end"],
             [:dynamic, tmp]]
          else
            [:dynamic, code]
          end
        end
      end
    end
  end
end
