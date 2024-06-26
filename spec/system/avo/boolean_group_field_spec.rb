require "rails_helper"

RSpec.describe "BooleanGroupField", type: :system do
  describe "with regular input" do
    let!(:user) { create :user, roles: {} }

    context "index" do
      it "displays the users name" do
        visit "/admin/resources/users"

        expect(page).to have_text "ROLES"
        expect(page).to have_text "View"
        find("tr[data-resource-id='#{user.to_param}'] [data-field-id='roles']").find("a", text: "View").hover
        sleep 0.1
        wait_for_loaded

        expect(page).to have_text "Administrator"
        expect(page).to have_text "Manager"
        expect(page).to have_text "Writer"
      end
    end

    context "show" do
      it "displays the users roles" do
        visit "/admin/resources/users/#{user.id}"

        show_roles_popup
        sleep 0.1

        expect(page).to have_text "ROLES"
        expect(page).to have_text "Administrator"
        expect(page).to have_text "Manager"
        expect(page).to have_text "Writer"
        expect(page.all(".tippy-content svg")[0][:class]).to have_text "text-red-500"
        expect(page.all(".tippy-content svg")[1][:class]).to have_text "text-red-500"
        expect(page.all(".tippy-content svg")[2][:class]).to have_text "text-red-500"
      end
    end

    context "edit" do
      it "changes the users roles" do
        visit "/admin/resources/users/#{user.id}/edit"

        check "user_roles_admin"
        uncheck "user_roles_manager"
        uncheck "user_roles_writer"

        save

        user_id = page.find('[data-field-id="id"] [data-slot="value"]').text
        user_slug = User.find(user_id).slug
        expect(current_path).to eql "/admin/resources/users/#{user_slug}"

        visit "/admin/resources/users/#{user_slug}"
        show_roles_popup
        sleep 0.1

        expect(page).to have_text "ROLES"
        expect(page).to have_text "Administrator"
        expect(page).to have_text "Manager"
        expect(page).to have_text "Writer"
        expect(page.all(".tippy-content svg")[0][:class]).to have_text "text-green-600"
        expect(page.all(".tippy-content svg")[1][:class]).to have_text "text-red-500"
        expect(page.all(".tippy-content svg")[2][:class]).to have_text "text-red-500"
      end

      it "doesn't affect unspecified options" do
        user.update(roles: user.roles.merge({publisher: true}))

        visit "/admin/resources/users/#{user.id}/edit"

        uncheck "user_roles_admin"
        uncheck "user_roles_manager"
        uncheck "user_roles_writer"

        save

        user.reload
        expect(user.roles).to eql({admin: false, manager: false, publisher: true, writer: false}.with_indifferent_access)
      end
    end
  end
end

def show_roles_popup
  find("[data-field-id='roles']").find("a", text: "View").hover
end
