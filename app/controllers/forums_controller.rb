class ForumsController < ApplicationController
  before_filter :check_permission, only: [:show, :edit, :update]

  def index
     @groups = Forumgroup.select {|g| g.can_read?(current_user) }
     @groups.sort_by!{|g| g[:position]}
  end

  def show
    @threads = @forum.forumthreads.order("sticky desc, updated_at desc")
  end

  def edit
  end

  def new
    if admin?
      @forum = Forum.new(forumgroup: @group)
      @forum.forumgroup = Forumgroup.find(params[:forumgroup])
    else
      flash[:alert] = "You are not allowed to create a forum."
      redirect_to forums_path
    end
  end

  def update
    if admin?
      if @forum.update_attributes(forum_params)
        flash[:notice] = "Forum updated"
        redirect_to @forum
      else
        flash[:alert] = "Something went wrong"
      end
    else
      flash[:alert] = "You are not allowed to change a forum"
      redirect_to @forum
    end
  end

  def create
    if admin?
      @forum = Forum.new(forum_params([:forumgroup_id]))
      if @forum.save
        flash[:notice] = "Forum created."
        redirect_to @forum
      else
        flash[:alert] = "Something went wrong"
        render :new
      end
    else
      flash[:alert] = "You are not allowed to create a forum."
      redirect_to forums_path
    end
  end


  private

  def check_permission
    @forum = Forum.find(params[:id])
    unless @forum.can_read?(current_user)
      flash[:alert] = "You are not allowed to view this forum"
      redirect_to forums_path
    end
  end

  def forum_params(add = [])
    a = [:name, :position, :role_read_id, :role_write_id] + add
    params.require(:forum).permit(a)
  end
end