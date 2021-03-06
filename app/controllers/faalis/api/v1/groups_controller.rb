require_dependency "faalis/api_controller"

module Faalis
  class API::V1::GroupsController < ::APIController
    # TODO: Use strong params
    # TODO: implement authorization

    # GET /api/v1/groups
    def index
      @groups = Group.includes(:permissions).to_a
      authorize! :read, Faalis::Group
      respond_with(@groups)
    end

    def create
      authorize! :create, Faalis::Group

      permissions = [];

      (params[:permissions] || []).each do |perm_string|
        perm, model = perm_string.split "|"
        permission = Permission.find_or_create_by_model_and_permission_type(model, perm)
        permissions << permission
      end

      @group = Group.new({
                           name: params[:name],
                           permissions: permissions,
                         })
      if @group.save
        respond_with(@group)
      else
        respond_to do |format|
          format.json { render :json => {:fields => @group.errors}, :status => :unprocessable_entity }
        end
      end
    end

    def show
      @group = Group.find(params[:id])
      authorize! :read, @group
      respond_with(@group)
    end

    def update

      @group = Group.find(params[:id])
      authorize! :update, @group

      permissions = [];
      (params[:permissions] || []).each do |perm_string|
        perm, model = perm_string.split "|"
        permission = Permission.find_or_create_by_model_and_permission_type(model, perm)
        permissions << permission
      end

      if @group.update(:name => params[:name],
                    :permissions => permissions)
        respond_with(@group)
      else
        respond_to do |format|
          format.json { render :json => {:fields => @group.errors}, :status => :unprocessable_entity }
        end
      end
    end

    def destroy
      ids = params[:id].split(",")
      @groups = Group.where(:id => ids)
      authorize! :destory, @groups
      @groups.destroy_all
    end
  end

end
