class MobileIssuesController < MobileController
  unloadable
  
  helper :application
  include ApplicationHelper
  
  helper :issues
  include IssuesHelper
  
  helper :queries
  include QueriesHelper
  
  helper :sort
  include SortHelper
    
  accept_api_auth :show, :index
  
  before_filter :find_issue, :only => [:show]
  before_filter :authorize, :except => [:index]
  
  def index
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      @offset, @limit = api_offset_and_limit
      @issue_count = @query.issue_count
      @issue_pages = Paginator.new @issue_count, @limit, params['page']
      @offset ||= @issue_pages.offset
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                              :order => sort_clause,
                              :offset => @offset,
                              :limit => @limit)      

      respond_to do |format|        
        format.api  {
          Issue.load_visible_relations(@issues) if include_in_api_response?('relations')
        }        
      end
    else
      respond_to do |format|        
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def show  
    if include_in_api_response?('relations')
      @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
    end
    
    if include_in_api_response?('journals')
      @journals = @issue.journals.includes(:user, :details).reorder("#{Journal.table_name}.id ASC").all
      @journals.each_with_index {|j,i| j.indice = i+1}
      @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
      @journals.reverse! if User.current.wants_comments_in_reverse_order?
    end
    
    if include_in_api_response?('statuses')
      @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    end
    
    if include_in_api_response?('assignables')
      @assignables = @issue.assignable_users
    end
    
    respond_to do |format|      
      format.api      
    end
  end
      
end
