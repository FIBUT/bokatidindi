# frozen_string_literal: true

class IndexesController < ApplicationController
  def publishers
    edition = Edition.current.first
    @publishers_by_first_initial = edition.publishers_by_first_initial
  end

  def authors
    edition = Edition.current.first
    @authors_by_first_initial = edition.authors_by_first_initial
  end
end
