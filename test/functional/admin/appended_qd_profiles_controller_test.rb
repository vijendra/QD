require 'test_helper'

class Admin::AppendedQdProfilesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_appended_qd_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create appended_qd_profile" do
    assert_difference('Admin::AppendedQdProfile.count') do
      post :create, :appended_qd_profile => { }
    end

    assert_redirected_to appended_qd_profile_path(assigns(:appended_qd_profile))
  end

  test "should show appended_qd_profile" do
    get :show, :id => admin_appended_qd_profiles(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => admin_appended_qd_profiles(:one).to_param
    assert_response :success
  end

  test "should update appended_qd_profile" do
    put :update, :id => admin_appended_qd_profiles(:one).to_param, :appended_qd_profile => { }
    assert_redirected_to appended_qd_profile_path(assigns(:appended_qd_profile))
  end

  test "should destroy appended_qd_profile" do
    assert_difference('Admin::AppendedQdProfile.count', -1) do
      delete :destroy, :id => admin_appended_qd_profiles(:one).to_param
    end

    assert_redirected_to admin_appended_qd_profiles_path
  end
end
