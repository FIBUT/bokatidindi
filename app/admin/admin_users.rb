# frozen_string_literal: true

ActiveAdmin.register AdminUser do
  permit_params do
    params = %i[email password password_confirmation]
    if current_admin_user.admin?
      params << %i[name publisher_id role]
      params << {
        admin_user_publishers_attributes: %i[id publisher_id _destroy]
      }
    end
  end

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

      permitted_params[:admin_user][
          :admin_user_publishers_attributes
        ]&.each do |aup|
          if aup[1]['_destroy'].to_i == 1
            AdminUserPublisher.find(aup[1]['id']).destroy
          end
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
    return false unless current_admin_user.admin?

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
    return false unless current_admin_user.admin?

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

  filter :name_cont, label: 'Nafn inniheldur'
  filter :email_cont, label: 'Tölvupótfang inniheldur'
  filter :publishers, as: :select
  filter :role, as: :check_boxes, collection: AdminUser.roles

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
    actions
  end

  form do |f|
    f.semantic_errors
    inputs 'Grunnupplýsingar' do
      if current_admin_user.admin?
        input :name, input_html: { autocomplete: 'off' }
      end
      input :email, input_html: { autocomplete: 'off' }
      if current_admin_user.admin?
        input :role, input_html: { autocomplete: 'off' }
      end
    end
    if current_admin_user.admin?
      f.has_many(
        :admin_user_publishers, heading: 'Útgefendur', allow_destroy: true
      ) do |up|
        up.input :publisher, required: false
      end
    end
    inputs 'Lykilorð' do
      input :password, required: false
      input :password_confirmation, required: false
    end
    f.actions
  end
end
