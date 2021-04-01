defmodule BrothTest.Message.Chat.SendMsgTest do
  use ExUnit.Case, async: true

  alias Broth.Message.Types.ChatToken
  alias Broth.Message.Chat.SendMsg

  describe "when you send a send_msg message" do
    test "it populates userId" do
      assert {:ok,
              %{
                payload: %SendMsg{
                  tokens: [
                    %ChatToken{
                      type: :text,
                      value: "foobar"
                    }
                  ]
                }
              }} =
               Broth.Message.validate(%{
                 "operator" => "chat:send_msg",
                 "payload" => %{
                   "tokens" => [
                     %{
                       "type" => "text",
                       "value" => "foobar"
                     }
                   ]
                 }
               })

      # short form also allowed
      assert {:ok,
              %{
                payload: %SendMsg{
                  tokens: [
                    %ChatToken{
                      type: :text,
                      value: "foobar"
                    }
                  ]
                }
              }} =
               Broth.Message.validate(%{
                 "op" => "chat:send_msg",
                 "p" => %{
                   "tokens" => [
                     %{
                       "type" => "text",
                       "value" => "foobar"
                     }
                   ]
                 }
               })
    end

    test "empty list is forbidden" do
      assert {:error, %{errors: [tokens: {"must not be empty", _}]}} =
               Broth.Message.validate(%{
                 "operator" => "chat:send_msg",
                 "payload" => %{
                   "tokens" => []
                 }
               })
    end

    test "non-lists are forbidden" do
      assert {:error, %{errors: [tokens: {"is invalid", _}]}} =
               Broth.Message.validate(%{
                 "operator" => "chat:send_msg",
                 "payload" => %{
                   "tokens" => "foo"
                 }
               })

      assert {:error, %{errors: [tokens: {"is invalid", _}]}} =
               Broth.Message.validate(%{
                 "operator" => "chat:send_msg",
                 "payload" => %{
                   "tokens" => %{"foo" => "bar"}
                 }
               })
    end

    @message_character_limit Application.compile_env!(:kousa, :message_character_limit)

    test "a message that's too long fails" do
      too_long_message =
        List.duplicate(
          %{"type" => "text", "value" => "a"},
          @message_character_limit + 1
        )

      assert {:error, %{errors: [tokens: {"combined length too long", _}]}} =
               Broth.Message.validate(%{
                 "operator" => "chat:send_msg",
                 "payload" => %{
                   "tokens" => too_long_message
                 }
               })
    end

    test "a message with invalid tokens are forbidden" do
      assert {:error, %{errors: [tokens: {"is invalid", _}]}} =
               Broth.Message.validate(%{
                 "operator" => "chat:send_msg",
                 "payload" => %{
                   "tokens" => ["a"]
                 }
               })
    end
  end
end