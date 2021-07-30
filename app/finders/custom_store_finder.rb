class CustomStoreFinder

  def initialize(scope: nil, url: nil)
    @scope = scope || Spree::Store
    @url = url
  end

  def execute
    by_url(scope) || scope.default
  end

  protected

  attr_reader :scope, :url

  def by_url(scope)
    return if url.blank?
 
    scope.where(url: url).first || ::Account.by_subdomain(url).first.spree_store
  end
end
