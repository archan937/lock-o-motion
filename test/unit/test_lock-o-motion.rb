require File.expand_path("../../test_helper", __FILE__)

module Unit
  class TestLockOMotion < MiniTest::Unit::TestCase

    describe LockOMotion do
      it "should skip certain files for requirement" do
        silence do
          assert_equal true , LockOMotion.skip?("pry")
          assert_equal true , LockOMotion.skip?("openssl")
          assert_equal false, LockOMotion.skip?("slot_machine")
        end
      end

      it "should mock paths when possible" do
        assert_equal "lock-o-motion/mocks/httparty", LockOMotion.mock_path("httparty")
        assert_equal nil, LockOMotion.mock_path("slot_machine")
      end
    end

  end
end