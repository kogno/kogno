class Conversation < Kogno::Context

  # before_blocks :do_something_before_blocks
  # after_blocks :do_something_after_blocks

  def do_something_before_blocks
    # This will be called before the blocks method in the current context will be executed
  end

  def do_something_after_blocks
    # This will be called after the blocks method in the current context will be executed
  end

end