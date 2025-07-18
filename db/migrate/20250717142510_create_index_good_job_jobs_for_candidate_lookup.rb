# frozen_string_literal: true

class CreateIndexGoodJobJobsForCandidateLookup < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        if connection.index_name_exists?(:good_jobs, :index_good_job_jobs_for_candidate_lookup)
          return
        end
      end
    end

    add_index :good_jobs, %i[priority created_at], order: { priority: 'ASC NULLS LAST', created_at: :asc },
                                                   where: 'finished_at IS NULL', name: :index_good_job_jobs_for_candidate_lookup,
                                                   algorithm: :concurrently
  end
end
