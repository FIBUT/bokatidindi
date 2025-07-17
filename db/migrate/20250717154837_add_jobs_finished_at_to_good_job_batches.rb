# frozen_string_literal: true

class AddJobsFinishedAtToGoodJobBatches < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        if connection.column_exists?(:good_job_batches, :jobs_finished_at)
          return
        end
      end
    end

    change_table :good_job_batches do |t|
      t.datetime :jobs_finished_at
    end
  end
end
