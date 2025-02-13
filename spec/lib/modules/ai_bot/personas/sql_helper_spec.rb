# frozen_string_literal: true

RSpec.describe DiscourseAi::AiBot::Personas::SqlHelper do
  let :sql_helper do
    subject
  end

  it "renders schema" do
    prompt = sql_helper.render_system_prompt
    expect(prompt).to include("posts(")
    expect(prompt).to include("topics(")
    expect(prompt).not_to include("translation_key") # not a priority table
    expect(prompt).to include("user_api_keys") # not a priority table

    expect(sql_helper.available_commands).to eq([DiscourseAi::AiBot::Commands::DbSchemaCommand])
  end
end
