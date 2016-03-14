module Kernel
  # #capture, #silence_stream, and #silence_stderr are deprecated after Rails
  # 4.2 and will be removed in 5.0, so just override them completely here

  def capture(stream)
    stream = stream.to_s
    captured_stream = Tempfile.new(stream)
    stream_io = eval("$#{stream}")
    origin_stream = stream_io.dup
    stream_io.reopen(captured_stream)

    yield

    stream_io.rewind
    return captured_stream.read
  ensure
    captured_stream.unlink
    stream_io.reopen(origin_stream)
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

  def silence_stderr
    silence_stream(STDERR) { yield }
  end
end
