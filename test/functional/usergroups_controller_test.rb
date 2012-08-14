require 'test_helper'

class UsergroupsControllerTest < ActionController::TestCase
  setup do
    @usergroup = usergroups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:usergroups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create usergroup" do
    assert_difference('Usergroup.count') do
      post :create, usergroup: { description: @usergroup.description, forumpermissions: @usergroup.forumpermissions, title: @usergroup.title, usertitle: @usergroup.usertitle }
    end

    assert_redirected_to usergroup_path(assigns(:usergroup))
  end

  test "should show usergroup" do
    get :show, id: @usergroup
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @usergroup
    assert_response :success
  end

  test "should update usergroup" do
    put :update, id: @usergroup, usergroup: { description: @usergroup.description, forumpermissions: @usergroup.forumpermissions, title: @usergroup.title, usertitle: @usergroup.usertitle }
    assert_redirected_to usergroup_path(assigns(:usergroup))
  end

  test "should destroy usergroup" do
    assert_difference('Usergroup.count', -1) do
      delete :destroy, id: @usergroup
    end

    assert_redirected_to usergroups_path
  end
end
