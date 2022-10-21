# frozen_string_literal: true

class EnablePgPrewarm < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pg_prewarm'
  end
end
