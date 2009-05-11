require 'test_helper'

class DealersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dealers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dealers" do
    assert_difference('Dealers.count') do
      post :create, :dealers => { }
    end

    assert_redirected_to dealers_path(assigns(:dealers))
  end

  test "should show dealers" do
    get :show, :id => dealers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => dealers(:one).to_param
    assert_response :success
  end

  test "should update dealers" do
    put :update, :id => dealers(:one).to_param, :dealers => { }
    assert_redirected_to dealers_path(assigns(:dealers))
  end

  test "should destroy dealers" do
    assert_difference('Dealers.count', -1) do
      delete :destroy, :id => dealers(:one).to_param
    end

    assert_redirected_to dealers_path
  end
end
