class SearchController < AuthenticatedController
  include ProjectScoped
  include SearchHelper

  before_action :set_scope

  def index
    # They send start as an index of what rows are shown. So we need to quickly
    # calculate how that equates to a page
    page = (params[:start].to_i / params[:length].to_i) + 1

    @search = Search.new(
      query: params[:q],
      scope: @scope,
      page: page,
      per: params[:length],
      project: current_project
    ).results

    @count = @search.count
    @results = Kaminari.paginate_array(@search).page(page).per(params[:length])
  end

  private
  def set_scope
    @scope = if params[:scope].blank? ||
                  !%{all evidence issues nodes notes}.include?(params[:scope])
               :all
             else
               params[:scope].to_sym
             end
  end
end
