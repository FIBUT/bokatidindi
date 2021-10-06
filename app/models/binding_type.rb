class BindingType < ApplicationRecord
  default_scope { order('rod ASC, name ASC') }

  before_create :set_slug

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
