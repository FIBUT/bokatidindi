# frozen_string_literal: true

ActiveAdmin.register AdminUser do
  permit_params :name, :publisher_id, :role, :email,
                :password, :password_confirmation,
                {
                  admin_user_publishers_attributes: %i[id publisher_id _destroy]
                }

  controller do
    def create
      @resource = AdminUser.create(permitted_params[:admin_user])
      unless @resource.valid?
        flash[:warn] = 'Ekki var hægt að búa notandann til.'
        return render :edit
      end

      redirect_to(
        admin_admin_users_url,
        notice: "Notandinn #{@resource.email} var skráður."
      )
    end

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
        return redirect_to(
          admin_admin_user_path,
          notice: 'Notandinn var uppfærður.'
        )
      end
      flash[:warn] = 'Ekki var hægt að uppfæra notandann'
      render :edit
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
    column :name do |admin_user|
      link_to admin_user.name, admin_admin_user_path(admin_user)
    end
    column :email
    column :role
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :locked_at
    column :publishers
    actions
  end

  filter :name
  filter :email
  filter :publishers, as: :select

  form do |f|
    f.semantic_errors
    inputs 'Grunnupplýsingar' do
      input :name, input_html: { autocomplete: 'off' }
      input :email, input_html: { autocomplete: 'off' }
      input :role, input_html: { autocomplete: 'off' }
    end
    f.has_many(
      :admin_user_publishers, heading: 'Útgefendur', allow_destroy: true
    ) do |up|
      up.input :publisher, required: false
    end
    inputs 'Lykilorð' do
      input :password, required: false
      input :password_confirmation, required: false
    end
    f.actions
  end
end
