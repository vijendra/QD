require 'test_helper'

class Admin::DataAppendsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_data_appends)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create data_append" do
    assert_difference('Admin::DataAppend.count') do
      post :create, :data_append => { }
    end

    assert_redirected_to data_append_path(assigns(:data_append))
  end

  test "should show data_append" do
    get :show, :id => admin_data_appends(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => admin_data_appends(:one).to_param
    assert_response :success
  end

  test "should update data_append" do
    put :update, :id => admin_data_appends(:one).to_param, :data_append => { }
    assert_redirected_to data_append_path(assigns(:data_append))
  end

  test "should destroy data_append" do
    assert_difference('Admin::DataAppend.count', -1) do
      delete :destroy, :id => admin_data_appends(:one).to_param
    end

    assert_redirected_to admin_data_appends_path
  end
end
