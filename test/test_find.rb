require 'test/unit'
require 'find'
require 'tmpdir'

class TestFind < Test::Unit::TestCase
  def test_empty
    Dir.mktmpdir {|d|
      a = []
      Find.find(d) {|f| a << f }
      assert_equal([d], a)
    }
  end

  def test_rec
    Dir.mktmpdir {|d|
      File.open("#{d}/a", "w")
      Dir.mkdir("#{d}/b")
      File.open("#{d}/b/a", "w")
      File.open("#{d}/b/b", "w")
      Dir.mkdir("#{d}/c")
      a = []
      Find.find(d) {|f| a << f }
      assert_equal([d, "#{d}/a", "#{d}/b", "#{d}/b/a", "#{d}/b/b", "#{d}/c"], a)
    }
  end

  def test_prune
    Dir.mktmpdir {|d|
      File.open("#{d}/a", "w")
      Dir.mkdir("#{d}/b")
      File.open("#{d}/b/a", "w")
      File.open("#{d}/b/b", "w")
      Dir.mkdir("#{d}/c")
      a = []
      Find.find(d) {|f|
        a << f
        Find.prune if f == "#{d}/b"
      }
      assert_equal([d, "#{d}/a", "#{d}/b", "#{d}/c"], a)
    }
  end

  def test_countup3
    Dir.mktmpdir {|d|
      1.upto(3) {|n| File.open("#{d}/#{n}", "w") }
      a = []
      Find.find(d) {|f| a << f }
      assert_equal([d, "#{d}/1", "#{d}/2", "#{d}/3"], a)
    }
  end

  def test_countdown3
    Dir.mktmpdir {|d|
      3.downto(1) {|n| File.open("#{d}/#{n}", "w") }
      a = []
      Find.find(d) {|f| a << f }
      assert_equal([d, "#{d}/1", "#{d}/2", "#{d}/3"], a)
    }
  end

  def test_unreadable_dir
    Dir.mktmpdir {|d|
      Dir.mkdir(dir = "#{d}/dir")
      File.open(file = "#{dir}/foo", "w")
      begin
        File.chmod(0300, dir)
        a = []
        Find.find(d) {|f| a << f }
        assert_equal([d, dir], a)
      ensure
        File.chmod(0700, dir)
      end
    }
  end

  def test_unsearchable_dir
    Dir.mktmpdir {|d|
      Dir.mkdir(dir = "#{d}/dir")
      File.open(file = "#{dir}/foo", "w")
      begin
        File.chmod(0600, dir)
        a = []
        Find.find(d) {|f| a << f }
        assert_equal([d, dir, file], a)
        assert_raise(Errno::EACCES) { File.lstat(file) }
      ensure
        File.chmod(0700, dir)
      end
    }
  end

end
