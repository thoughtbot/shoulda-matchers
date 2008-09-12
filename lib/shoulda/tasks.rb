Dir[File.join(File.basename(__FILE__), 'tasks', '*.rake')].each do |f|
  load f
end