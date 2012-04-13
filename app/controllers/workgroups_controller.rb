class WorkgroupsController < GroupsController
  unloadable
  skip_before_filter :require_admin, :except => [:new, :create, :destroy]
  before_filter :require_owned_workgroups
  before_filter :allow_find_if_owned, :except => [:index, :new, :create]
  
  def index
    @groups = User.current.workgroups

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = l(:notice_successful_create)
        format.html { redirect_to(workgroups_path) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = l(:notice_successful_update)
        format.html { redirect_to(workgroups_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(workgroups_url) }
      format.xml  { head :ok }
    end
  end

  def add_users
    @group = Group.find(params[:id])
    users = User.find_all_by_id(params[:user_ids])
    @group.users << users if request.post?
    respond_to do |format|
      format.html { redirect_to :controller => 'workgroups', :action => 'edit', :id => @group, :tab => 'users' }
      format.js {
        render(:update) {|page|
          page.replace_html "tab-content-users", :partial => 'workgroups/users'
          users.each {|user| page.visual_effect(:highlight, "user-#{user.id}") }
        }
      }
    end
  end

  def remove_user
    @group = Group.find(params[:id])
    @group.users.delete(User.find(params[:user_id])) if request.post?
    respond_to do |format|
      format.html { redirect_to :controller => 'workgroups', :action => 'edit', :id => @group, :tab => 'users' }
      format.js { render(:update) {|page| page.replace_html "tab-content-users", :partial => 'workgroups/users'} }
    end
  end

  def edit_membership
    @group = Group.find(params[:id])

    if params[:project_ids] # Multiple memberships, one per project
      params[:project_ids].each do |project_id|
        @membership = Member.edit_membership(params[:membership_id], (params[:membership]|| {}).merge(:project_id => project_id), @group)
        @membership.save if request.post?
      end
    else # Single membership
      @membership = Member.edit_membership(params[:membership_id], params[:membership], @group)
      @membership.save if request.post?
    end

    respond_to do |format|
      if @membership.valid?
        format.html { redirect_to :controller => 'workgroups', :action => 'edit', :id => @group, :tab => 'memberships' }
        format.js {
          render(:update) {|page|
            page.replace_html "tab-content-memberships", :partial => 'workgroups/memberships'
            page.visual_effect(:highlight, "member-#{@membership.id}")
          }
        }
      else
        format.js {
          render(:update) {|page|
            page.alert(l(:notice_failed_to_save_members, :errors => @membership.errors.full_messages.join(', ')))
          }
        }
      end
    end
  end

  def destroy_membership
    @group = Group.find(params[:id])
    Member.find(params[:membership_id]).destroy if request.post?
    respond_to do |format|
      format.html { redirect_to :controller => 'workgroups', :action => 'edit', :id => @group, :tab => 'memberships' }
      format.js { render(:update) {|page| page.replace_html "tab-content-memberships", :partial => 'workgroups/memberships'} }
    end
  end
  
  private
  
  def require_owned_workgroups
    return unless require_login
    if !User.current.workgroups.present?
      render_403
      return false
    end
    true
  end
  
  def allow_find_if_owned
    if Group.find(params[:id]).manager != User.current
      render_403
      return false
    end
    true
  end
  
end

