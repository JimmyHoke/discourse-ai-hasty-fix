# frozen_string_literal: true

class CompletionPrompt < ActiveRecord::Base
  # TODO(roman): Remove sept 2023.
  self.ignored_columns = ["value"]

  enum :prompt_type, { text: 0, list: 1, diff: 2 }

  validates :messages, length: { maximum: 20 }
  validate :each_message_length

  def messages_with_user_input(user_input)
    return messages unless user_input.present?

    if user_input[:custom_prompt].present?
      case ::DiscourseAi::AiHelper::LlmPrompt.new.enabled_provider
      when "huggingface"
        self.messages.each { |msg| msg.sub!("{{custom_prompt}}", user_input[:custom_prompt]) }
      else
        self.messages.each do |msg|
          msg["content"].sub!("{{custom_prompt}}", user_input[:custom_prompt])
        end
      end
    end

    case ::DiscourseAi::AiHelper::LlmPrompt.new.enabled_provider
    when "openai"
      self.messages << { role: "user", content: user_input[:text] }
    when "anthropic"
      self.messages << { "role" => "Input", "content" => "<input>#{user_input[:text]}</input>" }
    when "huggingface"
      self.messages.first.sub("{{user_input}}", user_input[:text])
    end
  end

  private

  def each_message_length
    messages.each_with_index do |msg, idx|
      next if msg["content"].length <= 1000

      errors.add(:messages, I18n.t("errors.prompt_message_length", idx: idx + 1))
    end
  end
end

# == Schema Information
#
# Table name: completion_prompts
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  translated_name :string
#  prompt_type     :integer          default("text"), not null
#  enabled         :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  messages        :jsonb
#  provider        :text
#
# Indexes
#
#  index_completion_prompts_on_name  (name)
#
