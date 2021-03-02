module Kernel
  # #capture, #silence_stream, and #silence_stderr were removed in rails 5.0,
  # but we keep it them here

  if method_defined?(:capture)
    undef_method :capture
  end

  def capture(stream)
    stream = stream.to_s
    captured_stream = Tempfile.new(stream)
    stream_io = eval("$#{stream}", binding, __FILE__, __LINE__) # rubocop:disable Security/Eval
    origin_stream = stream_io.dup
    stream_io.reopen(captured_stream)

    yield

    stream_io.rewind
    captured_stream.read
  ensure
    captured_stream.unlink
    stream_io.reopen(origin_stream)
  end

  if method_defined?(:silence_stream)
    undef_method :silence_stream
  end

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
    old_stream.close
  end

  if method_defined?(:silence_stderr)
    undef_method :silence_stderr
  end

  def silence_stderr
    silence_stream($stderr) { yield if block_given? }
  end
end
