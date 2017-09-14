require "test_helper"
require "open3"

class FeatureTest < Minitest::Test
  def setup
    @stdin, @stdout_and_stderr, @wait_thr = Open3.popen2e("ruby -Ilib exe/rredis")
    Thread.new do
      @stdout_and_stderr.each {|l| puts "> #{l}" }
    end
    sleep 1
  end

  def teardown
    @stdin.close
    @stdout_and_stderr.close
    Process.kill("INT", @wait_thr.pid)
  end

  def test_setting_and_getting
    assert_response "OK", "set foo bar"
    assert_response "bar", "get foo"
  end

  private

  def assert_response(expectation, command)
    assert_equal expectation, %x[ redis-cli #{command} ].strip
  end
end
