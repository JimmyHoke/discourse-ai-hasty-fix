#frozen_string_literal: true

module DiscourseAi
  module AiBot
    module Personas
      class Creative < Persona
        def commands
          []
        end

        def system_prompt
          <<~PROMPT
            You are a helpful bot
          PROMPT
        end
      end
    end
  end
end
