ActiveAdmin.register AdminUser do
  permit_params :name, :publisher_id, :role, :email,
                :password, :password_confirmation

  controller do
    def update
      @resource = AdminUser.find(permitted_params[:id])

      password         = permitted_params[:admin_user][:password]
      password_confirm = permitted_params[:admin_user][:password_confirmation]

      if password.blank? && password_confirm.blank?
        @resource.update_without_password(permitted_params[:admin_user])
      else
        @resource.update(permitted_params[:admin_user])
      end

      if @resource.errors.blank?
        redirect_to admin_admin_user_path, notice: 'Notandinn var uppfærður.'
      else
        render :edit
      end
    end
  end

  member_action :lock do
    if resource.lock_access!
      return redirect_to(
        resource_path,
        notice: 'Notandanum hefur verið læst.'
      )
    end
    redirect_to(
      resource_path,
      notice: 'Ekki var hægt að læsa notandanum.'
    )
  end

  member_action :unlock do
    if resource.unlock_access!
      return redirect_to(
        resource_path,
        notice: 'Notandinn hefur verið tekinn úr lás.'
      )
    end
    redirect_to(
      resource_path,
      notice: 'Ekki var hægt að taka notandann úr lás.'
    )
  end

  action_item :lock, only: [:show] do
    if current_admin_user.admin? && !resource.access_locked?
      link_to 'Læsa notanda', "#{admin_admin_user_url}/lock"
    end
  end

  action_item :unlock, only: [:show] do
    if current_admin_user.admin? && resource.access_locked?
      link_to 'Aflæsa notanda', "#{admin_admin_user_url}/unlock"
    end
  end


  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :locked_at
    actions
  end

  filter :name
  filter :email
  filter :role, as: :select
  filter :publisher, as: :select

  form do |f|
    f.semantic_errors
    inputs 'Grunnupplýsingar' do
      input :name
      input :email
    end
    inputs 'Hlutverk' do
      input :publisher
      input :role
    end
    inputs 'Lykilorð' do
      input :password, required: false
      input :password_confirmation, required: false
    end
    f.actions
  end
end