module RubyHelpers
  def append_to(path, contents)
    in_current_dir do
      File.open(path, 'a') do |file|
        file.puts
        file.puts contents
      end
    end
  end

  def append_to_gemfile(contents)
    append_to('Gemfile', contents)
  end

  def comment_out_gem_in_gemfile(gemname)
    in_current_dir do
      gemfile = File.read('Gemfile')
      gemfile.sub!(/^(\s*)(gem\s*['"]#{gemname})/, "\\1# \\2")
      File.open('Gemfile', 'w'){ |file| file.write(gemfile) }
    end
  end

  def insert_line_after(file_path, line, line_to_insert)
    line += "\n"
    line_to_insert += "\n"

    in_current_dir do
      contents = File.read(file_path)
      index = contents.index(line) + line.length
      contents.insert(index, line_to_insert)
      File.open(file_path, 'w') { |f| f.write(contents) }
    end
  end
end

World(RubyHelpers)
