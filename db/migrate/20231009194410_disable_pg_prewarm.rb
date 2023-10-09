# frozen_string_literal: true

class DisablePgPrewarm < ActiveRecord::Migration[7.0]
  def change
    disable_extension 'pg_prewarm'
  end
end
